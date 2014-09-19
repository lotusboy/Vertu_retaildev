/*************************************************
SOA_WSO_MaintainCustomer
Test Class:

Class for handling all the logic for outbound call out

Author: Mahfuz Choudhury
Created Date: 18/06/2014

**************************************************/
public class SOA_WSO_MaintainCustomer {
    /*Method to handle callout in future context, it takes a set of account
    ids and retrieve all the necessary information which need to be sent to
    ESB (Enterprise Service Bus) for getting a result back which is necessary to
    create a request log for accounts to be updated.
    **/
    
    //Declare static variables here..
    Public static final String RequestLogError = 'Error';
    Public static final String SuccessStatus = 'New';
    Public static final String ServiceName = 'Customer Update';
    Public static String ServiceUrl
    {
        get
        {
            String Endpoint = SOA_WSO_MaintainCustomerCall.CustomerUpdateEndPoint;      
            return SOA_WSO_MaintainCustomerCall.GetEndPointURLByName(EndPoint);   
        }
    }
    
    @future (callout=true)
    Public static void UpdateCustomerRequest(Set<id> Accountids)
    {
      //Declare a List to process the response here 
      List<SOA_Request_Log__c> RequestLog = new List<SOA_Request_Log__c>();
      List<Messaging.SingleEmailMessage> allfailureMails = new List<Messaging.SingleEmailMessage>();
      List<Account> ResetIntegrationSwitchList = new List<Account>();
        
      if(Accountids.size() > 0 && Accountids != null)
      {   
        Savepoint sp;
         
        //Get all the necessary fields by iterating over matching account here.
        //GetAccountWithVertuAccount is a utility method to return all Account and related vertu account fields for making SOA callout
        for(account acc : AccountUtils.GetAccountWithVertuAccount(Accountids))
        {
            //Go through the Vertu Accounts for each customer as each account needs to construct one SOAP call
            for(Vertu_Account__c VC: acc.Vertu_Accounts__r)
            {
                Try
                {
                    System.debug('Hey! Greetings from begining of the try block inside Maintain Customer Class---------------->>>'+VC);
                    //Pass the vertu account and customer info to helper class method for processing
                    SOA_WSO_MaintainCustomerCall UpdateCustomer = new SOA_WSO_MaintainCustomerCall();
                    WS_SOA_MaintainCustomerType.UpdateCustomerResponseType response = UpdateCustomer.UpdateCustomerCall(acc,VC);
                    System.debug('Update Customer Response in future method is:------------------------>>>>'+response);
                    
                    
                    if(response != NULL && response.AccountGUID != NULL && response.VertuAccountGUID != NULL)
                    {
                        //add response to a list of request log prepare for the DML
                        RequestLog.add(CreateRequestLog(response));
                        
                        //If the Switch was not resetted by one of the Vertu Accounts call out
                        if(acc.SOA_Update_Customer_Integration__c != FALSE)
                        {
                            acc.SOA_Update_Customer_Integration__c = FALSE;
                            ResetIntegrationSwitchList.add(acc);   
                        }
                    }
                    else
                    {
                        BG_SOAExceptionHandler.CalloutExceptionHandler(Acc, VC, 'Invalid Response ','Invalid Response from SOA', ServiceName, ServiceUrl);
                    }
                }
                Catch(CalloutException ex)
                {
                    //Call out failed...
                    System.debug('Call Out Failed in Future Method for Customer Update------------------------------->>>>'+ex.getMessage());
                    BG_SOAExceptionHandler.CalloutExceptionHandler(Acc, VC, 'Callout Error Occured', ex.getMessage(), ServiceName, ServiceUrl);
                }
                Catch(Exception ex)
                {
                    //Non Call Out failure...
                    System.debug('Internal Exception Occured in Future Method for Customer Update------------------------------->>>>'+ex.getMessage());     
                    BG_SOAExceptionHandler.CalloutExceptionHandler(Acc, VC, 'Salesforce Error Occured', ex.getMessage(), ServiceName, ServiceUrl);
                }
            }   
        }
          
        Try
        {
            if(RequestLog.size() > 0 && RequestLog != NULL)
            {
                //Insert the returned request log here
                Database.insert(RequestLog);
            }
            
            //Set a savepoint in case any error occurs
            sp = Database.setSavepoint();
            
            if(ResetIntegrationSwitchList.size() > 0 && ResetIntegrationSwitchList != NULL)
            {
                Database.Update(ResetIntegrationSwitchList);   
            }
        }
        Catch(DMLException ex)
        {
            System.debug('DML Operation Failed in Future Method for SOA Customer Update-------------------------------->>>>>'+ex.getMessage());
            
            //Roll back to previous state
            Database.RollBack(sp);
        }
          
      }
          
    }
    
    //Get the Acknowledgement for the response
    private static WS_SOA_MaintainCustomerAcknowledgement.AcknowledgementType ResponseAcknowledgement(WS_SOA_MaintainCustomerType.UpdateCustomerResponseType response)
    {
        //return the Acknowledement part of the response
        return response.Acknowledgement;
    }
    
    //Utility method to create a Request Log goes here
    Public static SOA_Request_Log__c CreateRequestLog(WS_SOA_MaintainCustomerType.UpdateCustomerResponseType response)
    {
        //Create a new Acknowledgement based on the response returned
        WS_SOA_MaintainCustomerAcknowledgement.AcknowledgementType Acknowledgement = ResponseAcknowledgement(response);
        String Status;
        
        if(Acknowledgement.Status == 'SUCCESS')
        {
            Acknowledgement.Status = SuccessStatus;   
        }
        
        //ServiceUrl = SOA_WSO_MaintainCustomerCall.GetEndPointURLByName(SOA_WSO_MaintainCustomerCall.CustomerUpdateEndPoint);
        
        SOA_Request_Log__c SOARequest = BG_RequestLogUtils.CreateSOALog(response.AccountGUID, response.VertuAccountGUID, response.RequestID,
                                                                        SOA_WSO_MaintainCustomerCall.NullCheckerMethod(response.VregID),
                                                                       Acknowledgement.Status, Acknowledgement.Message, ServiceName, ServiceUrl);  
        
        System.debug('SOARequest Size for Successfull Call out is:-------------------------------------> '+SOARequest);
        return SOARequest;
    }
    
    /*
     * Method to handle accounts ids in batch context
     *The following part is for batch processing only
     */
    public static void UpdateCustomerRequestBatch(Set<id> Accountids)
    {
        System.debug('Scheduling a Batch Job for sending Account update to SOA------------------------->>>>');
        
        //Create an instance of the maintaincustomerschedule class and pass all accountids to the set so that
        //it can be processed or resubmitted back to this method for processing just incase it fails this time 
        SOA_SCHEDULE_MaintainCustomer MaintainCustomerSchedule = new SOA_SCHEDULE_MaintainCustomer();
        MaintainCustomerSchedule.CustomerToProcess.addall(Accountids);
        
        System.debug('Account ids passed to schedule class for resubmission-------------------->>>>'+MaintainCustomerSchedule.CustomerToProcess);
        
        //Declare a name for the batch job here
        String ScheduledJobName =  BG_SheduleUtilityHelper.ScheduleJobTypes.ProcessSOACustomerUpdate
                                + '-'
                                + Datetime.now().hour()
                                + ':' + Datetime.now().minute()
                                + ':' + Datetime.now().second();
            
        DateTime scheduleDatetime = Datetime.now().addMinutes(10);
        if (ScheduledJobName.length() > 60)
        {
            ScheduledJobName = ScheduledJobName.substring(0,60);
        }
        
        //Schedule the time of the batch job using GetCRONString method of schedule utility class
        system.schedule(ScheduledJobName.trim(), ScheduleUtils.GetCRONString(scheduleDatetime), MaintainCustomerSchedule);
    }
}