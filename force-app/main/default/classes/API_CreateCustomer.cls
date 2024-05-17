@RestResource(urlMapping = '/CreateAccount/*')
global with sharing class API_CreateCustomer {
    
    //public String Classname = API_CreateAccountOpportunity.class.getName();
    global class Response extends WS_Response{
        public Response(){
        }

        public List<cls_customer_response> customer_status;
    }

    @HttpPost
    global static Response doPostAccountOpportunity(){
        // System.debug('name =====> ' + Classename);
        Response res = new Response();
        Integer failurecount;

        // ============================ Account Related ===============================
        set<String> CustomerExternalIds = new set<String>();
        List<Account> ExistingAccountList = new List<Account>();
        Map<String, Account> AccountExternalIdWithAccountMap = new Map<String, Account>();


        // ============================ Contact Related ================================
        List<Contact> ExistingContactList = new List<Contact>();
        Map<String, Contact> AccountExternalIdWithContactMap = new Map<String, Contact>();
        List<Contact> ContactListTObeInserted = new List<Contact>();

        // ============================= Opporttunity Related ===========================
        List<Opportunity> OpportunityTobeINsertedList = new List<Opportunity>();
        res.customer_status = new List<cls_customer_response>();

        // ============================= Response Map ============================================
        Map<String, cls_customer_response> AccountIdWithCustomerResponseWrapperClass = new Map<String, cls_customer_response>();
        map<String, String> JouneryExternalIdWithCustExternalIDMap = new Map<String, string>();
        Map<String, String> CustomerExternalIdWithAccountIdMap = new Map<String, String>();


        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString.length());
            if (!String.isBlank(requestString)){
                List<object> bodyMapList = (List<object>)JSON.deserializeUntyped(requestString);

                if (!bodyMapList.isEmpty() && bodyMapList != null){
                    for (Object CustObjectLog : bodyMapList){
                        Map<string, Object> AccOppStringmap = (Map<string, Object>)CustObjectLog;
                        CustomerExternalIds.add(String.valueOf(AccOppStringmap.get('CustomerID')));
                        JouneryExternalIdWithCustExternalIDMap.put(String.valueOf(AccOppStringmap.get('ExternalId')), String.valueOf(AccOppStringmap.get('CustomerID')));

                        if (CustomerExternalIds.size() > 0){

                            ExistingAccountList = [SELECT AccountSource, Business_Type__c, CustomerID__c, Customer_Type__c, Description, Email_Id__c, External_ID__c, Id, phone, Name, OwnerId, PAN_No__c, Partner_Name__c, Product_Family_Lead__c			//Mobile_Number__c
                                                   FROM Account
                                                   Where External_ID__c IN:CustomerExternalIds];
                            if (!ExistingAccountList.isEmpty() && ExistingAccountList.size() > 0){
                                for (Account AccRec : ExistingAccountList){
                                    if (AccRec.External_ID__c != null){
                                        AccountExternalIdWithAccountMap.put(AccRec.External_ID__c, AccRec);
                                    }

                                }
                            }
                            ExistingContactList = [SELECT AccountId, Con_ExternalId__c, Email, Id, LeadSource, Lead__c, MobilePhone, Name, OwnerId, Phone, Title, Account.External_ID__c
                                                   FROM Contact
                                                   Where Account.External_ID__c IN:CustomerExternalIds];
                            if (!ExistingContactList.isEmpty() && ExistingContactList.size() > 0){
                                for (Contact ConRec : ExistingContactList){
                                    if (ConRec.Account.External_ID__c != null){
                                        AccountExternalIdWithContactMap.put(ConRec.Account.External_ID__c, ConRec);
                                    }

                                }
                            }
                        }
                    }
                }

                if (!bodyMapList.isEmpty()){
                    AccountWrapperDemo AccWrap = CreateAccountOPportunity(bodyMapList);

                    System.debug('AccWrap.AccountTobeInserted ====> ' + AccWrap.AccountTobeInserted);

                    if (AccWrap.AccountTobeInserted != null){
                        Schema.SObjectField ftoken = Account.Fields.External_Id__c;
                        Database.UpsertResult[] cr = Database.upsert (AccWrap.AccountTobeInserted, ftoken, false); //Lead.ExternalId__c.getDescribe().getSObjectField(),
                        Map<Id, Account> AccountMap = new Map<Id, Account>(AccWrap.AccountTobeInserted);

                        System.debug('AccountMap ======> ' + AccountMap);

                        cls_customer_response resStatusObj = new cls_customer_response();
                        for (Database.upsertResult result : cr){

                            System.debug('result =====> ' + result);
                            if (result.isSuccess()){
                                CustomerExternalIdWithAccountIdMap.put(AccountMap.get(result.getId()).External_ID__c, result.getId());

                                // =================== For Opportunity under account ==================================
                                Opportunity Newopp = new Opportunity();
                                Newopp.CloseDate = System.today().addDays(1);
                                Newopp.AccountId = result.getId();
                                
                                // ===================== For Contact Under Account =====================================
                                Contact NewContact = new Contact();
                                NewContact.AccountId = result.getId();

                                if (result.isCreated()){
                                    resStatusObj.SF_AccountRecid = result.getId();
                                    resStatusObj.Customer_type = AccountMap.get(result.getId()).Customer_Type__c;
                                    resStatusObj.Message = Constants.API_SUCCESS;
                                    resStatusObj.CustomerId = AccountMap.get(result.getId()).External_ID__c;


                                    if (AccountMap.get(result.getId()).CustomerID__c != null){
                                        Map<string, Object> AccountStringMap = (Map<string, Object>)(AccWrap.CustomerIdWithCustomerLog).get(AccountMap.get(result.getId()).CustomerID__c);
                                        System.debug('AccountStringMap =====> ' + AccountStringMap);
                                        System.debug('String.valueOf(AccountStringMap.get(SubStatus)) =====> ' + String.valueOf(AccountStringMap.get('SubStatus')));
                                        
                                        System.debug('AccountExternalIdWithContactMap size =====> ' + AccountExternalIdWithContactMap.size()); // || AccountExternalIdWithContactMap == null  && AccountExternalIdWithContactMap != null
                                        System.debug('String.valueOf(AccountMap.get(result.getId()).CustomerID__c) ======> ' + String.valueOf(AccountMap.get(result.getId()).CustomerID__c));
                                         if((AccountExternalIdWithContactMap.size()== 0 )){
                                            System.debug('AccountExternalIdWithContactMap ====> ' + AccountExternalIdWithContactMap);
                                            Contact ContactTobeCReate = CreateContactUnderAccount(AccountStringMap, NewContact);
                                            System.debug('ContactTobeCReate ====> ' + ContactTobeCReate);
                                            ContactTobeCReate.AccountId = result.getId();
                                            ContactListTObeInserted.add(ContactTobeCReate);
                                            System.debug('ContactListTObeInserted ====> ' + ContactListTObeInserted);
                                        }
                                        if ((AccountExternalIdWithContactMap.size() >0  && !AccountExternalIdWithContactMap.containsKey(String.valueOf(AccountMap.get(result.getId()).CustomerID__c)))) {
                                            Contact ContactTobeCReate = CreateContactUnderAccount(AccountStringMap, NewContact);
                                            ContactTobeCReate.AccountId = result.getId();
                                            ContactListTObeInserted.add(ContactTobeCReate);
                                        }
                                    }
                                    AccountIdWithCustomerResponseWrapperClass.put(String.valueOf(result.getId()), resStatusObj);

                                } else{
                                    resStatusObj.SF_AccountRecid = result.getId();
                                    resStatusObj.Customer_type = AccountMap.get(result.getId()).Customer_Type__c;
                                    resStatusObj.Message = Constants.API_UPDATED_SUCCESS;
                                    resStatusObj.CustomerId = AccountMap.get(result.getId()).External_ID__c;

                                    if (AccountMap.get(result.getId()).CustomerID__c != null){
                                        Map<string, Object> AccountStringMap = (Map<string, Object>)(AccWrap.CustomerIdWithCustomerLog).get(AccountMap.get(result.getId()).CustomerID__c);
                                        System.debug('AccountStringMap =====> ' + AccountStringMap);
                                        System.debug('String.valueOf(AccountStringMap.get(SubStatus)) =====> ' + String.valueOf(AccountStringMap.get('SubStatus')));
                                       
                                    }
                                    AccountIdWithCustomerResponseWrapperClass.put(String.valueOf(result.getId()), resStatusObj);

                                }
                                System.debug('AccountIdWithCustomerResponseWrapperClass ======> ' + AccountIdWithCustomerResponseWrapperClass);
                            } else{

                                System.debug('errors ===> ' + result.geterrors());
                                res.errorMessage = String.valueof(result.geterrors());
                                resStatusObj.SF_AccountRecid = '';
                                resStatusObj.Customer_type = 'Individual';
                                failureCount++;

                            }
                            if (failureCount == AccWrap.AccountTobeInserted.size()){
                                res.status = Constants.API_FAILURE;//Constants.WS_SUCCESS_STATUS;
                                res.statusCode = '400';//Constants.WS_SUCCESS_CODE;
                            }
                        }
                        if (AccWrap.AccountError_status != null){
                            res.status = 'Partially Success';//Constants.WS_SUCCESS_STATUS;
                            res.statusCode = '300';
                            res.customer_status.addall(AccWrap.AccountError_status);
                        }
                        System.debug('insert OpportunityTobeINsertedList ======> ' + OpportunityTobeINsertedList);

                        if (!ContactListTObeInserted.isEmpty()){
                            System.debug('ContactListTObeInserted ======> ' + ContactListTObeInserted);
                            Database.SaveResult[] cONTACTSresults = Database.insert (ContactListTObeInserted, false);
                            System.debug('cONTACTSresults ======> ' + cONTACTSresults);
                        }
                        /*if (!OpportunityTobeINsertedList.isEmpty()){
                            Schema.SObjectField Oppftoken = Opportunity.Fields.Opp_ExternalId__c;
                            Database.UpsertResult[] OppSaveResult = Database.upsert (OpportunityTobeINsertedList, Oppftoken, false);
                            Map<Id, Opportunity> OppSavedResultMap = new Map<Id, Opportunity>(OpportunityTobeINsertedList);
                            System.debug('OppSavedResultMap ====> ' + OppSavedResultMap);

                            integer i = 0;
                            for (Database.upsertResult Oppresult : OppSaveResult){

                                System.debug('result =====> ' + Oppresult);
                                if (Oppresult.isSuccess()){
                                    if (Oppresult.isCreated()){
                                        

                                        if (AccountIdWithCustomerResponseWrapperClass.containsKey(OppSavedResultMap.get(Oppresult.getId()).AccountId)){
                                            cls_customer_response resStatusObjOpp = AccountIdWithCustomerResponseWrapperClass.get(OppSavedResultMap.get(Oppresult.getId()).AccountId);
                                            resStatusObjOpp.SF_WhatId = Oppresult.getId();
                                            resStatusObjOpp.Application_Status = Constants.API_SUCCESS_APPLICATION;
                                            resStatusObjOpp.ExternalId = OppSavedResultMap.get(Oppresult.getId()).Opp_ExternalId__c;
                                            AccountIdWithCustomerResponseWrapperClass.put(OppSavedResultMap.get(Oppresult.getId()).AccountId, resStatusObjOpp);

                                        }

                                    } else{
                                        System.debug('OppSavedResultMap.get(Oppresult.getId()).AccountId =====> ' + OppSavedResultMap.get(Oppresult.getId()).AccountId);
                                        if (AccountIdWithCustomerResponseWrapperClass.containsKey(OppSavedResultMap.get(Oppresult.getId()).AccountId)){
                                            System.debug('AccountIdWithCustomerResponseWrapperClass.get(OppSavedResultMap.get(Oppresult.getId()).AccountId) ======> ' + AccountIdWithCustomerResponseWrapperClass.get(OppSavedResultMap.get(Oppresult.getId()).AccountId));
                                            cls_customer_response resStatusObjOpp = AccountIdWithCustomerResponseWrapperClass.get(OppSavedResultMap.get(Oppresult.getId()).AccountId);
                                            resStatusObjOpp.SF_WhatId = Oppresult.getId();
                                            resStatusObjOpp.Application_Status = Constants.API_UPDATED_SUCCESS_APPLICATION;
                                            resStatusObjOpp.ExternalId = OppSavedResultMap.get(Oppresult.getId()).Opp_ExternalId__c;
                                            AccountIdWithCustomerResponseWrapperClass.put(OppSavedResultMap.get(Oppresult.getId()).AccountId, resStatusObjOpp);

                                        }

                                    }
                                } else{
                                    cls_customer_response resStatusObjOpp = new cls_customer_response();
                                    String AccountExternalID = '';
                                    String OppExternalId = OpportunityTobeINsertedList[i].Opp_ExternalId__c;
                                    if (OppExternalId != null && !JouneryExternalIdWithCustExternalIDMap.isEmpty() && JouneryExternalIdWithCustExternalIDMap.containsKey(OppExternalId)){
                                         AccountExternalID = JouneryExternalIdWithCustExternalIDMap.get(OppExternalId);
                                        if (AccountExternalID != null && !CustomerExternalIdWithAccountIdMap.isEmpty() && CustomerExternalIdWithAccountIdMap.containsKey(AccountExternalID)){
                                            String AccountId = CustomerExternalIdWithAccountIdMap.get(AccountExternalID);
                                            resStatusObjOpp = AccountIdWithCustomerResponseWrapperClass.get(AccountId);
                                            List<Database.Error> errors = Oppresult.getErrors();
                                            for (Database.Error theError : errors){
                                                System.debug('theError ======> ' + theError);
                                                if (theError.getStatusCode() != null){
                                                    resStatusObjOpp.ExternalId = OppExternalId;
                                                    resStatusObjOpp.SF_WhatId = '';
                                                    resStatusObjOpp.Application_Status = String.valueOf(theError.getStatusCode());
                                                }
                                            }
                                        }
                                    }

                                    AccountIdWithCustomerResponseWrapperClass.put(AccountExternalID, resStatusObjOpp); 
                                }
                                i++;
                            }

                            System.debug('OppSaveResult ======> ' + OppSaveResult);
                        }*/
                    }
                    res.customer_status.addAll(AccountIdWithCustomerResponseWrapperClass.values());
                } else{
                    res.status = 'Error';
                    res.errorMessage = 'REQUEST BODY IS NULL';
                    res.statusCode = '400';
                    return res;
                }
            } else{

            }
            return res;
        } catch (Exception e){
            System.debug('The error has occured due to ====> ' + e.getMessage());
            System.debug('The error at line number =======> ' + e.getLineNumber());

        }
        return res;
    }

    public static AccountWrapperDemo CreateAccountOPportunity(List<object> bodyList){

        Map<string, Object> CustomerIdWithCustomerLog = new Map<string, Object>();
        List<Account> AccountTobeInserted = new List<Account>();
        List<Account> AccountNotTobeInserted = new List<Account>();
        AccountWrapperDemo AccWrap = new AccountWrapperDemo();
        List<cls_customer_response> AccountError_status = new List<cls_customer_response>();
        try{
            if (!bodyList.isEmpty()){
                for (Object CustObjectLog : bodyList){
                    Map<string, Object> AccOppStringmap = (Map<string, Object>)CustObjectLog;
                    CustomerIdWithCustomerLog.put(string.valueof(AccOppStringmap.get('CustomerID')), CustObjectLog);
                }

                for (Object CustObjectLog : bodyList){
                    Account NewAccount = new Account();
                    NewAccount.Customer_Type__c= 'Individual';
                    cls_customer_response resStatusObj = new cls_customer_response();
                    Map<string, Object> AccOppStringmap = (Map<string, Object>)CustObjectLog;

                    if (string.valueOf(AccOppStringmap.get('CustomerID')) != null && string.valueOf(AccOppStringmap.get('CustomerID')) != ''){
                        NewAccount.CustomerID__c = string.valueOf(AccOppStringmap.get('CustomerID'));
                        if (string.valueOf(AccOppStringmap.get('Company')) == null || string.valueOf(AccOppStringmap.get('Company')) == ''){
                            NewAccount.Name = string.valueOf(AccOppStringmap.get('CustomerID'));
                        }
                    }
                    if (string.valueOf(AccOppStringmap.get('Phone')) != null && string.valueOf(AccOppStringmap.get('Phone')) != ''){
                        NewAccount.Phone = string.valueOf(AccOppStringmap.get('Phone'));
                    }
                    if (string.valueOf(AccOppStringmap.get('Company')) != null && string.valueOf(AccOppStringmap.get('Company')) != ''){
                        NewAccount.Name = string.valueOf(AccOppStringmap.get('Company'));
                    }
                    if (string.valueOf(AccOppStringmap.get('Email')) != null && string.valueOf(AccOppStringmap.get('Email')) != ''){
                        NewAccount.Email_Id__c = string.valueOf(AccOppStringmap.get('Email'));
                    }
                    if (string.valueOf(AccOppStringmap.get('ProductFamily')) != null && string.valueOf(AccOppStringmap.get('ProductFamily')) != ''){
                        NewAccount.Product_Family_Lead__c = string.valueOf(AccOppStringmap.get('ProductFamily'));
                    }
                   
                    if (string.valueOf(AccOppStringmap.get('Source')) != null && string.valueOf(AccOppStringmap.get('Source')) != ''){
                        NewAccount.AccountSource = string.valueOf(AccOppStringmap.get('Source'));
                    }
                    if (string.valueOf(AccOppStringmap.get('Status')) != null && string.valueOf(AccOppStringmap.get('Status')) != ''){
                        NewAccount.Account_Status__c = string.valueOf(AccOppStringmap.get('Status'));
                    }
                    if (string.valueOf(AccOppStringmap.get('CustomerID')) != null && string.valueOf(AccOppStringmap.get('CustomerID')) != ''){
                        NewAccount.External_ID__c = string.valueOf(AccOppStringmap.get('CustomerID'));
                        AccountTobeInserted.add(NewAccount);
                    } else{
                        AccountNotTobeInserted.add(NewAccount);
                        resStatusObj.Customer_type = String.valueOf(AccOppStringmap.get('CustomerType'));
                        resStatusObj.CustomerId = '';
                        resStatusObj.Message = 'Lead does not have ExternalId. Please Provide ExternalId belong this customer.';
                        resStatusObj.SF_AccountRecid = '';
                        AccountError_status.add(resStatusObj);
                    }
                }

                if (!AccountTobeInserted.isEmpty()){
                    AccWrap.AccountTobeInserted = AccountTobeInserted;
                } else{
                    AccWrap.AccountTobeInserted = Null;
                }
                if (!AccountError_status.isEmpty()){
                    AccWrap.AccountError_status = AccountError_status;
                } else{
                    AccWrap.AccountError_status = null;
                }
                if (!CustomerIdWithCustomerLog.isEmpty()){
                    AccWrap.CustomerIdWithCustomerLog = CustomerIdWithCustomerLog;
                }
            }
            // return AccWrap;
        } catch (Exception e){
            System.debug('The error has occured due to ======> ' + e.getMessage());
            System.debug('The error has occured due to ======> ' + e.getLineNumber());
            //return null;
        }
        return AccWrap;
    }

    public static Contact CreateContactUnderAccount(Map<string, Object> AccountStringMap, Contact Con){

        if ((String.valueOf(AccountStringMap.get('CustomerID')) != null && String.valueOf(AccountStringMap.get('CustomerID')) != '')){
            if ((String.valueOf(AccountStringMap.get('LastName')) == null || String.valueOf(AccountStringMap.get('LastName')) == '')){
                Con.LastName = String.valueOf(AccountStringMap.get('CustomerID'));
            }

        }
        //if ((String.valueOf(AccountStringMap.get('FirstName')) != null && String.valueOf(AccountStringMap.get('FirstName')) != '') || (String.valueOf(AccountStringMap.get('LastName')) != null && String.valueOf(AccountStringMap.get('LastName')) != '')){
            if (String.valueOf(AccountStringMap.get('FirstName')) != null && String.valueOf(AccountStringMap.get('FirstName')) != ''){
                Con.FirstName = String.valueOf(AccountStringMap.get('FirstName'));
            } 
            if (String.valueOf(AccountStringMap.get('LastName')) != null && String.valueOf(AccountStringMap.get('LastName')) != ''){
                Con.LastName = String.valueOf(AccountStringMap.get('LastName'));
            }

        //}
        return Con;
    }

    public class AccountWrapperDemo{
        public List<Account> AccountTobeInserted{ get; set; }
        public List<cls_customer_response> AccountError_status{ get; set; }
        public Map<string, Object> CustomerIdWithCustomerLog{ get; set; }
    }
    class cls_customer_response{
        public String SF_AccountRecid;
        public String Customer_type;
        public string Message;
        public string CustomerId;

    }
    /*public class OppWrapperDemo{
        public Opportunity OppTobeInserted{ get; set; }
        public String OpportunityError_status{ get; set; }

    }*/
}