public class EmailService {
    
    public static AuditResponseWrapperClass ExecuteEmailServices(Id taskId,String parentDocId){
        AuditResponseWrapperClass auditResponse = new AuditResponseWrapperClass();
        List<String> toAddresses = new List<String>();
        Task taskDetail = [SELECT Id,WhatId,Process_Path_Task_Detail__r.Communication_Template__r.Email_To__c,Process_Path_Task_Detail__r.Communication_Template__r.Email_From__c,
                           Process_Path_Task_Detail__r.Communication_Template__r.Email_Service__c,Process_Path_Task_Detail__r.Communication_Template__r.Template_Body_Query__c,
                           Process_Path_Task_Detail__r.Communication_Template__r.Channel_Type__c,Process_Path_Task_Detail__r.Communication_Template__r.Is_Active__c,
                           Process_Path_Task_Detail__r.Communication_Template__r.Subject__c,Process_Path_Task_Detail__r.Communication_Template__r.Template_Body__c,
                           Process_Path_Task_Detail__r.Communication_Template__c,Process_Path_Task_Detail__r.Communication_Template__r.Attachment_Query__c,
                           Process_Path_Deviation_Initiated_Task_Id__c,Process_Path_Task_Detail__r.Communication_Template__r.CC_Addresses__c
                           From Task 
                           WHERE Id =: taskId];
        system.debug('taskDetail::'+taskDetail);
        
        if(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_Service__c != null){
            if(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_Service__c == Constants.SALESFORCE){
                // Integrate Salesforce Email Service
                auditResponse = EmailHandler.SendEmailWithSalesforce(taskDetail,parentDocId);
            }else if(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_Service__c == Constants.NIMBUS){
                // Integrate Nimbus API
                //auditResponse = EmailHandler.SendEmailWithNimbus();
            }
        }
        
        return auditResponse;
    }
    
    public static AuditResponseWrapperClass SendEmailFunction(List<String> toAddress,String Subject,String templateBody,String LinkedEntityId,String fromAddress,String CCAddresses){
        AuditResponseWrapperClass auditResponse = new AuditResponseWrapperClass();
        auditResponse.auditRec = new API_Callout_Audit__c();
        try {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress orgWideEmail = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName =: fromAddress LIMIT 1];
        if(LinkedEntityId != ''){
            List<ContentVersion> files = getFirstFileOnOpportunity(LinkedEntityId);
            ContentVersion file = files[0];
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(file.Title+'.'+file.FileExtension);
            attachment.setBody(file.VersionData);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            
        }
        
        
        mail.setToAddresses(toAddress);
        mail.setSubject(Subject);
        mail.setHTMLBody(templateBody);
        mail.setOrgWideEmailAddressId(orgWideEmail.Id);
        mail.setCcAddresses(new String[]{CCAddresses});
        
            Messaging.SendEmailResult[] results = Messaging.sendEmail(
                new Messaging.SingleEmailMessage[] { mail });
            system.debug('results::'+results);
            for (Messaging.SendEmailResult res : results) {
                system.debug('res::'+res);
                if (res.isSuccess()) {
                    System.debug('Email sent successfully');
                    auditResponse.auditRec.API_Status__c = Label.AuditAPIStatus;
                    auditResponse.auditRec.Request__c = 'Subject :' + Subject+','+'To address: ' + mail.getToAddresses() + ','+'From address: ' + mail.getReplyTo() + ',' + 'Template Body : ' + templateBody;
                    auditResponse.auditRec.Response__c = 'Email sent successfully';
                    auditResponse.auditRec.Status_Code__c = '200';
                }
                else {
                    System.debug('The following errors occurred: ' + res.getErrors());
                    for(Database.Error err : res.getErrors()) {
                        auditResponse.auditRec.API_Status__c = Label.AuditAPIFailedStatus;
                        auditResponse.auditRec.Response__c = err.getMessage();
                        auditResponse.auditRec.Status_Code__c = String.valueOf(err.getStatusCode());
                    }
                    
                }
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            auditResponse.auditRec.API_Status__c = Label.AuditAPIFailedStatus;
            auditResponse.auditRec.Response__c = e.getMessage();
            auditResponse.auditRec.Status_Code__c = '404';
        }
        
        return auditResponse;
    }
    
    public static List<ContentVersion> getFirstFileOnOpportunity(Id LinkedEntityId) {
        List<ContentVersion> firstFileList = new List<ContentVersion>();
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink link : [SELECT ContentDocumentId 
                                         FROM ContentDocumentLink 
                                         WHERE LinkedEntityId = :LinkedEntityId]) {
                                             contentDocumentIds.add(link.ContentDocumentId);
                                         }
        if (!contentDocumentIds.isEmpty()) {
            firstFileList = [SELECT Id, Title, VersionNumber, ContentDocumentId,VersionData,FileExtension  
                             FROM ContentVersion 
                             WHERE ContentDocumentId IN :contentDocumentIds 
                             ORDER BY CreatedDate ASC LIMIT 1];
        }
        system.debug('firstFileList::'+firstFileList);
        return firstFileList;
    }
    
}