/*************************************************
SOA_WSO_MaintainCustomerCall
Test Class:

Class for handling all the logic for outbound callout (RESTful)

Author: Mahfuz Choudhury
Created Date: 19/06/2014

**************************************************/
public class SOA_WSO_MaintainCustomerCall {
    //Declare variable with non Changing values here..
    Public static final String BooleanFieldString = 'TRUE';
    Public static final String CUpdateCalloutMethod = 'POST';
    String RequestString;
    HttpResponse response;
    
    //Define the Endpoint Name here matching with Custom setting name
    Public static final string CustomerUpdateEndPoint = 'SOACustomerMaintainEndpoint'; 
    
    //Method to handle the callout
    Public WS_SOA_MaintainCustomerType.UpdateCustomerResponseType UpdateCustomerCall(Account acc, Vertu_Account__c VertuAcc)
    {
        WS_SOA_MaintainCustomerType.UpdateCustomerResponseType res = new WS_SOA_MaintainCustomerType.UpdateCustomerResponseType();
        
        System.debug('Hi Greeting from MaintainCustomerCall.UpdateCustomerCall method--------------------->>>>>>'+acc);
        
        //Initialize an instance of a customer type and handset here and map salesforce fields with SOA object
        WS_SOA_CustomerType.CustomerType SOACustomer = BuildCustomerType(acc,VertuAcc);
        
        System.debug('Calling BuildHandsetType() method below & returned customer type above is--------------------->>>>>>'+SOACustomer);
        WS_SOA_HandsetDetail.Handset Handset = BuildHandsetType();
        
        //Build an XML request string from BG_XMLUtility class by passing SOACustomer and Handset
        try
        {
            RequestString = BG_XMLUtility.CreateCustomerUpdateRequest(SOACustomer, Handset, SOACustomerMaintainHeader(CustomerUpdateEndPoint));
            System.debug('Request in customer maintain call class method is:-------------------------->'+RequestString);
        }
        Catch(Exception ex)
        {
            System.debug('XML Request Building Failed for: ----------------------------------->'+ex.getMessage());
        }
        
        //Make an instance of the web service handler class 
        WSO_SOA_HTTPCustomerMaintainInterface CallInterface = new WSO_SOA_HTTPCustomerMaintainInterface();
        CallInterface.Endpoint = GetEndPointURLByName(CustomerUpdateEndPoint);
        CallInterface.CalloutMethod = CUpdateCalloutMethod;
        CallInterface.Timeout = 12000;
        
        //Call the web service through the update customer interface
        Response = CallInterface.MaintainCustomerInterface(RequestString, '');
        System.debug('Response in Maintain Customer Call is: '+Response);
        
        //If the call out was successful and response body is not empty parse the response
        if(Response.getStatusCode() == 200 && Response.getBody() != NULL)
        {
            try
            {
                res = BG_XMLUtility.ParseCustomerUpdateResponse(Response.getBody());   
            }
            Catch(Exception ex)
            {
                System.debug('XML Response Parsing Failed for:--------------------------------------> '+ex.getMessage());
                System.debug('XML Response Parsing Failed Line Number:--------------------------------------> '+ex.getLineNumber());
            }
        }
        
        //Return type to be specified here
        return res;
    }
    
    //build customer type here
    Public Static WS_SOA_CustomerType.CustomerType BuildCustomerType(Account acc, Vertu_Account__c vc)
    {
        //Initialize Customer Type here...
        WS_SOA_CustomerType.CustomerType SOACustomer = new WS_SOA_CustomerType.CustomerType();
        
        System.debug('Hi Greeting from MaintainCustomerCall.BuildCustomerType method------------------------->>>>>>'+vc);  
        
        //Map SOA fields with Salesforce fields here
        SOACustomer.AccountGUID = acc.id;
        
        if(vc != NULL)
        {
            SOACustomer.VertuAccountGUID = vc.id;
            
            if(vc.VREG_ID_Vertu_Account__c != NULL)
            {
                SOACustomer.VregID = String.valueOf(NullCheckerMethod(vc.VREG_ID_Vertu_Account__c));   
            }
        }      
        
        SOACustomer.Salutation = NullCheckerMethod(acc.Salutation);   
        SOACustomer.FirstName = NullCheckerMethod(acc.FirstName);   
        SOACustomer.LastName = NullCheckerMethod(acc.LastName);   
        SOACustomer.Gender = NullCheckerMethod(acc.Gender__pc); 
        
        if(acc.PersonBirthdate != NULL)
            SOACustomer.BirthDate = acc.PersonBirthdate.day() + '/' + acc.PersonBirthdate.Month() + '/' + acc.PersonBirthdate.Year();
        
        SOACustomer.VertuSpokenLanguage = NullCheckerMethod(acc.Vertu_Spoken_Language__c);   
        SOACustomer.VertuWrittenLanguage = NullCheckerMethod(acc.Vertu_Written_Language__pc);   
        SOACustomer.PrimaryEmail = NullCheckerMethod(acc.PersonEmail);   
        SOACustomer.SecondaryEmail = NullCheckerMethod(acc.Secondary_Email_Address__pc);   
        SOACustomer.ThirdEmail = NullCheckerMethod(acc.Third_Email_Address__pc);   
        SOACustomer.FourthEmail = NullCheckerMethod(acc.Fourth_Email_Address__pc);
        SOACustomer.FifthEmail = NullCheckerMethod(acc.Fifth_Email_Address__pc);
        SOACustomer.Mobile = NullCheckerMethod(acc.PersonMobilePhone);
        SOACustomer.HomePhone = NullCheckerMethod(acc.PersonHomePhone);
        SOACustomer.OtherPhone = NullCheckerMethod(acc.PersonOtherPhone);
        SOACustomer.MailingStreet = NullCheckerMethod(acc.PersonMailingStreet);
        SOACustomer.MailingCountry = NullCheckerMethod(acc.PersonMailingCountry);
        SOACustomer.MailingPostCode = NullCheckerMethod(acc.PersonMailingPostalCode);
        SOACustomer.OtherStreet = NullCheckerMethod(acc.PersonOtherStreet);
        SOACustomer.OtherCountry = NullCheckerMethod(acc.PersonOtherCountry);
        SOACustomer.OtherPostCode = NullCheckerMethod(acc.PersonOtherPostalCode);
        SOACustomer.MailMe = ReplaceBooleanWithString(acc.Mail_Me__pc);
        SOACustomer.SMSMe = ReplaceBooleanWithString(acc.SMS_Me__pc);
        SOACustomer.PhoneMe = ReplaceBooleanWithString(acc.Phone_Me__pc);
        SOACustomer.EmailMe = ReplaceBooleanWithString(acc.Email_Me__pc);
        SOACustomer.PassionFineDining = ReplaceBooleanWithString(acc.Passion_Fine_Dining__pc);
        SOACustomer.PassionChampagneFineWineAndSpirits = ReplaceBooleanWithString(acc.Passion_Champagne_Fine_Wine_And_Spirits__pc);
        SOACustomer.PassionVIPEntertainment = ReplaceBooleanWithString(acc.Passion_VIP_Entertainment__pc);
        SOACustomer.PassionFashionAndStyle = ReplaceBooleanWithString(acc.Passion_Fashion_And_Style__pc);
        SOACustomer.PassionEliteWorldSport = ReplaceBooleanWithString(acc.Passion_Elite_World_Sport__pc);
        SOACustomer.PassionBusinessIntelligence = ReplaceBooleanWithString(acc.Passion_Business_Intelligence__pc);
        SOACustomer.PassionTheArts = ReplaceBooleanWithString(acc.Passion_The_Arts__pc);
        SOACustomer.PassionTechnologyandGadgets = ReplaceBooleanWithString(acc.Passion_Technology_and_Gadgets__pc);
        SOACustomer.PassionTravel = ReplaceBooleanWithString(acc.Passion_Travel__pc);
        
        If(vc != NULL)
        {
            SOACustomer.SecurityQuestion = NullCheckerMethod(vc.Private_Question__c);
            SOACustomer.SecurityAnswer = NullCheckerMethod(vc.Security_Answer__c);
            SOACustomer.Username = NullCheckerMethod(vc.Username__c);
        }   
        
        System.debug('SOA Customer is: ------------------------------------------->'+SOACustomer);
        return SOACustomer;
    }
    
    //Build Handset Type here
    private WS_SOA_HandsetDetail.Handset BuildHandsetType()
    {
        //No Information has to be passed to SOA at this moment but can be utilized later if necessary
        WS_SOA_HandsetDetail.Handset Handset = new WS_SOA_HandsetDetail.Handset();
        
        //Declare a services type here which is required for services
        return Handset;
    }
    
    //Utility method to create Header information for Web service call based on custom setting
    Public static WS_SOA_HeaderInfo.Header SOACustomerMaintainHeader(String CUpdateEndPoint)
    {
        System.debug('Hi Greeting from MaintainCustomerCall.SOACustomerMaintainHeader method (End point fetching...)--------------------->>>>>>'+CUpdateEndPoint);
        //Create an Instance of the header class
        WS_SOA_HeaderInfo.Header HeaderInfo = new WS_SOA_HeaderInfo.Header();
        Integration_Endpoints__c SOAEndPoint = Endpoint_Utils.getEndPoint(CUpdateEndPoint);
        
        if(SOAEndPoint != NULL)
        {
            HeaderInfo.UserName = NullCheckerMethod(SOAEndPoint.User_Name__c);
            //HeaderInfo.UserName = 'Vertu_Salesforce_PreProd_User';
            HeaderInfo.Password = NullCheckerMethod(SOAEndPoint.Password__c);
            //HeaderInfo.Password = '0ztkGCZcMtvNIuiQzDO6MS6groEOyUwXl54uPpBd7dg=';
            //HeaderInfo.Domain = SOAEndPoint.Endpoint__c;
            HeaderInfo.SecurityToken = NullCheckerMethod(SOAEndPoint.API_Key__c);
            //HeaderInfo.SecurityToken = 'MauCwBOhVitoXjLqgyN30BbeY7LfNz1anaiByKHFh5Q=';
            //HeaderInfo.Role = SOAEndPoint.Role__c;
            //HeaderInfo.MessageID = SOAEndPoint.Message_ID__c;
            //HeaderInfo.TransactionID = SOAEndPoint.Transaction_ID__c;
            HeaderInfo.Timestamp = Datetime.now();
        }
        System.debug('Header for Customer Update call------------------------------------->>>>'+HeaderInfo);
        return HeaderInfo;
    }
    
    //Utility method to get the endpoint url by name
    Public Static String GetEndPointURLByName(String CUpdateEndPoint)
    {
        String EndpointUrl = null;
        Integration_Endpoints__c SOAEndPoint = Endpoint_Utils.getEndPoint(CUpdateEndPoint);
        
        //Get the endPoint Url from Custom setting
        if(SOAEndPoint != NULL)
        {
            EndpointUrl = SOAEndPoint.Endpoint__c;     
        }
        
        return EndpointUrl;
    }
    
    //Utility Method to check if the field is null, if null replace with empty string
    Public Static String NullCheckerMethod(String field)
    {
        if(field != Null)
        {
            return field;
        }
        else 
        {
            return '';
        }
    }
    
    //Utility Method to Convert boolean to string for SOA Mapping
    Public static String ReplaceBooleanWithString(Boolean SForcevalue)
    {
        if(SForcevalue == TRUE)
        {
            return BooleanFieldString;   
        }    
        else
        {
            return '';   
        }
    }

}