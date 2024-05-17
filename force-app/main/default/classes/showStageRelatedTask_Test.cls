@isTest
public class showStageRelatedTask_Test {
    @isTest
    public static void testStage_Task(){
        List<Task> TaskToinsert=new List<Task>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1.com');
        insert u;
        
        
        
        Account AccRec=new Account();
        AccRec.Name='Test Account';
        Insert AccRec;
        
        Process_Attribute__c PR=new Process_Attribute__c();
        PR.Object_Type__c='Opportunity';
        PR.Opportunity_Type__c='DO Partner GoLive';
        PR.Sobject_RecordType_Name__c='Do Partner On Boarding';
        
        Insert PR;
        
         Process_Attribute_Details__c pad = new Process_Attribute_Details__c();
        pad.Process_Attribute__c = PR.Id;
        pad.Stage_Step__c = 'Group Creation';
        pad.Task_Owner_Type__c = 'Queue';
        pad.Task_Automation__c = true;
        pad.Stage_SL_No__c = '1';
        pad.SLA__c = 2;
        pad.Task_Owner_Name__c = 'Business Team - DO';
        pad.Task_Subject_Sl_No__c = '1';
        pad.Task_Reviwer_Type__c = 'Queue';
        pad.Task_Reviewer_Name__c = 'Business Team - DO';
        pad.Task_Subject__c = 'Create Product Analysis Group';
        pad.isActive__c = true;
        pad.Action_URL__c='FileUploadCmp';
        insert pad;
        
        Opportunity OppRec=new Opportunity();
        OppRec.Process_Attribute__c=PR.Id;
        OppRec.Name='Test Opportunity';
        OppRec.CloseDate=Date.valueOf('2023-5-29');
        OppRec.StageName='Qualification';
        OppRec.AccountId=AccRec.Id;
        
        insert OppRec;
        
        Opportunity OppRec2=new Opportunity();
        OppRec2.Process_Attribute__c=PR.Id;
        OppRec2.Name='Test Opportunity';
        OppRec2.CloseDate=Date.valueOf('2023-5-29');
        OppRec2.StageName='Qualification';
        OppRec2.AccountId=AccRec.Id;
        
        insert OppRec2;
        
        Opportunity OppRec3=new Opportunity();
        OppRec3.Process_Attribute__c=PR.Id;
        OppRec3.Name='Test Opportunity';
        OppRec3.CloseDate=Date.valueOf('2023-5-29');
        OppRec3.StageName='Qualification';
        OppRec3.AccountId=AccRec.Id;
        
        insert OppRec3;
        
        Opportunity OppRec4=new Opportunity();
        OppRec4.Process_Attribute__c=PR.Id;
        OppRec4.Name='Test Opportunity';
        OppRec4.CloseDate=Date.valueOf('2023-5-29');
        OppRec4.StageName='Qualification';
        OppRec4.AccountId=AccRec.Id;
        
        insert OppRec4;
        
        Opportunity OppRec5=new Opportunity();
        OppRec5.Name='Test Opportunity';
        OppRec5.CloseDate=Date.valueOf('2023-5-29');
        OppRec5.StageName='Qualification';
        OppRec5.AccountId=AccRec.Id;
        
        insert OppRec5;
        
        
        
        Task ts = new Task();
        ts.Subject = 'Test Subject';
        ts.WhatId = OppRec.Id;
        ts.Previous_Owner__c = UserInfo.getUserId();
        ts.OwnerId = u.Id;
        ts.Process_Attribute_Details__c = pad.Id;
        ts.ActivityDate = Date.valueOf('2021-5-29');
        ts.status='Completed';
        TaskToinsert.add(ts);
        
        Task ts1 = new Task();
        ts1.Subject = 'Test Subject1';
        ts1.WhatId = OppRec2.Id;
        ts1.Previous_Owner__c = UserInfo.getUserId();
        ts1.OwnerId = u.Id;
        ts1.Process_Attribute_Details__c = pad.Id;
        ts1.ActivityDate = Date.valueOf('2023-9-25');
        ts1.status='Completed';
        TaskToinsert.add(ts1);
        

        Task ts2 = new Task();
        ts2.Subject = 'Test Subject 2';
        ts2.WhatId = OppRec3.Id;
        ts2.Previous_Owner__c = UserInfo.getUserId();
        ts2.OwnerId = u.Id;
        ts2.Process_Attribute_Details__c = pad.Id;
        ts2.ActivityDate = Date.valueOf('2021-5-29');
        ts2.status='Open';
        TaskToinsert.add(ts2);
       
        Task ts3 = new Task();
        ts3.Subject = 'Test Subject 3';
        ts3.WhatId = OppRec4.Id;
        ts3.Previous_Owner__c = UserInfo.getUserId();
        ts3.OwnerId = u.Id;
        ts3.Process_Attribute_Details__c = pad.Id;
        ts3.ActivityDate = Date.valueOf('2023-9-25');
        ts3.status='Open';
        TaskToinsert.add(ts3);
        
        Task ts4= new Task();
        ts4.Subject = 'Test Subject 4';
        ts4.WhatId = OppRec5.Id;
        ts4.Previous_Owner__c = UserInfo.getUserId();
        ts4.OwnerId = u.Id;
        ts4.status='Open';
        ts3.ActivityDate = Date.valueOf('2023-10-25');
        TaskToinsert.add(ts4);
        
        insert TaskToinsert;
        
        
        showStageRelatedTasks.getAllProcessAttributeDetails(OppRec.Id);
        showStageRelatedTasks.getAllProcessAttributeDetails(OppRec2.Id);
        showStageRelatedTasks.getAllProcessAttributeDetails(OppRec3.Id);
        showStageRelatedTasks.getAllProcessAttributeDetails(OppRec4.Id);
        showStageRelatedTasks.getAllProcessAttributeDetails(OppRec5.Id);

    }
}