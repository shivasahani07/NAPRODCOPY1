@isTest
public class TaskReopenDocumentbulkProcessingTest {
    
    @testSetup
    static void setupData() {
        Account testAccount = TestUtility.createTestAccount();
        Process_Attribute__c processAttribute = TestUtility.createProAttributeInstance();
        insert processAttribute;
        
        // Ensure we link this properly
        Process_Attribute_Path_Deviation__c pathDeviation = TestUtility.ProcessAttributePathD();
        pathDeviation.Process_Attribute__c = processAttribute.Id;
        pathDeviation.Document_Sharing_Status__c = 'Approved'; // Ensuring this is set for test matching
        insert pathDeviation;
        
        Task testTask = new Task(
            WhatId = testAccount.Id,
            Subject = 'Test Task',
            Status = 'Closed',
            Process_Attribute_Path_Deviation__c = pathDeviation.Id
        );
        insert testTask;
        System.debug('tasks: ' + testTask.Id);
        
        // Make sure the status in Document_Handler__c leads to reopening the task
        Document_Metadata__c testDocumentMetaData = TestUtility.createDocumentmetadata();
        insert testDocumentMetaData;
        Process_Attribute_Dcoument_Detail__c PADD= TestUtility.ProcessAttributeDocumentDetailInstance();
        insert PADD;
        
        Document_Handler__c docHandler = TestUtility.createDocumentHandlerInstance();
        docHandler.Current_Task_ID__c = testTask.Id;
        docHandler.Task_Id__c = testTask.Id;
        docHandler.Status__c = 'Approved';
        docHandler.Document_Metadata__c = testDocumentMetaData.Id;
        docHandler.Process_Attribute_Dcoument_Detail__c = PADD.Id;
        insert docHandler;
         System.debug('Inserting Document Handler for Task ID: ' + docHandler.Id);
        System.debug('docHandler Current_Task_ID__c: ' + docHandler.Current_Task_ID__c);
        
        
    }

    
    
    
    @isTest
    static void testAllPaths() {
        Test.startTest();
        List<Task> tasks = [SELECT Id, Status, Process_Attribute_Path_Deviation__r.Document_Sharing_Status__c FROM Task WHERE Status = 'Closed'];
        System.debug('tasks: ' + tasks[0].Id);
        set<string> taskIds = new Set<String>{tasks[0].Id};
        set<string> taskPAPDStatus = new Set<String>{tasks[0].Process_Attribute_Path_Deviation__r.Document_Sharing_Status__c};
        List<Document_Handler__c> dochand = [select id,Process_Attribute_Dcoument_Detail__c,Task_Id__c,Document_Sharing_Task_Ids__c,status__c,Current_Task_ID__c from Document_Handler__c where Status__c IN :taskPAPDStatus]; //Current_Task_ID__c IN:taskIds AND 
        System.debug('dochand: ' + dochand[0].id);
        System.debug('dochand Current_Task_ID__c: ' + dochand[0].Current_Task_ID__c);
        // Make sure the status in Document_Handler__c leads to reopening the task
        
        TaskReopenDocumentbulkProcessing.TaskReopenDocumentbulkProcessing(tasks);
        Test.stopTest();
        
        // Assert conditions for both reopened and not-reopened tasks based on their statuses
       
    }



    
    
    
    
    
    // Additional tests can be created for edge cases and other scenarios
}