/*************************************************
Test_BG_PasswordResetExt

Test class for BG_PasswordResetExt controller extension

Author: Mahfuz Choudhury (BrightGen)
Created Date: 30/07/2014
Modification Date:
Modified By:

**************************************************/
@isTest
public class Test_BG_PasswordResetExt {
	static testmethod void TestPasswordResetPositive()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage'); 
        account b = New Account( Name = 'Retail Account');
        b.RecordTypeId = GetAccountRecordType().get('Business_Account').id;
        b.Store_Code__c = '000020000';
        insert b;
        
        Encryption_key__c EK = UnitTestHelper.CreateEncryptionKeyCS();
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
        
        Apexpages.StandardController sc = new Apexpages.StandardController(VertuAcc);
        BG_PasswordResetExt PR = new BG_PasswordResetExt(sc);
        PR.UserPassword = 'Vertu123456';
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        Test.startTest();
        
        HttpResponse mockResponse = getTestResponse(200, a.id, VertuAcc.id);
        WSO_HTTPCustomerInterface_Mock mockService = HTTPDeRegisterMockService(mockResponse, req);
		
        PR.ResetPassword();
        PR.Redirect();
        
        Test.stopTest();
    }
    
    static testmethod void TestPasswordResetNegative()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage'); 
        account b = New Account( Name = 'Retail Account');
        b.RecordTypeId = GetAccountRecordType().get('Business_Account').id;
        b.Store_Code__c = '000020000';
        insert b;
        
        Encryption_key__c EK = UnitTestHelper.CreateEncryptionKeyCS();
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
        
        Apexpages.StandardController sc = new Apexpages.StandardController(VertuAcc);
        BG_PasswordResetExt PR = new BG_PasswordResetExt(sc);
        PR.UserPassword = '456';
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        Test.startTest();
        
        HttpResponse mockResponse = getTestResponse(405, a.id, VertuAcc.id);
        WSO_HTTPCustomerInterface_Mock mockService = HTTPDeRegisterMockService(mockResponse, req);
        
        PR.ResetPassword();
        PR.Redirect();
        
        Test.stopTest();
    }
    
    //If there was an error saving the record
    static testmethod void TestPasswordResetNegative2()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage'); 
        account b = New Account( Name = 'Retail Account');
        b.RecordTypeId = GetAccountRecordType().get('Business_Account').id;
        b.Store_Code__c = '000020000';
        insert b;
        
        Encryption_key__c EK = UnitTestHelper.CreateEncryptionKeyCS();
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
        
        Apexpages.StandardController sc = new Apexpages.StandardController(VertuAcc);
        BG_PasswordResetExt PR = new BG_PasswordResetExt(sc);
        PR.UserPassword = 'Maf23456';
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        Test.startTest();
        
        HttpResponse mockResponse = getTestResponse(200, '1234', '34567');
        WSO_HTTPCustomerInterface_Mock mockService = HTTPDeRegisterMockService(mockResponse, req);
        
        PR.ResetPassword();
        PR.Redirect();
        
        Test.stopTest();
    }
    
    //this method manages the mock De register service with response provided from test method(s) - SOAP service
    public static WSO_HTTPCustomerInterface_Mock HTTPDeRegisterMockService(HTTPResponse MockResponse, HttpRequest req)
    {
        WSO_HTTPCustomerInterface_Mock mockService = new WSO_HTTPCustomerInterface_Mock();
        mockService.request = req;
        mockService.response = MockResponse;
        
        Test.setMock(HttpCalloutMock.class, mockService);
        
        return mockService;
    }
    
    //Set up a mock response here..
    Static HttpResponse getTestResponse(Integer Status, String a, String VertuAcc)
    {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/xml; charset=utf-8');
        mockResponse.setbody('<DeregisterHandsetResponse><RequestID>20140714507456080261</RequestID>'+
                             '<AccountGUID>'+a+'</AccountGUID><VertuAccountGUID>'+VertuAcc+'</VertuAccountGUID>'+
                             '<Acknowledgement><Status>SUCCESS</Status><MessageID>d183b16a-6957-47ae-a66b-dc2ba7207e81</MessageID></Acknowledgement></DeregisterHandsetResponse>');
        
        mockResponse.setStatusCode(Status);
        
        return mockResponse;
    }
    
    @isTest(SeeAllData=True)
    static Map<String, RecordType> GetAccountRecordType()
    {
        return recordTypeUtils.GetRecordTypeByObject('Account');
    }
}