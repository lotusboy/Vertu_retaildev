/********************************************************************
 * BATCH_updateCollectionSummary
 *
 * Batch Import Class to update Customer records with the sumamrise collection information from registered handsets
 * This will only be run once to update records that already exist. 
 * Trigger HandsetAfterInsertUpdate and method AccountUtils.updateCollectionInfo update all subsequent records
 * 
 * Author: Mick Nicholson ( BrightGen Ltd)
 * Created: 03-06-2013
 * Changes: 
 ********************************************************************/
global class BATCH_updateCollectionSummary implements Database.Batchable<sObject>, Database.Stateful
{
  
    global database.querylocator start(Database.BatchableContext BC)
    {
        // Customer & Vertu Accounts to be processed - Get all inactive registration monitoring Vertu Accounts
        // If Vertu Account is active then the registration process has inserted the record but not yet deleted it so need to ignore so that delete does not fail 
        // There should be a 1-1 match for Vertu Accounts and  Customers but as it is not master-detail there may be some Vertu Accounts without a Customer
               
        string query = 'select id, Account_Name__c from Handset__c where Registered__c = true';
        system.debug('MN**** query = ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Handset__c> registeredHandsets)
    {
        system.debug('MN*** registeredHandsets.size = ' + registeredHandsets.size());
        AccountUtils.updateCollectionInfo(registeredHandsets);
    }

    global void finish(Database.BatchableContext BC)
    {
    }
    
    /****************/
    /*              */
    /* Test Methods */
    /*              */
    /****************/
  
    private static testMethod void testBatch() 
    {
        BATCH_updateCollectionSummary batchTest = new BATCH_updateCollectionSummary();
        
        string expectedReg = '';
        string PhoneCollection1 = 'TestValue1';
        string PhoneCollection2 = 'TestValue2';
        string PhoneCollection3 = 'TestValue3';
        string PhoneCollectionCode1 = 'TestCode1';
        string PhoneCollectionCode2 = 'TestCode2';
        string PhoneCollectionCode3 = 'TestCode3';
        string PhoneVSN1 = 'TestVSN1';
        string PhoneVSN2 = 'TestVSN2';
        string PhoneVSN3 = 'TestVSN3';
        
        //Create an account and handsets
        Account acc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        Handset__c hs1 = UnitTestHelper.createHandset(acc.Id, PhoneCollection1, PhoneCollectionCode1, PhoneVSN1, true);
        
        //Get CreatedDate from handset1
        Handset__c testHs1 = [Select Id, CreatedDate from Handset__c where id = :hs1.id][0];
        //Wait until time has changed - this will force next insert to have different created datetime
        while(testHs1.CreatedDate.second() == system.now().second())
        {
            
        }
        
        Handset__c hs2 = UnitTestHelper.createHandset(acc.Id, PhoneCollection2, PhoneCollectionCode2, PhoneVSN1, true);
        //Get CreatedDate from handset2
        Handset__c testHs2 = [Select Id, CreatedDate from Handset__c where id = :hs2.id][0];
        //Wait until time has changed - this will force next insert to have different created datetime
        while(testHs2.CreatedDate.second() == system.now().second())
        {
            
        }
        Handset__c hs3 = UnitTestHelper.createHandset(acc.Id, PhoneCollection3, PhoneCollectionCode3, PhoneVSN1, false);

        //Retrive account and initialise collection details as trigger will already have updated and need to be null to test
        acc = [Select id, Collections_Registered__c, Collections_Last_Registered__c 
                from Account
                where id = :acc.id][0];
        acc.Collections_Registered__c = '';
        acc.Collections_Last_Registered__c = '';
        update acc;
        //Retrive account and check values are initialised
        acc = [Select id, Collections_Registered__c, Collections_Last_Registered__c 
                from Account
                where id = :acc.id][0];
        system.assertEquals(null,acc.Collections_Registered__c);
        system.assertEquals(null,acc.Collections_Last_Registered__c);

        //Execute Batch method
        Test.StartTest();
            ID batchprocessid = Database.executeBatch(batchTest);

        Test.stopTest();
        
        //Check Account values updated from handset 2
        Account testAcc = [Select Collections_Registered__c, Collections_Last_Registered__c
                            From Account where id = :acc.Id][0];
        expectedReg = hs2.Phone_Collection__c + ',' + hs1.Phone_Collection__c;
        //Last value should be this handset2, lists should have both values
        system.assertEquals(hs2.Phone_Collection__c, testAcc.Collections_Last_Registered__c);
        system.assertEquals(expectedReg, testAcc.Collections_Registered__c);
    }
 
}