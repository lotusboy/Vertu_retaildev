public class Endpoint_Utils {
    /********************************************************************
     *  Created 06/03/2013 MN - BrightGen Ltd                           *
     *  Utility class to get endpoints for outbound calls               *
     *  Change History                                                  *
     *  
     * Modified by: Mahfuz Choudhury
     * Date: 24/06/14
     * Updated SOQL to include added fields into custom setting for SOA
     * Customer maintain call                                                                *
     ********************************************************************/

	private static Integer FIRST_ERROR_NUMBER = 10000;
	private static map<String, Integration_Endpoints__c> endPoints = null;

	public static Integration_Endpoints__c getEndPoint(String webServiceName)
	{
		if (endPoints == null)
		{
			endPoints = new map<String, Integration_Endpoints__c>();
			//set dummy endpoint when running in test mode
			if (test.isRunningTest())
			{
				Integration_Endpoints__c endpoint = new Integration_Endpoints__c(Name=webServiceName, Endpoint__c = 'www.brightgen.com', API_Key__c = '12345678-1234-5678-9012-123456789012');
				endpoints.put(endpoint.Name, endPoint);
			}
			else
			//return all endpoints from custom setting
			{
				for (Integration_Endpoints__c endpoint : [SELECT	Name, Endpoint__c, API_Key__c, User_Name__c, Password__c,
                                                          			Time_Stamp__c, Transaction_ID__c, Role__c, Message_ID__c
														 FROM		Integration_Endpoints__c])
				{
					endPoints.put(endpoint.Name, endPoint);
				}
                System.debug('Current End Points in Custom setting are --------------------->>>>>>'+endPoints);
			}
		}
		else if (Test.isRunningTest())
		{
			if (!endPoints.containsKey(webServiceName))
			{
				Integration_Endpoints__c endpoint = new Integration_Endpoints__c(Name=webServiceName, Endpoint__c = 'www.brightgen.com', API_Key__c = '12345678-1234-5678-9012-123456789012');
				endpoints.put(endpoint.Name, endPoint);
			}
		}
		if (endPoints.containsKey(webServiceName))
		{
			return endPoints.get(webServiceName);
		}
		else
		{
			throw getMissingOutboundEndpointException(webServiceName);
		}
	}

	public enum Errors
	{
		InvalidBatchSize,
		MaxSizeExceeded,
		NoMatchesFound,
		EnterpriseUpdateFailed,
		ValidationRuleFailed,
		NullMessageId,
		InvalidMessageId,
		MissingOutboundEndpoint,
		NoEnterpriseIdSupplied,
		DatabaseSaveError,
		NMRBatchSequenceError
	}
	public static Integer getErrorNumber(Errors err)
	{
		return err.ordinal() + FIRST_ERROR_NUMBER;
	}
	private static CustomException getException(Errors err, String message){
		CustomException returnEx = new CustomException();
		returnEx.ErrorNumber = err.ordinal() + FIRST_ERROR_NUMBER;
		returnEx.setMessage(message);
		return returnEx;
	}

	public static CustomException getMissingOutboundEndpointException(String outboundService)
	{
		return getException(Errors.MissingOutboundEndpoint, 
							'Missing Integration Endpoint custom for webservice ' + outboundService);
	}

}