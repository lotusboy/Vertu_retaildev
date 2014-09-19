/*************************************************
BatchHelper
Test Class: 

Class to hold the utility methods for Batch Apex 

Author: Mahfuz Choudhury
Created Date: 30/06/2014
Changes:

**************************************************/

public class BatchHelper {
    
    //Method to return the AsyncApexJob by id
    Public static AsyncApexJob GetApexJobDetailsByID(ID AsyncJobId)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                 TotalJobItems, CreatedBy.Email
                          FROM   AsyncApexJob
                          WHERE Id = :AsyncJobId];
        
        return a;
    }
}