@IsTest
private class RetailStatsTest {

     static testMethod void testRetailStatsTriggerViaDML()
    {
            // This example is simple, illustrates how to invoke the trigger code via DML (required), 
            //   but can become complex and detract from TDD and more granularly testing of the Accounts class
            
            Retail_Stats__c testRetailStats = new Retail_Stats__c( Region__c = 'Test RetailStats' );
            insert testRetailStats;
            
            testRetailStats = [select Id, Region__c from Retail_Stats__c where Id = :testRetailStats.Id];
            System.assertEquals(testRetailStats.Region__c, 'Test RetailStats');  
    }


}