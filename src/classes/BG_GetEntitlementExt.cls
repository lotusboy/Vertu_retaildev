/*************************************************
BG_GetEntitlementExt
Test Class: Test_BG_GetEntitlementExt

Controller extension for Vertu Account object which gets launched from
a custom button on Vertu Account page Layout for getting the entitlements
from Galapagos via SOA

Author: Mahfuz Choudhury
Created Date: 31/07/2014

**************************************************/

public class BG_GetEntitlementExt {
    //Declaring the variables here for Get Entitlements here..
    Public Boolean ShowEntitlementRequest {get; Private set;}
    Public Boolean DisplayOutputsection {get; Private set;}
    Public WS_SOA_ServiceInfo.GetEntitlementResponse EntitlementDetailList {get; set;}
    Public boolean SendEntitlementRequest;
    Public Vertu_Account__c VertuAcc;
    Public String RemainingEntitlementStatus
    {
        get
        {
         	If(EntitlementDetailList.EntList == NULL)
            {
                Return System.label.Entitlement_Status;
            }
            Return NULL;
        }
        set;
    }
    
    //Declare Variables for Create Entitlement section here..
    Public Entitlement__c Entitlement {get; set;}
    Public Static String CreateEntitlementStatus {get; Private set;}
    Public Static String ServiceName = 'Create Entitlement Service'; 
    
	//Constructor...
    Public BG_GetEntitlementExt(ApexPages.StandardController VertuAccController)
    {
     	//Get the record from the database on button click
     	VertuAcc = (Vertu_Account__c)VertuAccController.getRecord();
        
        if(VertuAcc.id != NULL)
        {
        	VertuAcc = BG_VertuAccountUtils.getHandsetRegistrationById(VertuAcc.id);
        } 
        
        ShowEntitlementRequest = true;
        
        //Create a new Instance of Entitlement here for Create Entitlement Request
        Entitlement = new Entitlement__c();
    }
    
    //Method to fetch Entitlements from SOA on button click
    Public void GetEntitlementDetails()
    {
        //Set the entitlement request to true to make the callout
        SendEntitlementRequest = true;
        
        //If the VregId is Missing display error on the page
        If(VertuAcc.VREG_ID_Vertu_Account__c == NULL || VertuAcc.VREG_ID_Vertu_Account__c == '')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Invalid_Vreg_Id);
            ApexPages.addMessage(myMsg);
            DisplayOutputsection = true;
            SendEntitlementRequest = false;
        }
        
        //If VregId is valid and not null
        Else If(SendEntitlementRequest)
        {
         	WSO_SOA_HandsetsetRegistrationHelper GetEntitlement = new WSO_SOA_HandsetsetRegistrationHelper();
            EntitlementDetailList = GetEntitlement.GetEntitlements(VertuAcc.VREG_ID_Vertu_Account__c, VertuAcc.id, VertuAcc.Account_Name__c);
            System.debug('EntitlementDetailList----------------------->'+EntitlementDetailList);
            
            If(EntitlementDetailList != NULL)
            {
                String Status;
                If(EntitlementDetailList.Acknowledgement != NULL)
                {
                 	Status = (EntitlementDetailList.Acknowledgement.Status != NULL) ? EntitlementDetailList.Acknowledgement.Status : '';   
                }
                System.debug('Status is:---------------------------------->'+Status);
                If(EntitlementDetailList.SalesforceError != Null || !Status.contains('SUCCESS'))
                {
                 	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Get_Entitlement_Failure);
            		ApexPages.addMessage(myMsg);
            		DisplayOutputsection = true;
            		SendEntitlementRequest = false;   
                }
                
                Else If(EntitlementDetailList.SalesforceError == Null)
                {
                 	DisplayOutputsection = true;   
                }
            }
        }
    }
    
    //Method for Creating an Entitlemet Request
    Public Void CreateEntitlementRequest()
    {   
     	WSO_SOA_HandsetsetRegistrationHelper CreateEntitlement = new WSO_SOA_HandsetsetRegistrationHelper();
        System.debug('Vertu Account: '+VertuAcc+'Entitlement: '+Entitlement);
        CreateEntitlementStatus = CreateEntitlement.CreateEntitlementRequest(VertuAcc, Entitlement, ServiceName);
        
        //If the Request was Processed Successfully then just display the success message
        If(CreateEntitlementStatus == System.Label.Entitlement_request_success)
        {
            DisplayOutputSection = true;
            ShowEntitlementRequest = false;
        }
        //There was an issue processing the record notify user about it
        Else If(CreateEntitlementStatus != System.Label.Entitlement_request_success)
        {
         	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,CreateEntitlementStatus);
            ApexPages.addMessage(myMsg);
            DisplayOutputsection = true;
            ShowEntitlementRequest = false;  
        }
    }
    
    //method for Redirect users on button click
    Public Pagereference Redirect()
    {
        System.debug('Vertu Account Id is:------------------------------>'+VertuAcc.Id);
        PageReference pageRef;
        
        if(VertuAcc.Account_Name__c != NULL)
        {
         	pageRef = new PageReference('/'+VertuAcc.Account_Name__c);   
        }
        else
            pageRef = new PageReference('/'+VertuAcc.Id); 
        
        pageRef.setRedirect(true);
        
        return pageRef;
    }
}