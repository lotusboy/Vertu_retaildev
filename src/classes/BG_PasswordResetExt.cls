/*************************************************
BG_PasswordResetExt
Test Class: Test_BG_PasswordResetExt

Controller extension for Vertu Account object which gets launched from
a custom button on Vertu Account page Layout for resetting the user password

Author: Mahfuz Choudhury
Created Date: 29/07/2014

**************************************************/
public class BG_PasswordResetExt {
    //Declare all variables and properties here..
    Public Vertu_Account__c VertuAcc {get; set;}
    Public String UserPassword {get; set;}
    Public String PasswordVerificationStatus {get; set;}
    Public Boolean DisplayOutput {get; set;}
    Public Boolean DisplayInput {get; set;}
    Public Boolean SendPasswordRequest {get; set;}
    Private Static Final Integer PasswordStartingLength = 7;
    Private String EncryptionKey;
    Private String EncryptedPassword;
    Public Static String ServiceName = 'Password Reset';
    Public Static Final String Password_Encryption_Setting_Name = 'User_Password';
    
    //Constructor...
	Public BG_PasswordResetExt(ApexPages.StandardController VertuAccController)
    {
     	//Get the record from the database on button click
        if(VertuAccController.getRecord().id != NULL)
        {
        	VertuAcc = BG_VertuAccountUtils.getHandsetRegistrationById(VertuAccController.getRecord().id);	
        }
        
        //Check if the user name is not empty..
        If(VertuAcc.Username__c == NULL)
        {
            VertuAcc.Username__c = System.Label.UserName_Message;
        }
        
        //Display the input panel to user on page load
        DisplayInput = true;
    }
    
    public void ResetPassword()
    {
     	//Set the request boolean to true assuming user input is valid and processing status to failed 
     	//as this will be set success after successful processing
        SendPasswordRequest = true;
        PasswordVerificationStatus = System.label.Processing_failed;
        
        //Check the length of the password here and throw an error if criteria not met
        If(!ValidateStringLength(UserPassword, PasswordStartingLength))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Password_Format);
            ApexPages.addMessage(myMsg);
            SendPasswordRequest = false;
        }
        
        //If the password is valid then encrypt the password using AES 128
        Else If(ValidateStringLength(UserPassword, PasswordStartingLength))
        {
            //Fetch the encryption key from custom setting by name
            System.debug('Password Encryption Custom setting Name is:------------------------>'+Password_Encryption_Setting_Name);
            EncryptionKey = BG_CustomSettingUtils.GetEncryptionKeyByName(Password_Encryption_Setting_Name);
            If(EncryptionKey != NULL || EncryptionKey != '')
            {
                EncryptedPassword = BG_CryptoUtility.EncryptUsing128(UserPassword, EncryptionKey);
                System.debug('Encrypted Password is:----------------------------->'+EncryptedPassword);
            }
           	Else
            {
             	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Password_Encryption_Error);
                ApexPages.addMessage(myMsg);
                SendPasswordRequest = false;
            }
        }
        
        //If the password is valid send the request to SOA for processing
        If(SendPasswordRequest && EncryptedPassword != NULL && !PasswordVerificationStatus.contains(System.Label.Password_Reset_Success_Message))
        {
         	WSO_SOA_HandsetsetRegistrationHelper PasswordResetCall = new WSO_SOA_HandsetsetRegistrationHelper();
            PasswordVerificationStatus = PasswordResetCall.ProcessResetPasswordRequest(VertuAcc.Account_Name__c, VertuAcc.id, VertuAcc.VREG_ID_Vertu_Account__c, VertuAcc.Username__c, EncryptedPassword, ServiceName);
            System.debug('Status of Password Reset after Callout:------------------------->'+PasswordVerificationStatus);
            
            //If the callout was completed successfully, notify user on the page
        	If(PasswordVerificationStatus.contains(System.Label.Password_Reset_Success_Message))
        	{
         		//Display the output section
            	DisplayOutput = true;
            	DisplayInput = false;
        	}
        
        	//If operation was not processed
        	else
        	{
         		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,PasswordVerificationStatus);
            	ApexPages.addMessage(myMsg);
            	SendPasswordRequest = false;   
			}
        }
    }
    
    //method for Redirect users on button click
    Public Pagereference Redirect()
    {
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
    
    //The following method validate the length of a string providing that 
    //desired length passed from the super class
    Public static Boolean ValidateStringLength(String ValidateString, Integer SLength)
    {
        return (ValidateString.length() >= SLength) ? true : false; 
    }
}