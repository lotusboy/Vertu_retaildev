/*************************************************
BG_CustomSettingUtils

Class For getting List type Custom setting by supplying the name

Author: Mahfuz Choudhury
Created Date: 21/07/2014

**************************************************/

public with sharing class BG_CustomSettingUtils{
	
    //The following method returns the Encryption key value for given name
    public static String GetEncryptionKeyByName(String Name)
    {
        Encryption_key__c EK;
        If(Name != NULL)
        {
         	EK = Encryption_key__c.getInstance(Name);   
        }
        
        System.debug('Encryption Key is:-------------->'+EK.Key__c);
        return EK.Key__c;
    }
    
    /*Return a select options list from custom setting list based supplied name
    Public Static List<SOA_Operations__c> GetSOAOpsList()
    {        
        //Get All values from the custom settings
        List<SOA_Operations__c> ReturnList = SOA_Operations__c.getAll().values();
        
        return ReturnList;
    }*/
}