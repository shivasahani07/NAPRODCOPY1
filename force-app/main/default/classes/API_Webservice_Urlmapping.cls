@RestResource(urlMapping='/Create_Sobject/*')
global without sharing class API_Webservice_Urlmapping{
global class Response extends API_WebserviceResponse{
    public Response(){
    }
}

@HttpPost
global static Response doPostSobject(){

    Response res = new Response();
    try{
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString' + requestString);

        res = API_Auditlog_ResponseHelper.systemid_Related_Response_Helper(requestString);

    } catch (exception e){
        System.debug(' --- Error Msg ' + e.getMessage());
        System.debug(' --- Error LineNo ' + e.getLineNumber());
    }
    return res;
}

}

/*{
    "systemId": "ACSD-003",
    "sobjectarray": [
        {
            "customer_id": "52953467676",
            "external_id": "52953467676",
            "phone": "4876787974",
            "name": "5295845343676",
            "email": "",
            "source": "App",
            "status": "OTP VERIFIED SUCCESSFULLY",
            "product_family": "",
            "customer_type": "Partner"
        }
    ]
}*/