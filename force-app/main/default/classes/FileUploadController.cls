public class FileUploadController {
    
    @AuraEnabled  
    public static List<ContentDocument> getFiles(string recordId){  
        List<ContentDocument> DocumentList = new List<ContentDocument>();  
        Set<Id> documentIds = new Set<Id>();  //store file ids
        List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:recordId];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  // Document ids
        }      
        DocumentList = [select Id,Title,FileType,ContentSize,Description,CreatedDate from ContentDocument where id IN: documentIds];
        
        return DocumentList;  
    } 
    
    @AuraEnabled
    Public static wrapperClass returnWrapper(string TaskId){
        wrapperClass wrapperRec=new wrapperClass();
        List<Task> ChildTasks=new List<Task>();
        system.debug('recordId--'+TaskId);
        
        string LoginUser= UserInfo.getUserId();//Get Current Login UserId 
        system.debug('LoginUser--'+LoginUser);
        
        string LoginUserId= UserInfo.getUserId();
        
        Task Taskrec=[Select Id,Subject,OwnerId,WhatId,ActivityDate,UserId__r.Name,Submitted_User__c,Previous_Owner__c,
                      Process_Attribute_Details__c,Process_Attribute_Details__r.Task_Reviewer_Name__c,Status,Description,
                      Process_Attribute_Details__r.Task_Reviwer_Type__c,Parent_Task_Id__c,Attribute1__c,Attribute2__c,Attribute3__c,Attribute4__c
                      From Task 
                      Where Id=:TaskId];//Get Current Task Deatil 
        User UserRec=new User();
        if(Taskrec.Submitted_User__c!=null){
            system.debug('Previous_Owner__c--'+Taskrec.Submitted_User__c);
            UserRec=[Select Id,Name From User Where Id=:Taskrec.Submitted_User__c];
        }
        If(TaskRec.Id!=null){
            ChildTasks=[Select Id,Subject,OwnerId,Owner.Name,ActivityDate,UserId__r.Name,Submitted_User__c,Previous_Owner__c,Process_Attribute_Details__c,Status,Description,Parent_Task_Id__c From Task Where Parent_Task_Id__c=:TaskId];
        }
        string TaskPrdId=Taskrec.Process_Attribute_Details__c;
        system.debug('TaskSubject--'+TaskPrdId);
        
        Process_Attribute_Details__c  PraDetailRec=[Select Id,Task_Reviwer_Type__c,Task_Reviewer_Name__c,Task_Subject__c From Process_Attribute_Details__c where Id =:TaskPrdId];//Get Process Attribute Detail Related To Current Task
        system.debug('PraDetail--'+PraDetailRec);
        
        wrapperRec.PrDetail=PraDetailRec;
        wrapperRec.LoginUserId=LoginUser;
        wrapperRec.TaskRecord=Taskrec;
        wrapperRec.queueOptionList=[SELECT Name FROM Group WHERE Type = 'Queue'];
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
        
        @AuraEnabled
        Public List<Task> ChildTaskRecords{get;set;}
        
        
    }
    
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
                TaskRec.Status='Open';
                TaskToUpadte.add(TaskRec);
            }
            if(!TaskToUpadte.isEmpty()){
                Update TaskToUpadte;
            }
        }
    }
    
    
    @AuraEnabled  
    public static List<ContentDocument> UpdateFiles(string documentId,string title,string recordId,string Description){  
        system.debug('title: ' +title); 
        system.debug('Description: ' +Description);  
        ContentDocument cd = [select id,title from ContentDocument where Id=:documentId]; // Getting files from Parent record 
        cd.Title = title;
        cd.Description=Description;
        // Changing file Title with user entered title
        try{  
            update cd;  // Update ContentDocument (File)
        }  
        catch(DMLException e){  
            system.debug('Exception has occurred! ' +e.getMessage());  
        }  
        List<ContentDocument> DocumentList = new List<ContentDocument>();  
        Set<Id> documentIds = new Set<Id>();  
        List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:recordId];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        DocumentList = [select Id,Title,FileType,ContentSize,Description,CreatedDate from ContentDocument where id IN: documentIds];  
        return DocumentList;  // Return list of files on parent record
    }
    
    @AuraEnabled
    Public static Task  UpdateTaskStatus(string TaskIdValue,String ApproverStatus,String Comment,Id currentTaskId){
        system.debug('TaskIdValue::'+TaskIdValue);
        system.debug('ApproverStatus::'+ApproverStatus);
        system.debug('currentTaskId::'+currentTaskId);
        //List<Task> Taskre=[Select Id,Previous_Owner__c From Task where Id=:TaskIdValue];
        Task TaskrecToUpdate=new Task();
        string LoginUser= UserInfo.getUserId();
        try{
            
            if(ApproverStatus=='Approved'){
                List<Task> taskList = new List<Task>(); 
                taskList = [select id from task where parent_Task_Id__C =: TaskIdValue and id !=: currentTaskId and isClosed = false];
                system.debug('taskList::'+taskList);
                if(!taskList.isEmpty()){
                    TaskrecToUpdate.Id=TaskIdValue;
                    TaskrecToUpdate.Status='Submited For Review';
                    TaskrecToUpdate.UserId__c=LoginUser;
                    
                    Task childTask = new Task();
                    childTask.Id = currentTaskId;
                    childTask.Status = 'Completed';
                    childTask.UserId__c = LoginUser;
                    system.debug('childTask::'+childTask);
                    update childTask;
                }else{
                    TaskrecToUpdate.Id=TaskIdValue;
                    TaskrecToUpdate.Status='Completed';
                    TaskrecToUpdate.UserId__c=LoginUser;
                    
                    Task childTask = new Task();
                    childTask.Id = currentTaskId;
                    childTask.Status = 'Completed';
                    childTask.UserId__c = LoginUser;
                    update childTask;
                    
                }
                
                
                
            }else if(ApproverStatus=='Rejected'){
                
                TaskrecToUpdate.Id=TaskIdValue;
                TaskrecToUpdate.Status='Open';
                TaskrecToUpdate.Description=Comment;
                //TaskrecToUpdate.OwnerId=Taskre[0].Previous_Owner__c;
                TaskrecToUpdate.UserId__c=LoginUser;
                
                Task childTask = new Task();
                childTask.Id = currentTaskId;
                childTask.Status = 'Rejected';
                update childTask;
                
                
            }else if(ApproverStatus=='ReAssign'){
                
                
                TaskrecToUpdate.Id=TaskIdValue;
                TaskrecToUpdate.Status='Open';
                TaskrecToUpdate.Description=Comment;
                //TaskrecToUpdate.OwnerId=Taskre[0].Previous_Owner__c;
                TaskrecToUpdate.UserId__c=LoginUser;
                
                Task ts = new Task();
                ts.Id = currentTaskId;
                ts.Status = 'ReAssign';
                update ts;
            }
            Update  TaskrecToUpdate;
            //Task TaskRecord=[Select Id,WhatId From Task Where Id=:TaskrecToUpdate.Id];  
            
        }catch(Exception e){
            system.debug('The error has occured due to ====> '+ e.getMessage());
            system.debug('The error has occured at ====> '+ e.getLineNumber());
        }
        Task TaskRecord=[Select Id,WhatId From Task Where Id=:TaskrecToUpdate.Id];
        return TaskRecord;
    }
    
    @AuraEnabled
    Public static WrapperClassReviewer WrapperClassReviewerDetailFromApex(string recordId){
        system.debug('recordId--'+recordId);
        WrapperClassReviewer WrapperRecReviewer=new WrapperClassReviewer();
        Set<Id> UserGroudId=new set<Id>();
        Set<String> QueueListrec=new Set<String>();
        Task TaskRec=[Select WhatId,Process_Attribute_Details__c From Task Where Id=:recordId];
        
        if(TaskRec.Process_Attribute_Details__c != null){
            Process_Attribute_Details__c padObject = [select id,Task_Reviwer_Type__c,Task_Reviewer_Name__c from Process_Attribute_Details__c where id =: TaskRec.Process_Attribute_Details__c];
            List<Process_Attribute_Details__c> padObjectList = [select id,Task_Reviwer_Type__c,Task_Reviewer_Name__c from Process_Attribute_Details__c where Task_Reviewer_Name__c!=null];
            for(Process_Attribute_Details__c pad:padObjectList){
                QueueListrec.add(pad.Task_Reviewer_Name__c);
            }
            /*if(padObject.Task_Reviewer_Name__c!=null){
QueueListrec.add(padObject.Task_Reviewer_Name__c);
}*/
            if(padObject.Task_Reviwer_Type__c != null && padObject.Task_Reviwer_Type__c == 'Queue'){
                List<Group> ReviewerGroup = new List<Group>();
                Set<Id> publicGroupIdSet = new Set<Id>();
                ReviewerGroup=[SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE Type =: padObject.Task_Reviwer_Type__c and Name=: padObject.Task_Reviewer_Name__c];
                system.debug('ReviewerGroup::'+ReviewerGroup);
                if(!ReviewerGroup.isEmpty()){
                    for(Group grp : ReviewerGroup){
                        for(GroupMember gm : grp.GroupMembers){
                            if(string.valueOf(gm.UserOrGroupId).startsWith('00G')){
                                system.debug('inside public group section');
                                publicGroupIdSet.add(gm.UserOrGroupId);
                            }
                        }
                    }
                    system.debug('publicGroupIdSet::'+publicGroupIdSet);
                    if(!publicGroupIdSet.isEmpty()){
                        List<GroupMember> gmList = new List<GroupMember>();
                        gmList = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId in: publicGroupIdSet];
                        system.debug('gmList::'+gmList);
                        if(!gmList.isEmpty()){
                            for(GroupMember gm : gmList){
                                system.debug('inside');
                                UserGroudId.add(gm.UserOrGroupId);
                            }
                        }
                    }
                }
            }
        }
        system.debug('UserGroudId--'+UserGroudId);
        if(!UserGroudId.isEmpty()){
            List<User> UserList=[Select Id,Name From User Where Id in: UserGroudId];
            system.debug('UserList--'+UserList);
            WrapperRecReviewer.UserRecList=UserList;
            WrapperRecReviewer.TaskRecord=TaskRec;
            if(!QueueListrec.isEmpty()){
                WrapperRecReviewer.QueueList=QueueListrec;   
            } 
        }
        system.debug('WrapperRecReviewer UserList--'+WrapperRecReviewer.UserRecList);
        
        
        return WrapperRecReviewer;
    }
    
    Public Class WrapperClassReviewer{
        @AuraEnabled
        Public List<User> UserRecList{get;set;}
        @AuraEnabled
        Public Task TaskRecord{get;set;}
        @AuraEnabled
        Public Set<string> QueueList{get;set;}
    }
    
    @AuraEnabled
    Public static Task PassValueForApproval(Id TaskId,List<string> SelectReviewer){
        Task Taskre=[Select Id,OwnerId,WhatId,subject,ActivityDate,Process_Attribute_Details__c From Task where Id=:TaskId];
        system.debug('Taskre--'+Taskre);
        system.debug('TaskId--'+TaskId);
        system.debug('SelectReviewer--'+SelectReviewer);
        List<User> UserList=new List<User>();
        List<Task> taskListTobeInsert = new List<Task>();
        
        List<ContentDocument> DocumentList = new List<ContentDocument>(); 
        Set<Id> documentIds = new Set<Id>();  //store file ids
        List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:TaskId];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  // Document ids
        }      
        DocumentList = [select Id,Title,FileType,ContentSize,Description,CreatedDate from ContentDocument where id IN: documentIds];
        
        string LoginUserId= UserInfo.getUserId();
        Group GroupRec;
        if(SelectReviewer!=null){
            //List<Group> groupRecList = [SELECT Id, Name FROM Group WHERE Type ='Queue' and Name=:SelectReviewer]; 
            //if(!groupRecList.isEmpty()){
            for(String grp : SelectReviewer){
                Task ts = new Task();
                ts.Subject = 'Review For - ' + Taskre.Subject;
                ts.OwnerId = grp;
                ts.Status = 'Open';
                ts.Parent_Task_Id__c = Taskre.Id;
                ts.Submitted_User__c = LoginUserId;
                ts.Previous_Owner__c=Taskre.OwnerId;
                ts.WhatId = Taskre.whatId;
                ts.ActivityDate = Taskre.ActivityDate;
                ts.Process_Attribute_Details__c = Taskre.Process_Attribute_Details__c;
                taskListTobeInsert.add(ts);
            }
            // }
        }
        
        if(!taskListTobeInsert.isEmpty()){
            insert taskListTobeInsert;
        }
        if(Taskre!=null && !DocumentList.isEmpty() && LoginUserId!=null){
            
            Task TaskRec=new Task();
            TaskRec.Id=TaskId;
            //TaskRec.UserId__c=SelectReviewer;
            TaskRec.Submitted_User__c=LoginUserId;
            //TaskRec.OwnerId=GroupRec.Id;
            TaskRec.Previous_Owner__c=Taskre.OwnerId;
            TaskRec.Status='Submited For Review';
            
            Update TaskRec;
            
            return Taskre;
        }
        return null;
        
    }
    
    @AuraEnabled
    public Static Map<String, String> getAccRatings(){
        Map<String, String> options = new Map<String, String>();
        
        options.put('Completed','Completed');
        //options.put('Failed','Failed');
        //options.put('Rescheduled','Rescheduled');
        
        return options;
    }
    
    @AuraEnabled
    public Static Task updatetaskStatusValue(String recordId,String status){
        
        List<ContentDocument> DocumentList = new List<ContentDocument>(); 
        Set<Id> documentIds = new Set<Id>();  //store file ids
        List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:recordId];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  // Document ids
        }      
        DocumentList = [select Id,Title,FileType,ContentSize,Description,CreatedDate from ContentDocument where id IN: documentIds];
        
        string LoginUserId= UserInfo.getUserId();
        if(!String.isBlank(recordId) && !String.isBlank(status) && !DocumentList.isEmpty()){
            Task tk = new Task();
            tk.id = recordId;
            tk.Status = status;
            tk.Submitted_User__c=LoginUserId;
            try{
                update tk;
            }catch(exception e){
                system.debug('exception Trce::'+e.getStackTraceString());
            }
            
            System.debug('Updated Task === >'+tk);
            Task tkupdate = [SELECT Id,WhatId FROM Task Where Id=:recordId];
            system.debug('tkupdate == >'+tkupdate);
            return tkupdate;
        }
        return null;
    }
    //Delete This Method
    @AuraEnabled
    Public static void StatusUpadteToReopen(string TaskId){
        if(TaskId!=null){
            Task Taskre=[Select Id,OwnerId,Previous_Owner__c,WhatId From Task where Id=:TaskId];
            Task TaskRec=new Task();
            TaskRec.Id=TaskId;
            TaskRec.Status='Open';
            if(Taskre.Previous_Owner__c!=null){
                TaskRec.OwnerId=Taskre.Previous_Owner__c;
            }
            Update TaskRec;   
        } 
    }
    
    @AuraEnabled
    Public static boolean CallCheckCurrentUserEditRight(Id TaskId){
        Id LoginUserId= UserInfo.getUserId();
        boolean BooleanValue;
        system.debug('LoginUserId--'+LoginUserId);
        system.debug('TaskId--'+TaskId);
        if(LoginUserId!=null && TaskId!=null){
            BooleanValue=CheckCurrentUserEditRight.currentUserEditRight(LoginUserId,TaskId);  
        }
        system.debug('BooleanValue::'+BooleanValue);  
        return BooleanValue;
    }
    @AuraEnabled
    public static void openChildReviewerTask(Task taskRec){
        Task ts = new Task();
        ts.Id = taskRec.Id;
        ts.Status = 'Open';
        update ts;
        
        Task parentTask = new Task();
        parentTask.Id = taskRec.Parent_Task_Id__c;
        parentTask.Status = 'Submit For Review';
        update parentTask;
    }
    //Need To Delete 
    @AuraEnabled
    public static WrapperClassOption getOwnerOptions(String ownerType,List<String> SelectedUserORQueues) {
        WrapperClassOption wrap = new WrapperClassOption();
        if (ownerType == 'Queue') {
            // Query and add all available queues to 'options' list
            wrap.queueOptionList = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Id!=:SelectedUserORQueues];
        } else if (ownerType == 'Self') {
            // Query and add all active users to 'options' list
            wrap.userOPtionList = [SELECT Id,Name FROM User WHERE IsActive = true AND Id!=:SelectedUserORQueues];
        }
        return wrap;
    }
    //Need To Delete 
    Public Class WrapperClassOption{
        @AuraEnabled
        Public List<User> userOPtionList{get;set;}
        @AuraEnabled
        Public List<Group> queueOptionList{get;set;}
    }
    
    
    
}