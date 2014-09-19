/*
Developer Name   : Mick Nicholson (BrightGen Ltd)
Deployment Date  : 
Description      : Handler class to process incoming JSON Member content from QForce 
				 : and will update Vertu Customer, Member Passport, Member Family, Member Loyalty and Marketing Preference records 
				 : Called from VertuInboundDataHandler class
*/ 
global class QForceInboundMemberDataHandler {

    // Top level wrapper class representing JSON content
    class jsonWrapper
    {
        public String notification_type {get;set;}
		public Member member {get;set;}
		public PassportList[] passportlist {get;set;}
		public LoyaltySchemeList[] loyaltyschemelist {get;set;}
		public FamilyList[] familylist {get;set;}
    }
        
	// Inner classes        
    public class Member {
		public Key key {get;set;}
		public Details details {get;set;}
	}

	public class Key {
		public String vregid {get;set;}
	}
	
	public class Details {
		public String qmemberid {get;set;}
		public NameFields name {get;set;}
		public EmailFields email {get;set;}
		public PhoneFields phone {get;set;}
		public AddressFields address {get;set;}
		public Date dob {get;set;}
		public String dedicatedmanager {get;set;}
		public String conciergelanguage {get;set;}
		public String company {get;set;}
		public String cars {get;set;}
		public String writtenlanguage {get;set;}
		public Date ultimaterenewaldate {get;set;}
		public Boolean tandc {get;set;}
		public String status {get;set;}
		public Boolean serviceterms {get;set;}
		public Date renewaldate {get;set;}
		public String religion {get;set;}
		public String profession {get;set;}
		public String preferredlanguage {get;set;}
		public String preferredcontact {get;set;}
		public String owningoffice {get;set;}
		public String otherlanguage {get;set;}
		public Boolean oktosms {get;set;}
		public Boolean oktomail {get;set;}
		public Boolean oktoemail {get;set;}
		public Boolean oktocall {get;set;}
		public String numberrequests6months {get;set;}
		public String numberrequests12months {get;set;}
		public String numberrequests {get;set;}
		public Boolean neveremail {get;set;}
		public Boolean nevercall {get;set;}
		public String nationality {get;set;}
		public String memdate2desc {get;set;}
		public Date memdate2 {get;set;}
		public String memdate1desc {get;set;}
		public Date memdate1 {get;set;}
		public String marital {get;set;}
		public String level {get;set;}
		public DateTime lastrequestdate {get;set;}
		public String lastrequest {get;set;}
		public String jobtitle {get;set;}
		public String industry {get;set;}
		public String gender {get;set;}
		public String entitlementreason {get;set;}
		public Interests interests {get;set;}
	}
	
	//Name fields are grouped together
	public class NameFields {
		public String salutation {get;set;}
		public String preferred {get;set;}
		public String phonetic {get;set;}
		public String middle {get;set;}
		public String local {get;set;}
		public String last {get;set;}
		public String first {get;set;}
		public String assistant {get;set;}
	}

	//Email fields are grouped together
	public class EmailFields {
		public String third {get;set;}
		public String second {get;set;}
		public String primary {get;set;}
		public String fourth {get;set;}
		public String fifth {get;set;}
	}

	//Phone fields are grouped together
	public class PhoneFields {
		public String work {get;set;}
		public String mobile {get;set;}
		public String home {get;set;}
		public String fax {get;set;}
		public String assistant {get;set;}
		public String altmobile {get;set;}
		public String althome {get;set;}
	}

	//Address fields are grouped together
	public class AddressFields {
		public String thirdzip {get;set;}
		public String thirdtype {get;set;}
		public String thirdstreet {get;set;}
		public String thirdstate {get;set;}
		public String thirdcountry {get;set;}
		public String thirdcity {get;set;}
		public String secondzip {get;set;}
		public String secondtype {get;set;}
		public String secondstreet {get;set;}
		public String secondstate {get;set;}
		public String secondcountry {get;set;}
		public String secondcity {get;set;}
		public String primaryzip {get;set;}
		public String primarytype {get;set;}
		public String primarystreet {get;set;}
		public String primarystate {get;set;}
		public String primarycountry {get;set;}
		public String primarycity {get;set;}
		public String fourthzip {get;set;}
		public String fourthtype {get;set;}
		public String fourthstreet {get;set;}
		public String fourthstate {get;set;}
		public String fourthcountry {get;set;}
		public String fourthcity {get;set;}
	}
	
	//Interest fields are grouped together
	public class Interests {
		public String vipdesc {get;set;}
		public Boolean vip {get;set;}
		public String sportsfitness {get;set;}
		public String musicshows {get;set;}
		public String leisuretravelfrequency {get;set;}
		public String leisurecountries {get;set;}
		public String leisurecities {get;set;}
		public String holidaytypes {get;set;}
		public String finediningdesc {get;set;}
		public Boolean finedining {get;set;}
		public String fashiondesc {get;set;}
		public Boolean fashion {get;set;}
		public String entertainmentarts {get;set;}
		public String eliteworldsportdesc {get;set;}
		public Boolean eliteworldsport {get;set;}
		public String champagnewinedesc {get;set;}
		public Boolean champagnewine {get;set;}
		public String businesstravelfrequency {get;set;} 
		public Boolean businessintel {get;set;}
		public String businessintadesc {get;set;}
		public String businesscountries {get;set;}
		public String businesscities {get;set;}
		public String artdesc {get;set;}
		public Boolean art {get;set;}
	}

	//Multiple Family records can be received
	public class FamilyList {
		public String recordid {get;set;}
		public String name {get;set;}
		public String salutation {get;set;}
		public String relation {get;set;}
		public String notes {get;set;}
		public String dob {get;set;}
	}

	//Multiple passport records can be received
	public class PassportList {
		public String recordid {get;set;}
		public String fullname {get;set;}
		public String passportnumber {get;set;}
		public String nationality {get;set;}
		public String issuercode {get;set;}
		public String issuer {get;set;}
		public String issuedate {get;set;}
		public String expirydate {get;set;}
	}
	
	//Multiple Loyalty Scheme records can be received
	public class LoyaltySchemeList {
		public String recordid {get;set;}
		public String type {get;set;} 
		public String name {get;set;}
		public String loyaltynumber {get;set;}
		public String level {get;set;}
		public String hotel {get;set;}
		public String car {get;set;}
		public String airline {get;set;}
	}
    
    // Static objects
    
    static jsonWrapper j; 
    static Vertu_Account__c vertuAcc; 
    static Account acc; 
    static string vregid; 
    
    /**
     * Main method to process a member and its associated records
     *
     */
    public static void processMember (Vertu_Inbound_Data__c inboundMember)
    {
        // Local variable for json content      
        string jsonInput;   
        
        //jsonWrapper j; 
    	jsonInput = inboundMember.Inbound_Message__c;

        // Parse JSON
        try 
        {
            j = (jsonWrapper)JSON.deserialize(jsonInput, JsonWrapper.class);
    		//Convert VregID into valid format
    		vregId = j.member.key.vregid.replace(';A:;','');
    		vregId = vregId.replace('V:','');
    		//Get Vertu Account from this JSON Message
	        //List<Vertu_Account__c> vertuAccs = [Select Id, Account_Name__c, VREG_ID_Vertu_Account__c From Vertu_Account__c where VREG_ID_Vertu_Account__c = :j.member.key.vregid];
	        List<Vertu_Account__c> vertuAccs = [Select Id, Account_Name__c, VREG_ID_Vertu_Account__c From Vertu_Account__c where VREG_ID_Vertu_Account__c = :vregId];
	        //Vertu Account found
	        if (vertuAccs.size() == 1)
	        {
		       	vertuAcc = vertuAccs[0];
	        	 //Get person account for selected Vertu Account
		        string soqlQuery = 'Select ' + sObject_Utils.getFieldsSOQL(Account.SObjectType.getDescribe()) + ' from Account where id = \'' + vertuAcc.Account_Name__c + '\'';
				system.debug('MN*** soqlQuery = ' + soqlQuery);
				acc = database.query(soqlQuery);

				//Update account fields with details from json message
				updateAccountFields();
				
				//Save account details to database
				Database.saveResult sr = database.update(acc);
				
				if (sr.isSuccess())
				{
					//Successfully updated account so update child objects
					processMemberFamily(inboundMember);
					processMemberLoyalty(inboundMember);
					processMemberPassport(inboundMember);
				}
				else
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + ' - Unable to update Account: ' + acc.Name + ' error: ' + sr.getErrors()[0].message;
				}
	        }
	        //Vertu Account not found
	        else if(vertuAccs.size() == 0)
	        {
	        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
	        	//inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.INVALIDVREGID + j.member.Key.vregid;
	        	inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.INVALIDVREGID + vregId;
			}
	        //Multiple Vertu Accounts exist
	        else 
	        {
	        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
	        	//inboundMember.Detail__c = inboundMember.Detail__c + VertuInboundDataHandler.MULTIPLEVREGID + j.member.Key.vregid;
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
    *  Populate account fields with details from JSON message
    */
          
    static void updateAccountFields()
    {
    	//acc.Middle_Name__pc = j.member.details.name.middle;
    	acc.Name_in_local_language__pc = j.member.details.name.local;
    	acc.Preferred_Greeting__pc = j.member.details.name.preferred;
    	acc.Phonetic_pronunciation_of_rname__pc = j.member.details.name.phonetic;
    	//acc.PersonEmail = j.member.details.email.primary;
    	//acc.Secondary_Email_Address__pc = j.member.details.email.second;
    	//acc.Third_Email_Address__pc = j.member.details.email.third;
    	//acc.Fourth_Email_Address__pc = j.member.details.email.fourth;
    	//acc.Fifth_Email_Address__pc = j.member.details.email.fifth;
    	//acc.PersonHomePhone = j.member.details.phone.home;
    	//acc.PersonOtherPhone = j.member.details.phone.work;
    	//acc.PersonMobilePhone = j.member.details.phone.mobile;
    	acc.Concierge_Alternative_Mobile__pc = j.member.details.phone.altmobile;
    	acc.Concierge_Alternative_Phone__pc = j.member.details.phone.althome;
    	acc.Fax = j.member.details.phone.fax;
    	acc.PersonAssistantName = j.member.details.name.assistant;
    	acc.PersonAssistantPhone = j.member.details.phone.assistant;
    	acc.Preferred_method_of_contact__pc = j.member.details.preferredcontact;
    	acc.Address_Type__pc = j.member.details.address.primarytype;
    	acc.Dedicated_Concierge__pc = j.member.details.dedicatedmanager;
    	acc.Vertu_Written_Language__pc = j.member.details.writtenlanguage;
    	acc.Vertu_Spoken_Language__c = j.member.details.conciergelanguage;
    	acc.Last_entitlement_reason__pc = j.member.details.entitlementreason;
    	acc.Vertu_Terms_Accepted__pc = j.member.details.tandc;
    	acc.Concierge_Terms_Accepted__pc = j.member.details.serviceterms;
    	acc.Gender__pc = j.member.details.gender;
    	acc.PersonBirthdate = j.member.details.dob;
    	acc.Religion__pc = j.member.details.religion;
    	acc.Marital_Status__pc = j.member.details.marital;
    	//acc.Nationality__pc = j.member.details.nationality;
    	acc.Job_Title__pc = j.member.details.jobtitle;
    	acc.Profession__pc = j.member.details.profession;
    	acc.Company_Name__pc = j.member.details.company;
    	acc.Industry__pc = j.member.details.industry;
    	//acc.Name_in_local_language__pc = j.member.details.preferredlanguage; - Mot required??
    	acc.Other_languages_spoken__pc = j.member.details.otherlanguage;
    	acc.Cars_owned__pc = j.member.details.cars;
    	acc.Memorable_Date_1__pc = j.member.details.memdate1;
    	acc.Memorable_Date_1_Description__pc = j.member.details.memdate1desc;
    	acc.Memorable_Date_2__pc = j.member.details.memdate2;
    	acc.Memorable_Date_2_Description__pc = j.member.details.memdate2desc;
    	acc.Business_Travel_Frequency__pc = j.member.details.interests.businesstravelfrequency;
    	acc.Business_Countries_Visited__pc = j.member.details.interests.businesscountries;
    	acc.Business_Cities_Visited__pc = j.member.details.interests.businesscities;
    	acc.Leisure_Travel_Frequency__pc = j.member.details.interests.leisuretravelfrequency;
    	acc.Leisure_Countries_Visited__pc = j.member.details.interests.leisurecountries;
    	acc.Leisure_Cities_Visited__pc = j.member.details.interests.leisurecities;
    	acc.Never_Call__pc = j.member.details.nevercall;
    	acc.Never_Email__pc = j.member.details.neveremail;
    	if(j.member.details.numberrequests == null)
    	{
    		acc.Number_of_Requests__pc = 0;
	    }
    	else
    	{
    		acc.Number_of_Requests__pc = decimal.valueOf(j.member.details.numberrequests);	
    	}
    	if(j.member.details.numberrequests6months == null)
    	{
    		acc.Number_of_Requests_last_six_months__pc = 0;
	    }
    	else
    	{
    		acc.Number_of_Requests_last_six_months__pc = decimal.valueOf(j.member.details.numberrequests6months);
    	}
    	if(j.member.details.numberrequests12months == null)
    	{
    		acc.Number_of_Requests_12_months__pc = 0;
	    }
    	else
    	{
    		acc.Number_of_Requests_12_months__pc = decimal.valueOf(j.member.details.numberrequests12months);
    	}
    	if (j.member.details.lastrequest != null)
    	{
    		List<Case> lastCase = [Select Id from Case where Q_Force_SFID__c = :j.member.details.lastrequest];
    		if (lastCase.size() == 1)
    		{
    			acc.Last_Concierge_Request__pc = lastCase[0].Id;
    		}
    	}
    }
    
    /**
    *  Process all Family Member records from JSON message
    */
    static void processMemberFamily(Vertu_Inbound_Data__c inboundMember)
    {
		system.debug('MN*** in processMemberFamily');        
		//Get all existing Member Family records and store by Qforce SFDC Id
		Map<string, Member_Family__c> existingMemberFamilies = new map<string,Member_Family__c>();
		Map<string, boolean> existingMemberFamiliesFound = new map<string,boolean>();
		
		string soqlQuery = 'Select ' + sObject_Utils.getFieldsSOQL(Member_Family__c.SObjectType.getDescribe()) + ' from Member_Family__c where Vertu_Account__c = \'' + vertuAcc.Id + '\'';
		system.debug('MN*** soqlQuery = ' + soqlQuery);
																																											
		for (Member_Family__c existingMemberFamily :database.query(soqlQuery))
		{
			existingMemberFamilies.put(existingMemberFamily.Q_Force_SFID__c, existingMemberFamily);
			existingMemberFamiliesFound.put(existingMemberFamily.Q_Force_SFID__c, false);
		}
		system.debug('MN*** existingMemberFamilies size = ' + existingMemberFamilies.size());
		system.debug('MN*** existingMemberFamiliesFound size = ' + existingMemberFamiliesFound.size());
		
		List<Member_Family__c> memberFamilyToUpdate = new List<Member_Family__c>();
		
		//Process each Family Member record in JSON message
		for(FamilyList memberFamily : j.familylist)
		{
			if (existingMemberFamilies.containskey(memberFamily.recordid))
			{
				memberFamilyToUpdate.add(updateMemberFamilyFields(memberFamily,existingMemberFamilies.get(memberFamily.recordid).id));	
				existingMemberFamiliesFound.put(memberFamily.recordid,true);
			}
			//does not already exist so must be new record
			else
			{
				memberFamilyToUpdate.add(updateMemberFamilyFields(memberFamily,null));	
			}
		}
		
		//Check to see if any records are missing from the JSON record.
		//These will have been deleted on the QForce system so we will logically delete them
		for (string qforceId : existingMemberFamiliesFound.keyset())
		{
			if (existingMemberFamiliesFound.get(qforceId) != true)
			{
				memberFamilyToUpdate.add(deleteMemberFamily(existingMemberFamilies.get(qforceId)));	
			}
		}
		
		//Update member Family records on database
		if (memberFamilyToUpdate.size() > 0)
		{
			Database.Upsertresult[] srs = database.upsert(memberFamilyToUpdate, false);
			for (database.Upsertresult sr : srs)
			{
				//Add any error messages to inbound member
				if (!sr.isSuccess())
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + '\n - Unable to update Member Family: ' + sr.getId() + ' error: ' + sr.getErrors()[0].message;
				}
			}
		}
    }
        
    /**
    *  Populate member family fields with details from JSON message
    */
          
    static Member_Family__c updateMemberFamilyFields(FamilyList memberFamily, id vertuMemberFamilyId)
    {
    	Member_Family__c newMemberFamily = new Member_Family__c(Id = vertuMemberFamilyId, Vertu_Account__c = vertuacc.Id);
    	newMemberFamily.Q_Force_SFID__c = memberFamily.recordid;
    	//Only set person account on new records as field cannot be updated
    	if (vertuMemberFamilyId == null)
    	{
    		newMemberFamily.Person_Account__c = acc.Id;
    	}
    	if (memberFamily.dob != null)
    	{
    		newMemberFamily.Date_of_Birth__c = Date.ValueOf(memberFamily.dob);
    	}
    	newMemberFamily.Name__c = memberFamily.name;
    	newMemberFamily.Notes__c = memberFamily.notes;
    	newMemberFamily.Relation__c = memberFamily.relation;
    	newMemberFamily.Salutation__c = memberFamily.salutation;
    	newMemberFamily.Deleted__c = false;
    	return newMemberFamily;
    }
    
    /**
    *  Populate member family fields which have been deleted on QForce
    *  Remove link to person account and set deleted to true
    */
          
    static Member_Family__c deleteMemberFamily(Member_Family__c memberFamily)
    {
    	Member_Family__c deletedMemberFamily = new Member_Family__c(Id = memberFamily.Id);
    	deletedMemberFamily.Q_Force_SFID__c = memberFamily.Q_Force_SFID__c;
    	deletedMemberFamily.Person_Account__c = null;
    	deletedMemberFamily.Deleted__c = true;
    	return deletedMemberFamily;
    }

    /**
    *  Process all Loyalty Member records from JSON message
    */
    static void processMemberLoyalty(Vertu_Inbound_Data__c inboundMember)
    {
		        
		//Get all existing Member Loyalty records and store by Qforce SFDC Id
		Map<string, Member_Loyalty__c> existingMemberLoyalties = new map<string,Member_Loyalty__c>();
		Map<string, boolean> existingMemberLoyaltiesFound = new map<string,boolean>();
		
		string soqlQuery = 'Select ' + sObject_Utils.getFieldsSOQL(Member_Loyalty__c.SObjectType.getDescribe()) + ' from Member_Loyalty__c where Vertu_Account__c = \'' + vertuAcc.Id + '\'';
		for (Member_Loyalty__c existingMemberLoyalty :database.query(soqlQuery))
		{
			existingMemberLoyalties.put(existingMemberLoyalty.Q_Force_SFID__c, existingMemberLoyalty);
			existingMemberLoyaltiesFound.put(existingMemberLoyalty.Q_Force_SFID__c, false);
		}
		
		List<Member_Loyalty__c> memberLoyaltyToUpdate = new List<Member_Loyalty__c>();
		
		//Process each Loyalty Member record in JSON message
		for(LoyaltySchemeList memberLoyalty : j.loyaltyschemelist)
		{
			//If exists then update
			if (existingMemberLoyalties.containskey(memberLoyalty.recordid))
			{
				memberLoyaltyToUpdate.add(updateMemberLoyaltyFields(memberLoyalty,existingMemberLoyalties.get(memberLoyalty.recordid).id));	
				existingMemberLoyaltiesFound.put(memberLoyalty.recordid,true);
			}
			//does not already exist so must be new record
			else
			{
				memberLoyaltyToUpdate.add(updateMemberLoyaltyFields(memberLoyalty,null));	
			}
		}
		
		//Check to see if any records are missing from the JSON record.
		//These will have been deleted on the QForce system so we will logically delete them
		for (string qforceId : existingMemberLoyaltiesFound.keyset())
		{
			if (existingMemberLoyaltiesFound.get(qforceId) != true)
			{
				memberLoyaltyToUpdate.add(deleteMemberLoyalty(existingMemberLoyalties.get(qforceId)));	
			}
		}
		
		//Update member Loyalty records on database
		if (memberLoyaltyToUpdate.size() > 0)
		{
			Database.Upsertresult[] srs = database.upsert(memberLoyaltyToUpdate, false);
			for (database.Upsertresult sr : srs)
			{
				//Add any error messages to inbound member
				if (!sr.isSuccess())
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + '\n - Unable to update Member Loyalty: ' + sr.getId() + ' error: ' + sr.getErrors()[0].message;
				}
			}
		}
    }
        
    /**
    *  Populate member loyalty fields with details from JSON message
    */
          
    static Member_Loyalty__c updateMemberLoyaltyFields(LoyaltySchemeList memberLoyalty, id vertuMemberFamilyId)
    {
    	Member_Loyalty__c newMemberLoyalty = new Member_Loyalty__c(Id = vertuMemberFamilyId, Vertu_Account__c = vertuacc.Id);
    	newMemberLoyalty.Q_Force_SFID__c = memberLoyalty.recordid;
    	//Only set person account on new records as field cannot be updated
    	if (vertuMemberFamilyId == null)
    	{
    		newMemberLoyalty.Person_Account__c = acc.Id;
    	}
    	newMemberLoyalty.Membership_Level__c = memberLoyalty.level;
    	newMemberLoyalty.Membership_Number__c = memberLoyalty.loyaltynumber;
    	newMemberLoyalty.Programme__c = memberLoyalty.name;
    	if (memberLoyalty.airline != null)
    	{
    		newMemberLoyalty.Operator__c = memberLoyalty.airline;
    	}
    	if (memberLoyalty.car != null)
    	{
    		newMemberLoyalty.Operator__c = memberLoyalty.car;
    	}
    	if (memberLoyalty.hotel != null)
    	{
    		newMemberLoyalty.Operator__c = memberLoyalty.hotel;
    	}
    	newMemberLoyalty.Supplier_Type__c = memberLoyalty.type;
    	newMemberLoyalty.Deleted__c = false;
    	return newMemberLoyalty;
    }
    
    /**
    *  Populate member loyalty fields which have been deleted on QForce
    *  Remove link to person account and set deleted to true
    */
          
    static Member_Loyalty__c deleteMemberLoyalty(Member_Loyalty__c memberLoyalty)
    {
    	Member_Loyalty__c deletedMemberLoyalty = new Member_Loyalty__c(Id = memberLoyalty.Id);
    	deletedMemberLoyalty.Q_Force_SFID__c = memberLoyalty.Q_Force_SFID__c;
    	deletedMemberLoyalty.Person_Account__c = null;
    	deletedMemberLoyalty.Deleted__c = true;
    	return deletedMemberLoyalty;
    }

    /**
    *  Process all Passport Member records from JSON message
    */
    static void processMemberPassport(Vertu_Inbound_Data__c inboundMember)
    {
		        
		//Get all existing Member Loyalty records and store by Qforce SFDC Id
		Map<string, Member_Passport__c> existingMemberPassports = new map<string,Member_Passport__c>();
		Map<string, boolean> existingMemberPassportsFound = new map<string,boolean>();
		
		string soqlQuery = 'Select ' + sObject_Utils.getFieldsSOQL(Member_Passport__c.SObjectType.getDescribe()) + ' from Member_Passport__c where Vertu_Account__c = \'' + vertuAcc.Id + '\'';
		for (Member_Passport__c existingMemberPassport :database.query(soqlQuery))
		{
			existingMemberPassports.put(existingMemberPassport.Q_Force_SFID__c, existingMemberPassport);
			existingMemberPassportsFound.put(existingMemberPassport.Q_Force_SFID__c, false);
		}
		
		List<Member_Passport__c> memberPassportToUpdate = new List<Member_Passport__c>();
		
		//Process each Passport Member record in JSON message
		for(PassportList memberPassport : j.passportlist)
		{
			//If exists then update
			if (existingMemberPassports.containskey(memberPassport.recordid))
			{
				memberPassportToUpdate.add(updateMemberPassportFields(memberPassport,existingMemberPassports.get(memberPassport.recordid).id));	
				existingMemberPassportsFound.put(memberPassport.recordid,true);
			}
			//does not already exist so must be new record
			else
			{
				memberPassportToUpdate.add(updateMemberPassportFields(memberPassport,null));	
			}
		}
		
		//Check to see if any records are missing from the JSON record.
		//These will have been deleted on the QForce system so we will logically delete them
		for (string qforceId : existingMemberPassportsFound.keyset())
		{
			if (existingMemberPassportsFound.get(qforceId) != true)
			{
				memberPassportToUpdate.add(deleteMemberPassport(existingMemberPassports.get(qforceId)));	
			}
		}
		
		//Update member Passport records on database
		if (memberPassportToUpdate.size() > 0)
		{
			Database.Upsertresult[] srs = database.upsert(memberPassportToUpdate, false);
			for (database.Upsertresult sr : srs)
			{
				//Add any error messages to inbound member
				if (!sr.isSuccess())
				{
		        	inboundMember.Status__c = VertuInboundDataHandler.STATUSERROR;
		        	inboundMember.Detail__c = inboundMember.Detail__c + '\n - Unable to update Member Passport: ' + sr.getId() + ' error: ' + sr.getErrors()[0].message;
				}
			}
		}
    }
        
    /**
    *  Populate member loyalty fields with details from JSON message
    */
          
    static Member_Passport__c updateMemberPassportFields(PassportList memberPassport, id vertuMemberFamilyId)
    {
    	Member_Passport__c newMemberPassport = new Member_Passport__c(Id = vertuMemberFamilyId, Vertu_Account__c = vertuacc.Id);
    	newMemberPassport.Q_Force_SFID__c = memberPassport.recordid;
    	//Only set account on new records as field cannot be updated
    	if (vertuMemberFamilyId == null)
    	{
    		newMemberPassport.Account__c = acc.Id;
    	}
    	newMemberPassport.Issuing_Authority_Code__c = memberPassport.issuer;
    	if (memberPassport.expirydate != null)
    	{
    		newMemberPassport.Passport_Expiry_Date__c = Date.ValueOf(memberPassport.expirydate);
    	}
    	newMemberPassport.Passport_Full_Name__c = memberPassport.fullname;
    	if (memberPassport.issuedate != null)
    	{
    		newMemberPassport.Passport_Issue_Date__c = Date.ValueOf(memberPassport.issuedate);
    	}
    	newMemberPassport.Passport_Nationality__c = memberPassport.nationality;
    	newMemberPassport.Passport_Number__c = memberPassport.passportnumber;
    	newMemberPassport.Passport_Place_of_Issue__c = memberPassport.issuercode;
    	newMemberPassport.Deleted__c = false;
    	return newMemberPassport;
    }
    
    /**
    *  Populate member loyalty fields which have been deleted on QForce
    *  Remove link to person account and set deleted to true
    */
          
    static Member_Passport__c deleteMemberPassport(Member_Passport__c memberLoyalty)
    {
    	Member_Passport__c deletedMemberLoyalty = new Member_Passport__c(Id = memberLoyalty.Id);
    	deletedMemberLoyalty.Q_Force_SFID__c = memberLoyalty.Q_Force_SFID__c;
    	deletedMemberLoyalty.Account__c = null;
    	deletedMemberLoyalty.Deleted__c = true;
    	return deletedMemberLoyalty;
    }
    
    
    /*******************************/
    /*
    /*  Test Methods
    /*
    /*******************************/
    
	static testMethod void testInvalidDetail() {
        //Vertu_Inbound_Data__c.Detail__c contains the source system and record that is being updated.
        //This method checks the correct error messages are returned when an invalid value is inserted
        
        //Create Account and Vertu Account to be updated
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');
		
		//Get test Json message from static resource
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceMemberTestJsonMessage'];
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
		Vertu_Account__c testVertuAcc = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');
		
        //Create Vertu_Inbound_Data__c json message with invalid Detail__c value
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();

		String json = '{'+
		'	"notification_type":"",'+
		'	\"member\":{'+
		'		\"key\":{'+
		'			\"vregid\":\"001000000101010\"'+
		'			\"invlaidfield\":\"001000000101010\"'+
		'		},'+
		'	]'+
		'}';
        inboundMember.Detail__c = VertuInboundDataHandler.QFORCEMEMBER;
        inboundMember.Inbound_Message__c = json;
        
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Error and Invalid Parse
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.assertEquals(VertuInboundDataHandler.STATUSERROR, testInboundMember.Status__c);
		string testDetail = inboundMember.Detail__c + VertuInboundDataHandler.INVALIDPARSE;
		system.assert(testInboundMember.Detail__c.startswith(testDetail));
	}
	
	static testMethod void testInvalidVREGID() {
        //Create a json message which has a VREGID which does not exist in Vertu and ensure correct error messages are returned
        
        //Creaet Account and Vertu Account to be updated
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc = UnitTestHelper.createVertuAccount(testAcc.Id, '002000000202020');
		
        //Get test Json message from static resource
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceMemberTestJsonMessage'];
		string json = testJson[0].body.toString();
        
        //Create Vertu_Inbound_Data__c record
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();
		inboundMember.Detail__c = VertuInboundDataHandler.QFORCEMEMBER;
        inboundMember.Inbound_Message__c = json;
        
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Error and Invalid Vregid message
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.assertEquals(VertuInboundDataHandler.STATUSERROR, testInboundMember.Status__c);
		string testDetail = inboundMember.Detail__c + VertuInboundDataHandler.INVALIDVREGID;
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
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceMemberTestJsonMessage'];
		string json = testJson[0].body.toString();

        //Create Vertu_Inbound_Data__c record
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();
		inboundMember.Detail__c = VertuInboundDataHandler.QFORCEMEMBER;
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
	
	static testMethod void testValidMessage() {
        //Create a json message which has a VREGID which matches and ensure correct records are inserted
        
        //Creaet Account and Vertu Account to be updated
        Account testAcc = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry', 'testlanguage');
		Vertu_Account__c testVertuAcc1 = UnitTestHelper.createVertuAccount(testAcc.Id, '001000000101010');
		
        //Get test Json message from static resource which includes children (eg MemberFamily etc)
        List<StaticResource> testJson = [Select id, name, body, bodylength from StaticResource where name = 'QforceMemberTestJsonMessage'];
		string json = testJson[0].body.toString();

        //Create Vertu_Inbound_Data__c record
        Vertu_Inbound_Data__c inboundMember = new Vertu_Inbound_Data__c();
		inboundMember.Detail__c = VertuInboundDataHandler.QFORCEMEMBER;
        inboundMember.Inbound_Message__c = json;
        
        //Insert Vertu_Inbound_Data__c with invalid Detail__c
        test.startTest();
	        insert inboundMember;
	    test.stopTest();
	    
	    //Check record has been updated with Success
	    Vertu_Inbound_Data__c testInboundMember = [Select Id, Status__c, Detail__c from Vertu_Inbound_Data__c where id = :inboundMember.Id];
		system.assertEquals(VertuInboundDataHandler.STATUSSUCCESS, testInboundMember.Status__c);

		//Check children records have been added. Should be one record for each object 
		List<Member_Family__c> testMemberFamily = [Select Id from Member_Family__c where Person_Account__c = :testAcc.Id];
		system.assertEquals(1,testMemberFamily.size());
		
		List<Member_Passport__c> testMemberPassport = [Select Id from Member_Passport__c where Account__c = :testAcc.Id];
		system.assertEquals(1,testMemberPassport.size());
		
		List<Member_Loyalty__c> testMemberLoyalty = [Select Id from Member_Loyalty__c where Person_Account__c = :testAcc.Id];
		system.assertEquals(1,testMemberLoyalty.size());
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
        
        //Member fields
        testJson.member = new Member();
        //Member Key fields
        testJson.member.key = new Key();
        testJson.member.key.vregid = 'testvregid';
        system.assertEquals('testvregid', testJson.member.key.vregid);
        //Member Details fields
        testJson.member.details = new Details();
        testJson.member.details.qmemberid = 'testqmemberid';
        system.assertEquals('testqmemberid', testJson.member.details.qmemberid);
        testJson.member.details.dob = testToday;
        system.assertEquals(testToday, testJson.member.details.dob);
        testJson.member.details.dedicatedmanager = 'testdedicatedmanager';
        system.assertEquals('testdedicatedmanager', testJson.member.details.dedicatedmanager);
        testJson.member.details.conciergelanguage = 'testconciergelanguage';
        system.assertEquals('testconciergelanguage', testJson.member.details.conciergelanguage);
        testJson.member.details.company = 'testcompany';
        system.assertEquals('testcompany', testJson.member.details.company);
        testJson.member.details.cars = 'testcars';
        system.assertEquals('testcars', testJson.member.details.cars);
        testJson.member.details.writtenlanguage = 'testwrittenlanguage';
        system.assertEquals('testwrittenlanguage', testJson.member.details.writtenlanguage);
        testJson.member.details.ultimaterenewaldate = testToday;
        system.assertEquals(testToday, testJson.member.details.ultimaterenewaldate);
        testJson.member.details.tandc = true;
        system.assertEquals(true, testJson.member.details.tandc);
        testJson.member.details.status = 'teststatus';
        system.assertEquals('teststatus', testJson.member.details.status);
        testJson.member.details.serviceterms = true;
        system.assertEquals(true, testJson.member.details.serviceterms);
        testJson.member.details.renewaldate = testToday;
        system.assertEquals(testToday, testJson.member.details.renewaldate);
        testJson.member.details.religion = 'testreligion';
        system.assertEquals('testreligion', testJson.member.details.religion);
        testJson.member.details.profession = 'testprofession';
        system.assertEquals('testprofession', testJson.member.details.profession);
        testJson.member.details.preferredlanguage = 'testpreferredlanguage';
        system.assertEquals('testpreferredlanguage', testJson.member.details.preferredlanguage);
        testJson.member.details.preferredcontact = 'testpreferredcontact';
        system.assertEquals('testpreferredcontact', testJson.member.details.preferredcontact);
        testJson.member.details.owningoffice = 'testowningoffice';
        system.assertEquals('testowningoffice', testJson.member.details.owningoffice);
        testJson.member.details.otherlanguage = 'testotherlanguage';
        system.assertEquals('testotherlanguage', testJson.member.details.otherlanguage);
        testJson.member.details.oktosms = true;
        system.assertEquals(true, testJson.member.details.oktosms);
        testJson.member.details.oktomail = true;
        system.assertEquals(true, testJson.member.details.oktomail);
        testJson.member.details.oktoemail = true;
        system.assertEquals(true, testJson.member.details.oktoemail);
        testJson.member.details.oktocall = true;
        system.assertEquals(true, testJson.member.details.oktocall);
        testJson.member.details.numberrequests6months = 'testnumberrequests6months';
        system.assertEquals('testnumberrequests6months', testJson.member.details.numberrequests6months);
        testJson.member.details.numberrequests12months = 'testnumberrequests12months';
        system.assertEquals('testnumberrequests12months', testJson.member.details.numberrequests12months);
        testJson.member.details.numberrequests = 'testnumberrequests';
        system.assertEquals('testnumberrequests', testJson.member.details.numberrequests);
        testJson.member.details.neveremail = true;
        system.assertEquals(true, testJson.member.details.neveremail);
        testJson.member.details.nevercall = true;
        system.assertEquals(true, testJson.member.details.nevercall);
        testJson.member.details.nationality = 'testnationality';
        system.assertEquals('testnationality', testJson.member.details.nationality);
        testJson.member.details.memdate2desc = 'testmemdate2desc';
        system.assertEquals('testmemdate2desc', testJson.member.details.memdate2desc);
        testJson.member.details.memdate2 = testToday;
        system.assertEquals(testToday, testJson.member.details.memdate2);
        testJson.member.details.memdate1desc = 'testmemdate1desc';
        system.assertEquals('testmemdate1desc', testJson.member.details.memdate1desc);
        testJson.member.details.memdate1 = testToday;
        system.assertEquals(testToday, testJson.member.details.memdate1);
        testJson.member.details.marital = 'testmarital';
        system.assertEquals('testmarital', testJson.member.details.marital);
        testJson.member.details.level = 'testlevel';
        system.assertEquals('testlevel', testJson.member.details.level);
        testJson.member.details.lastrequestdate = testNow;
        system.assertEquals(testNow, testJson.member.details.lastrequestdate);
        testJson.member.details.lastrequest = 'testlastrequest';
        system.assertEquals('testlastrequest', testJson.member.details.lastrequest);
        testJson.member.details.jobtitle = 'testjobtitle';
        system.assertEquals('testjobtitle', testJson.member.details.jobtitle);
        testJson.member.details.industry = 'testindustry';
        system.assertEquals('testindustry', testJson.member.details.industry);
        testJson.member.details.gender = 'testgender';
        system.assertEquals('testgender', testJson.member.details.gender);
        testJson.member.details.entitlementreason = 'testentitlementreason';
        system.assertEquals('testentitlementreason', testJson.member.details.entitlementreason);
        //Member Detail Namefields
        testJson.member.details.name = new NameFields();
        testJson.member.details.name.salutation = 'testsalutation';
        system.assertEquals('testsalutation', testJson.member.details.name.salutation);
        testJson.member.details.name.preferred = 'testpreferred';
        system.assertEquals('testpreferred', testJson.member.details.name.preferred);
        testJson.member.details.name.phonetic = 'testphonetic';
        system.assertEquals('testphonetic', testJson.member.details.name.phonetic);
        testJson.member.details.name.middle = 'testmiddle';
        system.assertEquals('testmiddle', testJson.member.details.name.middle);
        testJson.member.details.name.local = 'testlocal';
        system.assertEquals('testlocal', testJson.member.details.name.local);
        testJson.member.details.name.last = 'testlast';
        system.assertEquals('testlast', testJson.member.details.name.last);
        testJson.member.details.name.first = 'testfirst';
        system.assertEquals('testfirst', testJson.member.details.name.first);
        testJson.member.details.name.assistant = 'testassistant';
        system.assertEquals('testassistant', testJson.member.details.name.assistant);
        //Member Detail EmailFields
        testJson.member.details.email = new EmailFields();
        testJson.member.details.email.primary = 'testprimary';
        system.assertEquals('testprimary', testJson.member.details.email.primary);
        testJson.member.details.email.second = 'testsecond';
        system.assertEquals('testsecond', testJson.member.details.email.second);
        testJson.member.details.email.third = 'testthird';
        system.assertEquals('testthird', testJson.member.details.email.third);
        testJson.member.details.email.fourth = 'testfourth';
        system.assertEquals('testfourth', testJson.member.details.email.fourth);
        testJson.member.details.email.fifth = 'testfifth';
        system.assertEquals('testfifth', testJson.member.details.email.fifth);
        //Member Detail PhoneFields
        testJson.member.details.phone = new PhoneFields();
        testJson.member.details.phone.work = 'testwork';
        system.assertEquals('testwork', testJson.member.details.phone.work);
        testJson.member.details.phone.mobile = 'testmobile';
        system.assertEquals('testmobile', testJson.member.details.phone.mobile);
        testJson.member.details.phone.home = 'testhome';
        system.assertEquals('testhome', testJson.member.details.phone.home);
        testJson.member.details.phone.fax = 'testfax';
        system.assertEquals('testfax', testJson.member.details.phone.fax);
        testJson.member.details.phone.assistant = 'testassistant';
        system.assertEquals('testassistant', testJson.member.details.phone.assistant);
        testJson.member.details.phone.altmobile = 'testaltmobile';
        system.assertEquals('testaltmobile', testJson.member.details.phone.altmobile);
        testJson.member.details.phone.althome = 'testalthome';
        system.assertEquals('testalthome', testJson.member.details.phone.althome);
        //Member Detail AddressFields
        testJson.member.details.address = new AddressFields();
        testJson.member.details.address.thirdzip = 'testthirdzip';
        system.assertEquals('testthirdzip', testJson.member.details.address.thirdzip);
        testJson.member.details.address.thirdtype = 'testthirdtype';
        system.assertEquals('testthirdtype', testJson.member.details.address.thirdtype);
        testJson.member.details.address.thirdstreet = 'testthirdstreet';
        system.assertEquals('testthirdstreet', testJson.member.details.address.thirdstreet);
        testJson.member.details.address.thirdstate = 'testthirdstate';
        system.assertEquals('testthirdstate', testJson.member.details.address.thirdstate);
        testJson.member.details.address.thirdcountry = 'testthirdcountry';
        system.assertEquals('testthirdcountry', testJson.member.details.address.thirdcountry);
        testJson.member.details.address.thirdcity = 'testthirdcity';
        system.assertEquals('testthirdcity', testJson.member.details.address.thirdcity);
        testJson.member.details.address.secondzip = 'testsecondzip';
        system.assertEquals('testsecondzip', testJson.member.details.address.secondzip);
        testJson.member.details.address.secondtype = 'testsecondtype';
        system.assertEquals('testsecondtype', testJson.member.details.address.secondtype);
        testJson.member.details.address.secondstreet = 'testsecondstreet';
        system.assertEquals('testsecondstreet', testJson.member.details.address.secondstreet);
        testJson.member.details.address.secondstate = 'testsecondstate';
        system.assertEquals('testsecondstate', testJson.member.details.address.secondstate);
        testJson.member.details.address.secondcountry = 'testsecondcountry';
        system.assertEquals('testsecondcountry', testJson.member.details.address.secondcountry);
        testJson.member.details.address.secondcity = 'testsecondcity';
        system.assertEquals('testsecondcity', testJson.member.details.address.secondcity);
       	testJson.member.details.address.primaryzip = 'testprimaryzip';
        system.assertEquals('testprimaryzip', testJson.member.details.address.primaryzip);
        testJson.member.details.address.primarytype = 'testprimarytype';
        system.assertEquals('testprimarytype', testJson.member.details.address.primarytype);
        testJson.member.details.address.primarystreet = 'testprimarystreet';
        system.assertEquals('testprimarystreet', testJson.member.details.address.primarystreet);
        testJson.member.details.address.primarystate = 'testprimarystate';
        system.assertEquals('testprimarystate', testJson.member.details.address.primarystate);
        testJson.member.details.address.primarycountry = 'testprimarycountry';
        system.assertEquals('testprimarycountry', testJson.member.details.address.primarycountry);
        testJson.member.details.address.primarycity = 'testprimarycity';
        system.assertEquals('testprimarycity', testJson.member.details.address.primarycity);
        testJson.member.details.address.primaryzip = 'testprimaryzip';
        system.assertEquals('testprimaryzip', testJson.member.details.address.primaryzip);
        testJson.member.details.address.primarytype = 'testprimarytype';
        system.assertEquals('testprimarytype', testJson.member.details.address.primarytype);
        testJson.member.details.address.primarystreet = 'testprimarystreet';
        system.assertEquals('testprimarystreet', testJson.member.details.address.primarystreet);
        testJson.member.details.address.primarystate = 'testprimarystate';
        system.assertEquals('testprimarystate', testJson.member.details.address.primarystate);
        testJson.member.details.address.primarycountry = 'testprimarycountry';
        system.assertEquals('testprimarycountry', testJson.member.details.address.primarycountry);
        testJson.member.details.address.primarycity = 'testprimarycity';
        system.assertEquals('testprimarycity', testJson.member.details.address.primarycity);
        testJson.member.details.address.fourthzip = 'testfourthzip';
        system.assertEquals('testfourthzip', testJson.member.details.address.fourthzip);
        testJson.member.details.address.fourthtype = 'testfourthtype';
        system.assertEquals('testfourthtype', testJson.member.details.address.fourthtype);
        testJson.member.details.address.fourthstreet = 'testfourthstreet';
        system.assertEquals('testfourthstreet', testJson.member.details.address.fourthstreet);
        testJson.member.details.address.fourthstate = 'testfourthstate';
        system.assertEquals('testfourthstate', testJson.member.details.address.fourthstate);
        testJson.member.details.address.fourthcountry = 'testfourthcountry';
        system.assertEquals('testfourthcountry', testJson.member.details.address.fourthcountry);
        testJson.member.details.address.fourthcity = 'testfourthcity';
        system.assertEquals('testfourthcity', testJson.member.details.address.fourthcity);
        //Member Detail Interests
        testJson.member.details.interests = new Interests();
        testJson.member.details.interests.vipdesc = 'testvipdesc';
        system.assertEquals('testvipdesc', testJson.member.details.interests.vipdesc);
        testJson.member.details.interests.vip = true;
        system.assertEquals(true, testJson.member.details.interests.vip);
        testJson.member.details.interests.sportsfitness = 'testsportsfitness';
        system.assertEquals('testsportsfitness', testJson.member.details.interests.sportsfitness);
        testJson.member.details.interests.musicshows = 'testmusicshows';
        system.assertEquals('testmusicshows', testJson.member.details.interests.musicshows);
        testJson.member.details.interests.leisuretravelfrequency = 'testleisuretravelfrequency';
        system.assertEquals('testleisuretravelfrequency', testJson.member.details.interests.leisuretravelfrequency);
        testJson.member.details.interests.leisurecountries = 'testleisurecountries';
        system.assertEquals('testleisurecountries', testJson.member.details.interests.leisurecountries);
        testJson.member.details.interests.leisurecities = 'testleisurecities';
        system.assertEquals('testleisurecities', testJson.member.details.interests.leisurecities);
        testJson.member.details.interests.holidaytypes = 'testholidaytypes';
        system.assertEquals('testholidaytypes', testJson.member.details.interests.holidaytypes);
        testJson.member.details.interests.finediningdesc = 'testfinediningdesc';
        system.assertEquals('testfinediningdesc', testJson.member.details.interests.finediningdesc);
        testJson.member.details.interests.finedining = true;
        system.assertEquals(true, testJson.member.details.interests.finedining);
        testJson.member.details.interests.fashiondesc = 'testfashiondesc';
        system.assertEquals('testfashiondesc', testJson.member.details.interests.fashiondesc);
        testJson.member.details.interests.fashion = true;
        system.assertEquals(true, testJson.member.details.interests.fashion);
        testJson.member.details.interests.entertainmentarts = 'testentertainmentarts';
        system.assertEquals('testentertainmentarts', testJson.member.details.interests.entertainmentarts);
        testJson.member.details.interests.eliteworldsportdesc = 'testeliteworldsportdesc';
        system.assertEquals('testeliteworldsportdesc', testJson.member.details.interests.eliteworldsportdesc);
        testJson.member.details.interests.eliteworldsport = true;
        system.assertEquals(true, testJson.member.details.interests.eliteworldsport);
        testJson.member.details.interests.champagnewinedesc = 'testchampagnewinedesc';
        system.assertEquals('testchampagnewinedesc', testJson.member.details.interests.champagnewinedesc);
        testJson.member.details.interests.champagnewine = true;
        system.assertEquals(true, testJson.member.details.interests.eliteworldsport);
        testJson.member.details.interests.businesstravelfrequency = 'testbusinesstravelfrequency';
        system.assertEquals('testbusinesstravelfrequency', testJson.member.details.interests.businesstravelfrequency);
        testJson.member.details.interests.businessintel = true;
        system.assertEquals(true, testJson.member.details.interests.businessintel);
        testJson.member.details.interests.businessintadesc = 'testbusinessintadesc';
        system.assertEquals('testbusinessintadesc', testJson.member.details.interests.businessintadesc);
        testJson.member.details.interests.businesscountries = 'testbusinesscountries';
        system.assertEquals('testbusinesscountries', testJson.member.details.interests.businesscountries);
        testJson.member.details.interests.businesscities = 'testbusinesscities';
        system.assertEquals('testbusinesscities', testJson.member.details.interests.businesscities);
        testJson.member.details.interests.artdesc = 'testartdesc';
        system.assertEquals('testartdesc', testJson.member.details.interests.artdesc);
        testJson.member.details.interests.art = true;
        system.assertEquals(true, testJson.member.details.interests.art);
        //Member Passports 
        testJson.passportlist = new List<PassportList>();
        PassportList pl = new PassportList();
        pl.recordid = 'testrecordid';
        pl.fullname = 'testfullname';
        pl.passportnumber = 'testpassportnumber';
        pl.nationality = 'testnationality';
        pl.issuercode = 'testissuercode';
        pl.issuer = 'testissuer';
        pl.issuedate = string.valueOf(testToday);
        pl.expirydate = string.valueOf(testToday);
        testJson.passportlist.add(pl);
        system.assertEquals('testrecordid', testJson.passportlist[0].recordid);
        system.assertEquals('testfullname', testJson.passportlist[0].fullname);
        system.assertEquals('testpassportnumber', testJson.passportlist[0].passportnumber);
        system.assertEquals('testnationality', testJson.passportlist[0].nationality);
        system.assertEquals('testissuercode', testJson.passportlist[0].issuercode);
        system.assertEquals('testissuer', testJson.passportlist[0].issuer);
        system.assertEquals(string.valueOf(testToday), testJson.passportlist[0].issuedate);
        system.assertEquals(string.valueOf(testToday), testJson.passportlist[0].expirydate);
        //Family Members
        testJson.familylist = new List<FamilyList>();
        FamilyList fl = new FamilyList();
        fl.recordid = 'testrecordid';
        fl.name = 'testname';
        fl.salutation = 'testsalutation';
        fl.relation = 'testrelation';
        fl.notes = 'testnotes';
        fl.dob = string.valueOf(testToday);
        testJson.familylist.add(fl);
        system.assertEquals('testrecordid', testJson.familylist[0].recordid);
        system.assertEquals('testname', testJson.familylist[0].name);
        system.assertEquals('testsalutation', testJson.familylist[0].salutation);
        system.assertEquals('testrelation', testJson.familylist[0].relation);
        system.assertEquals('testnotes', testJson.familylist[0].notes);
        system.assertEquals(string.valueOf(testToday), testJson.familylist[0].dob);
    	//Loyalty Schemes
        testJson.loyaltyschemelist = new List<LoyaltySchemeList>();
        LoyaltySchemeList lsl = new LoyaltySchemeList();
        lsl.recordid = 'testrecordid';
        lsl.type = 'testtype';
        lsl.name = 'testname';
        lsl.loyaltynumber = 'testloyaltynumber';
        lsl.level = 'testlevel';
        lsl.hotel = 'testhotel';
        lsl.car = 'testcar';
        lsl.airline = 'testairline';
        testJson.loyaltyschemelist.add(lsl);
        system.assertEquals('testrecordid', testJson.loyaltyschemelist[0].recordid);
        system.assertEquals('testtype', testJson.loyaltyschemelist[0].type);
        system.assertEquals('testname', testJson.loyaltyschemelist[0].name);
        system.assertEquals('testloyaltynumber', testJson.loyaltyschemelist[0].loyaltynumber);
        system.assertEquals('testlevel', testJson.loyaltyschemelist[0].level);
        system.assertEquals('testhotel', testJson.loyaltyschemelist[0].hotel);
        system.assertEquals('testcar', testJson.loyaltyschemelist[0].car);
        system.assertEquals('testairline', testJson.loyaltyschemelist[0].airline);
    }	
	
}