/*************************************************
BG_SOAExceptionHandler
Test Class: 

Class to handle exception for SOA call out

Author: Mahfuz Choudhury
Created Date: 13/07/2014
Changes:

**************************************************/

public class BG_SOAExceptionHandler {

    //Declare static variables here..
    Public static final String RequestLogError = 'Error';
    
    public Static void CalloutExceptionHandler(Account Acc, Vertu_Account__c VAcc, String Subject, String ExceptionMsg, String ServiceName, String Url)
    {               
        //Declare a List to process the response here 
         List<SOA_Request_Log__c> FailedRequestLog = new List<SOA_Request_Log__c>();
         List<Messaging.SingleEmailMessage> allfailureMails = new List<Messaging.SingleEmailMessage>();
        
        //Send emails to the receipient from custom setting if call out fails
        allfailureMails.add(BG_MessageMakerUtility.FormEmailMessage(BG_MessageMakerUtility.EmailAddressesfromCS(),Subject,System.Label.VREG_Connection_ERror+' Reason: '+acc.id+' for following reason: \n'+ExceptionMsg));
                    
        //Create a request log for failed records here..
        FailedRequestLog.add(CreateFailedLog(acc.id,VAcc.id, System.Label.VREG_Connection_ERror+' Reason: '+ExceptionMsg, ServiceName, Url));
        System.debug('FailedRequestLog Value is :-------------------------------->'+FailedRequestLog);
        
        Try
        {
            if(FailedRequestLog.size() > 0 && FailedRequestLog != NULL)
            {
                //Insert the returned request log here
                Database.insert(FailedRequestLog);
            }
            
            if(allfailureMails.size() > 0 && allfailureMails != NULL)
            {
            //If the sync failed executed catch block should have created the messages and send them here
            Messaging.sendEmail(allfailureMails);    
            }
            
        }
        Catch(DMLException ex)
        {
            System.debug('DML Operation Failed in Future Method for SOA Customer Update-------------------------------->>>>>'+ex.getMessage());
        }
        Catch(EmailException ex)
        {
            System.debug('Email sending failed: -------------------------------->>>>>'+ex.getMessage());   
        }
    }
    
    /*
     * Utility method to create a request for failed records..
     */
    Public static SOA_Request_Log__c CreateFailedLog(Id Accid, Id VertuAccId, String ErrorMsg, String ServiceName, String Url)
    {
        SOA_Request_Log__c FailedRequestLog;
        
        if(Accid != NULL && VertuAccid != NULL)
        {
            FailedRequestLog = BG_RequestLogUtils.CreateSOALog(Accid, VertuAccId, null, null, RequestLogError, ErrorMsg, ServiceName, Url);
            return FailedRequestLog;
        }
        
        //Should not reach here..
        return null;
    }
}