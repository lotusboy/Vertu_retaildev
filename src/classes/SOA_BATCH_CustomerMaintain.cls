/*************************************************
SOA_BATCH_CustomerMaintain
Test Class: TestSOA_BATCH_MaintainCustomer

Class for running the batch job for SOA customer maintain(update,) 

Author: Mahfuz Choudhury
Created Date: 20/06/2014
Changes:

**************************************************/

global class SOA_BATCH_CustomerMaintain implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    //Declare a set to hold all account ids
    global final Set<Id> AccountIdsToProcess = new Set<Id>();
    
    global database.querylocator start(Database.BatchableContext BC)
    {
     //Retrieve the required records via accountutils query method which needs updating in SOA 
     //String Query = AccountUtilsHelper.GetAccountWithVertuAccountQueryString(AccountIdsToProcess);
     String Query = AccountUtils.GetAccountWithVertuAccountQueryString('AccountIdsToProcess');
               
     System.debug('Returning Query Result for SOA batch class------------------------------>>>>'+Query);
        
     return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        //Declare variable to create a request log here
        List<SOA_Request_Log__c> RequestLog = new List<SOA_Request_Log__c>();
        List<Account> ResetIntegrationSwitchList = new List<Account>();
        List<Messaging.SingleEmailMessage> allfailureMails = new List<Messaging.SingleEmailMessage>();
        
        if(scope.size()>0)
        {
            //Loop through the retrieved record from query location and send it to web service caller class
            for(sobject s: scope)
            {
                //Get the Account sobject
                Account a = (Account)s;
                
                //get the related Vertu Accounts for current Account (Customer)
                List<SObject> RelatedRecords = a.getsobjects('Vertu_Accounts__r');
                List<Vertu_Account__c> RelatedVertuAcc = (List<Vertu_Account__c>)RelatedRecords; 
                String ServiceName = SOA_WSO_MaintainCustomer.ServiceName;
                String Url = SOA_WSO_MaintainCustomer.ServiceUrl;
            
                //If some record was retrived then....
                if(RelatedVertuAcc != NULL)
                {
                    //send record to the web service handler method for processing
                    for(Vertu_Account__c vc: RelatedVertuAcc)
                    {
                        try
                        {
                            //Pass the vertu account and customer info to helper class method for processing
                            SOA_WSO_MaintainCustomerCall UpdateCustomer = new SOA_WSO_MaintainCustomerCall();
                            WS_SOA_MaintainCustomerType.UpdateCustomerResponseType response = UpdateCustomer.UpdateCustomerCall(a,vc);
                            System.debug('Update Customer Response in Batch Apex is:------------------------>>>>'+response);
                            
                            //Add the response into request log and update Integration Switch value to false if call out was successful
                            if(response != NULL && response.AccountGUID != NULL && response.VertuAccountGUID != NULL)
                            {
                                RequestLog.add(SOA_WSO_MaintainCustomer.CreateRequestLog(response));
                                System.debug('List of Requests in Batch Class--------------------------->>>>>>'+RequestLog);
                                
                                if(a.SOA_Update_Customer_Integration__c != FALSE)
                                {
                                    a.SOA_Update_Customer_Integration__c = FALSE;
                                    ResetIntegrationSwitchList.add(a);
                                }
                            }
                            else
                            {
                                BG_SOAExceptionHandler.CalloutExceptionHandler(a, VC, 'Invalid Response','Invalid Response from SOA', ServiceName, Url);
                            }
                        
                        }
                        Catch(CalloutException ex)
                        {
                            System.debug('Call Out from Batch Apex Failed----------------------->>>>'+ex.getMessage());
                            
                            //Send emails to the receipient from custom setting if call out fails
                            //allfailureMails.add(BG_MessageMakerUtility.FormEmailMessage(BG_MessageMakerUtility.EmailAddressesfromCS(),'Call Out Failed','Call Out Failed for: '+a.Name+' for following reason: \n'+ex.getMessage()));
                    
                            //Create a request log for failed records here..
                            BG_SOAExceptionHandler.CalloutExceptionHandler(a, vc, 'Callout Error Occured', ex.getMessage(),ServiceName, Url);
                        }
                        Catch(Exception ex)
                        {
                            System.debug('Internal Exception Occured from Batch Apex--------------->>>>'+ex.getMessage());
                            //allfailureMails.add(BG_MessageMakerUtility.FormEmailMessage(BG_MessageMakerUtility.EmailAddressesfromCS(),'SOA update failed for Internal Salesforce Error','Call Out Failed for: '+a.Name +' for following reason: \n'+ex.getMessage()));
                 
                            //Create a request log for failed records here..
                            if(!test.isRunningTest())
                            {
                                BG_SOAExceptionHandler.CalloutExceptionHandler(a, vc, 'Salesforce Error Occured', ex.getMessage(),ServiceName, Url); 
                            }
                        }
                    }
                }
            }
            
            Try
            {
                //Insert the returned request log here if call out was successful
                if(RequestLog.size() > 0 && RequestLog != NULL)
                {
                    Database.insert(RequestLog);   
                }
                //Update Integration Switch on Account for all successful vertu Account
                if(ResetIntegrationSwitchList.size() > 0 && ResetIntegrationSwitchList != NULL)
                {
                    Database.update(ResetIntegrationSwitchList);   
                }
            }
            Catch(DMLException ex)
            {
                System.debug('DML Operation Failed in Batch Apex for SOA Customer Update-------------------------------->>>>>'+ex.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //Get the job details from helper class by passing the job id
        AsyncApexJob a = BatchHelper.GetApexJobDetailsByID(BC.getJobId());
        
        //Create a message with Job detail
        mail = BG_MessageMakerUtility.FormEmailMessage(BG_MessageMakerUtility.EmailAddressesfromCS(),'SOA Customer Update Status:'+ a.status,
                                                'The Total Customer Update Processed: '+ a.TotalJobItems +
                                                ' batches with '+ a.NumberOfErrors + ' failures.');
        
        //Send emails to users in custom setting
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
        
    }
}