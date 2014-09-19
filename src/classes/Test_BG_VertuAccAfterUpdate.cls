/*************************************************
Test_BG_VertuAccAfterUpdate
Covering Test For: BG_VertuAccAfterUpdate

Class to provide test for BG_VertuAccAfterUpdate trigger

Author: Mahfuz Choudhury
Created Date: 27/06/2014
Changes:

**************************************************/

@isTest
public class Test_BG_VertuAccAfterUpdate {
    
    private static testMethod void testBG_VertuAccAfterUpdate()
    {
        //Create a custom setting which controls the integration
        Operation_Switch__c OPSwitch = UnitTestHelper.CreateOpSwtichCS(); 
        
        //Create Account and Vertu Account
        Account acc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        Vertu_Account__c VA1 = UnitTestHelper.createVertuAccount(acc.id, '0001');
        
        //Query back Vertu Account to get fields to be changed in order to fire the trigger
        VA1 = [SELECT id, UserName__c from Vertu_Account__c where id =: VA1.id Limit 1];
        VA1.Username__c = 'New User Name';
        
        Test.startTest();
        update VA1;
        Test.stopTest();
        
        System.assertEquals('New User Name', VA1.Username__c);
    }
}