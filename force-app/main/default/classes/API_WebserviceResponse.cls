global virtual class API_WebserviceResponse {
    
    global string  Sf_auditId;
    global String  StatusCode;
    global String  Status; 
    global String  Message;
    global Integer NoofRecordSuccessed;
    global Integer NoofRecordFailed;
    global String errorMessage;
    global List<Utility_Wrapperclass.Record_Response> Activity_status;

    
    global API_WebserviceResponse(){
        Sf_auditId      ='';
        StatusCode		= '200';//Constants.WS_SUCCESS_CODE;
        Status          = 'Success';//Constants.WS_SUCCESS_STATUS;
        Message         ='';
        NoofRecordSuccessed =0;
        NoofRecordFailed =0;
        errorMessage = '';
       
    }

}