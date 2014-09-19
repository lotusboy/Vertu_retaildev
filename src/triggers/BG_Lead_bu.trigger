/*************************************************
BG_Lead_bu

Lead trigger for before update

Author: Steve Loftus (BrightGen)
Created Date: 05/09/2014
Modification Date:
Modified By:

**************************************************/
trigger BG_Lead_bu on Lead(before update) {

	list<Lead> boutiqueRequestProspectList = new list<Lead>();

	Id vertuRetailLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Vertu Retail Lead').getRecordTypeId();

	// loop the trigger for prospects which have lead source set to 'Vertu Boutique Request' and they have just been converted
	for (Lead prospect : trigger.new) {

		system.debug('prospect [' + prospect + ']');
		if (prospect.LeadSource == 'Vertu Boutique Request' &&
				prospect.RecordTypeId == vertuRetailLeadRecordTypeId &&
					trigger.oldMap.get(prospect.Id).IsConverted == false &&
						prospect.IsConverted == true) {

			// add it to the list
			boutiqueRequestProspectList.add(prospect);
		}
	}

	// check we have some prospects to create retail opportunities for
	if (!boutiqueRequestProspectList.isEmpty()) {

		// create the retail opportunity records
		BG_RetailOpportunityHelper.createRetailOpportunities(boutiqueRequestProspectList);
	}
}