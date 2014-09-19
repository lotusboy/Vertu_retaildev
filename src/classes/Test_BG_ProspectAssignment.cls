/*************************************************
Test_BG_ProspectAssignment

Test class for BG_ProspectAssignment trigger helper

Author: Steve Loftus (BrightGen)
Created Date: 28/08/2014
Modification Date:
Modified By:

**************************************************/
@isTest
private class Test_BG_ProspectAssignment {
	
	// tests that a new inserted prospect gets assigned to the correct store manager
	static testmethod void testProspectAssignment() {

		// set up a runas user to insert the prospect
		User insertUser = BG_LeadManagementTestHelper.getUser('insertemail@address.com', 'insertuser@vertu.com.retaildev', 'inu', null, null);
        insert insertUser;

		Lead prospect;
		User storeManager;
		// create the account, contact and community user and the propsect under the insert user
		// this is need to create a community user
		// also we want the prospect to be created by a user so we know the reassignment works
		system.RunAs(insertUser) {

			// set up an account
			Account store = UnitTestHelper.GetRetailAccount('Test Store', '123', 'Retail Store');
			store.OwnerId = insertUser.Id;
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
			system.assert([select isPortalEnabled from user where id = :storeManager.id].isPortalEnabled, 'User was not flagged as portal enabled.'); 

			// set up a new prospect and insert it
			prospect = BG_LeadManagementTestHelper.getLead(Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vertu Retail Lead').getRecordTypeId(), store.Id);
			insert prospect;
		}

		// reselect the prospect
		prospect = [select CreatedDate, OwnerId from Lead where Id = : prospect.Id limit 1];

		// assert the owner has changed to the portal user
		system.assertEquals(storeManager.Id, prospect.OwnerId, 'The new Propect has not been assigned to the Store Manager.');

		// assert the task has been linked to the prospect
		Task callReminderTask = [select WhoId, ReminderDateTime from Task where OwnerId = : storeManager.Id limit 1];
		system.assertEquals(prospect.Id, callReminderTask.WhoId, 'The task has not been linked to the Prospect');
	}
}