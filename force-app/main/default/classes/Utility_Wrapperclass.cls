public with sharing class Utility_Wrapperclass {
    public Utility_Wrapperclass() {

    }
 
    Public class ApiDmlandResponseList{
        Public List<SObject> sobjectlistto_upsert{get;set;}
        Public List<Record_Response> CRresponse{get;set;}
        Public Schema.SObjectField UpsertRelated_To{get;set;}
    }

    Public class Record_Response{
        Public string SF_RecId{get;set;}
        Public string Message{get;set;}
    }

    Public class AuditWrapper{

        Public string  status{get;set;}
        Public string  statuscode{get;set;}
        Public string  Sf_auditId{get;set;}
        Public string  Message{get;set;}
        Public Integer NoofRecordSuccessed{get;set;}
        Public Integer NoofRecordFailed{get;set;}
    }
    
    Public class ApexResponse_Wrapper{
        @AuraEnabled
        Public List<SObject> ObjectList{get;set;}
        @AuraEnabled
        Public String Responsemessage{get;set;}
        @AuraEnabled
        Public Boolean isSuccess{get;set;}
    }
    
      Public class audit_wrapper{
        Public String status;
        public String ResponseBody;
        public string RequestBody;
        public string processingDMLData;

    }

}