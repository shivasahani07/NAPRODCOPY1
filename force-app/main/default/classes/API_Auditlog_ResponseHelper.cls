public with sharing class API_Auditlog_ResponseHelper {
    public API_Auditlog_ResponseHelper() {

    }

    //Audit Log Creation&Updation on Each Request
    Public static Utility_Wrapperclass.AuditWrapper create_AuditLog(string Sf_auditId,string StatusCode,string Status,string Processed,string Request,string response,Integer NoofRecordProcessed,Integer NoofRecordFailed,String Message){

        Utility_Wrapperclass.AuditWrapper auditInstance=new Utility_Wrapperclass.AuditWrapper();

        API_Callout_Audit__c ACA=new API_Callout_Audit__c();
        ACA.Id=Sf_auditId;
        ACA.Status_Code__c=StatusCode;
        ACA.Status__c=Status;
        ACA.Processed__c=Processed;
        ACA.Request__c=Request;
        ACA.Response__c=response;
        ACA.NoofRecordFailed__c=NoofRecordFailed;
        ACA.NoofRecordSuccessed__c=NoofRecordProcessed;

        Upsert ACA;

        auditInstance.status=ACA.Status__c;auditInstance.statuscode=ACA.Status_Code__c;auditInstance.Sf_auditId=ACA.Id;
        auditInstance.Message=Message;auditInstance.NoofRecordSuccessed=NoofRecordProcessed;auditInstance.NoofRecordFailed=NoofRecordFailed;

        System.debug('auditInstance--'+auditInstance);
        
        return auditInstance;

    }
     
    //Response For Each API Instance
    Public static Utility_Wrapperclass.Record_Response create_Response(String SF_RecId,String Message){

        Utility_Wrapperclass.Record_Response ResponseValue=new Utility_Wrapperclass.Record_Response();

        ResponseValue.SF_RecId=SF_RecId;
        ResponseValue.Message=Message;

        return ResponseValue;
    }

    //Common method to Create Response
    Public static API_WebserviceHelper.Response BulkcreateResponse(string Sf_auditId,string StatusCode,string Status,string Processed,Integer NoofRecordProcessed,Integer NoofRecordFailed,String Message){

        API_WebserviceHelper.Response res=new API_WebserviceHelper.Response();
        res.Message=Message;
        res.Status=Status;
        res.StatusCode=StatusCode;
        res.NoofRecordSuccessed=NoofRecordProcessed;
        res.NoofRecordFailed=NoofRecordFailed;
        res.Sf_auditId=Sf_auditId;

        return res;
    }

    //Activity Response Method
    Public static API_Webservice_Urlmapping.Response systemid_Related_Response_Helper(String Requeststring){

        API_Webservice_Urlmapping.Response res=new API_Webservice_Urlmapping.Response();

        API_WebserviceHelper.Response webserviceResponse=new API_WebserviceHelper.Response();

        Map<string,object> JsonBody=(Map<string,object>)JSON.deserializeUntyped(Requeststring);

        if(string.valueOf(JsonBody.get('systemId'))=='ACSD-001'){
            webserviceResponse = API_WebserviceHelper.createResponse(Requeststring,Constants.API_ACTIVITY_SUCCESS,Constants.API_UPDATE_ACTIVITY_SUCCESS);
        }else if(string.valueOf(JsonBody.get('systemId'))=='ACSD-002'){
            webserviceResponse = API_WebserviceHelper.createResponse(Requeststring,Constants.API_CASE_SUCCESS,Constants.API_UPDATE_CASE_SUCCESS);
        }else if(string.valueOf(JsonBody.get('systemId'))=='ACSD-003'){
            webserviceResponse = API_WebserviceHelper.createResponse(Requeststring,'ACCOUNT CREATED SUCCESSFULLY','ACCOUNT UPDATED SUCCESSFULLY');
        }else if(string.valueOf(JsonBody.get('systemId'))=='ACSD-004'){
            webserviceResponse = API_WebserviceHelper.createResponse(Requeststring,'OPPORTUNITY CREATED SUCCESSFULLY','OPPORTUNITY UPDATED SUCCESSFULLY');
        }else if(string.valueOf(JsonBody.get('systemId'))=='ACSD-005'){
            webserviceResponse = API_WebserviceHelper.createResponse(Requeststring,Constants.API_ACTIVITY_SUCCESS,Constants.API_UPDATE_ACTIVITY_SUCCESS);
        }else{
            webserviceResponse = API_WebserviceHelper.createResponse(Requeststring,'',''); 
        }
        res.Message=webserviceResponse.Message;
        res.Status=webserviceResponse.Status;
        res.StatusCode=webserviceResponse.StatusCode;
        res.NoofRecordSuccessed=webserviceResponse.NoofRecordSuccessed;
        res.NoofRecordFailed=webserviceResponse.NoofRecordFailed;
        res.Sf_auditId=webserviceResponse.Sf_auditId;
        res.Activity_status=webserviceResponse.Activity_status;

        return res;
    }

    //Case Response Method
    // Public static API_Webservice_Urlmapping.Response UpsertCaseBulkcreateResponse(String Requeststring){

    //     API_Webservice_Urlmapping.Response res=new API_Webservice_Urlmapping.Response();

    //     API_WebserviceHelper.Response webserviceResponse = API_WebserviceHelper.createResponse(Requeststring,Constants.API_CASE_SUCCESS,Constants.API_UPDATE_CASE_SUCCESS);
    //     res.Message=webserviceResponse.Message;
    //     res.Status=webserviceResponse.Status;
    //     res.StatusCode=webserviceResponse.StatusCode;
    //     res.NoofRecordSuccessed=webserviceResponse.NoofRecordSuccessed;
    //     res.NoofRecordFailed=webserviceResponse.NoofRecordFailed;
    //     res.Sf_auditId=webserviceResponse.Sf_auditId;
    //     res.Activity_status=webserviceResponse.Activity_status;

    //     return res;
    // }


}