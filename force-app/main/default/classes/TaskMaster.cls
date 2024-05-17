public without sharing class TaskMaster {
    
    
    @AuraEnabled
    Public Static ChildTaskMaster getPRocessAttributeDetails(Id recId){
        system.debug('recId ====> ' + recId);
        ChildTaskMaster ctm = new ChildTaskMaster();
        List<Process_Component__c> pcList = new List<Process_Component__c>();
        
        Task taskRec = [Select Id,Subject,OwnerId,Owner.Name,WhatId,ActivityDate,UserId__r.Name,Submitted_User__c,Previous_Owner__c,
                        Process_Attribute_Details__c,Process_Attribute_Details__r.Task_Reviewer_Name__c,Status,Description, 
                        Process_Attribute_Details__r.Task_Reviwer_Type__c,Parent_Task_Id__c,Attribute1__c,Attribute2__c,Attribute3__c,Attribute4__c,
                        Process_Attribute_Details__r.Additional_Report_Task__c,Process_Path_Task_Detail__c
                        From Task 
                        where ID=: RecID];
        
        ctm.taskRec = taskRec;
        ctm.listOfProcessComp = new List<Process_Component__c>();
        if(taskRec.Process_Path_Task_Detail__c != null){
            pcList= [select Id,Active__c,Name__c,Process_Attribute_Details__c,Sequence__c,Process_Task_Detail__c
                     from Process_Component__c	 
                     where Process_Task_Detail__c =:[Select Id,Process_Task_Detail__c From Process_Path_Task_Detail__c Where Id=:taskRec.Process_Path_Task_Detail__c].Process_Task_Detail__c  and Active__c = true order by Sequence__c ASC];     
        }else if(taskRec.Process_Attribute_Details__c != null){
            pcList= [select Id,Active__c,Name__c,Process_Attribute_Details__c,Sequence__c
                     from Process_Component__c	 
                     where Process_Attribute_Details__c =: taskRec.Process_Attribute_Details__c
                     and Active__c = true order by Sequence__c ASC];
        }
        if(!pcList.isEmpty()){
            ctm.listOfProcessComp =  pcList;
        }
        List<Task> childTasklist = getChildtask_Access_with_loginuser(recId);
        List<string> listOfStrings = new List<String>(getCurrentUseraccess(UserInfo.getUserId()));
        
        ctm.childTasklist=childTasklist;
        ctm.loginUser_associated_Groups=listOfStrings;
        
        Return ctm;
    }
    
    public class ChildTaskMaster{
        @AuraEnabled
        public Task taskRec{get;set;}
        @AuraEnabled 
        public List<Process_Component__c> listOfProcessComp{get;set;}
        @AuraEnabled
        Public List<Task> childTasklist{get;set;}
        @AuraEnabled
        Public List<string> loginUser_associated_Groups{get;set;}
        
    }
    
    Public static List<Task> getChildtask_Access_with_loginuser(Id recId){
       
        List<Task> childTasklist=[Select Id,Parent_Task_Id__c,Status,OwnerId,Owner.Name From Task Where Parent_Task_Id__c=:recId];  
        
        return childTasklist;
    }
    
    Public static set<string> getCurrentUseraccess(Id loginUserId){
        set<Id> GroupId=new set<Id>();
        set<string> GroupName=new set<string>();
        if(String.isNotBlank(loginUserId)){
            List<GroupMember> PublicGroupMemmber =[SELECT GroupId,Id,Group.Name,SystemModstamp,UserOrGroupId FROM GroupMember Where Group.Type='Regular' AND UserOrGroupId=:loginUserId];
            if(!PublicGroupMemmber.isEmpty()){
                for(GroupMember Grm:PublicGroupMemmber){
                    GroupId.add(Grm.GroupId);
                }
            }
            
            List<GroupMember> QueueMemmber =[SELECT Id, Group.Name, UserOrGroupId FROM GroupMember WHERE Group.Type = 'Queue' AND (UserOrGroupId =:loginUserId OR UserOrGroupId IN: GroupId)];
            if(!QueueMemmber.isEmpty()){
                
                for(GroupMember Grm:QueueMemmber){
                    GroupName.add(Grm.Group.Name);
                }
            }
        }
         return GroupName;
    }
    
    @AuraEnabled
    Public static String close_ParentTask( String taskid){ 
        If(taskid!=null){
            Task tk=new Task();
            tk.Id=taskid;
            tk.Status='Completed';
            
            Update tk;
        }
        return 'SUCCESS';
    }
   
}