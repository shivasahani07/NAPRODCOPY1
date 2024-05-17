@RestResource(urlMapping = '/create_Activity')
global without sharing class API_CreateActivity{
    public static String Classname = API_CreateActivity.class.getName(); //
    global class Response extends WS_Response{
        public Response(){
        }

        public List<cls_customer_response> Activity_status;
    }

    @HttpPost
    global static Response doPostActivity(){
        Response res = new Response();
        integer failureCount = 0;
        //List<cls_customer_response> Activity_status = new List<cls_customer_response>();
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);
            System.debug('Classname ===> ' + Classname);

            res.Activity_status = new List<cls_customer_response>();
            List<Task> TaskListTobeInserted = new List<Task>();
            if (!String.isEmpty(requestString)){

                List<object> bodyMap = (List<object>)JSON.deserializeUntyped(requestString);
                TaskWrapperDemo TaskWrap = createtaskinstance(bodyMap);
                System.debug('TaskWrap.taskListTobeInserted ====> ' + TaskWrap.taskListTobeInserted);
                System.debug('TaskWrap.TaskError_status ====> ' + TaskWrap.TaskError_status);
                    
                if (TaskWrap.taskListTobeInserted != null ){
                    System.debug('TaskWrap.taskListTobeInserted ====> ' + TaskWrap.taskListTobeInserted);
                    Database.SaveResult[] srList = Database.insert (TaskWrap.taskListTobeInserted, false);
                    System.debug('srList ====> ' + srList);

                    Map<Id, Task> TaskMap = new Map<Id, Task>(TaskWrap.taskListTobeInserted);

                    
                    for (Database.SaveResult result : srList){
                        cls_customer_response resStatusObj = new cls_customer_response();
                        System.debug('result =====> ' + result);
                        if (result.isSuccess()){
                            System.debug('Successfully inserted account. Account ID: ' + result.getId());
                            resStatusObj.SF_Recid = result.getId();
                            resStatusObj.Type = 'Activity';
                            resStatusObj.Message = Constants.API_ACTIVITY_SUCCESS;

                        } else{
                            System.debug('errors ===> ' + result.geterrors());
                            res.errorMessage = String.valueof(result.geterrors());
                            for (Database.Error err : result.getErrors()){

                                resStatusObj.SF_Recid = result.getId();
                                resStatusObj.Type = 'Activity';
                                resStatusObj.Message = err.getMessage();
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());

                            }

                        }
                        System.debug('resStatusObj =====> ' + resStatusObj);
                        res.Activity_status.add(resStatusObj);

                    }

                }
                if (TaskWrap.TaskError_status != null) {
                    res.Activity_status.addall(TaskWrap.TaskError_status);   
                    res.status = 'Error';
                    res.errorMessage = 'Some Of the Required Paramter is empty!!!! Please provide Required Fields.';
                    res.statusCode = '400';

                }

            } else{
                res.status = 'Error';
                res.errorMessage = constants.API_REQUEST_BODY_IS_NULL;
                res.statusCode = '400';
                return res;
            }

            System.debug('res ====>  ' + res);
            return res;


        } catch (Exception e){
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());
            //HandleBusinessException.captureError(Classname, 'insertLead', e, requestString);

        }
        return res;
    }

    public static TaskWrapperDemo createtaskinstance(List<object> bodyList){
        TaskWrapperDemo TaskWrap = new TaskWrapperDemo();
        System.debug('bodyList ====> ' + bodyList);
        List<Task> NewtaskList = new List<Task>();
        List<Task> TaskListwithoutWhoId = new List<Task>();
        List<cls_customer_response> TaskError_status = new List<cls_customer_response>();
        try{
             Set<String> LeadIds = new Set<String>();
             Set<String> OppIds = new Set<String>();
             Set<String> OpportunityIds = new Set<String>();
             
             Set<String> LeadExternalIds = new Set<String>();
             List<Lead> Leadlist = new List<Lead>();
             List<Opportunity> Opportunitylist = new List<Opportunity>();
             Map<String, Lead> LeadMapwithId = new Map<String, Lead>();
             Map<String, Opportunity> OppIdwithOppMap = new Map<String, Opportunity>();
             Map<String, lead> LeadMapwithExternalId = new Map<String, lead>();
             //<String, Map<string, Object>> ExternalIDwithActivityObject = new Map<String, Map<string, Object>>();

            if (!bodyList.isEmpty() && bodyList.size() > 0) {
                for (Object ActivityObj : bodyList){
                    Map<string, Object> TaskStringmap = (Map<string, Object>)ActivityObj; 
                    /*if (string.valueOf(TaskStringmap.get('WhoId')) != null && string.valueOf(TaskStringmap.get('WhoId')) != '' ) {
                        LeadIds.add(string.valueOf(TaskStringmap.get('WhoId')));
                    }*/
                    if (string.valueOf(TaskStringmap.get('WhatId')) != null && string.valueOf(TaskStringmap.get('WhatId')) != '' ) {
                        OppIds.add(string.valueOf(TaskStringmap.get('WhatId')));
                        OpportunityIds.add(string.valueOf(TaskStringmap.get('WhatId')));
                    }
                    
                }

                /*if (!LeadIds.isEmpty()) {
                    Leadlist = [Select Id,ExternalId__c, Name From Lead where Id IN: LeadIds];

                    System.debug('Leadlist =====> ' + Leadlist);
                    if (!Leadlist.isEmpty()) {
                        for (Lead  LdRec : Leadlist) {
                           LeadMapwithId.put(LdRec.id, LdRec);
                           if (LdRec.ExternalId__c != null) {
                            LeadMapwithExternalId.put(LdRec.ExternalId__c, LdRec);
                           }
                        }
                    }
                }*/

                if (!OppIds.isEmpty()) {
                    Opportunitylist = [Select Id, Name, ownerId, owner.name, owner.email From Opportunity where Id IN: OpportunityIds];

                    System.debug('Leadlist =====> ' + Leadlist);
                    if (!Opportunitylist.isEmpty()) {
                        for (Opportunity  OppRec : Opportunitylist) {
                            OppIdwithOppMap.put(OppRec.id, OppRec);
                        }
                    }
                }
                
            }
            Integer i = 1;
            if (!bodyList.isEmpty() && bodyList.size() > 0){
                for (Object ActivityObj : bodyList){

                    cls_customer_response taskerror = new cls_customer_response();
                    Map<string, Object> TaskStringmap = (Map<string, Object>)ActivityObj;
                    
                    task newTask = new task();
                    newTask.DateTime_of_Meeting__c = system.now();
                    if (string.valueOf(TaskStringmap.get('Subject')) != null && string.valueOf(TaskStringmap.get('Subject')) != ''){
                        newtask.subject = string.valueOf(TaskStringmap.get('Subject'));
                    }
                    if (date.valueOf(String.valueOf(TaskStringmap.get('ActivityDate'))) != null){
                        newtask.ActivityDate = date.valueOf(String.valueOf(TaskStringmap.get('ActivityDate')));
                    }
                    if (string.valueOf(TaskStringmap.get('Status')) != null && string.valueOf(TaskStringmap.get('Status')) != ''){
                        newtask.Status = string.valueOf(TaskStringmap.get('Status'));
                    }

                    if (string.valueOf(TaskStringmap.get('Type')) != null && string.valueOf(TaskStringmap.get('Type')) != ''){
                        newtask.Type = string.valueOf(TaskStringmap.get('Type'));
                    }
                    if (string.valueOf(TaskStringmap.get('ExternalId')) != null && string.valueOf(TaskStringmap.get('ExternalId')) != '') {
                        newtask.External_Id__c = string.valueOf(TaskStringmap.get('ExternalId'));
                    }
                    if (string.valueOf(TaskStringmap.get('Purpose')) != null && string.valueOf(TaskStringmap.get('Purpose')) != '') {
                        //newtask.Purpose__c = string.valueOf(TaskStringmap.get('Purpose'));
                        newtask.Meeting_Call_Purpose__c = string.valueOf(TaskStringmap.get('Purpose'));
                    }
                    if (TaskStringmap.containsKey('serialnumber')) {
                        if (string.valueOf(TaskStringmap.get('serialnumber')) != null && string.valueOf(TaskStringmap.get('serialnumber')) != '') {
                            //newtask.Purpose__c = string.valueOf(TaskStringmap.get('Purpose'));
                            newtask.Serialnumber__c = Decimal.valueOf((String)((TaskStringmap.get('serialnumber'))));
                        }
                    }

                    if (string.valueOf(TaskStringmap.get('WhatId')) != null && string.valueOf(TaskStringmap.get('WhatId')) != ''){
                        /*if (!LeadMapwithId.isEmpty() && LeadMapwithId.containsKey(string.valueOf(TaskStringmap.get('WhoId')))) {
                            newtask.WhoId = LeadMapwithId.get(string.valueOf(TaskStringmap.get('WhoId'))).id;
                            NewtaskList.add(newTask);
                        }*/
                        if (!OppIdwithOppMap.isEmpty() && OppIdwithOppMap.containsKey(string.valueOf(TaskStringmap.get('WhatId')))) {
                            newtask.WhatId = OppIdwithOppMap.get(string.valueOf(TaskStringmap.get('WhatId'))).id;
                            newtask.Submitted_By__c = OppIdwithOppMap.get(string.valueOf(TaskStringmap.get('WhatId'))).owner.Name;
                            newtask.Submitted_User__c = OppIdwithOppMap.get(string.valueOf(TaskStringmap.get('WhatId'))).ownerId;
                            NewtaskList.add(newTask);
                        }
                    } else{
                        TaskListwithoutWhoId.add(newTask);
                        taskerror.Message = 'Task with External Id - ' + string.valueOf(TaskStringmap.get('ExternalId')) + ' does not have WhatId. Please Provide WhatId.';
                        taskerror.SF_Recid = '';
                        taskerror.type = 'Activity';
                        TaskError_status.add(taskerror);
                    }
                }
                //TaskWrap.ExternalIDwithActivityObjectwrap = ExternalIDwithActivityObject;
            }

            if (!NewtaskList.isEmpty()){
                TaskWrap.taskListTobeInserted = NewtaskList;
            }
            else {
                TaskWrap.taskListTobeInserted = null;
            }
            if (!TaskError_status.isEmpty()){
                TaskWrap.TaskError_status = TaskError_status;
            }
            else {
                TaskWrap.TaskError_status = null;
            }

        } catch (Exception e){
            System.debug(' --- Error Msg ' + e.getMessage());
            System.debug(' --- Error LineNo ' + e.getLineNumber());

        }
        return TaskWrap;
    }

    public class TaskWrapperDemo{
        public List<Task> taskListTobeInserted{ get; set; }
        public List<Task> taskListNotTobeInserted{ get; set; }
        public List<cls_customer_response> TaskError_status{ get; set; }

    }

    class cls_customer_response{
        public String SF_Recid;
        public String type;
        public string Message;

    }

}