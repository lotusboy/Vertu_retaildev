/*************************************************
BG_DeRegisterHandset
Test Class: 

Standard controller for Handset__c object, currently initiate the deregistration process
from DeRegister Handset custom button on the handset page layout.

Author: Mahfuz Choudhury
Created Date: 24/07/2014

**************************************************/
public class BG_DeRegisterHandset {
    Public Handset__c Handset {get; set;}
    public boolean SendDeRegistrationRequest {get; set;}
    Public boolean DisplayOutputSection	{get; set;}
    Public boolean Success	{get; set;}
    Public Static String DeRegistrationStatus {get; set;}
    Public Static String ServiceName = 'Handset DeRegistration';
    public BG_DeRegisterHandset(ApexPages.StandardController HandsetController)
    {
		System.debug('Handset Record to process is: ------------->'+HandsetController.getRecord());
        Handset = (Handset__c)HandsetController.getRecord();
        if(Handset.id != Null)
        {
            Handset = BG_HandsetUtils.getExistingHandsetById(Handset.id);
        }
        SendDeRegistrationRequest = true;
    }
    
    Public void DeRegistration()
    {   
        DeRegistrationStatus = System.Label.Processing_failed;
        System.debug('Handset is:--------------------------->'+Handset);
        //If handset is not null send it for processing
        If(Handset != Null)
    	{
        	WSO_SOA_HandsetsetRegistrationHelper CallSOA = new WSO_SOA_HandsetsetRegistrationHelper();
            DeRegistrationStatus = CallSOA.deRegisterHandset(Handset, ServiceName);
    	}
        
        //Display the output section for the callout
        If(DeRegistrationStatus.contains(System.Label.DeRegister_Success_Message))
        {
         	SendDeRegistrationRequest = false;
			DisplayOutputSection = true;
			Success = true;            
        }
        //If there was a problem for processing the request
        else if(DeRegistrationStatus.contains(System.Label.DeRegister_Failure_Message))
        {
         	SendDeRegistrationRequest = false;
			DisplayOutputSection = true;
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.DeRegister_Failure_Message);
            ApexPages.addMessage(myMsg);
        }
        //If there was a problem saving the log
        else if(DeRegistrationStatus.contains(System.Label.Request_Log_Error))
        {
         	SendDeRegistrationRequest = false;
			DisplayOutputSection = true;
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Request_Log_Error);
            ApexPages.addMessage(myMsg);
        }
    }
    
    Public Pagereference Redirect()
    {
        System.debug('Record Id is:------------------------------>'+Handset.Id);
        PageReference pageRef;
        
        if(Handset.Account_Name__c != Null)
        {
         	pageRef = new PageReference('/'+Handset.Account_Name__c);   
        }
        else
            pageRef = new PageReference('/home/home.jsp'); 
        
        pageRef.setRedirect(true);
        
        return pageRef;
    }
}