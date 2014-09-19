trigger RetailStatsBeforeInsert on Retail_Stats__c (before insert) {

 // if the user is a portal user then set the Boutique name based on the user contact account
 Id defaultBoutique;
 List<Contact> lsBoutique = [select AccountID from Contact where id in (select contactid from user where id =:UserInfo.getUserId()) Limit 1];
    if(!lsBoutique.isEmpty()){
            defaultBoutique = lsBoutique[0].AccountID;
            // assign the value to Boutique_Name__c
    for (Retail_Stats__c oRetail : trigger.new) {
             oRetail.Boutique_Name__c = defaultBoutique;
         }
    }
}