public class API_CreatePaymentScheduleAPI{
    // Method to create a payment schedule using the provided API endpoint and data
    // Method to create a payment schedule using the provided API endpoint and data
    public static String createPaymentSchedule(Id TaskRecId){ // 

        auditwrapper auditwarp = new auditwrapper();
        try{

            NUScoreCreds__mdt webCreds = NUScoreCreds__mdt.getInstance('createPaymentSchedule');
            system.debug('webCreds--->' + webCreds);
            String endpoint = webCreds.endpoint__c;
            String apiKey = webCreds.apiKey__c;
            String groupKey = webCreds.groupKey__c;
           
            String boundary = createboundary();
            PswithJSONwrapper PswithJSONwrapValue = GeneratePsWrapper(TaskRecId);
           /*String body = 
            '--' + boundary + '\r\n' +
            'Content-Disposition: form-data; name="ps"\r\n\r\n' +
            PswithJSONwrapValue.PsJSON + '\r\n' + //
            '--' + boundary + '--\r\n';*/
            

            String body = PswithJSONwrapValue.PsJSON;
            System.debug('body =====> ' + body);
            HttpRequest request = new HttpRequest();
            
            request.setEndpoint(endpoint);
            System.debug('endpoint =====> ' + endpoint);
            request.setMethod('POST');
            request.setHeader('API-KEY', apiKey);
            request.setHeader('GROUP-KEY', groupKey);
            //request.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Content-Length', '0');
            request.setBody(body);
            auditwarp.RequestBody = body;


            // Send the request
            Http http = new Http();
            HttpResponse response = http.send(request);

            // Parse and handle the response
            //if(response != null){
                if (response.getStatusCode() == 200){
                    System.debug('Payment schedule created successfully.');
                    auditwarp.ResponseBody = response.getBody();
                    auditwarp.status = Label.AuditAPIStatus;
                    Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    if (resultMap.containsKey('paymentScheduleId')) {
                        updatePaymentSchedule(String.valueOf(resultMap.get('paymentScheduleId')),  PswithJSONwrapValue.PsRec.Id);
                        
                    }
                } else{
                    System.debug('Failed to create payment schedule. Status code: ' + response.getStatusCode());
                    System.debug('failed Response Body ====> ' + response.getBody());
                    auditwarp.ResponseBody = response.getBody();
                    auditwarp.status = Label.AuditAPIFailedStatus;
                    Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    if (resultMap.containsKey('paymentScheduleId')) {
                        updatePaymentSchedule(String.valueOf(resultMap.get('paymentScheduleId')),  PswithJSONwrapValue.PsRec.Id);
                        
                    }
                }

            // }
            // else if (response == null) {
            //     auditwarp.ResponseBody = null;
            //     auditwarp.status = Label.AuditAPIFailedStatus;
            // }
            

        } catch (Exception e){
            auditwarp.ResponseBody = null;
            auditwarp.status = Label.AuditAPIFailedStatus;

        }
        return JSON.serialize(auditwarp);
    }

    private static String createBoundary() {
        return '-----------------' + Datetime.now().getTime();
    }

    Public static PswithJSONwrapper GeneratePsWrapper(Id TaskId){
        Task TaskRec = new Task();
        List<Payment_Schedule__c> psrecord = new List<Payment_Schedule__c>();
        List<Document_Handler__c> DocHandlerList = new List<Document_Handler__c>();
        PaymentScheduleWrapper PaymentScheduleWrap = new PaymentScheduleWrapper();
        // Price Pricewrap = new Price();
        List<Price> prList = new List<Price>();
        PswithJSONwrapper PswithJSONwrap = new PswithJSONwrapper();

        try {
            
            if (TaskId != null) {

                TaskRec = [Select Id, whatId from task Where Id =:TaskId];
                if (TaskRec.whatId != null && String.valueOf(TaskRec.whatId).startsWith('006')) {
                    psrecord = [SELECT Billing_Frequency__c,Ceiling_Period__c,Ceiling_Price__c,Comment__c,Cost_Price_Type__c,CreatedDate,Floor_Period__c,
                            Floor_Price__c,Id,Model_Build_Price__c,Model_Recalibration_Price__c,Name,Opportunity__c,validity_End_Date__c,validity_start_Date__c,Opportunity__r.account.CustomerID__c,
                            (SELECT CreatedDate,End_Value__c,Id,Name,Payment_Schedule__c,Price_Structure_Reset_Frequency__c,Price_Structure_Type__c,Rate__c,Start_Value__c FROM Price_Structures__r )
                            FROM Payment_Schedule__c where Opportunity__c =: TaskRec.whatId LIMIT 1];
                    if (psrecord != null) {
                        PswithJSONwrap.psRec = psrecord[0];
                        PaymentScheduleWrap.docValidityFrom = String.valueOf(psrecord[0].validity_start_Date__c);
                        PaymentScheduleWrap.docValidityTill = String.valueOf(psrecord[0].validity_End_Date__c);
                        PaymentScheduleWrap.invoiceFrequency = getfrequencyvalue(psrecord[0].Billing_Frequency__c);
                        PaymentScheduleWrap.modelBuildPrice = psrecord[0].Model_Build_Price__c;
                        PaymentScheduleWrap.modelRecalibrationPrice = psrecord[0].Model_Recalibration_Price__c;
                        PaymentScheduleWrap.partnerId = Long.valueOf(psrecord[0].Opportunity__r.account.CustomerID__c);
                        PaymentScheduleWrap.pricingStructure = getPricestructureValue(psrecord[0].Price_Structures__r[0].Price_Structure_Type__c);
                        PaymentScheduleWrap.floorPrice = psrecord[0].floor_price__c;
                        PaymentScheduleWrap.floorPeriod = getfrequencyvalue(psrecord[0].Floor_Period__c);
                        PaymentScheduleWrap.ceilingPrice = psrecord[0].Ceiling_Price__c;
                        PaymentScheduleWrap.ceilingPeriod = getfrequencyvalue(psrecord[0].Ceiling_Period__c);
                        if (psrecord[0].Price_Structures__r.size() >0) {
                            for (Price_Structure__c pricestructureRec : psrecord[0].Price_Structures__r) {
                                Price pr = new Price();
                                pr.end_value = pricestructureRec.End_Value__c;
                                pr.start_value = pricestructureRec.Start_Value__c;
                                pr.pricing = pricestructureRec.Price_Structure_Type__c;
                                pr.per_hit_charge = pricestructureRec.Rate__c;
                                pr.count_reset = pricestructureRec.Price_Structure_Reset_Frequency__c != null ? getfrequencyvalue(pricestructureRec.Price_Structure_Reset_Frequency__c) : null;
                                prList.add(pr);
                            }
                        }

                        PaymentScheduleWrap.price = prList;
                    }

                    DocHandlerList = [Select Id, Name, Document_Name__c,DMS_Document_Path__c  from Document_Handler__c where Opportunity__c =: TaskRec.whatId];

                    if (DocHandlerList.size() > 0) {
                        for (Document_Handler__c docHand : DocHandlerList) {
                            if ( docHand.Document_Name__c != null && docHand.Document_Name__c.contains('Execution Document')) {
                                PaymentScheduleWrap.executionDocId = docHand.DMS_Document_Path__c;
                                PaymentScheduleWrap.executedDocTimestamp = String.valueOf(System.now());
                            }
                            if ( docHand.Document_Name__c != null && docHand.Document_Name__c.contains('Executed Document')) {
                                PaymentScheduleWrap.executedDocId = docHand.DMS_Document_Path__c;
                                PaymentScheduleWrap.executedDocTimestamp = String.valueOf(System.now());

                            }
                        }
                    }
                }
            }
            PswithJSONwrap.PsJSON = JSON.serialize(PaymentScheduleWrap);

        } catch (Exception e) {
            
        }
        System.debug('JSON.serialize(CompleteJSONbody) ===> ' + JSON.serialize(PaymentScheduleWrap));
        return PswithJSONwrap;
    }

    Public static void updatePaymentSchedule(String PSExternalId, String PsRecId){
        Payment_Schedule__c PsRec = new Payment_Schedule__c();
        PsRec.Id =PsRecId;
        PsRec.Payment_Schedule_ExternalId__c = PSExternalId;
        Update PsRec;
    }


    public static integer getfrequencyvalue(String invoiceFreq){
        Map<String, integer> mapName = new Map<String, integer>();
        mapName.put('Quarterly', 2);
        mapName.put('Monthly', 1);
        mapName.put('Semi-Annually', 3);
        mapName.put('Annually', 4);
        integer InvoicefreqValue = mapName.get(invoiceFreq);
        return InvoicefreqValue;
    }

    public class PswithJSONwrapper{
        public String PsJSON;
        public Payment_Schedule__c psRec;
    }


    public static integer getPricestructureValue(String PriceStructure){
        Map<String, integer> mapName = new Map<String, integer>();
        mapName.put('Fixed', 1);
        mapName.put('Slab', 2);
        mapName.put('Flat', 3);
        integer InvoicefreqValue = mapName.get(PriceStructure);
        return InvoicefreqValue;
    }

    Public class auditwrapper{

        Public String status;
        public String ResponseBody;
        public string RequestBody;

    }

    public class PaymentScheduleWrapper{
        public Long partnerId;
        public String docValidityFrom;
        public String docValidityTill;
        public String executionDocId;
        public String executedDocId;
        public String executedDocTimestamp;
        public Integer pricingStructure;
        public Integer invoiceFrequency;
        public Decimal modelBuildPrice;
        public Decimal modelRecalibrationPrice;
        public Decimal floorPrice;
        public Decimal floorPeriod;
        public Decimal ceilingPrice;
        public Decimal ceilingPeriod;    
        public String approvedBy;     
        public List<Price> price;

    }

    public class Price {
		public String pricing;
		public Decimal per_hit_charge;
		public Decimal start_value;
		public Decimal end_value;
        public integer count_reset;
	}

}


/*
{
    "partnerId": 5206485696693244,
    "docValidityFrom": "2023-02-11",
    "docValidityTill": "2025-03-11",
    "executionDocId": "https://northernarc.autonom8.com/gcs/a8flow-asia-south/northernarc/assets/6d745e04-4e2e-464f-9838-c43ec01a63ed",
    "executedDocId": "https://northernarc.autonom8.com/gcs/a8flow-asia-south/northernarc/assets/6d745e04-4e2e-464f-9838-c43ec01a63ed",
    "executedDocTimestamp": "2024-04-03T12:34:56.789Z",
    "pricingStructure": 1,
    "invoiceFrequency": 1,
    "modelBuildPrice": 60000,
    "modelRecalibrationPrice": null,
    "ceilingPrice": null,
    "ceilingPeriod": null,
    "floorPrice": null,
    "floorPeriod": null,
    "approvedBy": null,
    "price": [
        {
            "pricing": "Fixed",
            "end_value": null,
            "count_reset": null,
            "start_value": 1,
            "per_hit_charge": 11.5
        }
    ]
}*/