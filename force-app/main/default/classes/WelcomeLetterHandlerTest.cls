@isTest
public class WelcomeLetterHandlerTest {
     @isTest
    static void testWelcomeLetterGenerationFlowWithNoReceivables() {
        // Arrange
        Account testAccount = TestUtility.createTestAccount();
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opportunity';
        testOpportunity.StageName = 'Prospecting'; 
        testOpportunity.CloseDate = Date.today().addDays(10); 
        testOpportunity.AccountId = testAccount.Id;
        insert testOpportunity;
        Task testTask = new Task();
        testTask.WhatId = testOpportunity.Id;
      	insert testTask;

        Financial_Account__c financialAccount = TestUtility.CreateFinancialAccountInstanceW();
        financialAccount.Opportunity__c = testOpportunity.Id;
        financialAccount.Tenuer__c = 16;
        insert financialAccount;

        // Mock setup for API call
        Test.setMock(HttpCalloutMock.class, new QuickBrickAPIMockResponse());

        // Act
        Test.startTest();
        AuditResponseWrapperClass result = WelcomeLetterHandler.WelcomeLetterGenerationFlow(testTask.Id);
        Test.stopTest();

        
    }

    private class QuickBrickAPIMockResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"success":true,"data":{"loan_account_schedule":[{"installment_no":"1","installment_date":"2023-05-01","installment_amount":"1000"}]}}');
            response.setStatus('OK');
            return response;
        }
    }

    

    @isTest
    static void testWelcomeLetterGenerationFlowWithExistingReceivables() {
        // Arrange
        Account testAccount = TestUtility.createTestAccount();
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opportunity';
        testOpportunity.StageName = 'Prospecting'; 
        testOpportunity.CloseDate = Date.today().addDays(10); 
        testOpportunity.AccountId = testAccount.Id;
        insert testOpportunity;
        Task testTask = new Task();
        testTask.WhatId = testOpportunity.Id;
      	insert testTask;
       // Payment_Schedule__c paymentSchedule = TestUtility.createTestPaymentSchedule(testOpportunity.Id);
        Financial_Account__c financialAccount = TestUtility.CreateFinancialAccountInstanceW();
        financialAccount.Opportunity__c = testOpportunity.Id;
        financialAccount.Tenuer__c = 16;
        insert financialAccount;
        Receivable__c receivable = new Receivable__c(Financial_Account__c = financialAccount.Id, RecordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId());
        insert receivable;

        // Act
        Test.startTest();
        AuditResponseWrapperClass result = WelcomeLetterHandler.WelcomeLetterGenerationFlow(testTask.Id);
        Test.stopTest();

        // Assert
        System.assert(result != null, 'Result should not be null');
        System.assertEquals('Schedule already initiated.', result.auditRec.Response__c, 'Should recognize already initiated schedule');
    }

    @isTest
    static void testWelcomeLetterGenerationFlowExceptionHandling() {
        // Arrange
        Account testAccount = TestUtility.createTestAccount();
        Opportunity testOpportunity = TestUtility.createTestOpportunity(testAccount.Id);
        insert testOpportunity;
        Task testTask = new Task(WhatId = testOpportunity.Id);
        insert testTask;
        Id recordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId();

        // Act & Assert
        Test.startTest();
        Exception thrownException = null;
        try {
            AuditResponseWrapperClass result = WelcomeLetterHandler.WelcomeLetterGenerationFlow(testTask.Id);
        } catch (Exception e) {
            thrownException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, thrownException, 'Exception should be thrown due to invalid setup');
    }

    @isTest
    static void testCreatePDFFile() {
        // Arrange
        Account testAccount = TestUtility.createTestAccount();
        Opportunity testOpportunity = TestUtility.createTestOpportunity(testAccount.Id);
        Task testTask = TestUtility.createTestTaskForOpportunity(testOpportunity.Id);

        // Simulate @future method behavior
        Test.startTest();
        WelcomeLetterHandler.createPDFFile(testOpportunity.Id, testTask.Id);
        Test.stopTest();

        // Assertions would depend on observable outcomes of createPDFFile method (usually queried data or logs)
    }
}