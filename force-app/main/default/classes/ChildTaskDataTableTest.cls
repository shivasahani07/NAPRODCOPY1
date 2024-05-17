@isTest
private class ChildTaskDataTableTest {
    
    @testSetup
    static void setup() {
        // Using TestUtility to create necessary test records.
        Account testAccount = TestUtility.createTestAccount();
        Task testTask = TestUtility.createTestTaskWithAttribute('Test Attribute');
        testTask.WhatId = testAccount.Id;
        
        insert testTask;
        
        
        
        User testUser = TestUtility.createUserInstance(); 
        insert testUser;
        system.debug('testUser ===> ' + testUser);
        
        Group testGroup = new Group(Name='Test Group', Type='Queue');
        insert testGroup;
        
        
        system.runAs(testUser){
            QueueSobject queueSobject = new QueueSobject();
            queueSobject.SObjectType = 'Task';
            queueSobject.QueueID = testGroup.Id;
            insert queueSobject;
            
            Group RegtestGroup = new Group();
            RegtestGroup.Name = 'Test Public Group';
            RegtestGroup.Type = 'Regular';
            insert RegtestGroup;
            
            GroupMember Reggm = new GroupMember();
            Reggm.GroupId = RegtestGroup.Id;
            Reggm.UserOrGroupId = testUser.Id;
            insert Reggm;
            
            GroupMember testGroupMember = new GroupMember(GroupId=testGroup.Id, UserOrGroupId=RegtestGroup.Id);
            insert testGroupMember;
            Process_Attribute_Review_Detail__c pard = new Process_Attribute_Review_Detail__c(Reviewer_Name__c = testGroup.Name, Bulk_Approval__c = true);
            insert pard;
            
            Task parentTask = TestUtility.createTestTaskWithAttribute('Parent Task');
            parentTask.Process_Attribute_Review_Detail__c = pard.Id;
            parentTask.Status = 'Submited For Review';
            parentTask.OwnerId = testGroup.Id;
            insert parentTask;
            
            Task childTask = TestUtility.createTestTaskWithAttribute('Child Task');
            childTask.Parent_Task_Id__c = parentTask.Id;
            childTask.OwnerId = testGroup.Id; 
            childTask.Process_Attribute_Review_Detail__c = pard.Id;
            insert childTask;
            
            
            Paybale__c testPayable = TestUtility.createMODTInstance();
            testPayable.Task_Id__c = testTask.Id;
            Update testPayable;
            
            List<Paybale__c> result = childTaskDataTable.getChildTasks(parentTask.Id);
        }
        
        
        
        
        
    }
    
    
    
    /* @isTest
static void testGetChildTasks() {
Test.startTest();
Task testTask = [SELECT Id FROM Task LIMIT 1];
List<Paybale__c> result = childTaskDataTable.getChildTasks(testTask.Id);
Test.stopTest();
}*/
    
    /*@isTest
static void testGetReviewerTask() {
List<Task> tasks = [SELECT Id, Process_Attribute_Review_Detail__r.Reviewer_Name__c FROM Task];
if (!tasks.isEmpty()) {
Test.startTest();
List<Paybale__c> result = childTaskDataTable.getReviewerTask(tasks);
Test.stopTest();
}
}*/
    
    
    
    @isTest
    static void testRejectedTask() {
        Account testAccount = TestUtility.createTestAccount();
        //insert testAccount;
        
        Opportunity testOpportunity = TestUtility.createTestOpportunity(testAccount.Id);
        insert testOpportunity;
        
        Process_Path__c processPath = TestUtility.createTestProcessPath();
        
        
        Process_Task_Detail__c processTaskDetail = TestUtility.createMockProcessTaskDetail();
        
        // Assume these utility methods exist and create records accordingly.
        Process_Path_Task_Detail__c pptd = TestUtility.createProcessPathTaskDetail(processPath, processTaskDetail);
        //insert pptd;
        
        Process_Attribute_Review_Detail__c pard = new Process_Attribute_Review_Detail__c(
            Reviewer_Name__c = 'Test Group',
            Bulk_Approval__c = true,
            Level__c = 5,  // Assuming level is set here for illustration
            Process_Path_Task_Detail__c = pptd.Id
        );
        insert pard;
        
        // Creating two tasks at level 5
        Task currentLevelTask1 = TestUtility.createTestTaskForOpportunity(testOpportunity.Id);
        currentLevelTask1.Current_Review_Level__c = 5;
        currentLevelTask1.Process_Attribute_Review_Detail__c = pard.Id;
        currentLevelTask1.WhatId = testOpportunity.Id;
        insert currentLevelTask1;
        
        Task currentLevelTask2 = TestUtility.createTestTaskForOpportunity(testOpportunity.Id);
        currentLevelTask2.Current_Review_Level__c = 5;
        currentLevelTask2.Process_Attribute_Review_Detail__c = pard.Id;
        currentLevelTask2.WhatId = testOpportunity.Id;
        insert currentLevelTask2;
        
        // Creating a task at level 4, which is the previous level
        Task previousLevelTask = TestUtility.createTestTaskForOpportunity(testOpportunity.Id);
        previousLevelTask.Current_Review_Level__c = 4;
        previousLevelTask.Process_Attribute_Review_Detail__c = pard.Id;
        previousLevelTask.WhatId = testOpportunity.Id;
        insert previousLevelTask;
        
        // List of IDs to be rejected
        List<String> taskIdsToReject = new List<String>{currentLevelTask1.Id, currentLevelTask2.Id};
            
            Test.startTest();
        String result = childTaskDataTable.rejectedTask(taskIdsToReject);
        Test.stopTest();
        
        // Post-execution, verify that the previous level task's status has been set to 'Submitted For Review'
        Task updatedPreviousLevelTask = [SELECT Status FROM Task WHERE Id = :previousLevelTask.Id];
        //System.assertEquals('Submitted For Review', updatedPreviousLevelTask.Status, 'The status of the previous level task should be updated.');
    }
    
    
    
    /*@isTest
static void testCheckLoggedInUserAccess() {
// This requires setting up Groups and GroupMembers that match your logic
// Assuming "SampleGroup" is a group name in your org
Set<String> groupNames = new Set<String>{'SampleGroup'};

Test.startTest();
Set<Id> result = childTaskDataTable.checkLoggerdInUserAccess(groupNames);
Test.stopTest();

// Here you would ideally check if the correct Ids are returned
}*/
    
    @isTest
    static void testCompleteParentTask() {
        // List<Task> parentTasks = [SELECT Id, Status FROM Task WHERE Parent_Task_Id__c = NULL LIMIT 2];  // Assuming these tasks are parent tasks
        Process_Path_Task_Detail__c processPathTaskDetail = TestUtility.createPPTD();
        
        Task testTask = TestUtility.createTestTaskWithAttribute('Test data');
        testTask.Process_Path_Task_Detail__c = processPathTaskDetail.id;
        testTask.Current_Review_Level__c = 5;
        insert testTask;
        Set<Id> parentTaskIds = new Set<Id>{testTask.id};
            for (Task t : [SELECT Id FROM TASK WHERE Id IN:parentTaskIds]) {
                parentTaskIds.add(t.Id);
            }
        
        Test.startTest();
        childTaskDataTable.completeParentTask(parentTaskIds);
        Test.stopTest();
        
        List<Task> updatedTasks = [SELECT Id, Status FROM Task WHERE Id IN :parentTaskIds];
        // Ideally, you should assert the Status is updated to 'Completed'
    }
    
    @isTest
    static void testApproveTask() {
        Account testAccount = TestUtility.createTestAccount();
        Opportunity testOpportunity = TestUtility.createTestOpportunity(testAccount.Id);
        insert testOpportunity;
        
        Opportunity testOpportunity1 = TestUtility.createTestOpportunity(testAccount.Id);
        insert testOpportunity1;
        Process_Path__c processPath = TestUtility.createTestProcessPath();
        
        
        Process_Task_Detail__c processTaskDetail = TestUtility.createMockProcessTaskDetail();
        
        
        Process_Path_Task_Detail__c pptd = TestUtility.createProcessPathTaskDetail(processPath, processTaskDetail);
        
        
        Process_Attribute_Review_Detail__c pard = new Process_Attribute_Review_Detail__c(
            Reviewer_Name__c = 'Test Group',
            Bulk_Approval__c = true,
            Level__c = 6,
            Process_Path_Task_Detail__c = pptd.Id,
            IsActive__c = true
        );
        insert pard;
        
        Task parentTask = TestUtility.createTestTaskForOpportunity(testOpportunity.Id);
        parentTask.Process_Attribute_Review_Detail__c = pard.Id;
        parentTask.Status = 'Submited For Review';
        insert parentTask;
        
        Task childTask1 = TestUtility.createTestTaskForOpportunity(testOpportunity.Id);
        childTask1.Parent_Task_Id__c = parentTask.Id;
        childTask1.Current_Review_Level__c = 5;
        childTask1.Process_Path_Task_Detail__c = pptd.Id;
        childTask1.Process_Attribute_Review_Detail__c = pard.Id;
        childTask1.WhatId = testOpportunity.Id;
        insert childTask1;
        
        
        
        Task childTask2 = TestUtility.createTestTaskForOpportunity(testOpportunity.Id);
        childTask2.Parent_Task_Id__c = parentTask.Id;
        childTask2.Current_Review_Level__c = 5; // Different level
        childTask2.Process_Path_Task_Detail__c = pptd.Id;
        childTask2.Process_Attribute_Review_Detail__c = pard.Id;
        childTask2.WhatId = testOpportunity.Id;
        insert childTask2;
        
        Task existingTaskForChild1 = TestUtility.createTestTaskForOpportunity(testOpportunity1.Id);
        existingTaskForChild1.Current_Review_Level__c = 6; // Next level
        existingTaskForChild1.WhatId = testOpportunity1.Id;
        insert existingTaskForChild1;
        
        Test.startTest();
        childTaskDataTable.approveTask(new List<String>{childTask1.Id, childTask2.Id});
        Test.stopTest();
        
        // Following the execution, childTask1 should transition to the next review level
        // and potentially spawn another task or update existing ones.
    }
    
    
    
}