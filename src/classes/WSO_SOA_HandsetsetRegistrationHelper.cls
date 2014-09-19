/*************************************************
WSO_SOA_HandsetsetRegistrationHelper
Test Class: Test_BG_VerifyHandsetDetails

Class for preparing data and communicationg with HTTP (RESTful)
interface class for handset registration, Create Customer, Password Reset
and get and create Entiltements. This provides synchronous 
Call out as Handset verfiation needs to be done prior registering a handset 
with SOA.

Author: Mahfuz Choudhury
Created Date: 09/07/2014

**************************************************/

public class WSO_SOA_HandsetsetRegistrationHelper {
    Public Static Final Integer Timeout = 120000;
    Public Static Final string EndpointName = 'Handset_Verification_Endpoint';
    Public Static Final string EndpointName1 = 'SOACreateCustomer';
    Public Static Final string EndpointName2 = 'Handset_Registration';
    Public Static Final string DeRegisterEndpointName = 'Handset_DeRegistration';
    Public Static String PasswordResetEndPointName = 'SOA_Password_Reset';
    Public Static String GetEntitlementEndPointName = 'SOA_Get_Entitlements';
    Public Static String AddEntitlementEndPointName = 'SOA_Create_Entitlement';
    Public Static String VerifyHandsetEndpoint = 'DEFAULT';
    Public Static String CreateCustomerEndpoint = 'DEFAULT';
    Public Static String RegisterHandsetEndpoint = 'DEFAULT';
    Public Static String DeRegisterHandsetEndpoint = 'DEFAULT';
    Public Static String PasswordResetEndPoint = 'DEFAULT';
    Public Static String GetEntitlementsEndPoint = 'DEFAULT';
    Public Static String AddEntitlementEndPoint = 'DEFAULT';
    Public Static final String CallOutMethod = 'POST';
    Public Static final String ValidResponse = 'SUCCESS';
    Public Static final String RequestLogError = System.Label.Request_Log_Error;
    public static String authorizationHeader = 'BASIC '+'';
    Public Static String ErrorSource = '';
    Public static final String RequestLogErrorStatus = 'Error';
    Public String response = '';
    Public String XMLRequestBody = Null;
    Public HttpResponse res;
    Public SOA_Request_Log__c SOARequest;
    
    public String VerifyHandsetWithSOA(String IMEI, String VSN, ID CustomerId, Boolean ServiceRegistration, String ServiceName, String VertuAccId,
                                      String PlaceOfPurchase, String OtherPlaceOfPurchase, Datetime DateofPurchase, String UserName,
                                      String Password, String SecurityQuestion, String SecurityAnswer)
    {        
        String XMLCreateCustomerReqBody = null;
        
        //Return the following types from XML utility method once response has been parsed for Handset verification & Create Customer
        WS_SOA_MaintainCustomerType.HandsetVerificationResponseType HandsetvResponse = new WS_SOA_MaintainCustomerType.HandsetVerificationResponseType();
        WS_SOA_MaintainCustomerType.CreateCustomerResponseType CreateCusResponse = new WS_SOA_MaintainCustomerType.CreateCustomerResponseType();
        //The following method call retrieve the Customer Information for embedding in the body section of the request (Create Vertu Customer)
        WS_SOA_CustomerType.CustomerType SOACustomer = new WS_SOA_CustomerType.CustomerType();
        
        
        //The following method call retrieve the header information for embedding in the body section of the request
        WS_SOA_HeaderInfo.Header Bodyheader = SOA_WSO_MaintainCustomerCall.SOACustomerMaintainHeader(EndpointName);
       
        //Retrieve the name of the Endpoint from Integration Endpoint custom setting
        VerifyHandsetEndpoint = SOA_WSO_MaintainCustomerCall.GetEndPointURLByName(EndpointName);
        
        Try
        {
            //Form the XML string for sending to web services
            XMLRequestBody = BG_XMLUtility.CreateHandsetVerificationRequest(IMEI, VSN, Bodyheader);
            System.debug('body for handset verification is :------------------------------->>>'+XMLRequestBody);   
            
        }Catch(NullPointerException ex)
        {
            System.debug('An exception Occured while Forming the Handset Request XML :------------------------------->>>'+ex.getMessage());
            response = System.Label.Salesforce_Exception+' Reason: '+System.Label.XML_Error;
        }
                
        //Call the interface class here and set all parameters for call out
        WSO_SOA_HTTPCustomerMaintainInterface CallOutInterface = SetInterface(VerifyHandsetEndpoint, CallOutMethod, 30000);
        
        Try
        {
            res = CallOutInterface.MaintainCustomerInterface(XMLRequestBody, authorizationHeader);
            System.debug('Response for Handset Validation is : -------------------------------------->>>>>>>'+res);
            
            //Parse the response here..
            if(res.getStatusCode() == 200 && res.getBody() != NULL)
            {
                Try
                {
                    HandsetvResponse = BG_XMLUtility.HandsetVerificationResponse(res.getBody());
                    //Add the missing information for handset node here presuming the call out was successful
                    If(HandsetVResponse != NULL)
                    {
                        HandsetvResponse.Handset.PurchasePlace = PlaceOfPurchase;
                        System.debug('Place of Purchase Code is:------------------------------->'+HandsetvResponse.Handset.PurchasePlace);
                        If(DateOfPurchase != NULL)
                        {
                         	//The following portion add a zero with singular day and month as SOA rejects otherwise
                            String MonthValue = String.valueOf(DateOfPurchase.month());
                            If(MonthValue.length() == 1)
                            {
                             	MonthValue = '0'+MonthValue;   
                            }
                            
                            String DayValue = String.valueOf(DateOfPurchase.Day());
                            If(DayValue.length() == 1)
                            {
                             	DayValue = '0'+DayValue;   
                            }
                            
                            HandsetvResponse.Handset.PurchaseDate = DateOfPurchase.year()+'-'+MonthValue+'-'+DayValue;   
                        }
                        HandsetVResponse.Handset.OtherPurchasePlace = OtherPlaceOfPurchase;
                    }
                }
                Catch(NullPointerException ex)
                {
                    System.debug('Error Parsing Response XML------------------------------->'+ex.getLineNumber());
                    response += System.Label.Salesforce_Exception+' Reason: '+System.Label.XML_Error;
                }
            }
            
            //If the Vreg id Already exists in SOA following block executes
            if(HandsetvResponse.Handset.VregID != NULL)
            {
                System.debug('Vreg Id Status from SOA response: ------------------------------->'+HandsetvResponse.Handset.VregID);
                response += System.Label.VregID_exists_SOA;
            }
            //If the verification was failed following blocks executes
            else if(HandsetvResponse.Acknowledgement.Status != 'SUCCESS')
            {
                System.debug('Vreg Id Status from SOA------------------------------->'+HandsetvResponse.Acknowledgement.Status);
                response += System.Label.VSN_EMEI_Invalid;
            }
            //Set response status to a valid response since 2nd call out will go almost as an asynchronous call out
            //from user's perspective
            else
                response = System.Label.Handset_Verified_Status;
            
        }Catch(CalloutException ex)
        {
            If(response == '')
            {
             	response = System.Label.VREG_Connection_ERror;   
            }
            System.debug('An Exception Occured while calling web services: -------------------------------------->>>>>>>'+ex.getMessage());
        }
        
        Catch(Exception ex)
        {
            If(response == '')
            {
             	response = System.Label.Salesforce_Exception + 'Reason: '+System.Label.Endpoint_Error;   
            }
            System.debug('An Exception Occured: -------------------------------------->>>>>>>'+ex.getMessage());
        }
            
        Try
        {
            //If vreg id is not returned or status is not failed it's a valid response, check which page this request has
            //come from and call the relevant service
            if(response == System.Label.Handset_Verified_Status && ServiceName == BG_VerifyHandsetDetails.ServiceName)
            {
                System.debug('Service Name Is:-------------------------------->'+ServiceName);
                //The following method call retrieve the header information for embedding in the body section of the request
                Bodyheader = SOA_WSO_MaintainCustomerCall.SOACustomerMaintainHeader(EndpointName1);
                
                //Retrieve the name of the Endpoint from Integration Endpoint custom setting
                CreateCustomerEndpoint = SOA_WSO_MaintainCustomerCall.GetEndPointURLByName(EndpointName1);
                System.debug('Customer Create Endpoint is---------------------------->'+CreateCustomerEndpoint);
                
                //Set the properties for the callout here
                CallOutInterface = SetInterface(CreateCustomerEndpoint, CallOutMethod, 30000);
                
                Account Acc = AccountUtils.GetAccountById(CustomerId);
                System.debug('Retrieved Account is:----------------------------------->'+Acc);
                
                if(Acc != Null)
                {
                    SOACustomer = SOA_WSO_MaintainCustomerCall.BuildCustomerType(Acc, null);
                    
                    //Since this a Create Customer Request we have to send the security details for SOA Customer 
                    SOACustomer.UserName = UserName;
                    SOACustomer.Password = Password;
                    SOACustomer.SecurityQuestion = SecurityQuestion;
                    SOACustomer.SecurityAnswer = SecurityAnswer;
                    
                    System.debug('SOACustomer in HandsetRegistrationHelper Class:------------------------------>'+SOACustomer);   
                }
                
                //If the customer has not opted in for services clear the service information from Verification Response
                if(ServiceRegistration == FALSE)
                {
                    HandsetvResponse.Handset.ServicesList.clear();   
                }
                
                //Create Customer Create Request here for Sending to SOA
                Try
                {
                    XMLCreateCustomerReqBody = BG_XMLUtility.CreateCustomerCreateRequest(SOACustomer, HandsetvResponse, Bodyheader);
                    System.debug('Create Customer Request Body is:------------------------------>'+XMLCreateCustomerReqBody);
                }
                Catch(NullPointerException ex)
                {
                    System.debug('Problem creating Vertu Account Create XML Request------------------------------->'+ex.getLineNumber());
                    ErrorSource += System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
                }
                //Call the create customer web services here..
                res = CallOutInterface.MaintainCustomerInterface(XMLCreateCustomerReqBody, authorizationHeader);
                
                //Parse the response here..
                if(res.getStatusCode() == 200 && res.getBody() != NULL)
                {
                    Try
                    {
                        //Parse the Xml response here using the appropriate method
                        CreateCusResponse = BG_XMLUtility.ParseCreateCustomerResponse(res.getBody());  
                    }
                    Catch(NullPointerException ex)
                    {
                    	System.debug('Error Parsing Response XML------------------------------->'+ex.getLineNumber());
                        ErrorSource = System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
                    }
                }
                
                If(CreateCusResponse != NULL)
                {
                    //Create a Request Log for the request
                    SOARequest = BG_RequestLogUtils.CreateSOALog((CreateCusResponse.AccountGUID != NULL)?CreateCusResponse.AccountGUID:CustomerID, CreateCusResponse.VertuAccountGUID,
                                                    CreateCusResponse.RequestID, NULL, CreateCusResponse.Acknowledgement.Status, CreateCusResponse.Acknowledgement.Message, ServiceName, CreateCustomerEndpoint);
                }
            }
            
            //If the request has come from an existing vertu Account
            else if(response == System.Label.Handset_Verified_Status && ServiceName == BG_SOA_HandsetRegistration.ServiceName)
            {
                WS_SOA_MaintainCustomerType.UpdateCustomerResponseType HandsetRegResponse = new WS_SOA_MaintainCustomerType.UpdateCustomerResponseType();
                //The following method call retrieve the header information for embedding in the body section of the request
                Bodyheader = SOA_WSO_MaintainCustomerCall.SOACustomerMaintainHeader(EndpointName2);
                
                //Retrieve the name of the Endpoint from Integration Endpoint custom setting
                RegisterHandsetEndpoint = SOA_WSO_MaintainCustomerCall.GetEndPointURLByName(EndpointName2);
                
                //Set the properties for the callout here
                CallOutInterface = SetInterface(RegisterHandsetEndpoint, CallOutMethod, 30000);
                
                //Add Accountid and VertuAccountId in HandsetVrespnse 
                if(CustomerId != NULL)
                {
                    SOACustomer.AccountGUID = CustomerId;
                }
                if(VertuAccId != NULL)
                {
                    SOACustomer.VertuAccountGUID = VertuAccId;
                    
                    //Get the Vreg Id for the handset since this is a mandatory field
                    String VregId = BG_VertuAccountUtils.getHandsetRegistrationById(VertuAccId).VREG_ID_Vertu_Account__c;
                    HandsetVresponse.Handset.VregId = VregId;
                }
                
                //If the customer has not opted in for services clear the service information from Verification Response
                if(ServiceRegistration == FALSE)
                {
                    HandsetvResponse.Handset.ServicesList.clear();   
                }

                Try
                {
                 	//Create the request xml string here for handset registration request
                	XMLRequestBody = BG_XMLUtility.HandsetRegistrationRequest(SOACustomer, HandsetVresponse, Bodyheader); 
                    System.debug('Handset Register Request Body Is:--------------------------------->'+XMLRequestBody);
                }Catch(NullPointerException ex)
                {
                    System.debug('Problem Occured While Creating Handset Registration Request for Existing Customer--------------->'+ex.getMessage());
                    ErrorSource = System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
                }
                
                //Call the create customer web services here..
                res = CallOutInterface.MaintainCustomerInterface(XMLRequestBody, authorizationHeader);
                
                //Parse the response here..
                if(res.getStatusCode() == 200 && res.getBody() != NULL)
                {
                    Try
                    {
                        //Parse the Xml response here using the appropriate method (Update Customer Method used because the response tree is same)
                        HandsetRegResponse = BG_XMLUtility.ParseCustomerUpdateResponse(res.getBody());  
                    }
                    Catch(NullPointerException ex)
                    {
                    	System.debug('Error Parsing Response for Handset Registration Request------------------------------->'+ex.getLineNumber());
                        ErrorSource = System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
                    }
                }
                
                If(HandsetRegResponse != NULL)
                {
                    //Create a Request Log for the request
                    SOARequest = BG_RequestLogUtils.CreateSOALog((HandsetRegResponse.AccountGUID != NULL)?HandsetRegResponse.AccountGUID:CustomerID, (HandsetRegResponse.VertuAccountGUID != NULL)?HandsetRegResponse.VertuAccountGUID : VertuAccId,
                                                    HandsetRegResponse.RequestID, NULL, HandsetRegResponse.Acknowledgement.Status, HandsetRegResponse.Acknowledgement.Message, ServiceName, RegisterHandsetEndpoint);
                }
            }
   
        }Catch(CalloutException ex)
        {
            SOARequest = BG_RequestLogUtils.CreateSOALog(CustomerID, VertuAccId, NULL, NULL, 
                                            RequestLogErrorStatus, ex.getMessage(), ServiceName, CreateCustomerEndpoint != 'DEFAULT'?CreateCustomerEndpoint:RegisterHandsetEndpoint);
            System.debug('An Exception Occured while calling web services: -------------------------------------->>>>>>>'+response);
        }
        
        Catch(Exception ex)
        {
            If(!ErrorSource.contains(System.label.XML_Error))
            {
             	ErrorSource = System.Label.Endpoint_Error;   
            }
            SOARequest = BG_RequestLogUtils.CreateSOALog(CustomerID, VertuAccId, NULL, NULL, 
                                            RequestLogErrorStatus, ErrorSource+ 'Error: '+ex.getMessage(), ServiceName, CreateCustomerEndpoint != 'DEFAULT'?CreateCustomerEndpoint:RegisterHandsetEndpoint);
            System.debug('An Exception Occured: -------------------------------------->>>>>>>'+response);
        }
        //If all the operation was completed successfully execute the following section..
        Try
        {
            if(SOARequest != NULL)
            {
                Database.insert(SOARequest);
            }
            
        }Catch(DMLException ex)
        {
            ErrorSource = System.label.Request_Log_Error;
            response = ErrorSource+' '+'Reason: '+ex.getMessage();
            System.debug('Failed to Create a Request Log: '+ex.getMessage());
        }
        
        System.debug('An Exception Occured: -------------------------------------->>>>>>>'+response);
        return response;
    }
    
    /*
     * The following method gets called from Handset de registration class to make a call out
     * to SOA for making a request for de registration.
	 */
    
    Public String DeRegisterHandset(Handset__c Handset, String ServiceName)
    {
     	String Response = '';
        //The following method call retrieve the header information for embedding in the body section of the request
        WS_SOA_HeaderInfo.Header Bodyheader = SOA_WSO_MaintainCustomerCall.SOACustomerMaintainHeader(DeRegisterEndpointName);
        WS_SOA_MaintainCustomerType.UpdateCustomerResponseType HandsetRegResponse = new WS_SOA_MaintainCustomerType.UpdateCustomerResponseType();
       
        //Retrieve the name of the Endpoint from Integration Endpoint custom setting
        DeRegisterHandsetEndpoint = SOA_WSO_MaintainCustomerCall.GetEndPointURLByName(DeRegisterEndpointName);
        
        //Call the interface class here and set all parameters for call out
        WSO_SOA_HTTPCustomerMaintainInterface CallOutInterface = SetInterface(DeRegisterHandsetEndpoint, CallOutMethod, 60000);
        
        Try
        {
         	Try
        	{
         		//Create the XML Request String here for sending to SOA
        		XMLRequestBody = BG_XMLUtility.CreateDeRegistrationRequest(Handset, Bodyheader); 
                System.debug('Deregister request XML body is:------------------------------------------->'+XMLRequestBody);
        	}
        	Catch(NullPointerException ex)
        	{
         		System.debug('Error Creating Request For Deregister Handset:------------------------------->'+ex.getLineNumber()+ex.getMessage());
        		ErrorSource = System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
        	}
        
        	If(XMLRequestBody != Null)
        	{
        		res = CallOutInterface.MaintainCustomerInterface(XMLRequestBody, authorizationHeader);
        	}
            
            //Parse the response here..
            if(res.getStatusCode() == 200 && res.getBody() != NULL)
            {
                Try
            	{
                	//Parse the Xml response here using the appropriate method (Update Customer Method used because the response tree is same)
                 	HandsetRegResponse = BG_XMLUtility.ParseCustomerUpdateResponse(res.getBody());
                    response = System.Label.DeRegister_Success_Message;
              	}
             	Catch(NullPointerException ex)
             	{
              		System.debug('Error Parsing Response for Handset DeRegistration:------------------------------->'+ex.getLineNumber()+ex.getMessage());
             		ErrorSource = System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
              	}
       		}
            
            If(HandsetRegResponse != NULL)
                {
                    //Create a Request Log for the request
                    SOARequest = BG_RequestLogUtils.CreateSOALog((HandsetRegResponse.AccountGUID != NULL)?HandsetRegResponse.AccountGUID:Handset.Account_Name__c, (HandsetRegResponse.VertuAccountGUID != NULL)?HandsetRegResponse.VertuAccountGUID : Handset.Vertu_Account__c,
                                                    (HandsetRegResponse.RequestID != NULL)?HandsetRegResponse.RequestID:NULL, Handset.Vreg_ID_Handset__c, HandsetRegResponse.Acknowledgement.Status, HandsetRegResponse.Acknowledgement.Message, ServiceName, DeRegisterHandsetEndpoint);

                   	SOARequest.Handset__c = Handset.id;  
                }
        }
        Catch(CalloutException ex)
        {
         	SOARequest = BG_RequestLogUtils.CreateSOALog(Handset.Account_Name__c, Handset.Vertu_Account__c, NULL, Handset.Vreg_ID_Handset__c, 
                                            RequestLogErrorStatus, ex.getMessage(), ServiceName, DeRegisterHandsetEndpoint);
           		
            SOARequest.Handset__c = Handset.id;   
            
            response = System.Label.DeRegister_Failure_Message;
            System.debug('An Exception Occured while calling web services: -------------------------------------->>>>>>>'+ex.getMessage());       
        }
        Catch(Exception ex)
        {
         	If(!ErrorSource.contains(System.label.XML_Error))
            {
             	ErrorSource = System.Label.Endpoint_Error;   
            }
            SOARequest = BG_RequestLogUtils.CreateSOALog(Handset.Account_Name__c, Handset.Vertu_Account__c, NULL, Handset.Vreg_ID_Handset__c, 
                                            RequestLogErrorStatus, ErrorSource+ 'Error: '+ex.getMessage(), ServiceName, DeRegisterHandsetEndpoint);
            
            SOARequest.Handset__c = Handset.id;   

            response = System.Label.DeRegister_Failure_Message;
            System.debug('An Exception Occured: -------------------------------------->>>>>>>'+ex.getMessage()+'At Line: '+ex.getLineNumber());	       
        }
        
        //If all the operation was completed successfully execute the following section..
        String Status = BG_RequestLogUtils.InsertSOALog(SOARequest);
        
        If(Status.contains(System.Label.Request_Log_Error))
        {
         	Response = System.Label.Request_Log_Error;   
        }
        
        System.debug('Response status in De register handset is: -------------------------------------->>>>>>>'+response);
        
        return Response;   
    }
    
    /*
     * The following method makes a call out to SOA for password reset request
	 */
    public String ProcessResetPasswordRequest(String AccountId, String VertuAccId, String VregId, String UserName, String Password, String ServiceName)
    {
        String Response = '';
        
        //Response type for the request..
        WS_SOA_MaintainCustomerType.UpdateCustomerResponseType PasswordResetResponse = new WS_SOA_MaintainCustomerType.UpdateCustomerResponseType();
        
        //The following method call retrieve the header information for embedding in the body section of the request
        WS_SOA_HeaderInfo.Header Bodyheader = SOA_WSO_MaintainCustomerCall.SOACustomerMaintainHeader(PasswordResetEndPointName);
        
        //Retrieve the name of the Endpoint from Integration Endpoint custom setting
        PasswordResetEndPoint = SOA_WSO_MaintainCustomerCall.GetEndPointURLByName(PasswordResetEndPointName);
        System.debug('Password Reset Endpoint is:------------------------------------->'+PasswordResetEndPoint);
        
        //Call the interface class here and set all parameters for call out
        WSO_SOA_HTTPCustomerMaintainInterface CallOutInterface = SetInterface(PasswordResetEndPoint, CallOutMethod, Timeout);
        
        Try
        {
            //Create a Password Request type from information provided
            WS_SOA_MaintainCustomerType.PasswordResetRequestType PasswordRequest = CreatePasswordResetRequestType(AccountId, VertuAccId, VregId, UserName, Password);
            Try
        	{
         		//Create the XML Request String here for sending to SOA
        		XMLRequestBody = BG_XMLUtility.CreatePasswordResetRequest(PasswordRequest, Bodyheader); 
                System.debug('Password Reset request XML body is:------------------------------------------->'+XMLRequestBody);
        	}
        	Catch(NullPointerException ex)
        	{
         		System.debug('Error Creating Request For Password Reset:-------------------------------> on Line:'+ex.getLineNumber()+'Error: '+ex.getMessage());
        		ErrorSource = System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
        	}
        
        	If(XMLRequestBody != Null)
        	{
        		res = CallOutInterface.MaintainCustomerInterface(XMLRequestBody, authorizationHeader);
        	}
            
            //Parse the response here..
            if(res.getStatusCode() == 200 && res.getBody() != NULL)
            {
                Try
            	{
                	//Parse the Xml response here using the appropriate method (Update Customer Method used because the response tree is same)
                 	PasswordResetResponse = BG_XMLUtility.ParseCustomerUpdateResponse(res.getBody());
                    response = System.Label.Password_Reset_Success_Message;
              	}
             	Catch(NullPointerException ex)
             	{
              		System.debug('Error Parsing Response for Password Reset:------------------------------->'+ex.getLineNumber()+ex.getMessage());
             		ErrorSource = System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
              	}
                
                //If the parsing of response was successful
                If(PasswordResetResponse != NULL)
                {
                    System.debug('Status of the response for password reset:------------------------->'+PasswordResetResponse.Acknowledgement.Status);
                    //Create a Request Log for the request
                    SOARequest = BG_RequestLogUtils.CreateSOALog(AccountId, VertuAccId, (PasswordResetResponse.RequestID != NULL)?PasswordResetResponse.RequestID:NULL, PasswordResetResponse.VregID, 
                                                                 PasswordResetResponse.Acknowledgement.Status, PasswordResetResponse.Acknowledgement.Message, ServiceName, PasswordResetEndPointName);
                }
       		}         
        }
        Catch(CalloutException ex)
        {
         	SOARequest = BG_RequestLogUtils.CreateSOALog(AccountId, VertuAccId, NULL, VregId, 
                                            RequestLogErrorStatus, ex.getMessage(), ServiceName, PasswordResetEndPointName);   
            
            response = System.Label.DeRegister_Failure_Message;
            System.debug('An Exception Occured while calling web services: -------------------------------------->>>>>>>'+ex.getMessage()+'Line:'+ex.getLineNumber());    
        }
        Catch(Exception ex)
        {
         	If(!ErrorSource.contains(System.label.XML_Error))
            {
             	ErrorSource = System.Label.Endpoint_Error;   
            }
            SOARequest = BG_RequestLogUtils.CreateSOALog(AccountId, VertuAccId, NULL, VregId, 
                                            RequestLogErrorStatus, ErrorSource+ 'Error: '+ex.getMessage(), ServiceName, PasswordResetEndPointName);  

            response = System.Label.DeRegister_Failure_Message;
            System.debug('An Exception Occured: -------------------------------------->>>>>>>'+ex.getMessage()+'At Line: '+ex.getLineNumber());   
        }
        
        //If all the operation was completed successfully execute the following section..
        String Status = BG_RequestLogUtils.InsertSOALog(SOARequest);
        
        If(Status.contains(System.Label.Request_Log_Error))
        {
         	Response = System.Label.Request_Log_Error;   
        }
        
        return Response;
    }
    
    /*
     * method to get Entitlement from SOA 
	 */
    Public WS_SOA_ServiceInfo.GetEntitlementResponse GetEntitlements(String VregId, Id VertuAccId, Id AccountId)
    {
        //Return type for Entitlements
        WS_SOA_ServiceInfo.GetEntitlementResponse Entitlements = new WS_SOA_ServiceInfo.GetEntitlementResponse();
        
        //The following method call retrieve the header information for embedding in the body section of the request
        WS_SOA_HeaderInfo.Header Bodyheader = SOA_WSO_MaintainCustomerCall.SOACustomerMaintainHeader(GetEntitlementEndPointName);
        
        //Retrieve the name of the Endpoint from Integration Endpoint custom setting
        GetEntitlementsEndPoint = SOA_WSO_MaintainCustomerCall.GetEndPointURLByName(GetEntitlementEndPointName);
        
        //Call the interface class here and set all parameters for call out
        WSO_SOA_HTTPCustomerMaintainInterface CallOutInterface = SetInterface(GetEntitlementsEndPoint, CallOutMethod, Timeout);
        
        Try
        {
            Try
        	{
         		//Create the XML Request String here for sending to SOA
        		XMLRequestBody = BG_XMLUtility.CreateGetEntitlementRequest(VregId, Bodyheader);
                System.debug('Get Entitlements request XML body is:------------------------------------------->'+XMLRequestBody);
        	}
        	Catch(NullPointerException ex)
        	{
         		System.debug('Error Creating Request For Get Entitlements:-------------------------------> on Line:'+ex.getLineNumber()+'Error: '+ex.getMessage());
        		Entitlements.SalesforceError = System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
        	}
        
        	If(XMLRequestBody != Null)
        	{
        		res = CallOutInterface.MaintainCustomerInterface(XMLRequestBody, authorizationHeader);
        	}
            
            //Parse the response here..
            Try
            {
                if(res.getStatusCode() == 200 && res.getBody() != NULL)
            	{
                	//Parse the Xml response here using the appropriate method 
                 	Entitlements = BG_XMLUtility.ParseGetEntitlementRequest(res.getBody());
                    System.debug('Entitlment in WSO_SOA_HRH class is------------------------------->'+Entitlements);
              	}
                //Test Running cases.. 
                else if(res.getBody()=='')
                {
                 	If(test.isRunningTest())
                    {
                     	Throw new NullPointerException();
                    }
                }
            }
            Catch(NullPointerException ex)
           	{
            	System.debug('Error Parsing Response for Get Entitlements:------------------------------->'+ex.getLineNumber()+ex.getMessage());
            	Entitlements.SalesforceError = System.Label.Salesforce_Exception + 'Reason: '+System.Label.XML_Error;
                
                If(test.isRunningTest())
                	Throw new BG_MyException();
      		}
            
        }
        Catch(CalloutException ex)
        {
            Entitlements.SalesforceError = System.Label.DeRegister_Failure_Message;
            System.debug('An Exception Occured while calling web services: -------------------------------------->>>>>>>'+ex.getMessage()+'Line:'+ex.getLineNumber());
            SOARequest = BG_RequestLogUtils.CreateSOALog(AccountId, VertuAccId, NULL, VregId, 
                                            RequestLogErrorStatus, ex.getMessage(), 'Get Entitlement Service', GetEntitlementEndPointName);
            String Status = BG_RequestLogUtils.InsertSOALog(SOARequest);
            System.debug('SOA log insertion Status:------------------------->'+Status);
        }
        Catch(Exception ex)
        {
         	If(Entitlements.SalesforceError != Null)
            {
             	If(!Entitlements.SalesforceError.contains(System.label.XML_Error))
            	{
             		Entitlements.SalesforceError = System.Label.Endpoint_Error;   
            	}
            	System.debug('An Exception Occured: -------------------------------------->>>>>>>'+ex.getMessage()+'At Line: '+ex.getLineNumber());     
            }
            else
                Entitlements.SalesforceError = System.Label.Endpoint_Error;
            
            SOARequest = BG_RequestLogUtils.CreateSOALog(AccountId, VertuAccId, NULL, VregId, 
                                            RequestLogErrorStatus, ex.getMessage(), 'Get Entitlement Service', GetEntitlementEndPointName);
            String Status = BG_RequestLogUtils.InsertSOALog(SOARequest);
            System.debug('SOA log insertion Status:------------------------->'+Status);
            
        }
        
        Return Entitlements;
    }
    
    /*
     * Method to create a SOA request for Adding an Entitlement via API request
	 */
    Public String CreateEntitlementRequest(Vertu_Account__c VertuAcc, Entitlement__c Entitlement, String ServiceName)
    {
     	String Status;
        //Return type for the request
     	WS_SOA_MaintainCustomerType.UpdateCustomerResponseType CreateHandsetResponse =  new WS_SOA_MaintainCustomerType.UpdateCustomerResponseType();
        //The following method call retrieve the header information for embedding in the body section of the request
        WS_SOA_HeaderInfo.Header Bodyheader = SOA_WSO_MaintainCustomerCall.SOACustomerMaintainHeader(AddEntitlementEndPointName);
        
        //Retrieve the name of the Endpoint from Integration Endpoint custom setting
        AddEntitlementEndPoint = SOA_WSO_MaintainCustomerCall.GetEndPointURLByName(AddEntitlementEndPointName);
        
        //Call the interface class here and set all parameters for call out
        WSO_SOA_HTTPCustomerMaintainInterface CallOutInterface = SetInterface(AddEntitlementEndPoint, CallOutMethod, Timeout);
        
        Try
        {
         	//Create the XML Request String here for sending to SOA
        	XMLRequestBody = BG_XMLUtility.CreateEntitlementRequest(VertuAcc, Entitlement, Bodyheader); 
            System.debug('Create Entitlement Request body is:-------------------------->'+XMLRequestBody);
            
            //If the Request creation was successful 
            If(XMLRequestBody != Null)
        	{
        		res = CallOutInterface.MaintainCustomerInterface(XMLRequestBody, authorizationHeader);
        	}
            
            if(res.getStatusCode() == 200 && res.getBody() != NULL)
            	{
                	//Parse the Xml response here using the appropriate method 
                 	CreateHandsetResponse = BG_XMLUtility.ParseCustomerUpdateResponse(res.getBody());
                    System.debug('Create Entitlement acknowledgement in WSO_SOA_HRH class is------------------------------->'+CreateHandsetResponse);
                    response = System.Label.Entitlement_request_success;
              	}
            
            //If the parsing of response was successful
            If(CreateHandsetResponse != NULL)
            {	   
            	System.debug('Status of the response for create Entitlements:------------------------->'+CreateHandsetResponse.Acknowledgement.Status);
            	//Create a Request Log for the request
             	SOARequest = BG_RequestLogUtils.CreateSOALog(VertuAcc.Account_Name__c, VertuAcc.id, (CreateHandsetResponse.RequestID != NULL)?CreateHandsetResponse.RequestID:NULL, VertuAcc.VREG_ID_Vertu_Account__c, 
                                                                 CreateHandsetResponse.Acknowledgement.Status, CreateHandsetResponse.Acknowledgement.Message, ServiceName,AddEntitlementEndPoint);
        	}
        }
        Catch(CalloutException ex)
        {
            System.debug('An Exception Occured while calling web services: -------------------------------------->>>>>>>'+ex.getMessage()+'Line:'+ex.getLineNumber());
            SOARequest = BG_RequestLogUtils.CreateSOALog(VertuAcc.Account_Name__c, VertuAcc.id, NULL, VertuAcc.VREG_ID_Vertu_Account__c, 
                                            RequestLogErrorStatus, ex.getMessage(), ServiceName, AddEntitlementEndPoint);
            response = System.label.Get_Entitlement_Failure;
        }
        Catch(Exception ex)   
        {
         	response = System.Label.Salesforce_Exception;
            System.debug('An Internal Exception Occured: -------------------------------------->>>>>>>'+ex.getMessage()+'Line:'+ex.getLineNumber());
            SOARequest = BG_RequestLogUtils.CreateSOALog(VertuAcc.Account_Name__c, VertuAcc.id, NULL, VertuAcc.VREG_ID_Vertu_Account__c, 
                                            RequestLogErrorStatus, ex.getMessage(), ServiceName, AddEntitlementEndPoint);
        }
        
        //Insert the log here
      	Status = BG_RequestLogUtils.InsertSOALog(SOARequest);
       	System.debug('SOA log insertion Status:------------------------->'+Status);
        
        If(Status.contains(System.Label.Request_Log_Error))
       	{
      		response += 'Following Issue Encountered: '+status;   
 		}
        
        Return response;   
    }
    
    /*
     * Utility method to create a Password Request Type from supplied detail type
	 */
    Public Static WS_SOA_MaintainCustomerType.PasswordResetRequestType CreatePasswordResetRequestType(String AccountId, String VertuAccId, String VregId, String UserName, String Password)
    {
     	//Declare the request and response type for Password reset here..
        WS_SOA_MaintainCustomerType.PasswordResetRequestType PasswordRequest = new WS_SOA_MaintainCustomerType.PasswordResetRequestType();
        PasswordRequest.AccountGUID = AccountId;
        PasswordRequest.VertuAccountGUID = VertuAccId;
        PasswordRequest.VregID = VregId;
        PasswordRequest.UserName = UserName;
        PasswordRequest.Password = Password;
        
        return PasswordRequest;
    }
    
    /*
     * Utility method to set parameters for Web service callout
     */
    
    Public static WSO_SOA_HTTPCustomerMaintainInterface SetInterface(String EndPointUrl, String Method, Integer Timeout1)
    {
        WSO_SOA_HTTPCustomerMaintainInterface CalloutInterface = new WSO_SOA_HTTPCustomerMaintainInterface();
        CallOutInterface.Endpoint = EndpointUrl;
        System.debug('Endpoint is: ----------------------------------->>>>'+CallOutInterface.Endpoint);
        CallOutInterface.CalloutMethod = Method;
        CallOutInterface.Timeout = Timeout1;
        
        return CalloutInterface;
    }

}