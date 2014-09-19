/*
Developer Name   : Mick Nicholson (BrightGen Ltd)
Deployment Date  : 
Description      : EmailMessage utility class
*/ 

public class EmailMessageUtils {

    private static string emailPCCW = 'customer.service@vertu.com';
    private static string emailAxiom = 'customer.serviceae@vertu.com';
    private static string originPCCW = 'Email - PCCW';
    private static string originAxiom = 'Email - Axiom';
    private static string statusNew = 'New';

    //method to check if the EMail Message has been added to a Closed Case  
    public static void checkForClosedCases(List<EmailMessage> newEmailMessages)
    {
        //Create a map of Cases and all related Emails that have just been added
        Map <Id, List<Id>> caseIdEmailMessageIds = new Map<Id,List<Id>>();
        for (EmailMessage emailMessage : newEmailMessages)
        {
            if (!caseIdEmailMessageIds.containsKey(emailMessage.ParentId))
            {
                caseIdEmailMessageIds.put(emailMessage.ParentId, new List<Id>());
            }
            caseIdEmailMessageIds.get(emailMessage.ParentId).add(emailMessage.Id);
        }
        
        //Get all closed cases for the new emails
        List<Case> closedCases = [Select Id from Case where Id in :caseIdEmailMessageIds.Keyset() and isClosed = true];
        
        List<Id> emailMessageIds = new List<Id>();
        //Create a list of EMail Message Ids from list passed through that relate to closed cases
        for(Case closedCase : closedCases)
        {
            for (id EmailMessageId : caseIdEmailMessageIds.get(closedCase.Id))
            {
                emailMessageIds.add(EmailMessageId);
            }
        }
        
        //If emails messaeg relate to closed cases
        if (!emailMessageIds.isEmpty())
        {
            //pass to future method
            createNewCaseAndReparentEmails(emailMessageIds);
        }
    }

@future 
    //Method to tak a list of email message ids, get all the data for the id,  create a new case and add these emailmessages to the new case
    public static void createNewCaseAndReparentEmails(List<id> emailMessages)
    {
        //Create a map of emailmessages by Id
        Map <Id, EmailMessage> originalEmailMessages = new Map <Id, EmailMessage>([Select Id, ParentId, BccAddress, ccAddress, FromAddress, FromName, HasAttachment, Headers, HtmlBody, Incoming, MessageDate, Subject, TextBody, toAddress from EmailMessage where id in : emailMessages]);
        
        //Create a map of Case Ids and all related Emails Messages 
        Map <Id, List<Id>> caseIdEmailMessageIds = new Map<Id,List<Id>>();
        for (EmailMessage emailMessage : originalEmailMessages.Values())
        {
            if (!caseIdEmailMessageIds.containsKey(emailMessage.ParentId))
            {
                caseIdEmailMessageIds.put(emailMessage.ParentId, new List<Id>());
            }
            caseIdEmailMessageIds.get(emailMessage.ParentId).add(emailMessage.Id);
        }
        
        Map<Id,Case> newCases = new Map<Id,Case>();
        //For each existing case Id, create a new case and link to original case
        
        //Fetching the assignment rules on case
        AssignmentRule AR =[select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
         
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        string Origin;
        for (Case originalCase : [Select id, AccountId, ContactId from Case where id in :caseIdEmailMessageIds.keyset()])
        {
            //Get first email message id for this case and use that id to set the case subject and description 
            id emailmessageid = caseIdEmailMessageIds.get(originalCase.Id)[0];
            if ((originalEmailMessages.get(emailmessageid).toAddress != null && originalEmailMessages.get(emailmessageid).toAddress.contains(emailAxiom)) ||
                (originalEmailMessages.get(emailmessageid).ccAddress != null && originalEmailMessages.get(emailmessageid).ccAddress.contains(emailAxiom)) ||
                (originalEmailMessages.get(emailmessageid).bccAddress != null && originalEmailMessages.get(emailmessageid).bccAddress.contains(emailAxiom)))
            {
                Origin = originAxiom;
            }
            else
            {
                Origin = originPCCW;
            }
            Case newCase = new Case(status=statusNew, 
                                    Origin=Origin, 
                                    AccountId=originalCase.AccountId,  
                                    ContactId=originalCase.ContactId, 
                                    parentId=originalCase.Id,
                                    Subject=originalEmailMessages.get(emailmessageid).subject,
                                    Description=originalEmailMessages.get(emailmessageid).TextBody);
            //Setting the DMLOption on Case instance
            newCase.setOptions(dmlOpts);
            newCases.put(newCase.ParentId, newCase);
        }
        if (newCases.size() > 0)
        {
            List<EmailMessage> emailMessagesToInsert = new List<EmailMessage>();
            
            //Insert new cases
            insert newCases.values();
            for (id originalCaseID : newCases.keyset())
            {
                //Create new Email Message and link to new Case
                string newCaseID = newCases.get(originalCaseID).Id;
                for (Id emailId : caseIdEmailMessageIds.get(originalCaseID))
                {
                    EmailMessage originalEmailMessage = originalEmailMessages.get(emailId);
                    //Remove Thread Id from subject and textbody. 
                    //This will ensure that replies to this email generate a new thread id to link it to the new case instead of the original
                    if (originalEmailMessage.Subject.Contains('[ ref:_'))
                    {
                        originalEmailMessage.Subject = originalEmailMessage.Subject.substring(0,originalEmailMessage.Subject.indexOf('[ ref:_'));
                    }
                    if (originalEmailMessage.TextBody.Contains('ref:_'))
                    {
                        originalEmailMessage.TextBody = originalEmailMessage.TextBody.substring(0,originalEmailMessage.TextBody.indexOf('ref:_'));
                    }
                    EmailMessage newEmailMessage = new EmailMessage(parentId = newCaseId,
                                                                    BccAddress = originalEmailMessage.BccAddress,
                                                                    ccAddress = originalEmailMessage.ccAddress, 
                                                                    FromAddress = originalEmailMessage.FromAddress,
                                                                    FromName = originalEmailMessage.FromName,
                                                                    Headers = originalEmailMessage.Headers,
                                                                    HtmlBody = originalEmailMessage.HtmlBody,
                                                                    Incoming = originalEmailMessage.Incoming,
                                                                    MessageDate = originalEmailMessage.MessageDate,
                                                                    Subject = originalEmailMessage.Subject,
                                                                    TextBody = originalEmailMessage.TextBody,
                                                                    toAddress = originalEmailMessage.toAddress);
                                                                    
                    emailMessagesToInsert.add(newEmailMessage);             
                }
            }
            //Insert new Email Messages
            if (emailMessagesToInsert.size() > 0)
            {
                insert emailMessagesToInsert;
            }
            //Delete original EmailMessages
            delete originalEmailMessages.Values();
        }
    }

                           /******************************/
                           /*                            */
                           /*   TEST METHODS             */
                           /*                            */
                           /******************************/
    static testMethod void testCheckForCLosedCases1() 
    {
        //Test Method to add a new incoming email to a closed case
        //This should create a new case, and add  the email to the new case and instead of the original case 
        
        //Create Closed Case
        Case originalCase = new Case(status='Closed');
        insert originalCase;
        
        //Check only 1 case exists 
        integer noOfCases = [Select count() from Case];
        system.assertEquals(1,noOfCases);
        
        //Create new EmailMessage and attach to Closed Case
        EmailMessage newEmail = new EmailMessage(parentId=originalCase.Id, 
                                                Incoming=true,
                                                BccAddress = 'testbcc@test.com',
                                                ccAddress = 'testcc@test.com', 
                                                FromAddress = 'testfrom@test.com',
                                                FromName = 'testfromname',
                                                Headers = 'testhdr',
                                                HtmlBody = 'testhtml',
                                                MessageDate = system.today(),
                                                Subject = 'testsubject [ ref:_00DL0276Vg._500L010Fit:ref ]',
                                                TextBody = 'testtext ref:_00DL0276Vg._500L010Fit:ref ]',
                                                toAddress = 'testto@test.com');
        Test.startTest();
            insert newEmail;
        Test.stopTest();
        
        //A new case should be created so total now 2
        noOfCases = [Select count() from Case];
        system.assertEquals(2,noOfCases);
        
        //Retrieve new case (id not equal to original case)
        Case testCase = [Select id,subject,description, origin from Case where id <> :originalCase.Id];
        system.assertequals(newEmail.Subject, testCase.subject);
        system.assertequals(newEmail.TextBody, testCase.description);
        system.assertequals(originPCCW, testCase.origin);
        
        //New Case should have 1 emailMessage attached
        integer NoOfNewEmails = [Select count() from EmailMessage where parentId = :testCase.Id];
        system.assertEquals(1,NoOfNewEmails);
        
        //Original Case should have 0 emailMessage attached as it should be deleted
        integer NoOfOldEmails = [Select count() from EmailMessage where parentId = :originalCase.Id];
        system.assertEquals(0,NoOfOldEmails);
        
        EmailMessage testEmail = [Select Subject, TextBody from EmailMessage where parentId = :testCase.Id];
        system.assertEquals('testsubject',testEmail.Subject);
        system.assertEquals('testtext',testEmail.TextBody);
    }
    
    static testMethod void testCheckForCLosedCases2() 
    {
        //Test Method to add a new incoming email to am open case
        //This should add the email to the open case, not creaete a new case and move the message 
        
        //Create Closed Case
        Case originalCase = new Case(status='Open');
        insert originalCase;
        
        //Check only 1 case exists 
        integer noOfCases = [Select count() from Case];
        system.assertEquals(1,noOfCases);
        
        //Create new EmailMessage and attach to Closed Case
        EmailMessage newEmail = new EmailMessage(parentId=originalCase.Id, 
                                                Incoming=true,
                                                FromAddress = 'testfrom@test.com',
                                                FromName = 'testfromname',
                                                Headers = 'testhdr',
                                                HtmlBody = 'testhtml',
                                                MessageDate = system.today(),
                                                Subject = 'testsubject',
                                                TextBody = 'testtext',
                                                toAddress = 'testto@test.com');
        Test.startTest();
            insert newEmail;
        Test.stopTest();
        
        //A new case should not have been created so total still 1
        noOfCases = [Select count() from Case];
        system.assertEquals(1,noOfCases);
        
        //Original Case should still have emailMessage attached as it should not have been deleted
        integer NoOfOldEmails = [Select count() from EmailMessage where parentId = :originalCase.Id];
        system.assertEquals(1,NoOfOldEmails);
    }

}