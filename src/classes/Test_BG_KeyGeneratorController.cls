/********************************************************************
 * Test_BG_KeyGeneratorController
 * 
 *
 * Test Class for BG_KeyGeneratorController
 * 
 * 
 * Author: Mahfuz Choudhury
 * Created Date: 29/07/2014
 *	 
 ********************************************************************/
@isTest
public class Test_BG_KeyGeneratorController {
    
    static testmethod void TestKeyGeneratorController()
    {   
        BG_KeyGeneratorController KG = new BG_KeyGeneratorController();
        //KG.GeneratedKey = '1234';
        KG.GenerateEncryptionkey128();
        KG.Redirect();
	}

}