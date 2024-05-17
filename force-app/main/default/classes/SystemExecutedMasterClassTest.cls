@IsTest
public class SystemExecutedMasterClassTest {
    private static void createTestData() {
        
        Account testAccount = TestUtility.createTestAccount();
        Task testTask = TestUtility.createTestTaskWithAttribute('SampleAttribute');
        insert testTask; 
        
        
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;

        public MockHttpResponseGenerator(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }

    private static SystemExecutedMasterClass.FlowInput prepareFlowInput(String actionName, Id recordId, Id taskRecordId) {
        SystemExecutedMasterClass.FlowInput input = new SystemExecutedMasterClass.FlowInput();
        input.recordId = recordId;
        input.actionName = actionName;
        input.taskRecordId = taskRecordId;
        return input;
    }

    
    
    private static void testAction(String actionName) {
        createTestData();

        Task testTask = [SELECT Id FROM Task LIMIT 1];
        API_Callout_Audit__c acaRec = new API_Callout_Audit__c();
        insert acaRec; 

        SystemExecutedMasterClass.FlowInput input = prepareFlowInput(actionName, acaRec.Id, testTask.Id);

        if (actionName.contains('API')) {
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"status":"Success","RequestBody":"test","ResponseBody":"response"}', 200));
        }

        Test.startTest();
        SystemExecutedMasterClass.processRecords(new List<SystemExecutedMasterClass.FlowInput>{ input });
        Test.stopTest();

        
        API_Callout_Audit__c updatedAudit = [SELECT API_Status__c FROM API_Callout_Audit__c WHERE Id = :acaRec.Id];
        //System.assertNotEquals(null, updatedAudit.API_Status__c, 'API status should be updated');
    }

   /* @IsTest
    static void testSendPayableDetailsToCustomer() {
        testAction('SendPayableDetailsToCustomer');
    }*/

    

    @IsTest
    static void testAPISearchPartnersAPI() {
        testAction('API_SearchPartnersAPI');
    }

    @IsTest
    static void testAPICreatePartnerAPI() {
        testAction('API_CreatePartnerAPI');
    }

    @IsTest
    static void testAPICreatePaymentScheduleAPI() {
        testAction('API_CreatePaymentScheduleAPI');
    }

    @IsTest
    static void testAPIAddRecalibrationAPI() {
        testAction('API_AddRecalibrationAPI');
    }

    @IsTest
    static void testAPIPennyDropCallout() {
        createTestData();
        Task testTask = [SELECT Id FROM Task LIMIT 1];
        API_Callout_Audit__c acaRec = new API_Callout_Audit__c();
        insert acaRec;
        
        SystemExecutedMasterClass.FlowInput input = prepareFlowInput('API_PennyDropCallout', acaRec.Id, testTask.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"status":"Success","RequestBody":"test","ResponseBody":"response"}', 200));
        
        Test.startTest();
        SystemExecutedMasterClass.processRecords(new List<SystemExecutedMasterClass.FlowInput>{ input });
        Test.stopTest();
        
        API_Callout_Audit__c updatedAudit = [SELECT API_Status__c FROM API_Callout_Audit__c WHERE Id = :acaRec.Id];
        //System.assertNotEquals(null, updatedAudit.API_Status__c, 'API status should be updated for PennyDropCallout');
    }
    
    @IsTest
    static void testAPIGetPennyDropStatusbyBatchId() {
        createTestData();
        Task testTask = [SELECT Id FROM Task LIMIT 1];
        API_Callout_Audit__c acaRec = new API_Callout_Audit__c();
        insert acaRec;
        
        SystemExecutedMasterClass.FlowInput input = prepareFlowInput('API_getPennyDropStatusbyBatchId', acaRec.Id, testTask.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"status":"Success","RequestBody":"test","ResponseBody":"response"}', 200));
        
        Test.startTest();
        SystemExecutedMasterClass.processRecords(new List<SystemExecutedMasterClass.FlowInput>{ input });
        Test.stopTest();
        
        API_Callout_Audit__c updatedAudit = [SELECT API_Status__c FROM API_Callout_Audit__c WHERE Id = :acaRec.Id];
        //System.assertNotEquals(null, updatedAudit.API_Status__c, 'API status should be updated for GetPennyDropStatus');
    }
    
    @IsTest
    static void testAPIUpdateStatus() {
        createTestData();
        Task testTask = [SELECT Id FROM Task LIMIT 1];
        API_Callout_Audit__c acaRec = new API_Callout_Audit__c();
        insert acaRec;
        
        SystemExecutedMasterClass.FlowInput input = prepareFlowInput('API_updateStatus', acaRec.Id, testTask.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"status":"Success","RequestBody":"test","ResponseBody":"response"}', 200));
        
        Test.startTest();
        SystemExecutedMasterClass.processRecords(new List<SystemExecutedMasterClass.FlowInput>{ input });
        Test.stopTest();
        
        API_Callout_Audit__c updatedAudit = [SELECT API_Status__c FROM API_Callout_Audit__c WHERE Id = :acaRec.Id];
        //System.assertNotEquals(null, updatedAudit.API_Status__c, 'API status should be updated for UpdateStatus');
    }




   
}