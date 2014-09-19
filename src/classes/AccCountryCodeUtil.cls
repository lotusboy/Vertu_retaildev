/*
Developer Name                          : Omar Qureshi
Deployment Date                         : 
Description                             : Utility class called by AccountBeforeInsert trigger
*/ 

public class AccCountryCodeUtil {

    // Method to strip off trailing country code
    // For example, a parameter of 'United Kingdom +44' will return 'United Kingdom'
    public static String stripOffCountryCode(String country)
    {
        
        String s = '';
        try
        {
        	s = country.subString(0, country.indexOf('+')-1);
        }
        catch (System.StringException e) 
        {
        	System.debug(e.getMessage());
        }
        return s;
        
    }
    
    /* Method that returns the new phone number along with country code
       It takes the old & new Account Maps as arguments, as well as a a Phone Type
       Valid values for Phone Type are 'mobile', 'home' and 'other'
       If there are no validation exceptions, the method returns a phone number
       starting with the '+' character. If the '+' character is not present, 
       an error message is returned instead.
	*/
    public static String returnNewPhoneNumber(Account oldAcc, Account newAcc, String strPhoneType)
    {

                // Initialise a map of country dialling codes stored in custom settings object Country_Code__c
                Map<String, Country_Code__c> countries = Country_Code__c.getAll();
                String strError = '';
                String oldPhoneCountry;
                String newPhoneCountry;
                String newPhone;
                String oldPhone;
                if (strPhoneType == 'Mobile')
                {
                    oldPhoneCountry = oldAcc.Mobile_Country__c;
                    newPhoneCountry = newAcc.Mobile_Country__c;
                    oldPhone = oldAcc.PersonMobilePhone; 
                    if (newAcc.PersonMobilePhone <> null) {
                        newPhone = '+' + newAcc.PersonMobilePhone.replaceAll('\\D', '');
                    }
                    
                    System.debug('omar: new phone: ' + newPhone);
                }
                else if (strPhoneType == 'Other')
                {
                    oldPhoneCountry = oldAcc.Other_Phone_Country__c;
                    newPhoneCountry = newAcc.Other_Phone_Country__c;
                    oldPhone = oldAcc.PersonOtherPhone;     
                    if (newAcc.PersonOtherPhone <> null) {
                        newPhone = '+' + newAcc.PersonOtherPhone.replaceAll('\\D', '');
                    }
                }
                else if (strPhoneType == 'Home')
                {
                    oldPhoneCountry = oldAcc.Home_Phone_Country__c;
                    newPhoneCountry = newAcc.Home_Phone_Country__c;
                    oldPhone = oldAcc.PersonHomePhone; 
                    if (newAcc.PersonHomePhone <> null) {
                        newPhone = '+' + newAcc.PersonHomePhone.replaceAll('\\D', '');
                    }                                         
                } else
                {
                    return 'INVALID PHONE TYPE';
                }
                
                String newDiallingCode = '';
   
                String oldDiallingCode = '';
                 
                String oldPhoneWithoutDiallingCode = '';
                String newPhoneWithDiallingCode = '';   
                     
                if (newPhoneCountry <> null && newPhone <> null) // both populated
                {
                    // If country was selected in old map                   
                    if (oldPhoneCountry <> null) 
                    {
                        // strip off suffix
                        oldPhoneCountry = AccCountryCodeUtil.stripOffCountryCode(oldPhoneCountry );
                        // get old country code from map
                        Country_Code__c oldCountryCodeObj = countries.get(oldPhoneCountry);
                        if (oldCountryCodeObj <> null) {
                        	oldDiallingCode = oldCountryCodeObj.Country_Code__c;
                        }
                        else
                        {
                        	strError = 'Country ' + oldPhoneCountry  + ' not found in custom settings. Please contact administrator.';
                    		return strError;
                        }
                    }
    				System.debug('omar: oldcountry: ' + oldPhoneCountry + ' old dialling code: ' + oldDiallingCode);
    				
                    // New  phone country, with the suffix stripped off
                    // This is necessary to be able to match the keyset in the custom settings map
                    newPhoneCountry = AccCountryCodeUtil.stripOffCountryCode(newPhoneCountry);                                    
    

    				
                    // Get the dialling code for the new country from the custom settings Map               
                    Country_Code__c newCountryCodeObj = countries.get(newPhoneCountry);
                    
                    if (newCountryCodeObj <> null) {
                    	newDiallingCode = newCountryCodeObj.Country_Code__c;
                    	System.debug('omar: newPhoneCountry:' + newPhoneCountry + ' new dialling code:' + newDiallingCode);
                    }
                    else if (newCountryCodeObj == null)
                    {
                    	strError = 'Country ' + newPhoneCountry  + ' not found in custom settings. Please contact administrator.';
                    	return strError;
                    }
					
					System.debug('omar: olddiallingcode: ' + oldDiallingCode);
					System.debug('omar: newphone:' + newphone);
					System.debug('omar: startsWith(oldDiallingCode) ' + newphone.startsWith(oldDiallingCode));
					
                    if (oldPhone == newPhone) // phone number hasn't changed, country code has
                    {
                        oldPhoneWithoutDiallingCode = oldPhone.removeStart(oldDiallingCode);
                        oldPhoneWithoutDiallingCode = oldPhoneWithoutDiallingCode.replaceAll('\\D', '');      
                        newPhoneWithDiallingCode = newDiallingCode + oldPhoneWithoutDiallingCode;       
                    
                    }
                    else if (newPhone.startsWith(oldDiallingCode) == true) // country code same, phone number changed
                    {
                        
                        newPhoneWithDiallingCode = newDiallingCode + newPhone.removeStart(oldDiallingCode);
                        newPhoneWithDiallingCode = '+' + newPhoneWithDiallingCode.replaceAll('\\D', '');

                    }
                    else
                    {          
                        newPhoneWithDiallingCode = newPhone;
                       	System.debug('omar: Code block 1');
                    }
                
            }
    		/*
            else if (newPhoneCountry == null && newPhone <> null) // country selected, phone null
            {                       
                strError = strError + strPhoneType + ' Phone country must be selected when ' + strPhoneType + ' Phone number is entered.<br>';
                
            }
            */
            
            else if (newPhoneCountry <> null && newPhone == null) // country null, phone populated
            {
                strError = strError + strPhoneType + ' Phone Number must be entered when ' + strPhoneType + ' Phone Country is selected.<br>';
            }
    
            if (strError <> '') 
            {
                return strError;
            }
            else
            {
                System.debug('omar: return val:' + newPhoneWithDiallingCode);
                return newPhoneWithDiallingCode; 
            }
            
    }

}