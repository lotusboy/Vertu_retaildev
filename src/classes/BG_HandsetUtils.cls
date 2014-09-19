/*************************************************
BG_HandsetUtils
Test Class:

Utility class for Handset object

Author: Mahfuz Choudhury
Created Date: 21/07/2014

**************************************************/

public class BG_HandsetUtils {
    
    Public Static Void UpdateHandsetWithRetailAccount(List<Handset__c> Handset)
    {
     	Set<String> StoreCodes = new Set<String>();
        Map<String, Id> AccIdMap = new Map<String, Id>();
        
        //Collect store codes from handset to identify accounts to be related
        for(Handset__c H: Handset)
        {
         	If((H.Place_of_Purchase_Code__c != NULL ||H.Place_of_Purchase_Code__c != '') && H.Place_of_Purchase__c == NULL)
            {
            	StoreCodes.add(H.Place_of_Purchase_Code__c);
            }
        }
        
        //Add ids to map keyed by Store code
        For(Account a: GetAccountByStoreCodeList(StoreCodes))
        {
         	AccIdMap.put(a.Store_Code__c, a.id);   
        }
        
        for(Handset__c H: Handset)
        {
            If(AccIdMap.containsKey(H.Place_of_Purchase_Code__c))
            {
                H.Place_of_Purchase__c = AccIdMap.get(H.Place_of_Purchase_Code__c);
            }
        }
    }
    
    /*
     * The following utility method query the database for handset records based on
     * the vertu Account id provided and return a list of matching handsets
	 */
    public static List<Handset__c> getHandsetRegistrationById(Id VertuAccid)
    {
        if(VertuAccid != NULL)
        {
         	return [SELECT id, Name, IMEI__C, VSN__C, Place_of_Purchase_Code__c, Other_Place_of_Purchase__c, Date_of_Purchase__c,
                           Service_Registration__c, Model_Variant__c, Vreg_ID_Handset__c
                   FROM	   Handset__c
                   WHERE   Vertu_Account__c =: VertuAccid];    
        }
        
        //Should never reach here if the id is not null
        return NULL;
    }
    
    /*
     * The following utility method query the database for handset record based on
     * the id provided.
	 */
    public static Handset__c getExistingHandsetById(Id HandsetId)
    {

         	return [SELECT id, Name, IMEI__C, VSN__C, Place_of_Purchase_Code__c, Other_Place_of_Purchase__c, Date_of_Purchase__c,
                           Service_Registration__c, Model_Variant__c, Vreg_ID_Handset__c, Vertu_Account__c, Account_Name__c, Account_Name__r.Store_Code__c
                   FROM	   Handset__c
                   WHERE   id =: HandsetId];    

    }
    
    /*
     * Utility method to Retrieve Account based on the store code Match
	 */
    Public Static List<Account> GetAccountByStoreCodeList(Set<String> StoreCodes)
    {
     	return [SELECT 	Id, Store_Code__c
                FROM	Account
                WHERE	Store_Code__c IN: StoreCodes
                AND 	RecordTypeId =:(recordTypeUtils.GetRecordTypeByObject('Account').get('Business_Account').id)];   
    }
}