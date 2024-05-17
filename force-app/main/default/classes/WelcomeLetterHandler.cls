public class WelcomeLetterHandler {
    
    public static AuditResponseWrapperClass WelcomeLetterGenerationFlow(Id taskId){
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
            try{
                auditResponse = QuickBrickAPI.sendGetRequest(financial_Account);
                createPDFFile(financial_Account.Id,taskId);
            }catch(Exception e){
                system.debug('Error::'+e.getStackTraceString());
            }
        }else{
            auditResponse.auditRec.Response__c = 'Schedule already initiated.';
            auditResponse.auditRec.API_Status__c = Label.AuditAPIStatus;
        }
        
        
        return auditResponse;
    }
    
    //@future(callout=true)
    Public static void createPDFFile(Id financial_Account_Id,Id taskId){
        WelcomeLetterController.generateWelcomeletterPDF(financial_Account_Id,taskId);
    }
    
}