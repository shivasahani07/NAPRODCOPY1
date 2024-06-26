public class SystemSchedualMEMOGeneration {
    public static API_Callout_Audit__c auditRec = new API_Callout_Audit__c();
    
    public void CreateSystemGeneratedTask(List<String> inp_list_payableids,String inp_mode){
        Datetime currentDateTime = Date.today();
        boolean workingDay = false;
        List<Holiday_List__c> holidayList = new List<Holiday_List__c>();
        holidayList =[SELECT Id,Holiday_Date__c From Holiday_List__c WHERE Holiday_Date__c =: Date.today()];
        if(!holidayList.Isempty()){
            workingDay = false;
        }else if(currentDateTime.format('EEEE') == 'Saturday' && !WeekNumberUtility.identifyWeekNumber()){
            workingDay = true;
        }else if(currentDateTime.format('EEEE') != 'Saturday' && currentDateTime.format('EEEE') != 'Sunday'){
            workingDay = true;
        }
        
        if(workingDay){
            Process_Path_Task_Detail__c pptdDetails = new Process_Path_Task_Detail__c();
            pptdDetails = [SELECT Id,Communication_Template__c,Subject__c,Action_URL__c,Action_Type__c 
                           From Process_Path_Task_Detail__c 
                           WHERE Name ='Bulk MEMO Execution Submission'];
            Task inp_Task = new Task();
            inp_Task.Status = Constants.TASK_STATUS_DRAFT;
            inp_Task.Process_Path_Task_Detail__c = pptdDetails.Id;
            inp_Task.Subject = pptdDetails.Subject__c + '('+inp_mode+')';
            inp_Task.Attribute1__c = inp_mode;
            if(inp_list_payableids != null && !inp_list_payableids.isEmpty()){
                inp_Task.Attribute2__c = String.join(inp_list_payableids, ',');
            }
            insert inp_Task;
            system.debug('inp_Task::'+inp_Task);
            inp_Task.Process_Path_Initiated_Task_Id__c = inp_Task.Id;
            update inp_Task;
        }
    }
}