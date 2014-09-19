/*************************************************
BG_MessageMakerUtility
Test Class:

Class for making messages to send to the approprate recepients

Author: Mahfuz Choudhury
Created Date: 20/06/2014

**************************************************/

public class BG_MessageMakerUtility {

    //This method creates email message and return it to the caller class
    public static Messaging.SingleEmailMessage FormEmailMessage(String[] receipient, String subject, String body)
    {   
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        if(!Test.isRunningTest())
        {
            mail.setToAddresses(receipient);
            mail.setHtmlBody(body); 
            mail.setSubject(subject);   
        }
        
        else if(Test.isRunningTest())
        {
            List<String> ToAddress = new List<String> { 'Test@Vertu.com'};
            mail.setToAddresses(ToAddress);
            mail.setHtmlBody('Test Body');
            mail.setSubject('Test Subject');
        }
 
        return mail;
    }
    
    //This method retrieves the email addresses from custom setting
    Public static string[] EmailAddressesfromCS()
    {
        List<SOA_Email_Receipient__c> receiver = SOA_Email_Receipient__c.getAll().values();
        List<String> emailreceiver = new List<String>();
        if(receiver != NULL)
        {
            for(integer i = 0;i<receiver.size(); i++)
            {
                emailreceiver.add(receiver[i].email__c);   
            }
            return emailreceiver;
        }
        else 
        {
            return emailreceiver = new List<String>{'support@vertu.com'};    
        }       
    }
}