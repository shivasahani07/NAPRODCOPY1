global virtual class WS_Response {
    global String status; 
    global String errorMessage;
    global String successMessage;
    global String statusCode;
    
    global WS_Response(){
        status          = 'Success';//Constants.WS_SUCCESS_STATUS;
        statusCode		= '200';//Constants.WS_SUCCESS_CODE;
        errorMessage='';
        successMessage='';    
    }
}