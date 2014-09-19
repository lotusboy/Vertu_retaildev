/*
Developer Name   : Mick Nicholson (BrightGen Ltd)
Deployment Date  : 
Description      : Class to process different types of Vertu Inbound Data records. Called by trigger VertuInboundDataAfterInsert 
*/ 

global class VertuInboundDataHandler {

    
    public static String CUSTOMER = 'customer';
    public static String QFORCE = 'qforce';
    public static String QFORCEMEMBER = 'qforce.member';
    public static String QFORCEREQUEST = 'qforce.request';
    public static String QFORCEREQUESTINSERT = 'qforce.request.insert';
    public static String QFORCEREQUESTUPDATE = 'qforce.request.update';
    public static String STATUSERROR = 'Error';
    public static String STATUSSUCCESS = 'Success';
   	public static String STATUSWARNING = 'Warning';
   	public static String SUCCESSMESSAGE = ' - Successfully Processed:';
    public static String INVALIDPARSE = ' - JSON Parsing error:';
    public static String INVALIDVREGID = ' - Unknown VREGID: ';
    public static String MULTIPLEVREGID = ' - Multiple Vertu Accounts for VREGID: ';
    public static String INVALIDCASEID = ' - Unknown Case Id: ';
    public static String MULTIPLECASEID = ' - Multiple Cases for Case Id: ';
    public static String INVALIDCASEMEMBERID = ' - Unknown Member Id for Case Id: ';
    public static String UNEXPECTEDERROR = ' - Unexpected Error - ';
     
    /**
     *  Method to process all Vertu Inbound Data customer records
     *  Called by trigger VertuInboundDataAfterInsert
     */    
    public static void processVertuCustomerInboundData(List<Vertu_Inbound_Data__c>  customerInboundDataRecords)
    {

        // Pass all customer records to the appropriate class to parse JSON and 
        // perform updates 
		VertuInboundCustomerDataHandler.processNotifications (customerInboundDataRecords);

    }

    /**
     *  Method to process all Vertu Inbound Data Qforce records
     *  Called by trigger VertuInboundDataAfterInsert
     */    

    public static void processQforceInboundDataIds(Set<Id> qforceInboundDataRecordIds)
    {

        // Vertu Qforce Inbound Data Ids to be processed
        // Run @future because each record has to be processed separately. One failure should not fail the whole batch
        for (Id qforceInboundDataRecordId : qforceInboundDataRecordIds)
		{
			processQforceInboundDataId(qforceInboundDataRecordId);
		}               
    }

    /**
     *  Method to process a single Vertu Inbound Data Qforce Record
     *  Accepts a Vertu Inbound Data Qforce id and gets the JSON messages to process. 
     *  Run @future because each record has to be processed separately. One failure should not fail the whole batch
     *  Called by processQforceInboundDataRecords
     */    
@future
    public static void processQforceInboundDataId(Id qforceInboundDataRecordId)
    {
    	system.debug('MN**** in processQforceInboundDataId');
    	system.debug('MN**** record Id = ' + qforceInboundDataRecordId);
    	Vertu_Inbound_Data__c qForceInboundData = [Select id, Detail__c, Status__c, Inbound_Message__c from Vertu_Inbound_Data__c where id = : qforceInboundDataRecordId];
		system.debug('MN**** qForceInboundData = ' + qForceInboundData);
    	processQforceInboundData(qforceInboundData);	
    }

    /**
     *  Method to process a single Vertu Inbound Data Qforce Record
     *  Accepts a Vertu Inbound Data Qforce JSON messages to process. 
     *  Called by @future method processQforceInboundDataRecord and BATCH_processQforceInboundData
     */    

    public static void processQforceInboundData(Vertu_Inbound_Data__c qforceInboundData)
    {
		system.debug('MN**** In processQforceInboundData');
        // Identify the type of QForce record being processed and pass to the appropriate class to parse JSON and 
        // perform updates 
		if (qForceInboundData.Detail__c.startsWith(QFORCEMEMBER))
		{
			QForceInboundMemberDataHandler.processMember(qforceInboundData);	
		}
		else if (qForceInboundData.Detail__c.startsWith(QFORCEREQUEST))
		{
			QForceInboundRequestDataHandler.processRequest(qforceInboundData);	
		}
		else
		{
			qforceInboundData.Status__c = STATUSERROR;
			qforceInboundData.Detail__c = qforceInboundData.Detail__c + ': Unknown Source';
			update qforceInboundData;
		}
    }

    
    /**
     *  Method to schedule a batch job to process bulk updates of  Vertu Inbound Data Qforce Records
     *  Accepts a set of Vertu Inbound Data Qforce JSON message Ids to process. 
     *  Called by trigger VertuInboundDataAfterInsert
     */    
    public static void scheduleQforceInboundDataBatchJob(Set<Id> jsonIDs)
    {
       	SCHEDULE_processQforceInboundData scheduleSubmit; 

        scheduleSubmit = new SCHEDULE_processQforceInboundData();
        scheduleSubmit.recordsToProcess.addall(jsonIDs);
        
        //String scheduleName =  ScheduleUtils.PROCESS_DELETEDESTINATION
        String scheduleName =  'SCHEDULE_processQforceInboundData'
        						+ '-'
        						+ Datetime.now().hour()
        						+ ':' + Datetime.now().minute()
        						+ ':' + Datetime.now().second()
        						+ ':' + Datetime.now().milliSecond();
        //						+ ':' + Datetime.now().milliSecond()
        //						+ '-' + filename;
        DateTime scheduleDatetime = Datetime.now().addMinutes(10);
        if (scheduleName.length() > 60)
        {
            scheduleName = scheduleName.substring(0,60);
        }
		system.schedule(scheduleName.trim(), ScheduleUtils.GetCRONString(scheduleDatetime), scheduleSubmit);
    }


}