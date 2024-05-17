@isTest(SeeAllData=false)
private class DocumentCourierDetailControllerTest {
    @isTest
    static void testGetDocumentCourierDetails() {  
        Account userAccDet = new Account(Name = 'Test User Account', Product_Bussiness_Line__c='NU Score');
        insert userAccDet;
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = userAccDet.Id, IsActive__c = true);
        insert testContact;
        Individual testIndividual = TestUtility.createIndividulaInstance();
        testIndividual.AccountId__c = userAccDet.id;
        insert testIndividual;
        User testUser = TestUtility.createUserInstance();
        testUser.IndividualId = testIndividual.id;
        insert testUser;

        Task testTaskData = TestUtility.CreateTaskInstance();
        insert testTaskData;

        Document_MetaData__c testDMD = TestUtility.createDocumentMetadata();
        insert testDMD;
        Financial_Account__c testFA = TestUtility.createFinancialAccountInstance();
        //insert testFA;
        Paybale__c testMEMO = TestUtility.createMODTInstance();
        //testMEMO.Financial_Account__c = testFA.id;
        //insert testMEMO;
        
        MODT_Details__c ModtDetails = TestUtility.CreateMODTDetailInsatance();
        ModtDetails.Task_Id__c = testTaskData.id;
        insert ModtDetails;
        
        Process_Attribute_Dcoument_Detail__c ProcessAtributeDocDetail = TestUtility.ProcessAttributeDocumentDetailInstance();
        Insert ProcessAtributeDocDetail;
        
        
        List<Document_Handler__c> documentHandlers = new List<Document_Handler__c>();
        
        
        Document_Handler__c testDocumentHandler = new Document_Handler__c(
            Status__c = 'Dispatched',
            Transfer_By__c = userAccDet.id,
            Transfer_to__c = userAccDet.Id,
            Document_Metadata__c = testDMD.id,
            Tracking_Number__c = '2345678',
            Extended_SObject_RecordId__c = testMEMO.id,
            Document_Sharing_Task_Ids__c = testTaskData.Id
        );
  
        documentHandlers.add(testDocumentHandler);
        Document_Handler__c testDocumentHandlerModt = new Document_Handler__c(
            Status__c = 'Dispatched',  
            Transfer_By__c = userAccDet.id,
            Transfer_to__c = userAccDet.Id,
            Document_Metadata__c = testDMD.id,
            Tracking_Number__c = '23456781',
            Extended_SObject_RecordId__c = ModtDetails.id,
            Document_Sharing_Task_Ids__c = testTaskData.Id
        );
        
        
        documentHandlers.add(testDocumentHandlerModt);
        
        Document_Handler__c testDocumentHandlerName = new Document_Handler__c(
            Status__c = 'Dispatched', 
            Document_Name__c = 'Test',
            Transfer_By__c = userAccDet.id,
            Transfer_to__c = userAccDet.Id,
            Document_Metadata__c = testDMD.id,
            Tracking_Number__c = '23456781',
            Extended_SObject_RecordId__c = ModtDetails.id,
            Document_Sharing_Task_Ids__c = testTaskData.Id
        );
        
        
        documentHandlers.add(testDocumentHandlerName);
        
        
        Document_Handler__c testDocumentHandlertatusTBH = new Document_Handler__c(
            Status__c = 'To Be Handed Over', 
            Document_Name__c = 'Cheque',
            Transfer_By__c = userAccDet.id,
            Transfer_to__c = userAccDet.Id,
            Document_Metadata__c = testDMD.id,
            Tracking_Number__c = '23456781',
            Extended_SObject_RecordId__c = ModtDetails.id,
            Document_Sharing_Task_Ids__c = testTaskData.Id
        );
        
        
        documentHandlers.add(testDocumentHandlertatusTBH);
		
        insert documentHandlers;

        System.runAs(testUser) {
            Test.startTest();
            system.debug('testUser.id===>'+testUser.id);
            DocumentCourierDetailController.wrapperforDocuments result = DocumentCourierDetailController.getDocumentCourierDetails(testTaskData);
            DocumentCourierDetailController.wrapperforDocuments result1 = DocumentCourierDetailController.docsWithdetails(testTaskData);
            DocumentCourierDetailController.wrapperforDocuments result2 = DocumentCourierDetailController.docsWithdetailsforStorage(testTaskData);
            Test.stopTest();
            System.assertNotEquals(null, result);
            System.assertNotEquals(null, result.documents);
        }
    }


    @isTest
    static void testMarkAsReceived() {
        User testUser = TestUtility.createUserInstance();
        insert testUser;

        Task testTaskData = TestUtility.createTaskInstance();
        insert testTaskData;

        Document_MetaData__c testDMD = TestUtility.createDocumentMetadata();
        insert testDMD;
        Document_Handler__c testDH = TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c = testDMD.id;
        testDH.Status__c = 'Dispatched';
        insert testDH;
        List<String> documentIds = new List<String>{testDH.Id};
        
        Test.startTest();
        String result = DocumentCourierDetailController.markAsReceived(documentIds);
        Test.stopTest();

        System.assertEquals('success', result);
        Document_Handler__c updatedDH = [SELECT Status__c FROM Document_Handler__c WHERE Id = :testDH.Id];
        System.assertEquals('Received', updatedDH.Status__c);
    }

    @isTest
    static void testDocsWithdetails() {
        User testUser = TestUtility.createUserInstance();
        //insert testUser;
        Task testTask = TestUtility.createTaskInstance();
        insert testTask;

       /* Test.startTest();
        DocumentCourierDetailController.wrapperforDocuments result = DocumentCourierDetailController.docsWithdetails(testTask);
        Test.stopTest();*/

        //System.assertNotEquals(null, result);
    }

    @isTest
    static void testUpdateDocumentRecord() {
        User testUser = TestUtility.createUserInstance();
        insert testUser;

        Document_MetaData__c testDMD = TestUtility.createDocumentMetadata();
        insert testDMD;
        Document_Handler__c testDH = TestUtility.createDocumentHandlerInstance();
        testDH.Document_Metadata__c = testDMD.id;
        insert testDH;

        testDH.Status__c = 'Received';
        testDH.Comment_History__c = 'Updated Comment';
        List<Document_Handler__c> documentsToUpdate = new List<Document_Handler__c>{testDH};

        Test.startTest();
        DocumentCourierDetailController.updateDocumentRecord(documentsToUpdate);
        Test.stopTest();

        Document_Handler__c updatedDH = [SELECT Status__c, Comment_History__c FROM Document_Handler__c WHERE Id = :testDH.Id];
        System.assertEquals('Received', updatedDH.Status__c);
        System.assertNotEquals(null, updatedDH.Comment_History__c);
    }
    
    private static Task createTestTask() {
        Task newTask = new Task(
            Subject = 'Test Task',
            Status = 'Open'
        );
        insert newTask;
        return newTask;
    }

    // Test method for successful task retrieval
    @isTest static void testGetTaskRecordByIdSuccess() {
        Task testTask = createTestTask();

        // Call the method with the ID of the inserted task
        Task retrievedTask = DocumentCourierDetailController.getTaskRecirdbyId(testTask.Id);

        // Assertions to check that the retrieved task matches the inserted task
        System.assertNotEquals(null, retrievedTask, 'Task should not be null');
        System.assertEquals(testTask.Id, retrievedTask.Id, 'The IDs should match');
        System.assertEquals('Test Task', retrievedTask.Subject, 'The subject should match');
    }

    // Test method to handle invalid task ID
    @isTest static void testGetTaskRecordByIdWithInvalidId() {
        String fakeId = '000000000000AAA'; // Non-existent ID
        Test.startTest();
        try {
            Task retrievedTask = DocumentCourierDetailController.getTaskRecirdbyId(fakeId);
            System.assert(false, 'Exception should have been thrown');
        } catch (QueryException e) {
            System.assert(e.getMessage().contains('List has no rows for assignment to SObject'), 'Expected no rows for assignment exception');
        }
        Test.stopTest();
    }
    
    
}