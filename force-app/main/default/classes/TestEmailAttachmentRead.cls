@isTest
private class TestEmailAttachmentRead {
    
    @testSetup
    static void setupTestData() {
        // Setup test data for various scenarios
        Document_Metadata__c docMeta = TestUtility.createDocumentmetadata(); // Create Document_Metadata__c with 'MEMO Executed'
        TestUtility.createTestAccount(); // If needed by the Paybale__c records
        TestUtility.createMODTInstance(); // Create a few Paybale__c records
        // You can add more setup data if needed
    }
    
    @isTest
    static void testSuccessfulCsvProcessing() {
        
        Document_Metadata__c docMetaRec = new Document_Metadata__c();
        docMetaRec.Name = 'MEMO Executed';
        docMetaRec.Document_Name__c = 'MEMO Executed';
        insert docMetaRec;

        Paybale__c payrec = TestUtility.createMODTInstance();
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
		
        String csvContent = 'Customer Reference Number,Other,Columns,Go,Here\n' +
                            '12345,Data,For,Other,Columns\n';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.fileName = 'TestAttachment.csv';       
        attachment.body = Blob.valueOf(csvContent);
        Messaging.InboundEmail.TextAttachment attachmentText = new Messaging.InboundEmail.TextAttachment();
        attachmentText.fileName = 'TestAttachment.txt';       
        //attachmentText.body = 'This is a test attachment.';
        attachmentText.body = 'Customer Reference Number,RBI/UTR Reference Number,Instrument Number,STATUS\n'+payrec.Id+',123abcd,6748,Memo Created';
        
            
        email.subject = 'Test Subject';
        email.fromAddress = 'test@example.com';
        email.toAddresses = new String[] {'receiver@example.com'};
        email.plainTextBody = 'This is a test email body.';
        email.htmlBody = '<html><body>This is a test email body.</body></html>';
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{attachment}; 
            email.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{attachmentText};
       // email.textAttachments = '';

        // Step 3: Define the InboundEnvelope Object
        envelope.fromAddress = 'test@example.com';

        // Step 4: Create an instance of your email handler class
        EmailAttachmentRead handler = new EmailAttachmentRead();

        // Step 5: Call the Test Method
        
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);
       
        
        
    ///    Messaging.InboundEmail email = new Messaging.InboundEmail();
    //    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
     //   email.subject = 'Test Email with CSV';
        
        /*
        // Simulate CSV attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.fileName = 'test.csv';
        attachment.body = Blob.valueOf('Customer Reference Number,RBI/UTR Reference Number,Instrument Number,STATUS\n12345,RBI123,67890,Completed');
        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] { attachment };

        EmailAttachmentRead handler = new EmailAttachmentRead();
        handler.handleInboundEmail(email, envelope);
      */

    }

    
    
    



}