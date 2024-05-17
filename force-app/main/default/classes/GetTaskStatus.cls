public without sharing class GetTaskStatus {
    
    @AuraEnabled
    Public static WrapperTaskAction GettaskDetail(string recordId){
        Task parentTaskRec = new Task();
        Task ReturnTaskRec=new Task();
        WrapperTaskAction wrapTask = new WrapperTaskAction();
        Task TaskRec=[SELECT AccountId,ActivityDate,CallDisposition,CallDurationInSeconds,
                      CallObject,CallType,Contact_Person__c, Contact_Person__r.Name,Contact_Person__r.LastName,Contact_Person__r.FirstName,
                      DateTime_of_Meeting__c,Description,Follow_Up__c,Id,IsClosed,Meeting_Call_Purpose__c,Meeting_Call_status__c,
                      OwnerId,Process_Attribute_Details__c,Stage__c,Status,Subject,TaskSubtype,
                      WhatCount,WhatId,WhoCount,Process_Attribute_Details__r.Action_Type__c,Process_Attribute_Details__r.Action_URL__c,
                      Process_Attribute_Details__r.Task_Automation__c,Parent_Task_Id__c,Process_Attribute_Details__r.Is_Review_Task__c,
                      Process_Attribute_Details__r.Process_Component__c,Process_Path_Task_Detail__r.Action_URL__c,Process_Path_Task_Detail__r.Action_Type__c,Owner.Name,
                      process_attribute__c,Process_Attribute_Path_Deviation__c,Process_Attribute_Path_Deviation__r.Process_Path_Type__c
                      FROM Task Where Id=:recordId ];
        
        system.debug('TaskRec Process attribute ====>'+ TaskRec.process_attribute__c);
        
        
        
        if(TaskRec.Parent_Task_Id__c != null && TaskRec.Process_Attribute_Path_Deviation__c==null){
            
            system.debug('Parent Task Id Not Null');
            
            parentTaskRec = [SELECT AccountId,ActivityDate,CallDisposition,CallDurationInSeconds,
                             CallObject,CallType,Contact_Person__c, Contact_Person__r.Name,Contact_Person__r.LastName,Contact_Person__r.FirstName,
                             DateTime_of_Meeting__c,Description,Follow_Up__c,Id,IsClosed,Meeting_Call_Purpose__c,Meeting_Call_status__c,
                             OwnerId,Process_Attribute_Details__c,Stage__c,Status,Subject,TaskSubtype,
                             WhatCount,WhatId,WhoCount,Process_Attribute_Details__r.Action_Type__c,Process_Attribute_Details__r.Action_URL__c,
                             Process_Attribute_Details__r.Task_Automation__c,Parent_Task_Id__c,Process_Attribute_Details__r.Is_Review_Task__c,
                             Process_Attribute_Details__r.Process_Component__c,Process_Path_Task_Detail__r.Action_URL__c,Process_Path_Task_Detail__r.Action_Type__c,Owner.Name
                             FROM Task Where Id=:TaskRec.Parent_Task_Id__c ];
            wrapTask.taskRec = parentTaskRec;
            wrapTask.isParentTask = false;
            wrapTask.currentRecordId = TaskRec.Id;
            return wrapTask;
            
        }
        wrapTask.taskRec = TaskRec;
        wrapTask.isParentTask = true;
        wrapTask.currentRecordId = TaskRec.Id;
        return wrapTask;
        //return TaskRec;
    }
    
    Public Class WrapperTaskAction{
        @AuraEnabled
        Public Task taskRec{get;set;}
        @AuraEnabled
        Public Boolean isParentTask{get;set;}
        @AuraEnabled
        public Id currentRecordId{get;set;}
    }
    
    
}