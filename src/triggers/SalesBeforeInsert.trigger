trigger SalesBeforeInsert on Sale__c (before insert) {
// April 2014 - Duncan Chambers
// Version 2.0 - extracting the SOQL from the loop
// Project - Retail Sales Reporting phase 1
// Set the ownership of the record to the Store Manager
Id StoreID;
Id localUserID; 
Set<String> StoreIdList = new Set<String>();
Map<String,Id> StoreToUserMap = new Map<String,Id>();
List<Sale__c> ToUpdate = new List<Sale__c>();
// populate the list of stores from all the Sales
for ( Sale__c  item:Trigger.new) {
    StoreIdList.add(item.Boutique_Name__c);
}
// create a list of portal users and their Ids for the Boutiques in the trigger set 
// this trigger expects to find one Manager for each store
For (User usr:[ SELECT Id, AccountId FROM User 
                          where AccountId in :StoreIdList 
                          and IsActive = true 
                          and IsPortalEnabled = true 
                          and Retail_Store_Role__c <> ''
                          order by Retail_Store_Role__c desc]){
                StoreToUserMap.put(usr.AccountID,usr.Id);           
                          }
// loop through the trigger set and create the updates for each record
Sale__c UpdateSale;
 for (Sale__c s: Trigger.new) {
    // if there is a boutique name assigned
    if (s.Boutique_Name__c <> null) {
        // Update the Owner field with the user ID
        // Else (by default the record will be still assigned to whatever user created it)        
        if (StoreToUserMap.containsKey(s.Boutique_Name__c)) {
            s.OwnerID = StoreToUserMap.get(s.Boutique_Name__c); 
            }
        }   
    } 
}