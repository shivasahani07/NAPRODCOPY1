@isTest
public class WelcomeLetterControllerTest {
    
    @isTest
    static void testControllerInitialization() {
        Test.startTest();
        
        // Assuming createTestAccount and CreateFinancialAccountInstance methods do not insert the accounts
        Account testAccount = TestUtility.createTestAccount();
        Financial_Account__c financialAccount = TestUtility.CreateFinancialAccountInstance();
        financialAccount.Account_Name__c = testAccount.Id;
       	Contact contactRec = TestUtility.CreateContactINstance();
        insert contactRec;
		        
        List<Receivable__c> receivables = new List<Receivable__c>();
        Receivable__c receivable = new Receivable__c(
            Financial_Account__c = financialAccount.Id,
            Receivable_Date__c = Date.today(),
            RecordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId()
        );
        receivables.add(receivable);
        insert receivables;
        
        Test.setCurrentPageReference(new PageReference('Page.WelcomeLetterTemplate'));
        ApexPages.currentPage().getParameters().put('id', financialAccount.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(financialAccount);
        WelcomeLetterController controller = new WelcomeLetterController(stdController);
        
        Test.stopTest();
        
        System.assertEquals(financialAccount.Id, WelcomeLetterController.fa_Record.Id);
        System.assertEquals(1, WelcomeLetterController.receivableList.size());
        System.assertEquals(receivable.Id, WelcomeLetterController.receivableList[0].Id);
    }
    @isTest
    static void testGenerateWelcomeLetterPDF() {
        Test.startTest();
        
        Account testAccount = TestUtility.createTestAccount();
        Financial_Account__c financialAccount = TestUtility.CreateFinancialAccountInstance();
        financialAccount.Account_Name__c = testAccount.Id;
        //insert testAccount;
        //insert financialAccount;
        
        Receivable__c receivable = new Receivable__c(
            Financial_Account__c = financialAccount.Id,
            Receivable_Date__c = Date.today(),
            RecordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId()
        );
        insert receivable;
        
        Task task = new Task(WhatId = testAccount.Id);
        insert task;

        Document_Metadata__c docMetaRec = TestUtility.createDocumentmetadata(); 
       
        
        
        

        
        String result = WelcomeLetterController.generateWelcomeletterPDF(financialAccount.Id, task.Id);
        
        Test.stopTest();
        
        List<Document_Handler__c> handlers = [SELECT Id FROM Document_Handler__c WHERE Financial_Account__c = :financialAccount.Id];
        System.assertEquals(0, handlers.size());
    }
    
    
}