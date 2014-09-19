/********************************************************************
 * SCHEDULE_deleteVregMonitoringRecords
 *
 * Apex Schedule Class to allow for scheduling job to delete Vreg Monitorig records
 * 
 * Author: Mick Nicholson (BrightGen Ltd)
 * Created: 29-05-2013
 * Changes: 
 ********************************************************************/
 global class SCHEDULE_deleteVregMonitoringRecords implements Schedulable{

    global void execute(SchedulableContext sc)
    {
    	if (ScheduleUtils.CanSubmitJob())
    	{
			BATCH_deleteVregMonitoringRecords batchSubmit = new BATCH_deleteVregMonitoringRecords();
	        //Submit batch job with batch size set to 1
	        ID batchprocessid = Database.executeBatch(batchSubmit, 1);
    	}
    	else
    	{
	       	SCHEDULE_deleteVregMonitoringRecords scheduleSubmit; 
	
	        scheduleSubmit = new SCHEDULE_deleteVregMonitoringRecords();
	        
	        String scheduleName =  'SCHEDULE_deleteVregMonitoringRecords'
	        						+ '-'
	        						+ Datetime.now().hour()
	        						+ ':' + Datetime.now().minute()
	        						+ ':' + Datetime.now().second()
	        						+ ':' + Datetime.now().milliSecond();
	        DateTime scheduleDatetime = Datetime.now().addMinutes(10);
	        if (scheduleName.length() > 60)
	        {
	            scheduleName = scheduleName.substring(0,60);
	        }
			system.schedule(scheduleName.trim(), ScheduleUtils.GetCRONString(scheduleDatetime), scheduleSubmit);
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
        SCHEDULE_deleteVregMonitoringRecords testSchedule = new SCHEDULE_deleteVregMonitoringRecords();
        
        test.startTest();
		
		String scheduleName =  'testSchedule' + ' - ' + Datetime.now().hour() + ':' + Datetime.now().minute() + ':' + Datetime.now().second();
		if (scheduleName.length() > 60)
		{
			scheduleName = scheduleName.substring(0,60);
		} 
		system.schedule(scheduleName, ScheduleUtils.GetCRONString(Datetime.now().addSeconds(5)), testSchedule);
        test.stopTest();

	}


}