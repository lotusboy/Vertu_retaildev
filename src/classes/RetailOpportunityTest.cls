@IsTest
private class RetailOpportunityTest {

     static testMethod void testRetailOpportunityTriggerViaDML()
    {
            // This example is simple, illustrates how to invoke the trigger code via DML (required), 
            //   but can become complex and detract from TDD and more granularly testing of the Accounts class
            Retail_Opportunities__c testRetailOpportunity = new Retail_Opportunities__c( email__c = 'dc@vertu.com', Comments__c = 'Test RetailOpportunity' );
            insert testRetailOpportunity;
            testRetailOpportunity = [select Id, Comments__c from Retail_Opportunities__c where Id = :testRetailOpportunity.Id];
            System.assertEquals(testRetailOpportunity.Comments__c, 'Test RetailOpportunity');  
    }


}