public without sharing class DocumentCourierDetailController {
    // @AuraEnabled(cacheable=true)
    @AuraEnabled
    public static wrapperforDocuments getDocumentCourierDetails(task inp_Task) {
        Account userAccDet;
        string userAccId;
        userAccDet = [SELECT Id, Name,(SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,AccountId FROM Contacts WHERE IsActive__c =true order by createddate desc limit 1) FROM Account WHERE Id =:[SELECT Individual.AccountId__c FROM User WHERE Id = :userinfo.getUserid()].Individual.AccountId__c];
        userAccId=userAccDet.Id;
        string v_query='';
        string v_currentLogin_userId=userinfo.getUserid();
        if(inp_Task!=null){
            System.debug('inp_Task'+inp_Task);
            string v_taskId= '%'+inp_Task.Id+'%';
            v_query = ' AND Document_Sharing_Task_Ids__c LIKE :v_taskId';
            system.debug('v_query'+v_query);
            system.debug('v_taskId'+v_taskId);
        }
        
        list<Document_Handler__c> documenLst = Database.query('SELECT DMS_ID__c,Document_Categories__c,Document_Metadata__c,Document_Name__c,Document_Uploaded__c,Id,Name,Opportunity__c,Physical_Document_Mandatory__c,Physical_Document_Received__c,Review_Required__c,Shipping_Partner__c,Status__c,Task_Id__c,Tracking_Number__c,Transfer_to__c,Transfer_to__r.Name,Upload_Mandatory__c,Document_Metadata__r.Document_Category__c,Document_Metadata__r.Document_Id_Name__c,Document_Id_Value__c,Document_Metadata__r.Document_Name__c,Document_Handler__c.Extended_SObject_RecordId__c,Current_Task_ID__c FROM Document_Handler__c WHERE Status__c =\'Dispatched\' AND Transfer_to__c =:userAccId AND Transfer_to__c !=null AND Tracking_Number__c !=null' + v_query);
        System.debug('documenLst'+documenLst);
        System.debug('documenLst Size'+documenLst.size());
        wrapperforDocuments prepare = new wrapperforDocuments();
        prepare.documents =documenLst;
        list<Paybale__c> payableLIst= new list<Paybale__c>();
        list<MODT_Details__c> modtLIst= new list<MODT_Details__c>();
        for(Document_Handler__c dc:prepare.documents){
            if(!String.isBlank(dc.Extended_SObject_RecordId__c) || !String.isEmpty(dc.Extended_SObject_RecordId__c)){
                string ObjectApiName=Id.valueOf(dc.Extended_SObject_RecordId__c).getSObjectType().getDescribe().getName();
                if(ObjectApiName=='Paybale__c'){
                    payableLIst.add(getRelatedPayables(dc.Extended_SObject_RecordId__c));
                    
                }else if(ObjectApiName=='MODT_Details__c'){
                    modtLIst.add(getRelatedMODTs(dc.Extended_SObject_RecordId__c));
                    if(modtLIst !=null){
                        prepare.modtlist=modtLIst;
                    }
                }
            }else if(dc.Document_Name__c !='Cheque'&& !String.isBlank(dc.Extended_SObject_RecordId__c) || !String.isEmpty(dc.Extended_SObject_RecordId__c)){
                prepare.modtlist.add(getRelatedMODTs(dc.Extended_SObject_RecordId__c));
            }
        }
        if(payableLIst !=null){
            prepare.paybles=payableLIst;
        }
        return prepare;
    }
    
    @AuraEnabled
    public static String markAsReceived(List<String> documentIds) {
        System.debug('documentIds===>'+documentIds);
        User userDetail = [SELECT Individual.AccountId__c FROM User WHERE Id = :userinfo.getUserid()];
        List<Document_Handler__c> docCourierListToUpdate = new List<Document_Handler__c>();
        List<Document_Handler__c> documentsToUpdate = [SELECT Id,Status__c,Tracking_Number__c,Transfer_to__c,To_Be_Received_By__c FROM Document_Handler__c WHERE Id IN :documentIds];
        System.debug('documentsToUpdate==>'+documentsToUpdate);
        for(Document_Handler__c doc : documentsToUpdate) {
            doc.Status__c = 'Received';
            if(userDetail.Individual.AccountId__c != null){
                doc.Transfer_By__c = userDetail.Individual.AccountId__c;
            }else{
                doc.Transfer_By__c =null;
            }
            doc.Transfer_to__c = null;
            doc.Tracking_Number__c=null;
            doc.To_Be_Received_By__c=null;
            doc.Shipping_Partner__c=null;
            doc.Process_Task_Owner_Assignment_Matrix__c=null;
            docCourierListToUpdate.add(doc);
        }
        if (!docCourierListToUpdate.isEmpty()) {
            update docCourierListToUpdate;
            return 'success';
        }
        return 'error';
    }
    
    @AuraEnabled
    public static wrapperforDocuments docsWithdetails(task inp_Task){
        Account userAccDet = [SELECT Id, Name,(SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,AccountId FROM Contacts WHERE IsActive__c =true order by createddate desc limit 1) FROM Account WHERE Id =:[SELECT Individual.AccountId__c FROM User WHERE Id = :userinfo.getUserid()].Individual.AccountId__c];
        string v_taskId= '%'+inp_Task.Id+'%';
        string userAccId=userAccDet.Id;
        string v_query;
        string v_currentLogin_userId=userinfo.getUserid();
        if(inp_Task!=null){
            System.debug('inp_Task'+inp_Task);
            v_query = ' AND Document_Sharing_Task_Ids__c LIKE :v_taskId';
        }
        
        list<Document_Handler__c> documenLst = Database.query('SELECT DMS_ID__c,Document_Categories__c,Document_Metadata__c,Document_Name__c,Document_Uploaded__c,Id,Name,Opportunity__c,Physical_Document_Mandatory__c,Physical_Document_Received__c,Review_Required__c,Shipping_Partner__c,Status__c,Task_Id__c,Tracking_Number__c,Transfer_to__c,Transfer_to__r.Name,Upload_Mandatory__c,Document_Metadata__r.Document_Category__c,Document_Metadata__r.Document_Id_Name__c,Document_Id_Value__c,Document_Metadata__r.Document_Name__c,Document_Handler__c.Extended_SObject_RecordId__c FROM Document_Handler__c WHERE Status__c =\'To Be Handed Over\' AND Transfer_By__c =:userAccId AND Transfer_By__c !=null' + v_query);
        
        System.debug('documenLst--'+documenLst);
        
        wrapperforDocuments prepare = new wrapperforDocuments();
        prepare.documents =documenLst;
        prepare.paybles = new list<Paybale__c>();
         prepare.modtlist = new list<MODT_Details__c>();
        for(Document_Handler__c dc:prepare.documents){
            system.debug('dc.Name::'+dc.Document_Metadata__r.Document_Name__c);
            system.debug('dc.Extended_SObject_RecordId__c::'+dc.Extended_SObject_RecordId__c);
            if(dc.Document_Name__c=='Cheque'&& !String.isBlank(dc.Extended_SObject_RecordId__c) || !String.isEmpty(dc.Extended_SObject_RecordId__c)){
                string ObjectApiName=Id.valueOf(dc.Extended_SObject_RecordId__c).getSObjectType().getDescribe().getName();
                system.debug('ObjectApiName::'+ObjectApiName);
                if(ObjectApiName=='Paybale__c'){
                    system.debug('dc.Extended_SObject_RecordId__c::'+dc.Extended_SObject_RecordId__c);
                    prepare.paybles.add(getRelatedPayables(dc.Extended_SObject_RecordId__c));
                }else if(ObjectApiName=='MODT_Details__c'){
                    prepare.modtlist.add(getRelatedMODTs(dc.Extended_SObject_RecordId__c));
                }
                
            }else if(dc.Document_Name__c !='Cheque'&& !String.isBlank(dc.Extended_SObject_RecordId__c) || !String.isEmpty(dc.Extended_SObject_RecordId__c)){
                prepare.modtlist.add(getRelatedMODTs(dc.Extended_SObject_RecordId__c));
            }
        }
        return prepare;
        
    }
    Public static Paybale__c getRelatedPayables(String RecordId) {
        
        Paybale__c payableRec = [SELECT Id,Amount__c,Finacial_Entity_Details__c,Financial_Account__c,
                                 Financial_Entity_A_C_Details__c,IsActive__c,Mode__c,Status__c,Task_Id__c,
                                 Name,Finacial_Entity_Details__r.Entity_Type__c,Financial_Entity_A_C_Details__r.Bank_Account_Number__c,
                                 Finacial_Entity_Details__r.Name,CreatedDate,Finacial_Entity_Details__r.Id 
                                 FROM Paybale__c  
                                 WHERE Id = :RecordId];
        system.debug('payableRec::'+payableRec);
        return payableRec;
    }
    
    Public Static MODT_Details__c getRelatedMODTs(String RecordId){
        system.debug('RecordId'+RecordId);
        MODT_Details__c newbss= new MODT_Details__c();
        newbss=[SELECT Id,Date_Of_Execution__c,Financial_Account__c,Mortgager_Name__c,Mortgager_Name__r.Name,Mortgager_Name__r.Id,Name,Place__c,Task_Id__c FROM MODT_Details__c WHERE Id = :RecordId];
        RETURN newbss;
    }
    
    public class wrapperforDocuments{
        @AuraEnabled
        public list<Document_Handler__c> documents;
        @AuraEnabled
        public list<account> recipants;
        @AuraEnabled
        public list<Paybale__c> paybles;
        @AuraEnabled
        public list<MODT_Details__c> modtlist;
    }
    
    
    @AuraEnabled
    public static void updateDocumentRecord(list<Document_Handler__c> docTobeUpdated){
        system.debug('docTobeUpdated---'+docTobeUpdated);
        String userId = UserInfo.getUserId();
        String userName = UserInfo.getName();
        Set<Id> docIdSet = new Set<Id>();
        Map<Id,Document_Handler__c> mapofDocIdByDocDetails = new Map<Id,Document_Handler__c>();
        list<Document_Handler__c> docsLIstTobeUpdated= new list<Document_Handler__c>();
        try {
            if(!docTobeUpdated.isEmpty()){
                for(Document_Handler__c doc : docTobeUpdated){
                    docIdSet.add(doc.Id);
                }
            }
            
            if(!docIdSet.isEmpty()){
                for(Document_Handler__c doc : [select Id,Transfer_By__c,Transfer_to__c from Document_Handler__c where Id in:docIdSet]){
                    mapofDocIdByDocDetails.put(doc.Id,doc);
                }
            }
            for (Document_Handler__c doc : docTobeUpdated) {
                if(doc.Status__c != null){
                    Document_Handler__c updateCommentWithDetails = new Document_Handler__c();
                    
                    updateCommentWithDetails.Status__c = doc.Status__c;
                    String newComment = '<div style="font-weight: bold;">Commented By: ' + userName + '</div>' +
                        '<div style="margin-top: 5px;border:1px grey">Comment: ' + doc.Comment_History__c + '</div>' +
                        '<div style="color: #999999; font-size: 0.8em; margin-top: 5px;">At: ' + Datetime.now().format('yyyy-MM-dd HH:mm:ss') + '</div>';
                    
                    updateCommentWithDetails.Comment_History__c = newComment;
                    updateCommentWithDetails.Id = doc.Id;
                    updateCommentWithDetails.Sub_Status__c=doc.Sub_Status__c;
                    updateCommentWithDetails.Transfer_By__c = mapofDocIdByDocDetails.get(doc.Id).Transfer_to__c;
                    updateCommentWithDetails.Transfer_to__c = null;
                    docsListToBeUpdated.add(updateCommentWithDetails);
                }
                
            }
            if (!docsLIstTobeUpdated.isEmpty()) {
                update docsLIstTobeUpdated;
                
            }
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static task getTaskRecirdbyId(id taskId){
        return [SELECT AccountId,ActivityDate,Address__c,Attribute1__c,
                Attribute2__c,Attribute3__c,Attribute4__c,Commnets__c,
                CompletedDateTime,Contact_Person__c,Current_Attempt_No__c,
                Current_Review_Level__c,DateTime_of_Meeting__c,Default_Owner_Assigned__c,
                Delete_Attempt_No__c,Description,Disposition_Type__c,
                Execution_Depended_Closed_Task_Ids__c,
                External_Id__c,Follow_Up__c,Geo_Location__c,Geo_Location__Latitude__s,
                Geo_Location__Longitude__s,Id,Initiated_Date__c,Initiated_Since__c,
                IsArchived,IsClosed,IsDeleted,IsHighPriority,IsRecurrence,IsReminderSet,
                Is_SLA_Overdued__c,Meeting_Call_Purpose__c,Meeting_Call_status__c,
                Meeting_Date__c,Meeting_Time__c,Mobile__c,Next_Action__c,Overdue_By__c,
                OwnerId,Owner_Spend_Time__c,Parent_Task_Id__c,Previous_Owner__c,Priority,
                Process_Attribute_Details__c,Process_Attribute_Object_Type__c,
                Process_Attribute_Review_Detail__c,Process_Attribute__c,
                Process_Path_Deviation_Ids__c,Process_Path_Deviation_Initiated_Task_Id__c,
                Process_Path_Initiated_Task_Id__c,Process_Path_Merged_Task_Ids__c,
                Process_Path_Task_Detail__c,Process_Share_Document_Task_Ids__c,Process_Task_Detail__c,
                Queue_Allocation_Date_Time__c,Queue_Name__c,Queue_Spend_Time__c,recording_url__c,
                RecordTypeId,RecurrenceActivityId,RecurrenceDayOfMonth,RecurrenceDayOfWeekMask,
                RecurrenceEndDateOnly,RecurrenceInstance,RecurrenceInterval,RecurrenceMonthOfYear,
                RecurrenceRegeneratedType,RecurrenceStartDateOnly,RecurrenceTimeZoneSidKey,
                RecurrenceType,ReminderDateTime,Report_View__c,Reviewer_Assigned_Date_Time__c,
                Reviewer_Spend_Time__c,Review_Record_Id__c,Serialnumber__c,Stage__c,Status,Subject,
                Submitted_By__c,Submitted_User__c,Sub_Disposition_Type__c,SystemModstamp,TaskSubtype,
                Task_Owner__c,Tobe_Completed_In__c,Type,UserId__c,User_Allocated_Date_Time__c,User_Id__c,
                User_Info_Details__c,WhatCount,WhatId,WhoCount,WhoId FROM Task WHERE Id=:taskId];
    }
    
    @AuraEnabled
    public static wrapperforDocuments docsWithdetailsforStorage(task inp_Task){
        Account userAccDet = [SELECT Id, Name,(SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,AccountId FROM Contacts WHERE IsActive__c =true order by createddate desc limit 1) FROM Account WHERE Id =:[SELECT Individual.AccountId__c FROM User WHERE Id = :userinfo.getUserid()].Individual.AccountId__c];
        string v_taskId= '%'+inp_Task.Id+'%';
        string userAccId=userAccDet.Id;
        system.debug('userAccId---'+userAccId);
        string v_query;
        string v_currentLogin_userId=userinfo.getUserid();
        if(inp_Task!=null){
            System.debug('inp_Task'+inp_Task);
            v_query = ' AND Document_Sharing_Task_Ids__c LIKE :v_taskId';
        }
        
        String statusQuery = '\'Document Storage\', \'Physically Stored\'';
        String queryString = 'SELECT DMS_ID__c, Document_Categories__c, Document_Metadata__c, Document_Name__c, Document_Uploaded__c, Id, Name, Opportunity__c, Physical_Document_Mandatory__c, Physical_Document_Received__c, Review_Required__c, Shipping_Partner__c, Status__c, Task_Id__c, Tracking_Number__c, Transfer_to__c, Transfer_to__r.Name, Upload_Mandatory__c, Document_Metadata__r.Document_Category__c, Document_Metadata__r.Document_Id_Name__c, Document_Id_Value__c, Document_Metadata__r.Document_Name__c, Document_Handler__c.Extended_SObject_RecordId__c, File_Barcode__c, Box_Barcode__c, Date_of_storage__c FROM Document_Handler__c WHERE Status__c IN (' + statusQuery + ') AND Transfer_By__c = :userAccId AND Transfer_By__c != null' + v_query;
        List<Document_Handler__c> documenLst = Database.query(queryString);
        //list<Document_Handler__c> documenLst = Database.query('SELECT DMS_ID__c,Document_Categories__c,Document_Metadata__c,Document_Name__c,Document_Uploaded__c,Id,Name,Opportunity__c,Physical_Document_Mandatory__c,Physical_Document_Received__c,Review_Required__c,Shipping_Partner__c,Status__c,Task_Id__c,Tracking_Number__c,Transfer_to__c,Transfer_to__r.Name,Upload_Mandatory__c,Document_Metadata__r.Document_Category__c,Document_Metadata__r.Document_Id_Name__c,Document_Id_Value__c,Document_Metadata__r.Document_Name__c,Document_Handler__c.Extended_SObject_RecordId__c,File_Barcode__c,Box_Barcode__c,Date_of_storage__c FROM Document_Handler__c WHERE Status__c =\'Document Storage\' AND Transfer_By__c =:userAccId AND Transfer_By__c !=null' + v_query);
        System.debug('documenLst--'+documenLst);
        wrapperforDocuments prepare = new wrapperforDocuments();
        prepare.documents =documenLst;
        prepare.paybles = new list<Paybale__c>();
        prepare.modtlist = new List<MODT_Details__c>();
        for(Document_Handler__c dc:prepare.documents){
            system.debug('dc.Name::'+dc.Document_Metadata__r.Document_Name__c);
            system.debug('dc.Extended_SObject_RecordId__c::'+dc.Extended_SObject_RecordId__c);
            if(!String.isBlank(dc.Extended_SObject_RecordId__c) || !String.isEmpty(dc.Extended_SObject_RecordId__c)){
                string ObjectApiName=Id.valueOf(dc.Extended_SObject_RecordId__c).getSObjectType().getDescribe().getName();
                system.debug('ObjectApiName::'+ObjectApiName);
                if(ObjectApiName=='Paybale__c'){
                    system.debug('dc.Extended_SObject_RecordId__c::'+dc.Extended_SObject_RecordId__c);
                    prepare.paybles.add(getRelatedPayables(dc.Extended_SObject_RecordId__c));
                }else if(ObjectApiName=='MODT_Details__c'){
                    prepare.modtlist.add(getRelatedMODTs(dc.Extended_SObject_RecordId__c));
                }
                
            }else if(dc.Document_Name__c !='Cheque'&& !String.isBlank(dc.Extended_SObject_RecordId__c) || !String.isEmpty(dc.Extended_SObject_RecordId__c)){
                prepare.modtlist.add(getRelatedMODTs(dc.Extended_SObject_RecordId__c));
            }
        }
        return prepare;
        
    }
    @AuraEnabled
    public static void updateDocumentStorageDetails(list<document_handler__c> docsToBeupdatesList){
        try{
            system.debug('docsToBeupdatesList ---'+docsToBeupdatesList);
            update docsToBeupdatesList;
        }catch(Exception e){
            system.debug('Error at Line ---'+e.getLinenumber());
            system.debug('Error message ---'+e.getmessage());
        }
    }
    
}