public class TaskStatusUpdateHelper {
    @AuraEnabled
    public Static Task updatetaskStatus(String recordId,String status){
        string LoginUserId= UserInfo.getUserId();
        if(!String.isBlank(recordId) && !String.isBlank(status)){
            Task tk = new Task();
            tk.id = recordId;
            tk.Status = status;
            tk.Submitted_User__c=LoginUserId;
            try{
                update tk;
            }catch(Exception e){
                system.debug('exception trace::'+e.getStackTraceString());
            }
            
            Task tkupdate = [SELECT Id,WhatId FROM Task Where Id=:recordId];
            return tkupdate;
        }
        return null;
    }
    
    @AuraEnabled
    public Static Map<String, String> getAccRatings(){
        Map<String, String> options = new Map<String, String>();
        options.put('Initiated','Initiated');
        options.put('Completed','Completed');
        
        return options;
    }
    
    
    
    @AuraEnabled 
    Public static Task UpdateTaskStatusInApprove(string TaskIdValue,String ApproverStatus,String Comment){
        
        Task TaskrecToUpdate=new Task();
        if(ApproverStatus=='Approved'){
            TaskrecToUpdate.Id=TaskIdValue;
            TaskrecToUpdate.Status='Completed';
            
        }else if(ApproverStatus=='Rejected'){
            TaskrecToUpdate.Id=TaskIdValue;
            TaskrecToUpdate.Status='Rejected';
            TaskrecToUpdate.Description=Comment;
        }else if(ApproverStatus=='ReAssign'){
            Task Taskre=[Select Id,Previous_Owner__c From Task where Id=:TaskIdValue];
            TaskrecToUpdate.Id=TaskIdValue;
            TaskrecToUpdate.Status='Open';
            TaskrecToUpdate.Description=Comment;
            TaskrecToUpdate.OwnerId=Taskre.Previous_Owner__c;
        }
        try{
            
        }catch(Exception e){
            system.debug('exception trace::'+e.getStackTraceString());
        }
        Update  TaskrecToUpdate;
        Task TaskRecord=[Select Id,WhatId From Task Where Id=:TaskIdValue];
        return TaskRecord;
    }
    
    @AuraEnabled
    Public static wrapperClass returnWrapper(string TaskId){
        wrapperClass wrapperRec=new wrapperClass();
        string LoginUserId= UserInfo.getUserId();//Get Current Login UserId 

        Task Taskrec=[Select Id,Subject,OwnerId,ActivityDate,UserId__r.Name,Submitted_User__c,Previous_Owner__c,Process_Attribute_Details__c,Status,Description From Task Where Id=:TaskId];//Get Current Task Deatil 
        User UserRec=new User();
        if(Taskrec.Submitted_User__c!=null){
            UserRec=[Select Id,Name From User Where Id=:Taskrec.Submitted_User__c];//Get Current Login User Detail  
        }
        string TaskPrdId=Taskrec.Process_Attribute_Details__c;
        
        Process_Attribute_Details__c  PraDetailRec=[Select Id,Task_Reviwer_Type__c,Task_Subject__c From Process_Attribute_Details__c where Id =:TaskPrdId];//Get Process Attribute Detail Related To Current Task
        
        wrapperRec.PrDetail=PraDetailRec;
        wrapperRec.LoginUserId=LoginUserId;
        wrapperRec.TaskRecord=Taskrec;
        wrapperRec.UserRecord=UserRec;
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
    }
    
    @AuraEnabled
    Public static WrapperClassReviewer WrapperClassReviewerDetail(string recordId){
        WrapperClassReviewer WrapperRecReviewer=new WrapperClassReviewer();
        Set<Id> UserGroudId=new set<Id>();
        Task TaskRec=[Select WhatId,Process_Attribute_Details__c From Task Where Id=:recordId];
        
        if(TaskRec.Process_Attribute_Details__c != null){
            Process_Attribute_Details__c padObject = [select id,Task_Reviwer_Type__c,Task_Reviewer_Name__c from Process_Attribute_Details__c where id =: TaskRec.Process_Attribute_Details__c];
            
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
        }
        system.debug('WrapperRecReviewer UserList--'+WrapperRecReviewer.UserRecList);
        
        return WrapperRecReviewer;
    }
    
    Public Class WrapperClassReviewer{
        @AuraEnabled
        Public List<User> UserRecList{get;set;}
        @AuraEnabled
        Public Task TaskRecord{get;set;}
    }
    
    @AuraEnabled
    Public static Task PassValueForApproval(Id TaskId,Id SelectReviewer){
        Task Taskre=[Select Id,OwnerId,WhatId From Task where Id=:TaskId];
        
        string LoginUserId= UserInfo.getUserId();
        
        Task TaskRec=new Task();
        TaskRec.Id=TaskId;
        TaskRec.UserId__c=SelectReviewer;
        //TaskRec.OwnerId=SelectReviewer;
        TaskRec.Previous_Owner__c=LoginUserId;
        TaskRec.Status='Submited For Review';
        
        Update TaskRec;
        return Taskre;
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
    
    
    
}