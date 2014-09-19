/*************************************************
BG_Lead_bi

Lead trigger for before insert

Author: Steve Loftus (BrightGen)
Created Date: 03/09/2014
Modification Date:
Modified By:

**************************************************/
trigger BG_Lead_bi on Lead(before insert) {

	list<Lead> boutiqueRequestProspectList = new list<Lead>();

	Id vertuRetailLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vertu Retail Lead').getRecordTypeId();

	// loop the trigger for prospects which have lead source set to 'Vertu Boutique Request' and the boutique sfid is not blank
	for (Lead prospect : trigger.new) {

		if (prospect.LeadSource == 'Vertu Boutique Request' &&
				prospect.RecordTypeId == vertuRetailLeadRecordTypeId &&
					string.isNotBlank(prospect.Boutique_SFID__c)) {

			// add it to the list
			boutiqueRequestProspectList.add(prospect);
		}
	}

	// check we have some prospects to reassign
	if (!boutiqueRequestProspectList.isEmpty()) {

		// reassign them
		BG_ProspectHelper.reassignBoutiqueRequestProspects(boutiqueRequestProspectList);
	}
}