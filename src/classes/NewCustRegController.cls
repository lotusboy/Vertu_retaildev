/*
 * This class is the controller behind the Handset Registration
 * wizard. 
 */  

public class NewCustRegController {


    // These four class variables maintain the state of the wizard.  
    // When users enter data into the wizard, their input is stored    
    // in these variables.
   
    public Contact contact {get; set; }
    public Handset__c handset {get; set;}
    public Account account {get; set;}
    public VregResponse response {get; set;}    
    public WizardStep wizard {get; set;}

    
    public String IMEI {get; set; }
    public String VSN {get; set; }
    public String RetailStoreCountry  {get; set; }
    public String RetailStoreCity  {get; set; }
    public String RetailStoreName  {get; set; }
    public String VREGID  {get; set; }    // Vertu Account ID to which handset will be added
    public String AccountID  {get; set; } // Account ID to which handset will be added
    
    public boolean MarketingOptIn {get; set;}
    public String RetailStoreCode {get;set;}
    public String PurchaseDate {get; set; }
    public String ConciergeOptIn {get; set; }
    public String VertuUsername {get; set; }
    public String VertuPassword {get; set; }
    public String VertuPasswordConfirm {get; set; }
    public String UsernameAvailResult {get; set; }
    public String VregResponseBody {get; set; }
    public String VregResponseTitle {get; set; }
    public boolean TermsAndConditions {get; set; }
    public boolean checkedUsername {get; set; } 
    public String SecretQuestion;
    public String SecretAnswer {get; set; }
    public String CustomSecretQuestion {get; set; }
    public boolean isCustomSecretQuestion {get; set; }

    // Public getter and setters for field level errors
    public String errorVSN { get; set; }
    public String errorIMEI { get; set; }
    public String errorUsername { get; set; } 
    public String errorVertuPassword { get; set; }
    public String errorVertuPasswordConfirm { get; set; }
    public String errorTermsAndConditions { get; set; }
    public String errorCountry { get; set; }
    public String errorCity { get; set; }
    public String errorBoutique { get; set; }
    public String errorSecretQuestion {get; set; }
    public String errorCustomSecretQuestion {get; set; }
    public String errorSecretAnswer {get; set; }
    
    static final string NEW_CUST_REG = 'NewCustReg';
    static final string ADD_HANDSET = 'AddHandsetToVertuAcc';
    static final string ADD_VERTU_ACC = 'AddNewVertuAcc';
    static final string NONE_OPTION = '--None--';
    static final string VREG_CREATE_ACCOUNT_CS = 'VREG Create Account';
	static final string VREG_UPDATE_ACCOUNT_CS = 'VREG Create Account';
	static final string VREG_IS_VALID_PHONE_CS = 'VREG Is Valid Phone';

    // Reset field error strings
    private void resetFieldErrors () {
        errorVSN = '';
        errorIMEI = '';
        errorUsername = ''; 
        errorVertuPassword = '';
        errorVertuPasswordConfirm = '';
        errorTermsAndConditions = '';
        errorCountry = '';
        errorCity = '';
        errorBoutique = '';
        errorSecretQuestion = '';
        errorSecretAnswer = '';
        errorCustomSecretQuestion = '';
    }

    public class WizardStep {
        public string type { get; set; } // The type of Wizard (different use cases)
        public string step { get; set; } // Step within the wizard
        public String PageTitle {get; set;} // Page Title 
        public String PageSubTitle {get; set; } // Subtitle, e.g. Step 1 of n
    }

    public class VregResponse {
        
        public string code { get; set; }
        public string result {get; set; }
        public boolean success {get; set; }
        public string ResultPageTitle {get; set; }  
  
    }       
    id retailStoreRecordTypeID;
    
    public NewCustRegController() {
        
        SetWizardType();
        retailStoreRecordTypeID = [Select Id From RecordType where SobjectType ='Account' and Name='Retail Store Account'].id;
        TermsAndConditions = false;
        checkedUsername = false;
        setUserRetailLocation();
        contact = new Contact();
        handset = new Handset__c();
        account = new Account();    
        this.handset = new Handset__c();
        this.handset.Date_Of_Purchase__c = Date.today();
        isCustomSecretQuestion = false;
        
    }

    public void setSecretQuestion(string question) {
        
        if (question == System.Label.Question_Write_Own ) {
            isCustomSecretQuestion = true;
        } else
        {
            isCustomSecretQuestion = false;
        }       
        this.SecretQuestion = question;
        
    }
    
    public string getSecretQuestion()
    {
        return this.SecretQuestion;
    }

    // Fetch parameters from URL to determine wizard type, read IDs
    private void SetWizardType() {

        String type = ApexPages.currentPage().getParameters().get('type');
        wizard = new WizardStep();
        if (type == 'regnewcust') { // Reg new customer & handset
            
            wizard.type = NEW_CUST_REG;
            wizard.step = '1'; 
            wizard.PageTitle = 'New Customer Registration';
            wizard.PageSubTitle = 'Step 1 of 5';
            
        } 
        else if (type == 'addhset') { // Register new handset to existing Vertu Account
             
            VREGID = ApexPages.currentPage().getParameters().get('vregid');
            AccountID = ApexPages.currentPage().getParameters().get('aid'); 
            wizard.type = ADD_HANDSET;
            wizard.step = '1'; 
            wizard.PageTitle = 'Add Handset To Vertu Account #' + VREGID;
            wizard.PageSubTitle = 'Step 1 of 3';            
        }
        else if (type == 'regvacct') { // Register new Vertu Account
            wizard.type = ADD_VERTU_ACC;
            AccountID = ApexPages.currentPage().getParameters().get('aid');
            wizard.step = '1'; 
            wizard.PageTitle = 'New Vertu Account Registration';
            wizard.PageSubTitle = 'Step 1 of 5';
        }
        
    }
  
    /*
     * Returns the next page in the wizard, specific to the use case
     * The click path is driven off the custom button where the wizard is invoked from
     * JL : Amended to setup the controller variables and just return null,
     *      that will refresh the page and conditionally render the next page
     *      in the wizard
     */     
    public PageReference next() {
        
        resetFieldErrors();
        
        if (wizard.type == NEW_CUST_REG) {
            
            if (wizard.step == '1') {   
                boolean result = isHandsetValid();  
        
                if (result == true) {
                    wizard.step = '2';
                    wizard.type = NEW_CUST_REG;
                    wizard.PageSubTitle = 'Step 2 of 5';
                }
            }
            else if (wizard.step == '2') {
                boolean result = isPicklistSelectionValid();
                if ( result == true )
                {                
                    wizard.step = '3';
                    wizard.type = NEW_CUST_REG;
                    wizard.PageSubTitle = 'Step 3 of 5';        
                }             
            }
            else if (wizard.step == '3') {
                boolean result = validateEmailAddress();
                if (result == true) {
                    wizard.step = '4';
                    wizard.type = NEW_CUST_REG;
                    wizard.PageSubTitle = 'Step 4 of 5';            
                }
            }
            else if (wizard.step == '4') {
                boolean result = validateUsernameAndPassword();
                
                if (result == true) {
                    wizard.step = '5';
                    wizard.type = NEW_CUST_REG;
                    wizard.PageSubTitle = 'Step 5 of 5';            
                }
            }
            else if (wizard.step == '5') {
                save();
            }
            
            
        }
        // Add handset to existing Vertu Account
        else if (Wizard.type == ADD_HANDSET) 
        {
            if (wizard.step == '1') {   
                boolean result = isHandsetValid();  
        
                if (result == true) {
                    wizard.step = '2';
                    wizard.type = ADD_HANDSET;
                    wizard.PageSubTitle = 'Step 2 of 3';
                }
            }
            else if (wizard.step == '2') {
                boolean result = isPicklistSelectionValid();
                if ( result == true )
                {                
                  wizard.step ='3';  
                  wizard.type = ADD_HANDSET;
                  wizard.PageSubTitle = 'Step 3 of 3';
                }             
            } 
            else if (wizard.step == '3') {
                save();             
            }   
            
        }
        
        // Add new Vertu account to existing Person Account
        else if (wizard.type == ADD_VERTU_ACC) 
        {
            if (wizard.step == '1') {   
                boolean result = isHandsetValid();  
        
                if (result == true) {
                    wizard.step = '2';
                    wizard.type = ADD_VERTU_ACC;
                    wizard.PageSubTitle = 'Step 2 of 5';
                }
            }
            else if (wizard.step == '2') {
                boolean result = isPicklistSelectionValid();
                if ( result == true )
                {                
                    wizard.step = '3';
                    wizard.type = ADD_VERTU_ACC;
                    wizard.PageSubTitle = 'Step 3 of 5';        
                }             
            }
            else if (wizard.step == '3') {
                boolean result = validateEmailAddress();
                if (result == true) {
                    wizard.step = '4';
                    wizard.type = ADD_VERTU_ACC;
                    wizard.PageSubTitle = 'Step 4 of 5';            
                }
                
            }
            else if (wizard.step == '4') {
                boolean result = validateUsernameAndPassword();
                
                if (result == true) {
                    wizard.step = '5';
                    wizard.type = ADD_VERTU_ACC;
                    wizard.PageSubTitle = 'Step 5 of 5';            
                }
            }
            else if (wizard.step == '5') {
                save();
            }           
        }
        
        return null;
    }

    // Method to manage navigation to previous screen
    
    public PageReference previous() {
        
        resetFieldErrors();
        if (wizard.type == NEW_CUST_REG) {
            
            if (wizard.step == '2') {   
                wizard.step = '1';
                wizard.type = NEW_CUST_REG;
                wizard.PageSubTitle = 'Step 1 of 5';
            }
            else if (wizard.step == '3') {
                boolean result = isHandsetValid();  
                
                if (result == true) {
                    wizard.step = '2';
                    wizard.type = NEW_CUST_REG;
                    wizard.PageSubTitle = 'Step 2 of 5';
                }
            }
            else if (wizard.step == '4') {
                
                wizard.step = '3';
                wizard.type = NEW_CUST_REG;
                wizard.PageSubTitle = 'Step 3 of 5';        
            }
            else if (wizard.step == '5') {
                boolean result = validateUsernameAndPassword();
                
                if (result == true) {
                    wizard.step = '4';
                    wizard.type = NEW_CUST_REG;
                    wizard.PageSubTitle = 'Step 4 of 5';            
                }
            }
            
        }
        // U.C. 2 - handset registration
        else if (Wizard.type == ADD_HANDSET) 
        { 
            if (wizard.step == '2') {   
                wizard.step = '1';
                wizard.type = ADD_HANDSET;
                wizard.PageSubTitle = 'Step 1 of 3';
                             
            } 
            if (wizard.step == '3') {   
                wizard.step = '2';
                wizard.type = ADD_HANDSET;
                wizard.PageSubTitle = 'Step 2 of 3';              
            }            
        }
        // U.C. 3 - add new Vertu account
        else if (Wizard.type == ADD_VERTU_ACC) 
        {

           if (wizard.step == '2') {   
                wizard.step = '1';
                wizard.type = ADD_VERTU_ACC;
                wizard.PageSubTitle = 'Step 1 of 5';
            }
            else if (wizard.step == '3') {
                boolean result = isHandsetValid();  
                
                if (result == true) {
                    wizard.step = '2';
                    wizard.type = ADD_VERTU_ACC;
                    wizard.PageSubTitle = 'Step 2 of 5';
                }
            }
            else if (wizard.step == '4') {
                
                wizard.step = '3';
                wizard.type = ADD_VERTU_ACC;
                wizard.PageSubTitle = 'Step 3 of 5';        
            }
            else if (wizard.step == '5') {
                boolean result = validateUsernameAndPassword();
                
                if (result == true) {
                    wizard.step = '4';
                    wizard.type = ADD_VERTU_ACC;
                    wizard.PageSubTitle = 'Step 4 of 5';            
                }
            }
            
        }
        return null;
    }

    // Helper method to build security question picklist
    public List<SelectOption> getSecretQuestionPicklist ()
    {
        List<SelectOption> lstSecurityPickList = new List<SelectOption>();
        lstSecurityPickList.add(new SelectOption(System.Label.Question_Favourite_City,System.Label.Question_Favourite_City));
        lstSecurityPickList.add(new SelectOption(System.Label.Question_Memorable_Date,System.Label.Question_Memorable_Date)); 
        lstSecurityPickList.add(new SelectOption(System.Label.Question_Write_Own,System.Label.Question_Write_Own));
        lstSecurityPickList.add(new SelectOption('', NONE_OPTION));
        lstSecurityPickList.sort();
        return lstSecurityPicklist;
    }

    // Helper method to build city & country picklists
    private List<SelectOption> buildCityCountryPicklist(String picklist) {

        List<Account> lstUnorderedValues = new List<Account>(); // To store SOQL result
        List<SelectOption> lstOrderedValues = new List<SelectOption>(); // To store sorted country/city list
        Map<String, SelectOption> mapValues = new Map<String, SelectOption>();  // Map to make country/city values unique
        
        if (picklist == 'Country') {        
            lstUnorderedValues = [Select BillingCountry From Account where billingcountry != null and recordtypeid =: retailStoreRecordTypeID  ] ;
 
            for (Integer i = 0; i< lstUnorderedValues.size(); i++) {            
                mapValues.put( lstUnorderedValues[i].BillingCountry, new SelectOption(lstUnorderedValues[i].BillingCountry, lstUnorderedValues[i].BillingCountry));
            }
        } 
        else if (picklist == 'City') {

            lstUnorderedValues = [Select BillingCity From Account where BillingCity != null and recordtypeid =:retailStoreRecordTypeID and BillingCountry =:RetailStoreCountry ] ;          
            for (Integer i = 0; i< lstUnorderedValues.size(); i++) {            
                mapValues.put( lstUnorderedValues[i].BillingCity, new SelectOption(lstUnorderedValues[i].BillingCity, lstUnorderedValues[i].BillingCity)); 
            }
        }
        else if (picklist == 'Store') {

            lstUnorderedValues = [Select Name, store_code__c From Account where BillingCity=:RetailStoreCity and BillingCountry =:RetailStoreCountry and RecordTypeID=:retailStoreRecordTypeID ] ;
            
            for (Integer i = 0; i< lstUnorderedValues.size(); i++) {
                /*
                    JL.  If store code is blank don't add it - this causes an error in the SelectOption constructor
                */
                if ( lstUnorderedValues[i].Store_Code__c != null && lstUnorderedValues[i].Store_Code__c != '' )
                {
                    mapValues.put( lstUnorderedValues[i].Name, new SelectOption(lstUnorderedValues[i].Store_Code__c, lstUnorderedValues[i].Name));
                } 
            }
        }       
        
        lstOrderedValues.addAll(mapValues.values());
        lstOrderedValues.add(new SelectOption('', NONE_OPTION));
        lstOrderedValues.sort();
        
        return lstOrderedValues;
                
    }

    /*
     *  Method to return distinct list of Retail Store countries
     */
    public List<SelectOption> getCountries()
    {
        return buildCityCountryPicklist ('Country');
    }

    
    /*
     *  Method to return distinct list of Retail Store Cities
     */
    public List<SelectOption> getCities()
    {
        return buildCityCountryPicklist ('City');
    }   

    /*
     *  Method to return distinct list of Retail Store Names
     */
    public List<SelectOption> getStores()
    {
        return buildCityCountryPicklist ('Store');
    }   
    
    /*
     *  Method to validate handset IMEI & Serial Number
     */
    private boolean isHandsetValid() {
        boolean isValid = true;
        resetFieldErrors();
        
        // Use regular expressions to validate input
        if (VSN == null || VSN == '' ) {
            errorVSN = System.Label.Serial_Number_Required;
            isValid = false;    
        }
        else {
            Pattern imeiPattern = Pattern.compile('[A-Za-z]{1,2}-[0-9]{6}$');
            Matcher imeiPM = imeiPattern.matcher( VSN );    
            
            if (imeiPM.matches() == false) {
                errorVSN = System.Label.Serial_Number_Format;
                isValid = false;
            }
        }       
        if (IMEI == null) {
            errorIMEI = System.Label.IMEI_Required;
            isValid = false;
        }
        else {
            Pattern imeiPattern = Pattern.compile('[0-9]{4}$');
            Matcher imeiPM = imeiPattern.matcher( IMEI );   
            
            if (imeiPM.matches() == false) {
                errorIMEI = System.Label.IMEI_Format;
                isValid = false;
            }
        }
  
		if (isValid)
		{  
	        response = isHandsetRegisteredNew();
	        if (response.result != '')
	        {
	            errorVSN = response.result;
	            isValid = false;
	        }
		}
        
        return isValid;
    }

    /*
     *  Method to check if handset with this VSN is already registered
     */ 
    private VREGResponse isHandsetRegisteredNew() {
        
        boolean isRegistered = false;

        // Check if handset already registered      
        Integration_Endpoints__c ie = Endpoint_Utils.getEndPoint(VREG_IS_VALID_PHONE_CS);
        
        string body = 'imei=' + EncodingUtil.urlEncode(IMEI, 'UTF-8') +
                  	  '&vsn=' + EncodingUtil.urlEncode(VSN, 'UTF-8');
        string r = callVregPostAPI(ie.Endpoint__c, ie.API_KEY__c, body); 
        response = parseVregValidateHandsetResponse (r);

        return response;
    }

    /*
     *  Method to check if entered username already exists
     */ 
    private boolean isUserNameValid () {

        integer count = getRowCount('select count() from Vertu_Account__c where username__c=\'' + VertuUserName + '\'');
        return (count == 0) ? true : false;
    }

    /*
     *  Method to check if entered email already exists
     */ 
    private boolean isEmailValid () {
                
        integer count = getRowCount('select count() from Account where PersonEmail=\'' + account.PersonEmail + '\'');
        return (count == 0) ? true : false; 
    }

    /*
     *  Method to check if Country > City > Boutique fields have been completed
     *  and set the relevant error text to the field
     */
     private boolean isPicklistSelectionValid () {
        boolean result = true;
        if ( ! String.isNotBlank(RetailStoreCountry) || RetailStoreCountry == NONE_OPTION )
        {
            errorCountry = 'You must select a country';
            result = false;
        }
        if ( ! String.isNotBlank(RetailStoreCity) || RetailStoreCity == NONE_OPTION  )
        {
            errorCity = 'You must select a city';
            result = false;
        }
        if ( ! String.isNotBlank(RetailStoreName) || RetailStoreName == NONE_OPTION  )
        {
            errorBoutique = 'You must select a boutique';
            result = false;
        }
        return result;
     }

    private integer getRowCount(string QueryString)
    {
        return Database.countQuery(QueryString);
    }

    /*
     *  Method to validate email address
     */     
    public boolean validateEmailAddress() {
        
        boolean isValid = true;
        if (isEmailValid() == false) {
            
            account.PersonEmail.addError(System.Label.Duplicate_Email_Exists);
            
            isValid = false;    
        }
        return isValid; 
    }

    /*
     *  Method to validate username and password 
     */     
    public boolean validateUsernameAndPassword() {
        
        boolean isValid = true; // Begin with an assumption that password valid, unless we find out otherwise
        resetFieldErrors();

         // Using if statements instead of else if to report all validation errors at once
        if ( String.isNotBlank( VertuUsername) == false )
        {
            errorUsername = System.Label.Blank_Username;
            isValid = false;
        }
        
        if (VertuUserName.length() < 4) 
        {
            errorUsername = System.Label.Username_Format;
            isValid = false;              
        }
        
        if (isUsernameValid() == false) {
            errorUsername = System.Label.Duplicate_Username_Exists;
            isValid = false;    
        }
        
        if (String.isNotBlank( VertuPassword) == false)
        {
            errorVertuPassword = System.Label.Blank_Password;
            isValid = false;    
        }
        if (VertuPassword.length() < 6) 
        {
            errorVertuPassword = System.Label.Password_Format;
            isValid = false;    
        }
       
        if (VertuPassword <> VertuPasswordConfirm) {
            errorVertuPassword = System.Label.Password_Mismatch;
            errorVertuPasswordConfirm = System.Label.Password_Mismatch;

            isValid = false;
        }
        
        if (!isCustomSecretQuestion && (SecretQuestion == NONE_OPTION || SecretQuestion == null)) {
            this.errorSecretQuestion = System.Label.Security_Question_Not_Selected;
            isValid = false;
        }
        
        if (isCustomSecretQuestion && CustomSecretQuestion.length() < 4 ) {
            this.errorCustomSecretQuestion = System.Label.Security_Question_Not_Selected;
            isValid = false;            
        }
        
        if (SecretAnswer.length() < 4) {
            this.errorSecretAnswer = System.Label.Security_Answer_Not_Entered;
            isValid = false;
        }
        // Convert username to lowercase
        VertuUserName = VertuUserName.toLowerCase();
        
        return isValid;         

    }

    // This method attempts to set the Retail Country, City & Store based on userinfo
    private void setUserRetailLocation() {
        
        // Initialise the choices
        this.RetailStoreCountry = '';
        this.RetailStoreCity = '';
        this.RetailStoreName = '';
        
        String UserName = UserInfo.getUserName();
        User thisUser = [select ContactId from user where username=:UserName];
        if (thisUser != null && thisUser.ContactId != null) {
            
            id ContactID = thisUser.ContactId;
            
            try {
                Contact c = [select AccountID from Contact where id =: ContactID ];
                Account a = [select Name, store_code__c, BillingCity, BillingCountry from Account where id =: c.AccountId];

                if (a != null) { 
                    this.RetailStoreCountry = a.BillingCountry;
                    this.RetailStoreCity = a.BillingCity;
                    this.RetailStoreName = a.store_code__c;
                }
                
            }
            catch (System.QueryException e) {
                System.debug(e.getMessage() );  
            }
        }
    }
    
    
    // Returns radio button options for concierge opt in
    public List<SelectOption> getConciergeOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        String optIn = System.Label.Concierge_OptIn;
        String optOut = System.Label.Concierge_OpOut;          
        options.add(new SelectOption(optIn,optIn)); 
        options.add(new SelectOption(optOut,optOut)); 
        return options; 
    }   

      
      
    /*
     * Creates new account, vertu account and handset by calling 
     * Vertu Registration Proxy
     */
        
    public PageReference save() {

        resetFieldErrors();
        string endPoint;
        string apiKey;
        id accid;
        
        if (isCustomSecretQuestion) {
            SecretQuestion = CustomSecretQuestion;
        }
         
        if (TermsAndConditions == false) {
            
            errorTermsAndConditions = System.Label.Terms_and_Conditions_Agreement;
        }
        else {
            // Reverse custom setting - country codes
            List <ISO_Country_Codes__c> iso_codes = ISO_Country_Codes__c.getAll().values();
            Map<String, String> reverse_iso_codes = new Map<String, String> ();
            
            for (ISO_Country_Codes__c i : iso_codes) {
                reverse_iso_codes.put(i.country__c, i.name);
            }           
            
            // Reverse custom setting - nationalities
            List <Nationalities__c> nationalities = Nationalities__c.getAll().values();
            Map<String, String> reverse_nationalities = new Map<String, String> ();
            
            for (Nationalities__c n : nationalities) {
                reverse_nationalities.put(n.nationality__C, n.name);
            }   
            
            // Reverse custom setting - language codes
            List <Country_language_codes__C> langugage_codes = Country_language_codes__C.getAll().values();
            Map<String, String> reverse_country_language_codes = new Map<String, String> ();
            
            for (Country_language_codes__C c : langugage_codes) {
                reverse_country_language_codes.put(c.Language__c, c.name);
            }  
            
            //Get Endpoints custom setting 
            String body;
            
            if (wizard.type == NEW_CUST_REG || wizard.type == ADD_VERTU_ACC) {
            
                String MarketingPref = MarketingOptIn ? 'true' : 'false';
                Integration_Endpoints__c ie = Endpoint_Utils.getEndPoint(VREG_CREATE_ACCOUNT_CS);
                endPoint = ie.Endpoint__c;
                apiKey = ie.API_Key__c;
                String nationality = reverse_nationalities.get(account.Nationality__pc);
                String country_code = reverse_iso_codes.get(account.Country_of_Residence__pc );
                String language = reverse_country_language_codes.get(account.Vertu_Spoken_Language__c);

                accid = AccountID;
                body = 'country_code='+EncodingUtil.urlEncode(country_code, 'UTF-8')+'&email='+EncodingUtil.urlEncode(account.PersonEmail, 'UTF-8') +
                  '&first_name=' + EncodingUtil.urlEncode(contact.firstname , 'UTF-8')+'&surname='+EncodingUtil.urlEncode(contact.lastname, 'UTF-8') +
                  '&imei=' + EncodingUtil.urlEncode(IMEI, 'UTF-8')+'&marketing='+EncodingUtil.urlEncode(MarketingPref, 'UTF-8') +
                  '&nationality=' + EncodingUtil.urlEncode(nationality, 'UTF-8')+'&number='+EncodingUtil.urlEncode(account.PersonMobilePhone, 'UTF-8') +
                  '&password=' + EncodingUtil.urlEncode(VertuPassword, 'UTF-8')+'&services='+EncodingUtil.urlEncode('true', 'UTF-8') +
                  '&spoken_language=' + EncodingUtil.urlEncode(language, 'UTF-8')+'&telephone='+EncodingUtil.urlEncode(account.PersonMobilePhone, 'UTF-8') +
                  '&title=' + EncodingUtil.urlEncode(contact.Salutation, 'UTF-8')+'&username='+EncodingUtil.urlEncode(VertuUserName, 'UTF-8') +
                  '&vsn=' + EncodingUtil.urlEncode(VSN, 'UTF-8')+'&written_language='+EncodingUtil.urlEncode(language, 'UTF-8') + 
                  '&purchase_place=' + EncodingUtil.urlEncode(RetailStoreName, 'UTF-8') +
                  '&purchase_date=' + EncodingUtil.urlEncode(String.valueOf(Date.ValueOf(handset.Date_of_Purchase__c)), 'UTF-8') +
                  '&secret_question=' + EncodingUtil.urlEncode(SecretQuestion, 'UTF-8') +
                  '&secret_answer=' + EncodingUtil.urlEncode(SecretAnswer, 'UTF-8');
                  
                 wizard.step='6';                 
            }
            else if (wizard.type == ADD_HANDSET) {
                
                Integration_Endpoints__c ie = Endpoint_Utils.getEndPoint(VREG_UPDATE_ACCOUNT_CS);
                endPoint = ie.Endpoint__c;
                apiKey = ie.API_Key__c;
                
                // Prepopulate member variables with existing Vertu Account details
                // These will get passed to the registration proxy, so that the current details
                // are maintained in the return message via the interface

                Vertu_account__c v = [Select v.Vertu_Written_Language__c, v.Vertu_Spoken_Language__c, v.VREG_ID_Vertu_Account__c, v.Primary_email_address__c, 
                                      v.Primary_Email_Address_ID__c, v.Phone_Me__c, v.Other_Phone__c, v.Other_Phone_ID__c, v.Nationality_Country__c, v.Mobile_Phone__c, 
                                      v.Mobile_Phone_ID__c, v.Mail_Me__c, v.Last_Name__c, v.First_Name__c, v.Email_Me__c, v.Account_Name__c 
                                      From Vertu_Account__c v where v.VREG_ID_Vertu_Account__c =: VREGID Limit 1];
                
                accid= v.account_name__c;
                
                Account a = [select id, firstname, lastname, salutation, Nationality__pc, Country_of_Residence__pc, Vertu_Spoken_Language__c
                            from Account where ID =:accid  limit 1];

                String nationality = reverse_nationalities.get(v.Nationality_Country__c);
                String written_language = reverse_country_language_codes.get(v.Vertu_Written_Language__c);
                String spoken_language = reverse_country_language_codes.get(v.Vertu_Spoken_Language__c);
                String MarketingPref = (v.Mail_me__c == true ?  'true' : 'false');
                
                nationality = (nationality == null) ? reverse_iso_codes.get(a.Country_Of_Residence__pc) : nationality;
                body =  'id='+EncodingUtil.urlEncode(VREGID, 'UTF-8')+
                        '&title='+EncodingUtil.urlEncode(a.salutation, 'UTF-8') +
                        '&first_name='+EncodingUtil.urlEncode(a.firstname, 'UTF-8')+
                        '&surname='+EncodingUtil.urlEncode(a.lastname, 'UTF-8') +
                        '&email='+EncodingUtil.urlEncode(v.Primary_email_address__c, 'UTF-8')+
                        '&email_id='+EncodingUtil.urlEncode(v.Primary_email_address_id__c, 'UTF-8') +
                        '&telephone='+EncodingUtil.urlEncode(v.Mobile_Phone__c, 'UTF-8')+
                        '&telephone_id='+EncodingUtil.urlEncode(v.Mobile_Phone_id__c, 'UTF-8') +
                        '&imei='+EncodingUtil.urlEncode(IMEI, 'UTF-8')+
                        '&marketing='+EncodingUtil.urlEncode(MarketingPref, 'UTF-8')+
                        '&vsn='+EncodingUtil.urlEncode(VSN, 'UTF-8') +
                        '&services='+EncodingUtil.urlEncode('true', 'UTF-8')+
                        '&spoken_language=' + EncodingUtil.urlEncode(spoken_language , 'UTF-8')+
                        '&written_language=' + EncodingUtil.urlEncode(written_language , 'UTF-8')+
                        '&nationality=' + EncodingUtil.urlEncode(nationality , 'UTF-8') +
                        '&purchase_place=' + EncodingUtil.urlEncode(RetailStoreName, 'UTF-8') +
                        '&purchase_date=' + EncodingUtil.urlEncode(String.valueOf(Date.ValueOf(handset.Date_of_Purchase__c)), 'UTF-8');
                        //'&purchase_date=' + EncodingUtil.urlEncode(String.valueOf(handset.Date_of_Purchase__c), 'UTF-8') +
                        //'&secret_question=' + EncodingUtil.urlEncode(SecretQuestion, 'UTF-8') +
                        //'&secret_answer=' + EncodingUtil.urlEncode(SecretAnswer, 'UTF-8');
                                        
                        
                wizard.step='4';
            }

            string r = callVregPostAPI(endPoint, apiKey, body); 
            
            response = parseVregSaveResponse (r);
            
            wizard.PageTitle = 'Result : ' + response.ResultPageTitle;
            wizard.PageSubTitle = '';           

            // Write to reg log
            Vertu_Outbound_Reg__c log = new Vertu_Outbound_Reg__c();
            try {
                System.debug(accid);
                log.Account__c = accid;
                log.VREG_ID__c = VREGID;
                log.IMEI__c = IMEI;
                log.VSN__c = VSN;
                log.Reg_Type__c = wizard.type;
                log.Vertu_Username__c = VertuUserName;
                log.result__c = VregResponseBody;
                log.success__c = response.success;
                insert log;
            }
            catch (DMLException e)
            {
                System.debug('DML Error ' + e.getMessage());
            }  

        }
        

       return null;
    }
    
    
    public PageReference cancel() {
        return home();
    }
    
    // Method to return pagereference to re-start wizard upon failed registration
    public PageReference retryRegistration() {
        this.TermsAndConditions = false;
        wizard.step = '1';
        wizard.PageSubTitle = '1 of 5';
        wizard.PageTitle = 'New Customer Registration';
        //return Page.newCustRegWizard;
        return null;
    }
    
    public PageReference navigateToHome() {
        return home();      
    }
    
    // Method to return pagereference to home tab
    private PageReference home () {
        PageReference home = new PageReference('/home/home.jsp' );
        home.setRedirect(true);
        return home;        
    }
    
    // Method to return pagereference to customer account detail page
    public PageReference navigateToAccountDetail() {
        
        PageReference accDetail;
        Vertu_account__c v = [select account_name__c from vertu_account__c where VREG_ID_Vertu_Account__c =: VREGID limit 1];
        id accid= v.account_name__c;
        Account a = [select id, name from Account where ID =:accid  limit 1];
        accDetail = new PageReference('/' + accID);
        return accDetail;
    } 

    private string callVregPostAPI(string endpoint, string apiKey, string body)
    {

            HttpRequest req = new HttpRequest();
            
            req.setEndpoint(endpoint); 
            req.setMethod('POST');       
            req.setHeader('X-Vertu-Api-Key', apiKey);
            req.setBody(body);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            return res.getBody();
        
    }
    
    private VregResponse parseVregSaveResponse(string response) {
        
        String code;
        String result;
        String success;
        
        VregResponseBody = response;
        
        VregResponse v = new VregResponse ();
        
        if (String.IsNotBlank(response) == true) {

            if (response.contains('success: true')) {
                v.success = true;
                
            } else
            {
                v.success = false;
                
            }
            v.ResultPageTitle = (v.success == true ? 'Registration Successful' : 'Registration Unsuccessful');                                      

            if (response.contains('code: ')) {
                
                if (v.success == true) 
                    code = response.substringbetween ('code: ', ' ');
                else
                    code = response.substringbetween ('code: ', ',');
                v.code = code; 
                
            }

            if ((response.contains('result:') == true) && (v.success == true)) {
                
                
                if (response.contains('{reference_id: ') == true) {
                    VREGID = response.substringbetween('{reference_id: ', ', ');
                    VREGID = VREGID.remove('\''); 
                }
                result = 'The customer account and/or handset registration was successful. The Vertu Account ID is ' + VREGID;
                v.result = result ;
                        
            } 
            else if ((response.contains('result:') == true) && (v.success == false)) {
                result = response.substringbetween ('result: ', ', ');
                v.result = 'The registration was unsuccessful. Reason: ' + result;

            }
        }
        return v;
    }

    private VregResponse parseVregValidateHandsetResponse(string response) {
        
        String code;
        String result;
        String success;
        
        VregResponseBody = response;
        
        VregResponse v = new VregResponse ();
        
        if (String.IsNotBlank(response) == true) 
        	
        {
	    	if (response.contains('code: 200')) 
	    		{
	    			if(response.contains('result: true'))
	            	
	            	{
	                	v.success = true;
	                	v.result = '';
	                
		            } 
		            else
		            {
		                v.success = false;
	                	v.result = system.label.VSN_EMEI_Invalid;
		                
		            }
            }
            else if(response.contains('result:'))
            {
                result = response.substringbetween ('result: ', ', ');
                v.result = system.label.VREG_Connection_error + ' Reason: ' + result;
            }
	        else
	        {
                v.success = false;
            	v.result = system.label.VREG_Connection_error + ' Unknown Reason';
		    }
        }
        else
        {
            v.success = false;
        	v.result = system.label.VREG_Connection_error + ' Unknown Reason';
        }
        return v;
    }

    public void TestData()
    {
        integer randomNum = Math.round( Math.random()*1000);
        Date d = Date.today();
        contact = new Contact();
        account = new Account();
        contact.Salutation = 'Mr';
        contact.FirstName = 'Omar';
        contact.LastName = 'Qureshi ';
        account.Vertu_Spoken_Language__c = 'English';
        account.Nationality__pc = 'British';
        account.Country_of_Residence__pc = 'United Kingdom';
        account.Gender__pc = 'Male';
        account.PersonEmail = 'oqureshi' + d.day() + '-' + d.month()+'@mycompany' + randomNum + '.co.uk';
        account.PersonMobilePhone = '+44777111222';
        account.PersonMailingStreet = 'The Causeway';
        account.PersonMailingCity = 'Staines';
        account.PersonMailingPostalCode = 'TW18 3AG';
        account.PersonMailingCountry = 'United Kingdom';
        VertuUsername = 'oqureshi' + randomNum;
    }

}