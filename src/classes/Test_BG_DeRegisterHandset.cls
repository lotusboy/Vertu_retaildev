/*************************************************
Test_BG_DeRegisterHandset

Test class for BG_DeRegisterHandset controller extension

Author: Mahfuz Choudhury (BrightGen)
Created Date: 25/07/2014
Modification Date:
Modified By:

**************************************************/
@isTest
public class Test_BG_DeRegisterHandset {
	static testmethod void TestBG_DeRegisterHandsetPositive()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage'); 
        account b = UnitTestHelper.createAccount('testSalutation', 'FirstName', 'LastName', 'nationality', 'country', 'language');
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
      	
        Handset__c H = UnitTestHelper.createHandSet(a.id, 'test Collection', 'P-1234', 'V-1234', false);
        H.IMEI__c = '1234';
        H.Vertu_Account__c = VertuAcc.id;
        Update H;
        
        Apexpages.StandardController sc = new Apexpages.StandardController(H);
        BG_DeRegisterHandset DH = new BG_DeRegisterHandset(sc);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        Test.startTest();
        
        HttpResponse mockResponse = getTestResponse(200, a.id, VertuAcc.id);
        WSO_HTTPCustomerInterface_Mock mockService = HTTPDeRegisterMockService(mockResponse, req);
        
        DH.DeRegistration();
        DH.Redirect();
        
        Test.stopTest();
    }
    
    static testmethod void TestBG_DeRegisterHandsetNegative()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage'); 
        account b = UnitTestHelper.createAccount('testSalutation', 'FirstName', 'LastName', 'nationality', 'country', 'language');
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
      	
        Handset__c H = UnitTestHelper.createHandSet(a.id, 'test Collection', 'P-1234', 'V-1234', false);
        H.IMEI__c = '1234';
        H.Vertu_Account__c = VertuAcc.id;
        Update H;
        
        Apexpages.StandardController sc = new Apexpages.StandardController(H);
        BG_DeRegisterHandset DH = new BG_DeRegisterHandset(sc);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        Test.startTest();
        
        HttpResponse mockResponse = getTestResponse(405, a.id, VertuAcc.id);
        WSO_HTTPCustomerInterface_Mock mockService = HTTPDeRegisterMockService(mockResponse, req);
        
        DH.DeRegistration();
        DH.Redirect();
        
        Test.stopTest();
    }
    
    //If there was an error saving the record
    static testmethod void TestBG_DeRegisterHandsetNegative2()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage'); 
        account b = UnitTestHelper.createAccount('testSalutation', 'FirstName', 'LastName', 'nationality', 'country', 'language');
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
      	
        Handset__c H = UnitTestHelper.createHandSet(a.id, 'test Collection', 'P-1234', 'V-1234', false);
        H.IMEI__c = '1234';
        H.Vertu_Account__c = VertuAcc.id;
        Update H;
        
        Apexpages.StandardController sc = new Apexpages.StandardController(H);
        BG_DeRegisterHandset DH = new BG_DeRegisterHandset(sc);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        Test.startTest();
        
        HttpResponse mockResponse = getTestResponse(200, '1234', '34567');
        WSO_HTTPCustomerInterface_Mock mockService = HTTPDeRegisterMockService(mockResponse, req);
        
        DH.DeRegistration();
        DH.Redirect();
        
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
}