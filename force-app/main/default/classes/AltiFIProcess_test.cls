@isTest
public with sharing class AltiFIProcess_test{
    @istest
    Public static void APITestmethodCapturePIIData(){

        try{
            Account acc = TestUtility.createaccountInstance();
            acc.CustomerID__c = '235676545676567';
            acc.External_Id__c = '235676545676567';
            insert acc;

            contact con = TestUtility.CreateContactINstance();
            con.AccountId = acc.Id;
            insert con;

            Opportunity opp = TestUtility.CreateOppINstance();
            opp.Opp_ExternalId__c = '23456856898347887';
            opp.AccountId = acc.Id;
            insert opp;

            Task tsk = TestUtility.CreateTaskInstance();
            tsk.WhatId = opp.Id;
            //tsk.IsClosed = false;
            insert tsk;

            opp.StageName = 'Aadhar flow';
            opp.SubStatus__c = 'Aadhaar Verification Completed';
            update opp;

            List<Opportunity> opplist = new List<Opportunity>();
            opplist.add(opp);

            Map<String, String> accountIdwithOppId = new Map<String, String>();
            accountIdwithOppId.put(acc.CustomerID__c, opp.Id);

            List<Contact> Conlist = new List<Contact>();
            conlist.add(con);


            Map<String, String> accountIdwithConId = new Map<String, String>();
            accountIdwithOppId.put(acc.CustomerID__c, con.Id);


            Test.startTest();


            API_AltiFiPIIDataCapture.sendContactlistForCallout(Conlist);
            Test.setMock(HttpCalloutMock.class, new AltiFiPIIdatacalloutMock());
            API_AltiFiPIIDataCapture.CaptureAltifiPIIData(acc.CustomerID__c, accountIdwithConId);
            Test.stopTest();

        //     Test.startTest();
        //     Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        // SampleClass.sampleMethod('test');
        //     Test.stopTest();
        } catch (Exception e){

        }
    }

    public class AltiFiPIIdatacalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{ "content": { "name": "Geetu ", "userId": 5152629520578016, "teamTypeId": 1, "updatedAdid": false, "mobileNo": "+919821949885", "email": "GEETU@GMAIL.COM" } }');
            return res;
        }
    }
	
    @istest
    public static void BatchPIIDataTest(){
        Account acc = new account();
        acc.name = 'TestPIIData';
        acc.Phone = '347656765676';
        //acc.Mobile_Number__c = '347656765676';
        acc.Product_Bussiness_Line__c='NU Score';
        insert acc;
        Test.startTest();

        Batch_UpdateAccountPIIData batch = new Batch_UpdateAccountPIIData();
        Id batchId = Database.executeBatch(batch);

        Test.stopTest();
    }
}