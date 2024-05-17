public without sharing class DispatchController {
    
    // @AuraEnabled method to retrieve Document Courier Details where Status is 'To be couriered'
    //(cacheable=true)
    @AuraEnabled(cacheable=true)
    public static wrapperData getDocumentsToBeCouriered(task inp_Task) {
        wrapperData prepare = new wrapperData();        
        set<id> accIds = new set<id>(); 
        list<Paybale__c> payableLIst= new list<Paybale__c>();
        List<MODT_Details__c> modtlist = new list<MODT_Details__c>();
        prepare.modtlist = new list<MODT_Details__c>();
        Account userAccDet;
        string userAccId;
        
         userAccDet = [SELECT Id, Name,(SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,AccountId FROM Contacts WHERE IsActive__c =true order by createddate desc limit 1) FROM Account WHERE Id =:[SELECT Individual.AccountId__c FROM User WHERE Id = :userinfo.getUserid()].Individual.AccountId__c];
         userAccId=userAccDet.Id;
        
        system.debug('userAccDet::'+userAccDet);
        
        string v_query='';
        if(inp_Task!=null){
            string v_taskId= '%'+inp_Task.Id+'%';
            v_query = ' AND Document_Sharing_Task_Ids__c LIKE :v_taskId';
        }
        
        prepare.documents = Database.query('SELECT DMS_ID__c,Document_Categories__c,Document_Metadata__c,Document_Name__c,Document_Uploaded__c,Id,Name,Opportunity__c,Physical_Document_Mandatory__c,Physical_Document_Received__c,Review_Required__c,Shipping_Partner__c,Status__c,Task_Id__c,Tracking_Number__c,Transfer_to__c,Transfer_to__r.Name,Upload_Mandatory__c,Document_Metadata__r.Document_Category__c,Document_Metadata__r.Document_Id_Name__c,Document_Id_Value__c,Document_Metadata__r.Document_Name__c,Document_Handler__c.Extended_SObject_RecordId__c,Current_Task_ID__c FROM Document_Handler__c WHERE Status__c =\'To Be Dispatched\' AND Transfer_By__c =:userAccId AND Transfer_to__c !=null' + v_query);
        system.debug('prepare.documents::'+prepare.documents);
        system.debug('prepare.documents size::'+prepare.documents.size());
        if(!prepare.documents.isEmpty()){
            for(Document_Handler__c dc:prepare.documents){
                
                if (!accIds.contains(dc.Transfer_to__c))
                {
                    accIds.add(dc.Transfer_to__c);
                    Account ac = new Account();
                    ac.Id = dc.Transfer_to__c;
                    ac.Name = dc.Transfer_to__r.Name;
                    if (prepare.recipants == null) {
                        prepare.recipants = new List<Account>();
                    }
                    prepare.recipants.add(ac);
                    
                    
                }
                if(dc.Document_Name__c=='Cheque'&& !String.isBlank(dc.Extended_SObject_RecordId__c) || !String.isEmpty(dc.Extended_SObject_RecordId__c)){
                    string ObjectApiName=Id.valueOf(dc.Extended_SObject_RecordId__c).getSObjectType().getDescribe().getName();
                    System.debug('ObjectApiName'+ObjectApiName);
                    if(ObjectApiName=='Paybale__c'){
                        system.debug('dc.Extended_SObject_RecordId__c'+dc.Extended_SObject_RecordId__c);
                        payableLIst.add(DocumentCourierDetailController.getRelatedPayables(dc.Extended_SObject_RecordId__c));
                        System.debug('payableLIst'+payableLIst);
                    }else if(ObjectApiName=='MODT_Details__c'){
                        prepare.modtlist.add(DocumentCourierDetailController.getRelatedMODTs(dc.Extended_SObject_RecordId__c));
                        System.debug('modtlist'+prepare.modtlist);
                    }
                    
                }else if(dc.Document_Name__c !='Cheque'&& !String.isBlank(dc.Extended_SObject_RecordId__c) || !String.isEmpty(dc.Extended_SObject_RecordId__c)){
                    prepare.modtlist.add(DocumentCourierDetailController.getRelatedMODTs(dc.Extended_SObject_RecordId__c));
                }
            }
            if(payableLIst.size() >0){
                prepare.paybles=payableLIst;
            }
            
            prepare.contacts=userAccDet.Contacts;
            prepare.shippingpartner=[SELECT Id, Name FROM Account WHERE Type = 'Shipping Partner'];
            //prepare.recipants=[SELECT Id, Name FROM Account WHERE Type = 'Branch' and ID IN: accIds];
            System.debug('prepare.recipants'+prepare.recipants);
            if (prepare.userDetails == null) {
                prepare.userDetails = new List<Account>();
            }
            prepare.userDetails.add(userAccDet);
            //List<Account> relatedAccounts = [SELECT Id, Name,(SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,AccountId FROM Contacts WHERE IsActive__c =true order by createddate desc limit 1) FROM Account WHERE Id IN: accIds].Contacts;
            if (prepare.showRelatedContacsAddress == null) {
                prepare.showRelatedContacsAddress = new List<contact>();
            }
            list<account> relatedAccountsCon=[SELECT Id, Name,(SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,AccountId FROM Contacts WHERE IsActive__c =true order by createddate desc limit 1) FROM Account WHERE Id IN: accIds];
            system.debug('relatedAccountsCon'+relatedAccountsCon);
            for(account ac:relatedAccountsCon){
                system.debug('ac.contacts'+ac.contacts);
                if(!ac.contacts.isEmpty()){
                    prepare.showRelatedContacsAddress.add(ac.contacts);
                }  
            }
            
            prepare.recepiantUsers=[SELECT Id,Name,Individual.AccountId__c FROM user WHERE IsActive=true AND Individual.AccountId__c IN:accIds];
            
        }else{
            prepare.message='No Documents To Be Dispatched';
        }
        
        return prepare;
    }
    
    
    @AuraEnabled
    public static wrapperData getAllreltedodcs(string recipantId) {
        wrapperData prepare = new wrapperData();
        prepare.documents=[SELECT CreatedDate,Description__c,DMS_ID__c,Document_Categories__c,Document_Metadata__c,Document_Metadata__r.Name,Document_Name__c,Document_Uploaded__c,Id,Name,Opportunity__c,Physical_Document_Mandatory__c,Physical_Document_Received__c,Review_Required__c,Shipping_Partner__c,Status__c,Task_Id__c,Tracking_Number__c,Transfer_to__c,Upload_Mandatory__c,Document_Metadata__r.Document_Category__c,Document_Id_Value__c FROM Document_Handler__c WHERE Status__c = 'To Be Dispatched' AND  Transfer_to__c =: recipantId];                
        return prepare;
    }
    
    @AuraEnabled
    public static String updateDocumentCourierDetail(list<String> documentCourierId, String shippingPartnerId, String awbNumber,string userId,String comments,String DepartmentName,String AccountId) {
        System.debug('documentCourierId == >'+documentCourierId);
        System.debug('shippingPartnerId == >'+shippingPartnerId);
        System.debug('awbNumber == >'+awbNumber);
        List<Document_Handler__c> docCourierListToUpdate = new List<Document_Handler__c>();
        try {
            List<Document_Handler__c> docCourierList = [SELECT Id,Transfer_to__c,Transfer_By__c,Comment_History__c FROM Document_Handler__c WHERE Id IN:documentCourierId];
            id PTOAMatrix=[Select Id From Process_Task_Owner_Assignment_Matrix__c Where Queue_Name__c=:DepartmentName AND Account__c=:AccountId].Id;
            id currentUserId=[Select Id From User Where Name=:userId].Id;
            if (docCourierList.size()>0) {
                for(Document_Handler__c doc : docCourierList){
                    Document_Handler__c docRec = new Document_Handler__c();
                    docRec.Id = doc.Id;
                    docRec.Tracking_Number__c =  awbNumber !=null ? awbNumber : null;
                    docRec.Shipping_Partner__c =   shippingPartnerId !=null ? shippingPartnerId : null;
                    docRec.Status__c = 'Dispatched';
                    docRec.To_Be_Received_By__c=currentUserId;
                    docRec.Comment_History__c=comments;
                    docRec.Process_Task_Owner_Assignment_Matrix__c=PTOAMatrix;
                    docCourierListToUpdate.add(docRec);
                }
                if(docCourierListToUpdate.size()>0){
                    update docCourierListToUpdate;
                    System.debug('docCourierListToUpdate === >'+docCourierListToUpdate);
                    if(docCourierListToUpdate.size()>0){
                        return 'SUCCESS';
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error '+e.getMessage()+' && Error Line '+e.getLineNumber());
        }
        return null;
    }
        
    @AuraEnabled(cacheable=true)
    Public static wrapperData getWiredDatforReceiver(string taskId){
        wrapperData prepare = new wrapperData();
        if(!string.isEmpty(taskId)){
            prepare.documents=[SELECT CreatedDate,Description__c,DMS_ID__c,Document_Categories__c,Document_Metadata__c,
                               Document_Name__c,Document_Uploaded__c,Id,Name,Opportunity__c,Physical_Document_Mandatory__c,
                               Physical_Document_Received__c,Review_Required__c,Shipping_Partner__c,Status__c,Task_Id__c,
                               Tracking_Number__c,Transfer_to__c,Upload_Mandatory__c FROM Document_Handler__c WHERE Status__c = 'To Be Dispatched' AND Task_Id__c=:taskId];
            system.debug('inside taskId---'+taskId);
        }else{
            prepare.documents=[SELECT CreatedDate,Description__c,DMS_ID__c,Document_Categories__c,Document_Metadata__c,
                               Document_Name__c,Document_Uploaded__c,Id,Name,Opportunity__c,Physical_Document_Mandatory__c,
                               Physical_Document_Received__c,Review_Required__c,Shipping_Partner__c,Status__c,Task_Id__c,
                               Tracking_Number__c,Transfer_to__c,Upload_Mandatory__c FROM Document_Handler__c WHERE
                               Status__c = 'To Be Dispatched' AND Transfer_to__c =:[SELECT Individual.AccountId__c FROM User WHERE Id = :userinfo.getUserid()].Individual.AccountId__c];                
        }
        return prepare;
    }
    
    @AuraEnabled
    Public static Map<String,List<String>> getGroupNameandGroupMembers(List<Id> AccountIds){
        set<string> GroupId=new set<string>();
        set<string> Queuename=new set<string> ();
        List<Process_Task_Owner_Assignment_Matrix__c> PTOWS=[Select Id,Queue_Name__c From Process_Task_Owner_Assignment_Matrix__c Where Account__c=:AccountIds AND Queue_Name__c!=null];
        if(!PTOWS.isEmpty()){
            for(Process_Task_Owner_Assignment_Matrix__c PT:PTOWS){
                if(PT.Queue_Name__c!=null){
                    Queuename.add(PT.Queue_Name__c); 
                }
            }
        }
        Map<String,string> GroupWithUserId=new Map<String,string>();
        Map<String,string> GroupWithGroupId=new Map<String,string>();
        Map<String,List<String>> QueueWithQueueMembers=new Map<String,List<String>>();
        List<User> userlist=new List<User> ();
        List<GroupMember> GroupMembers=new List<GroupMember>();
        if(!Queuename.isEmpty()){
            List<GroupMember> PublicGroupMemmber =[SELECT GroupId,Id,Group.Name,SystemModstamp,UserOrGroupId FROM GroupMember Where Group.Type='Regular' AND Group.Name=:Queuename];
            if(!PublicGroupMemmber.isEmpty()){
                for (GroupMember GM:PublicGroupMemmber){
                    if(GM.UserOrGroupId!=null && String.valueOf(GM.UserOrGroupId).startswith('005')){
                        GroupWithUserId.put(String.valueOf(GM.UserOrGroupId),GM.Group.Name);
                    }else if(GM.UserOrGroupId!=null && String.valueOf(GM.UserOrGroupId).startswith('00G')){
                        GroupWithGroupId.put(String.valueOf(GM.UserOrGroupId),GM.Group.Name);
                    }
                }
            }
            if(GroupWithUserId!=null){
                userlist = [Select Id,UserName,Name From User Where Id=:GroupWithUserId.keySet()];
            }
            if(GroupWithGroupId!=null){
                GroupMembers = [Select Id,Group.Name From GroupMember Where Id=:GroupWithGroupId.keySet()];
            }
            if(!userlist.isEmpty()){
                for(User u:userlist){
                    if(GroupWithUserId.containskey(u.Id)){
                        if(QueueWithQueueMembers.containskey(GroupWithUserId.get(u.Id))){
                            QueueWithQueueMembers.get(GroupWithUserId.get(u.Id)).add(u.Name);
                        }else{
                            QueueWithQueueMembers.put(GroupWithUserId.get(u.Id),new List<string>{u.Name});
                        }
                    }
                }
            }
            if(!GroupMembers.isEmpty()){
                for(GroupMember GM:GroupMembers){
                    if(GroupWithGroupId.containskey(GM.Id)){
                        if(QueueWithQueueMembers.containskey(GroupWithUserId.get(GM.Id))){
                            QueueWithQueueMembers.get(GroupWithUserId.get(GM.Id)).add(GM.Group.Name);
                        }else{
                            QueueWithQueueMembers.put(GroupWithUserId.get(GM.Id),new List<string>{GM.Group.Name});
                        }
                    }
                }
            }
        }
        
        return QueueWithQueueMembers;
    }
    
    
    
    public class wrapperData{
        @AuraEnabled
        public list<contact> contacts;
        @AuraEnabled
        public list<Document_Handler__c> documents;
        @AuraEnabled
        public list<account> recipants;
        @AuraEnabled
        public list<contact> showRelatedContacsAddress;
        @AuraEnabled
        public list<account> shippingpartner;
        @AuraEnabled
        public list<account> userDetails;
        @AuraEnabled
        public list<Paybale__c> paybles;
        @AuraEnabled
        public list<MODT_Details__c> modtlist;
        @AuraEnabled
        public list<user> recepiantUsers;
        @AuraEnabled
        Public String message;
        @AuraEnabled
        Public Map<String,List<String>> QueueWithQueueMembers;
        
    }
    
}