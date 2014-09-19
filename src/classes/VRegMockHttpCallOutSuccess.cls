@isTest
global class VRegMockHttpCallOutSuccess implements HttpCalloutMock {
	
	public String createdAccountId = '996699';
	global String methodCallSave = 'Save';
	global String methodCallIsValidHandset = 'isValidHandset';
	global String methodCall = '';
	
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake VReg API response
        HttpResponse res = new HttpResponse();
        if (methodCall == 'isValidHandset')
        {
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('code: 200 result: true, success: true');
	        res.setStatusCode(200);
        }
        else if (methodCall == 'save')
        {
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('code: 200 result: - {reference_id: \'' + createdAccountId + '\', system_messages: \'\'} success: true');
	        res.setStatusCode(200);
        }
        return res;
    }
    
    public VRegMockHttpCallOutSuccess ()
    {
    	// Constructor
    }
    
    public VRegMockHttpCallOutSuccess (String vertuAccountId)
    {
    	// Constructor
    	createdAccountId = vertuAccountId;
    }

}