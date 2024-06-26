public class API_CreatePartnerAPI {
    
    // Method to create a partner using the provided API endpoint and data
    public static String createPartner(Id taskRecordId) {

        auditwrapper auditwarp = new auditwrapper();
        try {
        // getting all thease details from custom metadata records.
        NUScoreCreds__mdt webCreds = NUScoreCreds__mdt.getInstance('createPartner');
        system.debug('webCreds--->'+webCreds);
        String endpoint =webCreds.endpoint__c;
        system.debug('endpoint--->'+endpoint);
        String apiKey =webCreds.apiKey__c;
        String groupKey =webCreds.groupKey__c;
        
        String jsonBody=generateJSONBody(taskRecordId);
        auditwarp.RequestBody = jsonBody;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('API-KEY', apiKey);
        request.setHeader('GROUP-KEY', groupKey);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);

        System.debug('request =====> '+ request);
        
        // Send the request
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // Parse and handle the response
        if (response.getStatusCode() == 200) {
            System.debug('Partner created successfully.');
            String responseBody = response.getBody();
            // Parse the JSON response body as needed
            System.debug('Response body: ' + responseBody);
            auditwarp.ResponseBody = responseBody;
            auditwarp.status = Label.AuditAPIStatus;
            //auditResult = Label.AuditAPIStatus;
        } else {
            auditwarp.ResponseBody = response.getBody();
            auditwarp.status = Label.AuditAPIFailedStatus;
            System.debug('Failed to create partner. Status code: ' + response.getStatusCode());
        }
            
        } catch (Exception e) {
            auditwarp.ResponseBody = null;
            auditwarp.status = Label.AuditAPIFailedStatus;
        }
        return JSON.serialize(auditwarp);
       
    }


    Public static String generateJSONBody(string TaskId){

        createPartnerWrapper createPartnerWrap = new createPartnerWrapper();
        partnerEmail PartnerEmailWrap = new partnerEmail();
        List<String> emailliststring = new List<String>();
        Account accRec = New Account();
        Task TaskRec = new Task();

        if(TaskId != null){
            TaskRec = [Select Id, whatId from task Where Id =:TaskId];
            if (TaskRec.whatId != null && String.valueOf(TaskRec.whatId).startsWith('001')) {
                accRec = [Select Id, External_ID__c, CustomerID__c, Short_Key__c,phone, CIN_No__c, Name, email_Id__c from Account where Id =: TaskRec.whatId];
                if (accRec != null) {
                    createPartnerWrap.cin = accRec.CIN_No__c;
                    createPartnerWrap.partnerId = accRec.CustomerID__c;
                    createPartnerWrap.partnerName = accRec.Name;
                    createPartnerWrap.phoneNumber = accRec.Phone;
                    createPartnerWrap.shortName = accRec.Short_Key__c;
                    emailliststring.add(accRec.Email_Id__c);
                    PartnerEmailWrap.to = emailliststring;
                    createPartnerWrap.partnerEmail = PartnerEmailWrap;
                }
                
            }
            
        }
        return JSON.serialize(createPartnerWrap);

    }

    Public class auditwrapper{
        Public String status;
        public String ResponseBody;
        public string RequestBody;
        public string processingDMLData;

    }

    public class createPartnerWrapper {

        public String partnerId;
        public String partnerName;
        public PartnerEmail partnerEmail;
        public String phoneNumber;
        public String cin;
        public string shortName;
        
    }

    public class partnerEmail {
        public List<String> to;
    }
}

// JSON payload for partner creation
//String jsonBody = '{ "partnerId": 5226836669675671, "partnerName": "01XARXA TECHNOLOGIES PRIVATE LIMITED", "partnerEmail": { "to": [ "c.shivad@northernarc.com" ] }, "phoneNumber": "", "cin": "U72900KA2019PTC124383" }';