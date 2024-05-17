@IsTest
public class TestSystemExecutedMasterClass {
	@IsTest
    public static void SendemaiaTestClass(){
        Communication_Template__c ctRec = new Communication_Template__c();
        ctRec.Email_From__c  = 'kispanchal86@gmail.com';
        ctRec.Email_To__c = 'kispanchal86@gmail.com';
        ctRec.Is_Active__c = true;
        ctRec.Template_Body__c = 'Test Body';
        ctRec.Email_Service__c = 'Salesforce';
        ctRec.Subject__c = 'test Subject';
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
        
        
    }
}