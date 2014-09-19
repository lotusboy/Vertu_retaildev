/*************************************************
TestSOA_BATCH_MaintainCustomer
Covering Test For: SOA_BATCH_CustomerMaintain

Class to provide test for SOA_BATCH_CustomerMaintain class which intiate a batch process for update customer to SOA

Author: Mahfuz Choudhury
Created Date: 26/06/2014
Changes:

**************************************************/
@isTest
public class TestSOA_BATCH_MaintainCustomer {
    
    private static testMethod void testBatchForSOACustomerUpdate() 
    {
        SOA_BATCH_CustomerMaintain batchTest = new SOA_BATCH_CustomerMaintain();
        
        Account acc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        Vertu_Account__c vertuAcc = UnitTestHelper.createVertuAccount(acc.ID, '834298');
        
        //acc = [Select id from Account where id =: acc.id];
        // Test validation Success
        Test.StartTest();
        batchTest.AccountIdsToProcess.add(acc.id);
        
        ID batchprocessid = Database.executeBatch(batchTest, 1);

        Test.stopTest();
    }
}