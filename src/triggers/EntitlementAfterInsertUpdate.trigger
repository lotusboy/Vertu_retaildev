trigger EntitlementAfterInsertUpdate on Entitlement__c (after insert, after update) {

    //Insert - Pass all Entitlements to method to update Entilement Level on Accounts
    if (trigger.isInsert)
    {
        AccountUtils.updateEntitlementLevel(trigger.new);
    }
    else
    {
        //Update - Only pass Entitlements to method to update Entilement Level on Accounts  where relevant field has been updated
        List<Entitlement__c> updatedEnts = new List<Entitlement__c>();
        for (Entitlement__c ent : trigger.new)
        {
            if (ent.Account__c != trigger.oldmap.get(ent.Id).Account__c ||
                ent.Expired__c != trigger.oldmap.get(ent.Id).Expired__c ||
                ent.End_Date__c != trigger.oldmap.get(ent.Id).End_Date__c ||
                ent.Level__c != trigger.oldmap.get(ent.Id).Level__c ||
                ent.Conversion_Requested__c)
            {
                updatedEnts.add(ent);
            }
        }
        AccountUtils.updateEntitlementLevel(updatedEnts);
    }
}