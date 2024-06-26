public class ConvertJSONBodytoObject {
    
    @InvocableMethod(label ='Convert JSON Body to Object')
    Public static List<wrapper_json> ConvertJsonBody_to_Object(List<string> jsonBody){
        Map<string,object> jsonobj=(Map<string,object>)JSON.deserializeUntyped(jsonBody[0]);
        system.debug('jsonobj'+jsonobj);
        List<String> reqbody_Label= String.valueOf(System.Label.JSON_Request_body_Label).split(',');
        List<wrapper_json> wjlist=new List<wrapper_json>();
        if(reqbody_Label.size()>0){ 
            wrapper_json wjrec=new wrapper_json();
            wjrec.verified_phonenumber=string.valueOf(jsonobj.get(reqbody_Label[0]));
            wjrec.pincode=Integer.valueOf(string.valueOf(jsonobj.get(reqbody_Label[1])));  
            wjlist.add(wjrec);
        }
        return wjlist;
    }
    
    public class wrapper_json {
        @InvocableVariable
        Public String verified_phonenumber;
        
        @InvocableVariable
        Public Integer pincode;
    }
    
}