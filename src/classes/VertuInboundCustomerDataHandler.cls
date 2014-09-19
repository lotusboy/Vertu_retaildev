/*
Developer Name   : Mick Nicholson (BrightGen tTd)
Deployment Date  : 
Description      : Handler class to process incoming JSON content. Called from VertuInboundDataAfterInsert trigger
*/ 

/*
Developmer Name  : Duncan Chambers (Vertu)
Deployment date  : 21-11-2013
Description		 :  	
				 place_of_purchase has been changed to purchase_place in the JSON message 
				 so the tag has been changed in this code block

Modified By: Mahfuz Choudhury (BrightGen)
Modification Date: 10-07-2014
Deployment Date:
Description: New Field Mapping with JSON Added (Instructed By D Chambers (Vertu))
*/

global class VertuInboundCustomerDataHandler {

    // Top level wrapper class representing JSON content
    class jsonWrapper
    {
        public ContactDetail [] contact_details {get; set;}
        public Phone [] phones {get; set;}
        public MarketingPermission marketing_permissions {get; set;}
        public PersonalDetail personal_details {get; set;}
        public Service [] services {get; set;}
        
        public string notification_type {get; set;}
        public string id {get; set;}
        public id sfdcRecordID {get; set;}
    } 
    
    // Inner classes        
    class ContactDetail
    {
        // These are common to all contact types
        public boolean isDefault {get; set;}
        public boolean isValid {get; set;}
        public string id {get; set;}
        
        // These are specific to whether contact type is phone, email or address
        public string number_type {get; set;}
        public string phone_number {get; set;}
        public string country {get; set;}
        public string country_code {get; set;}
        public string postcode {get; set;}
        public string address {get; set;}
        public string email {get; set;}
        

    }

    class Phone
    {
        public string type_designator {get; set;}
        public string type_description {get; set;}
        public string purchase_place {get; set;}
        public string date_of_registration {get; set;}
        //Following field Added by Mahfuz Choudhury as Incoming JSON will contain this field and needs Mapping
        Public boolean first_time_registration {get; set;}
        public string type_name {get; set;}
        public string purchase_date {get; set;}
        public string imei {get; set;}
        public string serial_number {get; set;}
        public string type_code {get; set;}
        public Service [] services;
        
    }

    class MarketingPermission
    {
        boolean post {get; set;}
        boolean mobile_messaging {get; set;}
        boolean telephone {get; set;}
        boolean email {get; set;}
       
        
    }

    class PersonalDetail 
    {
        public string username {get; set;}
        public string secret_answer {get; set;}
        public string first_name {get; set;}
        public string surname {get; set;}
        public string title {get; set;}
        public string spoken_language_code {get; set;}
        public boolean is_male {get; set;}
        public string written_language_code {get; set;}
        public string date_of_birth {get; set;}
        public string secret_question {get; set;}
        public string nationality {get; set;}
        Public Password password; 
        
    }


    class Service
    {
        public string name {get; set;}
        public string language_name {get; set;}
        public string language_code {get; set;}
        public boolean suspended {get; set;}
        public Entitlement [] entitlements {get; set;}
               
    }

    class Entitlement
    {
        public string duration {get; set;}
        public string end_date {get; set;}
        public string level {get; set;}
        public string start_date {get; set;}

    }
    
    //The following object was added by Mahfuz Choudhury for Password fields mapping which is nested under
    // personal details of JSON message
    class Password
    {
        Public string encrypted {get; set;}
        Public boolean expired {get; set;}
        public string type {get; set;}
    }

    // Static objects
    
    static List <string> listVregIDs = new List <string>(); 
    static Map<String, Vertu_Account__c> mapOfVertuAccounts;
    static Map<String, id> mapOfVregIds2PersonAcc;
    static Map<String, id> mapOfUsername2PersonAcc;     
    static Map<string, Handset__c[]>  mapVregID2Handset;
    static Map<String, account> storeCode2AccountMap;
    static id retailStoreRecordTypeID;
    static id personAccountRecordTypeID;        
    static Map <id, Vertu_Inbound_Data__c> jsonStatusUpdMap;
    static Map<String, Country_Language_Codes__c> countryLanguageCodes = Country_Language_Codes__c.getAll();
    static Map<String, ISO_Country_Codes__c> isoCountryCodes = ISO_Country_Codes__c.getAll();
    static Map<String, Nationalities__c> nationalities = Nationalities__c.getAll();
    
    public static String CUSTOMER_REGISTER = 'customer.register';
    public static String CUSTOMER_UPDATE = 'customer.update';
    public static String CUSTOMER_DELETE = 'customer.delete';
    static final String MOBILE = 'MOBILE';
    static final String LANDLINE = 'LANDLINE';
     

    /**
     *  Helper method to determine country based on telephone number
     *  Utilises custom setting Reverse_Country_Code__c
     *  20/12/2012: Changed algorithm to begin searching from length of phone number downwards
     */
          
    public static string getCountryFromPhone(string phone, boolean suffixCountryCode)
    {
        Map<String, Reverse_Country_Code__c> reverseCountryCodes = Reverse_Country_Code__c.getAll();
        String country = '';
        if (phone.length() > 2) { // Can't process a phone number shorter than 2 char
            for (integer i=phone.length()-1; i > 1; i--)
            {
                if (reverseCountryCodes.containsKey(phone.left(i)) == true)
                {
                    Reverse_Country_Code__c reverseCountryCodeObj = reverseCountryCodes.get(phone.left(i));
                    country = reverseCountryCodeObj.Country__c; 
                    if (suffixCountryCode) // Suffix country code, eg. United Kingdom +44
                        country += ' ' + phone.left(i);
                    return country;
                }       
            }   
        }
        return null; // Default picklist selection if country code not found
    }

    /*
     *   Factory method that returns Vertu Account sObject 
     *   Required params: JsonWrapper object and notification type
     *   Valid values of notification type are: customer.register & customer.update
     */
    static Vertu_Account__c createVertuAccount(JsonWrapper j, string notificationType)
    {

                Country_Language_Codes__c countryLanguageCodeObj;
                ISO_Country_Codes__c isoCountryCodeObj;
                Nationalities__c nationalityObj;

                Vertu_Account__c v;
                String vregID = j.id;
                //Account a;
                Account parentAccount;
                
                if (notificationType == CUSTOMER_REGISTER) {
                    v = new Vertu_Account__c();

                    // Use VREG-ID as foreign key to establish parent-child relationship 
                    // between Account & Vertu Account

                    // Begin OQ: 22/01/2013
                    // Changes for Retail Portal use case where new Vertu Acc added
                    // to existing Person Acc
                   
                    if (mapOfUsername2PersonAcc.containsKey(j.personal_details.username) == true) {
                        System.debug('createVertuAccount: Adding new vertu acc to existing account');
                        //parentAccount = new Account( id = mapOfUsername2PersonAcc.get(j.personal_details.username));
                        	System.debug('createHandset: Adding new vertu acc to existing account' + mapOfUsername2PersonAcc.get(j.personal_details.username));
                        	id parentAccountID = mapOfUsername2PersonAcc.get(j.personal_details.username);
                        	parentAccount = new Account(id = parentAccountID);
                        	v.Account_Name__c = parentAccount.id; 
                    }
                    else {
                        parentAccount = new Account();
                    	parentAccount.Vreg_ID__c = j.id;
                    	v.Account_Name__r = parentAccount;                         
                    }
 
                    // End: OQ 22/01/2013                    
                    
                    
                    v.VREG_ID_Vertu_Account__c = j.id;
                    v.Active__c = true;
                }
                // ****** CUSTOMER UPDATE **********
                else if (notificationType == CUSTOMER_UPDATE) { 
                    
                    v = mapOfVertuAccounts.get(vregID);
                    if (v == null) {
                        System.debug('Unknown VREG-ID:' + j.id + ', ' + notificationType + ' failed.');
                        updateJsonStatus(j.sfdcRecordId, 'Error', 'Unknown VREG-ID:' + j.id + ', ' + notificationType + ' failed.');  
                        return v;   
                    }
                                     
                }
                
                // Add recordID of originating Json record
                v.Vertu_Inbound_Data_ID__c = j.sfdcRecordID;
                    
                // Personal Details
                if (j.personal_details <> null) {
                    v.Title__c = j.personal_details.title;
                    v.First_Name__c = j.personal_details.first_name;
                    v.Last_Name__c = j.personal_details.surname;
                    v.Username__c = j.personal_details.username;    
                    if (j.personal_details.date_of_birth <> null)
                        v.Date_of_Birth__c = date.valueOf(j.personal_details.date_of_birth);
                    
                    if (j.personal_details.spoken_language_code <> null) {
                        countryLanguageCodeObj = countryLanguageCodes.get(j.personal_details.spoken_language_code);
                        if (countryLanguageCodeObj <> null)
                            v.Vertu_Spoken_Language__c = countryLanguageCodeObj.Language__c;
                    }
                            
                    if (j.personal_details.written_language_code <> null) {
                        countryLanguageCodeObj = countryLanguageCodes.get(j.personal_details.written_language_code);
                        if (countryLanguageCodeObj <> null)
                            v.Vertu_Written_Language__c = countryLanguageCodeObj.Language__c;
                    }
                    
                    if (j.personal_details.nationality <> null) {
                        nationalityObj = nationalities.get(j.personal_details.nationality);        
                        if (nationalityObj <> null)
                            v.Nationality_Country__c = nationalityObj.Nationality__c;
                    }
                    v.Security_Question__c = j.personal_details.secret_question;
                    v.Security_Answer__c = j.personal_details.secret_answer;
                    
                    //The following Mapping was Added by Mahfuz Choudhury as Part of new Mapping of JSON 
                    v.Password__c = j.personal_details.password.encrypted;
                    v.Password_Reset__c = j.personal_details.password.expired;
                    
                    if(j.personal_details.password.type == 'smd5')
                    	v.Password_Encryption__c = 'Galapagos';
                    else if(j.personal_details.password.type == 'Legacy')
                        v.Password_Encryption__c = 'Legacy'; //end of code by Mahfuz Choudhury

                    if (j.personal_details.is_male == null)
                        v.Gender__c = 'N/A';
                    else    
                        v.Gender__c = j.personal_details.is_male == true ? 'Male' : 'Female';                    
                    
                }
                
                if (v.Last_Name__c == null)
                    v.Last_NAme__c = 'Please Update';
                    
                // Contact Details          
                integer numOfMobilePhones = 0;
                integer numOfLandlinePhones = 0;
                integer numOfEmailAddr = 0;
                
                v.Primary_email_address__c = '';
                v.Secondary_Email_Address__c = '';
                v.Third_Email_Address__c = '';
                v.Fourth_Email_Address__c = '';
                v.Fifth_Email_address__c = '';
                v.Mobile_Phone__c = '';
                v.Other_Phone__c = '';
                v.Home_Phone__c = '';
                v.VREG_Notes__c = '';
                
                if (j.contact_details <> null) {
                    for (ContactDetail c : j.contact_details) {

                        if (c.phone_number <> null && c.number_type == MOBILE) {
                            numOfMobilePhones++;
                            
                            if (numOfMobilePhones == 1) {
                                v.Mobile_Phone__c = c.phone_number;
                                v.Mobile_Phone_ID__c = c.id;
                            }
                            else if (numOfMobilePhones > 1) {
                                String existingNotesValue = '';
                                if (v.VREG_Notes__c <> null)
                                    existingNotesValue = v.VREG_Notes__c; 
                                v.VREG_Notes__c = existingNotesValue + 'MOBILE #' + numOfMobilePhones + ': ' + c.phone_number + '\n';                               
                            }
                                 
                        }                                                   
                                            
                        if (c.phone_number <> null && c.number_type == LANDLINE) {
                            numOfLandlinePhones++;
                            if (numOfLandlinePhones == 1) {
                                v.Home_Phone__c = c.phone_number;
                                v.Home_Phone_ID__c = c.id;
                            }
                            else if (numOfLandlinePhones  == 2) {
                                v.Other_Phone__c = c.phone_number;
                                v.Other_Phone_ID__c = c.id;
                            }
                            else if (numOfLandlinePhones > 2) {
                                String existingNotesValue = '';
                                if (v.VREG_Notes__c <> null)
                                    existingNotesValue = v.VREG_Notes__c; 
                                v.VREG_Notes__c = existingNotesValue + 'LANDLINE #' + numOfLandLinePhones + ': ' + c.phone_number + '\n';                               
                            }
                        }
                        
                        if (c.email <> null && c.isDefault == true) {
                            v.Primary_email_address__c = c.email;
                            v.Primary_email_address_id__c = c.id;
                        }
                        
                        if (c.email <> null && c.isDefault == false) {
                            numOfEmailAddr++;
                            if (numOfEmailAddr == 1) {
                                v.Secondary_Email_Address__c = c.email;
                                v.Secondary_Email_Address_id__c = c.id;
                            }
                            else if (numOfEmailAddr == 2) {
                                v.Third_Email_Address__c = c.email;
                                v.Third_Email_Address_id__c = c.id;
                            } 
                            else if (numOfEmailAddr == 3) {
                                v.Fourth_Email_Address__c = c.email;
                                v.Fourth_Email_Address_id__c = c.id;
                            }
                            else if (numOfEmailAddr == 4) {
                                v.Fifth_Email_address__c = c.email;
                                v.Fifth_Email_address_id__c = c.id;
                            }
                            else if (numOfEmailAddr > 4) {
                                String existingNotesValue = '';
                                if (v.VREG_Notes__c <> null)
                                    existingNotesValue = v.VREG_Notes__c;                               
                                v.VREG_Notes__c = existingNotesValue + 'EMAIL #' + numOfEmailAddr + ': ' + c.email + '\n'; 
                            }
                        }
                        
                        // Primary address
                        if (c.address <> null && c.isDefault == true)              
                            v.Street__c = c.address;
                        
                        if (c.country <> null && c.isDefault == true)
                            v.Country__c = c.country;
                        
                        if (c.postcode <> null && c.isDefault == true )
                            v.Post_Code__c = c.postcode;
                            
                        // Seconary address
                        if (c.address <> null && c.isDefault == false) {
                            
                            string strAddress = '';
                            boolean addressElementsComplete = false;
                            strAddress = c.address;
                            if (c.postcode <> null)
                                strAddress += '\n' + c.postcode;
                            if (c.country <> null) {
                                strAddress += '\n' + c.country;
                                addressElementsComplete = true;
                            }
                            if (addressElementsComplete == true) { 
                                String existingNotesValue = '';
                                if (v.VREG_Notes__c <> null)
                                    existingNotesValue = v.VREG_Notes__c;
                                v.VREG_Notes__c = existingNotesValue + 'SECONDARY ADDRESS: ' + strAddress + '\n';
                                
                            } 
                        }
                    } // End for
                }
                
                if (j.marketing_permissions <> null) {
                    v.Email_Me__c = j.marketing_permissions.email;
                    v.SMS_Me__c = j.marketing_permissions.mobile_messaging;
                    v.Mail_Me__c = j.marketing_permissions.post;
                    v.Phone_Me__c = j.marketing_permissions.telephone;
                }               
                
            return v;       
    }

    /*
     *   Factory method that returns Account sObject 
     *   Required params: JsonWrapper object and notification type
     *   Valid values of notification type are: customer.register & customer.update
     */
    static Account createPersonAccount(JsonWrapper j, string notificationType)
    {
                Country_Language_Codes__c countryLanguageCodeObj;
                ISO_Country_Codes__c isoCountryCodeObj;
                Nationalities__c nationalityObj;
                String vregID = j.id;

                Account a;

                if (notificationType == CUSTOMER_UPDATE)
                {
                    // Instantiate Vertu_Account sObject associated with this VREG-ID
                    Vertu_Account__c v = mapOfVertuAccounts.get(vregID);
                    // Get parent Person Account
                    id parentAccountID = mapOfVregIds2PersonAcc.get(vregID);
                    
                    a = new Account(id = parentAccountID);
                    if (v == null) {
                        System.debug('Unknown VREG-ID:' + j.id + ', ' + notificationType + ' failed');
                        updateJsonStatus(j.sfdcRecordId, 'Error', 'Unknown VREG-ID:' + j.id + ', ' + notificationType + ' failed');  
                        return null;                    
                    }               
                }
                else if (notificationType == CUSTOMER_REGISTER)
                {

                    if (mapOfUsername2PersonAcc.containsKey(j.personal_details.username) == true) {
                        a = new Account( id = mapOfUsername2PersonAcc.get(j.personal_details.username));
                    }
                    else {
                        a = new Account();
                    }

                    //a = new Account();
                    
                    // Set the Record Type
                    a.RecordTypeId = personAccountRecordTypeID;    
                    a.Vreg_ID__c = j.id; // External ID used as foreign key         
                }
                else
                {
                    System.debug('Unknown notification_type: ' + notificationType);
                    updateJsonStatus(j.sfdcRecordId, 'Error', 'Unknown notification_type: ' + notificationType);                    
                    return null;
                }

                // Add recordID of originating Json record
                a.Vertu_Inbound_Data_ID__c = j.sfdcRecordID;

                // Personal Details
                if (j.personal_details <> null) {
                    
                    a.Salutation = j.personal_details.title;
                    a.FirstName = j.personal_details.first_name;
                    a.LastName = j.personal_details.surname;
                    if (j.personal_details.date_of_birth <> null)
                        a.PersonBirthdate = date.valueOf(j.personal_details.date_of_birth);
                    if (j.personal_details.is_male == null)
                        a.Gender__pc = 'N/A';
                    else    
                        a.Gender__pc = j.personal_details.is_male == true ? 'Male' : 'Female';

                    if (j.personal_details.spoken_language_code <> null) {
                        countryLanguageCodeObj = countryLanguageCodes.get(j.personal_details.spoken_language_code);
                        if (countryLanguageCodeObj <> null)
                            a.Vertu_Spoken_Language__c = countryLanguageCodeObj.Language__c;
                    }
                            
                    if (j.personal_details.written_language_code <> null) {
                        countryLanguageCodeObj = countryLanguageCodes.get(j.personal_details.written_language_code);
                        if (countryLanguageCodeObj <> null)
                            a.Vertu_Written_Language__pc = countryLanguageCodeObj.Language__c;
                    }           

                    if (j.personal_details.nationality <> null) {
                        nationalityObj = nationalities.get(j.personal_details.nationality);
                        if (nationalityObj <> null)
                            a.Nationality__pc = nationalityObj.Nationality__c;
                    }
                
                }
                
                if (a.LastName == null)
                    a.LastName = 'Please Update';
                
                // Contact Details          
                integer numOfPhone = 0;
                integer numOfMobile = 0;
                integer numOfEmailAddr = 0;

                // Clear out old email addresses & phone numbers
                a.PersonEmail = '';
                a.Secondary_Email_Address__pc = '';
                a.Third_Email_Address__pc = '';
                a.Fourth_Email_Address__pc = '';
                a.Fifth_Email_address__pc = '';
                a.PersonMobilePhone = '';
                a.Mobile_Country__c = null;
                a.PersonHomePhone = '';
                a.Home_Phone_Country__c = null;         
                a.PersonOtherPhone = '';
                a.Other_Phone_Country__c = null; 
                
                if (j.contact_details <> null) {
                    for (ContactDetail c : j.contact_details) {
                       
                        if (c.country <> null && c.isDefault == true) {
                            a.Country_of_Residence__pc = c.country;
                        }
            
                        if (c.phone_number <> null && c.number_type == MOBILE) {
                            numOfMobile++;
                            if (numOfMobile == 1) { // First mobile
                                a.PersonMobilePhone = c.phone_number;
                                a.Mobile_Country__c = getCountryFromPhone(c.phone_number, true);    
                            }
                            else { // Second mobile 
                                a.PersonOtherPhone = c.phone_number;
                                a.Other_Phone_Country__c = getCountryFromPhone(c.phone_number, true);
                            }
                        }
            
                        if (c.phone_number <> null && c.number_type == LANDLINE) {
                            numOfPhone++;
                            if (numOfPhone == 1) {
                                a.PersonHomePhone = c.phone_number;
                                a.Home_Phone_Country__c = getCountryFromPhone(c.phone_number, true);
                            }
                            else {
                                a.PersonOtherPhone = c.phone_number;
                                a.Other_Phone_Country__c = getCountryFromPhone(c.phone_number, true);                           
                            }
                        }
                        
                        if (c.email <> null && c.isDefault == true)
                            a.PersonEmail = c.email;
                        
                        if (c.email <> null && c.isDefault == false) {
                            numOfEmailAddr++;
                            if (numOfEmailAddr == 1) {
                                a.Secondary_Email_Address__pc = c.email;
                            }
                            else if (numOfEmailAddr == 2) {
                                a.Third_Email_Address__pc = c.email;
                            } 
                            else if (numOfEmailAddr == 3) {
                                a.Fourth_Email_Address__pc = c.email;
                            }
                            else if (numOfEmailAddr == 4) {
                                a.Fifth_Email_address__pc = c.email;
                            }
                        }
                        
                        if (c.address <> null && c.isDefault == true)              
                            a.PersonMailingStreet = c.address;
                        else if (c.address <> null & c.isDefault == false) {
                            a.PersonOtherStreet = c.address;
                        }
                        
                        if (c.country <> null && c.isDefault == true)
                            a.PersonMailingCountry = c.country;
                        else if (c.country <> null & c.isDefault == false) {
                            a.PersonOtherCountry = c.country;
                        }
                        
                        if (c.postcode <> null && c.isDefault == true )
                            a.PersonMailingPostalCode = c.postcode;
                        else if (c.postcode <> null & c.isDefault == false) {
                            a.PersonOtherPostalCode = c.postcode;
                        }  
                            
                            
                            
                    } // end Contact Details for
                } // end Contact Details If
                
                // Marketing Permissions
                
                if (j.marketing_permissions <> null) {
                    a.Email_Me__pc = j.marketing_permissions.email;
                    a.SMS_Me__pc = j.marketing_permissions.mobile_messaging;
                    a.Mail_Me__pc = j.marketing_permissions.post;
                    a.Phone_Me__pc = j.marketing_permissions.telephone;
                }
                
        return a;
                
        
    }

    /*
     *   Factory method that returns a collection of Handset sObjects to be deregistered
     *   Required params: JsonWrapper object and notification type
     */      
    
    static List<Handset__c> deregisterHandsets(JsonWrapper j)
    {

            List<Handset__c> h = new List<Handset__c> (mapVregID2Handset.get(j.id));
            List<Handset__c> handsetsDeRegistered = new List<Handset__c> ();
            for (Handset__c eachHandset : h)
            {
                eachHandset.Registered__c = false;
                eachHandset.Vertu_Inbound_Data_ID__c = j.sfdcRecordID;
                handsetsDeRegistered.add(eachHandset);
            }    

            return handsetsDeRegistered;  
              
    }
    
    /*
     *   Factory method that returns a collection of Handset sObjects 
     *   Required params: JsonWrapper object and notification type
     *   Valid values of notification type are: customer.register & customer.update
     */    
    static List<Handset__c> createHandsets (JsonWrapper j, string notificationType)
    {
            List<Handset__c> handsets = new List<Handset__c> ();     
            String vregID = j.id;
            Account parentAccount;
            
            // Check if any handsets
            if (j.phones <> null)
            {
                system.debug('MN*** phones = ' + j.phones);
                for (Phone p : j.phones)
                {
                    Handset__c aHandset = new Handset__c ();

                    if (notificationType == CUSTOMER_REGISTER) {
                        // Use External ID to establish parent-child relationship
                        // between Person Account -> Handset and Vertu Account -> Handset
            
                    	// Begin OQ: 22/01/2013
                    	// Changes for Retail Portal use case where new Vertu Acc added
                    	// to existing Person Acc
                   
                    	if (mapOfUsername2PersonAcc.containsKey(j.personal_details.username) == true) {
                        	System.debug('createHandset: Adding new vertu acc to existing account' + mapOfUsername2PersonAcc.get(j.personal_details.username));
                        	id parentAccountID = mapOfUsername2PersonAcc.get(j.personal_details.username);
                        	Account a = new Account(id = parentAccountID);
                        	aHandset.Account_Name__c = a.id;  
                    	}
                    	else {
                        	parentAccount = new Account();
			            	parentAccount.Vreg_ID__c = j.id;
                        	aHandset.Account_Name__r = parentAccount; // Parent Person Account
                    	}
                    

                    	// End: OQ 22/01/2013 
                                            
                        Vertu_Account__c parentVertuAccount = new Vertu_Account__c();
                        parentVertuAccount.VREG_ID_Vertu_Account__c = j.id;
                        aHandset.Vertu_Account__r = parentVertuAccount;                     
                    }
                    else if (notificationType == CUSTOMER_UPDATE) {
                        Vertu_Account__c v = mapOfVertuAccounts.get(vregID); 
                        if (v == null) {
                            System.debug('Handset update for unknown VREG ID ' + vregID);                        
                            continue;
                        }            
                        id parentAccountID = mapOfVregIds2PersonAcc.get(vregID);            
                        Account a = new Account(id = parentAccountID);                      
                        aHandset.Vertu_Account__c = v.id;                   
                        aHandset.Account_Name__c = a.id;                        
                    }

                    aHandset.Vreg_ID_Handset__c = j.id; // VREG ID

                    // Add recordID of originating Json record
                    aHandset.Vertu_Inbound_Data_ID__c = j.sfdcRecordID;
                        
                    aHandset.IMEI__c = p.imei; 
                    aHandset.VSN__c = p.serial_number;
                    aHandset.Composite_ID__c = j.id + '_' + p.serial_number;    
                    if (p.purchase_date <> null) {
                        try {
                            aHandset.Date_of_Purchase__c = Date.valueOf(p.purchase_date);
                        }
                        catch (System.Typeexception e) {
                            System.debug(e.getMessage() );
                            updateJsonStatus(j.sfdcRecordId, 'Error', 'Invalid handset Date of Purchase for VREGID: ' + j.id);

                        }
                    }
                    if (p.date_of_registration <> null) {
                        try {
                            aHandset.Date_of_Registration__c = DateTime.valueOf(p.date_of_registration); 
                        }
                        catch (System.Typeexception e) {
                            System.debug(e.getMessage ());
                            updateJsonStatus(j.sfdcRecordId, 'Error', 'Invalid handset date of purchase for VREGID: ' + j.id);
                        
                        }
                    }
                    aHandset.custom_product_code__c = p.type_code;
                    aHandset.Phone_Collection__c = p.type_name;
                    aHandset.Model_Variant__c = p.type_description;
                    aHandset.type_designator__c = p.type_designator;
                    aHandset.registered__c = true;
                    aHandset.Place_of_Purchase__c = null;
                    
                    //Following line added by Mahfuz Choudhury as part of new field Mapping
                    aHandset.First_Time_Registration__c = p.first_time_registration;
           
                    // Lookup for Retail Store Account
					//	DC 20-11-2013 p.place_of_purchase has been replaced by purchase_place
                    if (storeCode2AccountMap.containsKey(p.purchase_place)) {
                        aHandset.Place_of_Purchase__c = storeCode2AccountMap.get(p.purchase_place).id;        
                    }
 
                    handsets.add(aHandset); 

                } // End Handset for loop
            }  
                
            return handsets;    
    }

   /*
     *   Factory method that returns a collection of Entitlement sObjects to be deleted
     *   Required params: JsonWrapper object and notification type
     *   Valid values of notification type are: customer.register & customer.update
     */    
    static List<Entitlement__c> getEntitlementsToDelete(JsonWrapper j)
    {
        string vregID = j.id;
        List<Entitlement__c> l = [select id from entitlement__c where VREG_ID_Service__c=: vregID];
        return l;
    }
       
    /*
     *   Factory method that returns a collection of Entitlement sObjects 
     *   Required params: JsonWrapper object and notification type
     *   Valid values of notification type are: customer.register & customer.update
     */    
    static List<Entitlement__c> createEntitlements(JsonWrapper j)
    {
            List<Entitlement__c> entitlements = new List<Entitlement__c>();
            String vregID = j.id;
            if (j.services <> null){
                    List <Entitlement> entList = new List<Entitlement> ();
                    // loop over Services
                    for (Service s : j.services) {
                        

                        if (s.entitlements <> null) {
                            entList = s.entitlements;
                            // loop over Entitlements
                            for (Entitlement e : entList) {

                                Entitlement__c anEntitlement = new Entitlement__c ();

                                anEntitlement.entitlement_name__c = s.name;
                                anEntitlement.VREG_ID_Service__c = j.id;
                                // Add recordID of originating Json record
                                anEntitlement.Vertu_Inbound_Data_ID__c = j.sfdcRecordID;                                
                                //if (notificationType == CUSTOMER_REGISTER) {
                                // Use VREG as External ID to establish parent-child relationship
                                Account parentAccount = new Account();
                                parentAccount.Vreg_ID__c = j.id;
                                anEntitlement.Account__r = parentAccount;
                                Vertu_Account__c parentVertuAccount = new Vertu_Account__c();
                                parentVertuAccount.VREG_ID_Vertu_Account__c = j.id;
                                anEntitlement.Vertu_Account__r = parentVertuAccount;
                                
                                anEntitlement.duration__c = e.duration;
                                try {
                                    anEntitlement.Start_Date__c = date.valueOf(e.start_date);
                                    anEntitlement.End_Date__c = date.valueOf(e.end_date);
                                }
                                catch (System.Typeexception ex) {
                                    System.debug('Invalid entitlement date format for VREG-ID: ' + j.id);
                                    System.debug(ex.getMessage());                                
                                    updateJsonStatus(j.sfdcRecordId, 'Error', 'Invalid entitlement date format for VREG-ID: ' + j.id);
                                }
                                anEntitlement.level__c = e.level;
                                entitlements.add(anEntitlement);    
                                                    
                            }
                        }
                    } // End Entitlements for
            } // end Entitlements       
            
            return entitlements;
    
    }
    
    /**
     * Main method to process notifications
     *
     */
    public static void processNotifications (List<Vertu_Inbound_Data__c> jsonList) {
        
        // Initialise custom settings
        // We store them in maps to limit SOQL queries
        
        countryLanguageCodes = Country_Language_Codes__c.getAll();
        isoCountryCodes = ISO_Country_Codes__c.getAll();        
        nationalities = Nationalities__c.getAll();
       
        retailStoreRecordTypeID = [Select Id From RecordType where SobjectType ='Account' and Name='Retail Store Account'].id;
        personAccountRecordTypeID = [Select Id,SobjectType,Name From RecordType where SobjectType ='Account' and Name='Customer Account'].id;
        
        storeCode2AccountMap = getStoreCode2AccountMap();
        
        
        // Local variable for json content      
        string jsonInput;   
        
        // Populate list of jsonWrapper objects so we don't have to deserialise JSON twice
        List<jsonWrapper> listJsonWrapper = new List<jsonWrapper>(); 
        
        // First pass on List of JSON objects to deserialize and also get VREG IDs 
        for(Vertu_Inbound_Data__c singleJsonObj: jsonList)
        {   
            jsonWrapper j; 
            jsonInput = singleJsonObj.Inbound_Message__c;
               
            jsonInput = jsonInput.replace('\"default\":', '\"isDefault\":'); 
            jsonInput = jsonInput.replace('\"number\":', '\"phone_number\":'); 
                                    
            try {
                // Parse JSON
                j = (jsonWrapper)JSON.deserialize(jsonInput, JsonWrapper.class);
                j.sfdcRecordId = singleJsonObj.id;
                if (j.notification_type == null || j.id == null) {
                    System.debug('Both notification type and ID are required fields');
                    updateJSONStatus(singleJsonObj.id, 'Error', 'Both notification type and ID are required fields');
                }   
                else {                    
                    // Add VREG-ID to list
                    listVregIDs.add(j.id); 
                    // Add deserialized jsonWrapper objects into list 
                    listJsonWrapper.add(j); 
                }   
            }
            catch (JSONException e)
            {
                System.debug(e.getMessage());
                updateJsonStatus(singleJsonObj.id, 'Error', 'JSON Parsing error:' + e.getMessage());
            }
            
        }
        // End initial pass for loop

        // Initialise lookup maps
        mapOfVertuAccounts = getMapOfVertuAccounts();
        mapOfVregIds2PersonAcc = getMapOfVregIds2PersonAcc();       
        mapVregID2Handset = getMapOfVregID2Handsets();  
        mapOfUsername2PersonAcc = getMapOfUsername2PersonAcc();
        
        // Customer Register lists
        List<Account> accReg = new List<Account>();
        List<Vertu_Account__c> vaccReg = new List<Vertu_Account__c>();
        List<Handset__c> handsetsReg = new List<Handset__c>();
        List<Entitlement__c> entReg = new List<Entitlement__c>();
        
        boolean isRegister = false;

        // Customer Update lists
        List<Account> accUpdate = new List<Account>();
        List<Vertu_Account__c> vaccUpdate = new List<Vertu_Account__c>();
        List<Handset__c> handsetsUpdate = new List<Handset__c>();
        List<Handset__c> handsetsDeRegistered = new List<Handset__c> ();
        List<Entitlement__c> entUpdate = new List<Entitlement__c> ();
        List<Entitlement__c> entDelete = new List<Entitlement__c> ();
        boolean isUpdate = false;
        
        // Customer Delete lists    
        List<Vertu_Account__c> vaccDelete = new List<Vertu_Account__c>();
        List<Handset__c> handsetsDelete = new List<Handset__c>();
        boolean isDelete = false;
        
        
        Country_Language_Codes__c countryLanguageCodeObj;
        ISO_Country_Codes__c isoCountryCodeObj;
        
        // **** Second pass over JSON objects to parse out fields ******
        for(jsonWrapper j: listJsonWrapper)
        {

            // ****** Begin CUSTOMER REGISTER code *****
            
            if (j.notification_type == CUSTOMER_REGISTER)
            {
                
                // **** NEW PERSON ACCOUNT OBJECT RECORD ***
                isRegister = true;
                
                // OQ: 22/01/2013

                Account a = new Account();
                a = createPersonAccount(j, j.notification_type);
                System.debug('processNotifications: checking username ' + j.personal_details.username + ', result: ' + mapOfUsername2PersonAcc.containsKey(j.personal_details.username));
                if (mapOfUsername2PersonAcc.containsKey(j.personal_details.username) == false)
                {
                    accReg.add(a);
                }
                else
                {
                	System.debug('processNotifications: Adding new vertu acc to existing account');
					//accUpdate.add(a);
					//isUpdate = true;
                }
                
                // **** NEW VERTU ACCOUNT OBJECT RECORD ***
                Vertu_Account__c v = new Vertu_Account__c();
                v = createVertuAccount(j, j.notification_type);         
                vaccReg.add(v);
        
                // **** NEW HANDSET RECORD(S) ***        
                handsetsReg = createHandsets(j, j.notification_type);   

                // **** NEW ENTITLEMENT RECORD(S) *** 
                entReg = createEntitlements(j);
                
                // ****** End CUSTOMER REGISTER code *****
     
            }
            else if (j.notification_type == CUSTOMER_UPDATE) {
                    
                    // ***** Begin CUSTOMER UPDATE *****
    
                    isUpdate = true;
                    // *** UPDATE PERSON ACCOUNT ***
                    Account a = createPersonAccount(j, j.notification_type);
                    if (a <> null) {
                        accUpdate.add(a);
                    }
                    // *** UPDATE VERTU ACCOUNT ***
                    Vertu_Account__c v = createVertuAccount(j, j.notification_type);
                    if (v <> null) {
                        vaccUpdate.add(v); // add to collection
                    }
                        
                    // **** Handset Update ****
                    
                    handsetsUpdate = createHandsets(j, j.notification_type);
                    handsetsDeRegistered = deregisterHandsets(j);
        
                    // **** UPDATE ENTITLEMENT RECORD(S) *** 
                    entUpdate = createEntitlements(j);
                    entDelete = getEntitlementsToDelete(j);
                                                                               
                
            } // ***** End customer update *****

            else if (j.notification_type == CUSTOMER_DELETE) {
                
                // ***** Begin customer delete

                isDelete = true;
                
                String vregID = j.id; // Vertu account to update
                
                // Instantiate Vertu_Account sObject associated with this VREG-ID
                Vertu_Account__c v = mapOfVertuAccounts.get(vregID); 
               
                 // check match on VREG-ID
                if (v <> null) {
                    
                    v.Active__c = false;
                    // Add recordID of originating Json record
                    v.Vertu_Inbound_Data_ID__c = j.sfdcRecordID;
                    vaccDelete.add(v);
                    
                    // **** Handset DeRegister ****
                    
                    List<Handset__c> h = new List<Handset__c> (mapVregID2Handset.get(vregID));
                    
                    for (Handset__c eachHandset : h)
                    {
                        eachHandset.Registered__c = false;
                        // Add recordID of originating Json record
                        eachHandset.Vertu_Inbound_Data_ID__c = j.sfdcRecordID;
                        handsetsDelete.add(eachHandset);
                    }
                }
                else // Customer.delete for unknown VREG ID 
                {
                    System.debug('Customer Delete for unknown VREG-ID:' + j.id);
                    updateJsonStatus(j.sfdcRecordId, 'Error', 'Unknown VREG-ID: ' + j.id + ', ' + j.notification_type + ' failed');
                }
                            
            } // ***** End customer delete
            else {
                System.debug('Unrecognised notification_type: ' + j.notification_type);
                updateJsonStatus(j.sfdcRecordId, 'Error', 'Unknown notification type: ' + j.notification_type);
            }           
            
      
        } // End for loop

        // Clear out error map obj before DML
        jsonStatusUpdMap = new Map<id, Vertu_Inbound_Data__c>();
                
        //  BULK DML PROCESSING
        if (isRegister)
        {
            try
            {
                boolean hasAccError = false;
                boolean hasVaccError = false;
                boolean hasHandsetError = false;                

                Savepoint sp = Database.setSavepoint();
                                               
                Database.SaveResult[] accSaveResult = Database.Insert(accReg, false);
                hasAccError = processDBSaveResult(accSaveResult, accReg, CUSTOMER_REGISTER);

                Database.SaveResult[] vaccSaveResult = Database.Insert(vaccReg, false);
                hasVaccError = processDBSaveResult(vaccSaveResult, vaccReg, CUSTOMER_REGISTER);                            

                if (handsetsReg.size() > 0) {
                    Database.SaveResult[] handsetSaveResult = Database.Insert(handsetsReg, false);
                    hasHandsetError = processDBSaveResult(handsetSaveResult, handsetsReg, CUSTOMER_REGISTER) ;  
                }

                if (entReg.size() > 0) {
                    Database.SaveResult[] entSaveResult = Database.Insert(entReg, false);
                    hasHandsetError = processDBSaveResult(entSaveResult, entReg, CUSTOMER_REGISTER); 
                }
                
                if (hasAccError || hasVaccError || hasHandsetError) {
                    // There are errors 
                    Database.rollback(sp);
                    System.debug ('DML Error - Rolling back insert transaction');
                }  
            } 
            
            catch (DMLException e)
            {
                System.debug('Error: ' + e.getMessage());
            }
        } // end insert
        
        if (isUpdate)
        { 
            boolean hasAccError = false;
            boolean hasVaccError = false;
            boolean hasHandsetError = false;   
            boolean hasHandsetUpsertError = false;
            boolean hasEntUpsertError = false;         
            
            try
            {
                Savepoint sp = Database.setSavepoint();
                
                if (accUpdate.size()>0) {
                    Database.SaveResult[] accSaveResult = Database.Update(accUpdate, false);
                    hasAccError = processDBSaveResult(accSaveResult, accUpdate, CUSTOMER_UPDATE);
                }
                
                if (vaccUpdate.size() > 0) {
                    Database.SaveResult[] vaccSaveResult = Database.Update(vaccUpdate, false);
                    hasVaccError = processDBSaveResult(vaccSaveResult, vaccUpdate, CUSTOMER_UPDATE);
                }
                
                if (handsetsDeRegistered.size() > 0) {
                    Database.SaveResult[] handsetSaveResult = Database.Update(handsetsDeRegistered, false);
                    hasHandsetError = processDBSaveResult(handsetSaveResult, handsetsDeRegistered, CUSTOMER_UPDATE); 
                }
                
                if (handsetsUpdate.size() > 0) {

                    upsert handsetsUpdate Composite_id__c;
                }

                if (entDelete.size () > 0) {
                    delete entDelete;
                }
                                
                if (entUpdate.size() > 0) {

                    insert entUpdate;
  
                }

                if (hasAccError || hasVaccError || hasHandsetError || hasHandsetUpsertError || hasEntUpsertError) {
                    Database.rollback(sp);
                    System.debug ('DML Error - Rolling back update transaction');
                }                
        
            }

            catch (DMLException e)
            {
                System.debug('DML Error ' + e.getMessage());
            }  
            catch (System.ListException e)
            {
                System.debug(e.getMessage());
            } 
                  
        }  // end update

        if (isDelete)
        {
            try 
            {        
                boolean hasVaccError = false;
                boolean hasHandsetError = false;
                
                Savepoint sp = Database.setSavepoint();
                
                if (vaccDelete.size()> 0) {
                    Database.SaveResult[] vaccSaveResult = Database.Update(vaccDelete, false);

                    hasVaccError = processDBSaveResult(vaccSaveResult, vaccDelete, CUSTOMER_DELETE);
                }
                
                if (handsetsDelete.size() > 0) {
                    Database.SaveResult[] handsetSaveResult = Database.Update(handsetsDelete, false);   
                    hasHandsetError = processDBSaveResult(handsetSaveResult, handsetsDelete, CUSTOMER_DELETE);
                }

                if (hasVaccError || hasHandsetError) {
                    Database.rollback(sp);
                    System.debug ('DML Error - Rolling back delete transaction');
                }                         
            }           
            catch (DMLException e)
            {       
                System.debug(e.getMessage());
            }
            

        } // End Delete
        
        // Update Vertu Inbound Data with Error details, if any
        if (jsonStatusUpdMap.size() > 0)
        {
            try {
                System.debug(jsonStatusUpdMap);
                update jsonStatusUpdMap.values();
            }
            catch (DMLException e) {
                System.debug('DML Error - Could not update JSON status: ' + e.getMessage() );
            }
        }
    }

    /**
     *  Helper method to process Database.SaveResult array
     *  It also determines which record(s) have DML errors associated
     *  It updates the jsonStatusUpdMap Map with error details
     */   
    static boolean processDBSaveResult(Database.SaveResult [] sr, List<sObject> recordList, string notificationType)
    {
        boolean hasError = false;
        integer i = 0;
        string strError = '';
        
        if (sr != null){
            for (Database.SaveResult result : sr) {
                id jsonRecordID = String.valueOf( recordList[i].get('Vertu_Inbound_Data_ID__c'));
                if (!result.isSuccess()) {
                    
                    // For sObject name where error occurred
                    Schema.SObjectType token = recordList[i].getSObjectType();
                    Schema.DescribeSObjectResult dr = token.getDescribe();
                    
                    Database.Error[] errs = result.getErrors();
                    for(Database.Error err : errs) {

                        strError = 'OBJECT: ' +  dr.getName() + '\nERROR: ' + err.getStatusCode() + ' - ' + err.getMessage(); 
                        System.debug('Error on inbound record ID [' + String.valueOf( recordList[i].get('Vertu_Inbound_Data_ID__c')) + '] ' + strError);
                        hasError = true;

                        Vertu_Inbound_Data__c v = new Vertu_Inbound_Data__c (id = jsonRecordID);
                        if (jsonStatusUpdMap.containsKey(jsonRecordID)) {
                            if (jsonStatusUpdMap.get(jsonRecordID).detail__c <> null)
                                strError = jsonStatusUpdMap.get(jsonRecordID).detail__c + ',\n' + strError;                         
                            jsonStatusUpdMap.remove (jsonRecordID);
                        }                       
                        v.Status__c = 'Error';
                        v.Detail__c = strError;
                        jsonStatusUpdMap.put(jsonRecordID, v);                       
                    }
                }
                else
                {
                    Vertu_Inbound_Data__c v = new Vertu_Inbound_Data__c (id = jsonRecordID);
                    v.Status__c = 'Processed';
                    v.Detail__c = notificationType;
                    jsonStatusUpdMap.put(jsonRecordID, v); 
                }
                i++;
            }
        }
        return hasError;
    }  


    /**
     *  Helper method to update JSON record status field
     */
          
    static void updateJsonStatus(id jsonID, string status, string detail)
    {
        
        Vertu_Inbound_Data__c jsonStatusObj = new Vertu_Inbound_Data__c (id = jsonID, Status__c = status, Detail__c = detail);
        
        try {
            update jsonStatusObj;
        }
        catch (DMLException e) {
            System.debug('Error: Could not update JSON status for JSON ID:' + jsonID + ', Detail: ' + e.getMessage() );
        }
    }     
    
    // Return Map of Vertu Accounts - to be used for lookups during customer updates
    static Map<String, Vertu_Account__c> getMapOfVertuAccounts()
    {
        Map <String, Vertu_Account__c> mapOfVertuAcc = new Map <String, Vertu_Account__c> ();
        for (Vertu_Account__c v : [select id, VREG_ID_Vertu_Account__c  from Vertu_Account__c where VREG_ID_Vertu_Account__c in: listVregIDs ]) {
            mapOfVertuAcc.put(v.VREG_ID_Vertu_Account__c, v);
        }
        return  mapOfVertuAcc;  
    }
    
    // Return Map of VREG-IDs to Person Accounts. To be used for lookups during customer updates
    static Map<String, id> getMapOfVregIds2PersonAcc()
    {
        Map <string, id> mapVregID2PersonAcc = new Map<string, id>();   
        for (vertu_account__c v : [select VREG_ID_Vertu_Account__c, account_name__c from vertu_account__c where VREG_ID_Vertu_Account__c in: listVregIDs])
        {
            mapVregID2PersonAcc.put(v.VREG_ID_Vertu_Account__c, v.account_name__c);
        }
        return  mapVregID2PersonAcc;        
    }

    // Return Map of Vertu Usernames to Person Account IDs. To be used when adding new Vertu Account to existing Person Account
    static Map<String, id> getMapOfUsername2PersonAcc()
    {
        Map <string, id> mapUsername2PersonAcc = new Map<string, id>();   
        for (vertu_outbound_reg__c v : [select vertu_username__c, account__c from vertu_outbound_reg__c where Reg_Type__c = 'AddNewVertuAcc' and success__c = true limit 9999])
        {
            mapUsername2PersonAcc.put(v.vertu_username__c, v.account__c);
        }
        return  mapUsername2PersonAcc;        
    }

    
    // Return Map of VREG-IDs to Handsets. To be used for lookups during customer delete
    static Map<string, Handset__c[]> getMapOfVregID2Handsets()
    {
        
        Map <string, Handset__c[]> m = new Map<string, Handset__c []> (); 
        for (Vertu_Account__c v : [SELECT VREG_ID_Vertu_Account__c, ( SELECT id FROM handsets__r ) FROM Vertu_Account__c  where VREG_ID_Vertu_Account__c in: listVregIDs])
        {
            m.put(v.VREG_ID_Vertu_Account__c, v.handsets__r);
        }
        return m;               
    }   
    
    // Return Map with store ID as keys and store names as values
    static Map<String, Account> getStoreCode2AccountMap()
    {
        Map<string, account> retailStores = new Map<string, account>([Select ID, Store_Code__c from account where recordtypeid =: retailStoreRecordTypeID and Store_Code__c <> Null]);
        Map<String, account> m = new Map<String, account>();
        
        for (Account acc: retailStores.values()) {
            m.put(acc.Store_Code__c,acc);
        }        

        return m;

    }

}