/*************************************************
WSO_HTTPCustomerInterface_Mock

Class for mock HTTP callout during run time of test environment

Author: Mahfuz Choudhury
Created Date: 11/07/2014

**************************************************/
@isTest                        
global class WSO_HTTPCustomerInterface_Mock implements HttpCalloutMock {
    //Declare variables to manipulate requests and responses from test class
    public HttpRequest request {get; set; }
    public HttpResponse response {get; set;}
    
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals(request.getEndpoint(), req.getEndpoint());
        
        // Create a fake response
        HttpResponse res = response;
        //res.setStatusCode(200);
        
        return res;
    }
}