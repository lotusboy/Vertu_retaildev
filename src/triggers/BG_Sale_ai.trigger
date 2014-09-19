/*************************************************
BG_Sale_ai

Sale__c trigger for after insert

Author: Steve Loftus (BrightGen)
Created Date: 09/09/2014
Modification Date: 11/09/2014
Modified By: Steve Loftus (BrightGen)

**************************************************/
trigger BG_Sale_ai on Sale__c(before insert) {

	// pass the inserted Sale records over to get the related customer reassigned
	BG_CustomerHelper.reassignCustomersViaSaleInsert(trigger.new);

}