@isTest
private class DispatchControllerTest {
    
    
    @testSetup
    static void setup() {
        // Utilize TestUtility methods to create necessary test data.
        // Create test accounts, tasks, and other necessary objects.
        Account testAccount = TestUtility.createTestAccount();
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id, IsActive__c = true);
        insert testContact;
        
        Individual testIndividual = new Individual(LastName = 'Test Individual', AccountId__c = testAccount.Id);
        insert testIndividual;

        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Teststandarduser123@testorg.com',
            IndividualId = testIndividual.Id
        );
        insert testUser;
        
        /*System.runAs(new User(Id = UserInfo.getUserId())) {
            //insert testUser;
            system.debug('testUser ===> ' + testUser.Id);
        }*/
        
        Process_Task_Owner_Assignment_Matrix__c ptow = new Process_Task_Owner_Assignment_Matrix__c(
            Account__c = testAccount.Id,
            Queue_Name__c = 'Branch_Operations_Bangalore'
        );
        insert ptow;
        
        // Now create Groups and GroupMembers
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Group QueueGroup = new Group(Name = 'Branch_Operations_Bangalore', Type = 'Queue');
            insert QueueGroup;
            Group testGroup = new Group(Name = 'Branch_Operations_Bangalore', Type = 'Regular');
            insert testGroup;
            
            GroupMember testGroupMember = new GroupMember(GroupID = testGroup.Id, UserOrGroupId = testUser.Id);
            insert testGroupMember;
            
            List<GroupMember> Gmlist = new List<GroupMember>();
            GroupMember testGroupMember1 = new GroupMember(GroupID = QueueGroup.Id, UserOrGroupId = testGroup.Id);
            GroupMember testGroupMember2 = new GroupMember(GroupID = QueueGroup.Id, UserOrGroupId = testUser.Id);
            Gmlist.add(testGroupMember2);
            Gmlist.add(testGroupMember1);
            insert Gmlist;
        }
        
        
        
        Task testTask = new Task(OwnerId = testUser.Id, WhatId = testAccount.Id, Subject='Test Task');
        insert testTask;
       
        Document_Metadata__c testDocumentMetaData =TestUtility.createDocumentmetadata(); 
        insert testDocumentMetaData;
         Paybale__c testMEMO =TestUtility.createMODTInstance();
        
        Document_Handler__c docHandler = new Document_Handler__c(
            Transfer_to__c = testAccount.Id,
            Status__c = 'To Be Dispatched',
            Transfer_By__c = testAccount.Id,
            Payable__c = testMEMO.Id,
            Document_Metadata__c=testDocumentMetaData.Id,
            //Shipping_Partner__c = 
            Document_Name__c = 'Test Document',
            Extended_SObject_RecordId__c = testAccount.Id, // Ensure this is a string.
            Document_Sharing_Task_Ids__c = testTask.Id // This should be a string, ensure format if multiple.
        );
        insert docHandler;
    }
        
        
    @isTest
    static void testGetDocumentsToBeCouriered() {
        User testUser = [SELECT Id, name FROM User WHERE Alias = 'standt' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            // Make sure to retrieve a task that is associated with the test user and other criteria
            Task testTask = [SELECT Id FROM Task WHERE OwnerId = :testUser.Id LIMIT 1];
            DispatchController.wrapperData result = DispatchController.getDocumentsToBeCouriered(testTask);
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void testGetAllrelateddocs() {
        // Test the retrieval of all related documents for a recipient.
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        DispatchController.wrapperData result = DispatchController.getAllreltedodcs(testAccount.Id);
        Test.stopTest();
        // Normally, you would use assertions here to validate the behavior.
    }

    @isTest
    static void testUpdateDocumentCourierDetail() {
       Test.startTest();
        User usr = [Select Id, name From user where UserName='Teststandarduser123@testorg.com'LIMIT 1];
         System.debug('usr == >'+usr);
        System.runAs(usr) {
            //insert testUser;
            List<Document_Handler__c> docs = [SELECT Id FROM Document_Handler__c LIMIT 1];
        	Account acc = [SELECT Id FROM Account LIMIT 1];
            system.debug('docs'+docs);
        	List<String> docIds = new List<String>{docs[0].Id};
         	String result = DispatchController.updateDocumentCourierDetail(docIds, null, null, usr.name, 'TestComments', 'Branch_Operations_Bangalore', acc.Id);
        }
        Test.stopTest();
    }
    @isTest
    static void testGetWiredDatforReceiver() {
        Test.startTest();
        String taskId = [SELECT Id FROM Task LIMIT 1].Id;
        DispatchController.wrapperData result = DispatchController.getWiredDatforReceiver(taskId);
        Test.stopTest();
    }

    @isTest
    static void testGetGroupNameandGroupMembers() {
        Test.startTest();
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        Map<String, List<String>> results = DispatchController.getGroupNameandGroupMembers(new List<Id>{accounts[0].Id});
        Test.stopTest();
        
        // Debug output to understand what's in results
        System.debug('Results: ' + results);
        
        // Assertions to verify the correctness of the results
        System.assertNotEquals(null, results, 'Results should not be null.');
        System.assert(results.size() > 0, 'Results should contain data.');
        System.assert(results.containsKey('Branch_Operations_Bangalore'), 'Results should include group name "Branch_Operations_Bangalore".');
        
        // Ensuring group members list is correctly initialized and populated
        if (results.containsKey('Branch_Operations_Bangalore')) {
            List<String> groupMembers = results.get('Branch_Operations_Bangalore');
            System.debug('Group Members: ' + groupMembers);  // Check content of groupMembers
            System.assertNotEquals(null, groupMembers, 'Group members should not be null.');
            System.assert(groupMembers.size() > 0, 'Group members list should not be empty.');
            System.assertEquals('Testing', groupMembers[0], 'Expected user name should be Testing.');
        } else {
            System.assert(false, 'Group "Branch_Operations_Bangalore" not found in results.');
        }
    }



    



}