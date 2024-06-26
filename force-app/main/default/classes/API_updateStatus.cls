global class API_updateStatus {
    
    // Method to update status by transaction ID
    public static HttpResponse updateStatusByTransactionId(String transactionId) {
        // Construct the URL with the transaction ID
        PartnerCin__mdt partnerCinRecord = PartnerCin__mdt.getInstance('updateStatus');
        String API_KEY = partnerCinRecord.apiKey__c;
        String GROUP_KEY = partnerCinRecord.groupKey__c;
        String url =  partnerCinRecord.endPoint__c+ transactionId;
        // Create an HTTP request object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setHeader('Accept', '*/*');
        request.setHeader('API-KEY', API_KEY);
        request.setHeader('GROUP-KEY', GROUP_KEY);
        request.setHeader('Content-Type', 'application/json');
        system.debug('request---'+request);
        
        Http http = new Http();
        HttpResponse response;
        try {
            // Send the HTTP request and get the response
            response = http.send(request);
            // Check if the request was successful
            if (response.getStatusCode() == 200) {
                System.debug('Response Body: ' + response.getBody());
            } else {
                // Handle error response
                System.debug('Error Response: ' + response.getBody());
            }
        } catch (Exception e) {
            // Handle exception
            System.debug('Exception: ' + e.getMessage());
            response = null; // Ensure response is null in case of an exception
        }
        return response;
    }
    
    // Method to process the request data
    public static String processRequestData(String taskRecordId) {
        auditwrapper auditWarp = new auditwrapper();
        PeenyDropStatusWrapper wrapperResponse = new PeenyDropStatusWrapper();
        String bankDetailsSFDXId;
        HttpResponse response;
        
        Task taskRec = [SELECT Id, Attribute1__c FROM Task WHERE Id = :taskRecordId];
        if (taskRec != null && taskRec.Attribute1__c != null) {
            bankDetailsSFDXId = taskRec.Attribute1__c;
            Financial_Entity_AC_Detail__c backDetails = [SELECT Id, Name, Verification_Status__c, TransactionId__c, BatchId__c FROM Financial_Entity_AC_Detail__c WHERE Id = :bankDetailsSFDXId];
            
            response = updateStatusByTransactionId(backDetails.TransactionId__c);
            System.debug('response::: ' + response);
            if (response == null) {
                auditWarp.status = Label.AuditAPIFailedStatus;
                System.debug('auditWarp - Batch ID: ' + auditWarp);
            } else {
                if (response.getStatusCode() == 200) {
                    wrapperResponse = (PeenyDropStatusWrapper) JSON.deserialize(response.getBody(), PeenyDropStatusWrapper.class);
                    try {
                        Financial_Entity_AC_Detail__c updateBankDetailsStatus = new Financial_Entity_AC_Detail__c();
                        // Updating bank details status
                        updateBankDetailsStatus.Verification_Status__c = wrapperResponse.status;
                        updateBankDetailsStatus.Id = bankDetailsSFDXId;
                        update updateBankDetailsStatus;
                        
                        auditWarp.ResponseBody = String.valueOf(response.getBody());
                        auditWarp.status = Label.AuditAPIStatus;
                    } catch (Exception e) {
                        System.debug('Exception occurred: ' + e.getMessage());
                        System.debug('Exception occurred at line Number: ' + e.getLineNumber());
                        auditWarp.processingDMLData = e.getMessage();
                        auditWarp.status = Label.AuditAPIFailedStatus;
                    }
                } else {
                    // Handle error response
                    System.debug('Error Response: ' + response.getBody());
                    auditWarp.ResponseBody = response.getBody();
                    auditWarp.status = Label.AuditAPIFailedStatus;
                }
            }
        } else {
            auditWarp.ResponseBody = 'Invalid task record or missing Attribute1__c';
            auditWarp.status = Label.AuditAPIFailedStatus;
        }
        
        return JSON.serialize(auditWarp);
    }
    
    // Wrapper class for audit information
    public class auditwrapper {
        public String status;
        public String ResponseBody;
        public String RequestBody; 
        public String processingDMLData;
    }
    
    // Wrapper class for the penny drop status response
    public class PeenyDropStatusWrapper {
        public String status;
        public String timestamp;
        public String message;
        public List<String> errors;
    }
    
    public class PennyDropResponseWrapper {
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
        
    }
    public class Pennydrop {
        public String customerName;
        public String givenNameInBank;
        public String pennyDropStatus;
        public Datetime validatedOn;
        public Boolean isEligibleForPayout;
    }
    
    public class TransactionInfo {
        public Decimal amount;
        public String fromAccount;
        public String cmsRefNo;
        public String coreRefNo;
        public Long transactionInitiatedOn;
        public String transactionStatus;
    }
    
    
}