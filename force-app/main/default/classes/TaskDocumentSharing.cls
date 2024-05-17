public without sharing class TaskDocumentSharing {
    
    @InvocableMethod(label='TaskDocumentSharing' description='TaskDocumentSharing - Task List for which documents are to be shared')
    public static void TaskDocumentSharing(List<Task> inp_parms) {
        
        list<Task> cv_Tasks = new List<Task>();
        map<string,List<Task>> mv_sObjectPAId_Tasks_inp = new map<string,List<Task>>();
        map<string,List<Task>> mv_sObjectPAId_Tasks_related = new map<string,List<Task>>();
        map<string,set<string>> mv_PADocumentDetailId_ProcessTaskIds = new map<string,set<string>>();
        map<string,set<string>> map_taskid_dhids = new  map<string,set<string>>();
        
        set<string> s_sobjectid = new set<string>();
        set<string> s_paid = new set<string>();
        set<string> s_taskid_related = new set<string>();
        set<string> s_PADocumentDetail = new set<string>();
        
        string v_query;
        
        for (task lv_task:inp_parms)
        {
            string key;
            if (lv_task.Process_Attribute_Object_Type__c == 'Lead' || lv_task.Process_Attribute_Object_Type__c == 'Contact')
            {
                key = lv_task.whoid +'-'+lv_task.Process_Attribute__c;
                s_sobjectid.add(lv_task.whoid);  
            }
            
            else
            {
                key = lv_task.whatid +'-'+lv_task.Process_Attribute__c;//map key
                s_sobjectid.add(lv_task.whatid);  
            }
            s_paid.add(lv_task.Process_Attribute__c);
            
            if (!mv_sObjectPAId_Tasks_inp.containskey(key))
            {
                mv_sObjectPAId_Tasks_inp.put(key,new list<task>{lv_task});
            }
            else
            {
                mv_sObjectPAId_Tasks_inp.get(key).add(lv_task);
                //mv_sObjectPAId_Tasks_inp.put(key,(list<task>) mv_sObjectPAId_Tasks_inp.get(key).add(lv_task));
                
            }
            
        }
        map<id,task> map_tasks_related = new map<id,task>();
        system.debug('s_paid::'+s_paid);
        system.debug('s_sobjectid::'+s_sobjectid);
        v_query = 'Select id,whoid,whatid,Process_Attribute__c,Process_Attribute_Object_Type__c,Process_Attribute_Path_Deviation__c,Process_Attribute_Path_Deviation__r.Document_Sharing_Status__c from task where Process_Path_Task_Detail__c != null and Process_Attribute__c in : s_paid and ((whatid in : s_sobjectid and whatid != null) or (whoid in : s_sobjectid and whoid != null))';
        map_tasks_related.putAll(new Map<Id, task>((List<task>) Database.query(v_query)));
        
        
        for(task lv_task:map_tasks_related.values())
        {
            string key;
            if (lv_task.Process_Attribute_Object_Type__c == 'Lead' || lv_task.Process_Attribute_Object_Type__c == 'Contact')
            {
                key = lv_task.whoid +'-'+lv_task.Process_Attribute__c;
            }
            else
            {
                key = lv_task.whatid +'-'+lv_task.Process_Attribute__c;
            }
            
            if (mv_sObjectPAId_Tasks_inp.containskey(key))
            {
                s_taskid_related.add(lv_task.id);
            }
            
        }
        system.debug(s_taskid_related);
        list<Document_Handler__c> l_DocumentHandler = new list<Document_Handler__c>();
        
        v_query ='select id,Process_Attribute_Dcoument_Detail__c,Task_Id__c,Document_Sharing_Task_Ids__c,status__c,Current_Task_ID__c from Document_Handler__c where Task_Id__c in :s_taskid_related';
        l_DocumentHandler = Database.query(v_query);
        
        for(Document_Handler__c lv_dh : l_DocumentHandler )
        {
            s_PADocumentDetail.add(lv_dh.Process_Attribute_Dcoument_Detail__c);
            
            /*set<string> s_docsharetaskids = new set<string>(lv_dh.Document_Sharing_Task_Ids__c.split(','));

for (string lv_docsharetaskid:s_docsharetaskids)
{
if(!map_taskid_dhids.containskey(lv_docsharetaskid))
{
map_taskid_dhids.put(lv_docsharetaskid,new set<string>{lv_dh.id});
}
else
{
set<string> temp_dhids = new set<string>(map_taskid_dhids.get(lv_docsharetaskid));
temp_dhids.add(lv_dh.id);
map_taskid_dhids.put(lv_docsharetaskid,temp_dhids);
}
}*/
        }
        
        list<Process_Task_Document_Sharing__c> l_ProcessTaskDocumentSharing = new list<Process_Task_Document_Sharing__c>();
        v_query ='select id,Process_Attribute_Dcoument_Detail__c,Process_Task_Detail__c from Process_Task_Document_Sharing__c where Process_Attribute_Dcoument_Detail__c in :s_PADocumentDetail';
        l_ProcessTaskDocumentSharing = Database.query(v_query);
        
        for(Process_Task_Document_Sharing__c lv_ptds:l_ProcessTaskDocumentSharing)
        {
            string key = lv_ptds.Process_Attribute_Dcoument_Detail__c;
            set<String> s_existingPTD = new set<String>();
            if (!mv_PADocumentDetailId_ProcessTaskIds.containskey(key))
            {
                s_existingPTD.add(lv_ptds.Process_Task_Detail__c);
                mv_PADocumentDetailId_ProcessTaskIds.put(key,s_existingPTD);
            }
            else
            {
                s_existingPTD.addall(mv_PADocumentDetailId_ProcessTaskIds.get(key));
                s_existingPTD.add(lv_ptds.Process_Task_Detail__c);
                mv_PADocumentDetailId_ProcessTaskIds.put(key,s_existingPTD);
            }
            
        }
        system.debug(mv_PADocumentDetailId_ProcessTaskIds);
        set<string> s_DH_upd = new set<string>();
        set<id> s_ToBeOpenTaskIds = new set<id>();
        
        for (task lv_task:inp_parms)
        {
            
            string lv_task_share_doc_status;
            
            system.debug('lv_task ===> ' + lv_task);
            if(map_tasks_related.containskey(lv_task.id)){
                if(map_tasks_related.get(lv_task.id).get('Process_Attribute_Path_Deviation__c') !=null && map_tasks_related.get(lv_task.id).getsobject('Process_Attribute_Path_Deviation__r').get('Document_Sharing_Status__c') != null){
                    lv_task_share_doc_status = (string) map_tasks_related.get(lv_task.id).getsobject('Process_Attribute_Path_Deviation__r').get('Document_Sharing_Status__c');
                }                
            }
            
            
            system.debug('lv_task::'+lv_task);
            
            /*Set<String> DocToBeSharedWithTaskids = new Set<String>();
if (lv_task.Process_Share_Document_Task_Ids__c != null)
{
DocToBeSharedWithTaskids.addall(lv_task.Process_Share_Document_Task_Ids__c.split(','));
DocToBeSharedWithTaskids.remove(null);
DocToBeSharedWithTaskids.remove('null');

}*/
            
            system.debug(lv_task.Process_Share_Document_Task_Ids__c);
            for (Document_Handler__c lv_dh:l_DocumentHandler)
            {
                set<string> s_dhsharingtaskid = new set<string>();
                if (lv_dh.Document_Sharing_Task_Ids__c != null)
                {
                    s_dhsharingtaskid.addall(lv_dh.Document_Sharing_Task_Ids__c.split(','));
                    s_dhsharingtaskid.remove(null);
                    s_dhsharingtaskid.remove('null');
                }
                
            string lv_task_share_doc_status_old;
                
            if(map_tasks_related.containskey(lv_dh.Current_Task_ID__c)){
                if(map_tasks_related.get(lv_dh.Current_Task_ID__c).get('Process_Attribute_Path_Deviation__c') !=null && map_tasks_related.get(lv_dh.Current_Task_ID__c).getsobject('Process_Attribute_Path_Deviation__r').get('Document_Sharing_Status__c') != null){
                    lv_task_share_doc_status_old = (string) map_tasks_related.get(lv_dh.Current_Task_ID__c).getsobject('Process_Attribute_Path_Deviation__r').get('Document_Sharing_Status__c');
                }                
            }
                system.debug(lv_dh.Current_Task_ID__c);
                
                if (lv_task_share_doc_status != null && lv_dh.Current_Task_ID__c != null && lv_task.Process_Share_Document_Task_Ids__c.contains(lv_dh.Current_Task_ID__c))
                {
                    system.debug('lv_dh::'+lv_dh);
                    if ( lv_dh.status__c == lv_task_share_doc_status )
                    {
                        lv_dh.Current_Task_ID__c = lv_task.id;
                        s_dhsharingtaskid.add(lv_task.id);
                        s_DH_upd.add(lv_dh.id);      
                    }
                    else If(lv_task.Process_Share_Document_Task_Ids__c.contains(lv_dh.Current_Task_ID__c) && lv_dh.status__c == lv_task_share_doc_status_old)
                    {
                        s_ToBeOpenTaskIds.add(lv_dh.Current_Task_ID__c);
                    }
                    
                }  
                /*else {
s_dhsharingtaskid.add(lv_task.id);
s_DH_upd.add(lv_dh.id); 
}*/
                set<string> s_ProcessTaskIds = new set<string>();  
                if (mv_PADocumentDetailId_ProcessTaskIds.containskey(lv_dh.Process_Attribute_Dcoument_Detail__c))
                {
                    
                    s_ProcessTaskIds.addall(mv_PADocumentDetailId_ProcessTaskIds.get(lv_dh.Process_Attribute_Dcoument_Detail__c));
                }
                if (s_ProcessTaskIds.contains(lv_task.Process_Task_Detail__c))
                {
                    s_dhsharingtaskid.add(lv_task.id);
                    s_DH_upd.add(lv_dh.id);
                }
                
                lv_dh.Document_Sharing_Task_Ids__c = String.join(new List<String>(s_dhsharingtaskid), ',') +',';
                
            }
        } 
        
        List<Document_Handler__c> l_DH_upd = new list<Document_Handler__c>();
        List<Task> l_Task_upd = new list<Task>();
        
        for (Document_Handler__c lv_dh:l_DocumentHandler)
        {
            if (s_DH_upd.contains(lv_dh.id))
            {
                system.debug('lv_dh final::'+lv_dh);
                l_DH_upd.add(lv_dh);
            }
            
        }
        
        if (l_DH_upd.size() > 0)
        {
            update l_DH_upd;
        }
        
        /*Commented Date 30/04/2024
         * if (s_ToBeOpenTaskIds.size() > 0)
        {
            for (id lv_tempid:s_ToBeOpenTaskIds)
            {
                task task_upd = new task();
                task_upd.id = lv_tempid;
                task_upd.status = 'Open';
                l_Task_upd.add(task_upd);
            }
            //update l_Task_upd;
        }*/
        
    }
}