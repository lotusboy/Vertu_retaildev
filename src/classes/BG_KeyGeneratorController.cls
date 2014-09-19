/********************************************************************
 * BG_KeyGeneratorController
 * Test Class:
 *
 * Controller for BG_KeyGenerator Page
 * 
 * 
 * Author: Mahfuz Choudhury
 * Created Date: 29/07/2014
 *	 
 ********************************************************************/
public class BG_KeyGeneratorController {
    
    Public String GeneratedKey {get; set;}
    Public Boolean DisplayKey 
    {
        get
        {
            if(GeneratedKey != Null)
                Return True;
            else 
                Return False;
        }
        set;
    }
    
    //Constructor Method
    Public BG_KeyGeneratorController() {}
	
    //Method to generate a key for AES 128
    public void GenerateEncryptionkey128()
    {
     	GeneratedKey = BG_CryptoUtility.KeyGenerator128();	   
    }
    
    //Redirect method, gets invoked in cancel button press
    Public Pagereference Redirect()
    { 
        PageReference pageRef = new PageReference('/home/home.jsp'); 
		pageRef.setRedirect(true);
        
        return pageRef;
    }
}