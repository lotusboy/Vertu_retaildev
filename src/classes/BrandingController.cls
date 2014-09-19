/**
* K Hart 20/12/2012
* Vertu Branding Controller Mock-Up
* Framework for custom landing page
*/

public class BrandingController {
    public String json;
    public BrandingController() {
    }
    public List<Lead> getMyLeads() {
        String CurrentUserId = UserInfo.getUserId();   
        List<Lead> myVar = [select id, name, LeadSource from Lead where OwnerId =: CurrentUserId AND Status != 'xxxAccepted' And isConverted = False limit 10];        
        return myVar;
    }
    
    public List<Lead> getLeadsInbox()
    {
       String CurrentUserId = UserInfo.getUserId();   
        List<Lead> myVar = [select id, name, LeadSource from Lead where OwnerId !=: CurrentUserId AND Status != 'xxxAccepted' And isConverted = False limit 10];        
        return myVar;
    
    }
    public PageReference acceptLead() {
          
       String LeadId = ApexPages.currentPage().getParameters().get('LeadId');
       System.Debug('LeadId: '+LeadId);
       Lead l = [Select Id, OwnerId from Lead where Id =: LeadId];
       l.OwnerId = UserInfo.getUserid();
       update l;
       return null;    
    } 

    public List<Task> getMyTasks() {
        String CurrentUserId = UserInfo.getUserId();        
        List<Task> TaskList = new List<Task>();        
        TaskList = [select id, WhatId, WhoId, ActivityDate, subject, status, priority, Description,  ReminderDateTime, IsReminderSet,isClosed from Task where isClosed = false and OwnerId = :CurrentUserId];
        return TaskList;
        }
    // Recent Items Mapping Class

    public Class RecentItems {
        public String type { get;set; }
        public String url { get;set; }
        public String id { get;set; }  
        }
         
    public String getMyRecentItems() {
        /*
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        request.setEndPoint('https://na12.salesforce.com/services/data/v26.0/recent');
        request.setMethod('GET');
        HttpResponse response = httpProtocol.send(request);
        String jsonInput = response.getBody();
        system.debug('===>'+jsonInput);
        
        String cleanerString = jsonInput.removeEnd(']');
        String cleanString = cleanerString.removeStart('[');  
                
        //String TestString = '{"type":"user","url":"www.dummy.com","id":"FERRARI"}';
        RecentItems TST = (RecentItems)System.JSON.deserialize(cleanString, RecentItems.class); 
        //return TST;
        */  
        String msg = 'Recent Items will be placed on a standard Page';
        return msg;     
        }             
}