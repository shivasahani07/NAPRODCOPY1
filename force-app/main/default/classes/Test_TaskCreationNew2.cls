@IsTest
public class Test_TaskCreationNew2 {
	@IsTest
    public static void TaskCreationTestMethod(){
        Process_Attribute__c paRec = new Process_Attribute__C();
        paRec.Name = 'Opp - LAP';
        paRec.isActive__c = true;
        paRec.Sobject_RecordType_Name__c = 'Business Team LAP';
        paRec.Object_Type__c = 'Opportunity';
        insert paRec;
        
        string sObjectId = '';
        Account acc = new Account();
        acc.Name = 'Test Name';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opportunity';
        opp.CloseDate = system.today();
        opp.StageName = 'Closed Won';
        opp.Type = 'LAP Loan Application';
        opp.AccountId = acc.Id;
        opp.Process_Attribute__c = paRec.Id;
        insert opp; 
        sObjectId = opp.Id;
        
        Financial_Account__c faAccount = new Financial_Account__c();
        faAccount.Account_Name__c = acc.Id;
        faAccount.Amount__c = 5000;
        faAccount.EMI_Amount__c = 300;
        faAccount.First_EMI_Date__c = system.today();
        faAccount.Opportunity__c = opp.Id;
        insert faAccount;
        
        Communication_Template__c ctRec = new Communication_Template__c();
        ctRec.Email_From__c  = 'kispanchal86@gmail.com';
        ctRec.Email_To__c = 'kispanchal86@gmail.com';
        ctRec.Is_Active__c = true;
        ctRec.Template_Body__c = 'Test Body';
        ctRec.Email_Service__c = 'Salesforce';
        ctRec.Subject__c = 'test Subject';
        ctRec.Attachment_Query__c = 'SELECT Id From Document_Handler__c Where Task_Id__c =: parentRecId';
        ctRec.Template_Body_Query__c = 'SELECT Id,LMS_Application_ID__c,Sanction_Date__c,Sanctioned_Amount__c,Name,Tenuer__c,First_EMI_Date__c,EMI_Amount__c From Financial_Account__c where Opportunity__c =: sObjectId';
        insert ctRec;
        
        
        
        Process_path__c testDefaultPath = new Process_Path__c();
        testDefaultPath.name = 'Default Path';
        testDefaultPath.isActive__c = true;
        insert testDefaultPath;
        
        Process_Task_Detail__c testStartPTD = new Process_Task_Detail__c();
        testStartPTD.Name = 'Start';
        testStartPTD.Subject__c	 = 'Start';
        testStartPTD.Task_Record_Type__c = 'Admin';
        testStartPTD.IsActive__c = true;
        insert testStartPTD;
        
        
        Process_Path_Task_Detail__c testDeviationStartFromPPTD = new Process_Path_Task_Detail__c();
        testDeviationStartFromPPTD.name = 'Default Path - Start';
        testDeviationStartFromPPTD.Communication_Template__c = ctRec.Id;
        testDeviationStartFromPPTD.Process_Path__c = testDefaultPath.Id;
        testDeviationStartFromPPTD.Execution_Serial_No__c = String.valueOf(1);
        testDeviationStartFromPPTD.Path_No__c = 'P0';
        testDeviationStartFromPPTD.Business_Step_No__c = 1;
        testDeviationStartFromPPTD.Subject__c = 'Start';
        testDeviationStartFromPPTD.isActive__c = true;
        testDeviationStartFromPPTD.Process_Task_Detail__c = testStartPTD.Id;
        testDeviationStartFromPPTD.Task_Record_Type__c = 'API Call Out';
        testDeviationStartFromPPTD.Action_URL__c = 'SendPayableDetailsToCustomer';
        testDeviationStartFromPPTD.Action_Type__c = 'Apex';
        testDeviationStartFromPPTD.Task_Owner_Type__c = 'System';
        testDeviationStartFromPPTD.Task_Owner_Name__c = 'N/A';
        testDeviationStartFromPPTD.Execution_Serial_No__c = String.valueOf(1);
        insert testDeviationStartFromPPTD;
        
        Process_path__c testMainPath = new Process_Path__c();
        testMainPath.name = 'Main Path';
        testMainPath.isActive__c = true;
        insert testMainPath;
        
        Process_Task_Detail__c testMainPTD = new Process_Task_Detail__c();
        testMainPTD.Name = 'Document Collection';
        testMainPTD.Subject__c	 = 'Document Collection';
        testMainPTD.Task_Record_Type__c = 'Admin';
        testMainPTD.IsActive__c = true;
        insert testMainPTD;
        
        Process_Path_Task_Detail__c testDocumentCollectionPPTD = new Process_Path_Task_Detail__c();
        testDocumentCollectionPPTD.name = 'Opp - LAP : Fresh Main Path : T1';
        //testDocumentCollectionPPTD.Communication_Template__c = ctRec.Id;
        testDocumentCollectionPPTD.Process_Path__c = testMainPath.Id;
        testDocumentCollectionPPTD.Execution_Serial_No__c = String.valueOf(1);
        testDocumentCollectionPPTD.Path_No__c = 'P0';
        testDocumentCollectionPPTD.Business_Step_No__c = 1;
        testDocumentCollectionPPTD.Subject__c = 'Start';
        testDocumentCollectionPPTD.isActive__c = true;
        testDocumentCollectionPPTD.Process_Task_Detail__c = testMainPTD.Id;
        testDocumentCollectionPPTD.Task_Record_Type__c = 'Basic Task Layout';
        testDocumentCollectionPPTD.Action_URL__c = 'CMP_TaskMaster';
        testDocumentCollectionPPTD.Action_Type__c = 'Apex';
        testDocumentCollectionPPTD.Task_Owner_Type__c = 'System';
        testDocumentCollectionPPTD.Task_Owner_Name__c = 'N/A';
        testDocumentCollectionPPTD.Execution_Serial_No__c = String.valueOf(1);
        insert testDocumentCollectionPPTD;
        
        Process_path__c testEndPath = new Process_Path__c();
        testEndPath.name = 'End Path';
        testEndPath.isActive__c = true;
        insert testEndPath;
        
        Process_Task_Detail__c testEndPTD = new Process_Task_Detail__c();
        testEndPTD.Name = 'End Path';
        testEndPTD.Subject__c	 = 'End';
        testEndPTD.Task_Record_Type__c = 'Admin';
        testEndPTD.IsActive__c = true;
        insert testEndPTD;
        
        Process_Path_Task_Detail__c testEndPathPPTD = new Process_Path_Task_Detail__c();
        testEndPathPPTD.name = 'End Path';
        //testDocumentCollectionPPTD.Communication_Template__c = ctRec.Id;
        testEndPathPPTD.Process_Path__c = testEndPath.Id;
        testEndPathPPTD.Execution_Serial_No__c = String.valueOf(1);
        testEndPathPPTD.Path_No__c = 'P0';
        testEndPathPPTD.Business_Step_No__c = 1;
        testEndPathPPTD.Subject__c = 'End';
        testEndPathPPTD.isActive__c = true;
        testEndPathPPTD.Process_Task_Detail__c = testEndPTD.Id;
        testEndPathPPTD.Task_Record_Type__c = 'Basic Task Layout';
        testEndPathPPTD.Action_URL__c = 'CMP_TaskMaster';
        testEndPathPPTD.Action_Type__c = 'Apex';
        testEndPathPPTD.Task_Owner_Type__c = 'System';
        testEndPathPPTD.Task_Owner_Name__c = 'N/A';
        testEndPathPPTD.Execution_Serial_No__c = String.valueOf(1);
        insert testEndPathPPTD;
        
        Process_Execution_Condition__c testPEC = new Process_Execution_Condition__c();
        testPEC.Name = 'Opp - LAP : Fresh Main Path Cond';
        insert testPEC;
        
        Process_Execution_Condition_Detail__c testPECD = new Process_Execution_Condition_Detail__c();
        testPECD.Name = 'Opp - LAP : Fresh Main Path Cond. : 1';
        testPECD.Process_Execution_Condition__c = testPEC.Id;
        testPECD.Condition_Expression__c = 'select id from Financial_Account__c where Opportunity__c = :whatid and Loan_Closure_Required__c != true';
        testPECD.Condition_SL_No__c = String.valueOf(1);
        testPECD.Condition_Type__c = 'SOQL';
        
        Process_Attribute_Path_Deviation__c testPAPD = new Process_Attribute_Path_Deviation__c();
        testPAPD.Name = 'Default Path - Start -> Opp - LAP : Fresh Main Path : Dev';
        testPAPD.isActive__c = true;
        testPAPD.Process_Path_Task_Detail_Start__c = testDeviationStartFromPPTD.Id;
        testPAPD.Process_Attribute__c = paRec.Id;
        testPAPD.Process_Path_Type__c = 'Child Path';
        testPAPD.Process_Path__c = testMainPath.Id;
        testPAPD.Process_Path_Task_Detail_End__c = testEndPathPPTD.Id;
        testPAPD.Process_Execution_Condition__c = testPEC.Id;
        testPAPD.Is_Document_Sharing_Path__c = true;
        insert testPAPD;
        
        Task InitiatedTask = new Task();
        InitiatedTask.Subject = 'Start';
        InitiatedTask.Status = 'Draft';
        InitiatedTask.WhatId = opp.Id;
        InitiatedTask.Process_Attribute_Path_Deviation__c = testPAPD.Id;
        InitiatedTask.Process_Attribute__c = paRec.Id;
        InitiatedTask.Process_Path_Task_Detail__c = testDeviationStartFromPPTD.Id;
        InitiatedTask.Process_Path_Deviation_Ids__c = testPAPD.Id;
        Insert InitiatedTask;
        
        Task StartTask = new Task();
        StartTask.Subject = 'Start';
        StartTask.Status = 'Draft';
        StartTask.WhatId = opp.Id;
        StartTask.Process_Attribute_Path_Deviation__c = testPAPD.Id;
        StartTask.Process_Attribute__c = paRec.Id;
        StartTask.Process_Path_Task_Detail__c = testDeviationStartFromPPTD.Id;
        StartTask.Process_Path_Deviation_Ids__c = testPAPD.Id;
        Insert StartTask;
        String tempId = StartTask.Id;
        if(tempId.contains(',')){
           StartTask.Id = tempId.remove(','); 
        }else{
           StartTask.Id = tempId; 
        }
        StartTask.Process_Path_Deviation_Initiated_Task_Id__c = StartTask.Id;
        StartTask.Process_Path_Deviation_End_Task_Id__c = StartTask.Id;
        StartTask.Process_Path_Initiated_Task_Id__c = StartTask.Id;
        update StartTask;
        
        
        task inp_task = new task();
        inp_task.id = StartTask.Id;
        
        TaskCreationNew2.SObjectTaskWrapper cr = new TaskCreationNew2.SObjectTaskWrapper();
        cr.inp_sObject = inp_task;
        
        
        List<TaskCreationNew2.SObjectTaskWrapper> l = new List<TaskCreationNew2.SObjectTaskWrapper>();
        l.add(cr);
        TaskCreationNew2.SObjectNewTaskCreation(l);
        
        opportunity oppinp_task = new opportunity();
        oppinp_task.id = opp.Id;
        
        
        TaskCreationNew2.SObjectTaskWrapper crOpp = new TaskCreationNew2.SObjectTaskWrapper();
        crOpp.inp_sObject = oppinp_task;
        List<TaskCreationNew2.SObjectTaskWrapper> opp1 = new List<TaskCreationNew2.SObjectTaskWrapper>();
        opp1.add(crOpp);
        TaskCreationNew2.SObjectNewTaskCreation(opp1);
    }
}