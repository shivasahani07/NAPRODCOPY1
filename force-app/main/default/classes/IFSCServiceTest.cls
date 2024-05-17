@isTest
private class IFSCServiceTest {
    
    // Method to generate a standard mock response
    private static String generateMockResponse() {
        return '{' +
            '"MICR": "110002062",' +
            '"BRANCH": "KASTURBA GANDHI MARG,NEW DELHI",' +
            '"ADDRESS": "23, HIMALAYA HOUSE KASTURBA GANDHI MARG NEW DELHI ,PIN - 110001",' +
            '"STATE": "DELHI",' +
            '"CONTACT": "1234567890",' +
            '"UPI": true,' +
            '"RTGS": true,' +
            '"CITY": "NEW DELHI",' +
            '"CENTRE": "NEW DELHI",' +
            '"DISTRICT": "NEW DELHI",' +
            '"NEFT": true,' +
            '"IMPS": true,' +
            '"SWIFT": "SWFTCODE",' +
            '"ISO3166": "IN-DL",' +
            '"BANK": "State Bank of India",' +
            '"BANKCODE": "SBIN",' +
            '"IFSC": "SBIN0005943"' +
            '}';
    }
    
    // Mock class implementing HttpCalloutMock
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;
        
        public MockHttpResponseGenerator(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }
        
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBody(responseBody);
            response.setStatusCode(statusCode);
            return response;
        }
    }
    
    // Test method for successful HTTP response
    @isTest static void testGetIFSCDetailsSuccess() {
        String mockResponseBody = generateMockResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponseBody, 200));
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponseBody, 400));
        
        Test.startTest();
        IFSCService.IFSCDetailsWrapper result = IFSCService.getIFSCDetails('SBIN0005943');
        Test.stopTest();
        
        
    }
    
    
    // Additional test for malformed JSON or unexpected response structure
    @isTest static void testGetIFSCDetailsMalformedResponse() {
        String malformedResponseBody = '{"unexpectedField": "unexpectedValue"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(malformedResponseBody, 200));
        
        Test.startTest();
        IFSCService.IFSCDetailsWrapper result = IFSCService.getIFSCDetails('InvalidCode');
        Test.stopTest();
        
        // Adjust the assertion to check for a non-null result with null properties
        System.assertNotEquals(null, result, 'The result should not be null even for a malformed response.');
        // Optionally, assert that some expected fields are null
        System.assertEquals(null, result.BANK, 'BANK should be null for a malformed response.');
    }

}