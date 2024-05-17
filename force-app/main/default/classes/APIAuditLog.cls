global class APIAuditLog {
    public static void createAPIAuditLog(List<APIAuditLog.auditWrapper> auditWrapper,Map<Id,Id> mapofTaskIdByTaskCustomId){
        List<API_Callout_Audit__c> apiCalloutAuditTobeInsert = new List<API_Callout_Audit__c>();
        for(APIAuditLog.auditWrapper audit : auditWrapper){
            API_Callout_Audit__c aca = new API_Callout_Audit__c();
            aca.Process_Attribute_Details__c 	= audit.padID;
            aca.Request__c 						= audit.request;
            aca.Response__c						= audit.response;
            aca.API_Status__c					= audit.Status;
            aca.Task_ID__c						= audit.taskId;
            aca.Status_Code__c					= audit.statusCode;
            aca.Status__c						= 'Completed';
            system.debug('::'+audit.Id);
            aca.Id								= audit.Id;
            aca.Task_Custom__c					= mapofTaskIdByTaskCustomId.get(audit.taskId);
            apiCalloutAuditTobeInsert.add(aca);
        }
        
        if(!apiCalloutAuditTobeInsert.isEmpty()){
            update apiCalloutAuditTobeInsert;
        }
    }
    
    global class auditWrapper{
        public string request;
        public string response;
        public string Status;
        public string activityType;
        public Id 	   padID;
        public String taskId;
        public String statusCode;
        public String Id;
        
    }
}