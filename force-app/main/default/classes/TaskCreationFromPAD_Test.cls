@isTest
public class TaskCreationFromPAD_Test {
    
    //public static Map<String, String> processAttributedependtaskMap = new Map<String, String>();
    public static  Map<string, Process_Attribute_Details__c> processAttributedependtaskMap = new Map<string, Process_Attribute_Details__c>();
    static testmethod void CreateTasktest(){
        
       List<Process_Dependent_Task_Details__c> proDependTaskdetailList = new List<Process_Dependent_Task_Details__c>();
        
        Id CaseRecordtype = Schema.SObjectType.Process_Attribute__c.getRecordTypeInfosByName().get('Case Attribute').getRecordTypeId();
        Process_Attribute__c ProAttribute = TestUtility.createProAttributeInstance();
        ProAttribute.RecordTypeId = CaseRecordtype;
        insert ProAttribute;
        System.debug('ProAttribute ID ====> ' + ProAttribute.Id);
        

        List<Process_Attribute_Details__c> ProAttributeDetailsList =TestUtility.createProAttridetailsInstance();
        for (Process_Attribute_Details__c ProAttDetails : ProAttributeDetailsList) {
            ProAttDetails.Process_Attribute__c = ProAttribute.Id;
           
        }

       
        if (!ProAttributeDetailsList.isEmpty() && ProAttributeDetailsList.size() >0) {
            insert ProAttributeDetailsList;
             System.debug('ProAttributeDetailsList[0].Process_Attribute__c ====> ' + ProAttributeDetailsList[0].Process_Attribute__c);

            for (Process_Attribute_Details__c ProAttDetails : ProAttributeDetailsList) {
                //if (ProAttDetails.Dependent_of_Tasks__c != null) {
                    processAttributedependtaskMap.put(ProAttDetails.Name, ProAttDetails);
                //}
            }
            
            for (Process_Attribute_Details__c ProAttDetails : ProAttributeDetailsList) {
                if (ProAttDetails.Dependent_of_Tasks__c != null) {
                    System.debug('ProAttDetails.Dependent_of_Tasks__c ====> ' + ProAttDetails.Dependent_of_Tasks__c);
                    System.debug('processAttributedependtaskMap.get(ProAttDetails.Dependent_of_Tasks__c).Id =====> ' + processAttributedependtaskMap.get(ProAttDetails.Dependent_of_Tasks__c));
                   Process_Dependent_Task_Details__c ProDependTask = TestUtility.CreateProdependenttask(ProAttDetails.Process_Attribute__c, ProAttDetails.Id, processAttributedependtaskMap.get(ProAttDetails.Dependent_of_Tasks__c).Id);
                   proDependTaskdetailList.add(ProDependTask);
                } 
            }
        }
        
        System.debug('proDependTaskdetailList ====> ' + proDependTaskdetailList);

        if (!proDependTaskdetailList.isEmpty() && proDependTaskdetailList.size() >0) {
            insert proDependTaskdetailList;
            
        }

        account newacc = TestUtility.createaccountInstance();
        newacc.CustomerID__c = '23456787656765';
        newacc.Name = 'Test Acc';
        insert newacc;
        
        account newacc1 = TestUtility.createaccountInstance();
        newacc.CustomerID__c = '764788249284723';
        newacc.Name = 'Test Acc 1';
        insert newacc1;
       
        Financial_Account__c FinancialRec=new Financial_Account__c();
        FinancialRec.Name='34334';
        FinancialRec.Loan_Category__c='SBL';
        FinancialRec.Originating_System__c='Perdix';
        FinancialRec.Account_Name__c=newacc.Id;
        insert FinancialRec;
        
        Case newCase = TestUtility.CreateCaseInstance();
        newCase.accountId = newacc.Id;
        newCase.Process_Attribute__c = ProAttribute.id;
        newCase.Financial_Account__c=FinancialRec.Id;
        insert newCase;


        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Task' AND Name = 'Business Team EL'];
		
        Task tsk = new Task();
        tsk.Subject = 'Test Task';
        tsk.Status = 'Completed';
        tsk.Priority = 'Normal';
        tsk.Process_Attribute_Details__c = ProAttributeDetailsList[0].id;
        tsk.WhatId = newCase.ID;
        tsk.RecordTypeId = rt.Id;
        try{
            insert tsk;
        }catch(Exception e){
            system.debug('Exception::'+e.getStackTraceString());
        }
        
        system.debug('tsk ====> ' + tsk);
        system.debug('ProAttributeDetailsList ====> ' + ProAttributeDetailsList[0].id);

        
        Case Casenew = new Case();
        Casenew.Id = tsk.WhatId;
        Casenew.Process_Attribute__c = ProAttribute.id;
        
        
        //List<FlowInput> flowinpList = new List<FlowInput>();
        TaskCreationFromPAD.FlowInput taskcreationflowinstance = new TaskCreationFromPAD.FlowInput();
        List<TaskCreationFromPAD.FlowInput> flowinpList = new List<TaskCreationFromPAD.FlowInput>();
        
         taskcreationflowinstance.inp_record = Casenew;
        flowinpList.add(taskcreationflowinstance);
        
        TaskCreationFromPAD.CreateTask(flowinpList);
        
        

    }
    
    public class FlowInput{
        @InvocableVariable public sObject inp_record;
    }
    
}