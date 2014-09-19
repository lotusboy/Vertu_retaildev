/*
Developer Name   : Mick Nicholson (BrightGen Ltd)
Deployment Date  : 
Description      : Handler class to process incoming JSON Request content from QForce 
				 : and will update Vertu Case, Email Message and Task records 
				 : Called from VertuInboundDataHandler class
*/ 
global class QForceInboundRequestDataHandler {

    // Top level wrapper class representing JSON content
    
    class jsonWrapper
    {
		public String notification_type;	
		public cls_request request;
		public cls_emaillist[] emaillist;
		public cls_tasklist[] tasklist;
		public cls_vcllist[] vcllist;
    }
    
	class cls_request {
		public String vregid;	
		public String qmemberid;	
		public String recordid;	
		public String parentrequestid;	
		public String requestnumber;	
		public String owner;	
		public String category;	
		public String type;	
		public String status;	
		public String source;	
		public String subject;	
		public String priority;	
		public String origin;	
		public String description;	
		public String completionsummary;	
		public String membername;	
		public String primaryemail;	
		public String mobile;	
		public String memberstatus;	
		public String level;	
		public DateTime firstoutbound;	
		public String totalrequestvalue;	
		public String requestcurrency;	
		public String country;	
		public String city;	
		public DateTime createddate;	
		public DateTime lastmodified;	
		public DateTime scheduledfittingcall;	
		public boolean suppressedfittingcall;
		public String statusdetail;	
		public String callattempt;	
	}
	class cls_emaillist {
		public String recordid;	
		public Boolean incoming;	
		public String toaddress;	
		public String fromaddress;	
		public String fromname;	
		public DateTime emaildate;	
		public String subject;	
		public String body;	
	}
	class cls_tasklist {
		public String recordid;	
		public String type;	
		public String status;	
		public Date taskdate;	
		public String subject;	
		public String owner;	
	}
	class cls_vcllist {
		public String recordid;	
		public String type;	
		public String title;	
		public Datetime startdate;	
		public Datetime enddate;	
		public String name;	
		public Boolean hide;	
		public String description;	
		public Datetime createddate;	
	}

    // Static objects
    
    static jsonWrapper j; 
    static Vertu_Account__c vertuAcc; 
    static Case caseToUpdate; 
    static CaseComment caseCommentToUpdate; 
    static id upsertedCaseID;
    static RecordType caseConciergeRT;
    static RecordType taskConciergeRT;
    static string vregid; 
    static Schema.SObjectField qForceId = Case.Fields.Q_Force_SFID__c;
	
	/**
     * Main method to process a member and its associated records
     *
     */
    public static void processRequest (Vertu_Inbound_Data__c inboundMember)
    {
		system.debug('MN*** in processRequest');
        // Local variable for json content      
        string jsonInput;   
        
        //jsonWrapper j; 
    	jsonInput = inboundMember.Inbound_Message__c;

        // Parse JSON
        try 
        {
            j = (jsonWrapper)JSON.deserialize(jsonInput, JsonWrapper.class);
    	
	        //Convert VregID into valid format
    		vregId = j.request.vregid.replace(';A:;','');
    		vregId = vregId.replace('V:','');
    		
    		//Get Vertu Account from this JSON Message
	        //List<Vertu_Account__c> vertuAccs = [Select Id, Account_Name__c, Account_Name__r.PersonContactId, VREG_ID_Vertu_Account__c From Vertu_Account__c where VREG_ID_Vertu_Account__c = :j.request.vregid];
	        List<Vertu_Account__c> vertuAccs = [Select Id, Account_Name__c, Account_Name__r.PersonContactId, VREG_ID_Vertu_Account__c From Vertu_Account__c where VREG_ID_Vertu_Account__c = :vregId];
	        //Vertu Account found
	        if (vertuAccs.size() == 1)
	        {
		       	vertuAcc = vertuAccs[0];
		        //Get Case for selected Vertu Account
		        if (inboundMember.Detail__c == VertuInboundDataHandler.QFORCEREQUESTUPDATE)
		        {
		        	string soqlQuery = 'Select ' + sObject_Utils.getFieldsSOQL(Case.SObjectType.getDescribe()) + ' from Case where Vertu_Account__c = \'' + vertuAcc.id + '\' and Q_Force_SFID__c = \'' + j.request.recordid + '\'';
					system.debug('MN*** soqlQuery = ' + soqlQuery);
					List<Case> casesToUpdate = database.query(soqlQuery);
					if (casesToUpdate.size() == 1)
					{
						caseToUpdate = casesToUpdate[0];
						soqlQuery = 'Select ' + sObject_Utils.getFieldsSOQL(CaseComment.SObjectType.getDescribe()) + ' from CaseComment where ParentId = \'' + caseToUpdate.id + '\'';
						List<CaseComment> caseCommentsToUpdate = database.query(soqlQuery);
						if (caseCommentsToUpdate.size() == 1)
						{
							caseCommentToUpdate = caseCommentsToUpdate[0];
						}
						else
						{
							caseCommentToUpdate = new CaseComment();
						}
					}
			        //Case not found, so treat as insert
			        else if(casesToUpdate.size() == 0)
			        {
			        	populateNewCaseFields();
					}
			        //Multiple Cases exist (this should never occur as field should be unique external id)
			        else 
			        {
			        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
			        	inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.MULTIPLECASEID + j.request.recordid;
					}
		        }
		        else if (inboundMember.Detail__c == VertuInboundDataHandler.QFORCEREQUESTINSERT)
		        {
		        	populateNewCaseFields();
		        }
		       
				//No errors so process record
				if (inboundMember.Status__c != VertuInboundDataHandler.STATUSERROR)
				{
					//Update case fields with details from json message
					updateCaseFields(inboundMember);
					
					//Save case details to database
					system.debug('MN*** about to upsert Cases');
					Database.upsertResult sr = database.upsert(caseToUpdate, qForceId);
					
					if (sr.isSuccess())
					{
						//Set new case id as required for child records and wont be set if it is a case insert  
						upsertedCaseId = sr.getId();
						//If any case comments to be upserted 
						system.debug('MN**** caseCommentToUpdate = ' + caseCommentToUpdate);
						//Save casecomment details to database if comment has been added 
						if (caseCommentToUpdate.CommentBody != null)
						{
							system.debug('MN**** about to upsert CaseComment');
							//Set Parent Id on case comment if doesn't already exist
							if (caseCommentToUpdate.ParentId == null)
							{
								caseCommentToUpdate.ParentId = upsertedCaseId;
							}
							sr = database.upsert(caseCommentToUpdate);
							if (!sr.isSuccess())
							{
					        	inboundMember.Status__c = VertuInboundDataHandler.STATUSWARNING;
					        	inboundMember.Detail__c = inboundMember.Detail__c + ' - Unable to update Case Comment: ' + Case.CaseNumber + ' error: ' + sr.getErrors()[0].message;
							}
						}
						processEmailMessages(inboundMember);
						processVCLHistory(inboundMember);
						processTasks(inboundMember);
					}
					else
					{
			        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
			        	inboundMember.Detail__c = inboundMember.Detail__c + ' - Unable to update Case: ' + Case.CaseNumber + ' error: ' + sr.getErrors()[0].message;
					}
				}
	        }
	        //Vertu Account not found
	        else if(vertuAccs.size() == 0)
	        {
	        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
	        	//inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.INVALIDCASEMEMBERID + j.request.vregid;
	        	inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.INVALIDCASEMEMBERID + vregId;
			}
	        //Multiple Vertu Accounts exist
	        else 
	        {
	        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
	        	//inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.MULTIPLEVREGID + j.request.vregid;
	        	inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.MULTIPLEVREGID + vregId;
			}
        }
        catch (JSONException e)
        {
            System.debug(e.getMessage());
	        inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
	        inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.INVALIDPARSE + e.getMessage();
        }
        catch (Exception e)
        {
        	System.debug(e.getMessage());
	        inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
	        inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.UNEXPECTEDERROR + e.getMessage();
        }
        
        //No Errors so set status to success
        if (inboundMember.Status__c != VertuInboundDataHandler.STATUSERROR)
        {
        	inboundMember.Status__c = VertuInboundDataHandler.STATUSSUCCESS;	
 	        inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.SUCCESSMESSAGE;
        }
        
        //Update Status
        try
        {
 			update inboundMember;
 			//Create a connection record to share updated record back to Qforce
 			ConnectionUtils.createQforcePartnerNetworkConnection(inboundMember.Id);
        }
        catch (Exception e)
        {
        	system.debug('Unable to update inboundMember status');	
        }
         
    }

    /**
    *  create a new case in storage to upsert
    */
          
    static void populateNewCaseFields()
    {
		caseToUpdate = new Case(Vertu_Account__c = vertuAcc.Id);
		caseConciergeRT = recordTypeUtils.GetRecordTypeByObjectandName('Case', recordTypeUtils.CASE_CONCIERGE_RECORD_TYPE);
		casetoUpdate.RecordTypeId = caseConciergeRT.Id;
		caseCommentToUpdate = new CaseComment();
    }

    /**
    *  Populate case fields with details from JSON message
    */
          
    static void updateCaseFields(Vertu_Inbound_Data__c inboundMember)
    {
    	system.debug('MN*** in updateCaseFields');
    	caseToUpdate.ContactId = vertuAcc.Account_Name__r.PersonContactId;
    	caseToUpdate.Q_Force_SFID__c = j.request.recordid;	
    	if (j.request.parentrequestid != null)
    	{
    		List<Case> parentCases = [Select Id from Case where Q_Force_SFID__c = :j.request.parentrequestid];
    		if (parentCases.size() == 1)
    		{
    			caseToUpdate.ParentId = parentCases[0].id;
    		}
    		else if (parentCases.size() == 0)
    		{
				inboundMember.Status__c = VertuInboundDataHandler.STATUSWARNING;
			    inboundMember.Detail__c = inboundMember.Detail__c + ' - Parent Case not found for Q Force SFID : ' + j.request.parentrequestid;
			}
    		else
    		{
 			     inboundMember.Status__c = VertuInboundDataHandler.STATUSWARNING;
			     inboundMember.Detail__c = inboundMember.Detail__c + ' - Duplicate Parent Cases for Q Force SFID: ' + j.request.parentrequestid;
    		}
		}
		caseToUpdate.Q_Force_Case_Number__c = j.request.requestnumber;	
		caseToUpdate.Concierge__c = j.request.owner;	
		caseToUpdate.Category__c = j.request.category;	
		caseToUpdate.Sub_Category__c = j.request.type;	
		caseToUpdate.Status = j.request.status;	
		caseToUpdate.Vertu_request_idea_source__c = j.request.source;	
		caseToUpdate.Subject = j.request.subject;	
		caseToUpdate.Priority = j.request.priority;	
		caseToUpdate.Origin = j.request.origin;	
		caseToUpdate.Request_Description__c = j.request.description;	
		caseCommentToUpdate.CommentBody = j.request.completionsummary;	
		caseToUpdate.Concierge_Contact_Name__c = j.request.membername;	
		caseToUpdate.Concierge_Member_Email__c = j.request.primaryemail;	
		caseToUpdate.Concierge_Member_Mobile__c = j.request.mobile;	
		caseToUpdate.Concierge_Member_Status__c = j.request.memberstatus;	
		caseToUpdate.Concierge_Member_Level__c = j.request.level;
		caseToUpdate.First_outbound_email__c = j.request.firstoutbound;
		if(j.request.totalrequestvalue != null)
		{
			caseToUpdate.Request_Value__c = Decimal.ValueOf(j.request.totalrequestvalue);
		}	
		caseToUpdate.Request_Value_Currency__c = j.request.requestcurrency;
		caseToUpdate.Request_Country__c = j.request.country;	
		caseToUpdate.Request_City__c = j.request.city;	
		caseToUpdate.Concierge_Last_Updated_Date__c = j.request.lastmodified;	
		caseToUpdate.Concierge_Create_Date__c = j.request.createddate;	
		caseToUpdate.Scheduled_Fitting_Call__c = j.request.scheduledfittingcall;	
		caseToUpdate.Suppressed_Fitting_Call__c = j.request.suppressedfittingcall;
		caseToUpdate.Status_Detail__c = j.request.statusdetail;	
		caseToUpdate.Call_Attempt__c = j.request.callattempt;	

        //Fetching the assignment rules on case
        AssignmentRule AR =[select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
         
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
		caseToUpdate.setOptions(dmlOpts);
    }
    /**
    *  Process all VCL History records from JSON message
    */

    static void processVCLHistory(Vertu_Inbound_Data__c inboundMember)
    {
		        
		//Get all existing VCL History records and delete from database
		List<VCL_History__c> VCLHistoryIds = [Select Id from VCL_History__c where Case__c = :upsertedCaseId];
		if (VCLHistoryIds.size() > 0)
		{
			Database.Deleteresult[] drs = database.delete(VCLHistoryIds);
			for (Database.Deleteresult dr : drs)
			{
				//Add any error messages to inbound member
				if (!dr.isSuccess())
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + '\n - Unable to delete VCL History: ' + dr.getId() + ' error: ' + dr.getErrors()[0].message;
				}
			}
		}
		
		List<VCL_History__c> VCLHistoryToInsert = new List<VCL_History__c>();
		
		//Process each VCL History record in JSON message
		for(cls_vcllist VCLHistory : j.vcllist)
		{
	    	VCL_History__c newVCLHistory = new VCL_History__c();
	    	newVCLHistory.Case__c = upsertedCaseId;	
			newVCLHistory.Q_Force_SFID__c = VCLHistory.recordid;	
			newVCLHistory.Type__c = VCLHistory.type;	
			newVCLHistory.Title__c = VCLHistory.title;	
			newVCLHistory.Start_Date__c = VCLHistory.startdate;	
			newVCLHistory.End_Date__c = VCLHistory.enddate;	
			newVCLHistory.Name__c = VCLHistory.name;	
			newVCLHistory.Hide__c = VCLHistory.hide;
			newVCLHistory.Description__c = VCLHistory.description;	
			newVCLHistory.Original_Created_Date__c = VCLHistory.createddate;	
	       	VCLHistoryToInsert.add(newVCLHistory);
		}
		
		//Insert VCL History records on database
		if (VCLHistoryToInsert.size() > 0)
		{
			Database.saveresult[] srs = database.insert(VCLHistoryToInsert, false);
			for (database.saveresult sr : srs)
			{
				//Add any error messages to inbound member
				if (!sr.isSuccess())
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + '\n - Unable to insert VCL History: ' + sr.getId() + ' error: ' + sr.getErrors()[0].message;
				}
			}
		}
    }
        
    /**
    *  Process all Task records from JSON message
    */
    static void processTasks(Vertu_Inbound_Data__c inboundMember)
    {
		        
		//Get Task Concierge Record Type        
		taskConciergeRT = recordTypeUtils.GetRecordTypeByObjectandName('Task', recordTypeUtils.TASK_CONCIERGE_RECORD_TYPE);

		//Get all existing Task records and delete from database
		List<Task> taskIds = [Select Id from Task where whatId = :upsertedCaseId];
		if (taskIds.size() > 0)
		{
			Database.Deleteresult[] drs = database.delete(taskIds);
			for (Database.Deleteresult dr : drs)
			{
				//Add any error messages to inbound member
				if (!dr.isSuccess())
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + '\n - Unable to delete Task: ' + dr.getId() + ' error: ' + dr.getErrors()[0].message;
				}
			}
		}
		
		List<Task> tasksToInsert = new List<Task>();
		
		//Process each Task record in JSON message
		for(cls_tasklist inputTask : j.tasklist)
		{
			Task newTask = new Task();
			newTask.recordTypeId = taskConciergeRT.Id;
			newTask.Q_Force_SFID__c = inputTask.recordid;	
			newTask.WhatId = upsertedCaseId;	
			newTask.Type = inputTask.type;	
			newTask.Status = inputTask.status;	
			newTask.ActivityDate = inputTask.taskdate;	
			newTask.Subject = inputTask.subject;
			newTask.Concierge_Name__c = inputTask.owner;
			tasksToInsert.add(newTask);
		}
		
		//Insert Task records on database
		if (tasksToInsert.size() > 0)
		{
			Database.saveresult[] srs = database.insert(tasksToInsert, false);
			for (database.saveresult sr : srs)
			{
				//Add any error messages to inbound member
				if (!sr.isSuccess())
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + '\n - Unable to insert Task: ' + sr.getId() + ' error: ' + sr.getErrors()[0].message;
				}
			}
		}
    }
        
    /**
    *  Process all Email Messages records from JSON message
    */
    static void processEmailMessages(Vertu_Inbound_Data__c inboundMember)
    {
		system.debug('MN*** in process EmailMessages');        
		//Get all existing Email Message records and delete from database
		List<EmailMessage> emailMsgIds = [Select Id from EmailMessage where ParentId = :upsertedCaseId];
		if (emailMsgIds.size() > 0)
		{
			Database.Deleteresult[] drs = database.delete(emailMsgIds);
			for (Database.Deleteresult dr : drs)
			{
				//Add any error messages to inbound member
				if (!dr.isSuccess())
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + '\n - Unable to delete Email Message: ' + dr.getId() + ' error: ' + dr.getErrors()[0].message;
				}
			}
		}
		
		List<EmailMessage> emailMessagesToInsert = new List<EmailMessage>();
		
		system.debug('MN*** j.emaillist = ' + j.emaillist);        
		//Process each Email Message record in JSON message
		for(cls_emaillist EmailMsg : j.emaillist)
		{
			EmailMessage newEmailMsg = new EmailMessage();
			newEmailMsg.ParentId = upsertedCaseId;
			newEmailMsg.Incoming = EmailMsg.incoming;
			newEmailMsg.ToAddress = EmailMsg.toaddress;	
			newEmailMsg.FromAddress = EmailMsg.fromaddress;	
			newEmailMsg.FromName = EmailMsg.fromname;	
			newEmailMsg.MessageDate = EmailMsg.emaildate;
			newEmailMsg.Subject = EmailMsg.subject;	
			newEmailMsg.HtmlBody = EmailMsg.body;	
			emailMessagesToInsert.add(newEmailMsg);
		}
		
		system.debug('MN*** emailMessagesToInsert = ' + emailMessagesToInsert);        
		//Insert Email Messages records on database
		if (emailMessagesToInsert.size() > 0)
		{
			Database.saveresult[] srs = database.insert(emailMessagesToInsert, false);
			for (database.saveresult sr : srs)
			{
				//Add any error messages to inbound member
				if (!sr.isSuccess())
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + '\n - Unable to insert Email Message: ' + sr.getId() + ' error: ' + sr.getErrors()[0].message;
				}
			}
		}
    }
        

    /*******************************/
    /*
    /*  Test Methods
    /*
    /*******************************/

	static testMethod void testInvalidDetail() {
        //Vertu_Inbound_Data__c.Detail__c contains the source system and record that is being updated.
        //This method checks the correct error messages are returned when an invalid value is inserted
        
        //Creaet Account and Vertu Account to be updated
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc1 = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');

		//Get test Json message from static resource
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceRequestInsertTestJsonMessage'];
		string json = testJson[0].body.toString();
        
        //Create Vertu_Inbound_Data__c jrecord with invalid Detail__c value
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();
        inboundMember.Detail__c = VertuInboundDataHandler.QFORCE;
        inboundMember.Inbound_Message__c = json;
        
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Error and Unknonw Source
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.assertEquals(VertuInboundDataHandler.STATUSERROR, testInboundMember.Status__c);
		string testDetail = inboundMember.Detail__c + ': Unknown Source';
        system.assertEquals(testDetail, testInboundMember.Detail__c);
	}
	
	static testMethod void testInvalidParse() {
        //Create a json message which will fail the parse and ensure correct error messages are returned
        
        //Creaet Account and Vertu Account to be updated
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc1 = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');

        //Create Vertu_Inbound_Data__c json message with invalid Detail__c value
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();

		String json = '{'+
		'	"notification_type":"",'+
		'  \"request\":{' +
		'	    \"vregid\":\"001000000101010\",' +
		'		\"invlaidfield\":\"001000000101010\"'+
		'	}'+
		'	]'+
		'}';

		system.debug('MN*** json = ' + json);
        inboundMember.Detail__c = VertuInboundDataHandler.QFORCEREQUESTINSERT;
        inboundMember.Inbound_Message__c = json;
        
        system.debug('MN*** about to start test');
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Error and Invalid Parse
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.debug('MN*** testInboundMember = ' + testInboundMember);
		system.assertEquals(VertuInboundDataHandler.STATUSERROR, testInboundMember.Status__c);
		string testDetail = inboundMember.Detail__c + VertuInboundDataHandler.INVALIDPARSE;
		system.assert(testInboundMember.Detail__c.startswith(testDetail));
	}
	
	static testMethod void testInvalidCASEMEMBERID() {
        //Create a json message which has a VREGID which does not exist in Vertu and ensure correct error messages are returned
        
        //Creaet Account and Vertu Account
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc = UnitTestHelper.createVertuAccount(testAcc.Id, '002000000202020');
		
        //Get test Json message from static resource
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceRequestInsertTestJsonMessage'];
		string json = testJson[0].body.toString();
        
        //Create Vertu_Inbound_Data__c record
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();
		inboundMember.Detail__c = VertuInboundDataHandler.QFORCEREQUESTINSERT;
        inboundMember.Inbound_Message__c = json;
        
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Error and Invalid Vregid message
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.assertEquals(VertuInboundDataHandler.STATUSERROR, testInboundMember.Status__c);
		string testDetail = inboundMember.Detail__c + VertuInboundDataHandler.INVALIDCASEMEMBERID;
		system.debug('MN*** testDetail = ' + testDetail);
		system.debug('MN*** Detail__c = ' + testInboundMember.Detail__c);
		system.assert(testInboundMember.Detail__c.startswith(testDetail));
	}

	static testMethod void testMultipleVREGID() {
        //Create a json message which has a VREGID which matches multiple Vertu Accounts and ensure correct error messages are returned
        
        //Creaet Account and Vertu Account to be updated
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc1 = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');
		Vertu_Account__c testVertuAcc2 = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');
		
        //Get test Json message from static resource
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceRequestInsertTestJsonMessage'];
		string json = testJson[0].body.toString();

        //Create Vertu_Inbound_Data__c record
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();
		inboundMember.Detail__c = VertuInboundDataHandler.QFORCEREQUESTINSERT;
        inboundMember.Inbound_Message__c = json;
        
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Error and Multiple Vregid message
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.assertEquals(VertuInboundDataHandler.STATUSERROR, testInboundMember.Status__c);
		string testDetail = inboundMember.Detail__c + VertuInboundDataHandler.MULTIPLEVREGID;
		system.assert(testInboundMember.Detail__c.startswith(testDetail));
	}

	static testMethod void testValidInsertMessage() {
        //Create a json message which has a VREGID which matches and ensure correct records are inserted
        
        //Create Account, Vertu Account to be updated
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');
		
        //Get test Json message from static resource
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceRequestInsertTestJsonMessage'];
		string json = testJson[0].body.toString();
        
        //Create Vertu_Inbound_Data__c record
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();
		inboundMember.Detail__c = VertuInboundDataHandler.QFORCEREQUESTINSERT;
        inboundMember.Inbound_Message__c = json;
        
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Success
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.assertEquals(VertuInboundDataHandler.STATUSSUCCESS, testInboundMember.Status__c);
		
		//Check Case record has been inserted
		List<Case> testCases = [Select id from Case where AccountId = :testAcc.Id];
		system.assertEquals(1,testCases.size());
	}

	static testMethod void testValidUpdateMessage() {
        //Create a json message which has a VREGID and Case Idwhich matches and ensure correct records are inserted
        
        //Creaet Account, Vertu Account and Case to be updated
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');
		Case testcase = UnitTestHelper.createCase(testAcc.Id, testVertuAcc.Id, '002000000202020');
		system.debug('MN*** testcase = ' + testcase);
        //Get test Json message from static resource
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceRequestUpdateTestJsonMessage'];
		string json = testJson[0].body.toString();
		
        //Create Vertu_Inbound_Data__c record
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();
		inboundMember.Detail__c = VertuInboundDataHandler.QFORCEREQUESTUPDATE;
        inboundMember.Inbound_Message__c = json;
        
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Success
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.debug('MN*** testInboundMember.Status__c = ' + testInboundMember.Status__c);
		system.debug('MN*** testInboundMember.Detail__c = ' + testInboundMember.Detail__c);
		system.assertEquals(VertuInboundDataHandler.STATUSSUCCESS, testInboundMember.Status__c);
		
		//Check Email record has been inserted
		List<EmailMessage> testEmails = [Select id from EmailMessage where ParentId = :testCase.Id];
		system.assertEquals(1,testEmails.size());
		
		//Check Task record has been inserted
		List<Task> testTasks = [Select id from Task where WhatId = :testCase.Id];
		system.assertEquals(1,testTasks.size());
		
		//Check VCL History record has been inserted
		List<VCL_History__c> testVCL = [Select id from VCL_History__c where Case__c = :testCase.Id];
		system.assertEquals(1,testVCL.size());
	}

	static testMethod void testUpdateForMissingCase() {
        //Create a json message which has a valid VREGID but has a CaseId which does not exist and ensure the case is inserted
        
        //Creaet Account, Vertu Account to be updated
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');
		
        //Get test Json message from static resource
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceRequestUpdateTestJsonMessage'];
		string json = testJson[0].body.toString();
        
        //Create Vertu_Inbound_Data__c record
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();
		inboundMember.Detail__c = VertuInboundDataHandler.QFORCEREQUESTUPDATE;
        inboundMember.Inbound_Message__c = json;
        
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Success
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.debug('MN*** testInboundMember.Status__c = ' + testInboundMember.Status__c);
		system.debug('MN*** testInboundMember.Detail__c = ' + testInboundMember.Detail__c);
		system.assertEquals(VertuInboundDataHandler.STATUSSUCCESS, testInboundMember.Status__c);
		
		//check case has been inserted
		List<Case> testCases = [select id, Q_Force_SFID__c from Case where AccountId = :testAcc.ID];
		system.assertEquals(1,testCases.size());
	}

	static testMethod void testProperties() {
        DateTime testNow = system.Now();
        Date testToday = system.Today();
        
        //Test Getter and Setter methods for properties
        //Essentially this is for code coverage as some of the fields in the wrapper class are not used within the main body of the code
		        
        JsonWrapper testJson = new JsonWrapper();
        
        //Notification Type
        testJson.notification_type = 'testnotificationtype';
        system.assertEquals('testnotificationtype', testJson.notification_type);
        
        //Request fields
        testJson.request = new cls_request();
        testJson.request.vregid = 'testvregid';
        system.assertEquals('testvregid', testJson.request.vregid);
        testJson.request.qmemberid = 'testqmemberid';
        system.assertEquals('testqmemberid', testJson.request.qmemberid);
        testJson.request.recordid = 'testrecordid';
        system.assertEquals('testrecordid', testJson.request.recordid);
        testJson.request.parentrequestid = 'testparentrequestid';
        system.assertEquals('testparentrequestid', testJson.request.parentrequestid);
        testJson.request.requestnumber = 'testrequestnumber';
        system.assertEquals('testrequestnumber', testJson.request.requestnumber);
        testJson.request.owner = 'testowner';
        system.assertEquals('testowner', testJson.request.owner);
        testJson.request.category = 'testcategory';
        system.assertEquals('testcategory', testJson.request.category);
        testJson.request.type = 'testtype';
        system.assertEquals('testtype', testJson.request.type);
        testJson.request.status = 'teststatus';
        system.assertEquals('teststatus', testJson.request.status);
        testJson.request.source = 'testsource';
        system.assertEquals('testsource', testJson.request.source);
        testJson.request.subject = 'testsubject';
        system.assertEquals('testsubject', testJson.request.subject);
        testJson.request.priority = 'testpriority';
        system.assertEquals('testpriority', testJson.request.priority);
        testJson.request.origin = 'testorigin';
        system.assertEquals('testorigin', testJson.request.origin);
        testJson.request.description = 'testdescription';
        system.assertEquals('testdescription', testJson.request.description);
        testJson.request.completionsummary = 'testcompletionsummary';
        system.assertEquals('testcompletionsummary', testJson.request.completionsummary);
        testJson.request.membername = 'testmembername';
        system.assertEquals('testmembername', testJson.request.membername);
        testJson.request.primaryemail = 'testprimaryemail';
        system.assertEquals('testprimaryemail', testJson.request.primaryemail);
        testJson.request.mobile = 'testmobile';
        system.assertEquals('testmobile', testJson.request.mobile);
        testJson.request.memberstatus = 'testmemberstatus';
        system.assertEquals('testmemberstatus', testJson.request.memberstatus);
        testJson.request.level = 'testlevel';
        system.assertEquals('testlevel', testJson.request.level);
        testJson.request.firstoutbound = TestNow;
        system.assertEquals(TestNow, testJson.request.firstoutbound);
        testJson.request.totalrequestvalue = 'testtotalrequestvalue';
        system.assertEquals('testtotalrequestvalue', testJson.request.totalrequestvalue);
        testJson.request.requestcurrency = 'testrequestcurrency';
        system.assertEquals('testrequestcurrency', testJson.request.requestcurrency);
        testJson.request.country = 'testcountry';
        system.assertEquals('testcountry', testJson.request.country);
        testJson.request.city = 'testcity';
        system.assertEquals('testcity', testJson.request.city);
        testJson.request.createddate = TestNow;
        system.assertEquals(TestNow, testJson.request.createddate);
        testJson.request.lastmodified = TestNow;
        system.assertEquals(TestNow, testJson.request.lastmodified);
        testJson.request.scheduledfittingcall = TestNow;
        system.assertEquals(TestNow, testJson.request.scheduledfittingcall);
        testJson.request.suppressedfittingcall = true;
        system.assertEquals(true, testJson.request.suppressedfittingcall);
        testJson.request.statusdetail = 'teststatusdetail';
        system.assertEquals('teststatusdetail', testJson.request.statusdetail);
        testJson.request.callattempt = 'testcallattempt';
        system.assertEquals('testcallattempt', testJson.request.callattempt);
        
        //Email 
        testJson.emaillist = new List<cls_emaillist>();
        cls_emaillist el = new cls_emaillist();
        el.recordid = 'testrecordid';
        el.incoming = true;
        el.toaddress = 'testtoaddress';
        el.fromaddress = 'testfromaddress';
        el.fromname = 'testfromname';
        el.emaildate = TestNow;
        el.subject = 'testsubject';
        el.body = 'testbody';
        testJson.emaillist.add(el);
        system.assertEquals('testrecordid', testJson.emaillist[0].recordid);
        system.assertEquals(true, testJson.emaillist[0].incoming);
        system.assertEquals('testtoaddress', testJson.emaillist[0].toaddress);
        system.assertEquals('testfromaddress', testJson.emaillist[0].fromaddress);
        system.assertEquals('testfromname', testJson.emaillist[0].fromname);
        system.assertEquals(TestNow, testJson.emaillist[0].emaildate);
        system.assertEquals('testsubject', testJson.emaillist[0].subject);
        system.assertEquals('testbody', testJson.emaillist[0].body);
        
        //Tasks 
        testJson.tasklist = new List<cls_tasklist>();
        cls_tasklist tl = new cls_tasklist();
        tl.recordid = 'testrecordid';
        tl.type = 'testtype';
        tl.status = 'teststatus';
        tl.taskdate = testToday;
        tl.subject = 'testsubject';
        tl.owner = 'testowner';
        testJson.tasklist.add(tl);
        system.assertEquals('testrecordid', testJson.tasklist[0].recordid);
        system.assertEquals('testtype', testJson.tasklist[0].type);
        system.assertEquals('teststatus', testJson.tasklist[0].status);
        system.assertEquals(testToday, testJson.tasklist[0].taskdate);
        system.assertEquals('testsubject', testJson.tasklist[0].subject);
        system.assertEquals('testowner', testJson.tasklist[0].owner);
        
        //VCL History 
        testJson.vcllist = new List<cls_vcllist>();
        cls_vcllist vl = new cls_vcllist();
        vl.recordid = 'testrecordid';
        vl.type = 'testtype';
        vl.title = 'testtitle';
        vl.startdate = TestNow;
        vl.enddate = TestNow;
        vl.name = 'testname';
        vl.hide = true;
        vl.description = 'testdescription';
        vl.createddate = TestNow;
        testJson.vcllist.add(vl);
        system.assertEquals('testrecordid', testJson.vcllist[0].recordid);
        system.assertEquals('testtype', testJson.vcllist[0].type);
        system.assertEquals('testtitle', testJson.vcllist[0].title);
        system.assertEquals(TestNow, testJson.vcllist[0].startdate);
        system.assertEquals(TestNow, testJson.vcllist[0].enddate);
        system.assertEquals('testname', testJson.vcllist[0].name);
        system.assertEquals(true, testJson.vcllist[0].hide);
        system.assertEquals('testdescription', testJson.vcllist[0].description);
        system.assertEquals(TestNow, testJson.vcllist[0].createddate);
        
	}

}