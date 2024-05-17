@isTest
public class TaskStatusUpdateHelper_Test {
	@isTest
    public static void testCase1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1.com');
insert u;
        /*System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
        }*/
        Process_Attribute__c pa = new Process_Attribute__c();
        pa.Name = 'process attribute';
        pa.Opportunity_Type__c ='DO Partner GoLive';
        insert pa;
        
        Process_Attribute_Details__c pad = new Process_Attribute_Details__c();
        pad.Process_Attribute__c = pa.Id;
        pad.Stage_Step__c = 'Group Creation';
        pad.Task_Owner_Type__c = 'Queue';
        pad.Stage_SL_No__c = '1';
        pad.Task_Subject_Sl_No__c = '1';
        pad.Task_Reviwer_Type__c = 'Queue';
        pad.Task_Subject__c = 'Create Product Analysis Group';
        pad.SLA__c = 1;
        pad.Task_Owner_Name__c='Business Team - DO';
        insert pad;
        
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Qaulification';
        opp.Type = 'DO Partner GoLive';
        opp.Process_Attribute__c = pa.Id;
        insert opp;
        
        
        
        Task parentts = new Task();
        parentts.Subject = 'Test Subject';
        parentts.WhatId = opp.Id;
        parentts.Previous_Owner__c = UserInfo.getUserId();
        parentts.OwnerId = u.Id;
        parentts.Process_Attribute_Details__c = pad.Id;
        insert parentts;
        
        Task ts = new Task();
        ts.Subject = 'Test Subject';
        ts.WhatId = opp.Id;
        ts.Previous_Owner__c = UserInfo.getUserId();
        ts.OwnerId = u.Id;
        ts.Process_Attribute_Details__c = pad.Id;
        ts.Parent_Task_Id__c = parentts.Id;
        insert ts;

        
        
        TaskStatusUpdateHelper.updatetaskStatus(ts.Id,'Completed');
        TaskStatusUpdateHelper.getAccRatings();
        TaskStatusUpdateHelper.UpdateTaskStatusInApprove(ts.Id,'Approved','testcomment');
        TaskStatusUpdateHelper.UpdateTaskStatusInApprove(ts.Id,'Rejected','testcomment');
        TaskStatusUpdateHelper.UpdateTaskStatusInApprove(ts.Id,'ReAssign','testcomment');
        TaskStatusUpdateHelper.returnWrapper(ts.Id);
        TaskStatusUpdateHelper.WrapperClassReviewerDetail(ts.Id);
        TaskStatusUpdateHelper.PassValueForApproval(ts.Id,UserInfo.getUserId());
        GetTaskStatus.GettaskDetail(ts.Id);
    }
}