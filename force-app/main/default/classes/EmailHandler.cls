public class EmailHandler {
    
    public static AuditResponseWrapperClass SendEmailWithSalesforce(Task taskDetail,String parentDocId){
        String parentRecId = '';
        String sObjectId = taskDetail.whatId;
        String templateBody = '';
        List<String> ccAddresses = new List<String>();
        List<String> toAddress = new List<String>();
        List<Contact> conDetList = new List<Contact>();
        Account accountDetails = new Account();
        if(taskDetail.Process_Path_Task_Detail__r.Communication_Template__c != null && taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Template_Body__c != null)
            templateBody = (string) taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Template_Body__c;
        if(parentDocId == '' && taskDetail.Process_Path_Deviation_Initiated_Task_Id__c != null){
            if(taskDetail.Process_Path_Deviation_Initiated_Task_Id__c.contains(',')){
                parentRecId = taskDetail.Process_Path_Deviation_Initiated_Task_Id__c.split(',')[0];
            }else{
                parentRecId = taskDetail.Process_Path_Deviation_Initiated_Task_Id__c;
            }
            
        }else{
            parentRecId = parentDocId;
        }
        
        if(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_To__c!=null){
            toAddress.add(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_To__c);
        }
        
        List<Template_Merge_Field__c> templateMergeFields = new List<Template_Merge_Field__c>();
        
        templateMergeFields = [SELECT Id,Merge_Field__c,Value__c 
                               From Template_Merge_Field__c 
                               WHERE Is_Active__c = true 
                               and Communication_Template__c =: taskDetail.Process_Path_Task_Detail__r.Communication_Template__c];
        
        if(parentRecId != '' && taskDetail.Process_Path_Task_Detail__r.Communication_Template__c != null && taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Attachment_Query__c != null){
            String v_query = (string) taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Attachment_Query__c;
            system.debug('v_query::'+v_query);
            sObject r_Parent_RecDetails = Database.query(v_query);
            system.debug('r_Parent_RecDetails::'+r_Parent_RecDetails);
            parentRecId = (String)r_Parent_RecDetails.get('Id');
        }
        
        if(taskDetail.Process_Path_Task_Detail__r.Communication_Template__c != null && taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Template_Body_Query__c != null){
            
            String v_query = (string) taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Template_Body_Query__c;
            sObject r_ObjectRecord = Database.query(v_query);
            system.debug('r_ObjectRecord::'+r_ObjectRecord);
            if(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_To__c!=null){
                 toAddress.add(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_To__c);
            }else{
                conDetList = [SELECT Id,Email From Contact Where AccountId =: (String)r_ObjectRecord.get('Account_Name__c')];
                if(!conDetList.isEmpty()){
                    toAddress.add(conDetList[0].Email);
                } 
            }
            if(r_ObjectRecord.get('Originating_Branch__c') != null){
                accountDetails = [SELECT Id,Email_Id__c From Account Where ID =: (String)r_ObjectRecord.get('Originating_Branch__c')];
                ccAddresses.add(accountDetails.Email_Id__c);  
            }
            
            for(Template_Merge_Field__c tmf : templateMergeFields){
                system.debug('tmf.Merge_Field__c::'+tmf.Merge_Field__c);
                system.debug('String.valueOf(r_ObjectRecord.get(tmf.Value__c))::'+String.valueOf(r_ObjectRecord.get(tmf.Value__c)));
                templateBody = templateBody.replace('{!' + tmf.Merge_Field__c +'}',String.valueOf(r_ObjectRecord.get(tmf.Value__c)));
            }
        }
        
        /*if(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_To__c.contains(',')){
            toAddress = taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_To__c.split(',');
        }else{
            toAddress.add(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_To__c);
        }*/
        //String.valueOf(r_ObjectRecord.get(tmf.Value__c))
        
        if(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.CC_Addresses__c.contains(',')){
            ccAddresses.addAll(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.CC_Addresses__c.split(','));
        }else{
            ccAddresses.add(taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.CC_Addresses__c);
        }
        
        system.debug('ccAddresses::'+ccAddresses);
        system.debug('ccAddresses::'+toAddress);
        system.debug('ccAddresses::'+taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Subject__c);
        system.debug('ccAddresses::'+templateBody);
        system.debug('parentRecId::'+parentRecId);
        system.debug('ccAddresses::'+taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_From__c);
        return EmailService.SendEmailFunction(toAddress,taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Subject__c,
                                              templateBody,parentRecId,taskDetail.Process_Path_Task_Detail__r.Communication_Template__r.Email_From__c,
                                              ccAddresses);
        //return null;
    }
    
    public static void SendEmailWithNimbus(){
        
    }
}