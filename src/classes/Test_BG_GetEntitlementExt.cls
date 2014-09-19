/*************************************************
Test_BG_GetEntitlementExt

Test class for BG_GetEntitlementExt controller extension

Author: Mahfuz Choudhury
Created Date: 04/08/2014

**************************************************/
@isTest
public class Test_BG_GetEntitlementExt {
	
    //Positive Cases..
    static testmethod void TestGetEntitlementPositive()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage');
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
        
        Entitlement__c Entitlement = UnitTestHelper.createEntitlement('Classic', System.today().addDays(90), a.id, VertuAcc.id);
        Entitlement.Start_Date__c = System.today();
        Entitlement.Request_Duration__c = '3';
        Entitlement.Reason__c = 'Customer Purchased';
        Entitlement.Notes__c = 'None';
        Update Entitlement;
        
        Apexpages.StandardController sc = new Apexpages.StandardController(VertuAcc);
        BG_GetEntitlementExt GE = new BG_GetEntitlementExt(sc);
        GE.Entitlement = Entitlement;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        Test.startTest();
        
        HttpResponse mockResponse = getTestResponse(200, 'SUCCESS');
        WSO_HTTPCustomerInterface_Mock mockService = HTTPDeRegisterMockService(mockResponse, req);
		
        GE.GetEntitlementDetails();
        GE.CreateEntitlementRequest();
        GE.Redirect();
        
        Test.stopTest();
    }
    
    //Negative Cases..
    static testmethod void TestGetEntitlementNegative()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage');
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, '');
        
        Entitlement__c Entitlement = UnitTestHelper.createEntitlement('Classic', System.today().addDays(90), Null, VertuAcc.id);
        Entitlement.Start_Date__c = System.today();
        Entitlement.Request_Duration__c = '3';
        Entitlement.Reason__c = 'Customer Purchased';
        Entitlement.Notes__c = 'None';
        Update Entitlement;
        
        Apexpages.StandardController sc = new Apexpages.StandardController(VertuAcc);
        BG_GetEntitlementExt GE = new BG_GetEntitlementExt(sc);
        GE.Entitlement = Entitlement;
        
        Test.startTest();
		
        GE.GetEntitlementDetails();
        GE.CreateEntitlementRequest();
        GE.Redirect();
        
        Test.stopTest();
    }
    
    static testmethod void TestGetEntitlementNegative2()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage');
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, 'V-1234');
        
        Apexpages.StandardController sc = new Apexpages.StandardController(VertuAcc);
        BG_GetEntitlementExt GE = new BG_GetEntitlementExt(sc);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        Test.startTest();
        
        HttpResponse mockResponse = getTestResponse(200, 'FAILURE');
        WSO_HTTPCustomerInterface_Mock mockService = HTTPDeRegisterMockService(mockResponse, req);
		
        GE.GetEntitlementDetails();
        
        Test.stopTest();
    }
    
    //Catch Block
    static testmethod void TestGetEntitlementNegative3()
    {
        account a = UnitTestHelper.createAccount('testSalutation', 'TestFirstName', 'testLastName', 'testnationality', 'testcountry', 'testlanguage');
        
        Vertu_Account__c VertuAcc = UnitTestHelper.createVertuAccount(a.id, Null);
        
        WSO_SOA_HandsetsetRegistrationHelper CH = new WSO_SOA_HandsetsetRegistrationHelper();
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        Test.startTest();
        
        HttpResponse mockResponse = getInvalidResponse();
        mockResponse.setStatusCode(405);
        
        WSO_HTTPCustomerInterface_Mock mockService = HTTPDeRegisterMockService(mockResponse, req);
		CH.GetEntitlements(VertuAcc.VREG_ID_Vertu_Account__c, a.id, VertuAcc.id);   

        WS_SOA_MaintainCustomerType.PasswordResetRequestType PRT = WSO_SOA_HandsetsetRegistrationHelper.CreatePasswordResetRequestType(a.id, VertuAcc.id, '12345', 'Hello 123', '1234');
        
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
    Static HttpResponse getTestResponse(Integer Status, String AckStatus)
    {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/xml; charset=utf-8');
        mockResponse.setbody('<GetEntitlementResponse><EntitlementList><Entitlement><DurationLeft>10</DurationLeft></Entitlement>'+
                             '</EntitlementList><EntitlementFactsList><Entitlement>'+
                             '<Level>classic</Level><Duration>12</Duration><StartDate>2009-09-12</StartDate>'+
                             '<EndDate>2010-09-12T16:43:54.000+01:00</EndDate><AddedDate>2009-09-12T16:43:54.000+01:00</AddedDate>'+
                             '<Reason>imported</Reason><Notes>Z-000137</Notes></Entitlement></EntitlementFactsList>'+
                             '<Acknowledgement><Status>'+AckStatus+'</Status><MessageID>d183b16a-6957-47ae-a66b-dc2ba7207e81</MessageID></Acknowledgement></GetEntitlementResponse>');
        
        mockResponse.setStatusCode(Status);
        
        return mockResponse;
    }
    
    //Set invalid response here
    Static HttpResponse getInvalidResponse()
    {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/xml; charset=utf-8');

        mockResponse.setbody('');   
        
        return mockResponse;
    }
}