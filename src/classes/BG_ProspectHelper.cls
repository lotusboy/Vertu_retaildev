/*************************************************
BG_ProspectHelper

Helper class for the Prospect object

Author: Steve Loftus (BrightGen)
Created Date: 03/09/2014
Modification Date:
Modified By:

**************************************************/
public with sharing class BG_ProspectHelper {

	// this method reassigns boutique request prospects to the store manager of the identified boutique
	// it is called from a before insert trigger
	public static void reassignBoutiqueRequestProspects(list<Lead> boutiqueRequestProspectList) {

		// the trigger calling this method has already filtered the list of prospects to contain
		// only those prospects which have a lead source of 'Vertu Boutique Request'

		// map to hold the store manager Id against the boutique sfid (store Id)
		map<Id, Id> userIdByBoutiqueSFIDMap = new map<Id, Id>();

		// first we must pull the boutique sfids out of each propsect
		list<Id> boutiqueSFIDList = new list<ID>();

		Id vertuRetailLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vertu Retail Lead').getRecordTypeId();

		for (Lead prospect : boutiqueRequestProspectList) {

			// only add the boutique sfid to the list if it is not blank (whitespace, empty or null)
			if (prospect.LeadSource == 'Vertu Boutique Request' &&
					prospect.RecordTypeId == vertuRetailLeadRecordTypeId &&
						string.isNotBlank(prospect.Boutique_SFID__c)) {

				boutiqueSFIDList.add(prospect.Boutique_SFID__c);
			}
		}

		// make sure we have something to do
		if (!boutiqueSFIDList.isEmpty()) {

			// loop around all users found who are store managers and portal users and linked to the store identified in the boutique sfid list
			for (User storeManager : [select Id, AccountId
										from User 
											where Retail_Store_Role__c = 'Manager' and IsActive = true and IsPortalEnabled = true and AccountId in : boutiqueSFIDList]) {

				// if we don't already have an entry in the map for this store
				if (!userIdByBoutiqueSFIDMap.containsKey(storeManager.AccountId)) {

					// add the user Id against the store Id into the map
					userIdByBoutiqueSFIDMap.put(storeManager.AccountId, storeManager.Id);					
				}
			}

			// make sure we have some user Ids in the map
			if (!userIdByBoutiqueSFIDMap.isEmpty()) {

				// loop around the prospects and reassign to owner
				for (Lead prospect : boutiqueRequestProspectList) {

					// make sure we have a boutique sfid and it is in the map
					if (prospect.LeadSource == 'Vertu Boutique Request' &&
							prospect.RecordTypeId == vertuRetailLeadRecordTypeId && 
								string.isNotBlank(prospect.Boutique_SFID__c) && 
									userIdByBoutiqueSFIDMap.containsKey(prospect.Boutique_SFID__c)) {

						// reassign the owner to the store manager
						prospect.OwnerId = userIdByBoutiqueSFIDMap.get(prospect.Boutique_SFID__c);
					}
				}
			}
		}
	}
}