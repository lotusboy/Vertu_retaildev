/*
Developer Name   : Mick Nicholson (BrightGen Ltd)
Created Date	 : 30/05/2013
Description      : After insert/update/delete/undelete trigger on handset object
*/ 

trigger HandsetAfterInsertUpdateDeletUndelete on Handset__c (after delete, after insert, after undelete, 
after update) {
	List<Handset__c> handsetCollectionsUpdate = new List<Handset__c>();
	
	if (trigger.isdelete)
	{
		//Add all deleted handsets to list so Customer (account) Collections details can be recalculated
		for (Handset__c handset : trigger.old)
		{
			handsetCollectionsUpdate.add(handset);
		}
	}
	else
	{
		for (Handset__c handset : trigger.new)
		{
			//Add all new,undeleted handsets to list so Customer (account) Collections details can be recalculated
			if (trigger.isInsert ||
				trigger.isUnDelete)
			{
				handsetCollectionsUpdate.add(handset);
			}
			//If handsets collections updated or handset has been de/re-registered add to list so Customer (account) Collections details can be recalculated
			else if (trigger.isUpdate & 
				(handset.Registered__c != trigger.oldmap.get(handset.id).Registered__c ||
				handset.Phone_Collection__c != trigger.oldmap.get(handset.id).Phone_Collection__c))
			{
				handsetCollectionsUpdate.add(handset);
			}
			
		}
	}
	
	//Recalculate Customer (account) Collections details
	if (handsetCollectionsUpdate.size() > 0)
	{
		AccountUtils.updateCollectionInfo(handsetCollectionsUpdate);
	}
}