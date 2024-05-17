@isTest
public class DynamicRecordEditFormController_Test {
    
    @isTest
    Public Static void getRecordEditFormDetails_test(){
        List<Action_Form_Details__c> ActionFormList=new List<Action_Form_Details__c>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1.com');
        insert u;
        
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
        insert OppRec;
        
        Task ts = new Task();
        ts.Subject = 'Test Subject';
        ts.WhatId = OppRec.Id;
        ts.Previous_Owner__c = UserInfo.getUserId();
        ts.OwnerId = u.Id;
        ts.Process_Attribute_Details__c = pad.Id;
        ts.ActivityDate = Date.valueOf('2021-5-29');
        ts.status='Completed';
        Insert ts;
        
        Action_Form_Details__c AFD=new Action_Form_Details__c();
        AFD.Process_Attribute_Details__c=pad.Id;
        AFD.Active__c=true;
        AFD.Label_Name__c='Name';
        AFD.Label_API__c='Name';
        AFD.Input_Type__c='text';
        AFD.Editable__c=false;
        AFD.Mapping_Field_API__c='Attribute1__c';
        ActionFormList.add(AFD);
        Insert ActionFormList;
        
        DynamicRecordEditFormController.getRecordEditFormDetails(pad.Id);
        DynamicRecordEditFormController.upsertActionFormDetails(ActionFormList,ts.Id);

    }

}