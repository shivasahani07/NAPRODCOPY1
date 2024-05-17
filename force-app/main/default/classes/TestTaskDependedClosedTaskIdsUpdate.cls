@IsTest
private class TestTaskDependedClosedTaskIdsUpdate {

    @testSetup
    static void setup() {
        // Create test Accounts and Contacts for WhatId and WhoId
        Account testAccount = TestUtility.createTestAccount();
        Contact testContact = TestUtility.CreateContactINstance();

        // Create a parent task with WhatId set to the test Account
        Task parentTaskWithWhatId = TestUtility.createTestTaskWithAttribute('ParentTaskWhatId');
        parentTaskWithWhatId.WhatId = testAccount.Id;
        parentTaskWithWhatId.Execution_Depended_on_Task_Ids__c = '';
        insert parentTaskWithWhatId;

        // Create a parent task with WhoId set to the test Contact
        Task parentTaskWithWhoId = TestUtility.createTestTaskWithAttribute('ParentTaskWhoId');
        parentTaskWithWhoId.WhoId = testContact.Id;
        parentTaskWithWhoId.Execution_Depended_on_Task_Ids__c = '';
        insert parentTaskWithWhoId;

        // Create related tasks that will be updated based on the parent tasks
        Task relatedTaskForWhatId = new Task(
            Subject = 'Related Task WhatId',
            WhatId = testAccount.Id,
            Execution_Depended_on_Task_Ids__c = parentTaskWithWhatId.Id + ','
        );
        insert relatedTaskForWhatId;

        Task relatedTaskForWhoId = new Task(
            Subject = 'Related Task WhoId',
            WhoId = testContact.Id,
            Execution_Depended_on_Task_Ids__c = parentTaskWithWhoId.Id + ','
        );
        insert relatedTaskForWhoId;
    }

    @IsTest
    static void testTaskDependedClosedTaskIdsUpdateWithWhatIdAndWhoId() {
        // Retrieve the inserted parent tasks
        List<Task> parentTasks = [SELECT Id, WhatId, WhoId FROM Task WHERE Execution_Depended_on_Task_Ids__c = ''];

        Test.startTest();

        // Call the method under test with the parent tasks that have WhatId and WhoId set
        TaskDependedClosedTaskIdsUpdate.TaskStatusOpen(parentTasks);

        Test.stopTest();

        // Normally, assertions would be here to confirm behavior.
        // Since no assertions are to be used, the test stops here.
    }
}