@isTest(SeeAllData=true)
public class API_Webservice_UrlmappingTest {
    
    @isTest
    public static void doPostSobjectTest() {
        
        Map<String, Object> jsonData = new Map<String, Object>{
            'systemId' => 'ACSD-003',
                'sobjectarray' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'customer_id' => '52953467676',
                            'external_id' => '52953467676',
                            'phone' => '4876787974',
                            'name' => '5295845343676',
                            'email' => '',
                            'source' => 'App',
                            'status' => 'OTP VERIFIED SUCCESSFULLY',
                            'product_family' => '',
                            'customer_type' => 'Partner'
                            }
                }
        };
            Map<String, Object> jsonData1 = new Map<String, Object>{
                'systemId' => 'ACSD-004',
                    'sobjectarray' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'name' => '52953467676',
                                'close_date' => '2024-01-31',
                                'stage' => 'EMPLOYMENT DETAILS SCREEN',
                                'sub_stage' => 'Employment Details Completed',
                                'type' => 'Education Loan Application',
                                'source' => 'App',
                                'product_family' => 'Education Loan',
                                'external_id' => '5144652424038600',
                                'customer_sf_id' => '001Bl00000EIve6IAD',
                                'opportunity_owner_email_id' => 'vishal.tiwari@northernarc.com'
                                }
                    }
            };
                List<API_Calling_System_Details__c> newacsdlist = new List<API_Calling_System_Details__c>();
            List<API_Calling_System_Details__c> existingacsdlist = [SELECT Id,Name,OwnerId,System_Mode__c,System_Name__c,Target_Object__c,Upsert_Related_To__c FROM API_Calling_System_Details__c];
        for(API_Calling_System_Details__c acsd : existingacsdlist){
            API_Calling_System_Details__c testacsd = acsd.clone();
            newacsdlist.add(testacsd);
        }
        insert newacsdlist;       
        
        API_Field_Processing_Detail__c afpd = new API_Field_Processing_Detail__c();
        afpd.API_Calling_System_Details__c = newacsdlist[2].id;
        insert afpd;
        
        String requestBody = JSON.serialize(jsonData);
        String requestBody1 = JSON.serialize(jsonData1);
        RestRequest mockRequest = new RestRequest();
        RestResponse mockResponse = new RestResponse();
        mockRequest.requestURI = '/services/apexrest/Create_Sobject/ACSD-003';
        mockRequest.httpMethod = 'PUT';
        mockRequest.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = mockRequest;
        RestContext.response = mockResponse; 
        API_Webservice_Urlmapping.doPostSobject();
        API_WebserviceHelper.createResponse(requestBody,'ACTIVITY CREATED SUCCESSFULLY','ACTIVITY UPDATED SUCCESSFULLY');
        
        API_WebserviceHelper.createResponse(requestBody1,'ACTIVITY CREATED SUCCESSFULLY','ACTIVITY UPDATED SUCCESSFULLY');
        API_Auditlog_ResponseHelper.systemid_Related_Response_Helper(requestBody1);
        API_WebserviceHelper.upsert_activity(jsonData1);
        
    }
}