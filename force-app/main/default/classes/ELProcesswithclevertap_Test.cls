@isTest
public without sharing class ELProcesswithclevertap_Test{
    @isTest
    static void batchapexTestClass(){

        account acc = TestUtility.createaccountInstance();
        acc.name = 'Dummy Account';
        acc.AADHAAR_No__c = 345678909876.0;
        acc.Email_Id__c = 'Mukesh.test@maail.com';
        //acc.Mobile_Number__c = '5467890878';
        acc.PAN_No__c = 'ARVPC5776T';
        acc.Phone = '345678908';
        acc.BillingCity = 'Bangalore';
        acc.BillingCountry = 'INdia';
        acc.BillingPostalCode = '560034';
        acc.BillingState = 'Karnataka';
        acc.BillingStreet = 'Commercial Street';
        acc.Product_Bussiness_Line__c = 'EL';
        insert acc;


        Test.startTest();

        Batch_UpdateAccountPIIData batch = new Batch_UpdateAccountPIIData();
        Id batchId = Database.executeBatch(batch);

        Test.stopTest();
    }

    @istest
    Public static void APITestmethodCreateCustomer(){

        try{
            account newacc2 = TestUtility.createaccountInstance();
            newacc2.External_ID__c = '98765757543210';
            newacc2.Product_Bussiness_Line__c = 'EL';
            insert newacc2;

            Contact con = TestUtility.CreateContactINstance();
            con.accountId = newacc2.Id;
            insert con;

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/CreateAccount';
            req.requestBody = Blob.valueof('[{ "FirstName" : "Test FN","LastName" : "Test LN","CustomerID" : "987667657543210", "Source" : "App", "Status" : "OTP VERIFIED", "ProductFamily" : "Education Loan","Phone" : "4768686578","Company" : "test","Email" : "mukesh.chawla@gmail.com"  }, { "FirstName" : "Test FN1","LastName" : "Test LN1","CustomerID" : "98765757543210", "Source" : "App", "Status" : "OTP initiated", "ProductFamily" : "Education Loan","Phone" : "767678686578","Company" : "test","Email" : "mukesh.chawla@gmail.com"  }]');
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json');

            WS_Response resp = new WS_Response();
            resp.status = 'Success';
            resp.errorMessage = '';
            resp.statusCode = '200';
            resp.successMessage = '';
            List<cls_customer_response> customer_statuslist = new List<cls_customer_response>();
            cls_customer_response resStatusObj = new cls_customer_response();
            resStatusObj.SF_AccountRecid = '576dafd23t2e';
            resStatusObj.Customer_type = 'Individual';
            resStatusObj.Message = 'Success';
            resStatusObj.CustomerId = '345678987654678';
            customer_statuslist.add(resStatusObj);
            resp.customer_status = customer_statuslist;

            RestContext.request = req;
            RestContext.response = res;
            Test.startTest();

            API_CreateCustomer.doPostAccountOpportunity();
            Test.stopTest();

        } catch (Exception e){

        }


        /*

         Opportunity opp = TestUtility.CreateOppINstance();
         opp.AccountId = newacc2.Id;
         insert opp;

         Contact con = TestUtility.CreateContactINstance();
         con.AccountId = newacc2.Id;
         insert con;

         Lead Ld = TestUtility.CreateLeadINstance();
         insert Ld;*/
    }

    @istest
    Public static void APITestmethodCreateAccountOpp(){

        try{
            account newacc2 = TestUtility.createaccountInstance();
            newacc2.External_ID__c = '98765757543210';
            newacc2.Product_Bussiness_Line__c = 'EL';
            insert newacc2;

            Contact con = TestUtility.CreateContactINstance();
            con.accountId = newacc2.Id;
            insert con;

            Opportunity opp = TestUtility.CreateOppINstance();
            opp.AccountId = newacc2.Id;
            opp.Opp_ExternalId__c = '234567876545676';
            insert opp;

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/CreateAccount';
            req.requestBody = Blob.valueof('[{ "LeadSource": "APP","FirstName" : "Test FN","LastName" : "Test LN","CustomerID" : "98765757543210", "Source" : "App", "Status" : "Aadhar FLow", "ProductFamily" : "Education Loan","Phone" : "4768686578","Company" : "test","Email" : "mukesh.chawla@gmail.com", "SubStatus" : "Aadhar Flow Initiated", "ExternalId" : "234567876545676", "type": "Education loan Application", "CustomerType": "Individual" }, { "LeadSource": "APP","FirstName" : "Test FN1","LastName" : "Test LN1","CustomerID" : "987676545663210", "Source" : "App", "Status" : "OTP initiated", "ProductFamily" : "Education Loan","Phone" : "767678686578","Company" : "test","Email" : "mukesh.chawla@gmail.com", "SubStatus" : "Aadhar Flow Initiated", "ExternalId" : "23898787456545676"}, { "LeadSource": "APP","FirstName" : "Test FN","LastName" : "Test LN","CustomerID" : "72578765786724829", "Source" : "App", "Status" : "Aadhar FLow", "ProductFamily" : "Education Loan","Phone" : "4768686578","Company" : "test","Email" : "mukesh.chawla@gmail.com", "SubStatus" : "Aadhar Flow Initiated", "ExternalId" : "58765645234678587" }, { "LeadSource": "APP","FirstName" : "Test FN","LastName" : "Test LN","CustomerID" : "23456789876545675", "Source" : "App", "Status" : "Aadhar FLow", "ProductFamily" : "Education Loan","Phone" : "4768686578","Company" : "test","Email" : "mukesh.chawla@gmail.com", "SubStatus" : "Aadhar Flow Initiated", "ExternalId" : "" }]');
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json');

            WS_Response resp = new WS_Response();
            resp.status = 'Success';
            resp.errorMessage = '';
            resp.statusCode = '200';
            resp.successMessage = '';
            List<cls_customer_response> customer_statuslist = new List<cls_customer_response>();
            cls_customer_response resStatusObj = new cls_customer_response();
            resStatusObj.SF_AccountRecid = '576dafd23t2e';
            resStatusObj.Customer_type = 'Individual';
            resStatusObj.Message = 'Success';
            resStatusObj.CustomerId = '345678987654678';
            resStatusObj.ExternalId = '5185012578785537';
            resStatusObj.CustomerId = '5295967577765662';
            resStatusObj.Customer_type = 'Individual';
            customer_statuslist.add(resStatusObj);
            resp.customer_status = customer_statuslist;

            RestContext.request = req;
            RestContext.response = res;
            Test.startTest();
            API_CreateAccountOpportunity.doPostAccountOpportunity();
            Test.stopTest();

        } catch (Exception e){

        }
    }

    @istest
    Public static void APITestmethodCreateActivity(){

        try{

            account newacc2 = TestUtility.createaccountInstance();
            newacc2.External_ID__c = '98765757543210';
            newacc2.Product_Bussiness_Line__c = 'EL';
            insert newacc2;

            Contact con = TestUtility.CreateContactINstance();
            con.accountId = newacc2.Id;
            insert con;

            Opportunity opp = TestUtility.CreateOppINstance();

            opp.Opp_ExternalId__c = '234567876545676';
            insert opp;

            Opportunity opp2 = TestUtility.CreateOppINstance();

            opp2.Opp_ExternalId__c = '23453467546754545676';
            insert opp2;

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/CreateAccount';
            string RequestSTring = '[{ "Subject": "Call","ActivityDate" : "2023-08-04","WhatId" : ' + JSON.serialize(Opp.Id) + ',"Purpose" : "To Guide for Employment details Again","Status" : "Open", "Type" : "Call", "ExternalId" : "2344587645745676",  "serialnumber" : "7" },{ "Subject": "Call","ActivityDate" : "2023-08-04","WhatId" : "","Purpose" : "To Guide for Employment details Again","Status" : "Open", "Type" : "Call", "ExternalId" : "2344587645745676" ,  "serialnumber" : "7" } ]';
            System.debug('RequestSTring =====> ' + RequestSTring);
            req.requestBody = Blob.valueof(RequestSTring);
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json');

            WS_Response resp = new WS_Response();
            resp.status = 'Success';
            resp.errorMessage = '';
            resp.statusCode = '200';
            resp.successMessage = '';
            List<cls_customer_response> customer_statuslist = new List<cls_customer_response>();
            cls_customer_response resStatusObj = new cls_customer_response();
            resStatusObj.SF_Recid = '576dafd23t2e';
            resStatusObj.Message = 'Success';
            resStatusObj.type = 'Call';
            customer_statuslist.add(resStatusObj);
            resp.customer_status = customer_statuslist;

            RestContext.request = req;
            RestContext.response = res;
            Test.startTest();
            API_CreateActivity.doPostActivity();
            Test.stopTest();

        } catch (Exception e){

        }
    }

    @istest
    Public static void APITestmethodCapturePIIData(){

        try{
            Account acc = TestUtility.createaccountInstance();
            acc.CustomerID__c = '235676545676567';
            acc.External_Id__c = '235676545676567';
            acc.Product_Bussiness_Line__c = 'EL';
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
            //API_CustomerPIIDataCapture.sendEmailToOwner(opplist);

            //Test.stopTest();

            //Test.startTest();
            API_CustomerPIIDataCapture.sendEmailToOwner(opplist);
            Test.setMock(HttpCalloutMock.class, new PIIDataCalloutMock());
            API_CustomerPIIDataCapture.CapturePIIData(acc.Id, accountIdwithOppId);


            API_AltiFiPIIDataCapture.sendContactlistForCallout(Conlist);
            Test.setMock(HttpCalloutMock.class, new PIIDataCalloutMock());
            API_CustomerPIIDataCapture.CapturePIIData(acc.CustomerID__c, accountIdwithConId);
            Test.stopTest();
        } catch (Exception e){

        }
    }

    class cls_customer_response{
        public String SF_AccountRecid;
        public String Customer_type;
        public string Message;
        public string CustomerId;
        public string ExternalId;
        public string SF_WhatId;
        public string Application_Status;
        public string SF_Recid;
        public string type;
    }

    class WS_Response{
        public String status;
        public String errorMessage;
        public String successMessage;
        public String statusCode;
        public List<cls_customer_response> customer_status;

    }

}