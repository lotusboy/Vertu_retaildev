/*************************************************
BG_SheduleUtilityHelper 
Test Class:

Class for helping scheduling utility

Author: Mahfuz Choudhury
Created Date: 20/06/2014

**************************************************/

public class BG_SheduleUtilityHelper {
    
    //Declare an enum type to accomodate different job types here..
    public enum ScheduleJobTypes
    {
        ProcessSOACustomerUpdate
    }

    //Declare a Constant name for customer update batch job 
    @TestVisible
    private static final string JOB_NAME_CUSTOMERUPDATE = 'ProcessSOACustomerUpdate';

}