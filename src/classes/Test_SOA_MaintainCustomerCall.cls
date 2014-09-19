/*************************************************
Test_SOA_MaintainCustomerCall

Class for testing Maintain Customer Call class which makes 
the call out through interface

Author: Mahfuz Choudhury
Created Date: 26/06/2014

**************************************************/
@isTest
public class Test_SOA_MaintainCustomerCall {
    
    @isTest 
    static void testUpdateCustomerCall() 
    {              
        //Create a test account so id can be obtained for fake request and response
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
        
        //Create test vertu account so that vertu account id can be obtained for fake request and response 
        Vertu_Account__c testVA = UnitTestHelper.createVertuAccount(testAcc.id, '0001');
        
        //Select the Account and Vertu Account so that the fields can be obtained for response and request
        testAcc = getAccount(testAcc.id);
        testVA = getVertuAccount(testVA.id);
        
        /*The following SOAP testing service has been commemted out as Vertu changed their web service from SOAP to REST 
         * becasue of the compatibility issue
        //Create an Acknowledgement type here..
        WS_SOA_MaintainCustomerAcknowledgement.AcknowledgementType ack = new WS_SOA_MaintainCustomerAcknowledgement.AcknowledgementType();
        ack.Status = 'Success';
        ack.Message = 'Hello Salesforce';
        ack.Code = '1234';
        ack.MessageID = '0000';
        
        //set up mock response service here..
        WS_SOA_MaintainCustomerType.UpdateCustomerResponseType mockResponse = new WS_SOA_MaintainCustomerType.UpdateCustomerResponseType();
        mockResponse.RequestID = '1234';
        mockResponse.AccountGUID = testAcc.id;
        mockResponse.VertuAccountGUID = testVA.id;
        mockResponse.VregID = 1001;
        mockResponse.Acknowledgement = ack;
        
        //Get the Mock response here..
        WSO_CustomerMaintainInterface_Mock mockService = UpdateCallMockService(mockResponse);

        /*
            Call the method under test.
            StartTest and StopTest statements are required for mock service interface to work correctly.
        
        
        Test.startTest();
        
        SOA_WSO_MaintainCustomerCall testcustomercall = new SOA_WSO_MaintainCustomerCall();
        WS_SOA_MaintainCustomerType.UpdateCustomerResponseType actualResponse = testcustomercall.UpdateCustomerCall(testAcc,testVA);
        
        Test.stopTest();*/
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('http:\\test.vertu.com');
        
        //Positive case for call out below 
        HttpResponse mockResponse = getTestResponse(200);
        
        WSO_HTTPCustomerInterface_Mock mockService = HTTPUpdateCallMockService(mockResponse, req);
        
        WS_SOA_MaintainCustomerType.UpdateCustomerResponseType mockres = BG_XMLUtility.ParseCustomerUpdateResponse(mockResponse.getBody());
        
        Test.startTest();
        
        SOA_WSO_MaintainCustomerCall testcustomercall = new SOA_WSO_MaintainCustomerCall();
        WS_SOA_MaintainCustomerType.UpdateCustomerResponseType actualResponse = testcustomercall.UpdateCustomerCall(testAcc,testVA);
        
        Test.stopTest();
        
        //Assrertion...
        System.assertEquals(mockres.RequestID, actualResponse.RequestID);
    }
    
    //Method to query Account in database for test class
    static Account GetAccount(Id AccId)
    {
        Account Acc = [SELECT ID, Name, Salutation, FirstName, LastName, Gender__pc, 
                            PersonBirthdate, Vertu_Spoken_Language__c, Vertu_Written_Language__pc, 
                            PersonEmail, Secondary_Email_Address__pc, Third_Email_Address__pc,
                            Fourth_Email_Address__pc, Fifth_Email_Address__pc, PersonMobilePhone,
                            PersonHomePhone, PersonOtherPhone, PersonMailingStreet,
                            PersonMailingcountry, PersonMailingPostalCode, PersonOtherStreet,
                            PersonOthercountry, PersonOtherPostalCode, Mail_Me__pc, SMS_Me__pc, 
                            Phone_Me__pc, Email_Me__pc, Passion_Fine_Dining__pc,
                            Passion_Champagne_Fine_Wine_And_Spirits__pc, Passion_VIP_Entertainment__pc,
                            Passion_Fashion_And_Style__pc, Passion_Elite_World_Sport__pc,
                            Passion_Business_Intelligence__pc, Passion_The_Arts__pc,
                            Passion_Technology_and_Gadgets__pc,
                            Passion_Travel__pc 
                       from Account 
                       where ID =: AccId];
        return Acc;    
    }
    
    //Method to Query Vertu Account in Database for test class
    static Vertu_Account__c getVertuAccount(Id VAid)
    {
        Vertu_Account__c VA = [Select VREG_ID_Vertu_Account__c, Active__c, Id, Private_Question__c, 
                                      Security_Answer__c, Username__c 
                               from Vertu_Account__c 
                               where id=: VAid];
        
        return VA;
    }
    
    /* 
        Utility methods
     */
    
    /*this method manages the mock update customer call with response provided from test method(s) - SOAP service
    static WSO_CustomerMaintainInterface_Mock UpdateCallMockService(WS_SOA_MaintainCustomerType.UpdateCustomerResponseType mockResponse)
    {
        WSO_CustomerMaintainInterface_Mock updateMockService = new WSO_CustomerMaintainInterface_Mock();
        updateMockService.ResponseElement = mockResponse;
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, updateMockService);
        
        return updateMockService;
    }*/
    
    //this method manages the mock update customer call with response provided from test method(s) - SOAP service
    public static WSO_HTTPCustomerInterface_Mock HTTPUpdateCallMockService(HTTPResponse MockResponse, HttpRequest req)
    {
        WSO_HTTPCustomerInterface_Mock mockService = new WSO_HTTPCustomerInterface_Mock();
        mockService.request = req;
        mockService.response = MockResponse;
        
        Test.setMock(HttpCalloutMock.class, mockService);
        
        return mockService;
    }
    
    public Static HttpResponse getTestResponse(Integer Status)
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
}