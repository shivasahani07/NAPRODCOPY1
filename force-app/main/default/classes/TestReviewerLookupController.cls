@isTest
private class TestReviewerLookupController {
    
    @isTest
    static void testGetRelatedTasksWithNullTaskRecord() {
        
        List<sObject> results = reviewerLookupController.getRelatedtasks('Task', null);
        
    }
    
    @isTest
    static void testGetRelatedTasksWithNonNullTaskRecordButEmptyPCTDList() {
        Test.startTest();
        
        Account testAccount = TestUtility.createTestAccount();
        
        
        
        Process_Path__c testPP = TestUtility.createTestProcessPath();
        Process_Task_Detail__c testPTD = TestUtility.createMockProcessTaskDetail();
        Process_Path_Task_Detail__c pptd = TestUtility.createProcessPathTaskDetail(testPP, testPTD);
        
       
        Task task = new Task(
            Process_Path_Task_Detail__c = pptd.Id,
            WhatId = testAccount.Id 
        );
        insert task;
        
        
        List<sObject> results = reviewerLookupController.getRelatedtasks('Task', task);
        Test.stopTest();
        
    }
    

    
    @isTest
    static void testGetRelatedTasksWithResults() {
       
        Test.startTest();
         Process_Path_Task_Detail__c pptd = TestUtility.createPPTD();
        Process_Task_Detail__c ptd = TestUtility.createMockProcessTaskDetail();
        
        Account testAccount = TestUtility.createTestAccount();
        Task task = TestUtility.createTestTaskWithAttribute('Attribute');
        task.Process_Path_Task_Detail__c = pptd.Id;
        task.WhatId = testAccount.Id;
        insert task;
        
        
       
        
        
        Process_Component_Task_Detail__c pctd = new Process_Component_Task_Detail__c(
            Process_Path_Task_DetailId__c = pptd.Id,
            Process_Path_Task_Detail__c =  pptd.Id,
            Process_Task_Detail__c = ptd.Id
            
        );
        insert pctd;
        
       
        
        List<sObject> results = reviewerLookupController.getRelatedtasks('Task', task);
        Test.stopTest();
       
    }
    
    @isTest
    static void testGetRelatedTasksWithNonEmptyPCTDList() {
        Test.startTest();
        
        // Create necessary test records: Account, ProcessPath, Task, ProcessPathTaskDetail, and ProcessComponentTaskDetail
        Account testAccount = TestUtility.createTestAccount();
        Process_Path__c testPP = TestUtility.createTestProcessPath();
        Process_Task_Detail__c testPTD = TestUtility.createMockProcessTaskDetail();
        Process_Path_Task_Detail__c pptd = TestUtility.createProcessPathTaskDetail(testPP, testPTD);
        
        // Create Task linked to the ProcessPathTaskDetail
        Task task = new Task(
            Process_Path_Task_Detail__c = pptd.Id,
            WhatId = testAccount.Id
        );
        insert task;
        
        // Create at least one Process_Component_Task_Detail__c with valid links
        Process_Component_Task_Detail__c pctd = new Process_Component_Task_Detail__c(
            Process_Path_Task_DetailId__c = pptd.Id,
            Process_Path_Task_Detail__c = pptd.Id,
            Process_Task_Detail__c = testPTD.Id
        );
        insert pctd;
        
        // Execute the method under test
        List<sObject> results = reviewerLookupController.getRelatedtasks('Task', task);
        Test.stopTest();
        
        // Add assertions to validate the behavior
        System.assertNotEquals(0, results.size(), 'Should retrieve related tasks based on PCTDList.');
    }

    
    
}