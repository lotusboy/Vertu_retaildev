/********************************************************************
 * BG_CryptoUtility 
 * Test Class:
 *
 * This class provide encryption and decryption mechanism for Salesforce
 * instance using salesforce supported standards. Currently AES128 algorithm 
 * is implemented but can be extended to add others. 
 * 
 * 
 * Author: Mahfuz Choudhury
 * Created Date: 02/07/2014
 *	 
 ********************************************************************/
public class BG_CryptoUtility {
	
    //utility method to encrypt password using AES 128 algorithm
    Public static String EncryptUsing128(String password, String userKey)
    {
        String clearText = password;
		Blob key = EncodingUtil.base64Decode(userKey);
		Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(clearText));
		String encodedCipherText = EncodingUtil.base64Encode(cipherText); 
		
        System.debug(encodedCipherText);
        
        return encodedCipherText;
    }
    
    //utility method to decrypt encrypted password
    public static String DecryptUsingAES128(String encryptedPassword, String userKey)
    {
     	Blob key = EncodingUtil.base64Decode(userKey);
        Blob StringtoBlobPassword = EncodingUtil.base64Decode(encryptedPassword); 
        Blob DecryptedPassword = Crypto.DecryptWithManagedIV('AES128', key, StringtoBlobPassword);
        
        return DecryptedPassword.toString();
    }
    
    //The following method generate an AES 128 key and return it to calling Method
    public static string KeyGenerator128()
    {
     	Blob cryptoKey = Crypto.generateAesKey(128);
        System.debug('-------------------'+cryptoKey);
        String Key = EncodingUtil.base64Encode(cryptoKey);
        System.debug('String Value of Key is: [' + Key + ']');
        return Key;   
    }
    
}