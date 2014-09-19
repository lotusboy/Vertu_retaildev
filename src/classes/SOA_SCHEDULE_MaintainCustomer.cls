/*************************************************
SOA_SCHEDULE_MaintainCustomer
Test Class:

Class for helping scheduling the batch job for SOA customer maintain(update,) 

Author: Mahfuz Choudhury
Created Date: 20/06/2014

**************************************************/

global class SOA_SCHEDULE_MaintainCustomer implements Schedulable{
    //Declare a set to hold ids of the records to process
    global Set<Id> CustomerToProcess = new Set<Id>();
    
    global void execute(SchedulableContext sc)
    {
        //First check if a batch job can be submitted using CanSubmit method of ScheduleUtils class
        if (ScheduleUtils.CanSubmitJob())
        {
            //Create an instance of the batch class here
            SOA_BATCH_CustomerMaintain CustomerMaintainBatch = new SOA_BATCH_CustomerMaintain();
            CustomerMaintainBatch.AccountIdsToProcess.Addall(CustomerToProcess);
            
            System.debug('Account ids to be processed from batch class---------------------->>>>'+CustomerMaintainBatch.AccountIdsToProcess);
            
            //Submit batch job with batch size set to 1
            //This has been added to prevent test class failure
            if(!Test.isRunningTest())
                ID batchprocessid = Database.executeBatch(CustomerMaintainBatch, 1);
            else if(Test.isRunningTest())
                batchprocessid = Database.executeBatch(CustomerMaintainBatch); 
                
        }
        else
        {
            //If a job can not be submitted now send it back to where it came from for resubmission
            SOA_WSO_MaintainCustomer.UpdateCustomerRequestBatch(CustomerToProcess);
        }
    }
}