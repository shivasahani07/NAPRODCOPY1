public class CommunicationAPI_Nimbus { 
    
    Public static void sendNotificationToCustomer(List<Task> taskList,Id auditRecId){
        
        system.debug('taskList::'+taskList);
        Map<Id,Id> 	mapofTaskIdByPDAId 								= new Map<Id,Id>();
        Map<Id,Process_Attribute_Details__c> 	mapofIdByPADDetails = new Map<Id,Process_Attribute_Details__c>();
        Set<Id> 	setOfPADId										= new Set<Id>();
        List<APIAuditLog.auditWrapper>			auditRecList		= new List<APIAuditLog.auditWrapper>();
        List<Task>								taskListTobeUpdate	= new List<Task>();
        Map<Id,Id>					mapofTaskIdByTaskCustomId		= new Map<Id,Id>();

        // ================== Changes For Case SMS Template ===================================
        List<Case> Caselist = New List<Case>();
        Set<Id> TaskCaseIds = new Set<Id>();
        map<Id, case> caseMap = new map<Id, case>();
        
        Notification_Auth_Details__mdt nudMetaData 	= [select Id,API_Key__c,Content_Type__c,End_Point__c,Group_Key__c,Method__c from Notification_Auth_Details__mdt
                                                       where MasterLabel = 'Notification API Auth'];
        for(Task tsk : taskList){
            mapofTaskIdByPDAId.put(tsk.Id,tsk.Process_Attribute_Details__c);
            setOfPADId.add(tsk.Process_Attribute_Details__c);

            if(tsk.WhatId != null){
                String sObjName = (tsk.whatId).getSObjectType().getDescribe().getName();
                if (sObjName == 'Case') {
                    TaskCaseIds.add(tsk.whatId);                    
                }
                
            }
        }

        if (TaskCaseIds.size() > 0) {
            Caselist = [SELECT id, Customer_Mobile_No__c, ContactMobile from case where ID IN: TaskCaseIds ];

            if (Caselist.size() > 0) {
                for (Case cas : Caselist) {
                    caseMap.put(cas.Id, cas);
                }
                
            }
        }
        system.debug('setOfPADId::'+setOfPADId);
        List<Process_Attribute_Details__c> padRecList			= [select Id,Template_Id__c,Channel_Type__c,Communication_Template__r.Channel_Type__c,
                                                                   Communication_Template__r.Nimbus_Template_Id__c from Process_Attribute_Details__c
                                                                   where id in : setOfPADId];
        
        if(!padRecList.isEmpty()){
            for(Process_Attribute_Details__c pad : padRecList){
                mapofIdByPADDetails.put(pad.Id,pad);
            }
        }
        
        if(!taskList.isEmpty()){
            for(Task tsk : taskList){
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                String endPoint = nudMetaData.End_Point__c;
                req.setEndpoint(endPoint);
                req.setMethod(nudMetaData.Method__c);
                req.setHeader('API-KEY', nudMetaData.API_Key__c);
                req.setHeader('GROUP-KEY', nudMetaData.Group_Key__c);
                req.setHeader('Content-Type',nudMetaData.Content_Type__c);
                String reqBody = '';

                if (tsk.whatId != null && (tsk.whatId).getSObjectType().getDescribe().getName() == 'Case') {
                    String SMSmobilenumber = '';
                    if(casemap.containsKey(tsk.whatId)){
                        case casrec = casemap.get(tsk.whatId);
                        SMSmobilenumber = tsk.Mobile__c;
                    }
                     reqBody = JSONGenerator.CaseSMSnotificationJSONGenerator(mapofIdByPADDetails.get(mapofTaskIdByPDAId.get(tsk.Id)),SMSmobilenumber, tsk); //tsk.Paymentlink__c
                }
                else {
                    reqBody = JSONGenerator.notificationJSONGenerator(mapofIdByPADDetails.get(mapofTaskIdByPDAId.get(tsk.Id)),tsk.Mobile__c);
                }
                System.debug('reqBody ====> ' + reqBody);
                req.setBody(reqBody);
                HttpResponse res = new HttpResponse();
                if( !Test.isRunningTest() ){
                     res = http.send(req);
                }
                
                APIAuditLog.auditWrapper auditRec = new APIAuditLog.auditWrapper();
                auditRec.taskId 		= tsk.Id;
                auditRec.padID			= mapofTaskIdByPDAId.get(tsk.Id);
                //auditRec.activityType	= 'Inbound';
                auditRec.response		= res.getBody();
                auditRec.request 		= reqBody;
                auditRec.Id				= auditRecId;
                Task tk = new Task();
                tk.Id	=	tsk.Id;
                system.debug('status code::'+res.getStatusCode());
                if(res.getStatusCode() == 201){
                    tk.Status				= 'Completed';
                    auditRec.statusCode 	= String.valueOf(res.getStatusCode());
                    auditRec.Status 		= 'Success';
                }else{
                    tk.Status				= 'Failed';
                    auditRec.statusCode 	= String.valueOf(res.getStatusCode());
                    auditRec.Status 		= 'Failed';
                }
                auditRecList.add(auditRec);
                taskListTobeUpdate.add(tk);
            }
        }
        mapofTaskIdByTaskCustomId								    = createCustomTaskRecord(taskList);
        if(!auditRecList.isEmpty()){
            APIAuditLog.createAPIAuditLog(auditRecList,mapofTaskIdByTaskCustomId);
        }
        system.debug('taskListTobeUpdate::'+taskListTobeUpdate);
        if(!taskListTobeUpdate.isEmpty()){
            //update taskListTobeUpdate;
        }
        
        
        
    }
    
    public static Map<Id,Id> createCustomTaskRecord(List<Task> taskList){
        List<Task_Custom__c> taskCustomListTobeInsert = new List<Task_Custom__c>();
        Map<Id,Id> mapofTaskIdByTaskCustomId			= new Map<Id,Id>();
        for(Task tsk : taskList){
            Task_Custom__c tc = new Task_Custom__c();
            tc.Subject__c	= tsk.Subject;
            tc.Task_Id__c	= tsk.Id;
            if(tsk.whatId != null){
                if(tsk.whatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                    tc.Opportunity__c = tsk.whatId;
                }else if(tsk.whatId.getSObjectType().getDescribe().getName() == 'Case'){
                    tc.Case__c = tsk.WhatId;
                }
            }else if(tsk.whoId != null){
                if(tsk.whoId.getSObjectType().getDescribe().getName() == 'Lead'){
                    tc.Lead__c = tsk.WhoId;
                }else if(tsk.whoId.getSObjectType().getDescribe().getName() == 'Contact'){
                    tc.Lead__c = tsk.WhoId;
                }
            }
            taskCustomListTobeInsert.add(tc);
        }
        
        if(!taskCustomListTobeInsert.isEmpty()){
            Database.SaveResult[] results = Database.insert(taskCustomListTobeInsert, false);
            
            for(Integer index = 0, size = results.size(); index < size; index++){
                mapofTaskIdByTaskCustomId.put(taskCustomListTobeInsert[index].Task_Id__c,taskCustomListTobeInsert[index].Id);
                
            }
        }
        
        return mapofTaskIdByTaskCustomId;
    }
}