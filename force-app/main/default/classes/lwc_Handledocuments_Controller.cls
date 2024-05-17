public without sharing class lwc_Handledocuments_Controller {
    
    @AuraEnabled
    Public static wrapperHandler getDocumentHandler(String TaskId,String extendedSobjectRecordid,String documentsharingTaskId){
        system.debug('TaskId'+TaskId);
        system.debug('extendedSobjectRecordid'+extendedSobjectRecordid);
        system.debug('documentsharingTaskId'+documentsharingTaskId);
        wrapperHandler wr = new wrapperHandler();
        Task taskrec=[Select Id,Parent_Task_Id__c,Review_Record_Id__c,ownerId,owner.Name,Status From Task Where Id=:TaskId];
        If(taskrec!=null){
            if(taskrec.Id!=null && taskrec.Parent_Task_Id__c!=null){
                wr = getDHRecordsPADDRecords(taskrec.Parent_Task_Id__c,taskrec.Parent_Task_Id__c,true,taskrec,extendedSobjectRecordid,documentsharingTaskId);
            }else if(taskrec.Id!=null && taskrec.Parent_Task_Id__c==null){
                wr = getDHRecordsPADDRecords(taskrec.Id,taskrec.Id,false,taskrec,extendedSobjectRecordid,documentsharingTaskId);
            }
        }
        return wr;
    }
    
    Public static wrapperHandler getDHRecordsPADDRecords(String TaskId,String parentTaskId,boolean isChildTask,Task gettaskrec,String extendedSobjectRecordid,String documentsharingTaskId){
        wrapperHandler wr                                         =new wrapperHandler();
        try{
            set<Id> DocumentHandlerId                                 =new set<Id>();
            Id CurrentUserId							              =userinfo.getuserid();
            Map<Id,List<Map<string,string>>> DocumentIdRelatedToDHId  =new Map<Id,List<Map<string,string>>>();
            Set<Id> GroupId							                  =new Set<Id>();
            set<string> GrOwnerNames                                  =new set<string>();
            List<task> tasklist                                       =new List<task>();
            List<Document_Handler_History__c> DHHlist                 =new List<Document_Handler_History__c>();
            String documentSharingTkId;
            string ObjectApiName;
            
            if(!String.isBlank(documentsharingTaskId)){
                documentSharingTkId = '%' + String.escapeSingleQuotes(documentsharingTaskId) + '%';
                system.debug('documentSharingTkId'+documentSharingTkId);
            }
            String sobjectQuery='Select Id,Document_Metadata__r.Is_DocumentId_Mandatory__c,Is_Alternate_Document_Uploded__c,Financial_Account__c,MODT_Details__c,Opportunity__c,Exempted__c,Extended_SObject_RecordId__c,Document_SLA__c,Comment_History__c,Process_Attribute_Dcoument_Detail__r.Is_New_Document__c,Process_Attribute_Dcoument_Detail__r.DMS_System__c,Status__c,Physical_Document_Mandatory__c,Description__c,Physical_Document_Received__c,Document_Metadata__c,Upload_Mandatory__c,Task_Id__c,Review_Required__c,Document_Metadata__r.Document_Category__c,Document_Metadata__r.Document_Name__c,Document_Metadata__r.Description__c,Reviewer_Name__c,Process_Attribute_Dcoument_Detail__c, Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c,Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c,Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c,Process_Attribute_Dcoument_Detail__r.Reviewer_Type__c,Document_Id_Value__c,Process_Attribute_Dcoument_Detail__r.Alternate_Document_For_PADC__c,Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c,Account__c,Payable__c From Document_Handler__c Where ';
            
            if(!String.isBlank(extendedSobjectRecordid)){
                ObjectApiName=Id.valueOf(extendedSobjectRecordid).getSObjectType().getDescribe().getName();
                sobjectQuery = sobjectQuery+'Task_Id__c=:parentTaskId AND Extended_SObject_RecordId__c=:extendedSobjectRecordid  ORDER BY Document_Metadata__r.Document_Category__c, Document_Metadata__r.Document_Name__c';
            }else if(!String.isBlank(documentSharingTkId) && !String.isBlank(documentsharingTaskId)){
                sobjectQuery=sobjectQuery+'Process_Attribute_Dcoument_Detail__r.IsVisible__c=true AND Document_Sharing_Task_Ids__c LIKE :documentSharingTkId  ORDER BY Document_Metadata__r.Document_Category__c, Document_Metadata__r.Document_Name__c';
            }else{
                sobjectQuery=sobjectQuery+'Task_Id__c=:parentTaskId  ORDER BY Document_Metadata__r.Document_Category__c, Document_Metadata__r.Document_Name__c';
            }
            System.debug('sobjectQuery--'+sobjectQuery);
            
            List<Document_Handler__c> ListDocumentHandler=Database.query(sobjectQuery);
            system.debug('ListDocumentHandler--'+ListDocumentHandler);
            List<String> l_ExemptedStatus=String.valueOf(System.Label.Document_Handler_Status_Exempted).split(',');
            
            //List<Process_Attribute_Dcoument_Detail__c> PADD=[Select Is_New_Document__c,Id,Multile_DM_Allowed__c,Document_Metadata__c,Physical_Document_Mandatory__c,Pre_Defined__c,Process_Attribute_Details__c,Process_Path_Task_Detail__c,Review_Required__c,Upload_Mandatory__c,Document_Metadata__r.Description__c,Document_Metadata__r.Document_Category__c,Document_Metadata__r.Document_Name__c From Process_Attribute_Dcoument_Detail__c Where isActive__c=true AND Document_Metadata__c NOT IN (Select Document_Metadata__c From Document_Handler__c Where  Task_Id__c=:TaskId AND Status__c NOT IN :l_ExemptedStatus AND (Extended_SObject_RecordId__c=null OR Extended_SObject_RecordId__c=:extendedSobjectRecordid) AND((Process_Attribute_Dcoument_Detail__c != null and Process_Attribute_Dcoument_Detail__r.Multile_DM_Allowed__c=false) OR (Process_Attribute_Dcoument_Detail__r.Multile_DM_Allowed__c=null AND Document_Metadata__r.Multile_DM_Allowed__c=false))) AND Process_Path_Task_Detail__c=:[Select Id,Process_Path_Task_Detail__c From Task Where Id=:TaskId].Process_Path_Task_Detail__c ORDER BY Document_Metadata__r.Document_Category__c, Document_Metadata__r.Document_Name__c];
            List<Process_Attribute_Dcoument_Detail__c> PADD=[Select Is_New_Document__c,Id,Multile_DM_Allowed__c,Document_Metadata__c,Physical_Document_Mandatory__c,Pre_Defined__c,Process_Path_Task_Detail__c,Review_Required__c,Upload_Mandatory__c,Document_Metadata__r.Description__c,Document_Metadata__r.Document_Category__c,Document_Metadata__r.Document_Name__c From Process_Attribute_Dcoument_Detail__c Where isActive__c=true AND Document_Metadata__c NOT IN (Select Document_Metadata__c From Document_Handler__c Where  Task_Id__c=:TaskId AND Status__c NOT IN :l_ExemptedStatus AND (Extended_SObject_RecordId__c=null OR Extended_SObject_RecordId__c=:extendedSobjectRecordid) AND((Process_Attribute_Dcoument_Detail__c != null and Process_Attribute_Dcoument_Detail__r.Multile_DM_Allowed__c=false) OR (Process_Attribute_Dcoument_Detail__r.Multile_DM_Allowed__c=null AND Document_Metadata__r.Multile_DM_Allowed__c=false))) AND Process_Path_Task_Detail__c=:[Select Id,Process_Path_Task_Detail__c From Task Where Id=:TaskId].Process_Path_Task_Detail__c And  Associated_With_Sobject__c includes(:ObjectApiName) ORDER BY Document_Metadata__r.Document_Category__c, Document_Metadata__r.Document_Name__c ];
            
            system.debug('PADD'+PADD);
            
            if(!ListDocumentHandler.isEmpty()){
                for(Document_Handler__c DH:ListDocumentHandler){
                    DocumentHandlerId.add(DH.Id);  
                }
            }
            system.debug('DocumentHandlerId--'+DocumentHandlerId);
            if(!DocumentHandlerId.isEmpty()){
                DHHlist=[Select Id,File_Name__c,DMS_System_Name__c,Document_Path__c,Document_Handler__c,CreatedBy.Name,CreatedDate,Task_Id__c From Document_Handler_History__c Where Document_Handler__c=:DocumentHandlerId];
                system.debug('DHHlist--'+DHHlist);
                if(!DHHlist.isEmpty()){
                    for(Document_Handler_History__c cd:DHHlist){
                        if(DocumentIdRelatedToDHId.containskey(cd.Document_Handler__c)){
                            Map<string,string> titleRelatedToDocumentId=new Map<string,string>{cd.File_Name__c=>cd.Document_Path__c};
                                DocumentIdRelatedToDHId.get(cd.Document_Handler__c).add(titleRelatedToDocumentId);
                        }else{
                            Map<string,string> titleRelatedToDocumentId=new Map<string,string>{cd.File_Name__c=>cd.Document_Path__c};
                                DocumentIdRelatedToDHId.put(cd.Document_Handler__c,new list<Map<string,string>>{titleRelatedToDocumentId});
                        }  
                    }
                }
            }
            
            if(String.isNotBlank(CurrentUserId)){
                List<GroupMember> PublicGroupMemmber =[SELECT GroupId,Id,Group.Name,SystemModstamp,UserOrGroupId FROM GroupMember Where Group.Type='Regular' AND UserOrGroupId=:CurrentUserId];
                if(!PublicGroupMemmber.isEmpty()){
                    for(GroupMember Grm:PublicGroupMemmber){
                        GroupId.add(Grm.GroupId);
                    }
                }
                
                List<GroupMember> QueueMemmber =[SELECT Id, Group.Name, UserOrGroupId FROM GroupMember WHERE Group.Type = 'Queue' AND (UserOrGroupId =:CurrentUserId OR UserOrGroupId IN: GroupId)];
                if(!QueueMemmber.isEmpty()){
                    for(GroupMember Grm:QueueMemmber){
                        GrOwnerNames.add(Grm.Group.Name);
                    }
                }
            } 
            tasklist=[Select Id,Parent_Task_Id__c,Review_Record_Id__c,ownerId,owner.Name,Status,Subject,IsClosed From Task Where Parent_Task_Id__c=:parentTaskId];
            isChildTask = tasklist.isEmpty()?false:true;
            wr.ListDH=ListDocumentHandler;
            wr.PADD=PADD;
            wr.DocumentList=DocumentIdRelatedToDHId;
            wr.currentUserRelated_Groups=GrOwnerNames;
            wr.parent_childtasklist_ifexist = tasklist;
            wr.loginuserId=CurrentUserId;
            wr.ParentTaskRecord=gettaskrec;
            wr.isChildtask=isChildTask;
            wr.DocHandlerHistory=DHHlist;
            
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        return wr;
    }
    
    
    Public class wrapperHandler{
        
        @AuraEnabled
        Public List<Document_Handler__c> ListDH{get;set;}
        @AuraEnabled
        Public List<Process_Attribute_Dcoument_Detail__c> PADD{get;set;}
        @AuraEnabled
        Public Map<Id,List<Map<string,string>>> DocumentList{get;set;}
        @AuraEnabled
        Public set<string> currentUserRelated_Groups{get;set;}
        @AuraEnabled
        Public List<Task> parent_childtasklist_ifexist{get;set;} 
        @AuraEnabled
        Public Id loginuserId{get;set;}
        @AuraEnabled
        Public boolean isChildtask{get;set;}  
        @AuraEnabled
        Public Task ParentTaskRecord{get;set;} 
        @AuraEnabled
        Public List<Document_Handler_History__c> DocHandlerHistory{get;set;} 
        @AuraEnabled
        Public List<Opportunity> RelatedOpportunitytasks{get;set;} 
    }
    
    @AuraEnabled
    Public static List<Document_Handler__c> UpsertDocumentHandler(List<Document_Handler__c> UpsertDHRecords,String operationToPerform){
        set<id> dhrecordIds=new set<id>();
        try{ 
            System.debug('InsertDH---'+UpsertDHRecords);
            System.debug('operationToPerform---'+operationToPerform);
            if(operationToPerform=='Insert/UpsertDocHandler'){
                if(!UpsertDHRecords.IsEmpty()){
                    Upsert UpsertDHRecords;
                }
            } else if(operationToPerform =='UpsertDocHandlerDeviation'){
                upsertDocHandler_CreateDeviation(UpsertDHRecords);
            } else if(operationToPerform == 'AddMoreAlternativeDocuments'){
                UpsertDHRecords = AddAlternativedocuments(UpsertDHRecords);  
            }
            if(!UpsertDHRecords.isEmpty()){
                for(Document_Handler__c dh:UpsertDHRecords){
                    dhrecordIds.add(dh.Id);   
                }
            } 
            UpsertDHRecords=[Select Id,Document_Metadata__r.Is_DocumentId_Mandatory__c,Account__c,Payable__c,MODT_Details__c,Opportunity__c,Is_Alternate_Document_Uploded__c,Document_Id_Value__c,Exempted__c,Extended_SObject_RecordId__c,Document_SLA__c,Comment_History__c,Process_Attribute_Dcoument_Detail__r.Is_New_Document__c,Status__c,Physical_Document_Mandatory__c,Description__c,Physical_Document_Received__c,Document_Metadata__c,Upload_Mandatory__c,Task_Id__c,Review_Required__c,Document_Metadata__r.Document_Category__c,
                             Document_Metadata__r.Document_Name__c,Document_Metadata__r.Description__c,Reviewer_Name__c,Process_Attribute_Dcoument_Detail__c, 
                             Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c,Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c,Process_Attribute_Dcoument_Detail__r.DMS_System__c, 
                             Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c,Process_Attribute_Dcoument_Detail__r.Reviewer_Type__c,Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c From Document_Handler__c Where Id=:dhrecordIds];
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        return  UpsertDHRecords;
    }
    
    Public static List<Document_Handler__c> upsertDocHandler_CreateDeviation(List<Document_Handler__c> DHHandlerRecords){
        set<string> UserApprover                             = new set<string>();
        set<string> GroupApprover                            = new set<string>();
        set<Id> taskId                                       = new set<Id>();
        Map<string,user>  UserApproverNameRelatedUser;
        Map<string,Group> GroupNameRelatedGroup;  
        Map<Id,Task>      IdRelatedToTask;
        Map<Id,Id>        ReviewrecordId_RelatedTaskId;
        List<Task>        sobjectlisttoInsert                = new list<Task>();
        set<Id>           documentHandlerId                  = new set<Id>();
        try{
            if(!DHHandlerRecords.isEmpty()){
                for(Document_Handler__c DH:DHHandlerRecords){
                    DH.Status__c='Submitted for Deviation Approval';
                    if(DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c!=null && DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c=='User'){
                        UserApprover.add(DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c);
                    }else if(DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c!=null && DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c=='Queue'){
                        GroupApprover.add(DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c);
                    }
                    if(DH.Task_Id__c!=null){
                        taskId.add(DH.Task_Id__c);  
                    }
                    if(DH.Id!=null){
                        documentHandlerId.add(DH.Id);
                    }
                }
                System.debug('UserApprover--'+UserApprover);
                System.debug('taskId--'+taskId);
                System.debug('GroupApprover--'+GroupApprover);
                if(!taskId.isEmpty()){
                    IdRelatedToTask=new Map<Id,Task>([Select Id,Process_Attribute__c,Process_Path_Task_Detail__c,Subject From Task Where Id=:taskId]);
                }
                if(!UserApprover.isEmpty()){
                    List<user> userlist=[Select Id,Name From User Where Name=:UserApprover];
                    if(!userlist.isEmpty()){
                        for(User u:userlist){
                            UserApproverNameRelatedUser = new Map<string,user>{u.Name=>u};
                        }
                    }
                }
                if(!GroupApprover.isEmpty()){
                    List<Group> gr=[Select Id,Group.Name From Group Where Group.Type='Queue' AND Group.Name =:GroupApprover];
                    if(!gr.isEmpty()){
                        for(Group g:gr){
                            GroupNameRelatedGroup = new Map<string,Group>{g.Name=>g}; 
                        }
                    }
                }
                if(!documentHandlerId.isEmpty()){
                     List<Task> tasklist=[Select Id,Review_Record_Id__c From Task Where Review_Record_Id__c=:documentHandlerId AND Child_Task_Category__c='Deviation Approval - Record Level'];
                        if(!tasklist.isEmpty()){
                            for(Task tk:tasklist){
                                ReviewrecordId_RelatedTaskId=new Map<Id,Id>{tk.Review_Record_Id__c=>tk.Id};
                            }
                        }
                }
                
                System.debug('UserApproverNameRelatedUser--'+UserApproverNameRelatedUser);
                System.debug('GroupNameRelatedGroup--'+GroupNameRelatedGroup);
               
                for(Document_Handler__c DH:DHHandlerRecords){
                    Task ts=new Task();
                    ts.Id=!ReviewrecordId_RelatedTaskId.isEmpty() ? ReviewrecordId_RelatedTaskId.get(DH.Id):null;
                    ts.Parent_Task_Id__c=DH.Task_Id__c;
                    ts.Subject= !IdRelatedToTask.isEmpty() ? 'Deviation Review - '+ IdRelatedToTask.get(DH.Task_Id__c).subject : 'Deviation Review';
                    ts.Review_Record_Id__c=DH.Id;
                    if(DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c=='User' && UserApproverNameRelatedUser!=null){
                        ts.OwnerId=UserApproverNameRelatedUser.get(DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c).Id;
                    }else if(DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c=='Queue' && GroupNameRelatedGroup!=null){
                        ts.OwnerId = GroupNameRelatedGroup.get(DH.Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c).Id ;  
                    }else{
                        ts.OwnerId=UserInfo.getUserId();
                    }
                    ts.status='Submitted for Deviation Approval';
                    ts.whatId=[Select Id,Subject,whatId From Task Where Id=:DH.Task_Id__c].whatId;
                    ts.Process_Attribute__c=IdRelatedToTask.get(DH.Task_Id__c).Process_Attribute__c;
                    ts.Process_Path_Task_Detail__c=IdRelatedToTask.get(DH.Task_Id__c).Process_Path_Task_Detail__c;
                    ts.Child_Task_Category__c='Deviation Approval - Record Level';
                    sobjectlisttoInsert.add(ts);
                }
                if(!sobjectlisttoInsert.isEmpty()){
                    Upsert sobjectlisttoInsert;
                } 
                if(!DHHandlerRecords.isEmpty()){
                    Upsert DHHandlerRecords;
                } 
                
            }
        }catch(Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return DHHandlerRecords;
    }


    Public static List<Document_Handler__c> AddAlternativedocuments(List<Document_Handler__c> DHHandlerRecords){
            List<Document_Handler__c> UpsertDocumentHandler = new List<Document_Handler__c>(DHHandlerRecords);

          try{
              set<Id> PADDIds=new set<Id>();
              if(!DHHandlerRecords.isEmpty()){
                      for(Document_Handler__c dh:DHHandlerRecords){
                         if(dh.Is_Alternate_Document_Uploded__c && dh.Process_Attribute_Dcoument_Detail__c!=null && dh.Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c==true){
                              PADDIds.add(dh.Process_Attribute_Dcoument_Detail__c);
                         }
                      }
                      if(!PADDIds.isEmpty()){
                          List<Process_Attribute_Dcoument_Detail__c> PADDList_RelatedTo_AlternateDocument=[Select Id,Alternate_Document_For_PADC__c,Document_Metadata__c,Physical_Document_Mandatory__c,
                          Upload_Mandatory__c,Review_Required__c,Document_Metadata__r.Description__c
                          From Process_Attribute_Dcoument_Detail__c Where Alternate_Document_For_PADC__c=:PADDIds];
                          
                          Map<Id,List<Process_Attribute_Dcoument_Detail__c>> AlternateDocuments_RelatedTo_PADD = new Map<Id,List<Process_Attribute_Dcoument_Detail__c>>();
                          if(!PADDList_RelatedTo_AlternateDocument.isEmpty()){
                              for(Process_Attribute_Dcoument_Detail__c PADD:PADDList_RelatedTo_AlternateDocument){
                                  if(AlternateDocuments_RelatedTo_PADD.containsKey(PADD.Alternate_Document_For_PADC__c)){
                                      AlternateDocuments_RelatedTo_PADD.get(PADD.Alternate_Document_For_PADC__c).add(PADD);
                                  }else{
                                     AlternateDocuments_RelatedTo_PADD.put(PADD.Alternate_Document_For_PADC__c,new List<Process_Attribute_Dcoument_Detail__c>{PADD}); 
                                  }
                              }
                          }

                            if(AlternateDocuments_RelatedTo_PADD!=null){
                                   for(Document_Handler__c dhrecord:DHHandlerRecords){
                                         if(dhrecord.Is_Alternate_Document_Uploded__c && dhrecord.Process_Attribute_Dcoument_Detail__c!=null && AlternateDocuments_RelatedTo_PADD.containsKey(dhrecord.Process_Attribute_Dcoument_Detail__c)){
                                             if(!AlternateDocuments_RelatedTo_PADD.get(dhrecord.Process_Attribute_Dcoument_Detail__c).isEmpty()){
                                                 
                                                 for(Process_Attribute_Dcoument_Detail__c PADDRec:AlternateDocuments_RelatedTo_PADD.get(dhrecord.Process_Attribute_Dcoument_Detail__c)){
                                                        Document_Handler__c cloneddhrecord = dhrecord.clone(false, false, false, false);
                                                        cloneddhrecord.Process_Attribute_Dcoument_Detail__c = PADDRec.Id;
                                                        cloneddhrecord.Document_Metadata__c = PADDRec.Document_Metadata__c;
                                                        cloneddhrecord.Physical_Document_Mandatory__c = PADDRec.Physical_Document_Mandatory__c;
                                                        cloneddhrecord.Upload_Mandatory__c = PADDRec.Upload_Mandatory__c;
                                                        cloneddhrecord.Review_Required__c = PADDRec.Review_Required__c;
                                                        cloneddhrecord.Description__c = PADDRec.Document_Metadata__r.Description__c;
                                                        cloneddhrecord.Status__c = 'Draft';
                                                        cloneddhrecord.Is_Alternate_Document_Uploded__c=false;
                                                        UpsertDocumentHandler.add(cloneddhrecord);
                                                 }
                                             }
                                         }
                                   }
                            }
                      }
                      if(!UpsertDocumentHandler.isEmpty()){
                            Upsert UpsertDocumentHandler;
                      }
                      return UpsertDocumentHandler;
              }
          }catch (Exception e){
                System.debug('Exception type caught: ' + e.getTypeName());    
                System.debug('Message: ' + e.getMessage());    
                System.debug('Cause: ' + e.getCause());
                System.debug('Line number: ' + e.getLineNumber());    
                System.debug('Stack trace: ' + e.getStackTraceString());
          }
          return UpsertDocumentHandler;
    }
    
    @AuraEnabled
    Public Static Document_Handler__c insertTaskforReview(Document_Handler__c DHRecord){
        Id ownerId;
        try{
            if(DHRecord.Process_Attribute_Dcoument_Detail__r.Reviewer_Type__c == 'User'){
                ownerId=[Select Id From User Where Name=:DHRecord.Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c].Id;
            }else if(DHRecord.Process_Attribute_Dcoument_Detail__r.Reviewer_Type__c == 'Queue'){
                ownerId=[Select Id From Group Where Group.Type='Queue' AND Group.Name=:DHRecord.Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c].Id;
            }
            System.debug('ownerId--'+ownerId);
            List<Task> rec = [Select Id,process_Attribute__c,Child_Task_Category__c From Task Where Review_Record_Id__c=:DHRecord.Id AND Child_Task_Category__c='Review - Record Level'];
            List<Task> Taskrecord= DHRecord.Task_Id__c!=null ? [Select Id,Subject,process_Attribute__c,whatId From Task Where Id=:DHRecord.Task_Id__c]:null;
            System.debug('rec--'+rec);
            Task ts = new Task();
            ts.Id = rec.size()>0?rec[0].Id:null;
            ts.Parent_Task_Id__c=DHRecord.Task_Id__c;
            ts.OwnerId=ownerId;
            ts.subject=DHRecord.Task_Id__c!=null && Taskrecord.size()>0 ? 'Review - '+Taskrecord[0].Subject : 'Review Task';
            ts.Review_Record_Id__c=DHRecord.Id;
            ts.status='Submited For Review';
            ts.Child_Task_Category__c='Review - Record Level';
            ts.process_Attribute__c=DHRecord.Task_Id__c!=null &&  Taskrecord.size()>0 ? Taskrecord[0].process_Attribute__c : null;
            ts.whatId=DHRecord.Task_Id__c!=null &&  Taskrecord.size()>0 ? Taskrecord[0].whatId : null;
            Upsert ts;
            DHRecord.Status__c='Submited For Review';
            update DHRecord;
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        return DHRecord;          
    }
    
    @AuraEnabled
    public static UploadWrapper uploadFile(String base64, String filename, String recordId,string uploadedTaskId) {
        UploadWrapper UW = new UploadWrapper();
        Map<Id,List<Map<string,string>>> DocumentIdRelatedToDHId  =new Map<Id,List<Map<string,string>>>();
        try{
            ContentVersion cv = createContentVersion(base64, filename);
            ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
            if (cv == null || cdl == null) { return null; }  
            
            UW = UpdateDMSId(cdl.ContentDocumentId,recordId,filename,uploadedTaskId); 
        }catch(DMLException e) {
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        } 
        return UW;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
            return null;
        }
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [ SELECT ContentDocumentId  FROM ContentVersion  WHERE Id =: contentVersionId ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
            return null;
        }
    }
    
    @AuraEnabled
    Public static UploadWrapper UpdateDMSId(String uploadeFilePath,String uploadedrecId,string filename,string uploadedTaskId){
                 UploadWrapper uw=new UploadWrapper();
        try{
            Document_Handler__c dhrecord = [Select Id,Document_Metadata__r.Is_DocumentId_Mandatory__c,Account__c,Payable__c,MODT_Details__c,Opportunity__c,Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c,Is_Alternate_Document_Uploded__c,Document_Id_Value__c,Exempted__c,Extended_SObject_RecordId__c,Document_SLA__c,Comment_History__c,Process_Attribute_Dcoument_Detail__r.Is_New_Document__c,Status__c,Physical_Document_Mandatory__c,Description__c,Physical_Document_Received__c,Document_Metadata__c,Upload_Mandatory__c,Task_Id__c,Review_Required__c,Document_Metadata__r.Document_Category__c,
                                            Document_Metadata__r.Document_Name__c,Document_Metadata__r.Description__c,Reviewer_Name__c,Process_Attribute_Dcoument_Detail__c, 
                                            Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c,Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c,Process_Attribute_Dcoument_Detail__r.DMS_System__c, 
                                            Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c,Process_Attribute_Dcoument_Detail__r.Reviewer_Type__c,DMS_Document_Path__c From Document_Handler__c Where Id=:uploadedrecId];
            
            dhrecord.DMS_Document_Path__c=uploadeFilePath;
            dhrecord.DMS_System__c=dhrecord.Process_Attribute_Dcoument_Detail__r.DMS_System__c;
            if(dhrecord.Upload_Mandatory__c == true && dhrecord.DMS_Document_Path__c==null){
                dhrecord.Status__c = 'Document Upload Pending';
            }else if(dhrecord.Upload_Mandatory__c == true && ((dhrecord.Physical_Document_Mandatory__c == true && dhrecord.Physical_Document_Received__c==false))){
                dhrecord.Status__c = 'Physical Document Pending';
            }
            else if(dhrecord.Upload_Mandatory__c == true && dhrecord.Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c == null && (dhrecord.Physical_Document_Mandatory__c == false || (dhrecord.Physical_Document_Mandatory__c == true && dhrecord.Physical_Document_Received__c==true))){
                dhrecord.Status__c = 'Received';
            }
            else if(dhrecord.Upload_Mandatory__c == true && dhrecord.Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c != null && (dhrecord.Physical_Document_Mandatory__c == false || (dhrecord.Physical_Document_Mandatory__c == true && dhrecord.Physical_Document_Received__c==true))){
                dhrecord.Status__c = 'Submit For Review';
            }else if(dhrecord.Upload_Mandatory__c == false && dhrecord.DMS_Document_Path__c!=null){
                dhrecord.Status__c = 'Received';
            }
            Update dhrecord;
            uw.DocumentIdRelatedToDHId=CreateDocumentHandlerHistory(filename,uploadeFilePath,uploadedrecId,uploadedTaskId);
            uw.Dhrecord=dhrecord;
            uw.uplodedRecordId=uploadeFilePath;
            uw.DocHandlerHistory=[Select Id,File_Name__c,DMS_System_Name__c,Document_Path__c,Document_Handler__c,CreatedBy.Name,CreatedDate,Task_Id__c From Document_Handler_History__c Where Document_Handler__c=:uploadedrecId];
            
            System.debug('uw--'+uw);
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        return uw;
    }
    
    Public static Map<Id,List<Map<string,string>>> CreateDocumentHandlerHistory(string filename,string pathid_url,string docid,string uploadedTaskId){
        Document_Handler_History__c DHH =new Document_Handler_History__c();
        try{
            DHH.File_Name__c=filename;
            DHH.Document_Path__c=pathid_url;
            DHH.Document_Handler__c=docid;
            DHH.task_id__c=uploadedTaskId;
            Insert DHH;
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        Map<string,string> filenameRelatedPath_id=new Map<string,string>{filename=>pathid_url};
            return new Map<Id,List<map<string,string>>>{(Id)docid=>new list<map<string,string>>{filenameRelatedPath_id}};
        } 
    
    Public class UploadWrapper{
        @AuraEnabled
        Public Map<Id,List<Map<string,string>>> DocumentIdRelatedToDHId{get;set;}
        @AuraEnabled
        Public Document_Handler__c dhrecord{get;set;}
        @AuraEnabled
        Public string uplodedRecordId{get;set;}
        @AuraEnabled
        Public List<Document_Handler_History__c> DocHandlerHistory{get;set;} 
    }
    
    @AuraEnabled
    Public static deviation_reviewer_wrapper update_dh_status(Document_Handler__c dhrec,string taskid,string taskstatus){
        deviation_reviewer_wrapper drw   =new deviation_reviewer_wrapper();
        try{
            List<sObject> upsertrec          =new List<sObject>();
            Document_Handler__c dhrecord     =new Document_Handler__c();
            Task taskrec                     =new Task();
            if(dhrec!=null){ 
                System.debug('dhrec--'+dhrec);
                upsertrec.add(dhrec);
            }
            if(taskstatus!=null && taskid!=null){
                taskrec.Id=taskid;
                taskrec.Status=taskstatus;
                upsertrec.add(taskrec);
            }
            if(!upsertrec.isEmpty()){
                update upsertrec;
            }
            drw.dhrecord=dhrec;
            drw.taskrecord=taskrec;
            
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        return drw; 
    }
    
    Public class deviation_reviewer_wrapper{
        
        @AuraEnabled
        Public Document_Handler__c dhrecord{get;set;}
        @AuraEnabled
        Public Task taskrecord{get;set;}
    }
    
}