/*************************************************
BG_AccountAfterUpdate
Test Class:

trigger to control logic in after update context

Author: Mahfuz Choudhury
Created Date: 18/06/2014

**************************************************/
trigger BG_AccountAfterUpdate on Account (after update) {
    
    if(system.isFuture()) return;
    
    //Initialize all necessary variables here
    Map<id,Account> AccountMap = new Map<id,Account>();
    Set<id> Accountids = new Set<id>();
    Integer TotalRecordToProcess = 0;
    
   	//Retrieve the hierarchical custom setting value for controling the trigger
   	Operation_Switch__c OpSwitch = Operation_Switch__c.getOrgDefaults();
    
    for(Account acc : Trigger.new)
    {
        System.debug('Trigger Critera Values are:----------------------------->'+acc.SOA_Update_Customer_Integration__c+':'+acc.IsPersonAccount+':'+OpSwitch.Enable_SOA_Integration__c);
        //Refine accounts as per Call out requirements for SOA  
        if(acc.SOA_Update_Customer_Integration__c && acc.IsPersonAccount && OpSwitch.Enable_SOA_Integration__c)
        {
            Accountids.add(acc.id);    
        }
        
    }
            
    //we need another query because nested soql is not supported in trigger context
    for(Account acc: [Select id,(Select id, Active__c from Vertu_Accounts__r where Active__c = TRUE) from Account where id IN:Accountids])
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