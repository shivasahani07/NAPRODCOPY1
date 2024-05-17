public class TaskTriggerHandler {
    
    public static void tagDefaultNumber(List<Task> taskList){
        Set<ID> caseIdSet = new Set<Id>();
        Map<Id,Id> mapofCaseIdByTaskId = new Map<Id,Id>();
        Map<Id,Case> mapOfCaseIdByCase = new Map<Id,Case>();
        for(Task tsk : taskList){
            if(tsk.Subject == 'Communication - Email'){
                caseIdSet.add(tsk.WhatId);
                mapofCaseIdByTaskId.put(tsk.WhatId,tsk.Id);
            }
        }
        
        if(!caseIdSet.isEmpty()){
            List<Case> caseList = [select id,Account.phone from case where id in: caseIdSet];
            for(Case cs : caseList){
                mapOfCaseIdByCase.put(cs.Id,cs);
            }
            
            for(Task tsk : taskList){
                tsk.Mobile__c = mapOfCaseIdByCase.get(tsk.whatId).Account.phone;
            }
        }
    }
    
}