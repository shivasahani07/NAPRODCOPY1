public class TaskDependedClosedTaskIdsUpdate {
    
    
    // @InvocableVariable(label='TaskDependedClosedTaskIdsUpdate' description='TaskDependedClosedTaskIdsUpdate - Task List to update the depended closed Tasked Ids')
    //public List<Task> inp_sObject;
    
    @InvocableMethod(label='TaskDependedClosedTaskIdsUpdate' description='TaskDependedClosedTaskIdsUpdate - Task List to update the depended closed Tasked Ids')
    public static List<Task> TaskStatusOpen(List<Task> inp_parms) {
        
        set<String> s_sobjectid_inp = new Set<string>();
        for (task t:inp_parms)
        {
            //s_sobjectid_inp.add(t.id);
            if (t.whatid != null)
            {
                s_sobjectid_inp.add(t.whatid);
            }
            if (t.whoid != null)
            {
                s_sobjectid_inp.add(t.whoid);
            }
            
        }
        system.debug('s_sobjectid_inp::'+s_sobjectid_inp);
        list<task> l_tasks_related = new list<task>();
        string v_query = 'select id,Execution_Depended_on_Task_Ids__c,Execution_Depended_Closed_Task_Ids__c from task where whoid in :s_sobjectid_inp or whatid in: s_sobjectid_inp';
        l_tasks_related = Database.query(v_query);        
        set<id> s_updateTaskIds = new set<id>();
        list<task> l_updateTaskIds = new list<task>();
        
        for (task lv_task_inp:inp_parms)    
        {
            for (task lv_task_related:l_tasks_related)
            {
                
                if (lv_task_related.Execution_Depended_on_Task_Ids__c != null && lv_task_related.Execution_Depended_on_Task_Ids__c.contains(lv_task_inp.id))
                {
                    
                    lv_task_related.Execution_Depended_Closed_Task_Ids__c = (lv_task_related.Execution_Depended_Closed_Task_Ids__c != null) ? lv_task_related.Execution_Depended_Closed_Task_Ids__c + lv_task_inp.id + ',' : lv_task_inp.id + ',';
                    system.debug(lv_task_related.Execution_Depended_Closed_Task_Ids__c);
                    set<string> lv_Execution_Depended_on_Task_Ids = new set<string>(lv_task_related.Execution_Depended_on_Task_Ids__c.split(','));
                    lv_Execution_Depended_on_Task_Ids.remove(null);
                    lv_Execution_Depended_on_Task_Ids.remove('null');
                    system.debug('lv_Execution_Depended_on_Task_Ids::'+lv_Execution_Depended_on_Task_Ids);
                    set<string> lv_Execution_Depended_Closed_Task_Ids = new set<String>(lv_task_related.Execution_Depended_Closed_Task_Ids__c.split(','));
                    lv_Execution_Depended_Closed_Task_Ids.remove(null);
                    lv_Execution_Depended_Closed_Task_Ids.remove('null');
                    system.debug('lv_Execution_Depended_Closed_Task_Ids::'+lv_Execution_Depended_Closed_Task_Ids);
                    lv_Execution_Depended_Closed_Task_Ids.retainAll(lv_Execution_Depended_on_Task_Ids);
                    system.debug('After lv_Execution_Depended_Closed_Task_Ids::'+lv_Execution_Depended_Closed_Task_Ids);
                    lv_Execution_Depended_on_Task_Ids.retainAll(lv_Execution_Depended_Closed_Task_Ids);
                    lv_task_related.Execution_Depended_Closed_Task_Ids__c = String.join(new list<String>(lv_Execution_Depended_on_Task_Ids), ',') +',';
                    
                    s_updateTaskIds.add(lv_task_related.id);
                    //if (lv_Execution_Depended_Closed_Task_Ids.containsall(lv_Execution_Depended_on_Task_Ids))
                    //    lv_task_related.status = Label.Task_Status_Open.split(',')[0];                    
                }
                
            }
        }
        
        for (task lv:l_tasks_related)
        {
            if (s_updateTaskIds.contains(lv.id))
            {
                l_updateTaskIds.add(lv); 
            }
        }
        update l_updateTaskIds;
        return inp_parms;
        
    }
    
}