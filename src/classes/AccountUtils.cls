/*
Developer Name   : Mick Nicholson (BrightGen Ltd)
Deployment Date  : 21/03/2013
Description      : Account utility class
Update dc 14/11/13 - to add handset type designator
Update dc 22/11/13 - to add the VSN rollup to Customer

Modified by: Mahfuz Choudhury
Date: 18/06/14
Description: SOA_MaintainCustomerHelper method added to prepare the call out on trigger context
*/ 

public class AccountUtils {
    
    private static string ENTITLEMENTLEVELDEDICATED = 'Dedicated';
    private static string ENTITLEMENTLEVELCLASSIC = 'Classic';
    private static string ENTITLEMENTLEVELULTIMATE = 'Ultimate';
    private static string ENTITLEMENTLEVELNONE = 'None';


    public static void updateEntitlementLevel(List<Entitlement__c> ents)
    {
        //Create Map of Accounts related to  Entitlements which will be updated later
        Map <id,Account> accsToUpdate = new Map<id,Account>();
        List<Id> accIdsToUpdate = new List<Id>();
        for (Entitlement__c ent : ents)
        {
            if (ent.Account__c != null)
            {
                if (!accsToUpdate.containskey(ent.Account__c))
                {
                    Account accToUpdate = new Account(id=ent.Account__c);
                    accsToUpdate.put(ent.Account__c, accToUpdate);
                }
                
            }
        }
        
        //Get all Entitlements for Accounts
        Map<id,List<Entitlement__c>> accEnts = new Map<id,List<Entitlement__c>>();
        for (Entitlement__c ent : [Select Account__c, Level__c, End_Date__c, Expired__c, Account__r.Membership_Expiry_Date__pc, Account__r.Current_Membership_Level__pc from Entitlement__c where Account__c in :accsToUpdate.keyset() ])
        {
            if (!accEnts.containskey(ent.Account__c))
            {
                accEnts.put(ent.Account__c, new List<Entitlement__c>());
            }
            accEnts.get(ent.Account__c).add(ent);
        }
        
        //Loop round all accounts and their entitlements and recalculate the entitlement level and end date 
        string level;
        for (id accId : accEnts.keyset())
        {
            //Set default level to none (if all entitlements are expired)
            level = ENTITLEMENTLEVELNONE;
            for (Entitlement__c ent : accEnts.get(accId))
            {
                //If entitlement is active recalculate values
                if (ent.Expired__c == false)
                {
                    if (ent.Level__c == ENTITLEMENTLEVELDEDICATED)
                    {
                        level = ENTITLEMENTLEVELDEDICATED;
                    }
                    else if (level == ENTITLEMENTLEVELNONE)
                    {
                        level = ent.Level__c;
                    }
                    if (accsToUpdate.get(ent.Account__c).Membership_Expiry_Date__pc == null ||
                        ent.End_Date__c > accsToUpdate.get(ent.Account__c).Membership_Expiry_Date__pc)
                    {
                        accsToUpdate.get(accId).Membership_Expiry_Date__pc = ent.End_Date__c;
                    }
                }
            }
            accsToUpdate.get(accId).Current_Membership_Level__pc = level;
        }
        if (accsToUpdate.size() > 0)
        {
            Database.saveResult[] srs = Database.update(accsToUpdate.values(), false);
            for(Integer iterator=0; iterator<srs.size(); iterator++)
            {
                Database.saveResult sr = srs[iterator];
                if (!sr.isSuccess())
                {
                    system.debug('Error updating account entitlement level - ' + sr.getErrors()[0].message);
                }
            }
        }
    }

     //dc141113 new agregate Collections Code field added to this menthod
     //dc221113 agregate the VSN numbers in the same way as the Collections Code into VSN_Number__c
    public static void updateCollectionInfo(List<Handset__c> handsets)
    {
        //Get all the account ids from the handsets 
        List<id> handsetAccountIds = new List<id>();
        for (Handset__c handset : handsets)
        {
            handsetAccountIds.add(handset.Account_Name__c);
        }
        //Create a map of accounts to be updated
        Map<id,Account> accountsToUpdate = new map<id,Account>();
        for(Account acc : [Select id, Collections_Registered__c, Collections_Last_Registered__c, Collections_Codes_Registered__c, VSN_Number__c
                            From Account
                            where id in :handsetAccountIds])
        {
            //Reset the collections registered and registered list as they will always be regenerated 
            //from the registered handsets later
            acc.Collections_Registered__c = '';
            acc.Collections_Codes_Registered__c = '';
            acc.VSN_Number__c = '';
            accountsToUpdate.put(acc.id,acc);
        }
        
        string newListValue = '';
        string newListValueCode = '';
        string newListVSN = '';
        //Create a map of account IDs and all registered handsets
        //Handsets sorted by created date descending so that we know the first one in the list is the last registered
        Map<id, id> accHandsets = new map<id, id>();
        for (Handset__c handset : [Select id, Account_Name__c, Phone_Collection__c, CreatedDate, Type_Designator__c, VSN__c from Handset__c 
                                    where Account_Name__c in : accountsToUpdate.Keyset()
                                    and Registered__c = true
                                    order by CreatedDate DESC])
        {
            if(handset.Type_Designator__c != null)
                // dc 25-11-13 changed frmo Phone_Collection to Type Designator as Collection is no longer unique
            {
                if (!accHandsets.containskey(handset.Account_Name__c))
                {
                    accHandsets.put(handset.Account_Name__c,handset.Account_Name__c);
                    //Account not already in map so this must be first handset in list for this account
                    //which is last registered as sorted on creaeted date desc
                    //so set last registered value on account record.
                    accountsToUpdate.get(handset.Account_Name__c).Collections_Last_Registered__c = handset.Phone_Collection__c;
                    newListValue = handset.Phone_Collection__c;
                    //dc141113 add the collection code.
                    accountsToUpdate.get(handset.Account_Name__c).Collections_Codes_Registered__c = handset.Type_Designator__c;
                    newlistValueCode = handset.Type_Designator__c;
                    //dc221113 add the VSN Number.
                    accountsToUpdate.get(handset.Account_Name__c).VSN_Number__c = handset.VSN__c;
                    newlistVSN = handset.VSN__c;
                }
                else
                {
                    newListValue = ',' + handset.Phone_Collection__c;
                    //dc141113 add the collection code.
                    newlistValueCode = ',' + handset.Type_Designator__c;
                    //dc221113 add the VSN.
                    newlistVSN = ' ' + handset.VSN__c;
                    
                }
                //Add handset collection value to account multi select picklist and comma separated list if not already added
                if (!accountsToUpdate.get(handset.Account_Name__c).Collections_Registered__c.contains(handset.Phone_Collection__c))
                {
                    accountsToUpdate.get(handset.Account_Name__c).Collections_Registered__c += newListValue;
                }
                //dc141113 add the collection code.
                //Add handset collection Code value to account multi select picklist and comma separated list if not already added
                if (!accountsToUpdate.get(handset.Account_Name__c).Collections_Codes_Registered__c.contains(handset.Type_Designator__c))
                {
                    accountsToUpdate.get(handset.Account_Name__c).Collections_Codes_Registered__c += newListValueCode;
                }
                //dc221113 add the VSN number
                //Add handset collection Code value to account multi select picklist and comma separated list if not already added
                if (!accountsToUpdate.get(handset.Account_Name__c).VSN_Number__c.contains(handset.VSN__c))
                {
                    accountsToUpdate.get(handset.Account_Name__c).VSN_Number__c += newListVSN;
                }
            }
        }
        
        //Update account values
        update accountsToUpdate.values();
    }
    
    //SOA_UpdateCustomerHelper Added to maintain calling out to SOA for customer update
    //Added by Mahfuz Choudhury
    Public static void SOA_UpdateCustomerHelper(Map<id,Account> AccountMap, Integer TotalRecordToProcess){
        Set<id>AccIdsToSend = new Set<id>();
        Integer NumberOfAccountsToSend = 0;
        
        //Findout the number of future calls remaining and number of callout necessary
        Integer FutureCallsRemaining = system.limits.getLimitFutureCalls() - system.limits.getFutureCalls();
        
        System.debug('Total future Calls remaining is-------------------------------->>>>'+FutureCallsRemaining);
        System.debug('Total accounts to process is-------------------------------->>>>'+TotalRecordToProcess);
        
        //determines if it's a future call or a batch process
        if(TotalRecordToProcess <= FutureCallsRemaining * system.Limits.getLimitCallouts()){
        	for(Account a: AccountMap.values())
            {
             	NumberOfAccountsToSend++;
                AccIdsToSend.add(a.id);
                
                //Check if the limit for callout is reached
                if(NumberOfAccountsToSend == system.Limits.getLimitCallouts())
                {
                 	System.debug('Size of the current batch is------------------->>'+AccIdsToSend.size()); 
                    //Send this batch for processing from @future context
                    SOA_WSO_MaintainCustomer.UpdateCustomerRequest(AccIdsToSend);
                    
                    //Reset the parameters after sending each batch
                    NumberOfAccountsToSend = 0;
                    AccIdsToSend.clear();
                }
            }
            
            //send any remaining opportunity or anything has a batch of less than 10 for processing 
            if(AccIdsTosend.size() > 0)
            {
                SOA_WSO_MaintainCustomer.UpdateCustomerRequest(AccIdsToSend);
            }
        }
        else{
            //Send it to another method for scheduling a batch job for the records
            SOA_WSO_MaintainCustomer.UpdateCustomerRequestBatch(AccountMap.keySet());
        }
    }
    
    //Method to return Account List with Related Vertu Account...
    Public static List<Account> GetAccountWithVertuAccount(Set<id> Accid)
    {
     	//Declare a List for Account with Vertu Account and return it to calling method
        List<Account> AccountWithVertuAccount = Database.query(GetAccountWithVertuAccountQueryString('Accid'));
        return AccountWithVertuAccount;
    }
    
    /*
     * Utility method to retrieve Account with active Vertu Account using Query string
     * The argument is a set of Ids (Added By Mahfuz Choudhury)
	 */
    public static String GetAccountWithVertuAccountQueryString(String accSetVariableName)
    {
        String queryString = 'SELECT ID, Salutation, FirstName, LastName, Gender__pc,'+ 
                           'PersonBirthdate, Vertu_Spoken_Language__c, Vertu_Written_Language__pc,'+ 
                           'PersonEmail, Secondary_Email_Address__pc, Third_Email_Address__pc,'+ 
                           'Fourth_Email_Address__pc, Fifth_Email_Address__pc, PersonMobilePhone,'+
                           'PersonHomePhone, PersonOtherPhone, PersonMailingStreet, SOA_Update_Customer_Integration__c, '+
                           'PersonMailingcountry, PersonMailingPostalCode, PersonOtherStreet,'+
                           'PersonOthercountry, PersonOtherPostalCode, Mail_Me__pc, SMS_Me__pc,'+ 
                           'Phone_Me__pc, Email_Me__pc, Passion_Fine_Dining__pc,'+ 
                           'Passion_Champagne_Fine_Wine_And_Spirits__pc, Passion_VIP_Entertainment__pc,'+
                           'Passion_Fashion_And_Style__pc, Passion_Elite_World_Sport__pc,'+
                           'Passion_Business_Intelligence__pc, Passion_The_Arts__pc,'+ 
                           'Passion_Technology_and_Gadgets__pc,'+
                           'Passion_Travel__pc, (Select Account_Name__c, VREG_ID_Vertu_Account__c, Active__c,'+
                                                'Id, Private_Question__c, Security_Answer__c, Password__c,'+
                                                'Username__c from Vertu_Accounts__r where Active__c = True) '+
                           'from Account where ID IN :' + accSetVariableName;
    	return queryString;    
    }
    
    /*
     * Utility method to retrieve One Account based on supplied id (Added By Mahfuz Choudhury)
	 */
    public Static Account GetAccountById(Id AccId)
    {
        return [SELECT 	   ID, Salutation, FirstName, LastName, Gender__pc,
                           PersonBirthdate, Vertu_Spoken_Language__c, Vertu_Written_Language__pc,
                           PersonEmail, Secondary_Email_Address__pc, Third_Email_Address__pc, 
                           Fourth_Email_Address__pc, Fifth_Email_Address__pc, PersonMobilePhone,
                           PersonHomePhone, PersonOtherPhone, PersonMailingStreet, SOA_Update_Customer_Integration__c,
                           PersonMailingcountry, PersonMailingPostalCode, PersonOtherStreet,
                           PersonOthercountry, PersonOtherPostalCode, Mail_Me__pc, SMS_Me__pc,
                           Phone_Me__pc, Email_Me__pc, Passion_Fine_Dining__pc,
                           Passion_Champagne_Fine_Wine_And_Spirits__pc, Passion_VIP_Entertainment__pc,
                           Passion_Fashion_And_Style__pc, Passion_Elite_World_Sport__pc,
                           Passion_Business_Intelligence__pc, Passion_The_Arts__pc,
                           Passion_Technology_and_Gadgets__pc,
                           Passion_Travel__pc
         		FROM 	   Account 
                WHERE ID =: AccId];
    }
    
    /*
     * Utility method to retrieve retail account field by given id
     * 
	 */
    Public static Account GetRetailAccount(Id AccId)
    {
     Return [SELECT 	id, Name, Store_Code__c
             FROM 		Account 
             WHERE 		id =: Accid AND recordTypeId IN 
            	(SELECT 	id 
             	 FROM 		RecordType
             	 WHERE		SobjectType = 'Account' AND DeveloperName = 'Business_Account')];   
    }
    
    

                           /******************************/
                           /*                            */
                           /*   TEST METHODS             */
                           /*                            */
                           /******************************/

    static testMethod void testupdateEntitlementLevel() 
    {
        //Create 2 active entitlements - Dedicated and Classic levels
        Account acc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        //Added by Mahfuz Choudhury to prevent unit test failure as vertu account id is a mandatory field on entitlement
        Vertu_Account__c VA1 = UnitTestHelper.createVertuAccount(acc.id, 'Vreg0001');
        Entitlement__c ent1 = UnitTestHelper.createEntitlement(ENTITLEMENTLEVELDEDICATED, system.Today().addDays(5), acc.Id,VA1.id);
        Entitlement__c ent2 = UnitTestHelper.createEntitlement(ENTITLEMENTLEVELCLASSIC, system.Today().addDays(10), acc.Id,VA1.id);
        List<Entitlement__c> entList = new List<Entitlement__c>();
        entList.add(ent1);
        entList.add(ent2);
        //Update Account values - level should be Dedicated, Date should be latest date
        updateEntitlementLevel(entList);
        Account testAcc = [Select Membership_Expiry_Date__pc, Current_Membership_Level__pc From Account where id = :acc.Id];
        system.assertEquals(ENTITLEMENTLEVELDEDICATED, testAcc.Current_Membership_Level__pc);
        system.assertEquals(system.Today().addDays(10), testAcc.Membership_Expiry_Date__pc);
        
        //Reset list
        //Set dedicated entitlement to expired
        entList.clear();
        ent1.Expired__c = true;
        update ent1;
        entList.add(ent1);
        //Update Account values - level should be Classic, Date should be latest date
        updateEntitlementLevel(entList);
        testAcc = [Select Membership_Expiry_Date__pc, Current_Membership_Level__pc From Account where id = :acc.Id];
        system.assertEquals(ENTITLEMENTLEVELCLASSIC, testAcc.Current_Membership_Level__pc);
        system.assertEquals(system.Today().addDays(10), testAcc.Membership_Expiry_Date__pc);
        
        //Reset list
        //Change End date on classic entitlement
        entList.clear();
        ent2.End_Date__c = system.Today().addDays(1);
        update ent2;
        entList.add(ent2);
        //Update Account values - level should be Classic, Date should be new date
        updateEntitlementLevel(entList);
        testAcc = [Select Membership_Expiry_Date__pc, Current_Membership_Level__pc From Account where id = :acc.Id];
        system.assertEquals(ENTITLEMENTLEVELCLASSIC, testAcc.Current_Membership_Level__pc);
        system.assertEquals(system.Today().addDays(1), testAcc.Membership_Expiry_Date__pc);
        
        //Reset list
        //Set classic entitlement to expired
        entList.clear();
        ent2.Expired__c = true;
        update ent2;
        entList.add(ent2);
        //Update Account values - level should be None, Date should be new date
        updateEntitlementLevel(entList);
        testAcc = [Select Membership_Expiry_Date__pc, Current_Membership_Level__pc From Account where id = :acc.Id];
        system.assertEquals(ENTITLEMENTLEVELNONE, testAcc.Current_Membership_Level__pc);
        system.assertEquals(system.Today().addDays(1), testAcc.Membership_Expiry_Date__pc);
        
    }

    static testMethod void testupdateCollectionInfoViaTrigger() 
    {
        //n.b. Can only test this method via trigger as it reads all current registered handsets
        
        string expectedReg = '';
        string PhoneCollection1 = 'TestValue1';
        string PhoneCollection2 = 'TestValue2';
        string PhoneCollection3 = 'TestValue3';
        string PhoneCollectionCode1 = 'TestCode1';
        string PhoneCollectionCode2 = 'TestCode2';
        string PhoneCollectionCode3 = 'TestCode3';
        string PhoneVSN1 = 'TestVSN1';
        string PhoneVSN2 = 'TestVSN2';
        string PhoneVSN3 = 'TestVSN3';
        
        //Create an account and first handset
        Account acc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        Handset__c hs1 = UnitTestHelper.createHandset(acc.Id, PhoneCollection1, PhoneCollectionCode1, PhoneVSN1, true);
        
        //Check Account values updated from handset 1
        Account testAcc = [Select Collections_Registered__c, Collections_Last_Registered__c
                            From Account where id = :acc.Id][0];
        system.assertEquals(hs1.Phone_Collection__c, testAcc.Collections_Last_Registered__c);
        system.assertEquals(hs1.Phone_Collection__c, testAcc.Collections_Registered__c);
        
        //Get CreatedDate from handset1
        Handset__c testHs1 = [Select Id, CreatedDate from Handset__c where id = :hs1.id][0];
        //Wait until time has changed - this will force next insert to have different created datetime
        while(testHs1.CreatedDate.second() == system.now().second())
        {
            
        }

        //Add a second handset with different collection
        Handset__c hs2 = UnitTestHelper.createHandset(acc.Id, PhoneCollection2, PhoneCollectionCode2, PhoneVSN2, true);
        //Check Account values updated from handset 2
        testAcc = [Select Collections_Registered__c, Collections_Last_Registered__c
                    From Account where id = :acc.Id][0];
        expectedReg = hs2.Phone_Collection__c + ',' + hs1.Phone_Collection__c;
        //Last value should be this handset, lists should have both values
        system.assertEquals(hs2.Phone_Collection__c, testAcc.Collections_Last_Registered__c);
        system.assertEquals(expectedReg, testAcc.Collections_Registered__c);
        
        //Get CreatedDate from handset2
        Handset__c testHs2 = [Select Id, CreatedDate from Handset__c where id = :hs2.id][0];
        //Wait until time has changed - this will force next insert to have different created datetime
        while(testHs2.CreatedDate.second() == system.now().second())
        {
            
        }
        
        //Add a third handset with same collection value as first 
        Handset__c hs3 = UnitTestHelper.createHandset(acc.Id, PhoneCollection1, PhoneCollectionCode3, PhoneVSN3, true);
        //Check Account values updated from handset 3
        testAcc = [Select Collections_Registered__c, Collections_Last_Registered__c
                    From Account where id = :acc.Id][0];
        expectedReg = hs3.Phone_Collection__c + ',' + hs2.Phone_Collection__c;
        //Last value should be this handset, lists should have both values
        system.assertEquals(hs3.Phone_Collection__c, testAcc.Collections_Last_Registered__c);
        system.assertEquals(expectedReg, testAcc.Collections_Registered__c);
                
        //Update first handset with new collection
        hs1.Phone_Collection__c = PhoneCollection3;
        update hs1;
        //Check Account values updated from handset 
        testAcc = [Select Collections_Registered__c, Collections_Last_Registered__c
                    From Account where id = :acc.Id][0];
        expectedReg = hs3.Phone_Collection__c + ',' + hs2.Phone_Collection__c + ',' + hs1.Phone_Collection__c;
        //Last value should still be third  handset, lists should have 3 values
        system.assertEquals(hs3.Phone_Collection__c, testAcc.Collections_Last_Registered__c);
        system.assertEquals(expectedReg, testAcc.Collections_Registered__c);
        
        //deregister third handset
        hs3.Registered__c = false;
        update hs3;
        //Check Account values updated from handset 
        testAcc = [Select Collections_Registered__c, Collections_Last_Registered__c
                    From Account where id = :acc.Id][0];
        expectedReg = hs2.Phone_Collection__c + ',' + hs1.Phone_Collection__c;
        //Last value should now be second  handset as third is de-registered, lists should have 2 values
        system.assertEquals(hs2.Phone_Collection__c, testAcc.Collections_Last_Registered__c);
        system.assertEquals(expectedReg, testAcc.Collections_Registered__c);
        
        //reregister third handset 
        hs3.Registered__c = true;
        update hs3;
        //Check Account values updated from handset 
        testAcc = [Select Collections_Registered__c, Collections_Last_Registered__c
                    From Account where id = :acc.Id][0];
        expectedReg = hs3.Phone_Collection__c + ',' + hs2.Phone_Collection__c + ',' + hs1.Phone_Collection__c;
        //Last value should now be third  handset , lists should have 2 values
        system.assertEquals(hs3.Phone_Collection__c, testAcc.Collections_Last_Registered__c);
        system.assertEquals(expectedReg, testAcc.Collections_Registered__c);
        
        //Delete handsets 2 & 3
        List<Handset__c> handsetsToDelete = new List<Handset__c>();
        handsetsToDelete.add(hs2);
        handsetsToDelete.add(hs3);
        delete handsetsToDelete;
        //Check Account values updated from handset 
        testAcc = [Select Collections_Registered__c, Collections_Last_Registered__c
                    From Account where id = :acc.Id][0];
        expectedReg = hs1.Phone_Collection__c;
        //Last value should now be first handset , lists should have first value only
        system.assertEquals(hs1.Phone_Collection__c, testAcc.Collections_Last_Registered__c);
        system.assertEquals(expectedReg, testAcc.Collections_Registered__c);
        
        //UnDelete handsets 2 
        undelete hs2;
        //Check Account values updated from handset 
        testAcc = [Select Collections_Registered__c, Collections_Last_Registered__c
                    From Account where id = :acc.Id][0];
        expectedReg = hs2.Phone_Collection__c + ',' + hs1.Phone_Collection__c;
        //Last value should now be second handset , lists should have both values
        system.assertEquals(hs2.Phone_Collection__c, testAcc.Collections_Last_Registered__c);
        system.assertEquals(expectedReg, testAcc.Collections_Registered__c);

    }
    
    //Test Method Added by Mahfuz Choudhury for SOA_UpdateCustomerHelper method testing
    Static testmethod void TestSOA_UpdateCustomerHelper()
    {
        //Create a custom setting which controls the integration
        Operation_Switch__c OPSwitch = UnitTestHelper.CreateOpSwtichCS(); 
        
        Account acc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        acc.RecordTypeId = GetAccountRecordType().get('Person_Account').id;
        Update acc;
        
        Vertu_Account__c VA1 = UnitTestHelper.createVertuAccount(acc.id, '0001');
        
        Account testAcc = [SELECT id, SOA_Update_Customer_Integration__c from Account where id =: acc.id Limit 1];
        testAcc.SOA_Update_Customer_Integration__c = true;
        Test.startTest();
        update testAcc;
        Test.stopTest();
        
        Account acc1 = [Select id, SOA_Update_Customer_Integration__c from Account where id =: testAcc.id];
        //System.assertEquals(true,acc1.SOA_Update_Customer_Integration__c);
    }
    
    //Test Method Added by Mahfuz Choudhury for Testing web service call out
    Static testmethod void TestSOA_MaintainCustomer()
    {
        //Create a custom setting which controls the integration
        Operation_Switch__c OPSwitch = UnitTestHelper.CreateOpSwtichCS(); 
        
        Account acc = UnitTestHelper.getAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        acc.RecordTypeId = GetAccountRecordType().get('Person_Account').id;
        Insert acc;
        
        Vertu_Account__c VA1 = UnitTestHelper.createVertuAccount(acc.id, '0001');
        acc = [Select id, SOA_Update_Customer_Integration__c from Account where id =: acc.id];
        acc.SOA_Update_Customer_Integration__c  = true;
        update acc;
        
        Set<id> Accountids = new Set<id>();
        Accountids.add(acc.id);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        //Positive case for call out below 
        HttpResponse mockResponse = Test_SOA_MaintainCustomerCall.getTestResponse(200);
        
        WSO_HTTPCustomerInterface_Mock mockService = Test_SOA_MaintainCustomerCall.HTTPUpdateCallMockService(mockResponse, req);
        
        Test.startTest();
        
        SOA_WSO_MaintainCustomer.UpdateCustomerRequest(Accountids);
        
        Test.stopTest();
    }
    
    //Test method for bulk Account and Vertu Account records (SOA Customer Update)
	Static testmethod void TestSOA_UpdateCustomerHelperBulk()
    {   
        //Create a custom setting which controls the integration
        Operation_Switch__c OPSwitch = UnitTestHelper.CreateOpSwtichCS(); 
        
        //Create a List here for holding all accounts
     	List<Account> AccList = new List<Account>();
        List<Vertu_Account__c> VertuAcc = new List<Vertu_Account__c>();
        Set<ID> Accids = new Set<ID>();
        
        //Create 100 Accounts here.. 
     	for(Integer i = 0; i<100; i++)
        {
        	Account acc = UnitTestHelper.getAccount('testsalutation'+i, 'testfirstname'+i, 'testlastname'+i, 'testnationality'+i, 'testcountry'+i, 'testlanguage'+i);
            acc.RecordTypeId = GetAccountRecordType().get('Person_Account').id;
            
            AccList.add(acc);
        }
        //Insert Accounts here..
		insert AccList;
        
        for(integer i = 0 ; i < AccList.size();i++)
        {
            //Insert two vertu Account for each account here..
            for(integer j = i; j < i+2; j++)
            {
             	Vertu_Account__c VA1 = UnitTestHelper.getVertuAccount(AccList[i].id, '000'+j);
                VertuAcc.add(VA1);
            }
        }
        //Insert Vertu Account here..
        Insert VertuAcc;
        
        System.assertEquals('testfirstname99', AccList[99].FirstName);
        System.assertEquals(AccList[0].id, VertuAcc[0].Account_Name__c);
        
        //Update Integration flag on all account
        for(Account a: AccList)
        {
            a.SOA_Update_Customer_Integration__c = true;
            //SOA_BATCH_CustomerMaintain.AccountIdsToProcess.add(a.id);
        }
        
        //SOA_BATCH_CustomerMaintain.AccountIdsToProcess.addAll(Accids);
        
        Test.startTest();
        Update AccList;
        Test.stopTest();
    }
    
    //Retrieve record types for Account object by Name
    static Map<String, RecordType> GetAccountRecordType()
    {
        return recordTypeUtils.GetRecordTypeByObject('Account');
    }
}