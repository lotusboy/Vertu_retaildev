/*************************************************
BG_CustomerHelper

Helper class for the Customer object

Author: Steve Loftus (BrightGen)
Created Date: 08/09/2014
Modification Date: 11/09/2014
Modified By: Steve Loftus (BrightGen)

**************************************************/
public class BG_CustomerHelper {

	// this method will reassign customer records related to the incoming sale records to the store manager of the idenified boutique
	// a trigger on the after insert of the Sale records will pass the list into this method
	public static void reassignCustomersViaSaleInsert(list<Sale__c> insertedSaleList) {

		// map to hold the customer id and boutique id
		map<Id, Id> customerIdByBoutiqueIdMap = new map<Id, Id>();

		// map to hold the customer id and store manager id
		map<Id, Id> storeManagerIdByCustomerIdMap = new map<Id, Id>();

		// get the customer ids and the boutique ids out of each sale record in the list
		// the assumption is that all sales inserted for a particular customer are all for the same boutique
		for (Sale__c insertedSale : insertedSaleList) {

			if (string.isNotBlank(insertedSale.Boutique_Name__c) && string.isNotBlank(insertedSale.Account_Name__c)) {
				customerIdByBoutiqueIdMap.put(insertedSale.Boutique_Name__c, insertedSale.Account_Name__c);
			}
		}

		// find the store manager id for each boutique
		// make sure we have something to do
		if (!customerIdByBoutiqueIdMap.isEmpty()) {

			// loop around all users found who are store managers and portal users and linked to the store identified in the boutique sfid list
			for (User storeManager : [select Id, AccountId
										from User 
											where Retail_Store_Role__c = 'Manager' and IsActive = true and IsPortalEnabled = true and AccountId in : customerIdByBoutiqueIdMap.keySet()]) {

				// make sure we are looking for this store manager
				if (string.isNotBlank(storeManager.AccountId) && customerIdByBoutiqueIdMap.containsKey(storeManager.AccountId)) {

					// add the customer Id against the store Id into the map
					if (string.isNotBlank(storeManager.Id)) {
						storeManagerIdByCustomerIdMap.put(customerIdByBoutiqueIdMap.get(storeManager.AccountId), storeManager.Id);					
					}
				}
			}		

			// reassign the owner of the customer records

			list<Account> updatedCustomerList = new list<Account>();
			// make sure we have some store managers
			if (!storeManagerIdByCustomerIdMap.isEmpty()) {

				// loop around all the customers we need to update
				for (Account customer : [select Id, OwnerId from Account where Id in : storeManagerIdByCustomerIdMap.keySet()]) {

					// update the owner and add it to the list if it is needed
					if (storeManagerIdByCustomerIdMap.containsKey(customer.Id) && customer.OwnerId != storeManagerIdByCustomerIdMap.get(customer.Id)) {
						customer.OwnerId = storeManagerIdByCustomerIdMap.get(customer.Id);
						updatedCustomerList.add(customer);
					}
				}

				// if we have customers to update
				if (!updatedCustomerList.isEmpty()) {

					update updatedCustomerList;
				}
			}
		}
	}

	// this method will reassign customer records when the vertu store is changed to the store manager of the new store
	// a trigger on the before update and after insert of the customers will call this method
	public static void reassignCustomersViaVertuStore(list<Account> customerList) {

		// list to hold the boutique id
		list<Id> boutiqueIdList = new list<Id>();

		// map to hold the customer id and store manager id
		map<Id, Id> storeManagerIdByCustomerIdMap = new map<Id, Id>();

		// get the customer ids and the boutique ids out of each customer record in the list
		for (Account customer : customerList) {

			system.debug('customer [' + customer + ']');

			if (string.isNotBlank(customer.Boutique__pc)) {
				boutiqueIdList.add(customer.Boutique__pc);
			}
		}

		system.debug('boutiqueIdList [' + boutiqueIdList + ']');

		// find the store manager id for each boutique		
		// make sure we have something to do
		if (!boutiqueIdList.isEmpty()) {

			// loop around all users found who are store managers and portal users and linked to the store identified in the boutique sfid list
			for (User storeManager : [select Id, AccountId
										from User 
											where Retail_Store_Role__c = 'Manager' and IsActive = true and IsPortalEnabled = true and AccountId in : boutiqueIdList]) {

				// add the customer Id against the store Id into the map
				if (string.isNotBlank(storeManager.Id)) {
					storeManagerIdByCustomerIdMap.put(storeManager.AccountId, storeManager.Id);					
				}
			}		

			system.debug('storeManagerIdByCustomerIdMap [' + storeManagerIdByCustomerIdMap + ']');

			// reassign the owner of the customer records

			// make sure we have some store managers
			if (!storeManagerIdByCustomerIdMap.isEmpty()) {

				// loop around all the customers we need to update
				for (Account customer : customerList) {

					// update the owner if it is needed
					if (storeManagerIdByCustomerIdMap.containsKey(customer.Boutique__pc) && customer.OwnerId != storeManagerIdByCustomerIdMap.get(customer.Boutique__pc)) {
						customer.OwnerId = storeManagerIdByCustomerIdMap.get(customer.Boutique__pc);

						system.debug('customer.OwnerId [' + customer.OwnerId + ']');
					}
				}
			}
		}
	}
}