@isTest
private class TestTaskDocumentSharing {

    @testSetup
    static void setup() {
        
        // Create test accounts, contacts, and leads to use with tasks
        List<Account> accounts = new List<Account>{ 
            TestUtility.createTestAccount(),
                TestUtility.createTestAccount()
                };
                    
        
        List<Contact> contacts = new List<Contact>{ 
            TestUtility.CreateContactInstance()
                };
                    insert contacts;
        
        List<Lead> leads = new List<Lead>{ 
            TestUtility.CreateLeadInstance()
                };
                    insert leads;
        
        List<Process_Attribute__c> processAttributes = new List<Process_Attribute__c>{
            TestUtility.createProAttributeInstance(),
                TestUtility.createProAttributeInstance()
                };
                    processAttributes[0].Name = 'Process Attribute 1';
        processAttributes[1].Name = 'Process Attribute 2';
        insert processAttributes;
        
        Process_Attribute_Path_Deviation__c processAttributePD = new Process_Attribute_Path_Deviation__c();
        processAttributePD.Document_Sharing_Status__c = 'Approved';
        processAttributePD.Process_Path_Type__c = 'Adhoc Path';
        processAttributePD.Process_Attribute__c = processAttributes[0].Id; 
        
        insert processAttributePD;
        Process_Path__c pptest = TestUtility.createProcessPAthInstance();
        insert pptest;
        
        Process_Task_Detail__c ptdTest =TestUtility.createPTDinstance();
        insert ptdTest;
        
        Process_Path_Task_Detail__c PPTD =  TestUtility.createPPTD();
        pptd.Process_Path__c = pptest.id;
        pptd.Process_Task_Detail__c = ptdTest.id;
        pptd.Business_Step_No__c = 1;
        pptd.Execution_Serial_No__c ='1';
        pptd.Task_Owner_Name__c = 'mukesh';
        insert PPTD;
        
        List<Process_Attribute_Dcoument_Detail__c> docDetails = new List<Process_Attribute_Dcoument_Detail__c>{
            TestUtility.ProcessAttributeDocumentDetailInstance(),
                TestUtility.ProcessAttributeDocumentDetailInstance()
                };
                    insert docDetails;
        system.debug('docDetails::'+docDetails);
        
        List<Task> tasks = new List<Task>{
            TestUtility.createTestTaskWithAttribute('Test Attribute Value 1'),
                TestUtility.createTestTaskWithAttribute('Test Attribute Value 2')
                };
                    tasks[0].WhatId = accounts[0].Id;
        tasks[0].Process_Attribute__c = processAttributes[0].Id;
        tasks[0].Process_Path_Task_Detail__c = PPTD.id;
        tasks[0].Process_Attribute_Path_Deviation__c = processAttributePD.Id;
        //tasks[0].Process_Attribute_Object_Type__c = 'Lead';
        tasks[1].WhoId = contacts[0].Id;
        tasks[1].Process_Attribute__c = processAttributes[1].Id;
        tasks[1].Process_Attribute_Path_Deviation__c = processAttributePD.Id;
        tasks[1].Process_Path_Task_Detail__c = PPTD.id;
        insert tasks;
        
        List<Document_Handler__c> docHandlers = new List<Document_Handler__c>{
            TestUtility.createDocumentHandlerInstance(),
                TestUtility.createDocumentHandlerInstance()
                };
                    docHandlers[0].Task_Id__c = tasks[0].Id;
        docHandlers[0].Process_Attribute_Dcoument_Detail__c = docDetails[0].Id;
        docHandlers[0].Document_Sharing_Task_Ids__c = tasks[0].Id + ',' + tasks[1].Id;
        docHandlers[0].status__c = 'Approved';
        docHandlers[0].Current_Task_ID__c = tasks[0].Id;
        
        docHandlers[1].Task_Id__c = tasks[1].Id;
        docHandlers[1].Process_Attribute_Dcoument_Detail__c = docDetails[1].Id;
        docHandlers[1].Document_Sharing_Task_Ids__c = tasks[1].Id.toString();
        docHandlers[1].status__c = 'Status2';
        docHandlers[1].Current_Task_ID__c = tasks[1].Id;
        insert docHandlers;
        system.debug('docHandlers[0].Process_Attribute_Dcoument_Detail__c'+docHandlers[0].Process_Attribute_Dcoument_Detail__c);
       	system.debug('docHandlers[1].Process_Attribute_Dcoument_Detail__c'+docHandlers[1].Process_Attribute_Dcoument_Detail__c);

        
        tasks[0].Process_Share_Document_Task_Ids__c = docHandlers[0].Current_Task_ID__c;
         tasks[1].Process_Share_Document_Task_Ids__c = docHandlers[1].Current_Task_ID__c;
        update tasks;
        
        List<Process_Task_Document_Sharing__c> sharings = new List<Process_Task_Document_Sharing__c>{
            new Process_Task_Document_Sharing__c(),
                new Process_Task_Document_Sharing__c()
                };
                    sharings[0].Process_Attribute_Dcoument_Detail__c = docDetails[0].Id;
        sharings[0].Process_Task_Detail__c = TestUtility.createMockProcessTaskDetail().Id; // Assuming TestUtility.createMockProcessTaskDetail() returns inserted instances
        sharings[1].Process_Attribute_Dcoument_Detail__c = docDetails[1].Id;
        sharings[1].Process_Task_Detail__c = TestUtility.createMockProcessTaskDetail().Id; // Same assumption as above
        insert sharings;
    }



    @isTest
    static void testTaskDocumentSharing() {
        Test.startTest();
        
        // Query the tasks created in the setup
        List<Task> tasks = [SELECT Id, WhatId, WhoId,Process_Path_Task_Detail__c,Process_Task_Detail__c,Process_Attribute_Object_Type__c,Process_Attribute__c,Process_Attribute_Path_Deviation__c,Process_Share_Document_Task_Ids__c FROM Task];
        system.debug('tasks::'+tasks[0].Process_Attribute_Object_Type__c);

        // Call the invocable method
        TaskDocumentSharing.TaskDocumentSharing(tasks);

        Test.stopTest();

        // Add more data manipulation or method calls if necessary to cover more code within TaskDocumentSharing
        // Note: No assertions are being used as per the instruction
    }
}