global without sharing class API_WebserviceHelper {
   
    global class Response extends API_WebserviceResponse{
        public Response(){
        }
        public List<Utility_Wrapperclass.Record_Response> Activity_status;
    }

    Public static Response createResponse(String requestString,string CreateRecordStatus,string UpdateRecordStatus){

        Response res = new Response();
    
        Utility_Wrapperclass.AuditWrapper auditRecord = new Utility_Wrapperclass.AuditWrapper();
        List<Utility_Wrapperclass.Record_Response> Activity_status = new List<Utility_Wrapperclass.Record_Response>();
        Integer NoofRecordSuccessed = 0;
        Integer NoofRecordsFailed = 0;
        Integer TotalNoOfRecord = 0;
        string Message;
    
        try{
    
            if (!String.isEmpty(requestString)){
    
                   auditRecord = API_Auditlog_ResponseHelper.create_AuditLog(null, '201', 'New', 'Inbound', string.valueOf(requestString), string.valueOf(res), 0, 0, '');
    
                Map<String, Object> bodyMap = (Map<string, object>)JSON.deserializeUntyped(requestString);
                system.debug('bodyMap---' + bodyMap);
    
                Utility_Wrapperclass.ApiDmlandResponseList Task_upsert = upsert_activity(bodyMap);
    
                TotalNoOfRecord = Task_upsert.sobjectlistto_upsert.size();
    
                if (!Task_upsert.sobjectlistto_upsert.isEmpty()){
    
                    
                    Database.UpsertResult[] results = Database.upsert (Task_upsert.sobjectlistto_upsert,Task_upsert.UpsertRelated_To,false);
    
                    for (Database.UpsertResult result : results){
    
                        System.debug('result =====> ' + result);
                        if (result.isSuccess()){
    
                            NoofRecordSuccessed = NoofRecordSuccessed + 1;
    
                            if (result.isCreated()){
                                       Activity_status.add(API_Auditlog_ResponseHelper.create_Response(result.getId(), CreateRecordStatus));
                            } else{
                                      Activity_status.add(API_Auditlog_ResponseHelper.create_Response(result.getId(), UpdateRecordStatus));
                            }
                        } else{
                            System.debug('errors ===> ' + result.geterrors());
                            Message = String.valueof(result.geterrors());
                            for (Database.Error err : result.getErrors()){
    
                                NoofRecordsFailed = NoofRecordsFailed + 1;
                                   Activity_status.add(API_Auditlog_ResponseHelper.create_Response(result.getId(), err.getMessage()));
                            }
                        }
                    } 
                }
                if (TotalNoOfRecord == NoofRecordSuccessed){
    
                       res = API_Auditlog_ResponseHelper.BulkcreateResponse(auditRecord.Sf_auditId, '200', 'Success', 'Inbound',NoofRecordSuccessed, NoofRecordsFailed, '');
    
                } else if (TotalNoOfRecord == NoofRecordsFailed){
    
                       res = API_Auditlog_ResponseHelper.BulkcreateResponse(auditRecord.Sf_auditId, '400', 'Failed', 'Inbound',NoofRecordSuccessed, NoofRecordsFailed,Message);
    
                } else if (NoofRecordsFailed != 0 && TotalNoOfRecord > NoofRecordsFailed){
    
                       res = API_Auditlog_ResponseHelper.BulkcreateResponse(auditRecord.Sf_auditId, '207', 'Partial Success', 'Inbound',NoofRecordSuccessed, NoofRecordsFailed,Message);
    
                }
                res.Activity_status = Activity_status;
                if (!Task_upsert.CRresponse.isEmpty()){
    
                    Activity_status.addAll(Task_upsert.CRresponse);
                    res.Activity_status = Activity_status;
                }
            } else{
                    auditRecord = API_Auditlog_ResponseHelper.create_AuditLog(null, '400', 'Error', 'Inbound', string.valueOf(requestString), string.valueOf(res), 0, 0, constants.API_REQUEST_BODY_IS_NULL);
            } 
                System.debug('auditRecord--' + auditRecord);
                    auditRecord = API_Auditlog_ResponseHelper.create_AuditLog(auditRecord.Sf_auditId, res.StatusCode, res.Status, 'Inbound', string.valueOf(requestString), string.valueOf(res), NoofRecordSuccessed, NoofRecordsFailed, res.Message);
    
        }catch(Exception e){
    
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());
    
        }
        return res;
    }
    
    Public static Utility_Wrapperclass.ApiDmlandResponseList upsert_activity(Map<String, Object> bodyMap){
        system.debug('bodyMap---' + bodyMap);
    
        Utility_Wrapperclass.ApiDmlandResponseList Taskwrapperrec = new Utility_Wrapperclass.ApiDmlandResponseList();
        List<Utility_Wrapperclass.Record_Response> cresponse = new List<Utility_Wrapperclass.Record_Response>();
        List<Task> sobjectlistto_upsert = new List<Task>();
    
        Map<string, object> JSONbody = new Map<string, object>();
        Map<String, Boolean> MandatoryFields = new Map<String, Boolean>();
        Map<String, String> systemIdRelatedToSobject = new Map<String, String>();
        Map<string, string> APIlabelNameRelatedSobjectFieldApiName = new Map<String, String>();
        Map<String, String> ObjectApiNameRelatedErrorMessage = new Map<String, String>();
        Map<Id, Sobject> SobjectRecordRelatedToId = new Map<Id, Sobject>();
        Map<Id, Sobject> SobjectRecordRelatedToWhatId = new Map<Id, Sobject>();
        Map<String, String> ApiLabelNameDataType = new Map<String, String>();
        Boolean AddrecordToList;
        Set<Integer> indextoremove = new Set<Integer>();
        List<SObject> sobjectRec = new List<SObject>();
        String UpsertRelatedTo;
        Schema.SObjectField fieldtoken;

        Map<String,Id> UserEmailId=GetUserDetails();
    
        if (!bodyMap.isEmpty()){
    
            if (string.valueOf(bodyMap.get('systemId')) != null && string.valueOf(bodyMap.get('systemId')) != '' && string.valueOf(bodyMap.get('systemId')) != ' '){
    	
                List<API_Calling_System_Details__c> ACSD = [Select Id,Upsert_Related_To__c,System_Mode__c, System_Name__c, Name, (select Id, API_Label_Name__c, Error_Meassage__c, Object_API_Name__c, Mandatory__c, Object_Field_API_Name__c, Data_Type_Conversion__c, API_Calling_System_Details__r.Name
                                                                                                                From API_field_Processing_Details__r)
                                                            From API_Calling_System_Details__c
                                                            Where Name = :string.valueOf(bodyMap.get('systemId'))];
    
                if (!ACSD.isEmpty() && ACSD.size() > 0){
    
                    List<Object> JSONObjectList = (List<Object>)bodyMap.get('sobjectarray');
                    system.debug('JSONObjectList--' + JSONObjectList);
    
                    for (API_Calling_System_Details__c ACSDrecord : ACSD){
    
                        UpsertRelatedTo=ACSDrecord.Upsert_Related_To__c;
                        for (API_Field_Processing_Detail__c AFPR : ACSDrecord.API_field_Processing_Details__r){
    
                            systemIdRelatedToSobject.put(AFPR.API_Calling_System_Details__r.Name, AFPR.Object_API_Name__c);
    
                            APIlabelNameRelatedSobjectFieldApiName.put(AFPR.API_Label_Name__c, AFPR.Object_Field_API_Name__c);
    
                            MandatoryFields.put(AFPR.API_Label_Name__c, AFPR.Mandatory__c);
    
                            ObjectApiNameRelatedErrorMessage.put(AFPR.API_Label_Name__c, AFPR.Error_Meassage__c);
    
                            if (AFPR.Data_Type_Conversion__c != null){
                                ApiLabelNameDataType.put(AFPR.API_Label_Name__c, AFPR.Data_Type_Conversion__c);
                            }
                        }
                    }
                    system.debug('systemIdRelatedToSobject---' + systemIdRelatedToSobject);
                    system.debug('MandatoryFields---' + MandatoryFields);
                    system.debug('APIlabelNameRelatedSobjectFieldApiName---' + APIlabelNameRelatedSobjectFieldApiName);
                    //IF Mandatory Fields are Empty
                    if (!JSONObjectList.isEmpty()){
                        for (Object obj : JSONObjectList){
    
                            JSONbody = (map<string, object>)obj;
                            system.debug('JSONbody--' + JSONbody);
                            system.debug('JSONbody--is not Empty');
    
                            string SFobject = systemIdRelatedToSobject.get(string.valueOf(bodyMap.get('systemId')));
                            Schema.SObjectType t = Schema.getGlobalDescribe().get(SFobject);
                            SObject sObj = t.newSObject();
                            fieldtoken=Schema.getGlobalDescribe().get(SFobject).getDescribe().fields.getMap().get(UpsertRelatedTo);

                            
                            for (String jsonkey : JSONbody.keySet()){
                                if ((MandatoryFields.containsKey(jsonkey) && MandatoryFields.get(jsonkey) == true) && (string.valueOf(JSONbody.get(jsonkey)) != null && string.valueOf(JSONbody.get(jsonkey)) != '')){
    
                                    if (ApiLabelNameDataType.containsKey(jsonkey) && ApiLabelNameDataType.get(jsonkey) == 'Date'){
                                        sObj.put(APIlabelNameRelatedSobjectFieldApiName.get(jsonkey), Date.valueOf(String.valueOf(JSONbody.get(jsonkey))));
                                    } else if(ApiLabelNameDataType.containsKey(jsonkey) && ApiLabelNameDataType.get(jsonkey) == 'Decimal'){
                                        sObj.put(APIlabelNameRelatedSobjectFieldApiName.get(jsonkey), Decimal.valueOf(string.valueOf(JSONbody.get(jsonkey))));
                                    }else if(ApiLabelNameDataType.containsKey(jsonkey) && ApiLabelNameDataType.get(jsonkey) =='ownerId'){
                                        sObj.put(APIlabelNameRelatedSobjectFieldApiName.get(jsonkey), UserEmailId.get(string.valueOf(JSONbody.get(jsonkey))));
                                    }else{
                                        sObj.put(APIlabelNameRelatedSobjectFieldApiName.get(jsonkey), string.valueOf(JSONbody.get(jsonkey)));
                                    }
    
                                    AddrecordToList = true;
    
                                } else if (MandatoryFields.containsKey(jsonkey) && MandatoryFields.get(jsonkey) == false){
    
                                            if (string.valueOf(JSONbody.get(jsonkey)) != null && string.valueOf(JSONbody.get(jsonkey)) != ''){
                                                if (ApiLabelNameDataType.containsKey(jsonkey) && ApiLabelNameDataType.get(jsonkey) == 'Date'){
                                                    sObj.put(APIlabelNameRelatedSobjectFieldApiName.get(jsonkey), Date.valueOf(String.valueOf(JSONbody.get(jsonkey))));

                                                }else if(ApiLabelNameDataType.containsKey(jsonkey) && ApiLabelNameDataType.get(jsonkey) == 'Decimal'){
                                                    sObj.put(APIlabelNameRelatedSobjectFieldApiName.get(jsonkey), Decimal.valueOf(string.valueOf(JSONbody.get(jsonkey))));  
                                                } 
                                                else if(ApiLabelNameDataType.containsKey(jsonkey) && ApiLabelNameDataType.get(jsonkey) =='ownerId'){
                                                    sObj.put(APIlabelNameRelatedSobjectFieldApiName.get(jsonkey), UserEmailId.get(string.valueOf(JSONbody.get(jsonkey))));
                                                }else{
                                                    sObj.put(APIlabelNameRelatedSobjectFieldApiName.get(jsonkey), string.valueOf(JSONbody.get(jsonkey)));
                                                }
                                            } else{
                                                sObj.put(APIlabelNameRelatedSobjectFieldApiName.get(jsonkey), null);
                                            }
                                            AddrecordToList = true;
                                } else{

                                         AddrecordToList = false;
                                         cresponse.add(API_Auditlog_ResponseHelper.create_Response('', ObjectApiNameRelatedErrorMessage.get(jsonkey)));
                                         break;
                                }
                            }
                            system.debug('sObj--' + sObj);
                            system.debug('AddrecordToList--' + AddrecordToList);
                            if (!sobjectRec.contains(sObj) && AddrecordToList == true){
                                sobjectRec.add(sObj);
                            }
                        }
                    }
                    system.debug('sobjectRec--' + sobjectRec);
                    system.debug('sobjectRec--' + sobjectRec.size());
    
                } else{
                    cresponse.add(API_Auditlog_ResponseHelper.create_Response('', 'Invaild systemId'));
                }
            } else{
                cresponse.add(API_Auditlog_ResponseHelper.create_Response('', 'systemId Is Mandatory'));
                system.debug('systemId Is Mandatory');
            }
        }
        Taskwrapperrec.sobjectlistto_upsert = sobjectRec;
        Taskwrapperrec.CRresponse = cresponse;
        Taskwrapperrec.UpsertRelated_To=fieldtoken;
    
        return Taskwrapperrec;
    }

    Public static Map<string,Id> GetUserDetails(){

        Map<string,Id> UseremailId=new Map<string,Id>();
        List<user> userlist=[Select Id,email from User Where IsActive=true];

        if(!userlist.isEmpty()){
            for(User u:userlist){
                UseremailId.put(u.Email,u.Id);
            }
        }

        return UseremailId;
    }



}


/*{
    "StatusCode": "200",
    "Status": "Success",
    "Sf_auditId": "a0RBl000000StSzMAK",
    "NoofRecordSuccessed": 1,
    "NoofRecordFailed": 0,
    "Message": "",
    "errorMessage": "",
    "Activity_status": [
        {
            "SF_RecId": "001Bl00000EIAqUIAX",
            "Message": "ACCOUNT CREATED SUCCESSFULLY"
        }
    ]
}*/