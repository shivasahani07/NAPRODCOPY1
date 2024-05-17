public with sharing class TaskCreationFromPAD {
    public class FlowInput{
        @InvocableVariable public sObject inp_record;
    }
    
    public class TaskDetails{        
        public Id sObject_Id;
        public ID Process_Attribute_Id;
    }
    
    public static map<String,String> map_Owner_QueueType = new map<String,String>();
    public static map<String,String> map_Owner_TaskOwnerType = new map<String,String>();
    public static map<id,sObject> map_sObject = new map<id,sObject>();
    public static map<Id,sObject> map_PAD = new map<Id,sObject>();
    public static Map<Id,String>	 map_PAID_PA_RecordType_Name			= new Map<Id,String>();	// Map of PA Id with Sobject RecordType Name
    //public static map<String,sObject> map_Task_Previous = new map<String,sObject>();
    public static map<String,Task> map_Task_New = new map<String,Task>();
    
    
    @InvocableMethod public static void CreateTask(List<FlowInput> params){  
        //Variable declaration        
        
        map<String,Task> map_TaskDetails = new map<String,Task>();
        Task rv_TaskDetails = new Task();
        Set<ID> s_assign_PAD_Ids = new Set<ID>();
        
        Map<ID, sObject> map_Existing_Tasks = new Map<ID, sObject>();
        Map<ID, sObject> map_Dependent_PAD_Ids = new Map<ID, sObject>();
        Map<ID, sObject> map_Configured_and_Dependent_PAD_Ids = new Map<ID, sObject>();
        
        string query;
        string v_sObject_name;
        string v_sObject_Id;
        string v_Process_Attribute_Id;
        
        string v_PAD_Id;
        string v_key;
        string v_task_owner_type;
        string v_task_owner_name;
        
        
        boolean b_Dependent_Size;
        
        set<id> s_inp_sObject_Ids = new Set<id>();
        set<id> s_inp_Process_Attribute_Ids = new Set<id>();
        set<String> s_sObject_Id_Process_Attribute_Ids = new Set<String>();        
        set<id> s_ToBeCreated_PAD_Ids = new Set<id>();
        set<String> s_Processed_PAD_Ids = new Set<String>();
        
        //Functionality Start
        
        v_sObject_name = params[0].inp_record.id.getSObjectType().getDescribe().getName();
        //map_sObject = new map<Id,List<FlowInput>> ((List<FlowInput>) params.getSobjects('FlowInput'));
        for (FlowInput param:params)
        {
            
            v_Process_Attribute_Id = (string) param.inp_record.get('process_attribute__c');
            v_sObject_Id = param.inp_record.id;
            
            s_sObject_Id_Process_Attribute_Ids.add(v_sObject_Id + '-' + v_Process_Attribute_Id);
            s_inp_sObject_Ids.add(v_sObject_Id);
            s_inp_Process_Attribute_Ids.add(v_Process_Attribute_Id);
            map_sObject.put(v_sObject_Id,param.inp_record);
            
        }
        system.debug(s_inp_sObject_Ids);
        system.debug(s_inp_Process_Attribute_Ids);
        
        //Get all the existing tasks from the triggered objects where Process Attribute id matches
        //If no records, then Get all active records from Process Attribute Details where Process Attribute id matches and Depend_On_Process_Attribute_Details__c is null else below steps
        
        system.debug('v_sObject_name ====> ' + v_sObject_name);
        system.debug('s_inp_sObject_Ids ====> ' + s_inp_sObject_Ids);
        system.debug('s_inp_Process_Attribute_Ids ====> ' + s_inp_Process_Attribute_Ids);
        query = 'Select id,process_attribute__c,ownerid,(select id,Process_Attribute_Details__r.Name, Process_Attribute_Details__c,isclosed,ownerid from tasks order by createddate desc ) from '+ v_sObject_name + ' where id in : s_inp_sObject_Ids and Process_Attribute__c in : s_inp_Process_Attribute_Ids';
        map_Existing_Tasks = new Map<ID, sObject>((List<sObject>)Database.query(query));
        
        system.debug('map_Existing_Tasks ====> ' + map_Existing_Tasks);
        
        //Get all active records from the Process Dependent Task Details where  Process Attribute id matches
        //Get all active records from Process Attribute Details where Process Attribute id matches and not in either curent tasks and dependent taks list and Depend_On_Process_Attribute_Details__c is not null
        
        query = 'Select id,Sobject_RecordType_Name__c,(select id,Name,SLA__c,Process_Attribute__c,Task_Subject__c,Task_Owner_Type__c,Task_Owner_Name__c,Sobject_Recordtype__c from Process_Attribute_Details__r where isActive__c = true and Task_Automation__c = true),(select id,Current_Process_Attribute_Details__c,Depend_On_Process_Attribute_Details__c from Process_Dependent_Task_Details__r where isActive__C = true ) from Process_Attribute__c where id in : s_inp_Process_Attribute_Ids';
        map_Configured_and_Dependent_PAD_Ids = new Map<Id, sObject>((List<sObject>)Database.query(query));
        
        
        for(Id pa_Sobject_Id : map_Configured_and_Dependent_PAD_Ids.keySet()){
            system.debug('map_Configured_and_Dependent_PAD_Ids.get(pa_Sobject_Id)::'+map_Configured_and_Dependent_PAD_Ids.get(pa_Sobject_Id).get(Schema.Process_Attribute__c.Sobject_RecordType_Name__c));
            if(map_Configured_and_Dependent_PAD_Ids.get(pa_Sobject_Id).get(Schema.Process_Attribute__c.Sobject_RecordType_Name__c) != null){
                map_PAID_PA_RecordType_Name.put(pa_Sobject_Id,String.valueOf(map_Configured_and_Dependent_PAD_Ids.get(pa_Sobject_Id).get(Schema.Process_Attribute__c.Sobject_RecordType_Name__c)));
            }
            
        }
        system.debug('map_PAID_PA_RecordType_Name::'+map_PAID_PA_RecordType_Name);
        //Segregate the above list into Open task map and closed task map
        
        for (Id lp_sObject_Id : map_Existing_Tasks.keySet()) {
            v_Process_Attribute_Id = (string) map_Existing_Tasks.get(lp_sObject_Id).get('Process_Attribute__c');
            v_key = lp_sObject_Id + '-' + v_Process_Attribute_Id;
            
            
            if (s_sObject_Id_Process_Attribute_Ids.contains(v_key))
            {
                
                if (s_inp_Process_Attribute_Ids.contains(v_Process_Attribute_Id))
                {
                    system.debug('map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id) ======> ' + map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id) );
                    system.debug('map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id).getSobjects(Process_Attribute_Details__r) ======> ' + map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id).getSobjects('Process_Attribute_Details__r') );
                    
                    if(map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id).getSobjects('Process_Attribute_Details__r') != null){
                        map_PAD.putAll(new map<Id,sobject> (map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id).getSobjects('Process_Attribute_Details__r')));
                    }
                    
                    
                    
                    s_inp_Process_Attribute_Ids.remove(v_Process_Attribute_Id);
                }
                
                system.debug('');
                if(map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id).getSobjects('Process_Attribute_Details__r') != null){
                    s_ToBeCreated_PAD_Ids = (new Map<Id,SObject>(map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id).getSobjects('Process_Attribute_Details__r')).keySet());
                }
                
                map_Dependent_PAD_Ids = new Map<Id,SObject>();
                if ((map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id).getSobjects('Process_Dependent_Task_Details__r')) != null)
                {
                    map_Dependent_PAD_Ids = new Map<Id,SObject>(map_Configured_and_Dependent_PAD_Ids.get(v_Process_Attribute_Id).getSobjects('Process_Dependent_Task_Details__r'));
                    b_Dependent_Size = true;
                }               
                
                for ( task lp_task : map_Existing_Tasks.get(lp_sObject_Id).getSobjects('Tasks'))
                    
                {
                    
                    v_PAD_Id = (string) lp_task.get('Process_Attribute_Details__c');
                    
                    if (!s_Processed_PAD_Ids.contains(lp_sObject_Id +'-' +v_PAD_Id))
                    {
                        
                        s_Processed_PAD_Ids.add(lp_sObject_Id + '-' +v_PAD_Id);
                        map_Owner_TaskOwnerType.put(lp_sObject_Id +'-' + lp_task.Process_Attribute_Details__r.Name ,lp_task.OwnerId);
                        //map_Task_Previous.put(lp_sObject_Id +'-' +  v_PAD_Id ,lp_task);
                        
                        s_ToBeCreated_PAD_Ids.remove(v_PAD_Id);
                        
                        if (lp_task.get('Isclosed') == false)
                        {
                            
                        }
                        else
                        {
                            
                            for (id lp_Dependent_PAD_Id : map_Dependent_PAD_Ids.keyset())
                            {
                                if (map_Dependent_PAD_Ids.get(lp_Dependent_PAD_Id).get('Depend_On_Process_Attribute_Details__c') == v_PAD_Id)
                                    map_Dependent_PAD_Ids.remove(lp_Dependent_PAD_Id);
                            }
                            
                        }
                    }  
                }
                
                //Removing the dependt task from tasks to be created
                
                for (id lp_PAD_Id : map_Dependent_PAD_IDs.keyset())
                {
                    s_ToBeCreated_PAD_Ids.remove((string) map_Dependent_PAD_Ids.get(lp_PAD_Id).get('Current_Process_Attribute_Details__c'));
                }
                
                system.debug(s_ToBeCreated_PAD_Ids);
                for (Id lp_PAD_ID : s_ToBeCreated_PAD_Ids)
                {
                    
                    v_task_owner_type = (string) map_PAD.get(lp_PAD_ID).get('Task_Owner_Type__c');
                    v_task_owner_name = (string) map_PAD.get(lp_PAD_ID).get('Task_Owner_Name__c');
                    
                    Task rv_Task_New = new Task();
                    if (v_sObject_name == 'Lead')
                        rv_Task_New.WhoId = lp_sObject_Id;
                    else if (v_sObject_name == 'Case'|| v_sObject_name == 'Opportunity')
                        rv_Task_New.WhatId = lp_sObject_Id;
                    rv_Task_New.Process_Attribute_Details__c = lp_PAD_ID;
                    rv_Task_New.OwnerId = (string) map_Existing_Tasks.get(lp_sObject_Id).get('ownerid');   
                    if ( v_task_owner_type == 'Queue' && !map_Owner_QueueType.containskey(v_task_owner_name))
                    { 
                        map_Owner_QueueType.put(v_task_owner_name,'');
                    }
                    else if ( v_task_owner_type == 'Task Owner' && map_Owner_TaskOwnerType.containskey(lp_sObject_Id +'-' + v_task_owner_name))
                    {
                        rv_Task_New.OwnerId = (string) map_Owner_TaskOwnerType.get(lp_sObject_Id +'-' + v_task_owner_name );
                    }
                    else if ( v_task_owner_type == 'System')
                    {
                        rv_Task_New.OwnerId = System.Label.Integration_User_ID;
                    }
                    map_Task_New.put(v_key +'-'+lp_PAD_ID,rv_Task_New);	
                }
            }            
        }
        
        new AssignTask();
        
    }
    
    public class AssignTask{
        @InvocableVariable public List<sObject> out_lv_task;
        public AssignTask() {
            
            string query;
            string v_sObject_Id;
            string v_PAD_Id;
            
            if (map_Owner_QueueType.size() > 0 )
            {
                List<Group> lv_Group_Temp = new List<Group>();
                lv_Group_Temp = [Select id,Name from group where type='Queue' and Name in : map_Owner_QueueType.keySet()];
                for (Group lp_Group:lv_Group_Temp)
                {
                    if(map_Owner_QueueType.containsKey(lp_Group.Name))
                        map_Owner_QueueType.put(lp_Group.Name,lp_Group.Id);                    
                }
                
            }
            system.debug(map_Task_New);
            
            for (string lp_Task_New : map_Task_New.keyset() )
            {
                
                v_PAD_Id = (string) lp_Task_New.split('-', 3)[2];
                map_Task_New.get(lp_Task_New).ActivityDate = Date.today().addDays(Integer.valueOf(map_PAD.get(v_PAD_Id).get('SLA__c')));
                map_Task_New.get(lp_Task_New).Current_Attempt_No__c = 1;
                //map_Task_New.get(lp_Task_New).Initiated_Date__c = Date.today();
                map_Task_New.get(lp_Task_New).Subject = (string) (map_PAD.get(v_PAD_Id).get('Task_Subject__c'));
                system.debug('Task Recordtype::'+(string) (map_PAD.get(v_PAD_Id).get('Sobject_Recordtype__c')));
                if((string) (map_PAD.get(v_PAD_Id).get('Sobject_Recordtype__c')) != null){
                    map_Task_New.get(lp_Task_New).RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(String.valueOf(map_PAD.get(v_PAD_Id).get('Sobject_Recordtype__c'))).getRecordTypeId();
                }
                /*if(map_PAID_PA_RecordType_Name != null){
if(String.valueOf(map_PAD.get(v_PAD_Id).get('Process_Attribute__c')) != null &&  map_PAID_PA_RecordType_Name.get(String.valueOf(map_PAD.get(v_PAD_Id).get('Process_Attribute__c'))) != null){
system.debug('String.valueOf(map_PAD.get(v_PAD_Id).get(Process_Attribute__c)) ====> ' + String.valueOf(map_PAD.get(v_PAD_Id).get('Process_Attribute__c')));
if(Schema.SObjectType.Task.getRecordTypeInfosByName().get(map_PAID_PA_RecordType_Name.get(String.valueOf(map_PAD.get(v_PAD_Id).get('Process_Attribute__c')))).getRecordTypeId() != null){//Dynamic object name change -> Task
map_Task_New.get(lp_Task_New).RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(map_PAID_PA_RecordType_Name.get(String.valueOf(map_PAD.get(v_PAD_Id).get('Process_Attribute__c')))).getRecordTypeId();//Change Object wise from task;;;;
}
}     
}*/
                system.debug('map_Owner_QueueType.get((string)'+map_Owner_QueueType.get((string) map_PAD.get(v_PAD_Id).get('Task_Owner_Name__C')));
                if (map_PAD.get(v_PAD_Id).get('Task_Owner_Type__c') == 'Queue')
                    map_Task_New.get(lp_Task_New).OwnerId = (string) map_Owner_QueueType.get((string) map_PAD.get(v_PAD_Id).get('Task_Owner_Name__C'));  
                
            }
            system.debug(map_Task_New.values());
            upsert map_Task_New.values();
            this.out_lv_task = map_Task_New.values();
        }
    }
    
    public class AssignTaskOwner {
        string out_v_ownerId;
        public string AssignTaskOwner(Process_Attribute_Details__c inp_rv_PAD){
            this.out_v_ownerId = '';
            return out_v_ownerId;
        }
    }
    
}