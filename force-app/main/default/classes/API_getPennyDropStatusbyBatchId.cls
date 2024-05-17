public class API_getPennyDropStatusbyBatchId {
    
    public static HttpResponse getPeenyDropStatus(string BatchId){
        // Specify the URL with the query parameter
        String url =System.Label.FinancialEntityACDetails_getPennyDropStatusbyBatchIdEndPoint+BatchId;
        
        // Create an HTTP request object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse response;
        TransactionWrapperResponse wrapperResponse = new TransactionWrapperResponse();
        try {
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
        }
        return response;
    }
    
    public static string processRequestdata(string taskRecordId){
        auditwrapper auditwarp = new auditwrapper();
        TransactionWrapperResponse wrapperResponse = new TransactionWrapperResponse();
        string bankDetailsSFDXId;
        HttpResponse response;
        
        // Use list to retrieve records safely
        List<Task> taskRecs = [Select id, Attribute1__c from Task Where Id = :taskRecordId];
        if (!taskRecs.isEmpty() && taskRecs[0].Attribute1__c != null) {
            bankDetailsSFDXId = taskRecs[0].Attribute1__c;
            System.debug('bankDetailsSFDXId::' + bankDetailsSFDXId);
            
            List<Financial_Entity_AC_Detail__c> backDetailsList = [SELECT id, Name, Verification_Status__c, TransactionId__c, BatchId__c FROM Financial_Entity_AC_Detail__c WHERE Id = :bankDetailsSFDXId];
            if (!backDetailsList.isEmpty()) {
                Financial_Entity_AC_Detail__c backDetails = backDetailsList[0];
                System.debug('backDetails::' + backDetails);
                response = getPeenyDropStatus(backDetails.BatchId__c);
                if (response != null && response.getStatusCode() == 200) {
                    wrapperResponse = (TransactionWrapperResponse) JSON.deserialize(response.getBody(), TransactionWrapperResponse.class);
                    try {
                        Financial_Entity_AC_Detail__c updateBankDetailsStatus = new Financial_Entity_AC_Detail__c();
                        updateBankDetailsStatus.Verification_Status__c = wrapperResponse.status;
                        updateBankDetailsStatus.id = bankDetailsSFDXId;
                        updateBankDetailsStatus.TransactionId__c = wrapperResponse.transactionId;
                        update updateBankDetailsStatus;
                        auditwarp.ResponseBody = string.valueOf(response.getBody());
                        auditwarp.status = Label.AuditAPIStatus;
                    } catch(Exception e) {
                        System.debug('Exception occurred: ' + e.getMessage());
                        System.debug('Exception occurred at line Number: ' + e.getLineNumber());
                        auditwarp.CallOutApiProcessResult = e.getMessage();
                    }
                } else {
                    // Handle error response
                    System.debug('Error Response: ' + response.getBody());
                    auditwarp.ResponseBody = response.getBody();
                    auditwarp.status = Label.AuditAPIFailedStatus;
                }
            } else {
                System.debug('No Financial_Entity_AC_Detail__c found for ID: ' + bankDetailsSFDXId);
            }
        } else {
            System.debug('No Task record found or Attribute1__c is null for TaskId: ' + taskRecordId);
        }
        return JSON.serialize(auditwarp);
    }

    
    
    Public class auditwrapper{
        Public String status;
        public String ResponseBody;
        public string RequestBody; 
        public string CallOutApiProcessResult;
    }
    
    public class TransactionWrapperResponse {        
        public Long batchId;
        public String externalRefId;
        public String customerId;
        public String transactionId;
        public String status;
        public String errorCode;
        public String errorDesc;
        public String transactionType;
        public String paymentMode;
        public Decimal pennydrop;
        public TransactionInfo transactionInfo;
        public String vendor;
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