/*
Developer Name   : Omar Qureshi
Deployment Date  : 
Description      : After insert trigger on VertuInboundData object to deserialise incoming JSON content
*/ 

trigger VertuInboundDataAfterInsert on Vertu_Inbound_Data__c (after insert) {

	List<Vertu_Inbound_Data__c> vertuRecords = new List<Vertu_Inbound_Data__c>();
	Set<Id> qforceIds = new Set<Id>();
	for (Vertu_Inbound_Data__c newInboundData : trigger.new)
	{
		if (newInboundData.Detail__c == null ||
			!newInboundData.Detail__c.startsWith(VertuInboundDataHandler.QFORCE))
		{
			vertuRecords.add(newInboundData);
		}
		else
		{
			qforceIds.add(newInboundData.Id);
		}
	}

    if (vertuRecords.size() > 0)
    {
    	VertuInboundDataHandler.processVertuCustomerInboundData(vertuRecords);
    }
    if (qforceIds.size() > 0)
    {
    	if (qForceIds.size() > 10)
    	{
	    	VertuInboundDataHandler.scheduleQforceInboundDataBatchJob(qForceIds);
    	}
    	else
    	{
	    	VertuInboundDataHandler.processQforceInboundDataIds(qForceIds);
    	}
    }

}