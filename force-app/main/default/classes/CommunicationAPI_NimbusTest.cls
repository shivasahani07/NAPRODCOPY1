@isTest
public class CommunicationAPI_NimbusTest {
    
    @isTest static void testsendNotificationToCustomer() {
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Process_Attribute__c proatt = new Process_Attribute__c();
        proatt.Name = 'Test Data';
        insert proatt;
        
        Communication_Template__c com = new Communication_Template__c();
        com.Nimbus_Template_Id__c = '1235yu';
        com.Channel_Type__c = 'SMS';
        insert com;
        
        Process_Attribute_Details__c pro = new Process_Attribute_Details__c();
        pro.Process_Attribute__c = proatt.Id;
        pro.Name = 'Paid Id';
        pro.Stage_Step__c = 'Communication';
        pro.Task_Subject__c = 'Communication - Email';
        pro.Task_Owner_Type__c = 'Queue'; 
        pro.Stage_SL_No__c = '1';
        pro.Task_Subject_Sl_No__c = '1';
        pro.Communication_Template__c = com.Id;
        insert pro;
        
        Account acc = new Account(name='Kishan',phone='9825157781');
        insert acc;
        
        Case c = new Case();
        c.Type = 'Query';
        c.Category__c = 'Customer Engagement';
        c.Status = 'New';
        c.Sub_Category__c = 'Call Back';
        c.Cust_ID__c = '123567sdfj';
        c.Customer_Mobile_No__c = '8446557829';
        c.Customer_Type__c = 'Individual';
        c.Partner_Name__c = 'Cashe';
        c.Customer_Name__c = 'Aakash';
        c.AccountId = acc.Id;
        c.Financial_Account_Number__c = 'test';
        insert c;
            
        List<Task> tkList = new List<Task>();
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='Communication - Email1';
        t.Status='Open';
        t.Priority='Normal';
        t.Process_Attribute_Details__c = pro.Id;
        t.WhatId = acc.Id;
        insert t;
        Task t1 = new Task();
        t1.OwnerId = UserInfo.getUserId();
        t1.Subject='Communication - Email';
        t1.Status='Open';
        t1.Priority='Normal';
        t1.Process_Attribute_Details__c = pro.Id;
        t1.WhatId = c.Id;
        insert t1;
        tkList.add(t);
        
        API_Callout_Audit__c aca = new API_Callout_Audit__c();
        //aca.name ='test';
        aca.Processed__c = 'Inbound';
        insert aca;
        
       CommunicationAPI_Nimbus.sendNotificationToCustomer(tkList,aca.Id);
        test.stopTest();
    }
    
    /*
    @isTest static void testsendNotificationToCustomer1() {
        Process_Attribute__c proatt = new Process_Attribute__c();
        proatt.Name = 'Test Data';
        insert proatt;
        
        Communication_Template__c com = new Communication_Template__c();
        com.Nimbus_Template_Id__c = '1235yu';
        com.Channel_Type__c = 'SMS';
        insert com;
        
        Process_Attribute_Details__c pro = new Process_Attribute_Details__c();
        pro.Process_Attribute__c = proatt.Id;
        pro.Name = 'Paid Id';
        pro.Stage_Step__c = 'Communication';
        pro.Task_Subject__c = 'Communication - Email';
        pro.Task_Owner_Type__c = 'Queue'; 
        pro.Stage_SL_No__c = '1';
        pro.Task_Subject_Sl_No__c = '1';
        pro.Communication_Template__c = com.Id;
        insert pro;
        
        Account acc = new Account(name='Kishan');
        insert acc;
        
        Case c = new Case();
        c.Type = 'Query';
        c.Category__c = 'Bureau';
        c.Status = 'New';
        c.Sub_Category__c = 'Bureau Not Updated';
        c.Cust_ID__c = '123567sdfj';
        c.Customer_Mobile_No__c = '8446557829';
        c.Customer_Type__c = 'Individual';
        c.Partner_Name__c = 'Cashe';
        c.Customer_Name__c = 'Aakash';
        c.AccountId = acc.Id;
        insert c;
            
        List<Task> tkList = new List<Task>();
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='Test Case';
        t.Status='Open';
        t.Priority='Normal';
        t.Process_Attribute_Details__c = pro.Id;
        t.WhatId = c.Id;
        insert t;
        tkList.add(t);
        
        CommunicationAPI_Nimbus.createCustomTaskRecord(tkList);
    }
    */
    
}