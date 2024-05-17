public without sharing class Child_components_Controller {
    
    // To get The PreDefined Reviewers
    @AuraEnabled
    Public static WrapperClassReviewer WrapperClassReviewerDetailFromApex(string recordId){
        system.debug('recordId--'+recordId); 
        
        WrapperClassReviewer WrapperRecReviewer=new WrapperClassReviewer();
        Map<string,List<string>> ReviewerTypeRelatedToReviewerName=new Map<string,List<string>>();
        List<Process_Attribute_Review_Detail__c> l_PathReviewerDetails=new List<Process_Attribute_Review_Detail__c>();
        List<String> l_PRC_id=new List<String>();
        List<Process_Review_Checklist__c> PRCList=new List<Process_Review_Checklist__c>();
        List<Process_Review_Checklist_FACT__c> PRCFList=new List<Process_Review_Checklist_FACT__c>();
        List<Task> OppRelatedTask=new List<Task>();
        try{  
            Task TaskRec=[Select WhatId,Process_Path_Task_Detail__c From Task Where Id=:recordId];
            system.debug('TaskRec'+TaskRec);
            if(TaskRec.Process_Path_Task_Detail__c != null){
                List<Process_Path_Task_Detail__c> padObjectList = [select id,
                                                                   (Select Id,
                                                                    Reviewer_Name__c,Reviewer_Type__c,Level__c,Reject_Level_Allowed__c,Process_Attribute_Review_Detail__c,Process_Review_Checklist__c,Approve_Level_Allowed__c
                                                                    From Process_Attribute_Review_Details__r where IsActive__c=true) from Process_Path_Task_Detail__c Where Id=:TaskRec.Process_Path_Task_Detail__c];
                   
                for(Process_Path_Task_Detail__c pad:padObjectList){
                    for(Process_Attribute_Review_Detail__c PARD:PAD.Process_Attribute_Review_Details__r){
                        l_PathReviewerDetails.add(PARD);
                        system.debug('l_PathReviewerDetails'+l_PathReviewerDetails);
                        l_PRC_id.add(PARD.Process_Review_Checklist__c); 
                        if(PARD.Level__c==1){
                            if(ReviewerTypeRelatedToReviewerName.containsKey(PARD.Reviewer_Type__c)){
                                list<string> str=ReviewerTypeRelatedToReviewerName.get(PARD.Reviewer_Type__c);
                                str.add(PARD.Reviewer_Name__c);
                                ReviewerTypeRelatedToReviewerName.put(PARD.Reviewer_Type__c,str);
                            }else{
                                ReviewerTypeRelatedToReviewerName.put(PARD.Reviewer_Type__c,new list<string>{PARD.Reviewer_Name__c}); 
                            } 
                        } 
                    }
                }
                PRCFList=[Select Id,Comments__c,Comment_History__c,Checklist_Reviewer_value__c,Current_Review_Level__c,Parent_Task_Id__c,Process_Attribute_Review_Detail__c,Process_Review_Checklist_Detail__c,Task_ID__c,Process_Review_Checklist_Detail__r.Checklist_Name__c,Review_Related_TaskId__c,Last_Commented_Date__c From Process_Review_Checklist_FACT__c Where Parent_Task_Id__c=:recordId];
                if(!l_PRC_id.isEmpty()){
                     PRCList=[Select Id,(Select Id,Process_Review_Checklist__c,Checklist_Name__c From Process_Review_Checklist_Details__r) From Process_Review_Checklist__c Where Id=:l_PRC_id];
                }
            }
            
            if(TaskRec.WhatId!=null){
                OppRelatedTask=[Select Id,Status,Subject From Task Where WhatId=:TaskRec.WhatId];
                if(!OppRelatedTask.isEmpty()){
                    WrapperRecReviewer.Opportunity_Related_Tasks=OppRelatedTask;
                }
            }
            
            if(!ReviewerTypeRelatedToReviewerName.isEmpty()){
                WrapperRecReviewer.ReviewerTypeRelatedToReviewerName=ReviewerTypeRelatedToReviewerName;
                WrapperRecReviewer.ProcessPathTaskDetail_ReviewerType=l_PathReviewerDetails;
                WrapperRecReviewer.ProcessAttributeReviewer_ReviewerChecklist=PRCList;
            } 
            if(!PRCFList.isEmpty()){
                WrapperRecReviewer.ProcessAttributeReviewer_ReviewerChecklistFact=PRCFList;
            }
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString()); 
        }
        return WrapperRecReviewer;
    }
    
    Public Class WrapperClassReviewer{
        @AuraEnabled
        Public Task TaskRecord{get;set;}
        @AuraEnabled
        Public Map<string,List<string>> ReviewerTypeRelatedToReviewerName{get;set;}
        @AuraEnabled
        Public List<Process_Attribute_Review_Detail__c> ProcessPathTaskDetail_ReviewerType{get;set;}
        @AuraEnabled
        Public List<Process_Review_Checklist__c> ProcessAttributeReviewer_ReviewerChecklist{get;set;}
        @AuraEnabled
        Public List<Process_Review_Checklist_FACT__c> ProcessAttributeReviewer_ReviewerChecklistFact{get;set;}
        @AuraEnabled
        Public List<Task> Opportunity_Related_Tasks{get;set;}
    }
    
    // To get The Child task & Reviewer Label Data    
    @AuraEnabled
    Public static wrapperClass returnWrapper(Id TaskId){
        
        wrapperClass wrapperRec=new wrapperClass();
        List<Task> ChildTasks=new List<Task>();
        system.debug('recordId--'+TaskId);
        String sobjectName = TaskId.getSObjectType().getDescribe().getName();
        
        string LoginUser= UserInfo.getUserId();//Get Current Login UserId 
        system.debug('LoginUser--'+LoginUser);
        
        string LoginUserId= UserInfo.getUserId();
        
        Task Taskrec=[Select Id,Subject,OwnerId,Owner.Name,WhatId,ActivityDate,UserId__r.Name,Submitted_User__c,Previous_Owner__c,
                      Status,Description,Parent_Task_Id__c,Attribute1__c,Attribute2__c,Attribute3__c,Attribute4__c,Process_Path_Task_Detail__c From Task 
                      Where Id=:TaskId];//Get Current Task Deatil 
        User UserRec=new User();
        if(Taskrec.Submitted_User__c!=null){
            system.debug('Previous_Owner__c--'+Taskrec.Submitted_User__c);
            UserRec=[Select Id,Name From User Where Id=:Taskrec.Submitted_User__c];
        }
        If(TaskRec.Id!=null){
            ChildTasks=[Select Id,Subject,OwnerId,Owner.Name,ActivityDate,UserId__r.Name,Submitted_User__c,Previous_Owner__c,Process_Path_Task_Detail__c,
                        Status,Description,Parent_Task_Id__c,Current_Review_Level__c,No_Of_Times_Reviewed_Count__c,Process_Attribute_Review_Detail__c,Last_Open_Date__c,isclosed From Task Where Parent_Task_Id__c=:TaskId AND Current_Review_Level__c!=null Order By Current_Review_Level__c];
        }
        String user_name=userinfo.getName();
        wrapperRec.login_user_UserName=user_name;
        wrapperRec.LoginUserId=LoginUser;
        wrapperRec.TaskRecord=Taskrec;
        wrapperRec.queueOptionList=[SELECT Name FROM Group WHERE Type = 'Queue'];
        //wrapperRec.queueOptionList=[SELECT QueueId, Queue.Name, SobjectType FROM QueueSobject WHERE SobjectType =:sobjectName];
        wrapperRec.userOPtionList=[SELECT Name FROM User WHERE IsActive = true];
        if(UserRec!=null){
            wrapperRec.UserRecord=UserRec; 
        }
        if(!ChildTasks.isEmpty()){
            wrapperRec.ChildTaskRecords= ChildTasks;
        }
        return wrapperRec;
        
    }
    Public Class wrapperClass{
        
        @AuraEnabled
        Public Process_Attribute_Details__c PrDetail{get;set;}
        @AuraEnabled
        Public string LoginUserId{get;set;}
        @AuraEnabled
        Public Task TaskRecord{get;set;}
        @AuraEnabled
        Public User UserRecord{get;set;}
        @AuraEnabled
        Public List<User> userOPtionList{get;set;}
        @AuraEnabled
        Public List<Group> queueOptionList{get;set;}
        //Public List<QueueSobject> queueOptionList{get;set;}
        @AuraEnabled
        Public List<Task> ChildTaskRecords{get;set;}
        @AuraEnabled
        Public String login_user_UserName{get;set;}
    }
    
    // To  Update The Status For Parent and Child In Review
    @AuraEnabled
    Public static Task PassValueForApproval(String TaskId,List<Task> tasklist,String approver_action){
        
        Task Taskre=[Select Id,OwnerId,WhatId,subject,ActivityDate,Process_Path_Task_Detail__c,Process_Attribute__c From Task where Id=:TaskId];
        system.debug('Taskre--'+Taskre);
        system.debug('TaskId--'+TaskId);
        system.debug('tasklist--'+tasklist);
        List<User> UserList=new List<User>();
        List<Task> taskListTobeInsert = new List<Task>();
        
        string LoginUserId= UserInfo.getUserId();
       
        if(!tasklist.isEmpty()){
            for(task ts:tasklist){
                Task tsrec = new Task();
                if(ts.Id!=null){
                    tsrec.Id= ts.Id; 
                }
                tsrec.No_Of_Times_Reviewed_Count__c = ts.Id!=null && ts.Id!=Taskre.Id ? ts.No_Of_Times_Reviewed_Count__c+1:1; 
                tsrec.OwnerId = ts.OwnerId;
                if(ts.Id==Taskre.Id && approver_action=='Rejected'){
                    tsrec.Status = 'Open';
                }else{
                    tsrec.Status = 'Submited For Review';
                    tsrec.Last_Open_Date__c=DateTime.valueOf(system.now());
                    tsrec.Subject = 'Review For - ' + Taskre.Subject;
                    tsrec.Parent_Task_Id__c = Taskre.Id;
                    tsrec.Submitted_User__c = LoginUserId;
                    tsrec.Previous_Owner__c=Taskre.OwnerId;
                    tsrec.WhatId = Taskre.whatId;
                    tsrec.ActivityDate = Taskre.ActivityDate;
                    tsrec.Process_Path_Task_Detail__c = Taskre.Process_Path_Task_Detail__c;
                    tsrec.Process_Attribute_Review_Detail__c=ts.Process_Attribute_Review_Detail__c;
                    tsrec.Current_Review_Level__c=ts.Current_Review_Level__c;
                    tsrec.Process_Attribute__c=Taskre.Process_Attribute__c; 
                }
                taskListTobeInsert.add(tsrec);
            }
        }
        
        try{
            if(!taskListTobeInsert.isEmpty()){
                Upsert taskListTobeInsert;
            }
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        
        if(Taskre!=null && LoginUserId!=null && approver_action!='Rejected'){
            
            Task TaskRec=new Task();
            TaskRec.Id=TaskId;
            TaskRec.Submitted_User__c=LoginUserId;
            TaskRec.Previous_Owner__c=Taskre.OwnerId;
            TaskRec.Status = 'Submited For Review';
            Update TaskRec;         
            return Taskre;
        }
        return Taskre;  
    }

    //To Update the Reviewer Status Approve or Reject 
    @AuraEnabled
    Public static List<Task> UpdateTaskStatus(string ParentTaskIdValue,String ApproverStatus,List<Id> TaskIdset){
        task parenttkrec=new task();
        List<Task> tasklist=new List<task>();
        try{
            if(!TaskIdset.isEmpty()){
                for(Id TsId:TaskIdset){
                    Task TaskRec=new Task();
                    TaskRec.Id=TsId;
                    TaskRec.Status=ApproverStatus;
                    tasklist.add(TaskRec);
                }
                if(!tasklist.isEmpty()){
                    Update tasklist;
                }
            }           
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        return tasklist;
    }
    
    //To Update the status of the Rejected Tasks
    @AuraEnabled  
    Public Static Void UpdateTasks(List<Id> TaskIdset,Id ParentTaskId){
        List<Task> TaskToUpadte=new List<Task>();
        
        Task TaskRecord=new Task();
        TaskRecord.Id=ParentTaskId;
        TaskRecord.Status='Submited for review';
        Update TaskRecord;
        
        if(!TaskIdset.isEmpty()){
            for(Id TsId:TaskIdset){
                Task TaskRec=new Task();
                TaskRec.Id=TsId;
                TaskRec.Status='Submited for review';
                TaskToUpadte.add(TaskRec);
            }
            if(!TaskToUpadte.isEmpty()){
                Update TaskToUpadte;
            }
        }
    }
    //To Update the comment of the task
    @AuraEnabled
    Public static Task updateComment(Task taskrec){
        task parenttask=new task();
        if(taskrec.Parent_Task_Id__c!=null){
            parenttask.Id=taskrec.Parent_Task_Id__c;
        } 
        list<task>tk=new list<task>{parenttask,taskrec};
            Update tk;
        
        return taskrec;
    }
    
    @AuraEnabled
    Public static Financial_Account__c getFinancialAccId(String whatId){
        return [Select Id,(Select Id,Amount__c,Mode__c,Name,Status__c,Type__c From Receivables__r),
                    (Select Id,Amount__c,Finacial_Entity_Details__c,Financial_Entity_A_C_Details__c,Financial_Entity_A_C_Details__r.Name,Financial_Account__c,Financial_Account__r.Name,Instrument_Number__c,Mode__c,Opportunity__c,Name,RBI_UTR_Reference_Number__c,Status__c,Task_Id__c,Value_Date__c From Paybales__r),
                    Name,Opportunity__c,Sanctioned_Amount__c,Account_Name__c,Borrower_Name__c,LMS_Application_ID__c,Originating_System__c,
                    Loan_Category__c,LOS_Application_ID__c,Originating_Branch__c,Product__c,Product__r.Disbursal_Type__c,Product_Type__c,Receivables_Amount__c
                    From Financial_Account__c Where Opportunity__c=:whatId];  
    }
    
    @AuraEnabled
    Public static List<Process_Review_Checklist_FACT__c> upsert_PRCF(List<Process_Review_Checklist_FACT__c> PRCFRecord){
        try{
            set<Id>PRCFRecordId=new set<Id>();
            system.debug('PRCFRecord'+PRCFRecord);
            if(!PRCFRecord.isEmpty()){
                for(Process_Review_Checklist_FACT__c fact:PRCFRecord){
                    PRCFRecordId.add(fact.Id);
                }
                Upsert PRCFRecord;
                if(!PRCFRecordId.isEmpty()){
                    PRCFRecord=[Select Id,Comments__c,Comment_History__c,Checklist_Reviewer_value__c,Current_Review_Level__c,Last_Commented_Date__c From Process_Review_Checklist_FACT__c Where Id=:PRCFRecordId];
                }else{
                    return PRCFRecord;
                }
            } 
        }catch (Exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return PRCFRecord;
    }
}