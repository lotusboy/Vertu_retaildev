/********************************************************************
 * BATCH_processQforceInboundData
 *
 * Batch Import Class to enable bulk processing of JSON messages received from QForce which will be added to Vertu_Inbound_Data__c
 * Custom Object
 * 
 * Author: Mick Nicholson ( BrightGen Ltd)
 * Created: 27-03-2013
 * Changes: 
 ********************************************************************/
global class BATCH_processQforceInboundData implements Database.Batchable<sObject>, Database.Stateful
{
    global final List<Vertu_Inbound_Data__c> recordsToProcess = new list<Vertu_Inbound_Data__c>();
    global final Set<Id> recordIdsToProcess = new Set<Id>();
    
    global database.querylocator start(Database.BatchableContext BC)
    {
        // Vertu Qforce Inbound Data Ids to be processed
        
        string query = 'select id, Inbound_Message__c, Detail__c, Status__c from Vertu_Inbound_Data__c where id IN:recordIdsToProcess';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Vertu_Inbound_Data__c> scope)
    {
    	for(Vertu_Inbound_Data__c qForceInboundData : scope)
    	{
    		VertuInboundDataHandler.processQforceInboundData(qforceInboundData);
    	}
    }

    global void finish(Database.BatchableContext BC)
    {

     }
    

    private static testMethod void testBatch() 
    {
        BATCH_processQforceInboundData batchTest = new BATCH_processQforceInboundData();
        
        Account acc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c vertuAcc = UnitTestHelper.createVertuAccount(acc.ID, '834298');        
        Vertu_Inbound_Data__c json = new Vertu_Inbound_Data__c();
               
        // Test validation Success
        Test.StartTest();
        batchTest.recordIdsToProcess.add(json.Id);
        
        ID batchprocessid = Database.executeBatch(batchTest, 1);

		Test.stopTest();
    }

}