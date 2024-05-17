@isTest
private class lwc_Handledocuments_ControllerTest {
    
    /*@isTest
    static void testGetDocumentHandler() {
        Process_Task_Detail__c testPTD =TestUtility.createPTDinstance();
        insert testPTD;
        Process_Path__c  testPP=TestUtility.createProcessPAthInstance();
        insert	testPP;
        Process_Path_Task_Detail__c  testPPTD=TestUtility.createPPTD();
        testPPTD.Process_Path__c=testPP.id;
        testPPTD.Business_Step_No__c=3;
        testPPTD.Execution_Serial_No__c='4';
        testPPTD.Task_Owner_Type__c='System';
        testPPTD.Task_Owner_Name__c='Test Task Owner';
        testPPTD.Process_Task_Detail__c=testPTD.id;
        insert testPPTD;	
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task parentestTask=TestUtility.CreateTaskInstance();
        parentestTask.WhatId=TestAccount.id;
        insert parentestTask;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        testTask.Parent_Task_Id__c = parentestTask.id;
        testTask.Process_Path_Task_Detail__c=testPPTD.id;
        insert testTask;
        
        // Call the method to test
        lwc_Handledocuments_Controller.wrapperHandler result = lwc_Handledocuments_Controller.getDocumentHandler(testTask.Id, 'ExtendedSObjectRecordId','documentsharingTaskId');
        
        // Perform assertions
        //System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testUpsertDocumentHandler() {
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        insert testDH;
        // Call the method to test
        List<Document_Handler__c> result = lwc_Handledocuments_Controller.UpsertDocumentHandler(new List<Document_Handler__c>{testDH}, 'Insert/UpsertDocHandler');
        
        // Perform assertions
        System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testInsertTaskforReview() {
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        insert testDH;
        // Call the method to test
        Document_Handler__c result = lwc_Handledocuments_Controller.insertTaskforReview(testDH);
        
        // Perform assertions
        System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testUploadFile() {
        // Call the method to test
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        insert testDH;
        
        lwc_Handledocuments_Controller.UploadWrapper result = lwc_Handledocuments_Controller.uploadFile('base64String', 'testFile.txt',testDH.id,'uploadedTaskId');
        
        // Perform assertions
        System.assertNotEquals(null, result, 'Expected a non-null result');
        // Add more assertions based on the expected behavior of the method
    }
    
    @isTest
    static void testUpdateDhStatus() {
       
        Account TestAccount =TestUtility.createaccountInstance();
        TestAccount.Product_Bussiness_Line__c='NU Score';
        insert TestAccount ;
        task testTask=TestUtility.CreateTaskInstance();
        testTask.WhatId=TestAccount.id;
        //testTask.Process_Path_Task_Detail__c=testPPTD.id;
        insert testTask;
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        insert testDH;
        // Call the update_dh_status method with the test records
        lwc_Handledocuments_Controller.deviation_reviewer_wrapper result = lwc_Handledocuments_Controller.update_dh_status(testDH, testTask.Id, 'Completed');
        
        // Retrieve the updated records
        Document_Handler__c updatedDhRecord = [SELECT Id, Status__c FROM Document_Handler__c WHERE Id = :testDH.Id LIMIT 1];
        Task updatedTaskRecord = [SELECT Id, Status FROM Task WHERE Id = :testTask.Id LIMIT 1];
        
        // Assert that the records were updated as expected
        
    }
    
    @isTest
    static void testUpsertDocHandlerCreateDeviation() {
        // Create a test Process_Attribute_Dcoument_Detail__c record
        Document_metaData__c testDMD=TestUtility.createDocumentmetadata();
        insert testDMD;
        Process_Attribute_Dcoument_Detail__c testPADD = new Process_Attribute_Dcoument_Detail__c();
        testPADD.Document_Metadata__c=testDMD.id;
        testPADD.Deviation_Approver_Type__c='User';
        Document_Handler__c testDH=TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c=testDMD.id;
        testDH.Process_Attribute_Dcoument_Detail__c=testPADD.id;
        testDH.Status__c='Submitted for Deviation Approval';
        insert testDH;
        lwc_Handledocuments_Controller.upsertDocHandler_CreateDeviation(new List<Document_Handler__c>{testDH});
        
        // Retrieve the updated records
        Document_Handler__c updatedDHRecord = [SELECT Id, Status__c FROM Document_Handler__c WHERE Id = :testDH.Id LIMIT 1];
        // Task updatedTaskRecord = [SELECT Id, Status FROM Task WHERE Review_Record_Id__c = :testDH.Id LIMIT 1];
        
        
    }*/
    
        @isTest
    static void testGetDocumentHandler() {
        Test.startTest();
        
        // Setup test data
        Task task = TestUtility.createTestTaskWithAttribute('SampleAttributeValue');
        insert task;

        Document_Handler__c docHandler = TestUtility.createDocumentHandlerInstance();
        docHandler.Task_Id__c = task.Id;
        insert docHandler;
        
        Document_Handler_History__c DHH =TestUtility.createDHHInstance();
        DHH.Document_Handler__c = docHandler.Id;
        DHH.Task_Id__c = task.Id;
        insert DHH;

        // Test getDocumentHandler method
        lwc_Handledocuments_Controller.getDocumentHandler(task.Id, docHandler.Extended_SObject_RecordId__c, docHandler.Document_Sharing_Task_Ids__c);
        Test.stopTest();
    }

    @isTest
    static void testUpsertDocumentHandler() {
        Test.startTest();
        // Setup test data
        List<Document_Handler__c> docHandlers = new List<Document_Handler__c>{
            TestUtility.createDocumentHandlerInstance(),
            TestUtility.createDocumentHandlerInstance()
        };
        // Test upsertDocumentHandler method
        lwc_Handledocuments_Controller.upsertDocumentHandler(docHandlers, 'Insert/UpsertDocHandler');
        Test.stopTest();
    }

    @isTest
    static void testInsertTaskForReview() {
        Test.startTest();
        // Setup test data
        Document_Handler__c docHandler = TestUtility.createDocumentHandlerInstance();
        insert docHandler;
        // Test insertTaskforReview method
        lwc_Handledocuments_Controller.insertTaskforReview(docHandler);
        Test.stopTest();
    }

    @isTest
    static void testUploadFile() {
        Test.startTest();
        // Create necessary records and related data
        Account testAccount = TestUtility.createTestAccount();
        //insert testAccount;

        Task task = TestUtility.createTestTaskWithAttribute('SampleAttributeValue');
        task.WhatId = testAccount.Id;
        insert task;

        Document_Handler__c docHandler = TestUtility.createDocumentHandlerInstance();
        docHandler.Task_Id__c = task.Id;
        insert docHandler;

        // Use a sample base64 string representing a file
        String base64 = 'SampleBase64String';
        String filename = 'TestFile';
        
        // Use the actual record ID instead of a dummy ID
        String recordId = docHandler.Id; // Assuming the Document_Handler__c record is linked to the ContentVersion via recordId
        String uploadedTaskId = task.Id;

        // Test the uploadFile method
        lwc_Handledocuments_Controller.uploadFile(base64, filename, recordId, uploadedTaskId);
        Test.stopTest();
    }


    @isTest
    static void testUpdateDHStatus() {
        Test.startTest();
        // Setup test data
        Document_Handler__c dh = TestUtility.createDocumentHandlerInstance();
        Task task = TestUtility.CreateTaskInstance();
        insert dh;
       // insert task;

        // Test update_dh_status method
        lwc_Handledocuments_Controller.update_dh_status(dh, task.Id, 'NewStatus');
        Test.stopTest();
    }
    
    @isTest
    static void testUpsertDocHandlerCreateDeviation() {
        Test.startTest();
        Task task = TestUtility.createTestTaskWithAttribute('SampleAttributeValue');
        insert task;
        
        
        // Setup test data
        Process_Attribute_Dcoument_Detail__c padDetail = TestUtility.ProcessAttributeDocumentDetailInstance();
        padDetail.Is_Alternate_Document_Upload_Applicable__c = true;
        // Populate necessary fields on padDetail...
        insert padDetail;
        system.debug('padDetail :::: ' +padDetail.Deviation_Approver_Type__c);
        
        Document_Handler__c docHandler = TestUtility.createDocumentHandlerInstance();
   		 docHandler.Process_Attribute_Dcoument_Detail__c = padDetail.Id;
        dochandler.Task_Id__c = task.Id;
    	docHandler.Status__c = 'Pending Deviation Approval';
        docHandler.Process_Attribute_Dcoument_Detail__c = padDetail.Id;
    	insert docHandler;
        
        
        
         Process_Attribute_Dcoument_Detail__c padDetail2 = TestUtility.ProcessAttributeDocumentDetailInstance();
        padDetail2.Deviation_Approver_Type__c ='User';
        padDetail2.Is_Alternate_Document_Upload_Applicable__c = true;
        // Populate necessary fields on padDetail...
        insert padDetail2;
        system.debug('padDetail :::: ' +padDetail.Deviation_Approver_Type__c);
        
        Document_Handler__c docHandler2 = TestUtility.createDocumentHandlerInstance();
        docHandler2.Task_Id__c = task.Id;
    	docHandler2.Process_Attribute_Dcoument_Detail__c = padDetail2.Id;
        docHandler2.Is_Alternate_Document_Uploded__c = true;
    	docHandler2.Status__c = 'Pending Deviation Approval';
    	insert docHandler2;
        
        Document_Handler__c docHand1=[Select Id,Document_Metadata__r.Is_DocumentId_Mandatory__c,Account__c,Payable__c,MODT_Details__c,Opportunity__c,Is_Alternate_Document_Uploded__c,Document_Id_Value__c,Exempted__c,Extended_SObject_RecordId__c,Document_SLA__c,Comment_History__c,Process_Attribute_Dcoument_Detail__r.Is_New_Document__c,Status__c,Physical_Document_Mandatory__c,Description__c,Physical_Document_Received__c,Document_Metadata__c,Upload_Mandatory__c,Task_Id__c,Review_Required__c,Document_Metadata__r.Document_Category__c,
                             Document_Metadata__r.Document_Name__c,Document_Metadata__r.Description__c,Reviewer_Name__c,Process_Attribute_Dcoument_Detail__c, 
                             Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c,Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c,Process_Attribute_Dcoument_Detail__r.DMS_System__c, 
                             Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c,Process_Attribute_Dcoument_Detail__r.Reviewer_Type__c,Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c From Document_Handler__c Where Id=:docHandler.Id];
        
        Task task2 = TestUtility.createTestTaskWithAttribute('SampleAttributeValue');
        task2.Review_Record_Id__c = docHand1.id;
        task2.Child_Task_Category__c='Deviation Approval - Record Level';
        insert task2;
        
         Document_Handler__c docHand2=[Select Id,Document_Metadata__r.Is_DocumentId_Mandatory__c,Account__c,Payable__c,MODT_Details__c,Opportunity__c,Is_Alternate_Document_Uploded__c,Document_Id_Value__c,Exempted__c,Extended_SObject_RecordId__c,Document_SLA__c,Comment_History__c,Process_Attribute_Dcoument_Detail__r.Is_New_Document__c,Status__c,Physical_Document_Mandatory__c,Description__c,Physical_Document_Received__c,Document_Metadata__c,Upload_Mandatory__c,Task_Id__c,Review_Required__c,Document_Metadata__r.Document_Category__c,
                             Document_Metadata__r.Document_Name__c,Document_Metadata__r.Description__c,Reviewer_Name__c,Process_Attribute_Dcoument_Detail__c, 
                             Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c,Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c,Process_Attribute_Dcoument_Detail__r.DMS_System__c, 
                             Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c,Process_Attribute_Dcoument_Detail__r.Reviewer_Type__c,Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c From Document_Handler__c Where Id=:docHandler2.Id];

   
         List<Document_Handler__c> docHandlerslist = new List<Document_Handler__c>{docHand2, docHand1};

    // This will execute the logic in the upsertDocHandler_CreateDeviation method
    lwc_Handledocuments_Controller.UpsertDocumentHandler(docHandlerslist, 'UpsertDocHandlerDeviation');

    Test.stopTest();
    }


    @isTest
    static void testAddAlternativeDocuments() {
        Test.startTest();
        
        // Create and insert test records necessary to satisfy method conditions
        Process_Attribute_Dcoument_Detail__c padDetail = TestUtility.ProcessAttributeDocumentDetailInstance();
        padDetail.Is_Alternate_Document_Upload_Applicable__c = true;
        // Set necessary fields on padDetail
        insert padDetail;
        
        Document_Handler__c docHandler = TestUtility.createDocumentHandlerInstance();
        docHandler.Process_Attribute_Dcoument_Detail__c = padDetail.Id;
        docHandler.Is_Alternate_Document_Uploded__c = true;
        insert docHandler;
        
        List<Document_Handler__c> docHandlers = new List<Document_Handler__c>{docHandler};
            
            // This will execute the logic in the AddAlternativedocuments method
        lwc_Handledocuments_Controller.upsertDocumentHandler(docHandlers, 'AddMoreAlternativeDocuments');
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testAddMoreAlternativeDocuments() {
        Test.startTest();
        
        // Setup necessary records
        Account testAccount = TestUtility.createTestAccount();
       
        
        Opportunity testOpportunity = TestUtility.createTestOpportunity(testAccount.Id);
        
        
        Process_Attribute__c proAttr = TestUtility.createProAttributeInstance();
        insert proAttr;
        
       // Process_Attribute_Details__c proAttrDetails = TestUtility.createProAttridetailsInstance();
        //insert proAttrDetails;
        
        Process_Attribute_Dcoument_Detail__c padDetail = TestUtility.ProcessAttributeDocumentDetailInstance();
        //padDetail.Process_Attribute_Details__c = proAttrDetails.Id;
            // Set other necessary fields for Process_Attribute_Dcoument_Detail__c
        insert padDetail;
        
        Document_Handler__c docHandler = TestUtility.createDocumentHandlerInstance();
        docHandler.Process_Attribute_Dcoument_Detail__c = padDetail.Id;
        docHandler.Is_Alternate_Document_Uploded__c = true;
        insert docHandler;
        
        List<Document_Handler__c> dhList = new List<Document_Handler__c>{ docHandler };
            
            // Execute the method with the 'AddMoreAlternativeDocuments' operation
            lwc_Handledocuments_Controller.upsertDocumentHandler(dhList, 'AddMoreAlternativeDocuments');
        
        Test.stopTest();
    }

    
    

    
    

    
}