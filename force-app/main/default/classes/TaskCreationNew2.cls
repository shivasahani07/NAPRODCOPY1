public class TaskCreationNew2 {
    
    public static map<string,sobject>  map_start_task = new map<string,sobject>();
    public static map<string,sobject>  map_start_task_No_Child = new map<string,sobject>();
    public static map<string,sobject>  map_end_task = new map<string,sobject>();
    public static map<string,Task>  map_new_task = new map<string,Task>();
    
    public class SObjectTaskWrapper {
        @InvocableVariable(label='SObject' description='SObject id for which new tasks will be created')
        public SObject inp_sObject;
    }
    
    @InvocableMethod(label='SObject id for which new tasks will be created' description='sobject id for which new tasks will be created')
    public static List<String> SObjectNewTaskCreation(List<SObjectTaskWrapper> inp_parms) 
    {
        system.debug('inp_parms--->'+inp_parms);
        list<string> l_return = new list<string>();
        set<string> inp_sobjectids = new set<string>();
        set<string> inp_taskids = new set<string>();
        string inp_ObjectType = inp_parms[0].inp_sObject.id.getSObjectType().getDescribe().getName();
        system.debug('inp_ObjectType--->'+inp_ObjectType);
        
        map<string,sobject> out_sobject = new map<string,sobject>();        
        
        string v_query;
        
        
        
        for (SObjectTaskWrapper inp_parm : inp_parms)
        {
            if (inp_ObjectType != 'Task')
                inp_sobjectids.add((string) inp_parm.inp_sObject.get('id'));
            else
                inp_taskids.add((string) inp_parm.inp_sObject.get('id'));
            
        }
        
        if (inp_sobjectids.size() > 0)
        {
            v_query = 'select id,Process_Attribute__c, Process_Attribute__r.Object_Type__c,Process_Attribute__r.Process_Attribute_Path_Deviation__c,Process_Attribute__r.Process_Attribute_Path_Deviation__r.Process_Path__c from ' +  inp_ObjectType +' where id in : inp_sobjectids'; 
            out_sobject.putall(new Map<string, sObject>((List<sObject>)Database.query(v_query)));
        }
        
        if (inp_taskids.size() > 0)
        {
            v_query = 'select id,Subject,whoid,whatid,Process_Attribute__c, Process_Attribute__r.Object_Type__c,Process_Attribute__r.Process_Attribute_Path_Deviation__r.Process_Path__c,Process_Path_Task_Detail__c,Process_Path_Deviation_Ids__c,Process_Path_Deviation_Ids_Executed__c,Process_Attribute_Path_Deviation__c,Process_Attribute_Path_Deviation__r.Id,Process_Attribute_Path_Deviation__r.Process_Path_Task_Detail_Start__c,Process_Attribute_Path_Deviation__r.Process_Path_Task_Detail_End__c,Process_Attribute_Path_Deviation__r.Process_Path_Type__c,Process_Path_Deviation_Initiated_Task_Id__c,Process_Path_Initiated_Task_Id__c,Process_Path_Deviation_End_Task_Id__c,Execution_Depended_on_Task_Ids__c,Execution_Depended_Closed_Task_Ids__c,Process_Share_Document_Task_Ids__c,Has_Child_Task__c,Parent_Task_Id__c  from ' +  inp_ObjectType +' where id in : inp_taskids'; 
            out_sobject.putall(new Map<string, sObject>((List<sObject>)Database.query(v_query)));
        }
        
        set<string> s_PPDids =  new set<string>();
        set<string> s_PAids =  new set<string>();
        //map<map<string,sobject>,map<string,list<sobject>>> map_PPDmap_sobjectsmap = new map<map<string,sobject>,map<string,list<sobject>>>();
        
        
        map<string,sobject> map_sobjectidPPDid_sobject = new map<string,sobject>();
        map<string,sobject> map_sobjectidPPDid_PPD = new map<string,sobject>();
        
        set<string> s_taskwithChild = new set<string>();
        
        map<string,set<String>> map_ProcessPathId_sobjectidPPDid = new map<string,set<String>>();
        map<string,sobject> map_sobjectidPPDid_sobject_final = new map<string,sobject>();
        
        //map<string,sobject> map_sobjectid_sobject = new map<string,sobject>();    
        for (sobject lv_sobject:out_sobject.values())
        {
            if (inp_ObjectType != 'Task')
            {
                system.debug(lv_sobject.getsobject('Process_Attribute__r'));
                string s_PPDevid = (string) lv_sobject.getsobject('Process_Attribute__r').get('Process_Attribute_Path_Deviation__c');
                s_PPDids.add(s_PPDevid);
                string s_PAid =  (string) lv_sobject.get('Process_Attribute__c');
                s_PAids.add(s_PAid);
                map_sobjectidPPDid_sobject.put((string) lv_sobject.get('id')+'-'+s_PPDevid,lv_sobject);
                system.debug('map_sobjectidPPDid_sobject:eachloop::'+map_sobjectidPPDid_sobject);
            }
            else
            {
                string s_PAid =  (string) lv_sobject.get('Process_Attribute__c');
                s_PAids.add(s_PAid);
                set<string> s_PPDid_new = new set<string>(((string) lv_sobject.get('Process_Path_Deviation_Ids__c')).split(','));
                s_PPDid_new.remove(null);
                s_PPDid_new.remove('null');
                if (lv_sobject.get('Has_Child_Task__c') == true)
                {
                    s_taskwithChild.add((string) lv_sobject.get('id'));
                }
                
                
                for (string lv_PPDid : s_PPDid_new )
                {
                    system.debug('lv_PPDid::'+lv_PPDid); 
                    s_PPDids.add(lv_PPDid);
                    map_sobjectidPPDid_sobject.put((string) lv_sobject.get('id')+'-'+lv_PPDid,lv_sobject);
                    system.debug('map_sobjectidPPDid_sobject:eachloop::'+map_sobjectidPPDid_sobject);
                } 
            }
            
            
        }
        system.debug('map_sobjectidPPDid_sobject::'+map_sobjectidPPDid_sobject);
        system.debug('s_PPDids::'+s_PPDids);
        map_sobjectidPPDid_PPD.putall((map<string,sobject>) checkdeviation(map_sobjectidPPDid_sobject,s_PPDids,s_PAids,s_taskwithChild));
        system.debug('map_sobjectidPPDid_PPD::'+map_sobjectidPPDid_PPD);
        if (map_sobjectidPPDid_PPD.size() == 0)
        {
            system.debug('No New Task Creation');
        }
        else
        {
            for (string lv_sobjectidPPDid:map_sobjectidPPDid_PPD.keyset())
            {
                
                //sobject temp_PPD = map_sobjectidPPDid_PPDmap.get(lv_sobjectidPPDid).values();
                string temp_PPDid = (string) map_sobjectidPPDid_PPD.get(lv_sobjectidPPDid).get('Process_Path__c');
                
                if (!map_ProcessPathId_sobjectidPPDid.containsKey(temp_PPDid))
                {
                    map_ProcessPathId_sobjectidPPDid.put(temp_PPDid,new set<string> {lv_sobjectidPPDid});
                }
                else
                {
                    set<string> temp_set = new set<string>();
                    temp_set.addall((set<string>) map_ProcessPathId_sobjectidPPDid.get(temp_PPDid));
                    temp_set.add(lv_sobjectidPPDid);
                    map_ProcessPathId_sobjectidPPDid.put(temp_PPDid,temp_set );
                }
                
                map_sobjectidPPDid_sobject_final.put(lv_sobjectidPPDid,(sobject) map_sobjectidPPDid_sobject.get(lv_sobjectidPPDid) );
                
            }
            system.debug('map_sobjectidPPDid_sobject_final::'+map_sobjectidPPDid_sobject_final);
            system.debug('map_sobjectidPPDid_PPD::'+map_sobjectidPPDid_PPD);
            system.debug('map_ProcessPathId_sobjectidPPDid::'+map_ProcessPathId_sobjectidPPDid);
            newtask(map_sobjectidPPDid_sobject_final,map_sobjectidPPDid_PPD,map_ProcessPathId_sobjectidPPDid);
        }
        return l_return;
    }
    
    public static map<string,sobject> checkdeviation(map<string,sobject> inp_sobjectidPPDid_sobject,set<string> inp_PPDids,set<String> inp_PAids,set<string> inp_taskwithChild) 
    {
        string v_query;
        string v_skipPpathDev;
        
        
        set<String> s_taskwithChild_final = new set<string>();
        map<string,sobject> map_PPathDev = new map<string,sobject>();
        map<string,sobject> map_Sobjectid_PPathDev_return = new map<string,sobject>();
        sobject so_PPathDev;
        
        list<sobject> l_PECondDet = new list<sobject>(); 
        list<sobject> l_PECondOutcome = new list<sobject>();
        
        v_query = 'Select id,Name,Process_Attribute__c,Process_Path_Task_Detail_Start__c,Process_Path_Task_Detail_End__c,Process_Execution_Condition__c,Process_Path__c,Process_Path_Type__c,Is_Document_Sharing_Path__c,Document_Sharing_Status__c,subject__c from Process_Attribute_Path_Deviation__c where id in : inp_PPDids and (Process_Attribute__c in :inp_PAids or  Process_Path_Type__c =\'Default Path\') and  isActive__c = true';
        map_PPathDev.putall(new Map<string, sObject>((List<sObject>)Database.query(v_query)));
        system.debug('inp_PPDids::'+inp_PPDids);
        system.debug('map_PPathDev::'+map_PPathDev);
        
        for (string inp_sobjectidPPDid : inp_sobjectidPPDid_sobject.keyset())
        {            
            set<string> s_PECon = new set<string>();
            //task inp_task = new task();
            map<string,sobject> temp_PPathDevmap = new map<string,sobject>();
            
            string temp_PPathDevId = inp_sobjectidPPDid.split('-')[1];
            string temp_sobjectid = inp_sobjectidPPDid.split('-')[0];
            system.debug('temp_PPathDevId::'+temp_PPathDevId);
            sobject inp_task = (sobject) inp_sobjectidPPDid_sobject.get(inp_sobjectidPPDid);
            string temp_ObjectType = inp_task.id.getSObjectType().getDescribe().getName();
            so_PPathDev =  map_PPathDev.get(temp_PPathDevId);
            
            
            system.debug(so_PPathDev);
            
            if (temp_ObjectType =='Task' && inp_task.get('Process_Path_Deviation_Ids_Executed__c') != null && ((string)inp_task.get('Process_Path_Deviation_Ids_Executed__c')).contains(temp_PPathDevId))
            {
                continue;
            }
            else
            {
                if (so_PPathDev != null && so_PPathDev.get('Process_Execution_Condition__c') != null)
                {
                    s_PECon.add((string) so_PPathDev.get('Process_Execution_Condition__c'));
                    v_query = 'Select id,Condition_Expression__c from Process_Execution_Condition_Detail__c where Process_Execution_Condition__c in : s_PECon ';
                    l_PECondDet = Database.query(v_query);
                    v_skipPpathDev = 'false';
                    
                    
                    
                    if (l_PECondDet.size ()> 0)
                    {
                        for (sobject lv_PECondDetId : l_PECondDet)
                        {
                            
                            string whatid = (String) inp_task.get('whatid');
                            string whoid = (String) inp_task.get('whoid');
                            string taskid = (String) inp_task.get('id');
                            string papdid = (string) temp_PPathDevId;
                            string parenttaskid = (String) inp_task.get('Parent_Task_Id__c');
                            string pathinitiatedtaskId= ((string)inp_task.get('Process_Path_Initiated_Task_Id__c')).left(18);
                            parenttaskid = parenttaskid == null?taskid:parenttaskid;
                            string devstatus = (string) so_PPathDev.get('Document_Sharing_Status__c');
                            String ProcessAttribute = (string) so_PPathDev.get('Process_attribute__c');
                            system.debug('expresion condition'+lv_PECondDetId.get('Condition_Expression__c'));
                            v_query = (string) lv_PECondDetId.get('Condition_Expression__c');
                            l_PECondOutcome = Database.query(v_query);
                            if (l_PECondOutcome.size() == 0){
                                v_skipPpathDev = 'true';
                                break;
                            }
                            /*if (l_PECondOutcome.size() == 0 && inp_task.getsobject('Process_Attribute_Path_Deviation__r').get('Process_Path_Type__c') != 'Child Path')
{
v_skipPpathDev = 'true';
break;
}
if (l_PECondOutcome.size() != 0 && inp_task.getsobject('Process_Attribute_Path_Deviation__r').get('Process_Path_Type__c') == 'Child Path')
{
v_skipPpathDev = 'true';
break;
}*/
                            
                        }              
                        
                    }
                    
                }
                
                if (so_PPathDev != null && (so_PPathDev.get('Process_Execution_Condition__c') == null || v_skipPpathDev == 'false'))
                {
                    //inp_task.put('Id',ts.get('Id'));
                    //temp_PPathDevmap.put((string) so_PPathDev.get('id'),(sobject) so_PPathDev);
                    map_Sobjectid_PPathDev_return.put(inp_sobjectidPPDid,so_PPathDev);
                    
                    if ( temp_ObjectType =='Task' && so_PPathDev.get('Process_Path_Type__c')== 'Child Path')
                    {
                        s_taskwithChild_final.add(temp_sobjectid);
                    }
                    v_skipPpathDev = null;
                }
                
            }
        }
        system.debug('inp_taskwithChild::'+inp_taskwithChild);
        system.debug('s_taskwithChild_final::'+s_taskwithChild_final);
        
        inp_taskwithChild.removeall(s_taskwithChild_final);
        if (inp_taskwithChild.size() > 0)
        {
            list<task> l_TaskNoChild = new list<task>();
            for (string lv_TaskIdNoChild : inp_taskwithChild)
            {
                task temp_TaskNoChild = new task();
                temp_TaskNoChild.id = lv_TaskIdNoChild;
                temp_TaskNoChild.Has_Child_Task__c = false;
                l_TaskNoChild.add(temp_TaskNoChild);
            }
            Database.update(l_TaskNoChild,true);
            
        }
        
        return map_Sobjectid_PPathDev_return;
    }
    
    public static void newtask(map<string,sobject> inp_sobjectidPPDid_sobject_final,map<string,sobject> inp_sobjectidPPDid_PPD,map<string,set<string>> inp_ProcessPathId_sobjectidPPDid) 
    {
        // Your logic here using the input variables
        
        set<string> s_inp_PPathIds = new set<string>();
        set<string> s_ProcessPathInitiatedTaskIds = new set<string>();
        set<string> s_EndProcessPathTaskDetailsIds = new set<string>();
        set<id> s_new_PPathTaskDetIds = new set<id>();
        
        map<id,sObject>  map_new_PPath = new Map<id, sObject>();
        //map<id,sObject>  map_end_Task = new Map<id, sObject>();
        map<string,sObject>  map_end_Task_final = new Map<string, sObject>();
        map<ID,sobject> map_new_PAPathDev = new Map<ID, sobject>();
        map<string,string> map_PPathDevIds = new map<string,string>();
        map<string,boolean> map_PPathDevIds_childTask = new map<string,boolean> ();
        
        string v_query;
        
        //Get all the tasks related to the paths
        
        s_inp_PPathIds.addall(inp_ProcessPathId_sobjectidPPDid.keyset());
        
        //v_query = 'Select id,(SELECT id,Execution_Serial_No__c,Process_Path__c,Process_Task_Detail__c,ED_Process_Path_Task_Detail__c,SD_Process_Path_Task_Detail__c,Subject__c,Process_Task_Detail__r.Subject__c,Task_Record_Type__c,Process_Task_Detail__r.Task_Record_Type__c,isMergeable__c FROM Process_Path_Task_Details__r where isActive__c = true order by Process_Path__c,Path_No__c,Execution_Serial_No__c ) from Process_Path__c WHERE isActive__c = true and id in : s_inp_PPathIds';		
        v_query = 'Select id,(SELECT id,Execution_Serial_No__c,Process_Path__c,Process_Task_Detail__c,ED_Process_Path_Task_Detail__c,SD_Process_Path_Task_Detail__c,Subject__c,Process_Task_Detail__r.Subject__c,Task_Record_Type__c,Process_Task_Detail__r.Task_Record_Type__c,isMergeable__c FROM Process_Path_Task_Details__r where isActive__c = true order by Process_Path__c,Path_No__c,Execution_Serial_No__c ) from Process_Path__c WHERE isActive__c = true and id in : s_inp_PPathIds';
        map_new_PPath.putall(new Map<ID, sObject>((List<sObject>)Database.query(v_query)));
        //process path by task list
        system.debug('map_new_PPath::'+map_new_PPath);
        
        //Get all the Path Deviation task  
        if (1==1)
        {   
            
            for (id lv_PpathId : map_new_PPath.keyset())
            {
                for (sobject lv_PPathTaskDet : map_new_PPath.get(lv_PpathId).getSobjects('Process_Path_Task_Details__r'))
                    
                {
                    s_new_PPathTaskDetIds.add((string) lv_PPathTaskDet.get('Id'));//Task Id;
                    system.debug('s_new_PPathTaskDetIds::'+s_new_PPathTaskDetIds);
                }
            }
            
            
            v_query = 'Select id,Process_Attribute__c,Process_Path_Task_Detail_Start__c ,Process_Path_Task_Detail_End__c,Process_Execution_Condition__c,Process_Path__c,Process_Path_Type__c  from Process_Attribute_Path_Deviation__c WHERE isActive__c = true and Process_Attribute__c != null and Process_Path_Task_Detail_Start__c in :s_new_PPathTaskDetIds';  
            map_new_PAPathDev.putall(new Map<ID, sObject>((List<sobject>)Database.query(v_query)));
            
            
            //proceess atribute path deviation
            if (map_new_PAPathDev.size() > 0)   
            {
                for (id lv_PAPathDev : map_new_PAPathDev.keyset())
                {
                    system.debug('lv_PAPathDev::'+lv_PAPathDev);
                    string key = (string) map_new_PAPathDev.get(lv_PAPathDev).get('Process_Attribute__c')+'-'+map_new_PAPathDev.get(lv_PAPathDev).get('Process_Path_Task_Detail_Start__c');
                    string temp_PPD_Ids;
                    if ((string) map_new_PAPathDev.get(lv_PAPathDev).get('Id') != null)
                    {
                        if (!map_PPathDevIds.containskey(key))
                        {
                            system.debug('map_new_PAPathDev.get(lv_PAPathDev)::'+map_new_PAPathDev.get(lv_PAPathDev));
                            map_PPathDevIds.put(key,StringToStringDeDup((string) map_new_PAPathDev.get(lv_PAPathDev).get('Id')));
                        }
                        
                        else
                        {
                            temp_PPD_Ids = StringToStringDeDup((string) map_PPathDevIds.get(key) + (string) map_new_PAPathDev.get(lv_PAPathDev).get('Id'));
                            system.debug('temp_PPD_Ids::'+temp_PPD_Ids);
                            map_PPathDevIds.put(key,temp_PPD_Ids);
                            
                        }
                        
                        if ( (string) map_new_PAPathDev.get(lv_PAPathDev).get('Process_Path_Type__c') == 'Child Path')
                        {
                            map_PPathDevIds_childTask.put(key,true);
                        }
                    }
                }
                
            }
            system.debug(map_PPathDevIds);
        }
        
        // Get all the Path end tasks
        if (1==1)
        { 
            for (sObject lv_sObject:inp_sobjectidPPDid_sobject_final.values())
            {
                string s_objectname = (string) lv_sObject.id.getSObjectType().getDescribe().getName();
                if (s_objectname == 'Task')
                {
                    s_ProcessPathInitiatedTaskIds.add((string) lv_sObject.get('Process_Path_Initiated_Task_Id__c'));
                    s_EndProcessPathTaskDetailsIds.add((string) lv_sObject.getsobject('Process_Attribute_Path_Deviation__r').get('Process_Path_Task_Detail_End__c'));
                }
                
                map_start_task.put((String) lv_sObject.get('id'),lv_sObject);
                system.debug('map_start_task::'+map_start_task);
            }
            
            v_query = 'Select id,Process_Path_Initiated_Task_Id__c,Process_Path_Task_Detail__c,Execution_Depended_on_Task_Ids__c from task WHERE Process_Path_Initiated_Task_Id__c in : s_ProcessPathInitiatedTaskIds';		
            map_end_Task.putall(new Map<string, sObject>((List<sObject>)Database.query(v_query)));
            //Task Query
            
            for (sObject lv_sobject:map_end_Task.values())
            {
                
                map_end_Task_final.put(lv_sobject.get('Process_Path_Initiated_Task_Id__c')+'-'+lv_sobject.get('Process_Path_Task_Detail__c'),lv_sobject);
                
            }
            
        }        
        // Preparing the final list of all the new tasks
        
        if (1==1)
        {
            string v_FirstPPathTaskDetID;
            
            integer v_ExexutionSerialNo ;
            list<task> l_new_tasks = new list<task>();
            List<sObject> processPathTaskDetails = new List<sObject> ();
            
            for (id lv_ProcessPathid: map_new_PPath.KeySet())
            {
                l_new_tasks = new list<task>();
                for (sobject lv_ProcessPathTaskDetail : (List<sobject>) map_new_PPath.get(lv_ProcessPathid).getSobjects('Process_Path_Task_Details__r'))
                {
                    //Map<String, Object> lv_ProcessPathTaskDetail = (Map<String, Object>) lv_ProcessPathTaskDetailObj;
                    v_ExexutionSerialNo = Integer.valueOf((string) lv_ProcessPathTaskDetail.get('Execution_Serial_No__c'));
                    v_FirstPPathTaskDetID = (v_ExexutionSerialNo == 1)?(string) lv_ProcessPathTaskDetail.get('Id'):v_FirstPPathTaskDetID;                    
                    
                    
                    
                    
                    task temptask =  new task();
                    
                    temptask.ownerId = Label.Task_Default_Onwer;
                    temptask.status = Label.Task_Status_Draft;
                    
                    string PPathTaskSubject = (string) lv_ProcessPathTaskDetail.get('subject__c');
                    string PTaskSubject = (string)  lv_ProcessPathTaskDetail.getsobject('Process_Task_Detail__r').get('Subject__c');
                    temptask.subject = (PPathTaskSubject != null) ? PPathTaskSubject : PTaskSubject;
                    temptask.attribute2__c = PTaskSubject;
                    
                    string PPathTaskRecordType = (string) lv_ProcessPathTaskDetail.get('Task_Record_Type__c');
                    string PTaskRecordType = (string)  lv_ProcessPathTaskDetail.getsobject('Process_Task_Detail__r').get('Task_Record_Type__c');
                    string RecordTypeName = (PPathTaskRecordType != null) ? PPathTaskRecordType : PTaskRecordType;
                    temptask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(String.valueOf(RecordTypeName)).getRecordTypeId();
                    
                    //Setting Up task Controlling fields
                    
                    temptask.Process_Path_Task_Detail__c = (string) lv_ProcessPathTaskDetail.get('Id') ;
                    temptask.Process_Path_Initiated_Task_Id__c = v_FirstPPathTaskDetID;
                    temptask.Execution_Depended_on_Task_Ids__c = StringToStringDeDup((string) lv_ProcessPathTaskDetail.get('ED_Process_Path_Task_Detail__c'));
                    temptask.Process_Share_Document_Task_Ids__c = StringToStringDeDup((string) lv_ProcessPathTaskDetail.get('SD_Process_Path_Task_Detail__c'));
                    
                    
                    l_new_tasks.add(temptask);
                }
                system.debug('l_new_tasks::'+l_new_tasks);
                for (string lv_SobjectPDDid : (set<string>) inp_ProcessPathId_sobjectidPPDid.get(lv_ProcessPathid))
                {
                    sobject lv_TriggeringSobject =  inp_sobjectidPPDid_sobject_final.get(lv_SobjectPDDid);
                    sobject lv_PPD =  inp_sobjectidPPDid_PPD.get(lv_SobjectPDDid);
                    
                    string inpSobjectType = lv_TriggeringSobject.Id.getSObjectType().getDescribe().getName();
                    string inpSobjectId = (string) lv_TriggeringSobject.get('id');
                    
                    string inpProcessAttribute = (string) lv_TriggeringSobject.get('Process_Attribute__c');
                    string PA_ObjectType = (string) lv_TriggeringSobject.getsobject('Process_Attribute__r').get('Object_Type__c');
                    
                    
                    string inpPADPid = (string)  lv_PPD.get('id');
                    string PPDSubject = (string)  lv_PPD.get('Subject__c');
                    
                    integer i = 0;
                    for (task lv_task1:l_new_tasks)
                    {
                        Task lv_task = new task();
                        lv_task = lv_task1.clone();
                        i = i+1;
                        system.debug('lv_task::'+lv_task);
                        lv_task.Process_Attribute__c = inpProcessAttribute;
                        if  (inpSobjectType ==  'Lead' || inpSobjectType ==  'Contact') 
                        {
                            lv_task.whoid = inpSobjectId;
                        }
                        else if (inpSobjectType == 'Opportunity' || inpSobjectType == 'Case')
                        {
                            lv_task.whatid = inpSobjectId;
                        }
                        else if (inpSobjectType == 'Task' && (PA_ObjectType == 'Lead' || PA_ObjectType == 'Contact'))
                        {
                            lv_task.whoid = (string) lv_TriggeringSobject.get('whoid');
                        }
                        else if (inpSobjectType == 'Task' && (PA_ObjectType == 'Opportunity' || PA_ObjectType == 'Case'))
                        {
                            lv_task.whatid = (string) lv_TriggeringSobject.get('whatid');
                        }
                        
                        if (map_PPathDevIds.containskey(lv_task.Process_Attribute__c +'-'+lv_task.Process_Path_Task_Detail__c))
                        {
                            
                            lv_task.Process_Path_Deviation_Ids__c = StringToStringDeDup((string) map_PPathDevIds.get(lv_task.Process_Attribute__c +'-'+lv_task.Process_Path_Task_Detail__c));
                        }
                        
                        if (map_PPathDevIds_childTask.containskey(lv_task.Process_Attribute__c +'-'+lv_task.Process_Path_Task_Detail__c))
                        {
                            lv_task.Has_Child_Task__c = true;                         
                        }
                        
                        lv_task.Process_Attribute_Path_Deviation__c = inpPADPid;
                        
                        
                        if (inpSobjectType == 'Task')
                        {
                            string inpSubject = (string) lv_TriggeringSobject.get('Subject');
                            lv_task.Process_Path_Deviation_Initiated_Task_Id__c = inpSobjectId;
                            
                            if (i == 1 && lv_PPD.get('Is_Document_Sharing_Path__c') == true)
                            {
                                lv_task.Process_Share_Document_Task_Ids__c = StringToStringDeDup(inpSobjectId);
                                string PTSubject = lv_task.attribute2__c;
                                if (PTSubject == 'Receive')
                                {
                                    PPDSubject = inpSubject.replace('Dispatch','Receive');
                                    lv_task.Subject = PPDSubject!=null?PPDSubject:lv_task.Subject;
                                }
                                else
                                {
                                    lv_task.Subject = PPDSubject!=null?PPDSubject + ' ' + PTSubject :lv_task.Subject; 
                                }
                                
                            }
                            string s_endProcessPathTaskDetailId = (string) lv_PPD.get('Process_Path_Task_Detail_End__c');
                            
                            if (s_endProcessPathTaskDetailId != null && map_end_Task_final.containskey(lv_TriggeringSobject.get('Process_Path_Initiated_Task_Id__c') +'-'+s_endProcessPathTaskDetailId))
                            {
                                sobject r_endtask = (sobject) map_end_Task_final.get(lv_TriggeringSobject.get('Process_Path_Initiated_Task_Id__c') +'-'+s_endProcessPathTaskDetailId);
                                lv_task.Process_Path_Deviation_End_Task_Id__c = (string) r_endtask.get('id');
                                
                                if ( i == l_new_tasks.size())
                                {
                                    lv_task.attribute1__c = (string) r_endtask.get('id');
                                }
                                
                                
                            }
                            if (lv_PPD.get('Process_Path_Type__c') == 'Child Path')
                            {
                                lv_task.Parent_Task_Id__c = inpSobjectId;
                                if (lv_TriggeringSobject.getsobject('Process_Attribute_Path_Deviation__r').get('Process_Path_Type__c') != 'Child Path')
                                {
                                    lv_task.Process_Path_Initiated_Task_Id__c = (string)lv_TriggeringSobject.get('id');
                                }
                                else
                                {
                                    lv_task.Process_Path_Initiated_Task_Id__c = (string)((string) lv_TriggeringSobject.get('Process_Path_Initiated_Task_Id__c')).split(',')[0];
                                }
                                
                            }
                            
                            
                        }
                        lv_task.id = null;
                        system.debug(lv_task);
                        map_new_task.put(inpSobjectId+'-'+lv_task.Process_Path_Task_Detail__c,lv_task);
                        
                        system.debug(map_new_task);
                    }
                    
                    
                }
                
                
            }
        }
        // Insert the list of Task records into the database
        if (map_new_task.size() > 0)
        {
            system.debug(map_new_task);
            Database.insert(map_new_Task.values(), true);
            
            /*Database.SaveResult[] results = Database.insert(map_new_Task.values(), false);
// iterate over the list of returned results
for(Database.SaveResult result : results) {
if(result.isSuccess()) {
System.debug('Successfully inserted Accounts : ' + result.getId());
} else {
// iterate over the failed ones
for(Database.Error error : result.getErrors()) {
System.debug('Error Status : ' + error.getStatusCode() + ' : ' + 'Error Fields : ' + error.getFields());
}
}
}*/
            
            
            
            //Preparing the update data for replace the refference values for below fields with actual taskids
            //Process_Path_Initiated_Task_Id__c
            //Execution_Depended_on_Task_Ids__c
            //Process_Share_Document_Task_Ids__c 
            
            system.debug(map_new_Task);
            map<string,task> map_temp_Task = new map<string,task>();
            map<string,sobject> map_upd_Task = new map<string,sobject>();
            set<string> s_fieldnames = new set<string>(Label.Task_ReplacePPathTaskIds.split(','));
            for (string lv_newTaskKey : map_new_Task.keyset()) 
            {
                system.debug(lv_newTaskKey);
                task temp_task = new task();
                temp_task.id = (id) map_new_Task.get(lv_newTaskKey).get('id');
                temp_task.Subject = (string) map_new_Task.get(lv_newTaskKey).get('Subject');
                temp_task.Process_Path_Deviation_Initiated_Task_Id__c = (string) map_new_Task.get(lv_newTaskKey).get('Process_Path_Deviation_Initiated_Task_Id__c');
                temp_task.Parent_Task_Id__c = (string) map_new_Task.get(lv_newTaskKey).get('Parent_Task_Id__c');
                temp_task.Process_Path_Deviation_End_Task_Id__c = (string) map_new_Task.get(lv_newTaskKey).get('Process_Path_Deviation_End_Task_Id__c');
                temp_task.attribute1__c = (string) map_new_Task.get(lv_newTaskKey).get('attribute1__c');
                
                for (string v_filednames : s_fieldnames)
                {
                    temp_task.put(v_filednames,map_new_Task.get(lv_newTaskKey).get(v_filednames));
                }
                
                
                map_temp_Task.put(lv_newTaskKey,temp_task);
            }
            for (string lv_newTaskKey : map_temp_Task.keyset()) 
            {
                system.debug(lv_newTaskKey);
                task temp_task = new task();
                temp_task = map_temp_Task.get(lv_newTaskKey);
                
                string v_sobjectid = lv_newTaskKey.split('-')[0];
                
                for (string v_filednames : s_fieldnames)
                {
                    list<string> v_PPathTaskIds = new list<string>();
                    string v_finalvalue;
                    
                    if (temp_task.get(v_filednames) != null)
                    {
                        v_PPathTaskIds = ( (string) temp_task.get(v_filednames)).split(',');                
                        for (string lv_PPathTaskId : v_PPathTaskIds)
                        {
                            if (map_temp_Task.containskey(v_sobjectid +'-'+lv_PPathTaskId))
                            {
                                task new_task = map_temp_Task.get(v_sobjectid +'-'+lv_PPathTaskId);
                                string v_tobereplacetaskid = new_task.id;
                                v_finalvalue = (v_finalvalue ==  null)? v_tobereplacetaskid  :    v_finalvalue +','+v_tobereplacetaskid;
                            }
                            else
                            {
                                v_finalvalue = (v_finalvalue ==  null)? lv_PPathTaskId  :    v_finalvalue +',' +lv_PPathTaskId;
                            }
                            
                        }
                        v_finalvalue = StringToStringDeDup(v_finalvalue);
                        temp_task.put(v_filednames,v_finalvalue);
                    }
                    
                }
                
                //Update Start Task Status
                if (temp_task.get('Subject') ==  'Start')
                {
                    temp_task.put('Status','Completed');
                }
                
                //Updated Executed Paths if Not Child
                string starttaskid = (String) temp_task.get('Process_Path_Deviation_Initiated_Task_Id__c');
                system.debug('starttaskid::'+starttaskid);
                system.debug('starttaskidtreu::'+map_start_task.containskey(starttaskid));
                if (map_start_task.containskey(starttaskid))
                {
                    sobject starttask = map_start_task.get(starttaskid);
                    String temp_task_PAPD = (string) temp_task.get('Process_Attribute_Path_Deviation__c');
                    String temp_task_ParentTaskId = (string) temp_task.get('Parent_Task_Id__c');
                    String temp_inpsObject_PAPD_ToBeExecuted = (string) starttask.get('Process_Path_Deviation_Ids__c');
                    String temp_inpsObject_PAPD_Executed = (string) starttask.get('Process_Path_Deviation_Ids_Executed__c');
                    
                    if (temp_task_ParentTaskId == null && temp_inpsObject_PAPD_ToBeExecuted.contains(temp_task_PAPD) && (temp_inpsObject_PAPD_Executed == null || !temp_inpsObject_PAPD_Executed.contains(temp_task_PAPD)))
                    {
                        string DeDupString;
                        
                        DeDupString = StringToStringDeDup(temp_inpsObject_PAPD_Executed + temp_task_PAPD);
                        starttask.put('Process_Path_Deviation_Ids_Executed__c',DeDupString);
                        map_start_task.put(starttaskid,starttask);
                        map_upd_Task.put(starttaskid,starttask);
                    }
                    else if (temp_task_ParentTaskId == starttaskid)
                    {
                        starttask.put('Has_Child_Task__c',true);
                        map_start_task.put(starttaskid,starttask);
                        map_upd_Task.put(starttaskid,starttask);
                    }
                    
                }
                // Update Depency is End Task
                {
                    
                    string endtaskid = (String) temp_task.get('Process_Path_Deviation_End_Task_Id__c');
                    if (map_end_task.containskey(endtaskid) && temp_task.get('attribute1__c') == endtaskid)
                    {
                        string DeDupString;
                        
                        sobject endtask = map_end_task.get(endtaskid);
                        DeDupString = (string) endtask.get('Execution_Depended_on_Task_Ids__c') + (string) temp_task.get('id');
                        DeDupString = StringToStringDeDup(DeDupString);
                        endtask.put('Execution_Depended_on_Task_Ids__c',DeDupString);
                        map_end_task.put(endtaskid,endtask);
                        map_upd_Task.put(endtaskid,endtask);
                    }
                }            
                map_upd_Task.put(lv_newTaskKey,temp_task);  
                
                
                
            }
            system.debug('map_upd_Task.values() ===> ' + map_upd_Task.values());
            Database.update(map_upd_Task.values(),true);
        }
    }
    public static string StringToStringDeDup(string inp_string)
    {
        string out_string;
        
        system.debug(inp_string);
        if (inp_string != null)
        {
            set<string> set_string = new set<string>(inp_string.split(','));
            set_string.remove(null);
            set_string.remove('null');
            out_string = String.join(new List<String>(set_string), ',') + ',';
            system.debug(out_string);
        }
        return out_string;
    }
} 

/*
task inp_task = new task();
inp_task.id = '00TBl000002RMo6MAG';


TaskCreationNew2.SObjectTaskWrapper cr = new TaskCreationNew2.SObjectTaskWrapper();
cr.inp_sObject = inp_task;

List<TaskCreationNew2.SObjectTaskWrapper> l = new List<TaskCreationNew2.SObjectTaskWrapper>();
l.add(cr);
TaskCreationNew2.SObjectNewTaskCreation(l);
*/