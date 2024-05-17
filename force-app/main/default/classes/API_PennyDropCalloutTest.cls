@isTest
public class API_PennyDropCalloutTest {

    // Utility method to simulate HTTP response
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
    
    
	@isTest
    public static void testApiUpdateStatus(){
        Account testAccount = TestUtility.createTestAccount();
        //insert testAccount;
        Opportunity testOpportunity = TestUtility.createTestOpportunity(testAccount.Id);
        insert testOpportunity;
        
        Financial_Account__c faAccount = new Financial_Account__c();
        faAccount.Account_Name__c = testAccount.Id;
        faAccount.Amount__c = 5000;
        faAccount.EMI_Amount__c = 300;
        faAccount.First_EMI_Date__c = system.today();
        faAccount.Opportunity__c = testOpportunity.Id;
        insert faAccount;
        Financial_Entity__c FinancialEntity = new Financial_Entity__c();
        
        FinancialEntity.Financial_Account__c =faAccount.Id;
        FinancialEntity.Account_Name__c = testAccount.Id;
        insert FinancialEntity;
        
        Financial_Entity_AC_Detail__c feac = new Financial_Entity_AC_Detail__c();
        feac.Bank_Account_Number__c = 'Test Bank Account';
        feac.Bank_Account_Type__c = 'Savings';
        feac.Bank_Name__c = 'Axis Bank';
        feac.Branch_Name__c = 'Kormanagala';
        feac.Banking_Account_Name__c = 'Test Banking Name';
        feac.Financial_Account__c = faAccount.Id;
        feac.Financial_Entity__c = FinancialEntity.Id;
        feac.IFSC_Code__c = 'test IFSC';
        insert  feac;
        
        Task taskRec= new Task();
        taskRec.WhatId = testOpportunity.Id;
        taskRec.Attribute1__c = feac.Id;
        insert taskRec;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"message": "success",  "status": "Verified"}'));
        
        
        API_PennyDropCallout.processResponseData(taskRec.Id);
        Test.stopTest();
    }
}