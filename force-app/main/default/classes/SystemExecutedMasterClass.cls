public class SystemExecutedMasterClass {
    
    public class FlowInput {
        @InvocableVariable(label='Record Id' required=true)
        public Id recordId;
        @InvocableVariable(label='actionName' required=true)
        public String actionName;
        @InvocableVariable(label='taskRecordId' required=true)
        public String taskRecordId;
    } 
    
    @InvocableMethod(label='ExecuteSystemAction' description='Process records using Apex')
    public static void processRecords(List<FlowInput> flowInputs) {
        String auditResult = '';
        ID auditRecId;
        API_Callout_Audit__c acaRec = new API_Callout_Audit__c();
        AuditResponseWrapperClass auditResponse = new AuditResponseWrapperClass();
        //API_CreatePartnerAPI.auditwrapper auditwarp = new API_CreatePartnerAPI.auditwrapper();
        Utility_Wrapperclass.audit_wrapper auditResponse_warp=new Utility_Wrapperclass.audit_wrapper();
        auditRecId = flowInputs[0].recordId;
        if(flowInputs[0].actionName == 'RepaymentScheduleAPICallout'){
            auditResponse = WelcomeLetterHandler.CallRepymentScheduleAPI(flowInputs[0].taskRecordId);
            acaRec.API_Status__c = auditResponse.auditRec.API_Status__c;
        }else if(flowInputs[0].actionName == 'RepaymentSchedulePDFGeneration'){
            auditResponse = WelcomeLetterHandler.WelcomeLetterGenerationFlow(flowInputs[0].taskRecordId);
            acaRec.API_Status__c = auditResponse.auditRec.API_Status__c;
        }else if(flowInputs[0].actionName == 'EmailService'){
            auditResponse = EmailService.ExecuteEmailServices(flowInputs[0].taskRecordId,'');
            acaRec.API_Status__c = auditResponse.auditRec.API_Status__c;
        }else if(flowInputs[0].actionName == 'BulkMEMOExecutionSubmition'){
            auditResponse = BulkMEMOExecutionSubmittion.ExecutionProcess(flowInputs[0].taskRecordId);
            acaRec.API_Status__c = auditResponse.auditRec.API_Status__c;
        }
        else if (flowInputs[0].actionName == 'API_SearchPartnersAPI') {
            //NU Score Process
            //auditResult = API_SearchPartnersAPI.searchPartners(input.taskRecordId);
            //acaRec.API_Status__c = auditResult;
            //auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
        }
        else if (flowInputs[0].actionName == 'API_CreatePartnerAPI') {
            //NU Score Process
            //auditResult= API_CreatePartnerAPI.createPartner(input.taskRecordId);
            //auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
            
        }
        else if (flowInputs[0].actionName == 'API_CreatePaymentScheduleAPI') {
            //NU Score Process
            //auditResult = API_CreatePaymentScheduleAPI.createPaymentSchedule(input.taskRecordId);
            //auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
            
        }
        else if (flowInputs[0].actionName == 'API_AddRecalibrationAPI') {
            //NU Score Process
            //auditResult = API_AddRecalibrationAPI.addRecalibration(input.taskRecordId);
            //auditwarp = (API_CreatePartnerAPI.auditwrapper) System.JSON.deserialize(auditResult, API_CreatePartnerAPI.auditwrapper.class);
            
        }
        else if (flowInputs[0].actionName == 'API_PennyDropCallout') {
            //LAP Process
            auditResult = API_PennyDropCallout.processResponseData(flowInputs[0].taskRecordId);
            auditResponse_warp = (Utility_Wrapperclass.audit_wrapper) System.JSON.deserialize(auditResult, Utility_Wrapperclass.audit_wrapper.class);
        }
        else if (flowInputs[0].actionName == 'API_getPennyDropStatusbyBatchId') {
            //LAP Process
            auditResult = API_getPennyDropStatusbyBatchId.processRequestdata(flowInputs[0].taskRecordId);
            auditResponse_warp = (Utility_Wrapperclass.audit_wrapper) System.JSON.deserialize(auditResult, Utility_Wrapperclass.audit_wrapper.class); 
        }
        else if (flowInputs[0].actionName == 'API_updaeStatus') {
            //LAP Process
            auditResult = API_updateStatus.processRequestdata(flowInputs[0].taskRecordId);
            auditResponse_warp = (Utility_Wrapperclass.audit_wrapper) System.JSON.deserialize(auditResult, Utility_Wrapperclass.audit_wrapper.class);
        }
        system.debug('auditResult::'+auditResult);
        system.debug('auditRecId::'+auditRecId);
        acaRec.Id = auditRecId;
        
        /*if(auditwarp != null){
acaRec.Request__c = auditwarp.RequestBody;
acaRec.Response__c =auditwarp.ResponseBody;
acaRec.Response_Proccessing_DML_Result__c =auditwarp.processingDMLData;
acaRec.Status__c = 'Completed';
acaRec.API_Status__c = auditwarp.status;  
}*/
        
        if(auditResponse_warp!=null){
            acaRec.Request__c = auditResponse_warp.RequestBody;
            acaRec.Response__c =auditResponse_warp.ResponseBody;
            acaRec.Response_Proccessing_DML_Result__c =auditResponse_warp.processingDMLData;
            acaRec.Status__c = 'Completed';
            acaRec.API_Status__c = auditResponse_warp.status; 
        }
        
        if (auditResponse.auditRec != null) {
            acaRec.API_Status__c = auditResponse.auditRec.API_Status__c;
            acaRec.Response__c = auditResponse.auditRec.Response__c;
            acaRec.Request__c = auditResponse.auditRec.Request__c;
            acaRec.Status__c = 'Completed';
            acaRec.Status_Code__c = auditResponse.auditRec.Status_Code__c;
        }
        system.debug('acaRec::'+acaRec);
        update acaRec;
        
    }
    
}