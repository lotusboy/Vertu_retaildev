/*************************************************
WSO_SOA_HTTPCustomerMaintainInterface
Test Class:

Class for handling web service (RESTful) call out via HTTP interface

Author: Mahfuz Choudhury
Created Date: 08/07/2014

**************************************************/

public class WSO_SOA_HTTPCustomerMaintainInterface {
    Public String Endpoint = 'https://stageservices.vertuservices.com:6005/bs/customer/v01/MaintainCustomerService/UpdateCustomer';
    Public Integer Timeout = 60000;
    Public String CalloutMethod = 'POST';
    
    //Stub method for calling the REST based web service for Customer Update
    Public HttpResponse MaintainCustomerInterface(String XMLRequestBody, String authorizationHeader)
    {
        Http h = new Http(); 
        HttpRequest request = new HttpRequest(); 
        request.setEndpoint(Endpoint); 
        request.setMethod(CalloutMethod);
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Authorization', authorizationHeader);
        //req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        request.setBody(XMLRequestBody); 
        request.setTimeout(Timeout);

        HttpResponse response = new HttpResponse();
        response = h.send(request);

        System.debug('Response is ------------------------>>>>>>>>>>>>>>>>>>>>'+response.getbody());
        
        return response;
   
    }
}