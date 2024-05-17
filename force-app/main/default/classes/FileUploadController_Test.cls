@isTest
public class FileUploadController_Test {
    @isTest
    public static void testDocument(){
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
        
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
       
        Process_Attribute_Details__c pad = new Process_Attribute_Details__c();
        pad.Process_Attribute__c = pa.Id;
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
        insert pad;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Qaulification';
        opp.Type = 'DO Partner GoLive';
        opp.Process_Attribute__c = pa.Id;
        insert opp;
        
        Task ts = new Task();
        ts.Subject = 'Test Subject';
        ts.WhatId = opp.Id;
        ts.Previous_Owner__c = UserInfo.getUserId();
        ts.OwnerId = u.Id;
        ts.Process_Attribute_Details__c = pad.Id;
        ts.ActivityDate = Date.today().addDays(3);
        insert ts;
        
        Task tsChild = new Task();
        tsChild.Subject = 'Test Subject Child';
        tsChild.WhatId = opp.Id;
        tsChild.Previous_Owner__c = UserInfo.getUserId();
        tsChild.OwnerId = u.Id;
        tsChild.Process_Attribute_Details__c = pad.Id;
        tsChild.ActivityDate = Date.today().addDays(3);
        tsChild.Parent_Task_Id__c=ts.Id;
        insert tsChild;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = ts.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        FileUploadController.getFiles(ts.Id);
        FileUploadController.returnWrapper(ts.Id);
        FileUploadController.UpdateTaskStatus(ts.Id,'Approved','testcomment',tsChild.Id);
        FileUploadController.UpdateTaskStatus(ts.Id,'Rejected','testcomment',tsChild.Id);
        FileUploadController.UpdateTaskStatus(ts.Id,'ReAssign','testcomment',tsChild.Id);
        FileUploadController.WrapperClassReviewerDetailFromApex(ts.id);
        FileUploadController.PassValueForApproval(ts.Id,new list<string>{UserInfo.getUserId()}); //UserInfo.getUserId()
        FileUploadController.getAccRatings();
        FileUploadController.updatetaskStatusValue(ts.id,'completed');
        FileUploadController.CallCheckCurrentUserEditRight(ts.Id);
        FileUploadController.CallCheckCurrentUserEditRight(tsChild.Id);
        FileUploadController.openChildReviewerTask(tsChild);
        FileUploadController.getOwnerOptions('Queue',new List<String>{UserInfo.getUserId()});
        FileUploadController.getOwnerOptions('Self',new List<String>{UserInfo.getUserId()});
    }
}