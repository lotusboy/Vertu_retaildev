/*************************************************
BG_RequestLogUtils
Test Class:

Class for handling all the logic, utility methods for SOA Request Log

Author: Mahfuz Choudhury
Created Date: 16/07/2014

**************************************************/

public class BG_RequestLogUtils {
    
    /*
     * Utility method to create a Request Log based on User supplied details
     */
    Public Static SOA_Request_Log__c CreateSOALog(ID Accid, Id VertuAccID, String RequestId, String VregID, String Status, String Message, String ServiceName, String Url)
    {   
        //Create a new request log record for each callout
        SOA_Request_Log__c SOARequest = new SOA_Request_Log__c();
        
        If(Status == 'SUCCESS') Status = 'New';
        
        if(Accid != NULL)
        {
            SOARequest.Customer__c = Accid;
        }
        
        If(RequestId != NULL)
        {
         	SOARequest.Request_ID__c = RequestId;   
        }
        
        if(VertuAccID != NULL)
        {
            SOARequest.Vertu_Account__c = VertuAccID;    
        }
        SOARequest.VREG_ID__c = SOA_WSO_MaintainCustomerCall.NullCheckerMethod(VregID);
        SOARequest.Status__c = Status;
        SOARequest.SOA_Error_Message__c = Message;
        SOARequest.Service_Name__c = ServiceName;
        SOARequest.Service_URL__c = url;
        
        If(UserInfo.getUserId() != NULL)
        {
         	SOARequest.User__c = UserInfo.getUserId();   
        }
        
        System.debug('SOARequest Created in Utility Class: -------------------------------------> '+SOARequest);
        return SOARequest;
        
    }
    
    Public Static String InsertSOALog(SOA_Request_Log__c SOARequest)
    {
        String Status = '';
        Try
        {
            if(SOARequest != NULL)
            {
                Database.insert(SOARequest);
            }
            
        }Catch(DMLException ex)
        {
            Status = System.Label.Request_Log_Error;
            System.debug('Failed to Create a Request Log: '+ex.getMessage());
        }
        return Status;
    }
}