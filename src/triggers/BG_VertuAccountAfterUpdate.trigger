/*************************************************
BG_VertuAccountAfterUpdate
Test Class:

This is the after update trigger on Vertu Account Object, Please extend this if necessary

Author: Mahfuz Choudhury
Created Date: 20/06/2014
Changes:

**************************************************/

trigger BG_VertuAccountAfterUpdate on Vertu_Account__c (after update) {
    
    //Declare all the necessary variables here
    Set<id> VertuAccId = new Set<id>();
    Map<id,Account> AccountMap = new Map<id,Account>();
    Integer TotalRecordToProcess = 0;
    
    //Retrieve the hierarchical custom setting value for controling the trigger
   	Operation_Switch__c OpSwitch = Operation_Switch__c.getOrgDefaults();
    
    for(Vertu_Account__c va: Trigger.new)
    {   
        //If any of the mapping fields changes initiate the integration process
        if((va.Private_Question__c != Trigger.oldMap.get(va.id).Private_Question__c || 
           va.Security_Answer__c != Trigger.oldMap.get(va.id).Security_Answer__c ||
          va.Username__c != Trigger.oldMap.get(va.id).Username__c) && va.Active__c == TRUE && OpSwitch.Enable_SOA_Integration__c)
        {
            //Get all account ids into a set
            VertuAccId.add(va.Account_Name__c);   
        }
    }
    
    //we need to query for matching account along with all 
    for(Account acc: [Select id,(Select id, Active__c from Vertu_Accounts__r where Active__c = TRUE) from Account where id IN:VertuAccId])
    {
        //go through the child vertu accounts to see if they are active
        for(Vertu_Account__c VC : acc.Vertu_Accounts__r)
        {
            //Add the accounts in the Account Map only if they have an active account
            AccountMap.put(acc.id,acc);
            TotalRecordToProcess++;
            System.debug('Qualified Account Map------------------------------->>'+AccountMap);
        }
    }
            
    if(AccountMap.size() >0){
        AccountUtils.SOA_UpdateCustomerHelper(AccountMap, TotalRecordToProcess);    
    }
}