/*************************************************
Test_BG_VerifyHandsetDetails

Test class for BG_VerifyHandsetDetails controller extension

Author: Mahfuz Choudhury
Created Date: 11/07/2014

**************************************************/

@isTest
public class Test_BG_VerifyHandsetDetails {
    
    //Verify Handset Poditive cases..
    static testmethod void TestVerifyHandsetDetails()
    {   
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage'); 
        account b = New Account( Name = 'Retail Account');
        b.RecordTypeId = GetAccountRecordType().get('Business_Account').id;
        b.Store_Code__c = '000020000';
        insert b;
        
        Encryption_key__c EK = UnitTestHelper.CreateEncryptionKeyCS();
        
        Handset_Registration__c handsetReg1 = UnitTestHelper.createHandsetRegistration('2222255', a.id, Datetime.now().adddays(-5), 'test12345678', 'T 1234', '123', 'What is your favourite city?','London', b.id);
        Handset_Registration__c handsetReg = UnitTestHelper.createHandsetRegistration('2222255', a.id, Datetime.now().adddays(-5), 'test12345678', 'T 1234', '123', 'What is your favourite city?','London', b.id);
        
        Apexpages.StandardController sc = new Apexpages.StandardController(handsetReg);
        
        Test.startTest();
        BG_VerifyHandsetDetails HV = new BG_VerifyHandsetDetails(sc);
        HV.HandsetRegistration();
        HV.Redirect();
        HV.RenderSecurityQS();
        
        Handset_Registration__c handsetReg2 = [Select id, User_Name__c, Password1__c, IMEI__c, VSN__c from Handset_Registration__c where id =: handsetReg.id];
        
        handsetReg2.IMEI__c = '1234';
        handsetReg2.User_Name__c = 'Test1234_';
        handsetReg2.Password1__c = '12345677';
        handsetReg2.VSN__c = 'ddd12345';
        
        update handsetReg2;
        
        Apexpages.StandardController sc1 = new Apexpages.StandardController(handsetReg2);
        
        BG_VerifyHandsetDetails HV1 = new BG_VerifyHandsetDetails(sc1);
        
        HV1.HandsetRegistration();
		HV1.Redirect();
     
        Test.stopTest();
    }
    
    //Negative cases for verify handset details..
    static testmethod void TestVerifyHandsetDetailsNegative()
    {   
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage'); 
        a.PersonEmail = 'vertu@brightgen.com';
        Update a;
        
        account b = New Account( Name = 'Retail Account');
        b.RecordTypeId = GetAccountRecordType().get('Business_Account').id;
        b.Store_Code__c = '000020000';
        insert b;
        
        Vertu_Account__c VA = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
        VA.Username__c = 'T 1234';
        VA.Primary_email_address__c = 'vertu@brightgen.com';
        VA.Active__c = true;
        Update VA;
        
        Handset__c H = UnitTestHelper.createHandSet(a.id, 'test Collection', 'P-1234', 'V-1234', true);
        
        Handset_Registration__c handsetReg = UnitTestHelper.createHandsetRegistration('2222255', a.id, Datetime.now().adddays(-5), 'V-1234', 'T 1234', '123', GetCustomLabel(),'London', b.id);
        handsetReg.Private_Question__c = 'Hello Vertu?';
        Update handsetReg;
        
        Apexpages.StandardController sc = new Apexpages.StandardController(handsetReg);
        
        Test.startTest();
        BG_VerifyHandsetDetails HV = new BG_VerifyHandsetDetails(sc);
        HV.HandsetRegistration();
        HV.Redirect();
        HV.RenderSecurityQS();
     
        Test.stopTest();
    }
    
    //Callout for create customer test cases..
    static testmethod void TestSOA_RegistrationHelper()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage'); 
        account b = New Account( Name = 'Retail Account');
        b.RecordTypeId = GetAccountRecordType().get('Business_Account').id;
        b.Store_Code__c = '000010000';
        insert b;
        
        Encryption_key__c EK = UnitTestHelper.CreateEncryptionKeyCS();
        
        Handset_Registration__c handsetReg = UnitTestHelper.createHandsetRegistration('2345', a.id, Datetime.now().adddays(-5), 'test12345678', 'Test1234_', '12334567d', 'What is your favourite city?','London', b.id);
        
        Apexpages.StandardController sc = new Apexpages.StandardController(handsetReg);
        BG_VerifyHandsetDetails HV = new BG_VerifyHandsetDetails(sc);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        HttpResponse mockResponse = Test_SOA_MaintainCustomerCall.getTestResponse(200);
        WSO_HTTPCustomerInterface_Mock mockService = Test_SOA_MaintainCustomerCall.HTTPUpdateCallMockService(mockResponse, req);
        
        Test.startTest();
        
        HV.HandsetRegistration();
        
        mockResponse = Test_SOA_MaintainCustomerCall.getTestResponse(500);
        mockService = Test_SOA_MaintainCustomerCall.HTTPUpdateCallMockService(mockResponse, req);
        
        HV.HandsetRegistration();
        HV.Redirect();
        
        Test.stopTest();
    }
    
    //Handset registration positive case..
    static testmethod void TestHandsetRegistration()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage');
        
        account b = New Account( Name = 'Retail Account');
        b.RecordTypeId = GetAccountRecordType().get('Business_Account').id;
        b.Store_Code__c = '000030000';
        insert b;
        
        Encryption_key__c EK = UnitTestHelper.CreateEncryptionKeyCS();
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
        Handset__c H = UnitTestHelper.createHandSet(a.id, 'test Collection', 'P-1234', 'V-1234', false);
        H.Place_of_Purchase__c = b.id;
        H.IMEI__c = '1234';
        
        Apexpages.StandardController sc = new Apexpages.StandardController(VertuAcc);
        
        BG_SOA_HandsetRegistration HR = new BG_SOA_HandsetRegistration(sc);
        HR.NewHandset = H;
        
        //Create a test Request here
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        //Get the mock response defined in Test_SOA_MaintainCustomerCall class
        HttpResponse mockResponse = getTestResponse(200);
        WSO_HTTPCustomerInterface_Mock mockService = Test_SOA_MaintainCustomerCall.HTTPUpdateCallMockService(mockResponse, req);
        
        Test.startTest();
        	HR.HandsetRegistration();
        	HR.Redirect();
        Test.stopTest();
    }
    
    //Handset Registration Negative cases..
    static testmethod void TestHandsetRegistrationNegative()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage');
        
        account b = New Account( Name = 'Retail Account');
        b.RecordTypeId = GetAccountRecordType().get('Business_Account').id;
        b.Store_Code__c = '000030000';
        insert b;
        
        Encryption_key__c EK = UnitTestHelper.CreateEncryptionKeyCS();
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
        
        Handset__c H = UnitTestHelper.createHandSet(a.id, 'test Collection', 'P-1234', 'V-1234', true);
        H.Place_of_Purchase__c = b.id;
        H.IMEI__c = '1234';
        
        Handset__c H1 = UnitTestHelper.createHandSet(a.id, 'test Collection', 'P-1234', 'V-1234', true);
        H1.Place_of_Purchase__c = b.id;
        H1.IMEI__c = '123';
        
        Apexpages.StandardController sc = new Apexpages.StandardController(VertuAcc);
        
        BG_SOA_HandsetRegistration HR = new BG_SOA_HandsetRegistration(sc);
        HR.NewHandset = H1;
        
        Test.startTest();
        	HR.HandsetRegistration();
        	HR.Redirect();
        Test.stopTest();
    }
    
    Static HttpResponse getTestResponse(Integer Status)
    {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/xml; charset=utf-8');
        mockResponse.setbody('<UpdateCustomerResponse><RequestID>20140714507456080261</RequestID>'+
                             '<AccountGUID>1234</AccountGUID><VertuAccountGUID>23456</VertuAccountGUID>'+
                             '<Handset><IMEI>123</IMEI><ServicesList><ServicesType><ServiceName>Test Service</ServiceName>'+
                             '</ServicesType></ServicesList></Handset>'+
                             '<Acknowledgement><Status>SUCCESS</Status></Acknowledgement></UpdateCustomerResponse>');
        mockResponse.setStatusCode(Status);
        
        return mockResponse; 
    }
    
    @isTest(SeeAllData=True)
    static Map<String, RecordType> GetAccountRecordType()
    {
        return recordTypeUtils.GetRecordTypeByObject('Account');
    }
    
    @isTest(SeeAllData=True)
    static String GetCustomLabel()
    {
        return System.Label.Question_Write_Own;
    }
}