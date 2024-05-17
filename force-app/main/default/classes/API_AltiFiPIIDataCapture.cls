public without sharing class API_AltiFiPIIDataCapture{
    @InvocableMethod(label = 'Get PII Data Callout'description = 'returns opps for this contact.')
    public static void sendContactlistForCallout(List<Contact> conList){

        Set<String> AccountIds = new Set<String>();
        Set<String> AccountExternalIds = new Set<String>();
        Map<String, String> AccountIdwithContactId = new Map<String, String>();
        Map<String, String> AccountCustIdwithContactId = new Map<String, String>();
        List<Account> acclist = new List<Account>();
        if (!conList.isEmpty()){
            for (Contact con : conList){
                AccountIds.add(con.AccountId);
                if (con.AccountId != null){
                    AccountIdwithContactId.put(con.accountID, con.Id);
                }
                if (!AccountIds.isEmpty()){
                    acclist = [SELECT CustomerID__c, External_ID__c, Id, Name
                               FROM Account
                               where Id IN:AccountIds];
                    if (!acclist.isEmpty()){
                        for (account acc : acclist){
                            if (!AccountIdwithContactId.isEmpty() && AccountIdwithContactId.containsKey(acc.Id)){
                                AccountCustIdwithContactId.put(acc.CustomerID__c, AccountIdwithContactId.get(acc.Id));
                            }
                        }
                    }
                }
            }
        }
        if (!acclist.isEmpty()){
            for (Account acc : acclist){
               
                CaptureAltifiPIIData(acc.CustomerID__c, AccountIdwithContactId);
            }
        }
    }

    @Future(callout = true)
    public static void CaptureAltifiPIIData(String CustomerId, Map<String, String> AccountCustIdwithContactId){

    List<Account> AcclistTObeUpdated = new List<Account>();
    List<Contact> Conlisttobupdated = new List<Contact>();

        Notification_Auth_Details__mdt APIMetaData = [SELECT API_Key__c, Content_Type__c, Decryptionkey__c, Description__c, DeveloperName, EncryptionKey__c, End_Point__c, Group_Key__c, Id, Label, MasterLabel, Method__c, Sample_Body__c, Source_Facility__c
                                                      FROM Notification_Auth_Details__mdt
                                                      Where DeveloperName = 'AltiFi_CleverTap_PII_API'];

        Http httpProtocol = new Http();
        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();
        // Set the endpoint URL.
        String EndpointMetadata = APIMetaData.End_Point__c + CustomerId;
        System.debug('EndpointMetadata ====> ' + EndpointMetadata);
        //String endpoint = 'https://nimbusdev.northernarc.com/wm/api/user/salesForceUserInfo?userId=5186403223974263'; //'5295966510740562';
        request.setEndPoint(EndpointMetadata);

        // Set the HTTP verb to GET.
        request.setMethod(APIMetaData.Method__c);

        request.setHeader('API-Key', APIMetaData.API_Key__c);

        System.debug('request =====> ' + request);
        // Send the HTTP request and get the response.
        // The response is in JSON format.
        //if(!test.isrunningtest()){
            HttpResponse response = httpProtocol.send(request);
        //}
        
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201){
            System.debug('response.getBody() ====> ' + response.getBody());
            System.debug('JSON.deserializeUntyped(response.getBody() ====> ' + JSON.deserializeUntyped(response.getBody()));

            Map<String, object> AltiFiPIIDataCompleteMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            if (AltiFiPIIDataCompleteMap.containsKey('content')) {
                Map<string, Object> AltiFiPIIDataMap = (Map<string, Object>)(AltiFiPIIDataCompleteMap).get('content');
                System.debug('AltiFiPIIDataMap =====> ' + AltiFiPIIDataMap);
                if (!AltiFiPIIDataMap.isEmpty() && AltiFiPIIDataMap != null){
                Account updatedAcc = new Account();
                updatedAcc.External_Id__c = CustomerId;
                if (String.valueOf(AltiFiPIIDataMap.get('name')) != null && String.valueOf(AltiFiPIIDataMap.get('name')) != ''){
                    updatedAcc.Name = String.valueOf(AltiFiPIIDataMap.get('name'));
                }
                if (String.valueOf(AltiFiPIIDataMap.get('mobileNo')) != null && String.valueOf(AltiFiPIIDataMap.get('mobileNo')) != ''){
                    updatedAcc.Phone = String.valueOf(AltiFiPIIDataMap.get('mobileNo'));
                }
                if (String.valueOf(AltiFiPIIDataMap.get('email')) != null && String.valueOf(AltiFiPIIDataMap.get('email')) != ''){
                    updatedAcc.Email_Id__c = String.valueOf(AltiFiPIIDataMap.get('email'));
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
                            if (String.valueOf(AltiFiPIIDataMap.get('name')) != null){
                                    List < String > strList = (String.valueOf(AltiFiPIIDataMap.get('name'))).split(' ');
                                    if (strList.size() == 1) {
                                        con.LastName = String.valueOf(AltiFiPIIDataMap.get('name'));
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
                            if (String.valueOf(AltiFiPIIDataMap.get('mobileNo')) != null){
                                con.Phone = String.valueOf(AltiFiPIIDataMap.get('mobileNo'));
                            }
                            if (String.valueOf(AltiFiPIIDataMap.get('email')) != null){
                                con.Email = String.valueOf(AltiFiPIIDataMap.get('email'));
                            }
                            Conlisttobupdated.add(con);
                            System.debug('Conlisttobupdated ======> ' + Conlisttobupdated);

                        }
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

            }
                
            }
            
            //Map<String, object> AltiFiPIIDataMap = new Map<String, object>(AltiFiPIIDataCompleteMap.get('content'));
            //
            
        }
    }

}