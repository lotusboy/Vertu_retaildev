/*************************************************
BG_HandsetRegistrationUtils
Test Class:

Utility class for Handset Registration object

Author: Mahfuz Choudhury
Created Date: 18/07/2014

**************************************************/

public class BG_HandsetRegistrationUtils {
    /*
     * The following utility method query the database for registration record based on
     * the id provided.
	 */
    public static Handset_Registration__c getHandsetRegistrationById(Id RegId)
    {
     	
        if(RegId != NULL)
        {
         	return [SELECT id, IMEI__C, VSN__C, Place_of_Purchase_Code__c, Other_Place_of_Purchase__c, Date_of_Purchase__c,
                           User_Name__c, Password1__c, Private_Question_Pre_defined__c, Private_Question__c, Security_Answer__c,
                           Service_Registration__c, Customer__c, Retail_Account__c, Retail_Account__r.Store_Code__c,Customer__r.PersonEmail
                   FROM	   Handset_Registration__c
                   WHERE   Id =: RegId];    
        }
        
        //Should never reach here if the id is not null
        return NULL;
    }
}