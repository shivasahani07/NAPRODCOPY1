public class API_SearchPartnersAPI{
    // Method to search partners using the provided API endpoint and data
    public static String searchPartners(Id taskRecordId){
        task taskRec = new Task();
        String auditResult = '';
        List<String> ApiPArams = new List<String>();
        auditwrapper auditwrap = new auditwrapper();
        try{
            NUScoreCreds__mdt webCreds = NUScoreCreds__mdt.getInstance('searchPartners');
            system.debug('webCreds--->' + webCreds);
            String endpoint = webCreds.endpoint__c; //+ 'cin='+EncodingUtil.urlEncode(cin, 'UTF-8');
            String apiKey = webCreds.apiKey__c;
            String groupKey = webCreds.groupKey__c;

            if (taskRecordId != null){
                taskRec = [Select id, Attribute1__c
                           from Task
                           Where Id = :taskRecordId];
                if (taskRec.Attribute1__c != null && taskRec.Attribute1__c.contains(':')){
                    //myString1.contains(myString2);
                    ApiPArams = taskRec.Attribute1__c.split(':');
                    endpoint = endpoint + ApiPArams[0] + '=' + EncodingUtil.urlEncode(ApiPArams[1], 'UTF-8');
                }
            }

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('API-KEY', apiKey);
            request.setHeader('GROUP-KEY', groupKey);
            request.setTimeout(8000);

            auditwrap.RequestBody = String.ValueOf(request);

            // Send the request
            Http http = new Http();
            HttpResponse response = http.send(request);

            // Parse and handle the response
            if (response.getStatusCode() == 200){
                String responseBody = response.getBody();
                auditwrap.ResponseBody = responseBody;
                auditwrap.status = Label.AuditAPIStatus;
                // Parse the JSON response body as needed
                System.debug('Response body: ' + responseBody);
                if (ApiPArams[0] == 'cin'){
                    partnerlistwrapper partnerwrapperRec = (partnerlistwrapper)System.JSON.deserialize(responseBody, partnerlistwrapper.class);
                    DMLWrapper DMLWrap = createPartner_SF(partnerwrapperRec);
                    auditwrap.processingDMLData = DMLWrap.DMLMessage;
                    UpdateTask(taskRecordId, DMLWrap.AccRec.Id);
                } else if (ApiPArams[0] == 'companyName'){
                    List<partnerlistwrapper> partnerwrapperList = (List<partnerlistwrapper>)System.JSON.deserialize(responseBody, List<partnerlistwrapper>.class);
                    //createPartnerList_SF(partnerwrapperList);
                }
            } else{
                System.debug('Failed to search partners. Status code: ' + response.getStatusCode());
                auditwrap.status = Label.AuditAPIFailedStatus;
            }

        } catch (Exception e){
            System.debug('the error has ocurred due to ===> ' + e.getMessage());
            System.debug('the error has ocurred at ===> ' + e.getLineNumber());
            auditResult = Label.AuditAPIFailedStatus;
        }
        return JSON.serialize(auditwrap); //auditResult;
    }

    Public static DMLWrapper createPartner_SF(partnerlistwrapper partnerwrapperRec){
	
        DMLWrapper DMLWrap = new DMLWrapper();
        List<Account> Acclist = new List<Account>();
        Account partnerRec = new Account();
        partnerRec.External_ID__c = partnerwrapperRec.entity_id;
        partnerRec.CustomerID__c = partnerwrapperRec.entity_id;
        partnerRec.Name = partnerwrapperRec.name;
        partnerRec.CIN_No__c = partnerwrapperRec.cin;
        partnerRec.email_Id__c = partnerwrapperRec.email;
        partnerRec.Phone = partnerwrapperRec.phone;
        Acclist.add(partnerRec);
        
        Database.UpsertResult[] upsertResults = Database.upsert (Acclist, Account.External_ID__c, false);

        // Handle the upsert results
        for (Database.UpsertResult result : upsertResults){
            if (result.isSuccess()){
                // Record upserted successfully
                System.debug('Record upserted successfully: ' + result.getId());
                DMLWrap.DMLMessage = 'Created Successfully';
            } else{
                // Handle error
                for (Database.Error error : result.getErrors()){
                    System.debug('Error upserting record: ' + error.getMessage());
                    DMLWrap.DMLMessage = String.valueOf(error.getMessage());
                }
            }
        }
        DMLWrap.accRec = Acclist[0];
        return DMLWrap;
    }

    public Static Void UpdateTask(String TaskId, String AccountID){
        Task updateTask = new Task();
        updateTask.Id = TaskId;
        updateTask.WhatId = AccountID;
        update updateTask;

    }

    /*public static void createPartnerList_SF(List<partnerlistwrapper> partnerwrapperList){

        List<Account> Acclist = new List<Account>();
        for (partnerlistwrapper partnerwrapperRec : partnerwrapperList){
            Account partnerRec = new Account();
            partnerRec.External_ID__c = partnerwrapperRec.entity_id;
            partnerRec.CustomerID__c = partnerwrapperRec.entity_id;
            partnerRec.Name = partnerwrapperRec.name;
            partnerRec.CIN_No__c = partnerwrapperRec.cin;
            partnerRec.email_Id__c = partnerwrapperRec.email;
            partnerRec.Phone = partnerwrapperRec.phone;
            Acclist.add(partnerRec);
        }

        if (Acclist.size() > 0){
            Database.UpsertResult[] upsertResults = Database.upsert (Acclist, Account.External_ID__c, false);

            // Handle the upsert results
            for (Database.UpsertResult result : upsertResults){
                if (result.isSuccess()){
                    // Record upserted successfully
                    System.debug('Record upserted successfully: ' + result.getId());
                } else{
                    // Handle error
                    for (Database.Error error : result.getErrors()){
                        System.debug('Error upserting record: ' + error.getMessage());
                    }
                }
            }
        }
    }*/

    public class partnerlistwrapper{
        public String entity_id;
        public String name;
        public String cin;
        public String email;
        public String phone;

    }
    public class DMLWrapper{
		public Account accRec;
		public string DMLMessage;        
    }

    Public class auditwrapper{
        Public String status;
        public String ResponseBody;
        public string RequestBody;
        public string processingDMLData;

    }

}