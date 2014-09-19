/*************************************************
Test_BG_VertuAccAfterUpdate
Covering Test For: BG_VertuAccAfterUpdate

Class to provide test for BG_VertuAccAfterUpdate trigger

Author: Mahfuz Choudhury
Created Date: 27/06/2014
Changes:

**************************************************/

@isTest
public class Test_HandsetBeforeInsertBeforeUpdate {
    
    private static testMethod void Test_BeforeInsetAndUpdate()
    {   
        //Create Account and Vertu Account
        Account acc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        
        Account RetailAcc = UnitTestHelper.GetRetailAccount('Test Retail Account', '1234', 'Retail Store');
        Insert RetailAcc;

        Vertu_Account__c VA1 = UnitTestHelper.createVertuAccount(acc.id, '0001');
        
        Handset__c Handset = UnitTestHelper.getHandset(acc.id, 'Test Collection', 'Premium - 1234', 'V-123444', True);
        Handset.Place_of_Purchase_Code__c = '1234';
        
        Test.startTest();
        	Insert Handset;
        Test.stopTest();
        
        Handset = [Select Place_of_Purchase__c FROM Handset__c WHERE Id =: Handset.Id];
        System.assertEquals(RetailAcc.id, Handset.Place_of_Purchase__c);
    }
}