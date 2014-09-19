/********************************************************************
 * ScheduleUtils
 *
 * Schedule Utility methods 
 * 
 * Author: Mick Nicholson (BrightGen Ltd)
 * Created: 27-03-2013
 * Changes: 
 ********************************************************************/
public class ScheduleUtils {
    public static final String ASYNC_STATUS_COMPLETED = 'Completed';
    public static final String ASYNC_STATUS_QUEUED = 'Queued';
    public static final String ASYNC_STATUS_PROCESSING = 'Processing';
    public static final String ASYNC_STATUS_ABORTED = 'Aborted';
    public static final String ASYNC_STATUS_FAILED = 'Failed';
    public static final String ASYNC_STATUS_PREPARING = 'Preparing';
    
    
    public static String GetCRONString(Datetime scheduleDatetime)
    {
        /*
            Method to return the Schedule CRON String based on supplied date/time
        */
        String scheduleString;
        scheduleString = String.valueOf(scheduleDatetime.second()) + ' ' +
                                        String.valueOf(scheduleDateTime.minute()) + ' ' +
                                        String.valueOf(scheduleDateTime.hour()) + ' ' +
                                        String.valueOf(scheduleDateTime.day()) + ' ' +
                                        String.valueOf(scheduleDateTime.month()) + ' ' +
                                        '? ' +
                                        String.valueOf(scheduleDateTime.year());
        return scheduleString;
    }

    public static void ClearProcessScheduleQueue()
    {
        /*
            Method to clear the Schedule Queue of any processed jobs
        */
        ClearProcessScheduleQueue('');
    }
    public static void ClearProcessScheduleQueue(String ignoreJobId)
    {
        /*
            Method to clear the Schedule Queue of any processed jobs ensuring the supplied
            jobId is ignored
        */
        for (CronTrigger ct : [SELECT   TimesTriggered, State, StartTime, PreviousFireTime, OwnerId, 
                                        NextFireTime, Id, EndTime, CronExpression, CreatedDate 
                               FROM     CronTrigger
                               WHERE    State = 'DELETED' LIMIT 100])
        {
            system.debug(system.logginglevel.error, '###################### Abort :' + ct.Id);
            if ((ignoreJobId == null) ||
                (ignoreJobId.length() == 0) ||
                (ignoreJobId != String.valueOf(ct.Id).subString(0,15)))
            {
                try
                {
                    system.abortJob(ct.Id);
                } catch (Exception ex)
                {
                	system.debug(system.logginglevel.error, '###################### Abort Exception:' + ex.getMessage());
                }
            }
        }
    }
    public static Integer EstimateTTR()
    {
        /*
            Method to calculate the estimated number of minutes until the an available slot in the Batch Apex
            Queue will come available
        */
        Integer result = 10;
        list<AsyncApexJob> runningJobs = new list<AsyncApexJob>();
        runningJobs.addAll(GetRunningJobs());
        
        for (AsyncApexJob runningJob : runningJobs)
        {
            if (runningJob.Status == 'Processing')
            {
                Integer totalJobs = Math.max(1, runningJob.TotalJobItems);
                Integer processed = Math.max(1, runningJob.JobItemsProcessed);
                //Decimal percentComplete = processed / totalJobs;
                Long timeRunning = Datetime.now().getTime() - runningJob.CreatedDate.getTime();
                Integer estimateToComplete = (((timeRunning / processed) * totalJobs) / 60000).intValue();
                if (estimateToComplete < result)
                {
                    result = estimateToComplete;
                }
            }
        }
        if ( result == 0 )
        {
        	result = 1;
        }
        return result;
    }
    public static list<AsyncApexJob> GetRunningJobs()
    {
        /*
            Method to obtain a list of current running Async/Batch Apex Jobs
        */
        list<AsyncApexJob> runningJobs = new list<AsyncApexJob>();
        runningJobs.addAll([SELECT  TotalJobItems, Status, ParentJobId, NumberOfErrors, MethodName, LastProcessedOffset, 
                                    LastProcessed, JobType, JobItemsProcessed, Id, ExtendedStatus, CreatedDate,
                                    CreatedById, CompletedDate, ApexClassId
                            FROM    AsyncApexJob
                            WHERE   Status NOT IN(:ASYNC_STATUS_COMPLETED, :ASYNC_STATUS_ABORTED, :ASYNC_STATUS_FAILED)
                            AND		JobType != 'BatchApexWorker' 
                            AND		JobType != 'ScheduledApex' 
                            ORDER BY Status]);
        return runningJobs;
    }
    
    public static map<String, list<AsyncApexJob>> GetAsyncJobs()
    {
        /*
            Method to obtain a list of current Async/Batch Apex Jobs
        */
        map<String, list<AsyncApexJob>> asyncJobs = new map<String, list<AsyncApexJob>>(); 
        
        for ( AsyncApexJob thisJob :[SELECT  TotalJobItems, Status, ParentJobId, NumberOfErrors, MethodName, LastProcessedOffset, 
                                    LastProcessed, JobType, JobItemsProcessed, Id, ExtendedStatus, CreatedDate,
                                    CreatedById, CompletedDate, ApexClassId
                            FROM    AsyncApexJob
                            WHERE   Status NOT IN(:ASYNC_STATUS_COMPLETED, :ASYNC_STATUS_ABORTED, :ASYNC_STATUS_FAILED)
                            AND	JobType != 'BatchApexWorker'
                            AND	JobType != 'ScheduledApex' 
                            ])
        {
        	if ( !asyncJobs.containsKey(thisJob.Status))
        	{
        		asyncJobs.put(thisJob.Status, new List<AsyncApexJob>());
        	}
        	asyncJobs.get(thisJob.Status).add(thisJob);
        }
        return asyncJobs;
    }

    public static Boolean CanSubmitJob()
    {
        /*
            Method to evaluate if there is capacity within the Batch Apex queue for another job to be submitted
        */
        Integer maxRunningApexJobs = 5;
        Integer maxPreparingApexJobs = 5;
        
        map<String, list<AsyncApexJob>> allAsyncJobs = GetAsyncJobs();

		list<AsyncApexJob> preparingJobs = new list<AsyncApexJob>();
		if ( allAsyncJobs.containsKey(ASYNC_STATUS_PREPARING))
		{
			preparingJobs.addAll(allAsyncJobs.get(ASYNC_STATUS_PREPARING));
		}

        list<AsyncApexJob> currentRunning = new list<AsyncApexJob>();
        if ( allAsyncJobs.containsKey(ASYNC_STATUS_QUEUED))
        {
   	        currentRunning.addAll(allAsyncJobs.get(ASYNC_STATUS_QUEUED));
        }
        if ( allAsyncJobs.containsKey(ASYNC_STATUS_PROCESSING))
        {
	        currentRunning.addAll(allAsyncJobs.get(ASYNC_STATUS_PROCESSING));
        }
        if ( allAsyncJobs.containsKey(ASYNC_STATUS_PREPARING))
        {
        	currentRunning.addAll(allAsyncJobs.get(ASYNC_STATUS_PREPARING));        	
        }
        
        return (preparingJobs.size() < maxPreparingApexJobs) && (currentRunning.size() < maxRunningApexJobs);
    }
    

                                /************************************
                                 *                                  *
                                 *          TEST METHODS            *
                                 *                                  *
                                 ************************************/
    
    private static testMethod void testGetCRONString()
    {
        Datetime testTime = dateTime.now();
        String expected = String.valueOf(testTime.second()) + ' ' +
                          String.valueOf(testTime.minute()) + ' ' +
                          String.valueOf(testTime.hour()) + ' ' +
                          String.valueOf(testTime.day()) + ' ' +
                          String.valueOf(testTime.month()) + ' ' +
                          '? ' +
                          String.valueOf(testTime.year());
    
        system.assertEquals(expected, GetCRONString(testTime));
    }

    
    private static testMethod void testClearProcessScheduleQueue()
    {
        list<CronTrigger> cts = new list<CronTrigger>([SELECT   TimesTriggered, State, StartTime, PreviousFireTime, OwnerId, 
                                                                NextFireTime, Id, EndTime, CronExpression, CreatedDate 
                                                       FROM     CronTrigger
                                                       WHERE    State = 'DELETED']);
        integer expectedCount = cts.size();
        if (expectedCount <= 100)
        {
        	expectedCount = 0;
        }
        else
        {
        	expectedCount = expectedCount - 100;
        }
        ClearProcessScheduleQueue();
        cts = new list<CronTrigger>([SELECT   TimesTriggered, State, StartTime, PreviousFireTime, OwnerId, 
                                                                NextFireTime, Id, EndTime, CronExpression, CreatedDate 
                                                       FROM     CronTrigger
                                                       WHERE    State = 'DELETED']);
        system.assertEquals(expectedCount, cts.size());
    }
    
    private static testMethod void testGetRunningJobs()
    {
        //code coverage only and basically a SOQL call
        list<AsyncApexJob> results = GetRunningJobs();
        system.assertEquals(false, results == null);
    }
    
	private static testMethod void testCanSubmitJob()
    {
        Integer maxRunningApexJobs = 5;
        Integer maxPreparingApexJobs = 5;

		map<String, list<AsyncApexJob>> allAsyncJobs = GetAsyncJobs();

		list<AsyncApexJob> preparingJobs = new list<AsyncApexJob>();
		if ( allAsyncJobs.containsKey(ASYNC_STATUS_PREPARING))
		{
			preparingJobs.addAll(allAsyncJobs.get(ASYNC_STATUS_PREPARING));
		}
        
        list<AsyncApexJob> currentRunning = new list<AsyncApexJob>();
        if ( allAsyncJobs.containsKey(ASYNC_STATUS_QUEUED))
        {
   	        currentRunning.addAll(allAsyncJobs.get(ASYNC_STATUS_QUEUED));
        }
        if ( allAsyncJobs.containsKey(ASYNC_STATUS_PROCESSING))
        {
	        currentRunning.addAll(allAsyncJobs.get(ASYNC_STATUS_PROCESSING));
        }
        if ( allAsyncJobs.containsKey(ASYNC_STATUS_PREPARING))
        {
        	currentRunning.addAll(allAsyncJobs.get(ASYNC_STATUS_PREPARING));        	
        }
		Boolean expected = (preparingJobs.size() < maxPreparingApexJobs) && (currentRunning.size() < maxRunningApexJobs);        
        Boolean result = CanSubmitJob();
        system.assertEquals(expected, result);
   }
   
   
   
   private static testMethod void testEstimateTTR()
   {
        Integer result = EstimateTTR();
        system.assertEquals(true, (result <= 10));      
   } 
}