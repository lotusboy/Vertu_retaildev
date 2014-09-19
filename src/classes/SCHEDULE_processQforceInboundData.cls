/********************************************************************
 * SCHEDULE_processQforceInboundData
 *
 * Apex Schedule Class to allow for scheduling of ??.DeleteDestinationRecords
 * 
 * Author: Mick Nicholson (BrightGen Ltd)
 * Created: 27-03-2013
 * Changes: 
 ********************************************************************/
global class SCHEDULE_processQforceInboundData implements Schedulable{
    global Set<Id> recordsToProcess = new Set<Id>();
    
    global void execute(SchedulableContext sc)
    {
    	if (ScheduleUtils.CanSubmitJob())
    	{
			BATCH_processQforceInboundData batchSubmit = new BATCH_processQforceInboundData();
	        batchSubmit.recordIdsToProcess.addAll(recordsToProcess);
	        //Submit batch job with batch size set to 1
	        ID batchprocessid = Database.executeBatch(batchSubmit, 1);
    	}
    	else
    	{
			VertuInboundDataHandler.scheduleQforceInboundDataBatchJob(recordsToProcess);
    	}
    }


                                /************************************
                                 *                                  *
                                 *          TEST METHODS            *
                                 *                                  *
                                 ************************************/
    private static testMethod void testExecute()
    {
    	
        //Code coverage tests only
        Vertu_Inbound_Data__c vertuAcc = new Vertu_Inbound_Data__c();
        
        SCHEDULE_processQforceInboundData testSchedule = new SCHEDULE_processQforceInboundData();
        
        test.startTest();
		testSchedule.recordsToProcess.add(vertuAcc.Id);
		
		String scheduleName =  'testSchedule' + ' - ' + Datetime.now().hour() + ':' + Datetime.now().minute() + ':' + Datetime.now().second();
		if (scheduleName.length() > 60)
		{
			scheduleName = scheduleName.substring(0,60);
		} 
		system.schedule(scheduleName, ScheduleUtils.GetCRONString(Datetime.now().addSeconds(5)), testSchedule);
        test.stopTest();

	}


}