@isTest(seeAllData=true)
public class TestNewCustRegController {

	public static testMethod void testNewCustReg() {

		
		// Setup successful mock http response
		String vertuAccountId = '987654321';
		
		//Set up mock callout - initial callout will test isValidHandset response
		VRegMockHttpCallOutSuccess mock = new VRegMockHttpCallOutSuccess(vertuAccountId);
		mock.methodCall = mock.methodCallIsValidHandset;
		Test.setMock(HttpCalloutMock.class, mock);
		
		PageReference pageRef = Page.newCustRegWizard;
		pageRef.getParameters().put('type', 'regnewcust');	
		Test.setCurrentPage(pageRef);
		
		// Instantiate a new controller with all parameters in the page
		newCustRegController controller = getController();
        
        system.assertEquals('NewCustReg',controller.wizard.type);
        system.assertEquals('1',controller.wizard.step);
        
		controller.next();
		system.assertEquals('2',controller.wizard.step);		
		controller.next();
		system.assertEquals('3',controller.wizard.step);		
		controller.next();
		system.assertEquals('4',controller.wizard.step);		
		
		controller.VertuUsername = '';
		controller.VertuPassword = '';
		controller.VertuPasswordConfirm = '';
		controller.SecretQuestion = '--None--';
		controller.isCustomSecretQuestion = false;
		controller.CustomSecretQuestion = '';
		controller.SecretAnswer = '';
		
		controller.next();  // Attempt to move to step 5 - should fail
		system.assertEquals('4',controller.wizard.step);
	//	system.assertEquals(System.Label.Username_Format, controller.errorUsername);
		system.assertEquals(System.Label.Password_Format, controller.errorVertuPassword);
		system.assertEquals(System.Label.Security_Question_Not_Selected, controller.errorSecretQuestion);
		system.assertEquals(System.Label.Security_Answer_Not_Entered, controller.errorSecretAnswer);

		controller.VertuUsername = '@@@'; // Username too short
		controller.next();  // Attempt to move to step 5 - should fail
		system.assertEquals(System.Label.Username_Format, controller.errorUsername);
		
		controller.VertuPassword = '@@@'; // Password too short
		controller.next();  // Attempt to move to step 5 - should fail		
		system.assertEquals(System.Label.Password_Mismatch, controller.errorVertuPassword);

		controller.VertuUsername = '123456';
		controller.VertuPassword = '876543'; //  Doesn't match password
		controller.next();  // Attempt to move to step 5 - should fail		
		system.assertEquals(System.Label.Password_Mismatch, controller.errorVertuPassword);
		system.assertEquals(System.Label.Password_Mismatch, controller.errorVertuPasswordConfirm);
	
		controller.VertuUsername = 'jsmith';
		controller.VertuPassword = 'mypassword';
		controller.VertuPasswordConfirm = 'mypassword';

		controller.next();  // Attempt to move to step 5 - should fail		
		system.assertEquals('4',controller.wizard.step);		
		system.assertEquals(System.Label.Security_Question_Not_Selected, controller.errorSecretQuestion);
		system.assertEquals(System.Label.Security_Answer_Not_Entered, controller.errorSecretAnswer);
		
		controller.SecretQuestion = 'xyz'; 
		controller.next();  // Attempt to move to step 5 - should fail		
		system.assertEquals('4',controller.wizard.step);		
		system.assertEquals(System.Label.Security_Answer_Not_Entered, controller.errorSecretAnswer);
		
		controller.SecretAnswer = 'xyz'; //Anwer too small
		controller.next();  // Attempt to move to step 5 - should fail		
		system.assertEquals('4',controller.wizard.step);		
		system.assertEquals(System.Label.Security_Answer_Not_Entered, controller.errorSecretAnswer);
		
		controller.SecretAnswer = 'xyz1'; 
		controller.next();  // Move to step 5		
		system.assertEquals('5',controller.wizard.step);		

		// Simulate wizard previous
		controller.previous();
		system.assertEquals('4',controller.wizard.step);	
		
		//Reset Security Question so we can test custom security question
		controller.SecretQuestion = '--None--';
		controller.SecretAnswer = '';
		controller.CustomSecretQuestion = 'xyz'; //custom question too short
		controller.isCustomSecretQuestion = true;
		controller.next();	
		system.assertEquals('4',controller.wizard.step);		
		system.assertEquals(System.Label.Security_Question_Not_Selected, controller.errorCustomSecretQuestion);
		system.assertEquals(System.Label.Security_Answer_Not_Entered, controller.errorSecretAnswer);
		
		controller.CustomSecretQuestion = 'xyz1';
		controller.next();	
		system.assertEquals('4',controller.wizard.step);		
		system.assertEquals(System.Label.Security_Answer_Not_Entered, controller.errorSecretAnswer);
		
		controller.SecretAnswer = 'xyz1'; 
		controller.next();  // Move to step 5	
		system.assertEquals('5',controller.wizard.step);		

		// Simulate wizard previous
		controller.previous();
		system.assertEquals('4',controller.wizard.step);		
		controller.previous();
		system.assertEquals('3',controller.wizard.step);		
		controller.previous();
		system.assertEquals('2',controller.wizard.step);		
		controller.previous();
		system.assertEquals('1',controller.wizard.step);		

		controller.next();
		system.assertEquals('2',controller.wizard.step);		
		controller.next();
		system.assertEquals('3',controller.wizard.step);		
		controller.next();
		system.assertEquals('4',controller.wizard.step);		
		controller.next();
		system.assertEquals('5',controller.wizard.step);		
		
		//change mock callout to test save response
		mock.methodCall = mock.methodCallSave;
		controller.next();
		system.assertEquals('6',controller.wizard.step);		

	}

	public static testMethod void testController() {

		// Setup data
		String vregID = '12345657890';
		Account a = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry','testlanguage');
		Vertu_Account__c v = UnitTestHelper.createVertuAccount(a.Id, vregID);

		// Setup the page and parameters		
		PageReference pageRef = Page.newCustRegWizard;
		Test.setCurrentPage(pageRef);

		Test.startTest();
		// For code coverage only currently
		
		// Instantiate a new controller
		newCustRegController controller = new newCustRegController();
		controller.VREGID = vregID;
		
		system.assertEquals('/'+a.Id, controller.navigateToAccountDetail().getUrl());
		
		controller.getCountries();
		controller.getCities();
		controller.getStores();
		
		controller.TestData();
		controller.getConciergeOptions();
		
		system.assertEquals('/home/home.jsp', controller.navigateToHome().getUrl());
		system.assertEquals('/home/home.jsp', controller.cancel().getUrl());
		system.assertEquals(null, controller.retryRegistration());
		
		Test.stopTest();		
	}


	public static testMethod void testAddNewHandset() {

		// Setup successful mock http response
		String vertuAccountId = '987654321';
		//Set up mock callout - initial callout will test isValidHandset response
		VRegMockHttpCallOutSuccess mock = new VRegMockHttpCallOutSuccess(vertuAccountId);
		mock.methodCall = mock.methodCallIsValidHandset;
		Test.setMock(HttpCalloutMock.class, mock);

		// Setup the data for this test
		String vregID = '@@@@@@';

		Account a = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry','testlanguage');
		system.assertEquals(true, a.Id != null);

		Vertu_Account__c v = UnitTestHelper.createVertuAccount(a.Id, vregID);		
		system.assertEquals(true, v.Id != null);		

		// Setup the page and parameters		
		PageReference pageRef = Page.newCustRegWizard;
		pageRef.getParameters().put('type', 'addhset');		
		pageRef.getParameters().put('aid', a.Id);
		pageRef.getParameters().put('vregid', vregID);
		Test.setCurrentPage(pageRef);

		Test.startTest();
				
		// Instantiate a new controller
		newCustRegController controller = new newCustRegController();
		system.assertEquals(vregID, controller.VREGID);
		system.assertEquals('1', controller.wizard.step);
		
		controller.next(); // Attempt to move to step 2 - should fail
		system.assertEquals('1', controller.wizard.step);
		system.assertEquals(System.Label.IMEI_Required, controller.errorIMEI); // IMEI Blank
		system.assertEquals(System.Label.Serial_Number_Required, controller.errorVSN); // VSN Blank
		
		controller.IMEI ='32993354345'; // Too long
		controller.VSN = 'Z000255'; // Incorrect pattern
		controller.next(); // Attempt to move to step 2 - should fail		
		system.assertEquals('1', controller.wizard.step);
		system.assertEquals(System.Label.IMEI_Format, controller.errorIMEI); // IMEI Incorrect format
		system.assertEquals(System.Label.Serial_Number_Format, controller.errorVSN); // VSN Incorrect format

		controller.IMEI ='3299';
		controller.VSN = 'ZB-000255';

		controller.next(); // Move to step 2		
		system.assertEquals('2', controller.wizard.step);

		controller.next(); // Attempt to move to step 3 - should fail
		system.assertEquals('2', controller.wizard.step);
		system.assertEquals(true, controller.errorCountry != ''); // Country blank
		system.assertEquals(true, controller.errorCity != ''); // City blank
		system.assertEquals(true, controller.errorBoutique != ''); // Store blank
		
		controller.RetailStoreCountry = 'Test Country';
		controller.RetailStoreCity = 'Test City';
		controller.RetailStoreName = 'Test Store Name';

		controller.next(); // Move to step 3
		system.assertEquals('3', controller.wizard.step);

		controller.next(); // Attempt to move to step 4 - should fail
		system.assertEquals('3', controller.wizard.step);		
		system.assertEquals(System.Label.Terms_and_Conditions_Agreement, controller.errorTermsAndConditions); // Terms not accepted

		//change mock callout to test save response
		mock.methodCall = mock.methodCallSave;
		controller.TermsAndConditions = true;
		controller.next(); // Move to step 4
		system.assertEquals('4', controller.wizard.step);
		
		// Assert success
		system.assertEquals(true,controller.response.success);
		system.assertEquals(true,controller.response.result.contains('The customer account and/or handset registration was successful. The Vertu Account ID is '));
		system.assertEquals(true,controller.response.result.contains(vertuAccountId));

		Test.stopTest();
	}

	public static testMethod void testAddNewVertuAccount() {

		// Setup successful mock http response
		String vertuAccountId = '987654321';
		//Set up mock callout - initial callout will test isValidHandset response
		VRegMockHttpCallOutSuccess mock = new VRegMockHttpCallOutSuccess(vertuAccountId);
		mock.methodCall = mock.methodCallIsValidHandset;
		Test.setMock(HttpCalloutMock.class, mock);

		Account a = UnitTestHelper.createAccount('testsalutation', 'testfirstname', 'testlastname', 'testnationality', 'testcountry','testlanguage');
			
		PageReference pageRef = Page.newCustRegWizard;
		pageRef.getParameters().put('type', 'regvacct');		
		pageRef.getParameters().put('aid', a.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
				
		// Instantiate a new controller with all parameters in the page
		newCustRegController controller = getController();
        
        // Simulate wizard next 
		controller.next();
		system.assertEquals('2',controller.wizard.step);		
		controller.next();
		system.assertEquals('3',controller.wizard.step);		
		controller.next();
		system.assertEquals('4',controller.wizard.step);		
		controller.next();
		system.assertEquals('5',controller.wizard.step);		
		
		
		// Simulate wizard previous
		controller.previous();
		system.assertEquals('4',controller.wizard.step);		
		controller.previous();
		system.assertEquals('3',controller.wizard.step);		
		controller.previous();
		system.assertEquals('2',controller.wizard.step);		
		controller.previous();
		system.assertEquals('1',controller.wizard.step);		

		controller.next();
		system.assertEquals('2',controller.wizard.step);		
		controller.next();
		system.assertEquals('3',controller.wizard.step);		
		controller.next();
		system.assertEquals('4',controller.wizard.step);		
		controller.next();
		system.assertEquals('5',controller.wizard.step);		

		//change mock callout to test save response
		mock.methodCall = mock.methodCallSave;
		controller.next();
		system.assertEquals('6',controller.wizard.step);		
		
		Test.stopTest();

	}
	
	private static testmethod newCustRegController getController() {
		newCustRegController controller = new newCustRegController();
		
		controller.IMEI ='3299';
		controller.VSN = 'ZB-000255';		
		controller.RetailStoreCountry = 'United Kingdom';
		controller.RetailStoreCity = 'London';
		controller.RetailStoreName = 'Vertu Bond Street';
		controller.handset.Date_of_Purchase__c = Date.today();
		controller.contact.Salutation = 'Mr';
		controller.contact.FirstName = 'John';
		controller.contact.LastName = 'Smith';
		controller.account.Country_of_Residence__pc = 'United Kingdom';
		controller.account.Gender__pc = 'Male';
		controller.account.Vertu_Spoken_Language__c = 'English';
		controller.account.Nationality__pc = 'British';
		controller.account.PersonMobilePhone = '+44777111222';
		controller.account.PersonEmail = 'jsmith@mycompany.co.uk';
		controller.VertuUsername = 'jsmith';
		controller.VertuPassword = 'mypassword';
		controller.VertuPasswordConfirm = 'mypassword';
		controller.secretQuestion = 'myquestion';
		controller.secretAnswer = 'myanswer';
		controller.MarketingOptIn = true;
		controller.TermsAndConditions = true;
		return controller;		
	}

}