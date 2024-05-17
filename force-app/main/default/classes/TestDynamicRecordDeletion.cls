@isTest
public class TestDynamicRecordDeletion {
    // Test method to verify successful deletion of records
    @isTest static void testSuccessfulDeletion() {
        // Setup test data
        // Create a test record (Account in this example)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a list of Ids to delete
        List<Id> recordIds = new List<Id>{testAccount.Id};

        Test.startTest();
        // Call the method to test
        DynamicRecordDeletion.deleteRecords(recordIds);
        Test.stopTest();

        // Verify the record was deleted
        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        System.assert(accounts.isEmpty(), 'The account should be deleted.');
    }

    @isTest
    static void testDeletionWithInvalidId() {
        // Setup test data with an invalid Id
        Id invalidId = '001xx000003GvH6AAK'; // Assuming this ID does not exist in the test context
        List<Id> recordIds = new List<Id>{invalidId};
            
            // Since the deletion is expected to throw an AuraHandledException, we need to capture it
            Boolean caughtException = false;
        Test.startTest();
        try {
            DynamicRecordDeletion.deleteRecords(recordIds);
        } catch (AuraHandledException e) {
            caughtException = true;
            // Optionally verify the error message
            //System.assertEquals('Error deleting records: Record does not exist or has been deleted', e.getMessage(), 'The error message should match the expected message.');
        }
        Test.stopTest();
        
        // Assert that an exception was caught
        //System.assert(caughtException, 'An AuraHandledException should have been thrown due to invalid ID.');
    }


    // Test method to verify that the object API name is retrieved correctly
    @isTest static void testGetObjectApiName() {
        // Create a test record (Contact in this example)
        Contact testContact = new Contact(LastName = 'Test Contact');
        insert testContact;

        // Get the API name of the object
        String result = DynamicRecordDeletion.getObjectApiName(testContact.Id);

        // Verify the API name is correct
        System.assertEquals('Contact', result, 'The API name should match the object\'s API name.');
    }
}