@isTest
private class Child_components_ControllerTest {
    
    @isTest
    static void testWrapperClassReviewerDetailFromApex() {
        Process_Task_Detail__c testPTD =TestUtility.createMockProcessTaskDetail();
        //insert testPTD;
        Process_Path__c  testPP=TestUtility.createTestProcessPath();
       	//insert testPP;
        Process_Path_Task_Detail__c  testPPTD=TestUtility.createPPTD();
        testPPTD.Process_Path__c=testPP.id;
        testPPTD.Business_Step_No__c=3;
        testPPTD.Execution_Serial_No__c='4';
        testPPTD.Task_Owner_Type__c='System';
        testPPTD.Task_Owner_Name__c='Test Task Owner';
        testPPTD.Process_Task_Detail__c=testPTD.id;
        insert testPPTD;	
        
        Process_Attribute_Review_Detail__c PARD = TestUtility.createPARDInstance();
        PARD.Process_Path__c = testPP.Id;
        PARD.Process_Path_Task_Detail__c = testPPTD.Id;
        insert PARD;
        
        Process_Attribute_Review_Detail__c PARD2 = TestUtility.createPARDInstance();
        PARD2.Process_Path__c = testPP.Id;
        PARD2.Process_Path_Task_Detail__c = testPPTD.Id;
        insert PARD2;
        
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        testTask.Process_Path_Task_Detail__c=testPPTD.id;
        insert testTask;
        
        // Call the method to test
        Child_components_Controller.WrapperClassReviewer result = Child_components_Controller.WrapperClassReviewerDetailFromApex(testTask.Id);
        
        // Perform assertions
        System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testReturnWrapper() {
        // Create test data
        // 
         String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName='standarduser2@devtestorg.com');
        insert u;
        
        
        Process_Path__c  testPP= new Process_Path__c();
        testPP.Name='1234';
        testPP.isActive__c=true;
        insert testPP;
        String WhatId;
        Process_Path_Task_Detail__c testPPTD = new Process_Path_Task_Detail__c();
        testPPTD.isActive__c=true;
        testPPTD.Process_Path__c=testPP.id;
        
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        testTask.Process_Path_Task_Detail__c=testPPTD.id;
        testTask.OwnerId = u.Id;
        insert testTask; 
        
        // Call the method to test
       
        system.runAs(u){
            Child_components_Controller.wrapperClass result = Child_components_Controller.returnWrapper(testTask.Id);
            System.assertNotEquals(null, result, 'Expected a non-null result');
        }
        
        
        // Perform assertions
        
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testPassValueForApproval() {
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName='standarduser2@devtestorg.com');
        insert u;
        // Create test data
        Process_Path__c  testPP= new Process_Path__c();
        testPP.Name='1234';
        testPP.isActive__c=true;
        insert testPP;
        String WhatId;
        Process_Path_Task_Detail__c testPPTD = new Process_Path_Task_Detail__c();
        testPPTD.isActive__c=true;
        testPPTD.Process_Path__c=testPP.id;
        
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        testTask.Process_Path_Task_Detail__c=testPPTD.id;
        testTask.ownerId = u.Id;
        insert testTask; 
        
        // Call the method to test
        Child_components_Controller.PassValueForApproval(testTask.Id,new List<Task>{testTask},'Reviewer1');
        
        // Perform assertions if needed
    }
    @isTest
    static void testCallCheckCurrentUserEditRight() {
        // Create test data
        Process_Path__c  testPP= new Process_Path__c();
        testPP.Name='1234';
        testPP.isActive__c=true;
        insert testPP;
        
        Process_Path_Task_Detail__c testPPTD = new Process_Path_Task_Detail__c();
        testPPTD.isActive__c=true;
        testPPTD.Process_Path__c=testPP.id;
        
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        testTask.Process_Path_Task_Detail__c=testPPTD.id;
       // insert testTask; 
        
        
        // Call the method to test
        //boolean result = Child_components_Controller.CallCheckCurrentUserEditRight(taskRecord.Id);
        
        // Perform assertions
        //System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testUpdateTaskStatus() {
        // Create test data
        Process_Path__c  testPP= new Process_Path__c();
        testPP.Name='1234';
        testPP.isActive__c=true;
        insert testPP;
        
        Process_Path_Task_Detail__c testPPTD = new Process_Path_Task_Detail__c();
        testPPTD.isActive__c=true;
        testPPTD.Process_Path__c=testPP.id;
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        testTask.Process_Path_Task_Detail__c=testPPTD.id;
       insert testTask;        
        
        
        // Call the method to test
        List<Task> result = Child_components_Controller.UpdateTaskStatus(null,'Approved', new List<Id>{testTask.Id});
        
        // Perform assertions
        System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testUpdateTasks() {
        // Create test data
        Process_Path__c  testPP= new Process_Path__c();
        testPP.Name='1234';
        testPP.isActive__c=true;
        insert testPP;
        String WhatId;
        Process_Path_Task_Detail__c testPPTD = new Process_Path_Task_Detail__c();
        testPPTD.isActive__c=true;
        testPPTD.Process_Path__c=testPP.id;
        
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        testTask.Process_Path_Task_Detail__c=testPPTD.id;
        insert testTask; 
        
        // Call the method to test
        Child_components_Controller.UpdateTasks(new List<Id>{testTask.Id}, testTask.Id);
        
        // Perform assertions if needed
    }
    
    @isTest
    static void testUpdateComment() {
        // Create test data
        Process_Path__c  testPP= new Process_Path__c();
        testPP.Name='1234';
        testPP.isActive__c=true;
        insert testPP;
        String WhatId;
        Process_Path_Task_Detail__c testPPTD = new Process_Path_Task_Detail__c();
        testPPTD.isActive__c=true;
        testPPTD.Process_Path__c=testPP.id;
        
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask2=TestUtility.CreateTaskInstance();
        insert testTask2;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        testTask.Parent_Task_Id__c=testTask2.id;
        testTask.Process_Path_Task_Detail__c=testPPTD.id;
        insert testTask; 
        
        
        
        // Call the method to test
        Task result = Child_components_Controller.updateComment(testTask);
        
        // Perform assertions
        //System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    /* @isTest
static void testGetFinancialAccId() {
// Create test data
String opportunityId =;  // Replace with a valid Opportunity Id

// Call the method to test
String result = Child_components_Controller.getFinancialAccId(opportunityId);

// Perform assertions
System.assertNotEquals(null, result, 'Expected a non-null result');
// Add more assertions based on the expected behavior of the method
} */
    
    @isTest
    static void testUpsertPRCF() {
        List<Process_Review_Checklist_FACT__c> prcfRecords = new List<Process_Review_Checklist_FACT__c>();
        prcfRecords.add(new Process_Review_Checklist_FACT__c(Comments__c = 'Test PRCF'));

        Test.startTest();
        List<Process_Review_Checklist_FACT__c> results = Child_components_Controller.upsert_PRCF(prcfRecords);
        Test.stopTest();

        // Assertions to check the upsert operation
        System.assertNotEquals(null, results, 'Results should not be null');
        //System.assertEquals(1, results.size(), 'There should be one record');
        //System.assertEquals('Test PRCF', results[0].Comments__c, 'Name should match the test record');
    }
    
    private static Account createTestAccount() {
        Account testAccount = TestUtility.createaccountInstance();
        insert testAccount;
        return testAccount;
        
    }
    
     
     private static Financial_Account__c createTestFinancialAccount(Account testAccount) {
        // Correctly create and insert an Opportunity
        Opportunity opp = TestUtility.CreateOppINstance();
        insert opp; // Inserts the Opportunity to generate a valid ID

        // Create and insert Financial_Account__c with correct references to Account and Opportunity IDs
        Financial_Account__c fa = new Financial_Account__c(
            Opportunity__c = opp.Id,
            Name = 'Test Financial Account',
            Account_Name__c = testAccount.Id // Assign the Account ID to the lookup field
           // Borrower_Name__c = 'Test Borrower'
        );
        insert fa;
        return fa;
    }

    @isTest
    static void testGetFinancialAccId() {
        Account testAccount = createTestAccount();
        Financial_Account__c fa = createTestFinancialAccount(testAccount);
        Test.startTest();
        Financial_Account__c result = Child_components_Controller.getFinancialAccId(fa.Opportunity__c);
        Test.stopTest();
        
        // Assertions to ensure correct data retrieval
        System.assert(result != null, 'Financial Account should not be null');
        System.assertEquals('Test Financial Account', result.Name);
        System.assertEquals(testAccount.Id, result.Account_Name__c, 'Account ID should match the test Account');
    }
    
    
}