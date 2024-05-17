public without sharing class childTaskDataTable {

     @AuraEnabled
    public static List<Paybale__c> getChildTasks(Id taskId) {
        /*List<Task> taskList = new List<Task>();
        try {
            taskList = [SELECT Id, Parent_Task_Id__c, Subject, Status, Priority, Type FROM Task WHERE Parent_Task_Id__c = :taskId];
        } catch (Exception e) {
            System.debug('Error in getChildTasks: ' + e.getMessage());
        }
        return taskList;*/
        List<Task> taskList = new List<Task>();
        taskList = [SELECT Id,Process_Path_Task_Detail__c,Process_Attribute_Review_Detail__c,
        Process_Attribute_Review_Detail__r.Reviewer_Name__c 
        FROM Task 
        where ID =: taskId and Process_Attribute_Review_Detail__r.Bulk_Approval__c = true];

        if(!taskList.isEmpty()){
            return getReviewerTask(taskList);
        }
        return null;

    }

    @AuraEnabled
    Public static List<Paybale__c> getReviewerTask(List<Task> taskList){
        List<Task> taskListTobeReturn = new List<Task>();
        List<Paybale__c> payableListTobeReturn = new List<Paybale__c>();
        Set<String> setofGroupName = new Set<String>();
        List<Process_Attribute_Review_Detail__c> listOfPARD = new List<Process_Attribute_Review_Detail__c>();

        /*listOfPARD = [SELECT Id,Reviewer_Name__c From Process_Attribute_Review_Detail__c 
                        WHERE Process_Path_Task_Detail__c =: PPTDId and Bulk_Approval__c = true];*/
        If(!taskList.isEmpty()){
            /*for(Process_Attribute_Review_Detail__c pardRec : listOfPARD){
                setofGroupName.add(pardRec.Reviewer_Name__c);
            }*/
            setofGroupName.add(taskList[0].Process_Attribute_Review_Detail__r.Reviewer_Name__c);
            system.debug('setofGroupName::'+setofGroupName);
            if(!setofGroupName.isEmpty()){
                Set<Id> taskOwnerIdSet = new Set<ID>();
                
                taskOwnerIdSet = checkLoggerdInUserAccess(setofGroupName);
                system.debug('taskOwnerIdSet::'+taskOwnerIdSet);
                if(!taskOwnerIdSet.isEmpty()){
                    Set<Id> parentTaskIdSet = new Set<Id>();
                    taskListTobeReturn = [SELECT Id, Parent_Task_Id__c, Subject, Status, Priority, Type 
                    FROM Task 
                    WHERE ownerId in: taskOwnerIdSet and  status = 'Submited For Review'];
                    system.debug('taskListTobeReturn::'+taskListTobeReturn);
                    if(!taskListTobeReturn.isEmpty()){
                        Set<ID> taskIdSet = new Set<ID>();
                        Map<Id,List<Id>> mapofParentTaskIdByListOfChildTaskId = new Map<Id,List<Id>>();
                        for(Task ts : taskListTobeReturn){
                            parentTaskIdSet.add(ts.Parent_Task_Id__c);
                            if(mapofParentTaskIdByListOfChildTaskId.containsKey(ts.Parent_Task_Id__c)){
                                mapofParentTaskIdByListOfChildTaskId.get(ts.Parent_Task_Id__c).add(ts.Id);
                            }else{
                                mapofParentTaskIdByListOfChildTaskId.put(ts.Parent_Task_Id__c,new List<Id>{ts.Id});
                            }
                        }
                        system.debug('mapofParentTaskIdByListOfChildTaskId::'+mapofParentTaskIdByListOfChildTaskId);
                        List<Task> parentTaskList = new List<Task>();
                        Map<Id,String> mapOfTaskIDByTaskSubject = new Map<ID,String>();
                        parentTaskList = [select Id,Subject from Task where Id in:parentTaskIdSet];
                        for(Task ts : parentTaskList){
                            mapOfTaskIDByTaskSubject.put(ts.Id,ts.Subject);
                        }
                        system.debug('taskIdSet::'+parentTaskIdSet);
                        payableListTobeReturn = [SELECT ID,Name,Payee_Type__c,Finacial_Entity_Details__r.Name,Financial_Entity_A_C_Details__r.Bank_Account_Number__c,
                        Mode__c,Amount__c,Status__c,Task_Id__c 
                        From Paybale__c 
                        where Task_Id__c in: parentTaskIdSet];
                         
                        if(!payableListTobeReturn.isEmpty()){
                            for(Paybale__c payRec : payableListTobeReturn){
                                Id tempId = payRec.Task_Id__c;
                                payRec.Task_Id__c = mapOfTaskIDByTaskSubject.get(payRec.Task_Id__c);
                                payRec.Name = null;
                                for(ID childTaskRecId : mapofParentTaskIdByListOfChildTaskId.get(tempId)){
                                    system.debug('childTaskRecId::'+childTaskRecId);
                                    if(payRec.Name == null){
                                        payRec.Name = childTaskRecId;
                                    }else{
                                        payRec.Name = payRec.Name + ',' + childTaskRecId;
                                    }
                                }
                            }
                            system.debug('payableListTobeReturn::'+payableListTobeReturn);
                        }
                        
                    }
                }
            }
        }
        system.debug('payableListTobeReturn::'+payableListTobeReturn);
        return payableListTobeReturn;
    }

    public static Set<Id> checkLoggerdInUserAccess(Set<String> setofGroupName){
        List<Group> groupList = new List<Group>();
        Set<Id> publicGroupIdSet 	= new Set<Id>();
        Set<String> presentPublicGroupName = new Set<String>();
        Set<ID> taskOwnerIdSet = new Set<Id>();
        Map<Id,String> mapofUserIdByQueueName = new Map<Id,String>();
        Map<String,Id> mapOfQueueNameByQueueID = new Map<String,Id>();
        Id loggedInUserId = UserInfo.getUserId();
        groupList = [SELECT Id, Name,(SELECT Id,GroupId,UserOrGroupId FROM GroupMembers) 
        FROM Group 
        WHERE Type ='queue' and Name in: setofGroupName];

        if(!groupList.isEmpty()){
            for(Group g : groupList){
                mapOfQueueNameByQueueID.put(g.Name,g.Id);
                for(GroupMember gm : g.GroupMembers){
                    publicGroupIdSet.add(gm.UserOrGroupId);
                    system.debug('gm.Id::'+gm.Id);
                    mapofUserIdByQueueName.put(gm.UserOrGroupId,g.Name);
                    system.debug('mapofUserIdByQueueName::'+mapofUserIdByQueueName);
                    
                }
            }
            system.debug('publicGroupIdSet::'+publicGroupIdSet);
            if(!publicGroupIdSet.isEmpty()){
                List<GroupMember> gmList = new List<GroupMember>();
                gmList = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId in: publicGroupIdSet];
                system.debug('gmList::'+gmList);
                if(!gmList.isEmpty()){
                    for(GroupMember gm : gmList){
                        system.debug('gm.GroupId::'+gm.groupID);
                        system.debug('inside');
                        system.debug('gm.UserOrGroupId::'+gm.UserOrGroupId);
                        system.debug('loggedInUserId::'+loggedInUserId);
                        if(gm.UserOrGroupId == loggedInUserId){
                            system.debug('inside match id');
                            system.debug('mapofUserIdByQueueName.get(gm.Id)::'+mapofUserIdByQueueName.get(gm.GroupId));
                            presentPublicGroupName.add(mapofUserIdByQueueName.get(gm.GroupId));
                        }
                    }
                }
             }

             if(!presentPublicGroupName.isEmpty()){
                system.debug('presentPublicGroupName::'+presentPublicGroupName);
                for(String str : presentPublicGroupName){
                    taskOwnerIdSet.add(mapOfQueueNameByQueueID.get(str));
                }

                system.debug('taskOwnerIdSet::'+taskOwnerIdSet);
             }
        }
        return taskOwnerIdSet;

    }
    
    @AuraEnabled
    public static String approveTask(List<String> approveTaskIds) {
        try {
            Set<ID> parentTaskIdSet = new Set<Id>();
            Set<Id> whatIdSet =new Set<Id>();
            List<Task> tskList = [SELECT Id, Status,Parent_Task_Id__c,Process_Attribute_Review_Detail__c,
            Process_Attribute_Review_Detail__r.Reviewer_Name__c,Current_Review_Level__c,
            Process_Path_Task_Detail__c,WhatId,RecordTypeId,Subject  
            FROM Task WHERE Id IN :approveTaskIds];
            Decimal tempReviewLevel = 0;
            String pptdId = '';
            if(!tskList.isEmpty()){
                tempReviewLevel = tskList[0].Current_Review_Level__c + 1;
                pptdId = tskList[0].Process_Path_Task_Detail__c;
                for (Task ts : tskList) {
                    ts.Status = 'Approved';
                    parentTaskIdSet.add(ts.Parent_Task_Id__c);
                    whatIdSet.add(ts.WhatId);
                }
                update tskList;

                List<Process_Attribute_Review_Detail__c> prdfList = new List<Process_Attribute_Review_Detail__c>();
                List<Task> existingTaskList = new List<Task>();
                existingTaskList = [SELECT Id,Status,WhatId,Subject 
                FROM Task 
                where WhatID in: whatIdSet and Current_Review_Level__c =: tempReviewLevel and subject =: tskList[0].Subject];
                System.debug('existingTaskList::'+existingTaskList);
                Map<Id,Task> mapOfTaskIdByExisitngTask = new Map<Id,Task>();
                if(!existingTaskList.isEmpty()){

                    for(Task ts : existingTaskList){
                        mapOfTaskIdByExisitngTask.put(ts.WhatId,ts);
                    }

                }
                prdfList = [SELECT Id,Level__c,Reviewer_Name__c 
                FROM Process_Attribute_Review_Detail__c 
                where Process_Path_Task_Detail__c =: pptdId and Level__c =: tempReviewLevel and IsActive__c  =true];
                system.debug('prdfList::'+prdfList);
                system.debug('prdfList::true::'+!prdfList.isEmpty());
                if(!prdfList.isEmpty()){
                    Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :prdfList[0].Reviewer_Name__c].Id;
                    List<Task> taskListTobeInsert = new List<Task>();
                    for(Task dependantTask : tskList){
                        Task ts = new Task();
                        system.debug('!mapOfTaskIdByExisitngTask.isEmpty()::'+!mapOfTaskIdByExisitngTask.isEmpty());
                        system.debug('mapOfTaskIdByExisitngTask.containsKey(dependantTask.WhatId)::'+mapOfTaskIdByExisitngTask.containsKey(dependantTask.WhatId));
                        if(!mapOfTaskIdByExisitngTask.isEmpty() && mapOfTaskIdByExisitngTask.containsKey(dependantTask.WhatId)){
                            system.debug('inside existing task block::');
                            ts.Id = mapOfTaskIdByExisitngTask.get(dependantTask.WhatId).Id;
                            ts.Status = Constants.TASK_STATUS_SUBMITED_FOR_REVIEW;
                        }else{
                            ts.OwnerId                              = queueId;
                            ts.Parent_Task_Id__c                    = dependantTask.Parent_Task_Id__c;
                            ts.Subject                              = dependantTask.Subject;
                            ts.Current_Review_Level__c              = dependantTask.Current_Review_Level__c + 1;
                            ts.Status                               = Constants.TASK_STATUS_SUBMITED_FOR_REVIEW;
                            ts.Process_Attribute_Review_Detail__c   = prdfList[0].Id;
                            ts.Process_Path_Task_Detail__c          = dependantTask.Process_Path_Task_Detail__c;
                            ts.RecordTypeId                         = dependantTask.RecordTypeId;
                            ts.WhatId                               = dependantTask.WhatId;
                        }
                        

                        taskListTobeInsert.add(ts);
                    }

                    if(!taskListTobeInsert.isEmpty()){
                        upsert taskListTobeInsert;
                    }

                }else{
                    completeParentTask(parentTaskIdSet);
                }
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error in approveTask: ' + e.getMessage());
            return 'Error in approveTask: ' + e.getMessage();
        }
    }

    @future
    public static void completeParentTask(Set<ID> parentTaskIdSet){
        List<Task> taskListTobeUpdate = new List<Task>();
                    for(Id parentTaskId : parentTaskIdSet){
                        Task ts     = new Task();
                        ts.Id       = parentTaskId;
                        ts.Status   = 'Completed';
                        taskListTobeUpdate.add(ts);
                    }
                    system.debug('taskListTobeUpdate::'+taskListTobeUpdate);
                    if(!taskListTobeUpdate.isEmpty()){
                        update taskListTobeUpdate;
                    }
    }
    
    @AuraEnabled
    public static String rejectedTask(List<String> approveTaskIds) {
        try {
            Set<ID> parentTaskIdSet = new Set<Id>();
            Set<Id> whatIdSet = new Set<ID>();
            List<Task> tskList = [SELECT Id, Status,Parent_Task_Id__c,Process_Attribute_Review_Detail__c,
            Process_Attribute_Review_Detail__r.Reviewer_Name__c,Current_Review_Level__c,
            Process_Path_Task_Detail__c,WhatId,RecordTypeId,Subject
             FROM Task 
             WHERE Id IN :approveTaskIds];
             Decimal tempReviewLevel = 0;

            for (Task ts : tskList) {
                tempReviewLevel = tskList[0].Current_Review_Level__c - 1;
                ts.Status = 'Rejected';
                parentTaskIdSet.add(ts.Parent_Task_Id__c);
                whatIdSet.add(ts.whatId);
            }
            update tskList;
            List<Task> existingTaskList = new List<Task>();
                existingTaskList = [SELECT Id,Status,WhatId,Subject 
                FROM Task 
                where WhatID in: whatIdSet and Current_Review_Level__c =: tempReviewLevel and subject =: tskList[0].Subject];
                System.debug('existingTaskList::'+existingTaskList);

                if(!existingTaskList.isEmpty()){
                    for(Task ts : existingTaskList){
                        ts.status = Constants.TASK_STATUS_SUBMITED_FOR_REVIEW;
                    }

                    update existingTaskList;
                }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error in rejectedTask: ' + e.getMessage());
            return 'Error in rejectedTask: ' + e.getMessage();
        }
    }
    
 
}