/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest()
private class TestVertuInboundDataAfterInserrtTrigger {

    static testMethod void myUnitTest() {
        
        Vertu_Inbound_Data__c v = new Vertu_Inbound_Data__c();
        
        // Customer Register
        String jsonInput = '{ "contact_details": [ { "default": true, "id": "632008", "number": "+25623434521112", "number_type": "MOBILE",  "valid": true },  { "default": false,  "id": "632009",  "number": "+21383563456324",  "number_type": "LANDLINE", "valid": true }, { "default": false, "id": "632010", "number": "+374345623452643", "number_type": "LANDLINE", "valid": true }, { "address": "George Street, John Road, Michael Village, Jack St", "country": "Angola", "country_code": "AO", "default": false, "id": "632006", "postcode": "AB123DE", "valid": true }, { "address": "221B Baker Street, London, Greater London.", "country": "United Kingdom", "country_code": "GB", "default": true, "id": "632011", "postcode": "NW16XE", "valid": true }, { "default": false, "email": "ambrose@vertu.me", "id": "632005", "valid": true }, { "default": true, "email": "ambrose1@yahoo.com", "id": "632007", "valid": true } ], "groups": [ { "id": "CUSTOMERS", "name": "Customers" }, { "id": "MARKETINGPERMISSION_EMAIL", "name": "MarketingPermission_Email" }, { "id": "MARKETINGPERMISSION_TELEPHONE", "name": "MarketingPermission_Telephone" }, { "id": "MARKETINGPERMISSION_MOBILEMESSAGING", "name": "MarketingPermission_MobileMessaging" }, { "id": "MARKETINGPERMISSION_POST", "name": "MarketingPermission_Post" }, { "id": "LENSINITIATED", "name": "LensInitiated" }, { "id": "TEN", "name": "ten" } ], "marketing_permissions": { "email": true, "mobile_messaging": true, "post": true, "telephone": true }, "personal_details": { "date_of_birth": "1967-03-05", "first_name": "Ambrose", "is_male": true, "secret_answer": "Ambrose", "secret_question": "What is my name?", "spoken_language_code": "zh-yue", "surname": "McPierce", "title": "Mr", "username": "ambrose", "written_language_code": "en-GB","Password":{"encrypted": "{SMD5}PZoRHbIVVJn8JH1Lv1JUNeM+wYX7juwJDWCQvXyZ06w=", "expired": false, "type": "smd5"}}, "phones": [ { "date_of_registration": "2012-10-23 11:27:22", "imei": "929900581790238", "place_of_purchase": "264", "purchase_date": "2012-10-23", "serial_number": "ZS-005238", "services": [ { "name": "Concierge" }, { "name": "VertuSelect" }, { "name": "VertuEmail" }, { "name": "Checker" }, { "name": "Fortress2" } ], "type_code": "059F4G6", "type_description": "SS POLISHED BLACK LEATHER CERAMIC KEY", "type_designator": "RM-681V", "type_name": "Vertu Constellation" }, { "date_of_registration": "2012-10-23 11:29:46", "imei": "929900581790239", "place_of_purchase": "0", "purchase_date": "2012-10-23", "serial_number": "ZS-005239", "services": [ { "name": "Concierge" }, { "name": "VertuSelect" }, { "name": "VertuEmail" }, { "name": "Checker" }, { "name": "Fortress2" } ], "type_code": "059F4G6", "type_description": "SS POLISHED BLACK LEATHER CERAMIC KEY", "type_designator": "RM-681V", "type_name": "Vertu Constellation" } ], "services": [ { "entitlements": [ { "duration": "24", "duration_left": "24", "end_date": "2014-10-23T00:00:00", "level": "Classic", "start_date": "2012-10-23T00:00:00" } ], "language_code": "zh-yue", "language_name": "zh-yue", "name": "Concierge" }, { "name": "VertuSelect" }, { "level": "Standard", "name": "VertuEmail", "suspended": false }, { "name": "Checker" }, { "name": "Fortress2" } ], "notification_type": "customer.register", "id": "ABCD1234"}';
        v.Inbound_Message__c = jsonInput;
        
        insert v;
        
        Account testAccount = [Select ID from Account where VREG_Id__c = 'ABCD1234'];
        system.assertNotEquals(null,testAccount.Id);
        Handset__c[] testHandsets = [Select Id from Handset__c where Account_Name__c = :testAccount.Id];
        system.assertNotEquals(null,testHandsets.size());
        system.debug('MN*** size = ' + testHandsets.size());
        
        // Customer Update 
        jsonInput = '{ "contact_details": [ { "default": true, "id": "632008", "number": "+25623434521112", "number_type": "MOBILE",  "valid": true },  { "default": false,  "id": "632009",  "number": "+21383563456324",  "number_type": "LANDLINE", "valid": true }, { "default": false, "id": "632010", "number": "+374345623452643", "number_type": "LANDLINE", "valid": true }, { "address": "George Street, John Road, Michael Village, Jack St", "country": "Angola", "country_code": "AO", "default": false, "id": "632006", "postcode": "AB123DE", "valid": true }, { "address": "221B Baker Street, London, Greater London.", "country": "United Kingdom", "country_code": "GB", "default": true, "id": "632011", "postcode": "NW16XE", "valid": true }, { "default": false, "email": "ambrose@vertu.me", "id": "632005", "valid": true }, { "default": true, "email": "ambrose1@yahoo.com", "id": "632007", "valid": true } ], "groups": [ { "id": "CUSTOMERS", "name": "Customers" }, { "id": "MARKETINGPERMISSION_EMAIL", "name": "MarketingPermission_Email" }, { "id": "MARKETINGPERMISSION_TELEPHONE", "name": "MarketingPermission_Telephone" }, { "id": "MARKETINGPERMISSION_MOBILEMESSAGING", "name": "MarketingPermission_MobileMessaging" }, { "id": "MARKETINGPERMISSION_POST", "name": "MarketingPermission_Post" }, { "id": "LENSINITIATED", "name": "LensInitiated" }, { "id": "TEN", "name": "ten" } ], "marketing_permissions": { "email": true, "mobile_messaging": true, "post": true, "telephone": true }, "personal_details": { "date_of_birth": "1967-03-05", "first_name": "Ambrose", "is_male": true, "secret_answer": "Ambrose", "secret_question": "What is my name?", "spoken_language_code": "zh-yue", "surname": "McPierce", "title": "Mr", "username": "ambrose", "written_language_code": "en-GB","Password":{"encrypted": "{SMD5}PZoRHbIVVJn8JH1Lv1JUNeM+wYX7juwJDWCQvXyZ06w=", "expired": false, "type": "smd5"}}, "phones": [ { "date_of_registration": "2012-10-23 11:27:22", "imei": "929900581790238", "place_of_purchase": "264", "purchase_date": "2012-10-23", "serial_number": "ZS-005238", "services": [ { "name": "Concierge" }, { "name": "VertuSelect" }, { "name": "VertuEmail" }, { "name": "Checker" }, { "name": "Fortress2" } ], "type_code": "059F4G6", "type_description": "SS POLISHED BLACK LEATHER CERAMIC KEY", "type_designator": "RM-681V", "type_name": "Vertu Constellation" }, { "date_of_registration": "2012-10-23 11:29:46", "imei": "929900581790239", "place_of_purchase": "0", "purchase_date": "2012-10-23", "serial_number": "ZS-005239", "services": [ { "name": "Concierge" }, { "name": "VertuSelect" }, { "name": "VertuEmail" }, { "name": "Checker" }, { "name": "Fortress2" } ], "type_code": "059F4G6", "type_description": "SS POLISHED BLACK LEATHER CERAMIC KEY", "type_designator": "RM-681V", "type_name": "Vertu Constellation" } ], "services": [ { "entitlements": [ { "duration": "24", "duration_left": "24", "end_date": "2014-10-23T00:00:00", "level": "Classic", "start_date": "2012-10-23T00:00:00" } ], "language_code": "zh-yue", "language_name": "zh-yue", "name": "Concierge" }, { "name": "VertuSelect" }, { "level": "Standard", "name": "VertuEmail", "suspended": false }, { "name": "Checker" }, { "name": "Fortress2" } ], "notification_type": "customer.update", "id": "ABCD1234"}'; 
        v = new Vertu_Inbound_Data__c();
        v.Inbound_Message__c = jsonInput;
        insert v;
        
        // Customer Delete
        jsonInput = '{"notification_type": "customer.delete", "id": "ABCD1234"}';   
        v = new Vertu_Inbound_Data__c();
        v.Inbound_Message__c = jsonInput;
        insert v;
        
        
        // Some negative unit tests
        
        jsonInput = '{"notification_type": "INVALID NOTIFICATION TYPE", "id": "ABCD1234"}';   
        v = new Vertu_Inbound_Data__c();
        v.Inbound_Message__c = jsonInput;
        insert v;        	

        jsonInput = '{"notification_type": "customer.update", "id": "UNKNOWN_VREG_ID"}';   
        v = new Vertu_Inbound_Data__c();
        v.Inbound_Message__c = jsonInput;
        insert v;        	
        
    }
}