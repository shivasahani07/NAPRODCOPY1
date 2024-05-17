public class WelcomeLetterController {
    public static Financial_Account__c fa_Record{get;set;}
    public static List<Receivable__c> receivableList{get;set;}
    public static date installment_date{get;set;}
    public static Contact contact_details{get;set;}
    public WelcomeLetterController(ApexPages.StandardController ctrl){
        // if(ctrl.getId()!=null){
        // system.debug('ID === >'+ctrl.getId());
        system.debug('ctrl::'+ctrl);
        system.debug('ctrl.getId()::'+ctrl.getId());
        system.debug('inside the construction');
        Id financialAccountId = ctrl.getId();
        
        getFinancialDetails(financialAccountId);
        //}
    }
    
    public static void getFinancialDetails(Id financialAccountId){
        system.debug('financialAccountId::'+financialAccountId);
        fa_Record = [SELECT Id,Name,Sanctioned_Amount__c,Account_Name__r.Phone,
                     Sanction_Date__c,Tenuer__c,EMI_Amount__c,Account_Name__c,LOS_Application_ID__c
                     From Financial_Account__c 
                     Where Id =: financialAccountId];
        Id recordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId();
        receivableList = [SELECT Id,Series__c,Intrest_Amount__c,Amount__c,
                          Receivable_Date__c,Principal_Amount__c,Principal_Outstanding__c 
                          From Receivable__c 
                          WHERE Financial_Account__c =: financialAccountId 
                          and RecordTypeId =: recordTypeId];
        
        contact_details = [SELECT Id,MailingStreet,MailingCity,
                           MailingState,MailingPostalCode,MailingCountry,Name
                           From Contact 
                           where accountId =: fa_Record.Account_Name__c];
        installment_date = receivableList.size()>0 ?receivableList[0].Receivable_Date__c:null;
    }
    
    @AuraEnabled
    public static string generateWelcomeletterPDF(String recordId,String taskId){
        system.debug('recordId == >'+recordId);
        List<Attachment> attachList = new List<Attachment>();
        blob pdfBody;
        try{
            
            List<Receivable__c> ReceivableRecList = new List<Receivable__c>();
            Id recordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId();
            ReceivableRecList = [SELECT Id From Receivable__c 
                                 WHERE Financial_Account__c =: recordId and RecordTypeId =: recordTypeId];
            
            Document_Metadata__c docMetaRec = [select id,Document_Name__c from Document_Metadata__c where Document_Name__c='Welcome Letter' limit 1];
            
            Id DocumentHandlerId = [Select Id From Document_Handler__C where Document_Metadata__C =: docMetaRec.Id and Task_Id__C =:taskId].Id;
            
            PageReference pdfPage = Page.WelcomeLetterTemplate;
            pdfPage.getParameters().put('id',recordId);
            pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class'));
            
            lwc_Handledocuments_Controller.uploadFile(EncodingUtil.base64Encode(pdfPage.getContentAsPDF()),'Welcome Letter.pdf',DocumentHandlerId,taskId);
            
        }catch(Exception e){
            system.debug('Error == >'+e.getMessage()+'  && Error line == >'+e.getLineNumber());
        }
        return null;
    }
}