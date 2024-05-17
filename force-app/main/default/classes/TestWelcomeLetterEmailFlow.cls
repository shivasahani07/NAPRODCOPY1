@IsTest
public class TestWelcomeLetterEmailFlow {
	@IsTest
    public static void SendemaiaTestClass(){
        String parentRecId = '';
        String sObjectId = '';
        Account acc = new Account();
        acc.Name = 'Test Name';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opportunity';
        opp.CloseDate = system.today();
        opp.StageName = 'Closed Won';
        opp.Type = 'LAP Loan Application';
        opp.AccountId = acc.Id;
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
        
        Process_path__c testpp = new Process_Path__c();
        testpp.name = 'Memo Execution Request Path';
        testpp.isActive__c = true;
        insert testpp;
        Process_Task_Detail__c testPTD = new Process_Task_Detail__c();
        testPTD.Name = 'Memo Execution Request';
        testPTD.Subject__c	 = 'Memo Execution Request';
        testPTD.Task_Record_Type__c = 'Admin';
        testPTD.IsActive__c = true;
        insert testPTD;
        
        Process_Path_Task_Detail__c testPPTD= new Process_Path_Task_Detail__c();
        testPPTD.name = 'Memo Execution Request Path : T1';
        testPPTD.Communication_Template__c = ctRec.Id;
        testPPTD.Process_Path__c = testpp.Id;
        testPPTD.Subject__c = 'Memo Execution Request';
        testPPTD.Process_Task_Detail__c = testPTD.Id;
        testPPTD.isActive__c = true;
        testPPTD.Task_Record_Type__c = 'API Call Out';
        testPPTD.Action_URL__c = 'SendPayableDetailsToCustomer';
        testPPTD.Action_Type__c = 'Apex';
        testPPTD.Task_Owner_Type__c = 'System';
        testPPTD.Task_Owner_Name__c = 'N/A';
        testPPTD.Business_Step_No__c = 1;
        testPPTD.Execution_Serial_No__c = String.valueOf(1);
        
        insert testPPTD;
        
        Task parentTask = new Task();
        parentTask.Process_Path_Task_Detail__c = testPPTD.Id;
        parentTask.WhatId = opp.Id;
        parentTask.ActivityDate = system.today();
        parentTask.Subject = 'test subject';
        insert parentTask;
        Document_Metadata__c docMetaRec = new Document_Metadata__c();
        docMetaRec.Name = 'Welcome Letter';
        docMetaRec.Document_Name__c = 'Welcome Letter';
        insert docMetaRec;
        //Document_Metadata__c docMetaRec = [select id,Document_Name__c from Document_Metadata__c where Document_Name__c='Welcome Letter' limit 1];
        Document_Handler__c doHandler = new Document_Handler__c();
        doHandler.Account__c = acc.Id;
        doHandler.Task_Id__c = parentTask.Id;
        doHandler.Document_Metadata__c = docMetaRec.Id;
        insert doHandler;
        parentRecId = parentTask.Id;
        Task taskDet = new Task();
        taskDet.Process_Path_Task_Detail__c = testPPTD.Id;
        taskDet.WhatId = opp.Id;
        taskDet.ActivityDate = system.today();
        taskDet.Subject = 'test subject';
        taskDet.Process_Path_Deviation_Initiated_Task_Id__c = parentTask.Id;
        insert taskDet;
        
        API_Callout_Audit__c auditRec = new API_Callout_Audit__c();
        auditRec.Status__c = 'New';
        auditRec.Task_ID__c = taskDet.Id;
        auditRec.Apex_Action__c = 'EmailService';
        insert auditRec;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test File';
        cv.PathOnClient = 'Test_File.pdf'; // Name of the file
        cv.VersionData = Blob.valueOf('Test file content'); // Content of the file
        cv.IsMajorVersion = true;
        cv.ContentLocation = 'S'; // S indicates that the file is stored in Salesforce
        cv.FirstPublishLocationId = doHandler.Id; // Link the file to the Account
        insert cv;
        
        SystemExecutedMasterClass.FlowInput input = new SystemExecutedMasterClass.FlowInput();
        input.recordId = auditRec.Id;
        input.actionName = 'EmailService';
        input.taskRecordId = taskDet.Id;
        
        SystemExecutedMasterClass.processRecords(new List<SystemExecutedMasterClass.FlowInput>{ input });
        
    }
    
    private static SystemExecutedMasterClass.FlowInput prepareFlowInput(String actionName, Id recordId, Id taskRecordId) {
        SystemExecutedMasterClass.FlowInput input = new SystemExecutedMasterClass.FlowInput();
        input.recordId = recordId;
        input.actionName = actionName;
        input.taskRecordId = taskRecordId;
        return input;
    }
}