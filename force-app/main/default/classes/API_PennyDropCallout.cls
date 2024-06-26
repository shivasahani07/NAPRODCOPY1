global class API_PennyDropCallout {

    public static HttpResponse penyDropVerify(penyDropDataInputWrapper requestWrapper) {
        try {
            // Fetching metadata records
            PartnerCin__mdt partnerCinRecord = PartnerCin__mdt.getInstance('doPennyDrop');
            String partnerCin = partnerCinRecord.CIN_No__c;
            String API_KEY = partnerCinRecord.apiKey__c;
            String GROUP_KEY = partnerCinRecord.groupKey__c;
            String endpoint = partnerCinRecord.endPoint__c;
            // Setting up HTTP request
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', '*/*');
            request.setHeader('API-KEY', API_KEY);
            request.setHeader('GROUP-KEY', GROUP_KEY);
            String requestBody = JSON.serialize(requestWrapper);
            request.setBody(requestBody);
            
            // Sending HTTP request
            Http http = new Http();
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                System.debug('Response: ' + responseBody);
                // Process the response as needed
            } else {
                System.debug('HTTP request failed with status code: ' + response.getStatusCode());
            }
            System.debug('Response in penyDropVerify: ' + response);
            return response;
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e);
            return null;
        }
    }

    public static String processResponseData(String taskRecordId) {
        auditwrapper auditWrapper = new auditwrapper();
        String bankDetailsSFDXId;
        Task taskRec = [SELECT Id, Attribute1__c FROM Task WHERE Id = :taskRecordId];
        if (taskRec != null && taskRec.Attribute1__c != null) {
            bankDetailsSFDXId = taskRec.Attribute1__c;
        }
        penyDropDataInputWrapper requestInputs = prepareBankDetails(bankDetailsSFDXId);
        requestInputs.referenceId = bankDetailsSFDXId;
        requestInputs.paymentMode = 'IMPS';
        System.debug('Request Inputs: ' + requestInputs);

        HttpResponse response = penyDropVerify(requestInputs);
        System.debug('Response: ' + response);
        auditWrapper.RequestBody = JSON.serialize(requestInputs);

        if (response == null) {
            handleErrorResponse(bankDetailsSFDXId, 'No Response', auditWrapper, taskRecordId);
        } else if (response.getStatusCode() == 200) {
            processSuccessResponse(response, bankDetailsSFDXId, auditWrapper, taskRecordId);
        } else if (response.getStatusCode() == 502) {
            logError502('502 Bad Gateway: Invalid response from the upstream server.', auditWrapper, response);
            handleErrorResponse(bankDetailsSFDXId, 'Failed', auditWrapper, taskRecordId);
        } else {
            handleErrorResponse(bankDetailsSFDXId, response.getBody(), auditWrapper, taskRecordId);
        }
        System.debug('Audit Wrapper: ' + auditWrapper);
        return JSON.serialize(auditWrapper);
    }

    private static void handleErrorResponse(String bankDetailsSFDXId, String responseBody, auditwrapper auditWrapper, String taskRecordId) {
        updateBankDetailsStatus(bankDetailsSFDXId, 'Failed',auditWrapper);
        logErrorResponse(null, auditWrapper, responseBody, taskRecordId);
    }

    private static void updateBankDetailsStatus(String bankDetailsSFDXId, String status,auditwrapper auditWrapper) {
        Financial_Entity_AC_Detail__c FEACDetails = [SELECT Id, Name, Verification_Status__c, Physically_verified__c FROM Financial_Entity_AC_Detail__c WHERE Id = :bankDetailsSFDXId];
        Financial_Entity_AC_Detail__c updateBankDetailsStatus = new Financial_Entity_AC_Detail__c();
        if (status.contains('Fail') && !FEACDetails.Physically_verified__c) {
            updateBankDetailsStatus.Verification_Status__c = status;
        } else if (!status.contains('Fail')) {
            updateBankDetailsStatus.Verification_Status__c = status;
            updateBankDetailsStatus.Digitally_Verified__c = true;
        }
        updateBankDetailsStatus.Id = bankDetailsSFDXId;
        update updateBankDetailsStatus;
        auditWrapper.processingDMLData =JSON.serialize(updateBankDetailsStatus);
    }

    private static void logErrorResponse(HttpResponse response, auditwrapper auditWrapper, String responseBody, String taskRecordId) {
        ErrorResponse errorResponse;
        if (response != null) {
            errorResponse = new ErrorResponse(responseBody);
            errorResponse.statusCode = response.getStatusCode();
        } else {
            errorResponse = new ErrorResponse();
            errorResponse.status = 'Failed';
            errorResponse.message = responseBody;
        }
        auditWrapper.ResponseBody = responseBody;
        auditWrapper.status = Label.AuditAPIFailedStatus;
    }

    private static void logError502(String errorMessage, auditwrapper auditWrapper, HttpResponse response) {
        System.debug('Error Message: ' + errorMessage);
        auditWrapper.ResponseBody = 'Status: ' + response.getStatus() + ', StatusCode: ' + response.getStatusCode() +'Body:'+ response.getBody();
        auditWrapper.status = Label.AuditAPIFailedStatus;
        if (response != null) {
            System.debug('Response at error 502: ' + response.getBody());
        }
    }

    private static void processSuccessResponse(HttpResponse response, String bankDetailsSFDXId, auditwrapper auditWrapper, String taskRecordId) {
        try {
            SuccessResponse successResponse = new SuccessResponse(response.getBody());
            updateBankDetailsStatus(bankDetailsSFDXId, successResponse.status,auditWrapper);
            Financial_Entity_AC_Detail__c updateBankDetailsStatus = new Financial_Entity_AC_Detail__c();
            updateBankDetailsStatus.BatchId__c = String.valueOf(successResponse.batchId);
            update updateBankDetailsStatus;
            auditWrapper.ResponseBody = response.getBody();
            auditWrapper.status = Label.AuditAPIStatus;
        } catch (Exception e) {
            auditWrapper.processingDMLData = e.getMessage();
            auditWrapper.status = Label.AuditAPIFailedStatus;
        }
    }

    public static penyDropDataInputWrapper prepareBankDetails(String bankDetailsSFDXId) {
        system.debug('bankDetailsSFDXId:::'+bankDetailsSFDXId);
        penyDropDataInputWrapper contactInfoAndBackcDetails = new penyDropDataInputWrapper();
        bankAccountwrpper bankDetails = new bankAccountwrpper();
        contactwrapper contactInfo = new contactwrapper();
        Financial_Entity_AC_Detail__c bankdetailss = [SELECT Id, Name, Bank_Name__c, Branch_Name__c, Financial_Entity__r.Account_Name__r.Name,
                                                      Financial_Entity__r.Account_Name__r.Email_Id__c, Financial_Entity__r.Account_Name__r.BillingAddress,
                                                      IFSC_Code__c, Digitally_Verification_Method__c, Task_ID__c, Banking_Account_Name__c, Financial_Entity__c, Bank_Account_Number__c
                                                      FROM Financial_Entity_AC_Detail__c WHERE Id = :bankDetailsSFDXId LIMIT 1];
        bankDetails.accountNo = String.valueOf(bankdetailss.Bank_Account_Number__c);
        bankDetails.ifscCode = bankdetailss.IFSC_Code__c;
        bankDetails.bankName = bankdetailss.Bank_Name__c;
        bankDetails.branchName = bankdetailss.Branch_Name__c;
        bankDetails.vpa = '';
        contactInfo.address = String.valueOf(bankdetailss.Financial_Entity__r.Account_Name__r.BillingAddress);
        contactInfo.customerName = bankdetailss.Financial_Entity__r.Account_Name__r.Name;
        contactInfo.email = bankdetailss.Financial_Entity__r.Account_Name__r.Email_Id__c;
        contactInfoAndBackcDetails.bankAccount = bankDetails;
        contactInfoAndBackcDetails.contact = contactInfo;
        return contactInfoAndBackcDetails;
    }

    public class penyDropDataInputWrapper {
        public String referenceId;
        public String referenceId2;
        public String paymentMode;
        public bankAccountwrpper bankAccount;
        public contactwrapper contact;
    }

    public class bankAccountwrpper {
        public String accountNo;
        public String ifscCode;
        public String bankName;
        public String branchName;
        public String vpa;
    }

    public class contactwrapper {
        public String customerName;
        public String address;
        public String email;
    }

    public class auditwrapper {
        public String status;
        public String ResponseBody;
        public String RequestBody;
        public String processingDMLData;
    }

    public class SuccessResponse {
        public Integer batchId;
        public Integer requestCount;
        public Integer processedCount;
        public String status;
        public String statusCode;

        public SuccessResponse(String responseBody) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            this.batchId = (Integer) responseMap.get('batchId');
            this.requestCount = (Integer) responseMap.get('requestCount');
            this.processedCount = (Integer) responseMap.get('processedCount');
            this.status = (String) responseMap.get('status');
        }
    }

    public class ErrorResponse {
        public String status;
        public Datetime timestamp;
        public String reason;
        public String message;
        public Integer statusCode;
        public List<ErrorDetail> errors;

        public ErrorResponse() {}
        public ErrorResponse(String responseBody) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            this.status = (String) responseMap.get('status');
            this.timestamp = (DateTime) responseMap.get('timestamp');
            this.reason = (String) responseMap.get('reason');
            this.message = (String) responseMap.get('message');
        }
    }

    public class ErrorDetail {
        public String id;
        public String field;
        public String rejectedValue;
        public String message;

        public ErrorDetail(String id, String field, String rejectedValue, String message) {
            this.id = id;
            this.field = field;
            this.rejectedValue = rejectedValue;
            this.message = message;
        }
    }
}