/*
 * Trigger Name: HandsetBeforeInsertBeforeUpdate (before Insert, Before Update)
 * Test Class: Test_HandsetBeforeInsertBeforeUpdate
 * 
 *Author: Mahfuz Choudhury (BrightGen Ltd)
 *Created Date: 06/08/14
 *Description: Trigger to Handle logic on before insert and before update
 */

trigger HandsetBeforeInsertBeforeUpdate on Handset__c (before insert, before Update) {
    
    List<Handset__c> Handset = new List<Handset__c>();
    
    //If this is an Insert Operation
    If(Trigger.isInsert)
    {
     	If(Trigger.new.size() > 0 && Trigger.new != NULL && !System.isFuture())
    	{
        	BG_HandsetUtils.UpdateHandsetWithRetailAccount(Trigger.new);
    	}
    }
    
    //If this is an update Operation
    If(Trigger.isUpdate)
    {
		If(Trigger.new.size() > 0 && Trigger.new != NULL && !System.isFuture())
    	{
       		BG_HandsetUtils.UpdateHandsetWithRetailAccount(Trigger.new);
    	} 
    }
}