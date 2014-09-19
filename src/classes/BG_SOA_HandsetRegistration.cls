/*************************************************
BG_SOA_HandsetRegistration
Test Class: Test_BG_VerifyHandsetDetails

Controller extension for Vertu Account object which gets launched from
a custom button on Vertu Account page Layout for registrering a newly
purchased Handset.

Author: Mahfuz Choudhury
Created Date: 21/07/2014

**************************************************/
public class BG_SOA_HandsetRegistration {
    
    public Vertu_Account__c VertuAcc	{get; set;}
    Public Handset__c NewHandset {get; set;}
    Public String ExistingHandsetId {get; set;}
    public Boolean DisplayInputSection{get; set;}
    Public Boolean DisplayOutputSection{get; set;}
    //Public Boolean NewHandsetOption {get; set;}
    //Public Boolean ExistingHandsetOption {get; set;}
    //Public Boolean DisplayRegButton	{get; set;}
    Public String SelectedOperation	{get{ return SelectedOperation;} set;}
    Private Static Final String IMEIFormat = '^[0-9]{4}$';
    Private Static Final String UserNameFormat = '^[A-Za-z0-9._]{6,20}$';   
    Public Static String ServiceName = 'Register Handset';
    public Boolean VerifyHandsetwithSOA;
    public static String HandsetValidityStatus{get; set;}
    /*Public List<SelectOption> OperationType 
    {
        get
        {
            if(OperationType == NULL)
            {
                return GetUserOptions(BG_CustomSettingUtils.GetSOAOpsList());
			}
            else 
                return OperationType;
        }
    }*/
    
    //Constructor to execute on page load
    public BG_SOA_HandsetRegistration(ApexPages.StandardController registrationcontroller)
    {
     	System.debug('Record to process is: ------------->'+(Vertu_Account__c)registrationcontroller.getRecord());
        
        //If the controller was called from custom button
        if(registrationcontroller.getRecord().id != NULL)
        {
        	VertuAcc = BG_VertuAccountUtils.getHandsetRegistrationById(registrationcontroller.getRecord().id);	
        }
        
        //Determines if the user input section or output section to be displayed
        DisplayInputSection = true;
        
        //Pre-fill information if this is a new request
        NewHandset = new Handset__c();
        NewHandset.Vreg_ID_Handset__c = VertuAcc.VREG_ID_Vertu_Account__c;
        NewHandset.Place_of_Purchase_Code__c = NewHandset.Account_Name__r.Store_Code__c;

    }
    
    //Method to Initialte Handset Registration Process
    Public Void HandsetRegistration()
    {
		//Set the variables to determine a call out is needed
        VerifyHandsetwithSOA = true;
        HandsetValidityStatus = System.Label.Processing_failed;

        //Check if the user input for IMEI matches the pattern
        if(!BG_VerifyHandsetDetails.ValidateStringRegex(NewHandset.IMEI__c, IMEIFormat))
        {
            //Throw an error stored in custom label for IMEI
            NewHandset.IMEI__c.addError(System.Label.IMEI_Format);
            VerifyHandsetwithSOA = false;
        }
        
        //No Validation on VSN as customer wanted to relaxed as it changes frequently
        
        
        //Check if the VSN exists in a currently registered handset in Database
        if(!BG_VerifyHandsetDetails.ValidateVSNInSalesforce(NewHandset.VSN__c))
        {
            NewHandset.VSN__c.addError(System.Label.Duplicate_VSN_Exists);
            VerifyHandsetwithSOA = false;
        }
        
        if(VerifyHandsetwithSOA && !HandsetValidityStatus.contains(System.Label.Handset_Verified_Status))
        {
            //Prepare for call out here for phone verification
            System.debug('VerifyHandsetwithSOA value is------------------------------------------------>>>>>>'+VerifyHandsetwithSOA);
            
            //If IMEI and VSN was verified in Salesforce and entries are correct send them for verification
            if((NewHandset.IMEI__c != '' || NewHandset.IMEI__c != NULL) && (NewHandset.VSN__c != NULL || NewHandset.VSN__c != ''))
            {   
                //Get the Store code for sending to SOA
                String PurchasePlace;
                if(NewHandset.Place_of_Purchase__c != NULL)
                {
                 	Account Acc = AccountUtils.GetRetailAccount(NewHandset.Place_of_Purchase__c);
                    PurchasePlace = Acc.Store_Code__c;
                    System.debug('Store code in Registration controller----------------------->'+PurchasePlace);
                }
                
                WSO_SOA_HandsetsetRegistrationHelper VerificationInterface = new WSO_SOA_HandsetsetRegistrationHelper();
                HandsetValidityStatus = VerificationInterface.VerifyHandsetWithSOA(NewHandset.IMEI__c, NewHandset.VSN__c, VertuAcc.Account_Name__c, NewHandset.Service_Registration__c, 
                                                                                   ServiceName, VertuAcc.id, PurchasePlace, NewHandset.Other_Place_of_Purchase__c, NewHandset.Date_of_Purchase__c,
                                                                                   Null, Null, Null, Null);   
            }
            
            System.debug('Handset Validity Status: -------------------------------------->>>>>>>'+HandsetValidityStatus);
            if(HandsetValidityStatus.contains(System.Label.Handset_Verified_Status))
            {       
                    //Reset the sections to be displayed here
                    DisplayInputSection = false;
                    DisplayOutputSection = true;   
            }
            else       
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,HandsetValidityStatus);
                ApexPages.addMessage(myMsg);
                VerifyHandsetwithSOA = false; 
            }
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

    /*
     * The following portion was commented as part of design change from D Chambers (Vertu)
     * but hasn't been removed if Vertu wanted to go back to the original design or wanted
     * to enhance the existing functionality.
	 */
    
    //method to check which operation user have selected
    /*Public Void CheckUserStep()
    {
        //If user Have seleted the first operation from the list
        If(SelectedOperation == BG_CustomSettingUtils.GetSOAOpsList()[1].Op_Name__c)
        {
         	NewHandsetOption = true;
            ExistingHandsetOption = false;
            DisplayRegButton = true;
            
            //Pre-fill information if this is a new request
            NewHandset = new Handset__c();
            NewHandset.Vreg_ID_Handset__c = VertuAcc.VREG_ID_Vertu_Account__c;
        }
        //If User Have Selected the second operation from the list
        else if(SelectedOperation == BG_CustomSettingUtils.GetSOAOpsList()[2].Op_Name__c)
        {
         	ExistingHandsetOption = true;
            NewHandsetOption = false;
            DisplayRegButton = true;
        }
        else
        {
         	ExistingHandsetOption = False;
            NewHandsetOption = false;   
        }
    }*/
    
    /*
	 *Utility method to Return List of SelectOptions
	 */
    
    /*Public List<SelectOption> GetUserOptions(List<SOA_Operations__c> ReturnList)
    {
        List<SelectOption> options = new List<SelectOption>();
          if(options.isEmpty())
            {
            	for(integer i = 0; i<ReturnList.size();i++)
            	{	
                    options.add(new SelectOption(ReturnList[i].Op_Name__c,ReturnList[i].Op_Name__c));
            	}
            }
      return Options;
    }
    
    /*
     * Method to return All the existing Handsets in a select options list if users select to
     * register an existing handset
	 */
    
    /*Public List<SelectOption> GetHandsetList()
    {
     	System.debug('Vertu Account Id Is:---------------------->'+VertuAcc.id);
        List<Handset__c> HandsetList = BG_HandsetUtils.getHandsetRegistrationById(VertuAcc.id);
        List<SelectOption> options = new List<SelectOption>();
        if(options.isEmpty())
            {
				If(HandsetList.Size() > 0)
                {
                 	for(integer i = 0; i<HandsetList.size();i++)
            		{	
                        options.add(new SelectOption(HandsetList[i].id,(HandsetList[i].Model_Variant__c != Null)?HandsetList[i].Model_Variant__c:HandsetList[i].Vreg_ID_Handset__c));
            		}   
                }
                else
                {
                 	options.add(new SelectOption(System.Label.Handset_Not_Found,System.Label.Handset_Not_Found));   
                }
            }
      	return Options;
    }*/
}