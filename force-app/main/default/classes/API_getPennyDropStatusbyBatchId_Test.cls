@IsTest
public class API_getPennyDropStatusbyBatchId_Test {

    private static void setupTestData() {
        insert TestUtility.createTestTaskWithAttribute('00T72000007DQvAEAW');
        Financial_Entity_AC_Detail__c testDetail = TestUtility.CreateFiancialEntityAcctDetailInsatance();
        testDetail.Name = 'Vignesh';
        testDetail.TransactionId__c = '64789035467213';
        testDetail.BatchId__c = '54673848736623';
        testDetail.Task_ID__c = [SELECT Id FROM Task WHERE Attribute1__c = '00T72000007DQvAEAW' LIMIT 1].Id;
        insert testDetail;
    }

    @IsTest
    static void testGetPennyDropStatusError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, '{ "error": "Bad Request" }'));
        HttpResponse response = API_getPennyDropStatusbyBatchId.getPennyDropStatus('12345');
        System.assertEquals(400, response.getStatusCode());
        System.assert(response.getBody().contains('Bad Request'));
    }

    @IsTest
    static void testGetPennyDropStatus502() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(502, 'Mock Exception'));
        HttpResponse response = API_getPennyDropStatusbyBatchId.getPennyDropStatus('12345');
        System.assertEquals(502, response.getStatusCode());
        System.assert(response.getBody().contains('Mock Exception'));
    }

    @IsTest
    static void testGetPennyDropStatusException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionGenerator());
        HttpResponse response = API_getPennyDropStatusbyBatchId.getPennyDropStatus('12345');
        System.assertEquals(500, response.getStatusCode());
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }

    private class MockHttpExceptionGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Mock Exception');
        }
    }

    @IsTest
    static void testGetPennyDropStatusSuccess() {
        setupTestData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"batchId":123,"transactionId":"abc123","status":"Success"}'));
        Test.startTest();
        HttpResponse res = API_getPennyDropStatusbyBatchId.getPennyDropStatus('1265683');
        Test.stopTest();
        System.assertEquals(200, res.getStatusCode());
        System.assert(res.getBody().contains('Success'));
    }

    @IsTest
    static void testProcessRequestData() {
        setupTestData();
        Task testTask1 = TestUtility.createTestTaskWithAttribute([SELECT Id FROM Financial_Entity_AC_Detail__c LIMIT 1].Id);
        insert testTask1;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"batchId":64789035467213,"transactionId":"54673848736623","status":"Success"}'));
        Test.startTest();
        String result = API_getPennyDropStatusbyBatchId.processRequestData(testTask1.Id);
        Test.stopTest();
        API_getPennyDropStatusbyBatchId.auditwrapper resultData = (API_getPennyDropStatusbyBatchId.auditwrapper) JSON.deserialize(result, API_getPennyDropStatusbyBatchId.auditwrapper.class);
        
        
    }

    @IsTest
    static void testProcessRequestData502Error() {
        setupTestData();
        Task testTask1 = TestUtility.createTestTaskWithAttribute([SELECT Id FROM Financial_Entity_AC_Detail__c LIMIT 1].Id);
        insert testTask1;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(502, '{"errorCode":"502","errorDesc":"Bad Gateway"}'));
        Test.startTest();
        String result = API_getPennyDropStatusbyBatchId.processRequestData(testTask1.Id);
        Test.stopTest();
        API_getPennyDropStatusbyBatchId.auditwrapper resultData = (API_getPennyDropStatusbyBatchId.auditwrapper) JSON.deserialize(result, API_getPennyDropStatusbyBatchId.auditwrapper.class);
        System.assertEquals(Label.AuditAPIFailedStatus, resultData.status);
        
    }
}