/********************************************************************
 * recordTypeUtils
 *
 * Record Type Utility methods 
 * 
 * Author: Mick Nicholson - BrightGen Litd
 * Created:25-04-2013
 * Changes: 
 *
 *
 ********************************************************************/
public with sharing class recordTypeUtils 
{
	
	public static final string CASE_CONCIERGE_RECORD_TYPE = 'Concierge_Case';
	public static final string TASK_CONCIERGE_RECORD_TYPE = 'Concierge_Task';
	public static final string MARKETING_PREFERENCE_CONCIERGE_RECORD_TYPE = 'Concierge';
	
    public static map<String, RecordType> GetRecordTypeByObject(String objectName)
    {
        /*
            Method to return all RecordTypes for the supplied Object keyed by the RecordType name
        */
        map<String, RecordType> results = new map<String, RecordType>();
        for (RecordType rt : [SELECT    SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, 
                                        DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId 
                              FROM      RecordType
                              WHERE     SobjectType = :objectName])
        {
            results.put(rt.DeveloperName, rt);
        }
        return results;
    }
    
    public static map<Id, RecordType> GetRecordTypeByObjectById(String objectName)
    {
        /*
            Method to return all RecordTypes for the supplied Object keyed by the RecordType name
        */
        map<Id, RecordType> results = new map<Id, RecordType>();
        for (RecordType rt : [SELECT    SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, 
                                        DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId 
                              FROM      RecordType
                              WHERE     SobjectType = :objectName])
        {
            results.put(rt.Id, rt);
        }
        return results;
    }

    public static RecordType GetRecordTypeById(Id recordTypeId)
    {
        /*
            Method to return the RecordType for the supplied Id
        */
        RecordType result = [SELECT SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, 
                                    DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId 
                             FROM   RecordType
                             WHERE  Id = :recordTypeId];
        return result;
    }
    
    public static RecordType GetRecordTypeByObjectandName(String objectName, String recordTypeName)
    {
        /*
            Method to return the RecordType for the supplied Object and RecordType name
        */
        RecordType result;
        result =  [SELECT   SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, 
                            DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId 
                   FROM     RecordType
                   WHERE    SobjectType = :objectName
                   AND      DeveloperName = :recordTypeName];
        return result;
    }


                                /************************************
                                 *                                  *
                                 *          TEST METHODS            *
                                 *                                  *
                                 ************************************/
    
    private static testMethod void testGetRecordTypeByObject()
    {
        String objectName = 'Account';
        map<String, RecordType> results;
        results = GetRecordTypeByObject(objectName);
        system.assertEquals(true, results != null);
        system.assertEquals(false, results.isEmpty());
    } 
    private static testMethod void testGetRecordTypeByObjectById()
    {
        String objectName = 'Account';
        map<Id, RecordType> results;
        results = GetRecordTypeByObjectById(objectName);
        system.assertEquals(true, results != null);
        system.assertEquals(false, results.isEmpty());
    } 
    private static testMethod void testGetRecordTypeById()
    {
        String objectName = 'Account';
        map<Id, RecordType> results;
        results = GetRecordTypeByObjectById(objectName);
        system.assertEquals(true, results != null);
        system.assertEquals(false, results.isEmpty());
        RecordType expected  = results.values()[0];
        RecordType result = GetRecordTypeById(expected.Id);
        system.assertEquals(expected.Id, result.Id);
    } 
    private static testMethod void testGetRecordTypeByObjectandName()
    {
        String objectName = 'Case';
        RecordType result;
        result = GetRecordTypeByObjectandName(objectName, CASE_CONCIERGE_RECORD_TYPE);
        system.assertEquals(true, result != null);
        system.assertEquals(CASE_CONCIERGE_RECORD_TYPE, result.DeveloperName);

    } 
}