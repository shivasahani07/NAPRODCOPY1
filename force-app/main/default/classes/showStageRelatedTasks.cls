public class showStageRelatedTasks {
    
    @AuraEnabled(cacheable=true)
    Public Static Map<String,List<WrapperClass>> getAllProcessAttributeDetails(Id recordId){
        Boolean currentUserIsOpportunityOwner				=	false;
        String Sobject_Type_Name							=	recordId.getSObjectType().getDescribe().getName();
        Map<String,List<WrapperClass>> Stage_RelatedTask	=	new Map<String,List<WrapperClass>>(); 
        Map< ID,Sobject> ID_PADRecord						=	new Map<ID,Sobject>();
        Map<Id,List<Task>> mapofPADIdByListTask 			= 	new Map<Id,List<Task>>();
        List<sobject> SobjectList							=	new List<sobject>();
        List<WrapperClass> WrapperData						=	new List<WrapperClass>();
        Set<String> TaskownerName							=	new Set<String>();
        Set<Id> GroupId										=	new Set<Id>();
        Id CurrentUserId									=	userinfo.getuserid();//CurrentUser Id
        
        //To see Current User Belongs To Which PublicGroup and Queue
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
                    TaskownerName.add(Grm.Group.Name);
                }
            }
        } 
        
        String SobjectQuery='Select Id,Process_Attribute__c,OwnerId From '+Sobject_Type_Name+' Where Id=:recordId';
        Sobject SRecord=Database.query(SobjectQuery);
        String RelatedProcessAttributeId=String.valueOf(SRecord.get('Process_Attribute__c'));
        String SobjectOwnerId=String.valueOf(SRecord.get('OwnerId'));
        
        String Dynamicquery;
        if(CurrentUserId==SobjectOwnerId){
            currentUserIsOpportunityOwner = true;
        }
        Dynamicquery='Select Id,Stage_Step__c,Task_Subject__c,Action_URL__c,Task_Owner_Type__c,Task_Owner_Name__c From Process_Attribute_Details__c Where Process_Attribute__c=:RelatedProcessAttributeId AND Stage_Step__c!=null AND Task_Automation__c=true AND isActive__c=true Order By Stage_SL_No__c,Task_Subject_Sl_No__c';
        if(Dynamicquery!=null){
            SobjectList=Database.query(Dynamicquery);
            if(!SobjectList.isEmpty()){
                for(Sobject obj:SobjectList){
                    ID_PADRecord.put(String.valueOf(obj.get('Id')),obj);
                }                
            }
        }
        List<Task> TaskList=[Select Id,Status,Subject,Owner.Name,OwnerId,ActivityDate,Process_Attribute_Details__c,Process_Attribute_Details__r.Stage_Step__c,Is_SLA_Overdued__c,IsClosed,CreatedDate,CompletedDateTime,Parent_Task_Id__c From Task Where WhatId=:recordId Order By Process_Attribute_Details__r.Task_Subject__c,isclosed,Is_SLA_Overdued__c desc,ActivityDate,CompletedDateTime];
        if(!TaskList.isEmpty()){
            for(Task t:TaskList){
                if(mapofPADIdByListTask.containsKey(t.Process_Attribute_Details__c)){
                    mapofPADIdByListTask.get(t.Process_Attribute_Details__c).add(t);
                }else{
                    mapofPADIdByListTask.put(t.Process_Attribute_Details__c,new List<Task>{t});
                }
            }
        }
        
        
        if(!ID_PADRecord.isEmpty()){
            for(Sobject Rec:ID_PADRecord.values()){
                if(mapofPADIdByListTask.containsKey(String.valueOf(Rec.get('Id')))){
                    for(Task Taskrec : mapofPADIdByListTask.get(String.valueOf(Rec.get('Id')))){
                        
                        WrapperClass WRPData = new WrapperClass();
                        WRPData.Stage_Step				=	Taskrec.Process_Attribute_Details__r.Stage_Step__c;
                        WRPData.Subject					=	Taskrec.Subject;
                        WRPData.loggedInUserRoleList	=	TaskownerName;
                        WRPData.isOpportunityOwner		= 	currentUserIsOpportunityOwner;
                        WRPData.TaskDueDate				=	String.valueOf(Taskrec.ActivityDate);
                        WRPData.TaskCreatedDate			=	String.valueOf(Date.valueOf(Taskrec.CreatedDate));
                        WRPData.TaskId					=	Taskrec.Id;
                        WRPData.TaskOwner				=	Taskrec.Owner.Name;
                        WRPData.Task_Status				=	Taskrec.Status;
                        
                        if(Taskrec.IsClosed == true && Taskrec.Is_SLA_Overdued__c == true){
                            WRPData.TaskCompletionDate	=	String.valueOf(Date.valueOf(Taskrec.CompletedDateTime));
                            WRPData.DynamicCardColor	=	'background-color:#00FF00';//LimeCard
                            WRPData.ButtonLabel			=	'View';
                        }else if(Taskrec.IsClosed==true && Taskrec.Is_SLA_Overdued__c==false){
                            WRPData.TaskCompletionDate	=	String.valueOf(Date.valueOf(Taskrec.CompletedDateTime));
                            WRPData.DynamicCardColor	=	'background-color:#008000;color:white;';//DarkGreenCard
                            WRPData.ButtonLabel			=	'View';
                        }else if(Taskrec.IsClosed==false && Taskrec.Is_SLA_Overdued__c==true){
                            WRPData.TaskCompletionDate	=	'Yet To Complete';
                            WRPData.DynamicCardColor	=	'background-color:#00FFFF;';//CyanCard
                            WRPData.ButtonLabel			=	'Edit';
                        }else if(Taskrec.IsClosed==false && Taskrec.Is_SLA_Overdued__c==false){
                            WRPData.TaskCompletionDate	=	'Yet To Complete';
                            WRPData.DynamicCardColor	=	'background-color:#800000;color:white;';//MaroonCard
                            WRPData.ButtonLabel			=	'Edit';
                        }
                        WrapperData.add(WRPData);
                    }
                }else{
                    WrapperClass WRPData=new WrapperClass();
                    WRPData.Stage_Step				=	String.valueOf(Rec.get('Stage_Step__c'));
                    WRPData.Subject					=	String.valueOf(Rec.get('Task_Subject__c'));
                    WRPData.TaskCreatedDate			=	'Yet to start';
                    WRPData.TaskDueDate				=	'Yet to start';
                    WRPData.TaskCompletionDate		=	'Closer Date OF Task';
                    WRPData.TaskId					=	null;
                    WRPData.TaskOwner				=	String.valueOf(Rec.get('Task_Owner_Name__c')); 
                    WRPData.DynamicCardColor		=	'background-color:#808080;color:white;';//Gray Card
                    WRPData.ButtonLabel				=	'N/A';
                    WRPData.loggedInUserRoleList	=	TaskownerName;
                    WRPData.isOpportunityOwner		= 	currentUserIsOpportunityOwner;
                    //WRPData.Action_URL			=	null;
                    
                    WrapperData.add(WRPData);
                    System.debug('WRPData Else---'+WRPData);
                }
            }
            
        }
        
        if(!WrapperData.isEmpty()){
            for(WrapperClass PADRec:WrapperData){
                
                if(Stage_RelatedTask.containsKey(PADRec.Stage_Step)){
                    List<WrapperClass> WRPList	=	Stage_RelatedTask.get(PADRec.Stage_Step);
                    WRPList.add(PADRec);
                    Stage_RelatedTask.put(PADRec.Stage_Step,WRPList);
                }else{
                    Stage_RelatedTask.put(PADRec.Stage_Step,new List<WrapperClass>{PADRec});  
                }
                
            }
            System.debug('Stage_RelatedTask'+Stage_RelatedTask);
        }
        
        return Stage_RelatedTask;
    }
    Public Class WrapperClass{
        
        @AuraEnabled
        Public String Stage_Step{get;set;}
        @AuraEnabled
        Public String Task_Status{get;set;}
        @AuraEnabled
        Public string Subject{get;set;}
        @AuraEnabled
        Public String TaskCreatedDate{get;set;}
        @AuraEnabled
        Public String TaskDueDate{get;set;}
        @AuraEnabled
        Public String TaskCompletionDate{get;set;}
        @AuraEnabled
        Public String TaskId{get;set;}
        @AuraEnabled
        Public String TaskOwner{get;set;}
        @AuraEnabled
        Public String DynamicCardColor{get;set;}
        @AuraEnabled
        Public String ButtonLabel{get;set;}
        @AuraEnabled
        Public Set<String> loggedInUserRoleList{get;set;}
        @AuraEnabled
        Public Boolean isOpportunityOwner{get;set;}
    }
    
}