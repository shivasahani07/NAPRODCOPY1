global class API_getPennyDropStatusbyBatchId {
    
    // Method to get the penny drop status by batch ID
    public static HttpResponse getPennyDropStatus(String batchId) {
        // Retrieve the partner CIN record and necessary values
        PartnerCin__mdt partnerCinRecord = PartnerCin__mdt.getInstance('getStatusByBatchId');
        String API_KEY = partnerCinRecord.apiKey__c;
        String GROUP_KEY = partnerCinRecord.groupKey__c;
        String endpoint = partnerCinRecord.endPoint__c;
        
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('API-KEY', API_KEY);
            request.setHeader('GROUP-KEY', GROUP_KEY);
            system.debug('request---'+request);
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                System.debug('Response: ' + responseBody);
            } else {
                System.debug('HTTP request failed with status code: ' + response.getStatusCode());
            }
            
            System.debug('Response in getPennyDropStatus: ' + response);
            return response;
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e);
            HttpResponse errorResponse = new HttpResponse();
            errorResponse.setStatusCode(500); // Internal Server Error
            return errorResponse;
        }
    }
    
    
    // Method to process the request data
    public static String processRequestData(String taskRecordId) {
        auditwrapper auditWrapper = new auditwrapper();
        TransactionWrapperResponse wrapperResponse;
        String bankDetailsSFDXId;
        HttpResponse response;
        
        Task taskRec = [SELECT Id, Attribute1__c FROM Task WHERE Id = :taskRecordId];
        if (taskRec != null && taskRec.Attribute1__c != null) {
            bankDetailsSFDXId = taskRec.Attribute1__c;
            System.debug('bankDetailsSFDXId: ' + bankDetailsSFDXId);
            
            Financial_Entity_AC_Detail__c backDetails = [SELECT Id, Name, Verification_Status__c, TransactionId__c, BatchId__c FROM Financial_Entity_AC_Detail__c WHERE Id = :bankDetailsSFDXId];
            System.debug('backDetails: ' + backDetails);
            
            response = getPennyDropStatus(backDetails.BatchId__c);
            System.debug('response::: ' + response);
            if (response != null) {
                if (response.getStatusCode() == 200) {
                    wrapperResponse = (TransactionWrapperResponse) JSON.deserialize(response.getBody(), TransactionWrapperResponse.class);
                    try {
                        Financial_Entity_AC_Detail__c updateBankDetailsStatus = new Financial_Entity_AC_Detail__c();
                        // Updating bank details status
                        updateBankDetailsStatus.Verification_Status__c = wrapperResponse.status;
                        updateBankDetailsStatus.Id = bankDetailsSFDXId;
                        updateBankDetailsStatus.TransactionId__c = wrapperResponse.transactionId;
                        update updateBankDetailsStatus;
                        
                        auditWrapper.ResponseBody = String.valueOf(response.getBody());
                        auditWrapper.status = Label.AuditAPIStatus;
                    } catch (Exception e) {
                        System.debug('Exception occurred: ' + e.getMessage());
                        System.debug('Exception occurred at line Number: ' + e.getLineNumber());
                        auditWrapper.processingDMLData = e.getMessage();
                        auditWrapper.status = Label.AuditAPIFailedStatus; 
                    }
                } else if (response.getStatusCode() == 502) {
                    logError502('502 Bad Gateway: Invalid response from the upstream server.', auditWrapper, response);
                } else {
                    // Handle other error response
                    String errorBody = response.getBody();
                    System.debug('Error Response: ' + errorBody);
                    auditWrapper.ResponseBody = errorBody;
                    auditWrapper.status = Label.AuditAPIFailedStatus;
                }
            } else {
                auditWrapper.ResponseBody = 'No Response';
                auditWrapper.status = Label.AuditAPIFailedStatus;
            }
        } else {
            auditWrapper.ResponseBody = 'Invalid task record or missing Attribute1__c';
            auditWrapper.status = Label.AuditAPIFailedStatus;
        }
        system.debug('auditWrapper---'+auditWrapper);
        return JSON.serialize(auditWrapper);
    }
    
    private static void logError502(String errorMessage, auditwrapper auditWrapper, HttpResponse response) {
        System.debug('Error Message: ' + errorMessage);
        auditWrapper.ResponseBody = 'Status: ' + response.getStatus() + ', StatusCode: ' + response.getStatusCode();
        auditWrapper.status = Label.AuditAPIFailedStatus;
        if (response != null) {
            System.debug('Response at error 502: ' + response.getBody());
        }
    }
    
    // Wrapper class for audit information
    public class auditwrapper {
        public String status;
        public String ResponseBody;
        public String RequestBody; 
        public String processingDMLData;
    }
    
    // Wrapper class for the transaction response
    public class TransactionWrapperResponse {        
        public String batchId;
        public String externalRefId;
        public String customerId;
        public String transactionId;
        public String status;
        public String errorCode;
        public String errorDesc;
        public String transactionType;
        public String paymentMode;
        public Pennydrop pennyDrop;
        public TransactionInfo transactionInfo;
        public String vendor;
    }
    
    // Wrapper class for penny drop information
    public class Pennydrop {
        public String customerName;
        public String givenNameInBank;
        public String pennyDropStatus;
        public Datetime validatedOn;
        public Boolean isEligibleForPayout;
    }
    
    // Wrapper class for transaction information
    public class TransactionInfo {
        public Decimal amount;
        public String fromAccount;
        public String cmsRefNo;
        public String coreRefNo;
        public Long transactionInitiatedOn;
        public String transactionStatus;
    }
}