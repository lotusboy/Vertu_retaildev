/*************************************************
BG_LeadManagementTestHelper

Helper class for the lead management unit tests

Author: Steve Loftus (BrightGen)
Created Date: 04/09/2014
Modification Date:
Modified By:

**************************************************/
public class BG_LeadManagementTestHelper {
    
	public static User getUser(string theEmail, string theUserName, string theAlias, string theProfileId, string theRoleId) {

		UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		Profile adminProfile = [Select Id from Profile where name = 'System Administrator'];

		// set up a runas user to a the prospect
		User aUser = new User();
		aUser.Alias = theAlias;
		aUser.Email = theEmail;
		aUser.EmailEncodingKey = 'UTF-8';
		aUser.LastName = 'Last Name';
		aUser.LanguageLocaleKey = 'en_US';
		aUser.LocaleSidKey = 'en_GB';
		aUser.ProfileId = (theProfileId == null) ? adminProfile.Id : theProfileId;
        aUser.TimezoneSidKey = 'Europe/London';
        aUser.UserName = theUserName;
        aUser.FirstName = 'First Name';
        if (theRoleId != 'None') aUser.UserRoleId = (theRoleId == null) ? portalRole.Id : theRoleId;

        return aUser;
	}

	public static Lead getLead(string recordTypeId, string storeId) {

		Lead lead = new Lead();
		lead.LastName = 'Last Name';
		lead.Gender__c = 'Male';
		lead.Status = 'Open';
		lead.Email = 'email@address.com';
		lead.Vertu_Spoken_Language__c = 'English';
		lead.Vertu_Written_Language__c = 'English';
		lead.Boutique_SFID__c = storeId;
		lead.LeadSource = 'Vertu Boutique Request';
		lead.RecordTypeId = recordTypeId;

		return lead;
	}
}