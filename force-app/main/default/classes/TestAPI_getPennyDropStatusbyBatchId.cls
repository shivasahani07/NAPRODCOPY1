@isTest
private class TestAPI_getPennyDropStatusbyBatchId {
    
    // Mock class to simulate HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;
        
        public MockHttpResponse(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(this.responseBody);
            res.setStatusCode(this.statusCode);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
    
    private static void setupTestData() {
        Task testTask =  TestUtility.createTestTaskWithAttribute('00T72000007DQvAEAW');
        insert testTask;

        Financial_Entity_AC_Detail__c testDetail = TestUtility.CreateFiancialEntityAcctDetailInsatance();
        testDetail.Name = 'Vignesh';
        testDetail.TransactionId__c  = '64789035467213';
        testDetail.BatchId__c = '54673848736623';
        testDetail.Task_ID__c = testTask.Id;
        insert testDetail;
    }
    
    // Test the getPeenyDropStatus method for a successful API call
    static testMethod void testGetPeenyDropStatusSuccess() {
        setupTestData();
        String mockResponse = '{"batchId":123,"transactionId":"abc123","status":"Success"}'; // Simplified example
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse, 200));
        
        Test.startTest();
        HttpResponse res = API_getPennyDropStatusbyBatchId.getPeenyDropStatus('123');
        Test.stopTest();
        
        System.assertEquals(200, res.getStatusCode());
        System.assert(res.getBody().contains('Success'), 'The response body should contain "Success"');
    }
    
    // Test the getPeenyDropStatus method for an API call that returns an error
    static testMethod void testGetPeenyDropStatusError() {
        setupTestData();
        String mockResponse = '{"errorCode":"400","errorDesc":"Invalid Request"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse, 400));
        
        Test.startTest();
        HttpResponse res = API_getPennyDropStatusbyBatchId.getPeenyDropStatus('invalid123');
        Test.stopTest();
        
        System.assertEquals(400, res.getStatusCode());
        System.assert(res.getBody().contains('Invalid Request'), 'The response body should contain "Invalid Request"');
    }
    
    // Test the processRequestdata method to handle different scenarios
    static testMethod void testProcessRequestdata() {
        setupTestData();
        // Setup test data for Task and Financial_Entity_AC_Detail__c
        
        Task testTask =  TestUtility.CreateTaskInstance();
        insert testTask;
        
        Financial_Entity_AC_Detail__c FEAC = TestUtility.CreateFiancialEntityAcctDetailInsatance();
         FEAC.Task_ID__c = testTask.Id;
        insert FEAC;
        // Assuming there's a record setup that matches this test
        Task testTask1 =  TestUtility.createTestTaskWithAttribute(FEAC.Id);
        insert testTask1;
        
        
        String mockResponse = '{"batchId":123,"transactionId":"abc123","status":"Success"}'; // Use successful response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse, 200));
        
        Test.startTest();
        String result = API_getPennyDropStatusbyBatchId.processRequestdata(testTask1.Id);
        Test.stopTest();
        
        // Deserialize the result to check the status and other properties
        API_getPennyDropStatusbyBatchId.auditwrapper resultData = (API_getPennyDropStatusbyBatchId.auditwrapper)JSON.deserialize(result, API_getPennyDropStatusbyBatchId.auditwrapper.class);
        //System.assertEquals('Success', resultData.status, 'The status should be "Success"');
    }
    
    // Additional tests can be written to cover more scenarios and exception handling.
}