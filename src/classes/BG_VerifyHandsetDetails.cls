/*************************************************
BG_VerifyHandsetDetails
Test Class: Test_BG_VerifyHandsetDetails

Controller extension for BG_RegisterHandset Page which overrides the new button for 
new handset registration

Author: Mahfuz Choudhury
Created Date: 07/07/2014

**************************************************/

public class BG_VerifyHandsetDetails {
    
    public Handset_Registration__c HandsetReg { get;set;}
    Public Boolean SecurityAnswer {get {return true;} set;}
    Public Boolean UserDefinedSQ 
    {get
    	{
        	if(HandsetReg.Private_Question__c != NULL || HandsetReg.Private_Question_Pre_defined__c == System.Label.Question_Write_Own)
            {
             	return true;
            }
            else
                return false;
    	}
     set;
    }
    Private Static Final String IMEIFormat = '^[0-9]{4}$';
    Private Static Final String UserNameFormat = '^[A-Za-z0-9._]{6,20}$';   
    Private Static Final Integer PasswordStartingLength = 7;
    Public Static String ServiceName = 'Create Customer';
    public Boolean VerifyHandsetwithSOA;
    public Boolean DisplayInputSection{get; set;}
    Public Boolean DisplayOutputSection{get; set;}
    public static String HandsetValidityStatus{get; set;}
    Public String EncryptionKey;
    Public String EncryptedPassword;
    Public String SecurityQuestion;
        
    //Constructor to execute on page load
    public BG_VerifyHandsetDetails(ApexPages.StandardController registrationcontroller)
    {
        System.debug('Record to process is: ------------->'+(Handset_Registration__c)registrationcontroller.getRecord());
        
        //If the controller was called from custom button
        if(registrationcontroller.getRecord().id != NULL)
        {
        	this.HandsetReg = BG_HandsetRegistrationUtils.getHandsetRegistrationById(registrationcontroller.getRecord().id);
        }
        //If the controller was called from new button
        else 
            this.HandsetReg = (Handset_Registration__c)registrationcontroller.getRecord();
        
        //Determines if the user input section or output section to be displayed
        DisplayInputSection = true;
        DisplayOutputSection = false;
    }
    
    //This method executes when user clicks register button and perform all necessary operations
    public void HandsetRegistration()
    {        
        VerifyHandsetwithSOA = true;
        HandsetValidityStatus = System.label.Processing_failed;
        
        //Check if the user input for IMEI matches the pattern
        if(!ValidateStringRegex(HandsetReg.IMEI__c, IMEIFormat))
        {
            //Throw an error stored in custom label for IMEI
            HandsetReg.IMEI__c.addError(System.Label.IMEI_Format);
            VerifyHandsetwithSOA = false;
        }
        
        //No Validation on VSN as customer wanted to relaxed as it changes frequently
        
        //User Name format must be within 6 - 20 characters in length
        if(!ValidateStringRegex(HandsetReg.User_Name__c, UserNameFormat))
        {
            HandsetReg.User_Name__c.addError(System.Label.Username_Format);
            VerifyHandsetwithSOA = false;
        }
        
        //Check Vertu Accounts for duplicate user Name and throw an error if found in database
        if(!ValidateUserName(HandsetReg.User_Name__c))
        {
            HandsetReg.User_Name__c.addError(System.Label.Duplicate_Username_Exists);
            VerifyHandsetwithSOA = false;
        }
        
        //Check the length of the password here and throw an error if criteria not met
        if(!ValidateStringLength(HandsetReg.Password1__c, PasswordStartingLength))
        {
            HandsetReg.Password1__c.addError(System.Label.Password_Format);
            VerifyHandsetwithSOA = false;
        }
        
        //Check if the VSN exists in a currently registered handset in Database
        if(!ValidateVSNInSalesforce(HandsetReg.VSN__c))
        {
            HandsetReg.VSN__c.addError(System.Label.Duplicate_VSN_Exists);
            VerifyHandsetwithSOA = false;
        }
        //Check if the email address in person account is unique against vertu account
        If(!ValidateEmail (HandsetReg.Customer__r.PersonEmail))
        {
         	HandsetReg.addError(System.Label.Duplicate_Email_Exists);
            VerifyHandsetwithSOA = false;
        }
        
        //Encrypt the password before sending it to SOA (Password will be in text format as the code run in System context)
        If(HandsetReg.Password1__c != '' || HandsetReg.Password1__c != NULL)
        {
            Try
            {
                //Fetch the encryption key from custom setting by name
            	EncryptionKey = BG_CustomSettingUtils.GetEncryptionKeyByName('User_Password');
                
                EncryptedPassword = BG_CryptoUtility.EncryptUsing128(HandsetReg.Password1__c, EncryptionKey);
                System.debug('Encrypted Password is:----------------------------->'+EncryptedPassword);
            }
           	Catch(Exception ex)
            {
             	HandsetReg.addError(System.Label.Password_Encryption_Error);
                VerifyHandsetwithSOA = false;
                System.debug('Password Encryption Error is:--------------------------------->'+ex.getMessage());
            }
        }
        
        //Get the value of the entered security question here
        If(HandsetReg.Private_Question_Pre_defined__c == System.Label.Question_Write_Own && HandsetReg.Private_Question__c != Null)
        {
        	SecurityQuestion = HandsetReg.Private_Question__c;   
        }
        
        //If the security question is one of the predefined questions..
        If(HandsetReg.Private_Question__c == Null)
        {
         	SecurityQuestion = HandsetReg.Private_Question_Pre_defined__c;   
        }
        
        if(VerifyHandsetwithSOA && !HandsetValidityStatus.contains(System.Label.Handset_Verified_Status))
        {
            //Prepare for call out here for phone verification
            System.debug('VerifyHandsetwithSOA value is------------------------------------------------>>>>>>'+VerifyHandsetwithSOA);
            
            //If IMEI and VSN was verified in Salesforce and entries are correct send them for verification
            if((HandsetReg.IMEI__c != '' || HandsetReg.IMEI__c != NULL) && (HandsetReg.VSN__c != NULL || 
               HandsetReg.VSN__c != '') && (HandsetReg.Customer__c != NULL || HandsetReg.Customer__c != ''))
            {   
                WSO_SOA_HandsetsetRegistrationHelper VerificationInterface = new WSO_SOA_HandsetsetRegistrationHelper();
                HandsetValidityStatus = VerificationInterface.VerifyHandsetWithSOA(HandsetReg.IMEI__c, HandsetReg.VSN__c, HandsetReg.Customer__c, HandsetReg.Service_Registration__c, ServiceName, Null,
                                                                                  HandsetReg.Retail_Account__r.Store_Code__c, HandsetReg.Other_Place_of_Purchase__c, HandsetReg.Date_of_Purchase__c,
                                                                                  HandsetReg.User_Name__c, EncryptedPassword, SecurityQuestion, HandsetReg.Security_Answer__c);   
            }
            
            System.debug('Handset Validity Status: -------------------------------------->>>>>>>'+HandsetValidityStatus);
            if(HandsetValidityStatus.contains(System.Label.Handset_Verified_Status))
            {
                //Once the record has been processed execute the following
                Database.UpsertResult save = Database.upsert(HandsetReg, false);
                    
                if(save.issuccess()){
                    //Reset the sections to be displayed here
                    DisplayInputSection = false;
                    DisplayOutputSection = true;
                }
                else if(!save.issuccess())
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Problem_Saving_Record);
                    ApexPages.addMessage(myMsg);
                    VerifyHandsetwithSOA = false; 
                }    
            }
            else       
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,HandsetValidityStatus);
                ApexPages.addMessage(myMsg);
                VerifyHandsetwithSOA = false; 
            }
        }
    }
    
    /*
     * Method to redirect users after finishing the process
     */
    
    Public Pagereference Redirect()
    {
        System.debug('Record Id is:------------------------------>'+HandsetReg.Id);
        PageReference pageRef;
        
        if(HandsetReg.Customer__c != Null)
        {
         	pageRef = new PageReference('/'+HandsetReg.Customer__c);   
        }
        else
            pageRef = new PageReference('/home/home.jsp'); 
        
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    //The following utility method validates any string providing the format passed from the
    //super class
    Public static Boolean ValidateStringRegex(String ValidateString, String format)
    {
        Boolean isMatch = false;
        //Compile the pattern passed and match with the string to be validated 
        Pattern IMEIMatchingPattern = Pattern.compile(format);
		Matcher IMEISeq = IMEIMatchingPattern.matcher((ValidateString != NULL)?ValidateString:'');   

        
        //If the pattern matches the user input then set is match value to true
        if(IMEISeq.matches())
        {
            isMatch = true;
        }
        System.debug('is Match Value after matching IMEI with expected input ----------------------->>>>>>>>>>>>>'+isMatch);
        return isMatch;
    }
    
    //The following method Reset the value for Security question section
    Public void RenderSecurityQS()
    {
        if(HandsetReg.Private_Question_Pre_defined__c == System.Label.Question_Write_Own)
        {
            UserDefinedSQ = true;   
        }
        else
            UserDefinedSQ = false; 
    }
    
    //The following method checks if the userName already exist in the system
    private boolean ValidateUserName (String UserName)
    {
        
        integer count = 0;
        
        count = CountDuplicateRecord('select count() from Vertu_Account__c where username__c=\'' + UserName + '\'limit 50000'); 
        System.debug('Number of Duplicate User Name is------------------------------------->>>>>>'+count);      
        
        return (count == 0) ? true : false;
    }
    
    /*
     *  Method to check if the account email address is unique
     */ 
    private boolean ValidateEmail (String Email) {
                
        integer count = CountDuplicateRecord('select count() from Vertu_Account__c where Primary_email_address__c=\'' + Email + '\'AND Active__c = TRUE AND VREG_ID_Vertu_Account__c != NULL');
        System.debug('Number of Duplicate Email is------------------------------------->>>>>>'+count); 
        
        return (count == 0) ? true : false; 
    }
    
    //The following method checks if the VSN already registered in Salesforce
    Public static boolean ValidateVSNInSalesforce(String VSN)
    {
        //Convert VSN to UpperCase if the input was in lower case
        String UppercasedVSN = VSN.toUpperCase();
        integer count = 0;
        
        count = CountDuplicateRecord('select count() from Handset__c where (VSN__c=\'' + UppercasedVSN + '\'AND Registered__c = TRUE) limit 50000');
        
        return (count == 0) ? true : false;
    }
    
    //The following utility method is an interface to query the database based on query provided by the calling method
    Public static integer CountDuplicateRecord(String querystring)
    {
        integer count = 0;
        try
            {
                count = Database.CountQuery(querystring);
            
            }Catch(System.QueryException ex)
            {
                System.debug('Following Exception Occured while querying for duplicate record ----------------->>>>>'+ex.getMessage());   
            }
        return count;
    }
    
    //The following method validate the length of a string providing that 
    //desired length passed from the super class
    Public static Boolean ValidateStringLength(String ValidateString, Integer SLength)
    {
        return (ValidateString.length() >= SLength) ? true : false; 
    }
    
}