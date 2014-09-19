/*
Developer Name   : Omar Qureshi
Deployment Date  : 
Description      : Unit test class for trigger 
*/ 
@isTest(SeeAllData=true)
private class TestAccountBeforeInsertTrigger {

    static testMethod void testAccountBeforeInsert() {
        
       
        Map<String, Country_Code__c> countries = Country_Code__c.getAll();
        Account acc = new Account(LastName='abcdefghi', Gender__pc='Male', Vertu_Spoken_Language__c='English',Country_of_Residence__pc='United Kingdom');
        acc.RecordTypeId = [Select Id,SobjectType,Name From RecordType where SobjectType ='Account' and Name='Customer Account'].id;
        
        acc.Mobile_Country__c = 'United Kingdom +44';
        acc.PersonMobilePhone = '5551212';
        acc.Home_Phone_Country__c = 'France +33';
        acc.PersonHomePhone = '4441212';
        acc.Other_Phone_Country__c = 'Germany +49';
        acc.PersonOtherPhone = '12345';         
        insert acc;
        
        acc.Mobile_Country__c = 'Belgium +32';
        acc.PersonMobilePhone = '5551212';
        acc.Home_Phone_Country__c = 'China +86';
        acc.PersonHomePhone = '4441212';
        acc.Other_Phone_Country__c = 'Japan +81';
        acc.PersonOtherPhone = '12345'; 
        update acc;
        

        acc.PersonMobilePhone = '+325551212';
  
        acc.PersonHomePhone = '+864441212';

        acc.PersonOtherPhone = '+8112345';      
        
        update acc;
        
    }
    
}