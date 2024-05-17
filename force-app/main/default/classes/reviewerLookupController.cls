public without sharing class reviewerLookupController {
  
     @AuraEnabled
     Public static List<sObject> getRelatedtasks(String objectName,Task taskrecord){
        List<sObject> searchResults = new List<sObject>();
         set<Id> PPTDIds=new set<Id>();
         String query ;
         String WhatId; 
         system.debug('taskrecord'+taskrecord);
         if(taskrecord!=null && taskrecord.Id!=null && taskrecord.Process_Path_Task_Detail__c!=null){
             WhatId=taskrecord.WhatId;
             List<Process_Component_Task_Detail__c> PCTDList=[Select Id,Process_Path_Task_Detail__c,Process_Path_Task_DetailId__c,Process_Task_Detail__c From Process_Component_Task_Detail__c Where Process_Path_Task_DetailId__c=:taskrecord.Process_Path_Task_Detail__c];
             system.debug('PCTDList::'+PCTDList);
             if(!PCTDList.isEmpty()){
                 for(Process_Component_Task_Detail__c PDTDRec:PCTDList){
                     if(PDTDRec.Process_Path_Task_Detail__c!=null){
                         PPTDIds.add(PDTDRec.Process_Path_Task_Detail__c);
                     }
                 }
             }
         }
         if(objectName!=null && !PPTDIds.isEmpty() && WhatId!=null){
               query = 'SELECT Id, Subject,Process_Path_Initiated_Task_Id__c,Process_Path_Merged_Task_Ids__c FROM ' + objectName + ' WHERE Process_Path_Task_Detail__c=:PPTDIds AND WhatId=:WhatId ';
         }
         try {
             if(!String.isBlank(query)){
                  searchResults = Database.query(query);
             }
            system.debug('searchResults'+searchResults);
        } catch(Exception e) {
            // Handle exceptions if any
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        return searchResults;
     }
}