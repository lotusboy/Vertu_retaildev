/*
 * Helper class for unit tests
 *
 * J Llewellyn, 29-01-2013 
 * DC 14-11-2013
 */  
public class UnitTestHelper {

	public static Account createAccount(string salutation, string firstname, string lastname, string nationality, string country, string language)
	{
		/*
			Persist and return a new account record
		*/
		Account a  = getAccount(salutation, firstname, lastname, nationality, country, language);
		insert a;
		return a;
	}

	public static Account getAccount(string salutation, string firstname, string lastname, string nationality, string country, string language)
	{
		/*
			Create an in-memory account record, using default record type
		*/
		Account a = new Account();
        a.salutation = salutation;
        a.firstname = firstname;
		a.LastName = lastname;
        a.Nationality__pc = nationality;
        a.Country_of_Residence__pc = country;
		a.Vertu_Spoken_Language__c = language;
        a.SOA_Update_Customer_Integration__c = false;
		return a;
	}
	
	public static Account getAccount()
	{
		/*
			Create an in-memory account record, using default record type
		*/
		Account a = new Account();
        a.salutation = 'Mr';
        a.firstname = 'Jim';
		a.LastName = 'Smith';
        a.Nationality__pc = 'British';
        a.Country_of_Residence__pc = 'United Kingdom';
		a.Vertu_Spoken_Language__c = 'English';
		return a;
	}
    
    /*
     * Method to Create a Retail Account (Added By Mahfuz Choudhury)
	 */
	Public static Account GetRetailAccount(String Name, String StoreCode, String Type)
    {
     	/*
		 * Create an in memory record with the details provided and return it where additional fields can be added
		 * record can be inserted
		 */
        Account a = New Account();
        a.Name = Name;
        a.Store_Code__c = StoreCode;
        a.Type = 'Retail Store';
        a.RecordTypeId = recordTypeUtils.GetRecordTypeByObject('Account').get('Business_Account').id;
        
        Return a;
    }
	
	public static Vertu_Account__c createVertuAccount(String accountID, String vregID)
	{
		/*
			Persist and return a new Vertu_Account__c record
		*/
		Vertu_Account__c v = getVertuAccount(accountID, vregID);
		insert v;
		return v;
	}
	
	public static Vertu_Account__c getVertuAccount(String accountID, String vregID)
	{
		/*
			Create in-memory Vertu_Account__c record
		*/
		Vertu_Account__c v = new Vertu_Account__c();
		v.Vertu_Written_Language__c = 'English';
		v.Vertu_Spoken_Language__c = 'English';
		v.VREG_ID_Vertu_Account__c = vregID;
		v.Primary_email_address__c = 'uttest@uttest.com';
		v.Primary_Email_Address_ID__c = '111111';
		v.Phone_Me__c = false;
		v.Other_Phone__c = '0147311111';
		v.Other_Phone_ID__c = '222222';
		v.Nationality_Country__c = 'British';
		v.Mobile_Phone__c = '01473111111';
		v.Mobile_Phone_ID__c = '333333';
		v.Mail_Me__c = false;
		v.Last_Name__c = 'Smith';
		v.First_Name__c = 'Jim';
		v.Email_Me__c = false;
		v.Account_Name__c = accountID;
		v.Username__c = 'uttestusername';
        v.Active__c = true;
		return v;		
	}

	public static Entitlement__c createEntitlement(string level, date enddate, id accID, id VAid)
	{
		/*
			Persist and return a new account record
		*/
		Entitlement__c a  = getEntitlement( level,  enddate,  accID, VAid);
		insert a;
		return a;
	}

	public static Entitlement__c getEntitlement(string level, date enddate, id accID, id VAid)
	{
		/*
			Create an in-memory account record, using default record type
		*/
		Entitlement__c a = new Entitlement__c();
        a.Level__c = level;
        a.End_Date__c = enddate;
		a.Account__c = accID;
        a.Vertu_Account__c = VAid;
		return a;
	}
	
	public static Case createCase(id accId, id vertuAccId, string Qforce_SFDC_Id)
	{
		/*
			Persist and return a new account record
		*/
		Case c  = getCase(accId, vertuAccId, Qforce_SFDC_Id);
		insert c;
		return c;
	}

	public static Case getCase(id accId, id vertuAccId, string Qforce_SFDC_Id)
	{
		/*
			Create an in-memory account record, using default record type
		*/
		Case c = new Case();
        c.AccountId = accId;
        c.Vertu_Account__c = vertuAccId;
		c.Q_Force_SFID__c = Qforce_SFDC_Id;
		return c;
	}
	
	public static Group getGroup(string name)
	{
		/*
			Create an in-memory Group record
		*/
		Group g = new Group();
		g.Name = name;
		g.DeveloperName = name;
		return g;
	}
	
	public static Group createGroup(string name)
	{
		/*
			Create an in-memory Group record
		*/
		Group g = getGroup(name);
		insert g;
		return g;
	}
   
   public static GroupMember createGroupMember(id groupId, id userOrGroupId)
   {
      GroupMember gm = new GroupMember(groupId = groupId, UserOrGroupId = userOrGroupId);
      insert gm;
      return gm;
   } 

   public static User GetUser(String theEmail, String userName, String alias)
   {
      Profile p = [select id from profile limit 1];
      User u = new User(alias = alias.length() > 8 ? alias.substring(0,8) : alias, 
                        email=theEmail, emailencodingkey='UTF-8', lastname='Last Name', 
                        languagelocalekey='en_US', localesidkey='en_GB', profileid = p.Id,
                        timezonesidkey='Europe/London', username=username,
                        firstname=username);
      insert u;
      return u;
   } 
   
   public static Handset__c getHandset(Id accountId, string phoneCollection, string phoneCollectionCode, string phoneVSN, boolean registered)
	{
		/*
			Create an in-memory handset record
		*/
		Handset__c h = new Handset__c();
		h.Account_Name__c = accountId;
		h.Phone_Collection__c = phoneCollection;
        h.Type_Designator__c = phoneCollectionCode;
        h.VSN__c = phoneVSN;
		h.Registered__c = registered;
		return h;
	}
	
	public static Handset__c createHandSet(Id accountId, string phoneCollection, string phoneCollectionCode, string phoneVSN, boolean registered)
	{
		/*
			Create an in-memory handset record
		*/
		Handset__c h = getHandset(accountId, phoneCollection, phoneCollectionCode, phoneVSN, registered);
		insert h;
		return h;
	}
    
    public static Handset_registration__c createHandsetRegistration(String IMEI, id CustomerId, DateTime DateofPurchase, String VSN, String UserName, String password, String PrivateQS, String SecurityAnswer, Id RetailAcc)
    {
        Handset_registration__c handsetReg = getHandsetRegistration(IMEI, CustomerId, DateofPurchase, VSN, UserName, password, PrivateQS, SecurityAnswer, RetailAcc);
        insert handsetReg;
        return handsetReg;
    }
    
    public static Handset_registration__c getHandsetRegistration(String IMEI, id CustomerId, DateTime DateofPurchase, String VSN, String UserName, String password, String PrivateQS, String SecurityAnswer, Id RetailAcc)
    {
        Handset_Registration__c handsetReg = new Handset_Registration__c();
        handsetReg.IMEI__c = IMEI;
        handsetReg.Customer__c = CustomerId;
        handsetReg.Date_of_Purchase__c = DateofPurchase;
        handsetReg.VSN__c = VSN;
        handsetReg.User_Name__c = UserName;
        handsetReg.Password1__c = Password;
        handsetReg.Private_Question_Pre_defined__c = PrivateQS;
        handsetReg.Security_Answer__c = SecurityAnswer;
        handsetReg.Retail_Account__c = RetailAcc;
        
        return handsetReg;
    }
    
    //Insert a custom setting here..
    Public static Encryption_key__c CreateEncryptionKeyCS()
    {
        Encryption_key__c EK = new Encryption_key__c();
        EK.Name = 'User_Password';
        EK.Key__c = 'mRMjHmlC1C+1L/Dkz8EJuw==';
        insert EK;
        Return EK;
    }
    
    //Insert a Hierarchical custom setting here for Integration
    Public static Operation_Switch__c CreateOpSwtichCS()
    {
        Operation_Switch__c OPSwitch = new Operation_Switch__c();
        OpSwitch.Enable_SOA_Integration__c = true;
        insert OpSwitch;
        Return OpSwitch;
    }
}