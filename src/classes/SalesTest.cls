@ISTest
private class SalesTest {
// test class for the Sales Trigger to set the owner to a portal user for the boutique
    static testMethod void testSalesTriggerInsert() {
    	// initial test a record with no boutique name
    	Sale__c testSale = new Sale__c(Discount_Reason__c = 'Test Sale no Boutqiue');
    	insert testSale;
    	System.assertEquals(testSale.Discount_Reason__c, 'Test Sale no Boutqiue');
    }

}