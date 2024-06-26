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
        
        API_Callout_Audit__c acaRec = new API_Callout_Audit__c();
        insert acaRec;
        
        SystemExecutedMasterClass.FlowInput input = prepareFlowInput('API_PennyDropCallout', acaRec.Id, taskRec.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"status":"Verified","RequestBody":"test","ResponseBody":"response"}', 200));
        
        Test.startTest();
        SystemExecutedMasterClass.processRecords(new List<SystemExecutedMasterClass.FlowInput>{ input });
        Test.stopTest();
        
        API_Callout_Audit__c updatedAudit = [SELECT API_Status__c FROM API_Callout_Audit__c WHERE Id = :acaRec.Id];
        //System.assertNotEquals(null, updatedAudit.API_Status__c, 'API status should be updated for PennyDropCallout');
    }
    
    @IsTest
    static void testAPIGetPennyDropStatusbyBatchId() {
        createTestData();
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
        
        API_Callout_Audit__c acaRec = new API_Callout_Audit__c();
        insert acaRec;
        
        
        SystemExecutedMasterClass.FlowInput input = prepareFlowInput('API_getPennyDropStatusbyBatchId', acaRec.Id, taskRec.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"status":"Verified","RequestBody":"test","ResponseBody":"response"}', 200));
        
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