@isTest
public class TestConvertJSONBodytoObject {
    @isTest
    Public static void TestConvertJSONBodytoObject(){
        List<string> strlist=new List<String> {'{"enterCustomerNumber": "8327771792","enterPinCode": "761101"}'};    
        ConvertJSONBodytoObject.ConvertJsonBody_to_Object(strlist);
    }
}