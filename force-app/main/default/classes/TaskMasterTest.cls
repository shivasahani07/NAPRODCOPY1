@isTest
private class TaskMasterTest {
    
    @isTest
    static void testgetPRocessAttributeDetails(){
        Process_Attribute__c ProAttribute =Testutility.createProAttributeInstance();
        ProAttribute.Case_Category__c='	Collection';
        ProAttribute.Case_Sub_Category__c=null;
        insert ProAttribute;
        
        List<Process_Attribute_Details__c> ProAttDetailsFirst =Testutility.createProAttridetailsInstance();
        for(Process_Attribute_Details__c pca:ProAttDetailsFirst){
            pca.Process_Attribute__c=ProAttribute.id;
        }
        insert ProAttDetailsFirst;
        /*Process_Task_Detail__c testPTD =TestUtility.createPTDinstance();
        insert testPTD;
        Process_Path__c  testPP=TestUtility.createProcessPAthInstance();
        insert	testPP;
        Process_Path_Task_Detail__c  testPPTD=TestUtility.createPPTD();
        testPPTD.Process_Path__c=testPP.id;
        testPPTD.Business_Step_No__c=3;
        testPPTD.Execution_Serial_No__c='4';
        testPPTD.Task_Owner_Type__c='System';
        testPPTD.Task_Owner_Name__c='Test Task Owner';
        testPPTD.Process_Task_Detail__c=testPTD.id;
        insert testPPTD;
        Process_Component__c testPC=Testutility.createPCinstance();
        testPC.active__c=true;
        testPC.Process_Task_Detail__c=testPTD.id;*/
        
        Task testTask=Testutility.CreateTaskInstance();
        insert testTask;
        //testTask.Process_Path_Task_Detail__c=testPPTD.id;
        testTask.Process_Attribute_Details__c=ProAttDetailsFirst[0].id;
        Update testTask;
        TaskMaster.ChildTaskMaster result = TaskMaster.getPRocessAttributeDetails(testTask.id);
        
    }
    @isTest
    static void testClose_ParentTask() {
        // Test setup
        Task taskRec = new Task(Subject='Test Task', Status='Not Started');
        insert taskRec;
        // Test method
        String result = TaskMaster.close_ParentTask(taskRec.Id);
        // Verify result
        System.assertEquals('SUCCESS', result);
        // Verify task status
        Task updatedTask = [SELECT Id, Status FROM Task WHERE Id = :taskRec.Id];
        System.assertEquals('Completed', updatedTask.Status);
    }
    
}