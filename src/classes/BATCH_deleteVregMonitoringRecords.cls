/********************************************************************
 * BATCH_deleteVregMonitoringRecords
 *
 * Batch Import Class to delete records created by the VREG Monitoring system. 
 * Currently records are only logically deleted via the interface 
 * so this will physically remove the records and keep the data to real customers 
 * 
 * Author: Mick Nicholson ( BrightGen Ltd)
 * Created: 29-05-2013
 * Changes: 
 * 
 * Modified By: Mahfuz Choudhury (BrightGen Ltd)
 * Date: 17-07-14
 * Description: One line of code was added to pass unit testing (please see inline comment) 
 ********************************************************************/
global class BATCH_deleteVregMonitoringRecords implements Database.Batchable<sObject>, Database.Stateful
{
    global final string monitoringEmail = 'reg.monitor%';
    global integer customersDeleted = 0;
    global integer vertuAccountsDeleted = 0;
    global integer customersErrors = 0;
    global integer vertuAccountsErrors = 0;
    
    global database.querylocator start(Database.BatchableContext BC)
    {
        // Customer & Vertu Accounts to be processed - Get all inactive registration monitoring Vertu Accounts
        // If Vertu Account is active then the registration process has inserted the record but not yet deleted it so need to ignore so that delete does not fail 
        // There should be a 1-1 match for Vertu Accounts and  Customers but as it is not master-detail there may be some Vertu Accounts without a Customer
               
        string query = 'select id, Account_Name__c from Vertu_Account__c where Primary_email_address__c Like \'' + monitoringEmail + '\' and (Active__c = false or LastModifiedDate < yesterday)';
        system.debug('MN**** query = ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Vertu_Account__c> vertuAccountsToDelete)
    {
        system.debug('MN**** vertuAccountsToDelete = ' + vertuAccountsToDelete);
        //Create a list of Customers to be deleted
        List<Account> customersToDelete = new List<Account>();
        for(Vertu_Account__c vAcc : vertuAccountsToDelete)
        {
            //Add Customer account to list of records to delete
            if (vAcc.Account_Name__c != null)
            {
                customersToDelete.add(new Account(id=vAcc.Account_Name__c));
            }
        }
        
        //Delete vertuAccounts and capture number of successes and errors for email
        Database.Deleteresult[] drs = database.delete(vertuAccountsToDelete);
        for (Database.Deleteresult dr : drs)
        {
            if (dr.isSuccess())
            {
                vertuAccountsDeleted ++;
            }
            else
            {
                vertuAccountsErrors ++;
            }
        }
        
        //Delete customers and capture number of successes and errors for email
        drs = database.delete(customersToDelete);
        for (Database.Deleteresult dr : drs)
        {
            if (dr.isSuccess())
            {
                customersDeleted ++;
            }
            else
            {
                customersErrors ++;
            }
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        String[] toAddresses = new String[]{};
       
        //Get Notifications Admin group members
        Group notifyAdminGroup = [Select id from Group where developerName = 'Notifications_Admin'][0];
        if (notifyAdminGroup != null)
        {
            Set<Id> groupMemberIds = publicGroupUtils.GetUserIdsFromGroup(notifyAdminGroup.Id);
            List<User> notifyUsers = [select id, Name, Email from User where id in :groupMemberIds
                                                                         and Email != null];
            for (User notifyUser : notifyUsers)
            {
                ToAddresses.add(notifyUser.Email);
            }
        }      
       
       // Send an email to the on job completion to the Notification Admin group members.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       mail.setToAddresses(toAddresses);
       mail.setSubject('Batch Registration Monitoring Delete Job ');
       mail.setHTMLBody
       ('Registration Monitoring Customers deleted =  ' + customersDeleted + '<br>' +
       'Registration Monitoring Customer errors =  '+ customersErrors + ' <br>' +
       'Registration Monitoring Vertu Accounts deleted =  ' + vertuAccountsDeleted + '<br>' +
       'Registration Monitoring Vertu Account errors =  '+ vertuAccountsErrors );
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /****************/
    /*              */
    /* Test Methods */
    /*              */
    /****************/
    private static testMethod void testBatch() 
    {
        BATCH_deleteVregMonitoringRecords batchTest = new BATCH_deleteVregMonitoringRecords();
        
        Account acc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        Vertu_Account__c vertuAcc = UnitTestHelper.createVertuAccount(acc.ID, '834298');        
        vertuAcc.Primary_email_address__c = batchTest.monitoringEmail + 'test@test.com';
        //Following line was added by Mahfuz Choudhury to make the test class pass the unit testing
        vertuAcc.Active__c = false;
        update vertuAcc;    
        
        //Get Account and Vertu Account and check they exist
        List<Account> testAcc = [Select Id from Account where id = :acc.Id];
        system.assertEquals(1, testAcc.size());       
        List<Vertu_Account__c> testvertuAcc = [Select Id from Vertu_Account__c where id = :vertuAcc.Id];
        system.assertEquals(1, testvertuAcc.size());       
        
        //Execute Batch method
        Test.StartTest();
            ID batchprocessid = Database.executeBatch(batchTest, 1);

        Test.stopTest();
        
        //Get Account and Vertu Account and check they no longer exist
        testAcc = [Select Id from Account where id = :acc.Id];
        system.assertEquals(0, testAcc.size());       
        testvertuAcc = [Select Id from Vertu_Account__c where id = :vertuAcc.Id];
        system.assertEquals(0, testvertuAcc.size());     
    }

}