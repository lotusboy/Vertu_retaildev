/*************************************************
TestMessageMakerUtility

Test Class for Message Maker Utility Class

Author: Mahfuz Choudhury
Created Date: 25/06/2014

**************************************************/
@isTest
public class TestMessageMakerUtility {
    Static testmethod void testMsgMakerUtility()
    {
        Test.startTest();
        List<String> emaillist = new List<String>();
        SOA_Email_Receipient__c ER1 = new SOA_Email_Receipient__c();
        
        ER1.Name = 'TestMsgSetting';
        ER1.Email__c = 'test@a.com';
        insert ER1;
        
        emaillist.add(ER1.Email__c);
        
        String Subject = 'Test Subject';
        String Body = 'Test Body';
        
        BG_MessageMakerUtility.EmailAddressesfromCS();
        BG_MessageMakerUtility.FormEmailMessage(emaillist, Subject, Body);
        
        System.assertEquals(1, emaillist.size());
        
        //Delete custom settings to cover else
        Delete ER1;
        
        BG_MessageMakerUtility.EmailAddressesfromCS();
        
        Test.stopTest();
    }
}