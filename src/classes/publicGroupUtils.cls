public class publicGroupUtils {
/*
Developer Name   : Mick Nicholson (BrightGen Ltd)
Date Created	 : 29/05/2013
Description      : Public Group utility class
*/ 	
   public static Set<id> GetUserIdsFromGroup(Id groupId)
   {
		
		// store the results in a set so we don't get duplicates
		Set<Id> result=new Set<Id>();
		String userType = Schema.SObjectType.User.getKeyPrefix();
		String groupType = Schema.SObjectType.Group.getKeyPrefix();
    
		// Loop through all group members in a group
		for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId])
		{
			// If the user or group id is a user
			if (((String)m.UserOrGroupId).startsWith(userType))
			{
				result.add(m.UserOrGroupId);
			}
			// If the user or group id is a group
			// Note: there may be a problem with governor limits if this is called too many times
			else if (((String)m.UserOrGroupId).startsWith(groupType))
			{
				// Call this function again but pass in the group found within this group
				result.addAll(GetUSerIdsFromGroup(m.UserOrGroupId));
			}
		}
    
		return result;   
	}
    
    /****************/
    /*              */
    /* Test Methods */
    /*              */
    /****************/
    private static testMethod void testGetUserIdsFromGroup() 
    {
    	//Create test Groups
    	Group testGroup1 = UnitTestHelper.createGroup('testGroup1');
		Group testGroup2 = UnitTestHelper.createGroup('testGroup2');
		//Create test users
		User testUser1 = UnitTestHelper.GetUser('testuser1@testuser1.vertucom', 'testuser1@testuser1.vertucom', 'testuser1');
		User testUser2 = UnitTestHelper.GetUser('testuser2@testuser2.vertucom', 'testuser2@testuser2.vertucom', 'testuser2');
		//Add users to groups
		GroupMember testGroupMember1 = UnitTestHelper.createGroupMember(testGroup1.Id, testUser1.Id);    	
        GroupMember testGroupMember2 = UnitTestHelper.createGroupMember(testGroup2.Id, testUser2.Id);   
        //Add group2 to geoup1 	
        GroupMember testGroupMember3 = UnitTestHelper.createGroupMember(testGroup1.Id, testGroup2.Id);   

		//get all user Ids for group1
		Set<id> returnedUserIDs = GetUserIdsFromGroup(testGroup1.Id);
		//Should return both users
		system.assertEquals(2,returnedUserIDs.size());
		system.assertEquals(true,returnedUserIDs.contains(testUser1.Id));
		system.assertEquals(true,returnedUserIDs.contains(testUser2.Id));
		
		//get all user Ids for group2
		returnedUserIDs = GetUserIdsFromGroup(testGroup2.Id);
		//Should only return testUser2
		system.assertEquals(1,returnedUserIDs.size());
		system.assertEquals(true,returnedUserIDs.contains(testUser2.Id));
    }

}