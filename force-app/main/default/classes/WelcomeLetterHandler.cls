public without sharing class WelcomeLetterHandler {
    
    public Static AuditResponseWrapperClass CallRepymentScheduleAPI(Id taskId){
        Id recordTypeId 	= Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId();
        String auditResult 	= Label.AuditAPIFailedStatus;
        
        Id opportunity_Id 						= [SELECT Id,WhatId From Task Where Id =: taskId].WhatId;
        Financial_Account__c financial_Account 	= [SELECT Id,Tenuer__c,Name,
                                                   (Select Id 
                                                    From Receivables__r 
                                                    WHERE RecordTypeId =:recordTypeId)
                                                   From Financial_Account__c 
                                                   Where Opportunity__c =:opportunity_Id];
        
        AuditResponseWrapperClass auditResponse = new AuditResponseWrapperClass();
        auditResponse.auditRec 					= new API_Callout_Audit__c();
        if(financial_Account.Receivables__r.isEmpty()){
            auditResponse = QuickBrickAPI.sendGetRequest(financial_Account);
        }else{
            auditResponse.auditRec.Response__c = 'Schedule already initiated.';
            auditResponse.auditRec.API_Status__c = Label.AuditAPIStatus;
        }
        return auditResponse;
    }
    
    public static AuditResponseWrapperClass WelcomeLetterGenerationFlow(Id taskId){
        Id recordTypeId 	= Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId();
        String auditResult 	= Label.AuditAPIFailedStatus;
        
        Id opportunity_Id 						= [SELECT Id,WhatId From Task Where Id =: taskId].WhatId;
        Financial_Account__c financial_Account 	= [SELECT Id,Tenuer__c,Name
                                                   From Financial_Account__c 
                                                   Where Opportunity__c =:opportunity_Id];
        return WelcomeLetterController.generateWelcomeletterPDF(financial_Account.Id,taskId);
    }
}