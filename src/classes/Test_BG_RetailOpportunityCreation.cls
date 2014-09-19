/*************************************************
Test_BG_RetailOpportunityCreation

Test class for BG_RetailOpportunity trigger helper

Author: Steve Loftus (BrightGen)
Created Date: 04/09/2014
Modification Date:
Modified By:

**************************************************/
@isTest
private class Test_BG_RetailOpportunityCreation {
	
	/* 
		this method tests that when a prospect is converted a reatil opportunity is created
	*/		
	static testmethod void testRetailOpportunityCreation() {

		// set up a runas user to insert the prospect
		User insertUser = BG_LeadManagementTestHelper.getUser('insertemail@address.com', 'insertuser@vertu.com.retaildev', 'inu', null, null);
        insert insertUser;

		Lead prospect;
		User storeManager;
		Prospect_Management__c prospectManagementConfiguration;
		// create the account, contact and community user and the propsect under the insert user
		// this is need to create a community user
		// also we want the prospect to be created by a user so we know the reassignment works
		system.RunAs(insertUser) {

			// create the custom settings
			prospectManagementConfiguration = new Prospect_Management__c();
			prospectManagementConfiguration.Name = 'en_US';
			prospectManagementConfiguration.Prospect_Status__c = 'Closed - Customer (Converted)';
			prospectManagementConfiguration.Retail_Opportunity_Status__c = 'Open';
			insert prospectManagementConfiguration;

			// set up an account
			Account store = UnitTestHelper.GetRetailAccount('Test Store', '123', 'Retail Store');
			insert store;		

			// set up a contact
			Contact managerContact = new Contact();
			managerContact.AccountId = store.Id;
			managerContact.LastName = 'Manager';
			insert managerContact;

			// get the partner profile
			Id communityProfileId = [select Id from profile where name = 'Vertu Retail Community EPOS' limit 1].Id;

			// set up a portal user
			storeManager = BG_LeadManagementTestHelper.getUser('theManager@address.com', 'theManager@vertu.com.retaildev', 'theMan', communityProfileId, 'None');
			storeManager.ContactId = managerContact.Id;
			storeManager.CommunityNickName = 'theBoss';
			storeManager.Retail_Store_Role__c = 'Manager';
			insert storeManager;

			// test that the inserted store manager is portal enabled
			System.assert([select isPortalEnabled from user where id = :storeManager.id].isPortalEnabled, 'User was not flagged as portal enabled.'); 
			System.assertEquals(communityProfileId, [select ProfileId from user where id = :storeManager.id].ProfileId, 'User does not have the portal profile.'); 

			// set up a new prospect and insert it
			prospect = BG_LeadManagementTestHelper.getLead(Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vertu Retail Lead').getRecordTypeId(), store.Id);
			insert prospect;
		}

		// reselect the prospect
		prospect = [select Id, CreatedDate, OwnerId from Lead where Id = : prospect.Id limit 1];

		// assert the owner has changed to the portal user
		System.assertEquals(storeManager.Id, prospect.OwnerId, 'The new Propect has not been assigned to the Store Manager.');

		Database.LeadConvertResult leadConvertResult;

		system.RunAs(storeManager) {		
			// convert the prospect
			Database.LeadConvert leadConvert = new Database.LeadConvert();
			leadConvert.setLeadId(prospect.Id);
			leadConvert.setDoNotCreateOpportunity(true);

			LeadStatus convertStatus = [select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
			leadConvert.setConvertedStatus(convertStatus.MasterLabel);

			Test.startTest();
			leadConvertResult = Database.convertLead(leadConvert);
			Test.stopTest();
		}

		System.assertEquals(true, leadConvertResult.isSuccess(), 'The prospect has failed to convert');

		// reselect the prospect
		prospect = [select Id, ConvertedAccountId, ConvertedContactId, OwnerId, Boutique_SFID__c from Lead where Id = : prospect.Id limit 1];		

		// select the Customer created from the conversion
		Account customer = [select Id, Type, Boutique__pc from Account where Id = : prospect.ConvertedAccountId limit 1];
		// assert we got one
		System.assertEquals('Owner', customer.Type, 'The type has not been set to Owner');
		System.assertEquals(prospect.Boutique_SFID__c, customer.Boutique__pc, 'The boutique has not been set');

		// select a retail opportunity
		Retail_Opportunities__c retailOpportunity = [select Id, OwnerId, Customer__c, Boutique_Name__c, Prospect_Status__c from Retail_Opportunities__c where Customer__c = : prospect.ConvertedContactId limit 1];

		// assert we got one
		System.assertNotEquals(null, retailOpportunity.Id, 'A Retail Opportunity has not been created');
		System.assertEquals(prospectManagementConfiguration.Retail_Opportunity_Status__c, retailOpportunity.Prospect_Status__c, 'The retail opportunity prospect status not set to Open');
		System.assertEquals(prospect.OwnerId, retailOpportunity.OwnerId, 'The retail opportunity owner id not set to the store manager');
		System.assertEquals(prospect.ConvertedContactId, retailOpportunity.Customer__c, 'The retail opportunity customer not set to the contact');
		System.assertEquals(prospect.Boutique_SFID__c, retailOpportunity.Boutique_Name__c, 'The retail opportunity boutique name not set to the store');
	}
}