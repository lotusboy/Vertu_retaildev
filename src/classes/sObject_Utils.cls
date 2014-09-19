/*
Developer Name   : Mick Nicholson (BrightGen Ltd)
Deployment Date  : 
Description      : Generic sObject class 
*/
public class sObject_Utils {

	//getFieldsSoql - returns a string of all fields separated by a comma for the DescribeObjectResult that has been passed
	// 				  This will allow a select statement to be generated to bring back all fields
    public static string getFieldsSOQL(Schema.DescribeSObjectResult sObjectResult)
	{
		string fieldList = '';
		for(String fieldName : sObjectResult.Fields.getMap().keySet())
		{
			fieldList += fieldName + ', ';
		}
		fieldList = fieldList.substring(0, fieldList.length() - 2);
		return fieldList;
	}

   /*********************************************************
    *                                                       *
    *               TEST METHODS                            *
    *                                                       *
    *********************************************************/

	private static testMethod void testgetFieldSOQL()
	{
		String results = '';
		Schema.DescribeSObjectResult res = Account.SObjectType.getDescribe();
 		results = getFieldsSOQL(res);
		system.assert(results.toLowercase().contains('name'));
	}
}