/*************************************************
TestEndPoint_Utils
Test Class: 

Class to increase code coverage for EndPoint_Utils class which was written prevoiusly

Author: Mahfuz Choudhury
Created Date: 30/06/2014
Changes:

**************************************************/
@isTest
public class TestEndPoint_Utils {
    
    static testmethod void testgetErrorNumber()
    {
        CustomException returnEx = new CustomException();
        
        String TestString = 'TestError';
        
        returnEx = Endpoint_Utils.getMissingOutboundEndpointException('Test Service');
        Integer errnumber = Endpoint_Utils.getErrorNumber(Endpoint_Utils.Errors.InvalidBatchSize);
        
    }
}