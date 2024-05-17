public class TaskReopenDocumentbulkProcessing {

    @InvocableMethod(label='TaskReopenDocumentbulkProcessing' description='TaskReopenDocumentbulkProcessing - Task List for which documents are to be shared')
    Public Static void TaskReopenDocumentbulkProcessing(List<Task> inp_parms){
         set<Id> set_taskIds=new set<Id>();
         map<string,string> map_taskId_status = new  map<string,string>();
         map<id,task> map_tasks_related = new map<id,task>();
         set<id> s_ToBeOpenTaskIds = new set<id>();
         List<Task> l_Task_upd = new list<Task>();
          for (task lv_task:inp_parms)
          {
              set_taskIds.add(lv_task.Id);
              System.debug('Adding task id: ' + lv_task.Id);
              
          }
        
        String v_query = 'Select id,whoid,whatid,Process_Attribute__c,Process_Attribute_Object_Type__c,Process_Attribute_Path_Deviation__c,Process_Attribute_Path_Deviation__r.Document_Sharing_Status__c from task where Id IN:set_taskIds';
        map_tasks_related.putAll(new Map<Id, task>((List<task>) Database.query(v_query)));
        
        System.debug('Tasks fetched: ' + map_tasks_related.size());
        
        for(Task lv_task:map_tasks_related.values())
        {
                String lv_task_share_doc_status;
                if(map_tasks_related.get(lv_task.id).get('Process_Attribute_Path_Deviation__c') !=null && map_tasks_related.get(lv_task.id).getsobject('Process_Attribute_Path_Deviation__r').get('Document_Sharing_Status__c') != null){
                    lv_task_share_doc_status = (string) map_tasks_related.get(lv_task.id).getsobject('Process_Attribute_Path_Deviation__r').get('Document_Sharing_Status__c');
                    map_taskId_status.put(lv_task.Id,lv_task_share_doc_status);
                     System.debug('Task Id: ' + lv_task.Id + ' has sharing status: ' + lv_task_share_doc_status);
                } 
        }
        
        System.debug('Task Ids with valid statuses: ' + map_taskId_status.size());

        set<string> set_tkid= new set<string>(map_taskId_status.keyset());
        set<string> set_docstatus=new set<string>(map_taskId_status.values());
        System.debug('map_taskId_status keySet(): ' + map_taskId_status.keySet());
        System.debug('Document Handler Statuses in map: ' + map_taskId_status.values());
        list<Document_Handler__c> l_DocumentHandler = new list<Document_Handler__c>();
        v_query ='select id,Process_Attribute_Dcoument_Detail__c,Task_Id__c,Document_Sharing_Task_Ids__c,status__c,Current_Task_ID__c from Document_Handler__c where Current_Task_ID__c in :set_tkid AND Status__c in :set_docstatus';
        l_DocumentHandler = Database.query(v_query);
        System.debug('Document Handlers fetched: ' + l_DocumentHandler.size());
        
        for(String lv_tkId:map_taskId_status.keyset())
        {
            for(Document_Handler__c lv_dhrecord:l_DocumentHandler)
                
            {
				System.debug('Fetched Document Handler ID: ' + lv_dhrecord.Id + ' for Task ID: ' + lv_dhrecord.Current_Task_ID__c + ' with Status: ' + lv_dhrecord.Status__c);
                if(lv_dhrecord.Current_Task_ID__c!=null && lv_dhrecord.Current_Task_ID__c==lv_tkId && lv_dhrecord.Status__c==map_taskId_status.get(lv_tkId)){
                   s_ToBeOpenTaskIds.add(lv_tkId);
                    System.debug('Matching Document Handler: Task Id ' + lv_tkId + ' with Status: ' + lv_dhrecord.Status__c);
                }
            }
        }
        
        System.debug('Tasks to be reopened: ' + s_ToBeOpenTaskIds.size());
        
        if(s_ToBeOpenTaskIds.size()>0){
            for (id lv_tempid:s_ToBeOpenTaskIds)
            {
                task task_upd = new task();
                task_upd.id = lv_tempid;
                task_upd.status = 'Open';
                l_Task_upd.add(task_upd);
                System.debug('Preparing to update Task to Open: ' + lv_tempid);
            }
            update l_Task_upd;
            System.debug('Tasks successfully updated to Open');
        }
    }
}