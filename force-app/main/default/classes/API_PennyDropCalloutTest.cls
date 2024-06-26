@IsTest
public class API_PennyDropCalloutTest {
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        
        public MockHttpResponseGenerator(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }
        
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(body);
            return response;
        }
    }
    
    private class MockHttpExceptionGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Mock Exception');
        }
    }

    private static Task setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = testAccount.Id);
        insert testOpportunity;
        
        Financial_Account__c faAccount = new Financial_Account__c(Account_Name__c = testAccount.Id, Amount__c = 5000, EMI_Amount__c = 300, First_EMI_Date__c = System.today(), Opportunity__c = testOpportunity.Id);
        insert faAccount;

        Financial_Entity__c FinancialEntity = new Financial_Entity__c(Financial_Account__c = faAccount.Id, Account_Name__c = testAccount.Id);
        insert FinancialEntity;
        
        Financial_Entity_AC_Detail__c feac = new Financial_Entity_AC_Detail__c(Bank_Account_Number__c = 'Test Bank Account', Bank_Account_Type__c = 'Savings', Bank_Name__c = 'Axis Bank', Branch_Name__c = 'Kormanagala', Banking_Account_Name__c = 'Test Banking Name', Financial_Account__c = faAccount.Id, Financial_Entity__c = FinancialEntity.Id, IFSC_Code__c = 'test IFSC');
        insert feac;
        
        Task taskRec = new Task(WhatId = testOpportunity.Id, Attribute1__c = feac.Id);
        insert taskRec;

        return taskRec;
    }

    @IsTest
    static void testProcessResponseData_Success() {
        Task taskRec = setupTestData();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"message": "success", "status":"Verified", "batchId":12345654}'));
        API_PennyDropCallout.processResponseData(taskRec.Id);
        Test.stopTest();

        Financial_Entity_AC_Detail__c updatedFEAC = [SELECT Verification_Status__c FROM Financial_Entity_AC_Detail__c WHERE Id = :taskRec.Attribute1__c];
        System.assertEquals('Verified', updatedFEAC.Verification_Status__c);
    }

    @IsTest
    static void testProcessResponseData_502Response() {
        Task taskRec = setupTestData();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(502, 'Bad Gateway'));
        API_PennyDropCallout.processResponseData(taskRec.Id);
        Test.stopTest();

        Financial_Entity_AC_Detail__c updatedFEAC = [SELECT Verification_Status__c FROM Financial_Entity_AC_Detail__c WHERE Id = :taskRec.Attribute1__c];
        System.assertEquals('Failed', updatedFEAC.Verification_Status__c);
    }

    @IsTest
    static void testProcessResponseData_400Response() {
        Task taskRec = setupTestData();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, 'Invalid Request'));
        API_PennyDropCallout.processResponseData(taskRec.Id);
        Test.stopTest();

        Financial_Entity_AC_Detail__c updatedFEAC = [SELECT Verification_Status__c FROM Financial_Entity_AC_Detail__c WHERE Id = :taskRec.Attribute1__c];
        System.assertEquals('Failed', updatedFEAC.Verification_Status__c);
    }

    @IsTest
    static void testPennyDropVerify_Exception() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionGenerator());
        HttpResponse response = API_PennyDropCallout.penyDropVerify(new API_PennyDropCallout.penyDropDataInputWrapper());
        Test.stopTest();
        System.assertEquals(null, response);
    }

    @IsTest
    static void testPennyDropVerify_Non200Response() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        HttpResponse response = API_PennyDropCallout.penyDropVerify(new API_PennyDropCallout.penyDropDataInputWrapper());
        Test.stopTest();
        System.assertEquals(500, response.getStatusCode());
        System.assertEquals('Internal Server Error', response.getBody());
    }
}