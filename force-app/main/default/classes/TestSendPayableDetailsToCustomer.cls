@isTest
private class TestSendPayableDetailsToCustomer {
    
    @isTest
    static void testSendPayableDetails() {
        // Create necessary test data using TestUtility
        Account testAccount = TestUtility.createTestAccount();
        //insert testAccount;
        Opportunity testOpportunity = TestUtility.createTestOpportunity(testAccount.Id);
        insert testOpportunity;
        
        Financial_Account__c faAccount = new Financial_Account__c();
        faAccount.Account_Name__c = testAccount.Id;
        faAccount.Originating_Branch__c = testAccount.Id;
        faAccount.Amount__c = 5000;
        faAccount.EMI_Amount__c = 300;
        faAccount.First_EMI_Date__c = system.today();
        faAccount.Opportunity__c = testOpportunity.Id;
        insert faAccount;
        
        Financial_Entity__c FinancialEntity = new Financial_Entity__c();
        
        FinancialEntity.Financial_Account__c =faAccount.Id;
        insert FinancialEntity;
        
        Document_Metadata__c docMetaRec = new Document_Metadata__c();
        docMetaRec.Name = 'MEMO Submitted For Request';
        docMetaRec.Document_Name__c = 'MEMO Submitted For Request';
        insert docMetaRec;
        
        Financial_Entity_AC_Detail__c feac = new Financial_Entity_AC_Detail__c();
        feac.Bank_Account_Number__c = 'Test Bank Account';
        feac.Bank_Account_Type__c = 'Savings';
        feac.Bank_Name__c = 'Axis Bank';
        feac.Banking_Account_Name__c = 'Test Banking Name';
        feac.Financial_Account__c = faAccount.Id;
        feac.Financial_Entity__c = FinancialEntity.Id;
        feac.IFSC_Code__c = 'test IFSC';
        insert  feac;       
        Communication_Template__c ctRec = new Communication_Template__c();
        ctRec.Email_From__c  = 'kispanchal86@gmail.com';
        ctRec.Email_To__c = 'kispanchal86@gmail.com';
        ctRec.Is_Active__c = true;
        ctRec.Template_Body__c = 'Test Body';
        ctRec.Email_Service__c = 'Salesforce';
        ctRec.Subject__c = 'test Subject';
        ctRec.CC_Addresses__c = 'test@gmail.com';
        //ctRec.Attachment_Query__c = 'SELECT Id From Document_Handler__c Where Task_Id__c =: parentRecId';
        //ctRec.Template_Body_Query__c = 'SELECT Id,LMS_Application_ID__c,Sanction_Date__c,Sanctioned_Amount__c,Name,Tenuer__c,First_EMI_Date__c,EMI_Amount__c From Financial_Account__c where Opportunity__c =: sObjectId';
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
        testPPTD.Communication_Template__c = ctRec.Id;
        insert testPPTD;
        
        
        Task parentTask = new Task();
        parentTask.Process_Path_Task_Detail__c = testPPTD.Id;
        parentTask.WhatId = testOpportunity.Id;
        parentTask.ActivityDate = system.today();
        parentTask.Subject = 'test subject';
        insert parentTask;
        
        
        Paybale__c testPayable = TestUtility.createMODTInstance();
        //insert testPayable;
        Paybale__c testMEMO = new Paybale__c();
        testMEMO.Amount__c=150000;
        testMEMO.IsActive__c=true;	
        testMEMO.Financial_Account__c=faAccount.id;
        testMEMO.Task_Id__c = parentTask.Id;
        testMEMO.RBI_UTR_Reference_Number__c = '12345';
        testMEMO.Finacial_Entity_Details__c = FinancialEntity.Id;
        testMEMO.Status__c =Constants.PAYABLE_STATUS_MEMO_CREATED;
        testMEMO.Financial_Entity_A_C_Details__c =feac.Id;
        testMEMO.Mode__c = 'RTGS';
        testMEMO.Execution_Request_Processed__c = false;
        testMEMO.Execution_Request_Document_Handler__c = null;
        insert testMEMO;
        
        testMEMO.Mode__c = 'RTGS';
        //update testMEMO;
        
        Task taskDet = new Task();
        taskDet.Process_Path_Task_Detail__c = testPPTD.Id;
        //taskDet.WhatId = testOpportunity.Id;
        taskDet.ActivityDate = system.today();
        taskDet.Subject = 'test subject';
        taskDet.Process_Path_Deviation_Initiated_Task_Id__c = parentTask.Id;
        taskDet.Parent_Task_Id__c = parentTask.Id;
        taskDet.Attribute1__c = 'RTGS';
        insert taskDet;
        
        Document_Handler__c docHandler = new Document_Handler__c();
        system.debug('docMetaRec::'+docMetaRec);
        docHandler.Task_Id__c = taskDet.id;
        docHandler.Status__c = 'Completed';
        docHandler.Document_Metadata__c = docMetaRec.Id;
        //insert docHandler;
        
        // Call the method under test
        Test.startTest();
        //BulkMEMOExecutionSubmittion.ExecutionProcess(taskDet.Id);
        SendPayableDetailsToCustomer.sendPayableDetails(new list<Id>{taskDet.Id});
        
        Test.stopTest();
        
        // Assertions would normally go here
    }
    
    
}