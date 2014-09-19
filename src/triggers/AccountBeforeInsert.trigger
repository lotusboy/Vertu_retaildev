/*
Developer Name	 : Omar Qureshi
Deployment Date	 : 08/11/2012
Description		 : Before insert, before update trigger to prefix country code to telephone numbers
Modified Date 	 : 15/09/2014
Modified By      : Steve Loftus (BrightGen)
*/ 

trigger AccountBeforeInsert on Account (before insert, before update) {
    
	Id customerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();

	// list to hold updated/inserted customer account where the vertu store has changed or is new
	list<Account> customerList = new list<Account>();

    // Initialise a map of country dialling codes stored in custom settings object Country_Code__c
    Map<String, Country_Code__c> countries = Country_Code__c.getAll();
  	String strError = '';
  	
    if (System.trigger.isInsert) // Creating a new account
    {    
        for (Account a: trigger.new)
        {	
			// Steve Loftus (BrightGen)	
			// if this is a customer account and the vertu store is not blank
			if (a.RecordTypeId == customerAccountRecordTypeId &&
					string.isNotBlank(a.Boutique__pc)) {

				// add it to the list to update
				customerList.add(a);
			}

            String dialling_code = '';
            Country_Code__c c;
            strError = '';
            
        	String mobilePhoneCountry = a.Mobile_Country__c;
        	String mobilePhone = a.PersonMobilePhone;  

        	String homePhoneCountry = a.Home_Phone_Country__c;
        	String homePhone = a.PersonhomePhone;  
        	
            String otherPhoneCountry = a.Other_Phone_Country__c;
            String otherPhone = a.PersonOtherPhone;
            

            if (mobilePhoneCountry <> null && mobilePhone <> null ) {
                // Strip off the country code from the picklist value         	
            	mobilePhoneCountry = AccCountryCodeUtil.stripOffCountryCode(mobilePhoneCountry);
            	
	            // Get dialling code for selected country from our custom settings map
	            c = countries.get(mobilePhoneCountry);
	            if (c == null) {
	            	strError = 'Could not find ' + mobilePhoneCountry + ' in custom settings. Please contact administrator.';
	            	break;
	            }
	            
	            // Do not append country code if phone number already begins with it
	            if (mobilePhone.startsWith(c.Country_Code__c) == false) {
	            	a.PersonMobilePhone = c.Country_Code__c + mobilePhone.replaceAll('\\D', '');
	            } else {
	            	a.PersonMobilePhone = '+' + mobilePhone.replaceAll('\\D', '');
	            }	            
            } else if (mobilePhoneCountry <> null && mobilePhone == null) {
				strError = strError + 'Mobile Phone Number must be entered when Mobile Phone Country is selected.<br>';
			}
			
			// Home phone
            if (homePhoneCountry <> null && homePhone <> null ) {
          		// Strip off the country code from the picklist value         	
            	homePhoneCountry = AccCountryCodeUtil.stripOffCountryCode(homePhoneCountry);
				// Get dialling code for selected country from our custom settings map
				c = countries.get(homePhoneCountry);
	            if (c == null) {
	            	strError = 'Could not find ' + homePhoneCountry + ' in custom settings. Please contact administrator.';
	            	break;
	            }
	            				
	            // Do not append country code if phone number already begins with it
	            if (HomePhone.startsWith(c.Country_Code__c) == false) {
	            	a.PersonHomePhone = c.Country_Code__c + HomePhone.replaceAll('\\D', '');
	            } else {
	            	a.PersonHomePhone = '+' + HomePhone.replaceAll('\\D', '');
	            }				
            } else if (homePhoneCountry <> null && homePhone == null) {
				strError = strError + 'Home Phone Number must be entered when Home Phone Country is selected.<br>';
			}

			// Other phone
            if (otherPhoneCountry <> null && otherPhone <> null ) {
				// Strip off the country code from the picklist value         	
            	otherPhoneCountry = AccCountryCodeUtil.stripOffCountryCode(otherPhoneCountry);
            	// Get dialling code for selected country from our custom settings map
            	c = countries.get(otherPhoneCountry);
	            if (c == null) {
	            	strError = 'Could not find ' + otherPhoneCountry + ' in custom settings. Please contact administrator.';
	            	break;
	            }
	            // Do not append country code if phone number already begins with it
	            if (otherPhone.startsWith(c.Country_Code__c) == false) {
	            	a.PersonOtherPhone = c.Country_Code__c + otherPhone.replaceAll('\\D', '');
	            } else {
	            	a.PersonOtherPhone = '+' + otherPhone.replaceAll('\\D', '');
	            }            	            	            
            } else if (otherPhoneCountry <> null && otherPhone == null) {
				strError = strError + 'Other Phone Number must be entered when Other Phone Country is selected.<br>';
			}
			
			// Add any errors to the collection
			if (strError <> '')
				a.addError(strError);
        }

    } else { // If not a before insert, it must be a before update event    

        for (Account a: trigger.new) {                               
			// Steve Loftus (BrightGen)	
			// if this is a customer account and the vertu store is not blank and has changed
			if (a.RecordTypeId == customerAccountRecordTypeId &&
					string.isNotBlank(a.Boutique__pc) &&
						(trigger.oldMap.get(a.Id).Boutique__pc != a.Boutique__pc)) {

				// add it to the list to update
				customerList.add(a);
			}

			strError = '';
			String strPhoneReturnVal = '';
            Account oldAcc = Trigger.oldMap.get(a.ID);    
            Account newAcc = Trigger.newMap.get(a.ID);

			// MOBILE
			if (a.Mobile_Country__c <> null) {
				strPhoneReturnVal = AccCountryCodeUtil.returnNewPhoneNumber(oldAcc, newAcc, 'Mobile');
				if (strPhoneReturnVal.startsWith('+') == true) {
					a.PersonMobilePhone = strPhoneReturnVal;
				} else {
					strError = strError + strPhoneReturnVal;
				}
			}

			// HOME
			if (a.Home_Phone_Country__c <> null) {
				strPhoneReturnVal = AccCountryCodeUtil.returnNewPhoneNumber(oldAcc, newAcc, 'Home');
				if (strPhoneReturnVal.startsWith('+') == true) {
					a.PersonHomePhone = strPhoneReturnVal;
				} else {
					strError = strError + strPhoneReturnVal;
				}
			}
            
            // OTHER
            if (a.Other_Phone_Country__c <> null) {
				strPhoneReturnVal = AccCountryCodeUtil.returnNewPhoneNumber(oldAcc, newAcc, 'Other');
				if (strPhoneReturnVal.startsWith('+') == true) {
					a.PersonOtherPhone = strPhoneReturnVal;
				} else {
					strError = strError + strPhoneReturnVal;
				}
            }
			
			// Add any errors to the collection
			if (strError <> '')
				a.addError(strError);
        }
           
    }

	// make sure we have some customers to update
	if (!customerList.isEmpty()) {

		// reassign the owner
		BG_CustomerHelper.reassignCustomersViaVertuStore(customerList);
	}    
}