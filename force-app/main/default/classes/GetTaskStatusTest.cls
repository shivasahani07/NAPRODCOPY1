@isTest
public class GetTaskStatusTest {
    
    // This method will prepare test data for scenarios
    @testSetup
    static void setup() {
        Account testAccount = TestUtility.createTestAccount();
        
        // Create tasks with and without parent
        Task parentTask = new Task(
            Subject = 'Parent Task',
            Status = 'Completed',
            WhatId = testAccount.Id
        );
        insert parentTask;

        Task childTask = new Task(
            Subject = 'Child Task',
            Status = 'Open',
            WhatId = testAccount.Id,
            Parent_Task_Id__c = parentTask.Id // Linking to parent
        );
        insert childTask;

        Task simpleTask = new Task(
            Subject = 'Simple Task',
            Status = 'Open',
            WhatId = testAccount.Id
        );
        insert simpleTask;
    }

    // Test method for task with no parent
    @isTest
    static void testGetTaskDetailNoParent() {
        Task testTask = [SELECT Id FROM Task WHERE Parent_Task_Id__c = null LIMIT 1];
        Test.startTest();
        GetTaskStatus.WrapperTaskAction result = GetTaskStatus.GettaskDetail(testTask.Id);
        Test.stopTest();
        
        System.assertEquals(True, result.isParentTask, 'Should be false as there is no parent task.');
        System.assertEquals(testTask.Id, result.taskRec.Id, 'The task ID should match the input task.');
    }

    // Test method for task with a parent
    @isTest
    static void testGetTaskDetailWithParent() {
        Task testTask = [SELECT Id, Parent_Task_Id__c FROM Task WHERE Parent_Task_Id__c != null LIMIT 1];
        Test.startTest();
        GetTaskStatus.WrapperTaskAction result = GetTaskStatus.GettaskDetail(testTask.Id);
        Test.stopTest();
        
        System.assertEquals(false, result.isParentTask, 'Should be false as it should fetch the parent task.');
        System.assertNotEquals(testTask.Id, result.taskRec.Id, 'Should return the parent task instead of the child.');
    }
    
    // More tests can be added to cover different variations and edge cases
}