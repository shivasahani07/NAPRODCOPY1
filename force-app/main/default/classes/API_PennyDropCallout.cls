global class API_PennyDropCallout {    
    
    public static HttpResponse penyDropVerify(penyDropDataInputWrapper requestWrapper) {
        string partnerCin;
        PartnerCin__mdt pertnerCin = PartnerCin__mdt.getInstance('pennyDropCin');
        if (pertnerCin != null) {
            partnerCin = pertnerCin.CIN_No__c;
        } else {
            // Handle the null case, maybe by logging an error or throwing a custom exception
            System.debug('No PartnerCin__mdt record found for DeveloperName "pennyDropCin".');
            
        }
        String endpoint =System.Label.FinancialEntityACDetails_PennyDropCallOutEndPoint+partnerCin;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        // Serialize the request body
        String requestBody = JSON.serialize(requestWrapper);
        request.setBody(requestBody);
        
        // Create a new HTTP object to send the request
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // Parse and process the response
        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            System.debug('Response: ' + responseBody);
            // Process the response as needed
        } else {
            System.debug('HTTP request failed with status code: ' + response.getStatusCode());
        }
        
        return response;
    }
    
    public static string processResponseData(string taskRecordId){
        auditwrapper auditwarp = new auditwrapper();
		task taskRec = new task();        
        string bankDetailsSFDXId;
        try{
			 taskRec = [Select id, Attribute1__c from Task Where Id= :taskRecordId];
        }catch(Exception e){
            
        }
        
        if (taskRec	 != null && taskRec.Attribute1__c !=null){
            bankDetailsSFDXId=taskRec.Attribute1__c;
        }
        penyDropDataInputWrapper requestInputs = prepareBankDetails(bankDetailsSFDXId);
        requestInputs.referenceId = bankDetailsSFDXId;
        requestInputs.paymentMode ='IMPS';
        System.debug('requestInputs---'+requestInputs);
        
        // Call penyDropVerify and capture the response
        HttpResponse response = penyDropVerify(requestInputs);
        auditwarp.RequestBody = JSON.serialize(requestInputs);
        // Handle the response here
        if (response.getStatusCode() == 200) {
            // Assuming SuccessResponse constructor takes a JSON string as an argument
            SuccessResponse successResponse = new SuccessResponse(string.valueof(response.getBody()));
            system.debug('successResponse---'+successResponse);
            try{
                Financial_Entity_AC_Detail__c updateBankDetailsStatus= new Financial_Entity_AC_Detail__c();
                updateBankDetailsStatus.Verification_Status__c=successResponse.status;
                updateBankDetailsStatus.id=bankDetailsSFDXId;
                updateBankDetailsStatus.BatchId__c=string.valueof(successResponse.batchId);
                //updateBankDetailsStatus.TransactionId__c=bankDetailsSFDXId;
                update updateBankDetailsStatus;
                auditwarp.ResponseBody =string.valueof(response.getBody());
                auditwarp.status = Label.AuditAPIStatus;
            }catch(Exception e){
                System.debug('Exception occurred: ' + e.getMessage());
                System.debug('Exception occurred at line Number: ' + e.getlineNumber());
                auditwarp.CallOutApiProcessResult= e.getMessage();
            }
            
        } else {
            ErrorResponse errorResponse = new ErrorResponse(string.valueof(response.getBody()));
            errorResponse.statusCode=response.getStatusCode();
            auditwarp.ResponseBody = response.getBody();
            auditwarp.status = Label.AuditAPIFailedStatus;
            system.debug('errorResponse---'+errorResponse);
        }
        
        return JSON.serialize(auditwarp);
    }
    
    
    
    public static penyDropDataInputWrapper prepareBankDetails(string bankDetailsSFDXId){
        
        penyDropDataInputWrapper contactInfoAndBackcDetails= new penyDropDataInputWrapper();
        bankAccountwrpper bankDetails = new bankAccountwrpper();
        contactwrapper contactInfo = new contactwrapper();
        List<Financial_Entity_AC_Detail__c> bankDetailsList = [SELECT  Id,name,Bank_Name__c,Branch_Name__c,Financial_Entity__r.Account_Name__r.Name,
                                                               Financial_Entity__r.Account_Name__r.Email_Id__c,Financial_Entity__r.Account_Name__r.BillingAddress,
                                                               IFSC_Code__c,Digitally_Verification_Method__c,Task_ID__c,Banking_Account_Name__c,Financial_Entity__c,Bank_Account_Number__c
                                                               FROM Financial_Entity_AC_Detail__c where id=:bankDetailsSFDXId limit 1];
        if (!bankDetailsList.isEmpty()) {
            Financial_Entity_AC_Detail__c bankdetailss = bankDetailsList[0];
            system.debug('bankdetailss::'+bankdetailss);
            bankDetails.accountNo=string.valueOf(bankdetailss.Bank_Account_Number__c);
            bankDetails.ifscCode=bankdetailss.IFSC_Code__c;
            bankDetails.bankName=bankdetailss.Bank_Name__c;
            bankDetails.branchName=bankdetailss.Branch_Name__c;
            bankDetails.vpa='';
            if(bankdetailss.Financial_Entity__r.Account_Name__r.BillingAddress != null){
                contactInfo.address=string.valueof(bankdetailss.Financial_Entity__r.Account_Name__r.BillingAddress);
            }
            
            contactInfo.customerName=bankdetailss.Financial_Entity__r.Account_Name__r.Name;
            contactInfo.email=bankdetailss.Financial_Entity__r.Account_Name__r.Email_Id__c;
            contactInfoAndBackcDetails.bankAccount=bankDetails;
            contactInfoAndBackcDetails.contact=contactInfo;
            
        } else {
            // Handle the case where no details are found, maybe initialize default values or throw a custom exception
            system.debug('No bank details found for ID: ' + bankDetailsSFDXId);
        }            
        return contactInfoAndBackcDetails;
    }
    
    
    //API REQUEST RELATED WRAPPER
    public class penyDropDataInputWrapper  {
        public string referenceId;
        public string referenceId2;
        public string paymentMode;
        public bankAccountwrpper bankAccount;
        public contactwrapper contact;
        
    }
    
    public class bankAccountwrpper{
        public string accountNo;
        public string ifscCode;
        public string bankName;
        public string branchName;
        public string vpa;
        
    }
    public class contactwrapper{
        public string customerName;
        public string address;
        public string email;
    }
    
    Public class auditwrapper{
        Public String status;
        public String ResponseBody;
        public string RequestBody; 
        public string CallOutApiProcessResult;
    }
    
    
    
    
    // api response related wrapper
    public class SuccessResponse {
        public Integer batchId;
        public Integer requestCount;
        public Integer processedCount;
        public String status;
        public string statusCode;
        
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
        public integer statusCode;
        public List<ErrorDetail> errors;
        public ErrorResponse(String responseBody) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            this.status = (String) responseMap.get('status');
            this.timestamp=(dateTime)responseMap.get('timestamp');
            this.reason=(String) responseMap.get('reason');
            // Parse other fields as needed
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