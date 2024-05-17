@IsTest
private class TestTaskStatusOpen {

    @testSetup
    static void setup() {
        // Create a parent task
        Task parentTask = TestUtility.createTestTaskWithAttribute('ParentTask');
        insert parentTask;

        // Create dependent tasks that will be updated based on the parent task
        Task dependentTask1 = TestUtility.createTestTaskWithAttribute('DependentTask1');
        dependentTask1.Execution_Depended_on_Task_Ids__c = parentTask.Id;
        dependentTask1.Execution_Depended_Closed_Task_Ids__c = '';
        insert dependentTask1;

        Task dependentTask2 = TestUtility.createTestTaskWithAttribute('DependentTask2');
        dependentTask2.Execution_Depended_on_Task_Ids__c = parentTask.Id;
        dependentTask2.Execution_Depended_Closed_Task_Ids__c = '';
        insert dependentTask2;
    }

    @IsTest
    static void testTaskStatusOpenWithDependentTasks() {
        // Retrieve the inserted tasks
        Task parentTask = [SELECT Id FROM Task WHERE Execution_Depended_on_Task_Ids__c = null LIMIT 1];
        List<Task> dependentTasks = [SELECT Id, Execution_Depended_on_Task_Ids__c FROM Task WHERE Execution_Depended_on_Task_Ids__c != null];

        // Create a list with the parent task to pass to the method
        List<Task> tasksToProcess = new List<Task>{ parentTask };

        Test.startTest();

        // Call the method under test with a parent task that has dependent tasks
        TaskStatusOpen.TaskStatusOpen(tasksToProcess);

        Test.stopTest();

        // The test stops here, but the actions performed above should increase the code coverage
        // Since no assertions are to be used, this is where the test method ends
    }
}