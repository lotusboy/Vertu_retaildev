/*************************************************
BG_HandsetUtils
Test Class:

Utility class for Handset object

Author: Mahfuz Choudhury
Created Date: 21/07/2014

**************************************************/

public class BG_VertuAccountUtils {
    /*
     * The following utility method query the database for handset record based on
     * the id provided.
	 */
    public static Vertu_Account__c getHandsetRegistrationById(Id VertuAccid)
    {
        if(VertuAccid != NULL)
        {
         	return [SELECT id, Name, VREG_ID_Vertu_Account__c, Account_Name__c, Username__c
                    FROM	   Vertu_Account__c
                    WHERE   Id =: VertuAccid];    
        }
        
        //Should never reach here if the id is not null
        return Null;
    }
}