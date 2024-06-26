public class API_AddRecalibrationAPI{
    // Method to add recalibration using the provided API endpoint and data
    public static String addRecalibration(Id TaskId){

        auditwrapper auditwarp = new auditwrapper();
        try{
            NUScoreCreds__mdt webCreds = NUScoreCreds__mdt.getInstance('addRecalibration');
            system.debug('webCreds--->' + webCreds);
            RecalibrationWrapper RecalibrationWrap = GeneratePsDetails(TaskId);
            String reqBody = JSON.serialize(RecalibrationWrap);
            System.debug('reqBody =====> ' + reqBody);
            auditwarp.RequestBody = reqBody;

            String endpoint = webCreds.endpoint__c; // + Paymentschedulewrap.PsExtId + '?submit_remarks=' + (Paymentschedulewrap.submitRemarks != null ? EncodingUtil.urlEncode(Paymentschedulewrap.submitRemarks, 'UTF-8'): '');
            String apiKey = webCreds.apiKey__c;
            String groupKey = webCreds.groupKey__c;

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('API-KEY', apiKey);
            request.setHeader('GROUP-KEY', groupKey);
            request.setHeader('Content-Length', '0');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(reqBody);

            

            // Send the request
            Http http = new Http();
            HttpResponse response = http.send(request);

            // Parse and handle the response
            if (response.getStatusCode() == 200){
                System.debug('Recalibration added successfully.');
                String responseBody = response.getBody();
                System.debug('Response body: ' + responseBody);
                auditwarp.ResponseBody = responseBody;
                auditwarp.status = Label.AuditAPIStatus;
                updatePsRecalibrationstatus(Label.AuditAPIStatus, String.valueOf(RecalibrationWrap.paymentScheduleId));
            } else{
                auditwarp.ResponseBody = response.getBody();
                auditwarp.status = Label.AuditAPIFailedStatus;
                updatePsRecalibrationstatus(Label.AuditAPIFailedStatus, String.valueOf(RecalibrationWrap.paymentScheduleId));
                System.debug('Failed to create partner. Status code: ' + response.getStatusCode());
            }

        } catch (Exception e){
            auditwarp.ResponseBody = null;
            auditwarp.status = Label.AuditAPIFailedStatus;

        }
        return JSON.serialize(auditwarp);
    }

    Public static RecalibrationWrapper GeneratePsDetails(Id TaskId){
        Task TaskRec = new Task();
        List<Payment_Schedule__c> psrecord = new List<Payment_Schedule__c>();
        Paymentschedulewrapper Paymentschedulewrap = new Paymentschedulewrapper();
        RecalibrationWrapper RecalibrationWrap = new RecalibrationWrapper();
        List<Document_Handler__c> DocHandlerList = new List<Document_Handler__c>();

        try {
            
            if (TaskId != null) {

                //TaskRec = [Select Id, whatId from task Where Id =:TaskId];
                TaskRec = [SELECT Id, Status, Subject,WhatId, TYPEOF What
                                        WHEN Opportunity THEN Name, AccountId
                                        END
                                        FROM Task where Id=:TaskId];

                system.debug('AccountId +==> ' + TaskRec.what);
                Opportunity Opp = TaskRec.What;
                system.debug('AccountId +==> ' + Opp.AccountId);
                if (TaskRec.whatId != null && String.valueOf(TaskRec.whatId).startsWith('006')) {

                    psrecord = [SELECT Billing_Frequency__c,Ceiling_Period__c,Ceiling_Price__c,Comment__c,Cost_Price_Type__c,CreatedDate,Floor_Period__c,Payment_Schedule_ExternalId__c,New_Recalibration_Price__c,
                            Floor_Price__c,Id,Model_Build_Price__c,Model_Recalibration_Price__c,Name,Opportunity__c,Opportunity__r.Account.CustomerID__c,validity_End_Date__c,validity_start_Date__c,Recalibration_Price_Status__c,
                            (SELECT CreatedDate,End_Value__c,Id,Name,Payment_Schedule__c,Price_Structure_Reset_Frequency__c,Price_Structure_Type__c,Rate__c,Start_Value__c FROM Price_Structures__r )
                            FROM Payment_Schedule__c where Opportunity__r.AccountId =: Opp.AccountId and Opportunity__r.Type ='Payment Schedule Creation' LIMIT 1];
                    if (psrecord != null) {
                        //Paymentschedulewrap.PartnerId = psrecord[0].Opportunity__r.Account.CustomerID__c;
                        Paymentschedulewrap.PsExtId = psrecord[0].Payment_Schedule_ExternalId__c;
                        Paymentschedulewrap.submitRemarks = psrecord[0].Comment__c;

                        RecalibrationWrap.paymentScheduleId = Long.valueOf(psrecord[0].Payment_Schedule_ExternalId__c);
                        if(psrecord[0].Recalibration_Price_Status__c == '' || psrecord[0].Recalibration_Price_Status__c == null){
                            RecalibrationWrap.type = 'modelBuild';
                            RecalibrationWrap.charges = psrecord[0].Model_Build_Price__c;
                        }
                        else if (psrecord[0].Recalibration_Price_Status__c != '' || psrecord[0].Recalibration_Price_Status__c == 'In Progress') {
                            RecalibrationWrap.type = 'recalibration';
                            RecalibrationWrap.charges = psrecord[0].New_Recalibration_Price__c;
                        }
                    }

                    DocHandlerList = [Select Id, Name, Document_Name__c, DMS_Document_Path__c from Document_Handler__c where Opportunity__c =: TaskRec.whatId];
                    if (DocHandlerList.size() > 0) {
                        for (Document_Handler__c docHand : DocHandlerList) {
                        if ( docHand.Document_Name__c != null && docHand.Document_Name__c.contains('Recalibration Document')) {
                                RecalibrationWrap.recalExecutedDocId = docHand.DMS_Document_Path__c;
                            }
                        }
                    }
                }
            }  
        }
        catch(Exception e){
            System.debug('The error occured Due to :: ' + e.getMessage());
            System.debug('The error occured Due to :: ' + e.getLineNumber());
        }
        return RecalibrationWrap;
    }

    public static void updatePsRecalibrationstatus(String Status, String PsExtId){

        Payment_Schedule__c updatePs = new Payment_Schedule__c();
        updatePs.Payment_Schedule_ExternalId__c = PsExtId;
        updatePs.Recalibration_Price_Status__c = Status;

        Schema.SObjectField ftoken = Payment_Schedule__c.Fields.Payment_Schedule_ExternalId__c;
        Database.UpsertResult results = Database.Upsert(updatePs, ftoken,false);

    }

    Public class auditwrapper{
        Public String status;
        public String ResponseBody;
        public string RequestBody;

    }

    public class Paymentschedulewrapper{
        public string PsExtId;
        public string submitRemarks;
    }

    public class RecalibrationWrapper{
        public Long paymentScheduleId;
        public decimal charges;
        public string type;
        public String recalExecutedDocId;

    }

}

/*
{
    "paymentScheduleId": 5176400577974174,
    "charges": 50000,
    "type": "recalibration",
    "recalExecutedDocId": "https://northernarc.autonom8.com/gcs/a8flow-asia-south/northernarc/assets/6d745e04-4e2e-464f-9838-c43ec01a63ed"
}*/