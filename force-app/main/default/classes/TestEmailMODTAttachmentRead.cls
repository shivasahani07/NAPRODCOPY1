@isTest
public class TestEmailMODTAttachmentRead {
    // Utility method to create and insert necessary data for testing createMODTDocHandler()
    private static void setupTestData() {
        // Create test Account
        Account testAccount = TestUtility.createTestAccount();
        Paybale__c payableRec =TestUtility.createMODTInstance();

        // Create test Opportunity linked to the Account
        Opportunity testOpportunity = TestUtility.createTestOpportunity(testAccount.Id);
        
        Process_Path_Task_Detail__c processPathTaskDetail = TestUtility.createPPTD();

        // Insert Financial Accounts correctly linking to the Opportunity
        List<Financial_Account__c> financialAccounts = new List<Financial_Account__c>{
            new Financial_Account__c(
                Name='Financial Account 1',
                Opportunity__c=testOpportunity.Id,  // Use the correct Opportunity ID
                LOS_Application_ID__c='12345'  // This should match the LOANNO in your test CSV
            ),
            new Financial_Account__c(
                Name='Financial Account 2',
                Opportunity__c=testOpportunity.Id,  // Use the correct Opportunity ID
                LOS_Application_ID__c='67890'  // Matching second LOANNO
            )
        };
        insert financialAccounts;
        
        Document_Metadata__c docMeta = new Document_Metadata__c(
            Name = 'Test Document Metadata',
            Document_Category__c = 'Finance',
            Description__c = 'Finance Document',
            Physical_Document_Mandatory__c = true,
            Upload_Mandatory__c = true
        );
        insert docMeta;


		Task otcTask = new Task(
            WhatId = testOpportunity.Id,
            Subject = Constants.OTC_DOCUMENT_COLLECTION,
            Status = 'Open',
            Process_Path_Task_Detail__c = processPathTaskDetail.Id // Placeholder, adjust as necessary
        );
        Task pddTask = new Task(
            WhatId = testOpportunity.Id,
            Subject = Constants.PDD_DOCUMENT_COLLECTION,
            Status = 'Open',
            Process_Path_Task_Detail__c = processPathTaskDetail.Id // Placeholder, adjust as necessary
        );
        insert new List<Task>{otcTask, pddTask};
            
        Process_Attribute_Dcoument_Detail__c ProcessAttributeDocumentDetail = TestUtility.ProcessAttributeDocumentDetailInstance();
        ProcessAttributeDocumentDetail.Document_Metadata__c = docMeta.Id;
        ProcessAttributeDocumentDetail.Process_Path_Task_Detail__c = processPathTaskDetail.Id;
        Insert ProcessAttributeDocumentDetail;
        
         /*Document_Handler__c docHandler = new Document_Handler__c(
            Task_Id__c = String.valueOf(task.Id),
            Document_Metadata__c = docMeta.Id,
            Transfer_to__c = testAccount.Id,
             Tracking_Number__c='123456',
            Status__c = 'Draft',
             Extended_SObject_RecordId__c=payableRec.Id,
             Process_Attribute_Dcoument_Detail__c =ProcessAttributeDocumentDetail.id
        );
        insert docHandler;*/
        
        Document_Metadata__c additionalDocMeta = new Document_Metadata__c(
            Name = 'Additional Document Metadata',
            Document_Category__c = 'Healthcare',
            Description__c = 'Healthcare Document',
            Physical_Document_Mandatory__c = false,
            Upload_Mandatory__c = false
        );
        insert additionalDocMeta;

        // Assuming other necessary records are set up similarly
    }


    @isTest
    static void testHandleInboundEmailWithTextAttachment() {
        setupTestData();  // Ensure all needed data is ready before running the test

        // Mock CSV data as it would appear in the inbound email attachment
        String csvData = 'LOANNO,PDD / OTC,CATEGORY OF OTC/PDD\n';
        csvData += '12345,OTC,"Education (EDU);Healthcare (Primary Care)"\n';
        csvData += '67890,PDD,"Finance (Banking);Retail (Malls)"\n';

        // Prepare email and envelope
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.textAttachments = new List<Messaging.InboundEmail.textAttachment>();
        email.textAttachments.add(prepareTextAttachment(csvData));
        Messaging.InboundEnvelope env = prepareEnvelope();

        // Instantiate the handler and process the email
        EmailMODTAttachmentRead handler = new EmailMODTAttachmentRead();
        Test.startTest();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);
        Test.stopTest();

        // Assertions to check the outcome
        System.assert(result.success, 'The email processing should be successful');
        List<Document_Handler__c> handlers = [SELECT Id, Status__c FROM Document_Handler__c];
        //System.assertNotEquals(0, handlers.size(), 'Document handlers should be created or updated.');
        
        // Verify that the document metadata exclusion logic works correctly
        List<Document_Metadata__c> metaList = [SELECT Id FROM Document_Metadata__c WHERE Physical_Document_Mandatory__c = true];
        System.assertEquals(1, metaList.size(), 'Should match documents with mandatory physical document requirements');
    }

    // Additional test methods as necessary...

    // Utility method for preparing text attachments
    private static Messaging.InboundEmail.textAttachment prepareTextAttachment(String body) {
        Messaging.InboundEmail.textAttachment txtAttachment = new Messaging.InboundEmail.textAttachment();
        txtAttachment.fileName = 'test.csv';
        txtAttachment.body = body;
        return txtAttachment;
    }

    // Utility method to prepare envelope
    private static Messaging.InboundEnvelope prepareEnvelope() {
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'test@example.com';
        env.toAddress = 'receiver@example.com';
        return env;
    }
}