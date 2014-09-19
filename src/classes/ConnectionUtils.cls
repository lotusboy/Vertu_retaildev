public class ConnectionUtils {

	public static string QFORCE_CONNECTION = 'Quintessentially Concierge';
	
	public static PartnerNetworkConnection getPartnerNetworkConnectionByName(string connectionName)
	{
		string soqlQuery = 'Select ' + sObject_Utils.getFieldsSOQL(PartnerNetworkConnection.SObjectType.getDescribe()) + ' from PartnerNetworkConnection where ConnectionName = \'' + connectionName + '\' Limit 1';
		system.debug('MN*** soqlQuery = ' + soqlQuery);
		PartnerNetworkConnection pnc = database.query(soqlQuery);
		return pnc;
	}
	
	public static void createQforcePartnerNetworkConnection(id recordId)
	{
 		PartnerNetworkConnection qforceConnection = ConnectionUtils.getPartnerNetworkConnectionByName(ConnectionUtils.QFORCE_CONNECTION);
 		PartnerNetworkRecordConnection newConnection =  new PartnerNetworkRecordConnection(
																	                ConnectionId = qforceConnection.Id,
																	                LocalRecordId = recordId,
																	                SendClosedTasks = false,
																	                SendOpenTasks = false,
																	                SendEmails = false,
																	                ParentRecordId = null);
		insert newConnection;
	}
	
    /*******************************/
    /*
    /*  Test Methods
    /*
    /*******************************/
@isTest(seeAllData=true)
	static void testGetPartnerNetworkConnectionByName() 
	{
        string soqlQuery = 'Select ' + sObject_Utils.getFieldsSOQL(PartnerNetworkConnection.SObjectType.getDescribe()) + ' from PartnerNetworkConnection Limit 1';
		PartnerNetworkConnection newPNC = database.query(soqlQuery);
		if (newPNC != null)
		{
			PartnerNetworkConnection testPNC = getPartnerNetworkConnectionByName(newPNC.ConnectionName);
        	system.assertEquals(newPNC.Id, testPNC.Id);
		}
	}
	
	static void testCreateQforcePartnerNetworkConnection() 
	{
		Vertu_Inbound_Data__c testData = New Vertu_Inbound_Data__c();
		createQforcePartnerNetworkConnection(testData.Id);
		List<PartnerNetworkRecordConnection> testPNRC = [Select Id from PartnerNetworkRecordConnection where LocalRecordId = :testData.Id];
		system.assertEquals(1,testPNRC.size());
	}
	
}