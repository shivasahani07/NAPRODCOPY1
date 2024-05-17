@isTest
global  class PIIDataCalloutMock implements HttpCalloutMock{

    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{"status": "SUCCESS", "content": {"name": "Lavkush","mobile": "+919834890728","email": "bharatkedia888@gmail.com"} }');
        return res;
    }
    
}