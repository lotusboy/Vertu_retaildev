/*************************************************
BG_XMLUtility
Test Class:

*Class for creating xml request and also parsing xml to object form
*from an xml response. This was developed for REST based HTTP request
*as SOAP call out was decomissioned because of XML name space issue
*
*
Author: Mahfuz Choudhury
Created Date: 04/07/2014

**************************************************/
public class BG_XMLUtility {
    //Namespace definitions for xml requests and responses 
    public static final String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
    public static final String xsi_ns = 'http://www.w3.org/2001/XMLSchema-instance';
    public static final String Head_ns = 'http://services.vertu.com/schema/common/header/v01/Header';
    public static final String mainbody_ns = 'http://services.vertu.com/schema/bs/customer/v01/MaintainCustomer';
    public static final String Customer_ns = 'http://services.vertu.com/schema/common/customer/v01/Customer';
    public static final String Handset_ns = 'http://services.vertu.com/schema/common/handset/v01/Handset';
    public static final String Acknowledgement_ns = 'http://services.vertu.com/schema/common/acknowledgement/v01/Acknowledgement';
    public static final String MaintainHandset_ns = 'http://services.vertu.com/schema/bs/handset/v01/MaintainHandset';
    
    //Name for Request and Response Types so that Namespaces can dynamically be rendered
    Public Static String CustomerUpdateRequest = 'Customer_Update_Request';
    Public Static String HandsetVerificationRequest = 'Handset_Verification_Request';
    
    Public Static Map<String, String> ResponseMap = new Map<String, String>();
    
    
    /*
     *Method to create customer update request based on the data supplied and using DOM class 
     */
    public Static String CreateCustomerUpdateRequest(WS_SOA_CustomerType.CustomerType SOACustomer, WS_SOA_HandsetDetail.Handset Handset, WS_SOA_HeaderInfo.Header header)
    {
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        // Create the request envelope
        DOM.Document doc = new DOM.Document();
        
        dom.XmlNode UpdateCustomerRequestnode = doc.createRootElement(SchemaInfo.UpdateCusRequestParentNode, null, null);
        
        /*The following section was commented out as SOA team changed the request string for the
         * web services as they were facing issues with Namespaces. But this was not completely removed as
         * they kept changing the XML structure as just incase the went back to their original structure.
         * 
         * 
        //Create the envelope for the request String here
        dom.XmlNode envelope = EnvelopeCreator(doc, CustomerUpdateRequest);
        
        envelope.setAttributeNS('schemaLocation', soapNS, xsi, null);*/
        
        //Build the header section of the request XML here....
        dom.XmlNode head = BuildRequestHeader(UpdateCustomerRequestnode, header);   
        
        /*Start of the body section of the request XML
        dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        
            //Start of the update customer request node here
            dom.XmlNode UpdateCustomerRequestnode = body.addChildElement('UpdateCustomerRequest',mainbody_ns, 'main');*/
                
                //Create the Customer Node for the request here
                dom.XmlNode customernode =  CreateCustomerNode(UpdateCustomerRequestnode, SOACustomer, SchemaInfo);
        
                //Handset list node goes here..
                dom.XmlNode handsetlistnode = UpdateCustomerRequestnode.addChildElement(SchemaInfo.HandsetListNode, null, null);
        			//SOA requires empty nodes to be sent
        			dom.XmlNode handsetTypenode = handsetlistnode.addChildElement(SchemaInfo.HandsetTypeNode, null, null);
        
        System.debug('Customer Update request String is: ---------------------------->>>>'+doc.toXmlString());
        
        return doc.toXmlString();
    }
    
    /*
     *The following method parse the xml response for customer update to Salesforce format
     */
    Public static WS_SOA_MaintainCustomerType.UpdateCustomerResponseType ParseCustomerUpdateResponse(String XmlResponse)
    {
        //Initialize the return types here...
        WS_SOA_MaintainCustomerType.UpdateCustomerResponseType SOAResponse = new WS_SOA_MaintainCustomerType.UpdateCustomerResponseType();
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        //Map<String, String> UpdateCustomerResponseMap = new Map<String, String>();
        
        //Initialize the DOM class for parsing the response and 
        Dom.Document doc = new Dom.Document();
        doc.load(XmlResponse);

        //Get the root element for the response
        dom.XmlNode xroot = doc.getrootelement();
            
            //Parse Customer Update node info here
            SOAResponse.RequestID = ParseInfofromTextNode(xroot).get(SchemaInfo.RequestIDNode);
            SOAResponse.AccountGUID = ParseInfofromTextNode(xroot).get(SchemaInfo.AccGUIDNode);
            SOAResponse.VregID = ParseInfofromTextNode(xroot).get(SchemaInfo.VregIDNode);
            SOAResponse.VertuAccountGUID = ParseInfofromTextNode(xroot).get(SchemaInfo.VAccGUIDNode);
            System.debug('SOAResponse.RequestID for customer update is--------------------------->'+SOAResponse.RequestID);

        //Get the Acknowledgement here..
        SOAResponse.Acknowledgement = GetAcknowledgement(xroot); 
        System.debug('SOAResponse from Parser Method is: --------------------------->>>>>>>>>>>>>>'+SOAResponse);
        
        return SOAResponse;
    }
    
    /*
     *Method to create Handset Verification request based on the data supplied and using DOM class 
     */
    public Static String CreateHandsetVerificationRequest(String IMEI, String VSN, WS_SOA_HeaderInfo.Header header)
    {
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        // Create the request envelope
        DOM.Document doc = new DOM.Document();
        
        dom.XmlNode GetHandsetDetailsRequestnode = doc.createRootElement(SchemaInfo.HandsetDetailRequestnodeName, null, null);       
        
        /*The following section was commented out as SOA team changed the request string for the
         * web services as they were facing issues with Namespaces. But this was not completely removed as
         * they kept changing the XML structure as just incase the went back to their original structure.
         * 
         * Create the envelope for the request String here
        dom.XmlNode envelope = EnvelopeCreator(doc,HandsetVerificationRequest);
        
        //envelope.setAttributeNS('schemaLocation', soapNS, xsi, null);*/
        
        //Build the header section of the request XML here....
        dom.XmlNode head = BuildRequestHeader(GetHandsetDetailsRequestnode, header);    
        
        /*Start of the body section of the request XML
        //dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        
            //Start of the Handset Details node under body
            dom.XmlNode HandsetDetailRequestnode = body.addChildElement(SchemaInfo.HandsetDetailRequestnodeName, null, null);*/
                
                //Start of the IMEI and VSN details node...
                dom.XmlNode IMEIRequestNode = CreateTextNode(GetHandsetDetailsRequestnode, SchemaInfo.HandsetDetailIMEINodeName, null, null, IMEI);  
                dom.XmlNode VSNRequestNode = CreateTextNode(GetHandsetDetailsRequestnode, SchemaInfo.VSNNodeName, null, null, VSN);  
        
        System.debug('Handset Verification request String is: ---------------------------->>>>'+doc.toXmlString());
        
        return doc.toXmlString();   
    }
    
    /*
     *Method to parse Handset Verification response based on the data supplied and using DOM parser
     */
    
    Public static WS_SOA_MaintainCustomerType.HandsetVerificationResponseType HandsetVerificationResponse(String XMLResponse)
    {
        //Declare an instance of the response type here which will be returned
        //Response is the parent class for Handsetresponsetype which contains Handset and Acknowledgement
        WS_SOA_MaintainCustomerType.HandsetVerificationResponseType Response = new WS_SOA_MaintainCustomerType.HandsetVerificationResponseType();
        WS_SOA_HandsetDetail.HandsetType ResponseHandset = new WS_SOA_HandsetDetail.HandsetType();
        
        //Initialize the schemaInfo class for node names
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        //Initialize the DOM class for parsing the response and load the response 
        Dom.Document doc = new Dom.Document();
        doc.load(XmlResponse);
        
        //Get the root element from the response
        dom.XmlNode xroot = doc.getrootelement();
        dom.XmlNode HandsetNode;
            
            //Get the handset Node here..
        if(CheckNodeStatus(xroot))
        {
            HandsetNode = xroot.getChildElement(SchemaInfo.HandsetNode, null);
        } 
            
        
            /*Get the body element from the response
            dom.XmlNode BodyNode = xroot.getChildElement('Body', soapNS);
            System.debug('Body is: ---------------->>>'+bodyNode);

                //Get the handset detail node here...
                dom.XmlNode HandsetDetailNode = BodyNode.getChildElement('GetHandsetDetailsResponse', MaintainHandset_ns);
                String ns = HandsetDetailNode.getnamespace();
                System.debug('handsetdetails node is: ----------------'+HandsetDetailNode);
                    
                    //Get the Handset node here...
                    dom.XmlNode handset = HandsetDetailNode.getChildElement('Handset', MaintainHandset_ns);
                    System.debug('handset node is: ----------------'+handset);*/
                
                    //Get the text from nodes containing actual data
                    ResponseHandset = GetHandset(HandsetNode, SchemaInfo);
        			
        			//The following section remove some handset information from the response as register handset service
        			//requires those information to be removed
        			ResponseHandset.TypeDesignator = NULL;
        			ResponseHandset.TypeDescription = NULL;
            		ResponseHandset.TypeName = NULL;
        			ResponseHandset.FirstTimeRegistration = NULL;
                    
                    //Get the services node here by passing the Handsetlist node
                    if(CheckNodeStatus(HandsetNode))
                    {
                        //populate HandsetNode with direct response as we can send handset node as it is for Create customer call out
                        //Response.HandsetNode = HandsetNode;
                        //System.debug('HandsetNode in Response is--------------------->'+Response.HandsetNode);
                        
                        dom.XmlNode ServiceListNode = HandsetNode.getChildElement(SchemaInfo.HandsetResServiceList, null);
                        ResponseHandset.ServicesList = GetServiceDetails(ServiceListNode);
                    }
                    
                    //Build the response here...
                    Response.Handset = ResponseHandset;
                    Response.Acknowledgement = GetAcknowledgement(xroot);               
        
        return Response;
    }
    
    /*
     *Method to create Customer Create request based on the data supplied and using DOM class 
     */
    public static String CreateCustomerCreateRequest(WS_SOA_CustomerType.CustomerType SOACustomer, WS_SOA_MaintainCustomerType.HandsetVerificationResponseType Handset, WS_SOA_HeaderInfo.Header header)
    {
        //Initialize the schemaInfo class for node names
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        // Create the request envelope
        DOM.Document doc = new DOM.Document();
        dom.XmlNode CreateCustomerRequestnode = doc.createRootElement(SchemaInfo.CreateCusRequestParentNode, null, null);
        
            //Build the header section of the request XML here....
            dom.XmlNode head = BuildRequestHeader(CreateCustomerRequestnode, header);
        
            //Create the Customer Node for the request here
            dom.XmlNode customernode =  CreateCustomerNode(CreateCustomerRequestnode, SOACustomer, SchemaInfo);
            
            //Create a handset node for the request here if the user has opted in for the services..
            dom.XmlNode HandsetNode = CreateHandsetNode(CreateCustomerRequestnode, Handset, SchemaInfo);
        
        return doc.toXmlString();
    }
    
    /*
     * Utility method to parse customer create response
     */
    Public static WS_SOA_MaintainCustomerType.CreateCustomerResponseType ParseCreateCustomerResponse(String XmlResponse)
    {
        WS_SOA_MaintainCustomerType.CreateCustomerResponseType response = new WS_SOA_MaintainCustomerType.CreateCustomerResponseType();
        
        //Initialize the schemaInfo class for node names
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        //Initialize the DOM class for parsing the response and load the response 
        Dom.Document doc = new Dom.Document();
        doc.load(XmlResponse);
        
        //Get the root element from the response
        dom.XmlNode xroot = doc.getrootelement();
        
        //Parse the responses into response object here..
        response.AccountGUID = ParseInfofromTextNode(xroot).get(SchemaInfo.AccGUIDNode);
        response.RequestID = ParseInfofromTextNode(xroot).get(SchemaInfo.RequestIDNode);
        response.Acknowledgement = GetAcknowledgement(xroot);
        
        return response;
    }
    
    /*
     * Utility method to create RegisterHandset Request 
	 */
    public static String HandsetRegistrationRequest(WS_SOA_CustomerType.CustomerType SOACustomer, WS_SOA_MaintainCustomerType.HandsetVerificationResponseType HandsetReg, WS_SOA_HeaderInfo.Header header)
    {
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        //Empty the VSN node here
        //HandsetReg.Handset.SerialNumber = NULL;
        
        // Create the request envelope
        DOM.Document doc = new DOM.Document();
        dom.XmlNode CreateHandsetRegisterNode = doc.createRootElement(SchemaInfo.RegisterHandsetRequestNode, null, null);
        
        	//Build the header section of the request XML here....
        	dom.XmlNode head = BuildRequestHeader(CreateHandsetRegisterNode, header);
        
        	//Create a handset node for the request here if the user has opted in for the services..
        	dom.XmlNode HandsetNode = CreateHandsetNode(CreateHandsetRegisterNode, HandsetReg, SchemaInfo);
        	
        	//Add AccoutGUID and VertuAccountGUID below for the request
            dom.XmlNode AccountIdNode = CreateTextNode(CreateHandsetRegisterNode, SchemaInfo.AccGUIDNode, null, null,SOACustomer.AccountGUID);
			dom.XmlNode VertuAccNode = CreateTextNode(CreateHandsetRegisterNode, SchemaInfo.VAccGUIDNode, null, null,SOACustomer.VertuAccountGUID); 
        
        Return doc.toXmlString();
    }
    
    /*
     * Utility method to create Handset DeRegistration Request based on the information suplied from the calling method
	 */
    public static String CreateDeRegistrationRequest(Handset__c Handset, WS_SOA_HeaderInfo.Header Header)
    {
     	//type to provide the node names for xml request string
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        //Create a Handset type as Handset request creation XML method takes this type as argument
        WS_SOA_MaintainCustomerType.HandsetVerificationResponseType HandsetParent = new WS_SOA_MaintainCustomerType.HandsetVerificationResponseType();
        WS_SOA_HandsetDetail.HandsetType SOAHandset = new WS_SOA_HandsetDetail.HandsetType();
        SOAHandset.IMEI = Handset.IMEI__c;
        SOAHandset.VregID = Handset.Vreg_ID_Handset__c;
        SOAHandset.SerialNumber = Handset.VSN__c;
        HandsetParent.Handset = SOAHandset;
        
        // Create the request envelope
        DOM.Document doc = new DOM.Document();
        dom.XmlNode CreateHandsetDeRegisterNode = doc.createRootElement(SchemaInfo.DeRegisterHandsetRequestNode, null, null);
        
        	//Build the header section of the request XML here....
        	dom.XmlNode head = BuildRequestHeader(CreateHandsetDeRegisterNode, Header);
        	
        	//Create the handset node here..
        	dom.XmlNode HandsetNode = CreateHandsetNode(CreateHandsetDeRegisterNode, HandsetParent, SchemaInfo);
        
        	dom.XmlNode AccountIdNode = CreateTextNode(CreateHandsetDeRegisterNode, SchemaInfo.AccGUIDNode, null, null,Handset.Account_Name__c);
			dom.XmlNode VertuAccNode = CreateTextNode(CreateHandsetDeRegisterNode, SchemaInfo.VAccGUIDNode, null, null,Handset.Vertu_Account__c); 
        
        return doc.toXmlString();
    }
    
    /*
     * Utility method to create a Password reset request xml string 
	 */
    Public Static String CreatePasswordResetRequest(WS_SOA_MaintainCustomerType.PasswordResetRequestType PasswordRequest, WS_SOA_HeaderInfo.Header header)
    {
     	//type to provide the node names for xml request string
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        // Create the request envelope
        DOM.Document doc = new DOM.Document();
        dom.XmlNode CreatePasswordResetNode = doc.createRootElement(SchemaInfo.PasswordResetRequestNode, null, null);
        
        	//Build the header section of the request XML here....
        	dom.XmlNode head = BuildRequestHeader(CreatePasswordResetNode, Header);
        
        	//Add all the information nodes here..
        	dom.XmlNode AccountIdNode = CreateTextNode(CreatePasswordResetNode, SchemaInfo.AccGUIDNode, null, null, PasswordRequest.AccountGUID);
			dom.XmlNode VertuAccNode = CreateTextNode(CreatePasswordResetNode, SchemaInfo.VAccGUIDNode, null, null, PasswordRequest.VertuAccountGUID);
        	dom.XmlNode VregIdNode = CreateTextNode(CreatePasswordResetNode, SchemaInfo.VregIDNode, null, null, PasswordRequest.VregID);
        	dom.XmlNode UserNameNode = CreateTextNode(CreatePasswordResetNode, SchemaInfo.UserName1, null, null, PasswordRequest.UserName);
        	dom.XmlNode PasswordNode = CreateTextNode(CreatePasswordResetNode, SchemaInfo.Password, null, null, PasswordRequest.Password);
        
        return doc.toXmlString();
    }
    
    /*
     * Utility Method to create Get Entitlement request... 
	 */
    Public static String CreateGetEntitlementRequest(String VregId, WS_SOA_HeaderInfo.Header header)
    {
     	//type to provide the node names for xml request string
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        // Create the request envelope
        DOM.Document doc = new DOM.Document();
        dom.XmlNode CreateGetEntitlementNode = doc.createRootElement(SchemaInfo.GetEntitlementRequestNode, null, null);
        
        	//Build the header section of the request XML here....
        	dom.XmlNode head = BuildRequestHeader(CreateGetEntitlementNode, Header);
        	dom.XmlNode VregIdNode = CreateTextNode(CreateGetEntitlementNode, SchemaInfo.VregIDNode, null, null, VregId);
        
        Return doc.toXmlString();
    }
    
    /*
     * Utility method to Parse Get Entitlements Response from SOA
	 */
    Public static WS_SOA_ServiceInfo.GetEntitlementResponse ParseGetEntitlementRequest(String XmlResponse)
    {
     	//Return type for Entitlements
        WS_SOA_ServiceInfo.GetEntitlementResponse Entitlements = new WS_SOA_ServiceInfo.GetEntitlementResponse();
        
        //Initialize the schemaInfo class for node names
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        //Initialize the DOM class for parsing the response and load the response 
        Dom.Document doc = new Dom.Document();
        doc.load(XmlResponse);
        
        //Get the root element from the response
        dom.XmlNode xroot = doc.getrootelement();
        
        	//Get the Entitlementfact Node and serviceList node name before processing
        	dom.XmlNode EntitlementListNode = xroot.getChildElement(SchemaInfo.EntitlementListNode, null);
        	dom.XmlNode EntitlementFactListNode = xroot.getChildElement(SchemaInfo.EntitlementFactListNode, null);
        	
        	//Parse the entitlementlist and entitlementfacts using utility method
        	Entitlements.EntList = GetEntitlements(EntitlementListNode, SchemaInfo);
        	Entitlements.EntFacts = GetEntitlements(EntitlementFactListNode, SchemaInfo);
        	Entitlements.Acknowledgement = GetAcknowledgement(xroot);
        	    
        Return Entitlements;
    }
    
    /*
     * Utility method to Get Entiltements for both Entitlementlist and EntitlementFactlist
	 */
    
    Public Static List<Entitlement__c> GetEntitlements(dom.XmlNode xroot,  BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo)
    {
     	//Return the EntitlementList
        //List<WS_SOA_ServiceInfo.Entitlement> EntFacts = new List<WS_SOA_ServiceInfo.Entitlement>();
        List<Entitlement__c> EntFacts = new List<Entitlement__c>();
        
        if(CheckNodeStatus(xroot))
       {
            for(dom.XmlNode EntitlementNode : xroot.getChildElements())
            {
                System.debug('Entitlement Node Name-----------------'+EntitlementNode.getName());
                
                if(CheckNodeStatus(EntitlementNode))
                {
                    //WS_SOA_ServiceInfo.Entitlement EntFact = new WS_SOA_ServiceInfo.Entitlement();
                    Entitlement__c EntFact = new Entitlement__c();
                    
                    for(dom.XmlNode EntitlementChild : EntitlementNode.getChildElements())
                    {
                        System.debug('Entitlement Node Name is:----------------->'+EntitlementChild.getName());
                        
                        //If the node is service Level Node
                        if(EntitlementChild.getNodeType() == DOM.XMLNodeType.ELEMENT && EntitlementChild.getName() == SchemaInfo.LevelNode)
                        {
                            if (EntitlementChild.getText().trim() != '')
                            {
                                EntFact.Level__c = EntitlementChild.getText().trim();   
                            }   
                        }
                        //If the node is Duration Node
                        else if(EntitlementChild.getNodeType() == DOM.XMLNodeType.ELEMENT && EntitlementChild.getName() == SchemaInfo.DurationNode)
                        {
                            if (EntitlementChild.getText().trim() != '')
                            {
                                EntFact.Duration__c = EntitlementChild.getText().trim(); 
                            }   
                        }
                        
                        //If the node is startDate Node
                        else if(EntitlementChild.getNodeType() == DOM.XMLNodeType.ELEMENT && EntitlementChild.getName() == SchemaInfo.StartDateNode)
                        {
                            if (EntitlementChild.getText().trim() != '')
                            {
                                //EntFact.startDate = FormatSOAXmlDateString(EntitlementChild.getText().trim()); 
                                EntFact.start_Date__c = FormatSOAXmlDateString(EntitlementChild.getText().trim()); 
                            }   
                        }
                        
                        //If the node is EndDate Node
                        else if(EntitlementChild.getNodeType() == DOM.XMLNodeType.ELEMENT && EntitlementChild.getName() == SchemaInfo.EndDateNode)
                        {
                            if (EntitlementChild.getText().trim() != '')
                            {
                                EntFact.end_Date__c = FormatSOAXmlDateString(EntitlementChild.getText().trim()); 
                            }   
                        }
                        
                        //If the node is ReasonNode Node
                        else if(EntitlementChild.getNodeType() == DOM.XMLNodeType.ELEMENT && EntitlementChild.getName() == SchemaInfo.ReasonNode)
                        {
                            if (EntitlementChild.getText().trim() != '')
                            {
                                EntFact.Reason__c = EntitlementChild.getText().trim(); 
                            }   
                        }
                        
                        //If the node is AddedDateNode Node
                        else if(EntitlementChild.getNodeType() == DOM.XMLNodeType.ELEMENT && EntitlementChild.getName() == SchemaInfo.AddedDateNode)
                        {
                            if (EntitlementChild.getText().trim() != '')
                            {
                                EntFact.Added_Date__c = FormatSOAXmlDateString(EntitlementChild.getText().trim()); 
                            }   
                        }
                        
                        //If the node is NotesNode Node
                        else if(EntitlementChild.getNodeType() == DOM.XMLNodeType.ELEMENT && EntitlementChild.getName() == SchemaInfo.NotesNode)
                        {
                            if (EntitlementChild.getText().trim() != '')
                            {
                                EntFact.Notes__c = EntitlementChild.getText().trim(); 
                            }   
                        }
                        
                        //If the node is DurationLeftNode Node
                        else if(EntitlementChild.getNodeType() == DOM.XMLNodeType.ELEMENT && EntitlementChild.getName() == SchemaInfo.DurationLeftNode)
                        {
                            if (EntitlementChild.getText().trim() != '')
                            {
                                EntFact.Duration_Left__c = EntitlementChild.getText().trim(); 
                            }   
                        }
                    }
                    System.debug('Entitlement Facts are-----------'+EntFact);
                    EntFacts.add(EntFact);
                }
            }
        }
        
        Return EntFacts;  
    }
    
    /*
     * Method to Create an Entitlement xml request string
	 */
    Public static String CreateEntitlementRequest(Vertu_Account__c VertuAcc, Entitlement__c Entitlement, WS_SOA_HeaderInfo.Header header)
    {
     	//type to provide the node names for xml request string
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        // Create the request envelope
        DOM.Document doc = new DOM.Document();
        dom.XmlNode CreateEntitlementRequestNode = doc.createRootElement(SchemaInfo.CreateEntitlementRequestNode, null, null);
        
        	//Build the header section of the request XML here....
        	dom.XmlNode head = BuildRequestHeader(CreateEntitlementRequestNode, header);
        	dom.XmlNode VregIdNode = CreateTextNode(CreateEntitlementRequestNode, SchemaInfo.VregIDNode, null, null, VertuAcc.VREG_ID_Vertu_Account__c);
        	dom.XmlNode AccountIdNode = CreateTextNode(CreateEntitlementRequestNode, SchemaInfo.AccGUIDNode, null, null, VertuAcc.Account_Name__c);
			dom.XmlNode VertuAccNode = CreateTextNode(CreateEntitlementRequestNode, SchemaInfo.VAccGUIDNode, null, null, VertuAcc.id);
        	dom.XmlNode EntitlementNode = CreateEntitlementNode(CreateEntitlementRequestNode, Entitlement, SchemaInfo);
        
        Return doc.toXmlString();
    }
    
    /*
     * Utility method to Parse SOA datetime field into a Salesforce Date field
	 */
    Public Static Date FormatSOAXmlDateString(String SOADateString)
    {        
        Date SalesforceFormatDate;
        If(SOADateString != NULL)
        {
         	If(SOADateString.contains('T'))
        	{
         		SalesforceFormatDate = Date.valueOf(SOADateString.split('T')[0]);
                System.debug('Formatted date is : ------------------->'+ SalesforceFormatDate);
        	}  
        }
        
        Return SalesforceFormatDate;
    }
    
    /*
     * Utility method to form header for the request. Many requests have same header
     *  therefore this can be dynamically rendered in each request. 
     */
    Public static dom.XMLNode BuildRequestHeader(dom.XmlNode envelope, WS_SOA_HeaderInfo.Header header)
    {
        //Build the header section of the request XML here....
        dom.XmlNode head = envelope.addChildElement('Header', null, null);
            
            //Add the sub header here..
            //dom.XmlNode subhead = head.addChildElement('Header', null, null);
        
                //Add the header information here..
                dom.XmlNode userName = CreateTextNode(head,'UserName', null, null, header.UserName);
                dom.XmlNode Password = CreateTextNode(head,'Password', null, null, header.Password);
                dom.XmlNode SecurityToken = CreateTextNode(head,'SecurityToken', null, null, header.SecurityToken);
        
        System.debug('Header for the Request is :-------------------------------------------->>>'+head);
        
        return head;
       
    }
    
    /*
     * Utility method to set name space for the requests and responses
     */
    
    /*Public static Dom.XmlNode EnvelopeCreator(Dom.Document doc, String HandsetVreq)
    {   
        String Head_tag = 'head';
        String Body_tag = 'main';
        String Customer_tag = 'cus';
        String Handset_tag = 'han';
        
        dom.XmlNode Envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('xsi', xsi_ns);
        envelope.setNamespace(Head_tag, Head_ns);
        envelope.setNamespace(Body_tag, mainbody_ns);
        
        if(HandsetVreq == CustomerUpdateRequest)
        {
            envelope.setNamespace(Customer_tag, Customer_ns);
            envelope.setNamespace(Handset_tag, Handset_ns);   
        }
        
        return Envelope;
        
    }*/
    
    /*
     * The following utility method Add a text node for a DOM request providing Branch, Node Name,
     * NameSpace, NameSpace Prefix, and Value is provided from the calling method  
     */
    
    Public static dom.XmlNode CreateTextNode(dom.XmlNode Branch, String NodeName, String NameSpace, String NS_Prefix, String Value)
    {
        dom.XmlNode RequestTextNode;
        If(Value != NULL && Value != '')
        {
            RequestTextNode = Branch.addChildElement(NodeName,NameSpace,NS_Prefix). 
                                addTextNode(Value.trim()); 
        }
        return RequestTextNode;
    }
    
    /* Utility method to retrieve and create the Customer, Handset and Acknowledgement from the response
     * This is done in different method since all the responses has same customer, Handset 
     * Acknowledgent node  
     */
    public static dom.XmlNode CreateCustomerNode(dom.XmlNode xroot, WS_SOA_CustomerType.CustomerType SOACustomer, BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo)
    {   
        //Start of the customer node here
        dom.XmlNode customernode =  xroot.addChildElement(SchemaInfo.CustomerNode, null, null);
        
        //The following fields needs to be nested under customer node (Account and Vertu Account)
        dom.XmlNode personAccIdNode = CreateTextNode(customernode, SchemaInfo.AccGUIDNode, null, null, SOACustomer.AccountGUID);  
        dom.XmlNode VertuAccountGUIDNode = CreateTextNode(customernode, SchemaInfo.VAccGUIDNode, null, null, SOACustomer.VertuAccountGUID);    
        dom.XmlNode VregIDNode = CreateTextNode(customernode, SchemaInfo.VregIDNode, null, null, SOACustomer.VregID);    
        dom.XmlNode PersonFirstNameNode = CreateTextNode(customernode, SchemaInfo.CusFirstName, null, null, SOACustomer.FirstName);
        dom.XmlNode PersonLastNameNode = CreateTextNode(customernode, SchemaInfo.CusLastName, null, null, SOACustomer.LastName);
        dom.XmlNode GenderNode = CreateTextNode(customernode, SchemaInfo.CusGender, null, null, SOACustomer.Gender);
        dom.XmlNode SalutationNode = CreateTextNode(customernode, SchemaInfo.Salutation, null, null, SOACustomer.Salutation);
        dom.XmlNode BirthDateNode = CreateTextNode(customernode, SchemaInfo.BirthDate, null, null, SOACustomer.BirthDate);
        dom.XmlNode VertuSpokenLanguageNode = CreateTextNode(customernode, SchemaInfo.VertuSpokenLanguage, null, null, SOACustomer.VertuSpokenLanguage);
        dom.XmlNode VertuWrittenLanguageNode = CreateTextNode(customernode, SchemaInfo.VertuWrittenLanguage, null, null, SOACustomer.VertuWrittenLanguage);
        dom.XmlNode PrimaryEmailNode = CreateTextNode(customernode, SchemaInfo.PrimaryEmail, null, null, SOACustomer.PrimaryEmail);
        dom.XmlNode SecondaryEmailNode = CreateTextNode(customernode, SchemaInfo.SecondaryEmail, null, null, SOACustomer.SecondaryEmail);
        dom.XmlNode ThirdEmailNode = CreateTextNode(customernode, SchemaInfo.ThirdEmail, null, null, SOACustomer.ThirdEmail);
        dom.XmlNode FourthEmailNode = CreateTextNode(customernode, SchemaInfo.FourthEmail, null, null, SOACustomer.FourthEmail);
        dom.XmlNode FifthEmailNode = CreateTextNode(customernode, SchemaInfo.FifthEmail, null, null, SOACustomer.FifthEmail);
        dom.XmlNode MobileNode = CreateTextNode(customernode, SchemaInfo.Mobile, null, null, SOACustomer.Mobile);
        dom.XmlNode HomePhoneNode = CreateTextNode(customernode, SchemaInfo.HomePhone, null, null, SOACustomer.HomePhone);
        dom.XmlNode OtherPhoneNode = CreateTextNode(customernode, SchemaInfo.OtherPhone, null, null, SOACustomer.OtherPhone);
        dom.XmlNode MailingStreetNode = CreateTextNode(customernode, SchemaInfo.MailingStreet, null, null, SOACustomer.MailingStreet);
        dom.XmlNode MailingCountryNode = CreateTextNode(customernode, SchemaInfo.MailingCountry, null, null, SOACustomer.MailingCountry);
        dom.XmlNode MailingPostCodeNode = CreateTextNode(customernode, SchemaInfo.MailingPostCode, null, null, SOACustomer.MailingPostCode);
        dom.XmlNode OtherStreetNode = CreateTextNode(customernode, SchemaInfo.OtherStreet, null, null, SOACustomer.OtherStreet);
        dom.XmlNode OtherCountryNode = CreateTextNode(customernode, SchemaInfo.OtherCountry, null, null, SOACustomer.OtherCountry);
        dom.XmlNode OtherPostCodeNode = CreateTextNode(customernode, SchemaInfo.OtherPostCode, null, null, SOACustomer.OtherPostCode);
        dom.XmlNode MailMeNode = CreateTextNode(customernode, SchemaInfo.MailMe, null, null, SOACustomer.MailMe);
        dom.XmlNode SMSMeNode = CreateTextNode(customernode, SchemaInfo.SMSMe, null, null, SOACustomer.SMSMe);
        dom.XmlNode PhoneMeNode = CreateTextNode(customernode, SchemaInfo.PhoneMe, null, null, SOACustomer.PhoneMe);
        dom.XmlNode EmailMeNode = CreateTextNode(customernode, SchemaInfo.EmailMe, null, null, SOACustomer.EmailMe);
        dom.XmlNode PassionFineDiningNode = CreateTextNode(customernode, SchemaInfo.PassionFineDining, null, null, SOACustomer.PassionFineDining);
        dom.XmlNode PassionChampagneFineWineAndSpiritsNode = CreateTextNode(customernode, SchemaInfo.PassionChampagneFineWineAndSpirits, null, null, SOACustomer.PassionChampagneFineWineAndSpirits);
        dom.XmlNode PassionVIPEntertainmentNode = CreateTextNode(customernode, SchemaInfo.PassionVIPEntertainment, null, null, SOACustomer.PassionVIPEntertainment);
        dom.XmlNode PassionFashionAndStyleNode = CreateTextNode(customernode, SchemaInfo.PassionFashionAndStyle, null, null, SOACustomer.PassionFashionAndStyle);
        dom.XmlNode PassionEliteWorldSportNode = CreateTextNode(customernode, SchemaInfo.PassionEliteWorldSport, null, null, SOACustomer.PassionEliteWorldSport);
        dom.XmlNode PassionBusinessIntelligenceNode = CreateTextNode(customernode, SchemaInfo.PassionBusinessIntelligence, null, null, SOACustomer.PassionBusinessIntelligence);
        dom.XmlNode PassionTheArtsNode = CreateTextNode(customernode, SchemaInfo.PassionTheArts, null, null, SOACustomer.PassionTheArts);
        dom.XmlNode PassionTechnologyandGadgetsNode = CreateTextNode(customernode, SchemaInfo.PassionTechnologyandGadgets, null, null, SOACustomer.PassionTechnologyandGadgets);
        dom.XmlNode PassionTravelNode = CreateTextNode(customernode, SchemaInfo.PassionTravel, null, null, SOACustomer.PassionTravel);
        dom.XmlNode SecurityQuestionNode = CreateTextNode(customernode, SchemaInfo.SecurityQuestion, null, null, SOACustomer.SecurityQuestion);
        dom.XmlNode SecurityAnswerNode = CreateTextNode(customernode, SchemaInfo.SecurityAnswer, null, null, SOACustomer.SecurityAnswer);
        dom.XmlNode UsernameNode = CreateTextNode(customernode, SchemaInfo.Username, null, null, SOACustomer.Username);
        dom.XmlNode PasswordNode = CreateTextNode(customernode, SchemaInfo.Password, null, null, SOACustomer.Password);
        dom.XmlNode CountryOfResidenceNode = CreateTextNode(customernode, SchemaInfo.CountryOfResidence, null, null, SOACustomer.CountryOfResidence);
        dom.XmlNode NationalityCodeNode = CreateTextNode(customernode, SchemaInfo.NationalityCode, null, null, SOACustomer.NationalityCode);
        
        return customernode;
        
    }
    
    Public Static WS_SOA_HandsetDetail.HandsetType GetHandset(dom.XmlNode xroot, BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo)
    {
        WS_SOA_HandsetDetail.HandsetType ResponseHandset = new WS_SOA_HandsetDetail.HandsetType();
        ResponseHandset.TypeDesignator = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetTypeDesignator);
        ResponseHandset.TypeDescription = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetTypeDescription);
        ResponseHandset.PurchasePlace = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetPurchasePlace);
        ResponseHandset.VregID = ParseInfofromTextNode(xroot).get(SchemaInfo.VregIDNode);
        
        String RegDate;
        If(ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetRegistrationDate) != NULL)
        {
         	If(ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetRegistrationDate).contains('+'))
        	{
         		RegDate = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetRegistrationDate).split('\\+')[0]; 
                System.debug('RegDate : ------------------->'+ RegDate);
        	}
            else
        		RegDate = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetRegistrationDate);
        }
        
        //ResponseHandset.RegistrationDate = (RegDate != NULL) ? DateTime.Valueof(RegDate.trim()) : NULL;
        System.debug('Registration date in Xml parsing method is: ------------------->'+ ResponseHandset.PurchaseDate);
        
        ResponseHandset.TypeName = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetTypeName);
        
        String PurchaseD;
        If(ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetPurchaseDate) != NULL)
        {
         	If(ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetPurchaseDate).contains('+'))
        	{
         		PurchaseD = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetPurchaseDate).split('\\+')[0];
                System.debug('PurchaseD : ------------------->'+ PurchaseD);
        	}
        	else
            	PurchaseD = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetPurchaseDate);   
        }
            
        //ResponseHandset.PurchaseDate = (PurchaseD != NULL) ? Datetime.valueOf(PurchaseD.trim()) : NULL;
        System.debug('Purchase date Xml parsing method is: ------------------->'+ ResponseHandset.PurchaseDate);
        
        ResponseHandset.FirstTimeRegistration = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetFirstTimeRegistration);
        ResponseHandset.IMEI = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetDetailIMEINodeName);
        ResponseHandset.SerialNumber = ParseInfofromTextNode(xroot).get(SchemaInfo.HandsetSerialNumber);
        
        return ResponseHandset;
    }
    
    Public Static WS_SOA_MaintainCustomerAcknowledgement.AcknowledgementType GetAcknowledgement(dom.XmlNode xroot)
    {
        WS_SOA_MaintainCustomerAcknowledgement.AcknowledgementType Acknowledgement = new WS_SOA_MaintainCustomerAcknowledgement.AcknowledgementType();
        BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo = new BG_XMLUtility.BG_XMLUtilityHelper();
        
        //Get the children of Acknowledgement node
        //dom.XmlNode AcknowledgementNode = xroot.getChildElement(SchemaInfo.AckResNode, null);
                
            //Parse the Acknowledgement information here (Child of customer info)
            Acknowledgement.Status = ParseInfofromTextNode(xroot).get(SchemaInfo.AckStatusResNode);
            System.debug('Status is--------------------------->'+Acknowledgement.Status);
            Acknowledgement.Message = ParseInfofromTextNode(xroot).get(SchemaInfo.AckMsgResNode);
            Acknowledgement.Code = ParseInfofromTextNode(xroot).get(SchemaInfo.AckCodeResNode);
            Acknowledgement.MessageID = ParseInfofromTextNode(xroot).get(SchemaInfo.AckMsgIDResNode);
        
        return Acknowledgement;
    }
    
    //Use this method to create a Handset without service list
    Public static dom.XmlNode CreateHandsetNode(dom.XmlNode xroot, WS_SOA_MaintainCustomerType.HandsetVerificationResponseType Handset, BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo)
    {
        //Start of the handset node here
        dom.XmlNode HandsetNode =  xroot.addChildElement(SchemaInfo.HandsetNode, null, null);
        
            String RegistrationDate = Handset.Handset.RegistrationDate != NULL ? String.valueof(Handset.Handset.RegistrationDate) : '';
            String PurchaseDate = Handset.Handset.PurchaseDate != NULL ? String.valueof(Handset.Handset.PurchaseDate) : '';
            
            //Build Handset sub node here...
            dom.XmlNode TypeDesignatorNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetTypeDesignator, null, null, Handset.Handset.TypeDesignator);
            dom.XmlNode TypeDescriptionNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetTypeDescription, null, null, Handset.Handset.TypeDescription);
            dom.XmlNode PurchasePlaceNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetPurchasePlace, null, null, Handset.Handset.PurchasePlace);
            dom.XmlNode RegistrationDateNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetRegistrationDate, null, null, RegistrationDate);
            dom.XmlNode TypeNameNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetTypeName, null, null, Handset.Handset.TypeName);
            dom.XmlNode IMEINode = CreateTextNode(HandsetNode, SchemaInfo.HandsetDetailIMEINodeName, null, null, Handset.Handset.IMEI);
        	dom.XmlNode VSNNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetDetailVSNNodeName, null, null, Handset.Handset.SerialNumber);
        	dom.XmlNode VRegIdNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetVregIdNode, null, null, Handset.Handset.VregID);
        	dom.XmlNode OtherPurchasePlaceNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetOtherPurchasePlace, null, null, Handset.Handset.OtherPurchasePlace);
            dom.XmlNode PurchaseDateNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetPurchaseDate, null, null, PurchaseDate);
            dom.XmlNode FirstTimeRegistrationNode = CreateTextNode(HandsetNode, SchemaInfo.HandsetFirstTimeRegistration, null, null, Handset.Handset.FirstTimeRegistration);
        	
        	//The following portion Creates the services node for the XML request
        	dom.XmlNode ServicesNode = HandsetNode.addChildElement(SchemaInfo.HandsetResServiceList, NULL, NULL);
        
        	List<List<String>> Services = Handset.Handset.ServicesList;
        	
        	If(Services != NULL && Services.size() > 0)
            {
             	for(Integer i = 0; i<Services.size(); i++)
            	{
             		dom.XmlNode ServicesTypeNode = ServicesNode.addChildElement(SchemaInfo.HandsetServiceResType, NULL, NULL);
                	List<String> Temp = Services[i];
                	for(Integer j = 0; j <Temp.size(); j++)
                	{
                 		System.debug('Added value to Service Name:---------------------------------->'+Temp[j]);
                    	dom.XmlNode ServiceNameNode = CreateTextNode(ServicesTypeNode,SchemaInfo.HandsetServiceNameRes, NULL, NULL,Temp[j]);
                    
                	}
            	}   
            }
            
        return HandsetNode;
    }
    
    /*
     * Utility method to Add an Entitlement node..
	 */
    Public static dom.XmlNode CreateEntitlementNode(dom.XmlNode xroot, Entitlement__c Entitlement, BG_XMLUtility.BG_XMLUtilityHelper SchemaInfo)
    {
     	//Start of the Entitlement node here
        dom.XmlNode EntitlementNode =  xroot.addChildElement(SchemaInfo.EntitlementNode, null, null);
        
        String StartDate = Entitlement.Start_Date__c != NULL ? String.valueof(Entitlement.Start_Date__c) : '';
        
        	//Add Child nodes here..
        	dom.XmlNode LevelNode = CreateTextNode(EntitlementNode, SchemaInfo.LevelNode, null, null, Entitlement.Level__c);
        	dom.XmlNode DurationNode = CreateTextNode(EntitlementNode, SchemaInfo.DurationNode, null, null, Entitlement.Request_Duration__c);
        	dom.XmlNode StartDateNode = CreateTextNode(EntitlementNode, SchemaInfo.StartDateNode, null, null, StartDate);
        	dom.XmlNode ReasonNode = CreateTextNode(EntitlementNode, SchemaInfo.ReasonNode, null, null, Entitlement.Reason__c);
        	dom.XmlNode NotesNode = CreateTextNode(EntitlementNode, SchemaInfo.NotesNode, null, null, Entitlement.Notes__c);
        
        Return EntitlementNode;
    }
    
    //Utility method to parse service information from Handsetdetails response string
    public Static List<List<String>> GetServiceDetails(dom.XmlNode ServiceNode)
    {
        List<List<String>> HandsetServiceList = new List<List<String>>();
        
       if(CheckNodeStatus(ServiceNode))
       {
            for(dom.XmlNode ParentNode : ServiceNode.getChildElements())
            {
                String[] ServicesType = new String[]{};
                System.debug('servicesType-----------------'+ParentNode.getName());
                
                if(CheckNodeStatus(ParentNode))
                {
                    for(dom.XmlNode serviceName:ParentNode.getChildElements())
                    {
                        if(serviceName.getNodeType() == DOM.XMLNodeType.ELEMENT)
                        {
                            if (serviceName.getText().trim() != '')
                            {
                                ServicesType.add(serviceName.getText().trim());
                                System.debug('ServicesType are-----------'+ServicesType);   
                            }   
                        }
                    }   
                HandsetServiceList.add(ServicesType);
                System.debug(' HandsetServiceList are--------------'+ HandsetServiceList);   
                }
            }   
        }
        
        return HandsetServiceList;
    }
    
    /*
     * The following utility method parse the information from the TEXT node of an element 
     * and return the information to the calling method in String format providing root node
     * and child node name was passed
     */
    
    Public Static Map<String, String> ParseInfofromTextNode(dom.XmlNode xroot)
    {   
        //If the root has some child under it...
        if(CheckNodeStatus(xroot))
        {
            for(dom.XmlNode infoNode: xroot.getChildElements())
            {
                //Check the element node and containing node here
                if(infoNode.getNodeType() == DOM.XMLNodeType.ELEMENT) 
                {
                    String NodeName = infoNode.getName();
                    if (infoNode.getText().trim() != '')
                    {
                        ResponseMap.put(NodeName, infoNode.getText().trim());
                        System.debug('Information on Current node is :--------------------------->'+infoNode.getText().trim());
                    }  
                }
                if(infoNode != NULL)
                    ParseInfofromTextNode(infoNode);    
            }   
        }
        
        return ResponseMap;
    }
    
    /*Utility method to check if the node is not empty and has children 
     * under this node
     */
    
    Public Static Boolean CheckNodeStatus(dom.XmlNode node)
    {
        Boolean HasNode = false;
        
        if(node != NULL)
            {
                if(node.getChildElements().size() > 0)
                {
                    HasNode = true;
                    return Hasnode;
                } 
            }
        
        return HasNode;
    }
    
    /*The following class contains all the nodenames for requests and response xml
     * this will help us prevent hardcoding of node names into the method
     */
    
    public class BG_XMLUtilityHelper {
        //Common node for response goes here
        public string AckResNode = 'Acknowledgement';
        public string AckStatusResNode = 'Status';
        public string AckMsgResNode = 'Message';
        public string AckCodeResNode = 'Code';
        public string AckMsgIDResNode = 'MessageID';
        public string VregIDNode = 'VregID';
        
        //Node names for Customer Update Requests & Response
        public String UpdateCusRequestParentNode = 'UpdateCustomerRequest';
        public string CSUpdateResParentNode = 'com.vertu.services.schema.bs.customer.v01.maintaincustomer.UpdateCustomerResponseType';
        
        //Node Names for Customer Section
        public string CustomerNode = 'Customer';
        Public string AccGUIDNode = 'AccountGUID';
        public string RequestIDNode = 'RequestID';
        public string VAccGUIDNode = 'VertuAccountGUID';
        public string CusFirstName = 'FirstName';
        public string CusLastName = 'LastName';
        public string CusGender = 'Gender';
        public String Salutation = 'Salutation';
        public String BirthDate = 'BirthDate';
        public String VertuSpokenLanguage = 'VertuSpokenLanguage';
        public String VertuWrittenLanguage = 'VertuWrittenLanguage';
        public String PrimaryEmail = 'PrimaryEmail';
        public String SecondaryEmail = 'SecondaryEmail';
        public String ThirdEmail = 'ThirdEmail';
        public String FourthEmail = 'FourthEmail';
        public String FifthEmail = 'FifthEmail';
        public String Mobile = 'Mobile';
        public String HomePhone = 'HomePhone';
        public String OtherPhone = 'OtherPhone';
        public String MailingStreet = 'MailingStreet';
        public String MailingCountry = 'MailingCountry';
        public String MailingPostCode = 'MailingPostCode';
        public String OtherStreet = 'OtherStreet';
        public String OtherCountry = 'OtherCountry';
        public String OtherPostCode = 'OtherPostCode';
        public String MailMe = 'MailMe';
        public String SMSMe = 'SMSMe';
        public String PhoneMe = 'PhoneMe';
        public String EmailMe = 'EmailMe';
        public String PassionFineDining = 'PassionFineDining';
        public String PassionChampagneFineWineAndSpirits = 'PassionChampagneFineWineAndSpirits';
        public String PassionVIPEntertainment = 'PassionVIPEntertainment';
        public String PassionFashionAndStyle = 'PassionFashionAndStyle';
        public String PassionEliteWorldSport = 'PassionEliteWorldSport';
        public String PassionBusinessIntelligence = 'PassionBusinessIntelligence';
        public String PassionTheArts = 'PassionTheArts';
        public String PassionTechnologyandGadgets = 'PassionTechnologyandGadgets';
        public String PassionTravel = 'PassionTravel';
        public String SecurityQuestion = 'SecurityQuestion';
        public String SecurityAnswer = 'SecurityAnswer';
        public String Username = 'Username';
        //Xml node name is different for Password reset for user name that's why duplicate username
        public String Username1 = 'UserName';
        public String Password = 'Password';
        public String CountryOfResidence = 'CountryOfResidence';
        public String NationalityCode = 'NationalityCode';
        
        //Node Names for getHandsetDetails requests and Response
        public string HandsetDetailRequestnodeName = 'GetHandsetDetailsRequest';
        
        //Node for Handset Registration Requests and responses
        Public String RegisterHandsetRequestNode = 'RegisterHandsetRequest';
        
        //Node for Handset DeRegistration Requests and responses
        Public String DeRegisterHandsetRequestNode = 'DeRegisterHandsetRequest';
        
        //Node Names for handset section
        Public String HandsetListNode = 'HandsetList';
        Public String HandsetTypeNode = 'HandsetType';
        Public String HandsetNode = 'Handset';
        Public string HandsetDetailIMEINodeName = 'IMEI';
        Public string VSNNodeName = 'VSN';
        Public string HandsetDetailVSNNodeName = 'SerialNumber';
        Public String HandsetVregIdNode = 'VregID';
        Public string HandsetResServiceList = 'ServicesList';
        Public String HandsetServiceResType = 'ServicesType';
        Public String HandsetServiceNameRes = 'ServiceName';
        Public String HandsetTypeDesignator = 'TypeDesignator';
        Public String HandsetTypeDescription = 'TypeDescription';
        Public String HandsetPurchasePlace = 'PurchasePlace';
        Public String HandsetRegistrationDate = 'RegistrationDate';
        Public String HandsetTypeName = 'TypeName';
        Public String HandsetPurchaseDate = 'PurchaseDate';
        public String HandsetSerialNumber = 'SerialNumber';
        public String HandsetFirstTimeRegistration = 'FirstTimeRegistration';
        Public String HandsetOtherPurchasePlace = 'OtherPurchasePlace';
        
        //Node Names for Create Customer Requests and Response
        public String CreateCusRequestParentNode = 'CreateCustomerRequest';
        
        //Node Name for Password Reset Requests and responses
        Public String PasswordResetRequestNode = 'PasswordResetRequest';
        
        //Node names for Get Entitlement requests and response
        Public String GetEntitlementRequestNode = 'GetEntitlementRequest';
        Public String CreateEntitlementRequestNode = 'CreateEntitlementRequest';
        Public String EntitlementListNode = 'EntitlementList';
        Public String EntitlementFactListNode = 'EntitlementFactsList';
        Public String EntitlementNode = 'Entitlement';
        Public String LevelNode = 'Level';
        Public String DurationNode = 'Duration';
        Public String StartDateNode = 'StartDate';
        Public String ReasonNode = 'Reason';
        Public String EndDateNode = 'EndDate';
        Public String AddedDateNode = 'AddedDate';
        Public String NotesNode = 'Notes';
        Public String DurationLeftNode = 'DurationLeft';
    }
}