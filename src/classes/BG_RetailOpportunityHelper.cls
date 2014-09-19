/*************************************************
BG_RetailOpportunityHelper

Helper class for the Retail Opportunity

Author: Steve Loftus (BrightGen)
Created Date: 04/09/2014
Modification Date:
Modified By:

**************************************************/
public with sharing class BG_RetailOpportunityHelper {
    
    // this method takes a list of converted propsects from an before insert trigger
    // it will create a new retail opportunity for each one and link it to the created customer object
	public static void createRetailOpportunities(list<Lead> convertedProspectList) {

		/*
			process flow:

			get the customer records for the converted leads
			for each one, create and link a new retail opportunity record
			set the status of the prospect and the retail opportunity to a custom setting

			assumptions:

			The leads arriving here are being updated to be converted.
			The leads have the vertu retail lead record type.
			The leads have a source of Vertu Retail Boutique.
			This check should be done in the trigger which calls this method.
		*/

		// list to hold the new reatil opportunity records for insert
		list<Retail_Opportunities__c> retailOpportunityList = new list<Retail_Opportunities__c>();

		// list to hold the customer Ids
		list<Id> customerIdList = new list<Id>();

		// get the custom settings based on the user language...default to English if none found

		system.debug('UserInfo.getLanguage() [' + UserInfo.getLanguage() + ']');

		Prospect_Management__c prospectManagementConfiguration = (Prospect_Management__c.getInstance(UserInfo.getLanguage()) == null) ?
			Prospect_Management__c.getInstance('en_US') : Prospect_Management__c.getInstance(UserInfo.getLanguage());

		for (Lead prospect : convertedProspectList) {

			// set the status of the converted prospect to that in the customer setting
			prospect.Status = prospectManagementConfiguration.Prospect_Status__c;

			// create a new Retail Opportunity
			Retail_Opportunities__c retailOpportunity = new Retail_Opportunities__c();
			retailOpportunity.Prospect_Status__c = prospectManagementConfiguration.Retail_Opportunity_Status__c;
			retailOpportunity.OwnerId = prospect.OwnerId;
			retailOpportunity.Customer__c = prospect.ConvertedContactId;
			retailOpportunity.Boutique_Name__c = prospect.Boutique_SFID__c;
			retailOpportunity.Email__c = prospect.Email;

			// more fields may be added here

			system.debug('retailOpportunity [' + retailOpportunity + ']');

			retailOpportunityList.add(retailOpportunity);

			// get the customer id into the list
			customerIdList.add(prospect.ConvertedAccountId);
		}		

		// check we have some new retail opportunities to insert
		if (!retailOpportunityList.isEmpty()) {

			insert retailOpportunityList;
		}

		// check we have some customer Ids
		if (!customerIdList.isEmpty()) {

			map<Id, Account> updatedCustomerMap = new map<Id, Account>([select Boutique__pc, Type from Account where Id in : customerIdList]);

			if (!updatedCustomerMap.isEmpty()) {

				for (Lead prospect : convertedProspectList) {

					// make sure the customer we need is in the map
					if (updatedCustomerMap.containsKey(prospect.ConvertedAccountId)) {
						updatedCustomerMap.get(prospect.ConvertedAccountId).Boutique__pc = prospect.Boutique_SFID__c;
						updatedCustomerMap.get(prospect.ConvertedAccountId).Type = 'Owner';
					}
				}

				system.debug('updatedCustomerMap [' + updatedCustomerMap + ']');

				// update the customer records
				update updatedCustomerMap.values();
			}
		}
	}

}