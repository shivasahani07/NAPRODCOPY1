public without sharing class API_CustomerPIIDataCapture{
    @InvocableMethod(label = 'Get PII Data Callout'description = 'returns opps for this contact.')
    public static void sendEmailToOwner(List<Opportunity> Opplist){

        System.debug('Opplist =====> ' + Opplist);
        Set<String> AccountIds = new Set<String>();
        Set<String> AccountExternalIds = new Set<String>();
        Map<String, String> accountIdwithOppId = new Map<String, String>();
        Map<String, String> accountCustomerIdwithOppId = new Map<String, String>();

        for (Opportunity opp : Opplist){
            AccountIds.add(opp.AccountId);
            if (opp.IsClosed != true){
                 //Constants.OPP_STAGENAME_CLOSED_WON && opp.StageName != Constants.OPP_STAGENAME_CLOSED_LOST
                if (!accountIdwithOppId.containsKey(opp.AccountId)){
                    accountIdwithOppId.put(opp.AccountId, opp.Id);
                }

            }
        }
        if (!AccountIds.isEmpty()){
            List<Account> acclist = [SELECT CustomerID__c, Customer_Type__c, Email_Id__c, External_ID__c, Id, phone, Name, OwnerId, PAN_No__c, Partner_Name__c			//Mobile_Number__c
                                     FROM Account
                                     where Id IN:AccountIds];

            if (!acclist.isEmpty()){
                for (Account acc : acclist){
                    if (accountIdwithOppId.containsKey(acc.Id)){
                        accountCustomerIdwithOppId.put(acc.CustomerID__c, accountIdwithOppId.get(acc.Id));
                    }
                }

                if (!accountCustomerIdwithOppId.isEmpty()){
                    for (Account acc : acclist){
                        CapturePIIData(acc.CustomerID__c, accountCustomerIdwithOppId);
                    }
                }
            }
        }
    }

    @Future(callout = true)
    public static void CapturePIIData(String CustomerId, Map<String, String> accountIdwithOppId){

        try{
            Notification_Auth_Details__mdt APIMetaData = [SELECT API_Key__c, Content_Type__c, Decryptionkey__c, Description__c, DeveloperName, EncryptionKey__c, End_Point__c, Group_Key__c, Id, Label, MasterLabel, Method__c, Sample_Body__c, Source_Facility__c
                                                          FROM Notification_Auth_Details__mdt
                                                          Where DeveloperName = 'EL_CleverTap_PII_API'];
                                                    
            System.debug('APIMetaData ====> ' + APIMetaData);
            string apikey = System.Label.ClevertapAPIkey;
            System.debug('apikey =====> ' + APIMetaData.API_Key__c);
            System.debug('apikey =====> ' + APIMetaData.End_Point__c);
            System.debug('apikey =====> ' + APIMetaData.Method__c);
            System.debug('apikey =====> ' + APIMetaData.Method__c);
            Http httpProtocol = new Http();
            // Create HTTP request to send.
            HttpRequest request = new HttpRequest();
            // Set the endpoint URL.
            String EndpointMetadata = APIMetaData.End_Point__c + CustomerId;
            System.debug('EndpointMetadata ====> ' + EndpointMetadata);
            //String endpoint = 'https://stage.northernarc.com/retail/api/user/details?userId=' + CustomerId; //'5295966510740562';
            request.setEndPoint(EndpointMetadata);

            // Set the HTTP verb to GET.
            request.setMethod(APIMetaData.Method__c);

            request.setHeader('x-api-key', APIMetaData.API_Key__c);

            System.debug('request =====> ' + request);
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            HttpResponse response = httpProtocol.send(request);
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201){
                Map<String, object> PIIDataMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

                Map<String, Object> CustomerPIIData = (Map<String, Object>)PIIDataMap.get('content');
                System.debug('CustomerPIIData =====> ' + CustomerPIIData);

                List<Account> AcclistTObeUpdated = new List<Account>();
                List<Contact> Conlisttobupdated = new List<Contact>();
                List<Task> taskListTObeUpdated = new List<Task>();
                Account updatedAcc = new Account();
                updatedAcc.External_Id__c = CustomerId;
                if (String.valueOf(CustomerPIIData.get('name')) != null && String.valueOf(CustomerPIIData.get('name')) != ''){
                    updatedAcc.Name = String.valueOf(CustomerPIIData.get('name'));
                }
                if (String.valueOf(CustomerPIIData.get('mobile')) != null && String.valueOf(CustomerPIIData.get('mobile')) != ''){
                    updatedAcc.Phone  = String.valueOf(CustomerPIIData.get('mobile'));
                }
                if (String.valueOf(CustomerPIIData.get('email')) != null && String.valueOf(CustomerPIIData.get('email')) != ''){
                    updatedAcc.Email_Id__c = String.valueOf(CustomerPIIData.get('email'));
                }
                

                AcclistTObeUpdated.add(updatedAcc);

                Schema.SObjectField ftoken = Account.Fields.External_Id__c;
                Database.UpsertResult[] cr = Database.upsert (AcclistTObeUpdated, ftoken, false); //Lead.ExternalId__c.getDescribe().getSObjectField(),
                Map<Id, Account> AccountMap = new Map<Id, Account>(AcclistTObeUpdated);
                for (Database.upsertResult result : cr){

                    System.debug('result =====> ' + result);
                    if (result.isSuccess()){
                        List<Contact> conList = [Select id, Firstname, Lastname, Phone, email
                                                 From contact
                                                 where account.External_Id__c = :CustomerId];

                        System.debug('conList ====> ' + conList);

                        if (!conList.isEmpty()){

                            Contact con = new contact();
                            con.Id = conList[0].Id;
                            if (String.valueOf(CustomerPIIData.get('name')) != null){
                                    List < String > strList = (String.valueOf(CustomerPIIData.get('name'))).split(' ');
                                    if (strList.size() == 1) {
                                        con.LastName = String.valueOf(CustomerPIIData.get('name'));
                                    }
                                    if (strList.size() == 2) {
                                        con.LastName = strList[1];
                                        con.FirstName = strList[0];
                                    }
                                    if (strList.size() == 3) {
                                        //con.LastName = String.valueOf(CustomerPIIData.get('name'));
                                        con.LastName = strList[2];
                                        con.MiddleName = strList[1];
                                        con.FirstName = strList[0];
                                    }
                                
                            }
                            if (String.valueOf(CustomerPIIData.get('mobile')) != null){
                                con.Phone = String.valueOf(CustomerPIIData.get('mobile'));
                            }
                            if (String.valueOf(CustomerPIIData.get('email')) != null){
                                con.Email = String.valueOf(CustomerPIIData.get('email'));
                            }
                            Conlisttobupdated.add(con);
                            System.debug('Conlisttobupdated ======> ' + Conlisttobupdated);

                        }

                        if (accountIdwithOppId.containsKey(CustomerId)){
                            String OppId = accountIdwithOppId.get(CustomerId);

                            if (OppId != NULL){

                                List<Task> CustomerOppTaskList = [SELECT AccountId, CreatedDate, DateTime_of_Meeting__c, External_Id__c, IsClosed, Follow_Up__c, Id, Meeting_Call_Purpose__c, Meeting_Call_status__c, Meeting_Date__c, Meeting_Time__c, OwnerId, Stage__c, Status, WhatId, WhoId
                                                                  FROM Task
                                                                  where whatId = :OppId];
                                if (CustomerOppTaskList.size() > 0){
                                    for (Task tas : CustomerOppTaskList){
                                        if (tas.IsClosed == false){
                                            task updatedtask = new task();
                                            updatedtask.Id = TAS.Id;
                                            updatedtask.Status = Constants.TASK_STATUS_SYSTEM_CLOSED;
                                            taskListTObeUpdated.add(updatedtask);
                                        }
                                    }
                                }
                            }
                        }

                    } else{

                    }
                }

                System.debug('Conlisttobupdated =====> ' + Conlisttobupdated);
                System.debug('Conlisttobupdated size =====> ' + Conlisttobupdated.size());
                if (!Conlisttobupdated.isEmpty()){

                    Database.UpsertResult[] Conresultlist = Database.upsert (Conlisttobupdated, false); //Lead.ExternalId__c.getDescribe().getSObjectField(),
                    for (Database.upsertResult conresult : Conresultlist){
                        System.debug('conresult =====> ' + conresult);
                        if (conresult.isSuccess()){

                        } else{

                        }
                    }

                }
                System.debug('Conlisttobupdated =====> ' + Conlisttobupdated);
                if (!taskListTObeUpdated.isEmpty()){
                    Database.UpsertResult[] Taskresultlist = Database.upsert (taskListTObeUpdated, false); //Lead.ExternalId__c.getDescribe().getSObjectField(),

                    for (Database.upsertResult taskresult : Taskresultlist){

                        System.debug('taskresult =====> ' + taskresult);
                        if (taskresult.isSuccess()){

                        } else{

                        }
                    }

                }
            }

        } catch (Exception e){
            System.debug('the error has occured due to ======> ' + e.getMessage());
            System.debug('the error has occured at line number ======> ' + e.getLineNumber());

        }
    }

}