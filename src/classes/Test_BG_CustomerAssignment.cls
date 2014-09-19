/*************************************************
Test_BG_CustomerAssignment

Test class for BG_CustomerAssignment trigger helper

Author: Steve Loftus (BrightGen)
Created Date: 05/09/2014
Modification Date: 11/09/2014
Modified By: Steve Loftus (BrightGen)

**************************************************/
@isTest
private class Test_BG_CustomerAssignment {
	
	// tests that customer records for newly imported sales record get assigned to the manager of the boutique identified in the sale records
	static testmethod void testCustomerAssignmentViaSaleInsert() {

		// set up a runas user to insert the prospect
		User insertUser = BG_LeadManagementTestHelper.getUser('insertemail@address.com', 'insertuser@vertu.com.retaildev', 'inu', null, null);
        insert insertUser;

		Lead prospect;
		User storeManager;
		Account store;
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
			store = UnitTestHelper.GetRetailAccount('Test Store', '123', 'Retail Store');
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

		// assert the task has been linked to the prospect
		Task callReminderTask = [select WhoId, ReminderDateTime from Task where OwnerId = : storeManager.Id limit 1];
		system.assertEquals(prospect.Id, callReminderTask.WhoId, 'The task has not been linked to the Prospect');

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
		Account customer = [select Id, OwnerId, Type, Boutique__pc from Account where Id = : prospect.ConvertedAccountId limit 1];
		// assert we got one
		System.assertEquals('Owner', customer.Type, 'The type has not been set to Owner');
		system.assertEquals(storeManager.Id, customer.OwnerId, 'The owner of the customer is not set to the store manager');
		System.assertEquals(prospect.Boutique_SFID__c, customer.Boutique__pc, 'The boutique has not been set');

		// select a retail opportunity
		Retail_Opportunities__c retailOpportunity = [select Id, OwnerId, Customer__c, Boutique_Name__c, Prospect_Status__c from Retail_Opportunities__c where Customer__c = : prospect.ConvertedContactId limit 1];

		// assert we got one
		System.assertNotEquals(null, retailOpportunity.Id, 'A Retail Opportunity has not been created');
		System.assertEquals(prospectManagementConfiguration.Retail_Opportunity_Status__c, retailOpportunity.Prospect_Status__c, 'The retail opportunity prospect status not set to Open');
		System.assertEquals(prospect.OwnerId, retailOpportunity.OwnerId, 'The retail opportunity owner id not set to the store manager');
		System.assertEquals(prospect.ConvertedContactId, retailOpportunity.Customer__c, 'The retail opportunity customer not set to the contact');
		System.assertEquals(prospect.Boutique_SFID__c, retailOpportunity.Boutique_Name__c, 'The retail opportunity boutique name not set to the store');

		system.RunAs(insertUser) {

			// change the owner of the customer to the insert guy
			customer.OwnerId = insertUser.Id;
			update customer;

			// reselect the customer
			customer = [select OwnerId from Account where Id = : customer.Id limit 1];
			// assert that he is the owner
			system.assertEquals(insertUser.Id, customer.OwnerId, 'The customer is not owned by the insert user.');

			// insert a sale record linked to that customer
			Sale__c newSale = new Sale__c();
			newSale.Boutique_Name__c = store.Id;
			newSale.Account_Name__c = customer.Id;
			insert newSale;
		}

		// assert that the customer has changed ownership to the store manager
		// reselect the customer
		customer = [select OwnerId from Account where Id = : customer.Id limit 1];
		// assert that he is the owner
		system.assertEquals(storeManager.Id, customer.OwnerId, 'The customer is not owned by the store manager.');
	}

	static testmethod void testCustomerAssignmentViaVertuStoreChange() {

		// set up a runas user to insert the prospect
		User insertUser = BG_LeadManagementTestHelper.getUser('insertemail@address.com', 'insertuser@vertu.com.retaildev', 'inu', null, null);
        insert insertUser;

		Lead prospect;
		User storeManagerA;
		User storeManagerB;
		Account storeA;
		Account storeB;
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
			storeA = UnitTestHelper.GetRetailAccount('Test Store A', '123', 'Retail Store');
			insert storeA;		

			storeB = UnitTestHelper.GetRetailAccount('Test Store B', '456', 'Retail Store');
			insert storeB;

			// set up a contact
			Contact managerContactA = new Contact();
			managerContactA.AccountId = storeA.Id;
			managerContactA.LastName = 'Manager A';
			insert managerContactA;

			Contact managerContactB = new Contact();
			managerContactB.AccountId = storeB.Id;
			managerContactB.LastName = 'Manager B';
			insert managerContactB;

			// get the partner profile
			Id communityProfileId = [select Id from profile where name = 'Vertu Retail Community EPOS' limit 1].Id;

			// set up a portal user
			storeManagerA = BG_LeadManagementTestHelper.getUser('theManagerA@address.com', 'theManagerA@vertu.com.retaildev', 'theManA', communityProfileId, 'None');
			storeManagerA.ContactId = managerContactA.Id;
			storeManagerA.CommunityNickName = 'theBossA';
			storeManagerA.Retail_Store_Role__c = 'Manager';
			insert storeManagerA;

			storeManagerB = BG_LeadManagementTestHelper.getUser('theManagerB@address.com', 'theManagerB@vertu.com.retaildev', 'theManB', communityProfileId, 'None');
			storeManagerB.ContactId = managerContactB.Id;
			storeManagerB.CommunityNickName = 'theBossB';
			storeManagerB.Retail_Store_Role__c = 'Manager';
			insert storeManagerB;

			// test that the inserted store manager is portal enabled
			System.assert([select isPortalEnabled from user where id = :storeManagerA.id].isPortalEnabled, 'User A was not flagged as portal enabled.'); 
			System.assertEquals(communityProfileId, [select ProfileId from user where id = :storeManagerA.id].ProfileId, 'User A does not have the portal profile.'); 
			System.assert([select isPortalEnabled from user where id = :storeManagerB.id].isPortalEnabled, 'User B was not flagged as portal enabled.'); 
			System.assertEquals(communityProfileId, [select ProfileId from user where id = :storeManagerB.id].ProfileId, 'User B does not have the portal profile.'); 

			// set up a new prospect and insert it
			prospect = BG_LeadManagementTestHelper.getLead(Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vertu Retail Lead').getRecordTypeId(), storeA.Id);
			insert prospect;
		}

		// reselect the prospect
		prospect = [select Id, CreatedDate, OwnerId from Lead where Id = : prospect.Id limit 1];

		// assert the owner has changed to the portal user
		System.assertEquals(storeManagerA.Id, prospect.OwnerId, 'The new Propect has not been assigned to the Store Manager A.');

		// assert the task has been linked to the prospect
		Task callReminderTask = [select WhoId, ReminderDateTime from Task where OwnerId = : storeManagerA.Id limit 1];
		system.assertEquals(prospect.Id, callReminderTask.WhoId, 'The task has not been linked to the Prospect');

		Database.LeadConvertResult leadConvertResult;

		system.RunAs(storeManagerA) {		
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
		Account customer = [select Id, RecordTypeId, Type, Boutique__pc from Account where Id = : prospect.ConvertedAccountId limit 1];
		// assert we got one
		System.assertEquals('Owner', customer.Type, 'The type has not been set to Owner');
		System.assertEquals(prospect.Boutique_SFID__c, customer.Boutique__pc, 'The boutique has not been set');
		system.assertEquals(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(), customer.RecordTypeId, 'The converted customer does not have the Customer Account record type');

		// select a retail opportunity
		Retail_Opportunities__c retailOpportunity = [select Id, OwnerId, Customer__c, Boutique_Name__c, Prospect_Status__c from Retail_Opportunities__c where Customer__c = : prospect.ConvertedContactId limit 1];

		// assert we got one
		System.assertNotEquals(null, retailOpportunity.Id, 'A Retail Opportunity has not been created');
		System.assertEquals(prospectManagementConfiguration.Retail_Opportunity_Status__c, retailOpportunity.Prospect_Status__c, 'The retail opportunity prospect status not set to Open');
		System.assertEquals(prospect.OwnerId, retailOpportunity.OwnerId, 'The retail opportunity owner id not set to the store manager a');
		System.assertEquals(prospect.ConvertedContactId, retailOpportunity.Customer__c, 'The retail opportunity customer not set to the contact');
		System.assertEquals(prospect.Boutique_SFID__c, retailOpportunity.Boutique_Name__c, 'The retail opportunity boutique name not set to the store');

		system.RunAs(insertUser) {

			// Change the Vertu Store of the customer
			customer.Boutique__pc = storeB.Id;
			update customer;
		}

		// reselect the customer
		customer = [select OwnerId from Account where Id = : prospect.ConvertedAccountId limit 1];

		// assert that the owner of the customer is store manager b
		system.assertEquals(storeManagerB.Id, customer.OwnerId, 'The owner of the customer has not been switched to store manager b');
	}
}