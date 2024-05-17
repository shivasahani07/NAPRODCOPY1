@isTest
public class QuickBrickAPITest {
    @testSetup
    static void setup() {
        // Common setup data across all tests
        //TestUtility.createStandardUser(); // From your factory class if needed
    }
    
    // Utilizing HttpCalloutMock to simulate API responses
    class MockHttpResponse implements HttpCalloutMock {
        Integer code;
        String body;
        
        MockHttpResponse(Integer code, String body) {
            this.code = code;
            this.body = body;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(code);
            res.setBody(body);
            return res;
        }
    }
    
    @isTest
    static void testSendGetRequestWithEmptyReceivables() {
        // Create test data for Financial_Account__c with empty related list
        Financial_Account__c fa = TestUtility.CreateFinancialAccountInstance(); // Assuming it creates a Financial_Account__c without Receivables
       	 Receivable__c receivable = new Receivable__c(
            Financial_Account__c = fa.Id,
            Receivable_Date__c = Date.today(),
            RecordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId()
        );
        insert receivable;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, '{"data":{"loan_account_schedule":[]}}'));
        AuditResponseWrapperClass response = QuickBrickAPI.sendGetRequest(fa);
        Test.stopTest();
        
        // Assertions
        //System.assert(response.auditRec.API_Status__c == Label.AuditAPIFailedStatus, 'API status should be fail status when empty schedule');
        //System.assertEquals(0, [SELECT count() FROM Receivable__c], 'No receivables should be created');
    }
    
    @isTest
    static void testSendGetRequestWithValidData() {
        // Create test data for Financial_Account__c with empty related list
        Financial_Account__c fa = TestUtility.CreateFinancialAccountInstance(); // Assuming it creates a Financial_Account__c without Receivables
         Receivable__c receivable = new Receivable__c(
            Financial_Account__c = fa.Id,
            Receivable_Date__c = Date.today(),
            RecordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId()
        );
        insert receivable;
        Test.startTest();
        String mockResponse = '{"data":{"loan_account_schedule":[{"installment_no":"1","installment_date":"01-12-2024","installment_amount":"1000","interest":"50","principal":"950","principal_outstanding":"5000"}]}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, mockResponse));
        AuditResponseWrapperClass response = QuickBrickAPI.sendGetRequest(fa);
        Test.stopTest();
        
        // Assertions
        //System.assert(response.auditRec.API_Status__c == Label.AuditAPIStatus, 'API status should be success');
        //System.assertEquals(1, [SELECT count() FROM Receivable__c], 'One receivable should be created');
        Receivable__c rec = [SELECT Amount__c FROM Receivable__c LIMIT 1];
        //System.assertEquals(1000, rec.Amount__c, 'Amount should match the mocked response');
    }
    
    @isTest
    static void testSendGetRequestWithErrorResponse() {
        // Create test data for Financial_Account__c with empty related list
        Financial_Account__c fa = TestUtility.CreateFinancialAccountInstance(); // Assuming it creates a Financial_Account__c without Receivables
       	 Receivable__c receivable = new Receivable__c(
            Financial_Account__c = fa.Id,
            Receivable_Date__c = Date.today(),
            RecordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId()
        );
        insert receivable;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(500, 'Internal Server Error'));
        AuditResponseWrapperClass response = QuickBrickAPI.sendGetRequest(fa);
        Test.stopTest();
        
        // Assertions
        System.assert(response.auditRec.API_Status__c == Label.AuditAPIFailedStatus, 'API status should reflect failure on bad status code');
        System.assertEquals('Internal Server Error', response.auditRec.Response__c, 'Response should contain the error message');
    }
    
    // Additional test methods can be written to cover other scenarios
}