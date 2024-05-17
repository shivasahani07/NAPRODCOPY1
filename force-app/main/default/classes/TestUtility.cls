@istest(SeeAllData=false)
public without sharing class TestUtility{
    public static Process_Attribute__c createProAttributeInstance(){
        
        // =================================== Process Attribute Instance Creation ==================================
        
        Process_Attribute__c ProAttribute = new Process_Attribute__c();
        ProAttribute.Name = 'C-233';
        
        ProAttribute.Case_Category__c = 'Bureau Related';
        ProAttribute.Case_Type__c = 'Complaint';
        ProAttribute.Case_Sub_Category__c = 'Bureau Update';
        ProAttribute.isActive__c = true;
        ProAttribute.Object_Type__c = 'Case';
        ProAttribute.SLA__c = 1;
        //insert ProAttribute;
        return ProAttribute;
        
    }

    


	
    
    // =================================== used for test class  AccountControllerTest ==================================
    
    public static Account createTestAccount() {
        Account testAccount = new Account(Name='Test Account', Email_Id__c='test@example.com', Phone='1234567890', CIN_No__c='CIN12345', CustomerID__c='48776463589879');
        insert testAccount;
        return testAccount;
    }
    
    public static Process_Path__c createTestProcessPath() {
        Process_Path__c testPP = new Process_Path__c();
        testPP.isActive__c = true;
        testPP.Name = 'Opp - NuScoreRecalibrationInvoiceCreation P0';
        insert testPP;
        return testPP;
    }
    
    public static Process_Task_Detail__c createMockProcessTaskDetail() {
        Process_Task_Detail__c mockProcessTaskDetail = new Process_Task_Detail__c(Subject__c = 'Communication - Email');
        insert mockProcessTaskDetail;
        return mockProcessTaskDetail;
    }
    
    public static Process_Path_Task_Detail__c createProcessPathTaskDetail(Process_Path__c testPP, Process_Task_Detail__c mockProcessTaskDetail) {
        Process_Path_Task_Detail__c pptDetail = new Process_Path_Task_Detail__c(
            Subject__c = 'Test Subject',
            Process_Path__c = testPP.Id,
            Process_Task_Detail__c = mockProcessTaskDetail.Id,
            Business_Step_No__c = 1,
            Execution_Serial_No__c = '1',
            Task_Owner_Type__c = 'System',
            Task_Owner_Name__c = 'Test System',
            isActive__c = true
        );
        insert pptDetail;
        return pptDetail;
    }
    
    public static Process_Path_Task_Detail__c createProcessPathTaskDetail2(Process_Path__c testPP, Process_Task_Detail__c mockProcessTaskDetail) {
        Process_Path_Task_Detail__c pptDetail = new Process_Path_Task_Detail__c(
            Subject__c = 'Test Subject',
            Process_Path__c = testPP.Id,
            Process_Task_Detail__c = mockProcessTaskDetail.Id,
            Business_Step_No__c = 1,
            Execution_Serial_No__c = '1',
            Task_Owner_Type__c = 'System',
            Task_Owner_Name__c = 'Test System',
             isActive__c = true
        );
        insert pptDetail;
        return pptDetail;
    }
    
     public static Process_Attribute_Path_Deviation__c ProcessAttributePathD() {
         
         Process_Attribute_Path_Deviation__c processAttributePD = new Process_Attribute_Path_Deviation__c();
         
         processAttributePD.Document_Sharing_Status__c = 'Approved';
         processAttributePD.Process_Path_Type__c = 'Adhoc Path';
         //processAttributePD.Object_Type__c = 'Opportunity';
         //insert processAttributePD;
         return processAttributePD;
         
     }
    
    
     // =================================== used for api test class (API_SearchPartnersAPITest) ==================================
    public static Task createTestTaskWithAttribute(String attributeValue) {
        // First, create and insert a new Account with all necessary fields populated.
        Account testAccount = createTestAccount();
        
        
        
        
        // Then, create a new Task that is related to the Account just created.
        Task testTask = new Task();
        testTask.Subject = 'Test Task';
        testTask.Status = 'Open';
        // Here, link the Task to the Account via the WhatId field.
        testTask.WhatId = testAccount.Id;
        
        // If there's a specific attribute field, set it as well.
        // For example, if Attribute1__c is a field on the Task object, set it like this:
        testTask.Attribute1__c = attributeValue;
        
        //insert testTask;
        
        return testTask;
    }
    
    
    public static Task createTestTaskForPaymentSchedule() {
        Account testAccount = createTestAccount();
        Opportunity testOpportunity = createTestOpportunity(testAccount.Id);
        //Payment_Schedule__c testPaymentSchedule = createTestPaymentSchedule(testOpportunity.Id);
        // Create and link Task to the Opportunity
        Task testTask = new Task(Subject = 'Test Task for Payment Schedule', WhatId = testOpportunity.Id, Status = 'Open');
        insert testTask;
        return testTask;
    }

    public static Opportunity createTestOpportunity(Id accountId) {
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(10), AccountId = accountId);
        //insert opp;
        return opp;
    }

    /*public static Payment_Schedule__c createTestPaymentSchedule(Id opportunityId) {
        // Assume that Price_Structure__c is a child object of Payment_Schedule__c
        Payment_Schedule__c ps = new Payment_Schedule__c(
            //Name = 'Test Payment Schedule', 
            Opportunity__c = opportunityId, 
            Billing_Frequency__c = 'Monthly',
            Billing_Period__c = 86,
            Ceiling_Period__c= 'Monthly',
            Ceiling_Price__c=78,
            Comment__c = 'Hi there',
            Cost_Price_Type__c = 'Model Build Price',
            Floor_Period__c = 'Semi-Annually',
            Floor_Price__c = 68,
            Model_Build_Price__c = 84,
            Model_Recalibration_Price__c=87,
            validity_End_Date__c = Date.newInstance(2024, 12, 9),
            validity_start_Date__c = Date.newInstance(2024, 02, 9)
            
            
            // Set other fields as required by your logic in API_CreatePaymentScheduleAPI
        );
        insert ps;

        // Add related Price_Structures__c records if necessary
        // ...

        return ps;
    }*/
    
    public static Task createTestTaskForOpportunity(Id opportunityId) {
        Task testTask = new Task();
        testTask.WhatId = opportunityId; // Assuming 'WhatId' is used to link the Task to the Opportunity
        // Populate other necessary fields for the Task here
        // ...
        //insert testTask;
        return testTask;
    }

    // Method to create a test price structure for a given payment schedule ID
    /*public static Price_Structure__c createTestPriceStructure(
        Id paymentScheduleId, 
        String priceStructureType, 
        Decimal startValue, 
        Decimal endValue, 
        Decimal rate,
        String resetFrequency
    ) {
        Price_Structure__c priceStructure = new Price_Structure__c(
            Payment_Schedule__c = paymentScheduleId,
            Price_Structure_Type__c = priceStructureType,
            Start_Value__c = startValue,
            End_Value__c = endValue,
            Rate__c = rate,
            Price_Structure_Reset_Frequency__c = resetFrequency
            // Add other fields as necessary
        );
        
        insert priceStructure;
        return priceStructure;
    }*/
    
    
    
    
    
    public static List<Process_Attribute_Details__c> createProAttridetailsInstance(){
        
        List<Process_Attribute_Details__c> ProAttributeDetailsList = new List<Process_Attribute_Details__c>();
        
        // =================================== Process Attribute Details First ==================================
        Process_Attribute_Details__c ProAttDetailsFirst = new Process_Attribute_Details__c();
        ProAttDetailsFirst.name = 'C-233-1.1';
        ProAttDetailsFirst.Stage_SL_No__c = '1';
        ProAttDetailsFirst.Stage_Step__c = 'Communication';
        ProAttDetailsFirst.Task_Subject_Sl_No__c = '1';
        ProAttDetailsFirst.Task_Subject__c = 'Communication - Email';
        ProAttDetailsFirst.SLA__c = 1;
        ProAttDetailsFirst.Task_Owner_Type__c = 'Case Owner';
        ProAttDetailsFirst.Allowed_No_Of_Attempts__c = 1;
        ProAttDetailsFirst.isActive__c = true;
        ProAttributeDetailsList.add(ProAttDetailsFirst);
        
        
        // =================================== Process Attribute Details Second ==================================
        Process_Attribute_Details__c ProAttDetailsSecond = new Process_Attribute_Details__c();
        ProAttDetailsSecond.name = 'C-233-10.1';
        ProAttDetailsSecond.Dependent_of_Tasks__c = 'C-233-1.1';
        ProAttDetailsSecond.Stage_SL_No__c = '10';
        ProAttDetailsSecond.Stage_Step__c = 'Transfer Ownership';
        ProAttDetailsSecond.Task_Subject_Sl_No__c = '1';
        ProAttDetailsSecond.Task_Subject__c = 'Change Ownership - Operations - DO Bureau';
        ProAttDetailsSecond.SLA__c = 1;
        ProAttDetailsSecond.Task_Owner_Type__c = 'System';
        ProAttDetailsSecond.Allowed_No_Of_Attempts__c = 1;
        ProAttDetailsSecond.isActive__c = true;
        
        ProAttributeDetailsList.add(ProAttDetailsSecond);
        
        // =================================== Process Attribute Details Third ==================================
        Process_Attribute_Details__c ProAttDetailsThird = new Process_Attribute_Details__c();
        ProAttDetailsThird.name = 'C-233-20.1';
        ProAttDetailsThird.Dependent_of_Tasks__c = 'C-233-10.1';
        ProAttDetailsThird.Stage_SL_No__c = '1';
        ProAttDetailsThird.Stage_Step__c = 'Operation Activity';
        ProAttDetailsThird.Task_Subject_Sl_No__c = '1';
        ProAttDetailsThird.Task_Subject__c = 'Bureau Update Activity';
        ProAttDetailsThird.SLA__c = 1;
        ProAttDetailsThird.Task_Owner_Type__c = 'Queue';
        ProAttDetailsThird.Task_Owner_Name__c = 'Operations - DO';
        ProAttDetailsThird.Allowed_No_Of_Attempts__c = 1;
        ProAttDetailsThird.isActive__c = true;
        
        ProAttributeDetailsList.add(ProAttDetailsThird);
        return ProAttributeDetailsList;
    }
    
    public static Process_Attribute_Details__c createProcessAttributeDetails(){
        Process_Attribute_Details__c ProAttDetails = new Process_Attribute_Details__c();
        ProAttDetails.name = 'C-233-20.1';
        ProAttDetails.Dependent_of_Tasks__c = 'C-233-10.1';
        ProAttDetails.Stage_SL_No__c = '1';
        ProAttDetails.Stage_Step__c = 'Operation Activity';
        ProAttDetails.Task_Subject_Sl_No__c = '1';
        ProAttDetails.Task_Subject__c = 'Bureau Update Activity';
        ProAttDetails.SLA__c = 1;
        ProAttDetails.Task_Owner_Type__c = 'Queue';
        ProAttDetails.Task_Owner_Name__c = 'Operations - DO';
        ProAttDetails.Allowed_No_Of_Attempts__c = 1;
        ProAttDetails.isActive__c = true;
        
        
		
        return ProAttDetails;
    }
    
    // =================================== Process Dependent Task Detail Instance Creation ==================================
    Public static Process_Dependent_Task_Details__c CreateProdependenttask(String ProcessAttrId, String CurrentProcessAttridetailID, String DependTaskId){
        
        Process_Dependent_Task_Details__c ProDependTask = new Process_Dependent_Task_Details__c();
        ProDependTask.Process_Attribute__c = ProcessAttrId;
        ProDependTask.Current_Process_Attribute_Details__c = CurrentProcessAttridetailID;
        ProDependTask.Depend_On_Process_Attribute_Details__c = DependTaskId;
        return ProDependTask;
    }
    
    // =================================== Account Instance Creation ==================================
    public static account createaccountInstance(){
        account acc = new account();
        acc.name = 'Dummy Account';
       // acc.AADHAAR_No__c = '345678909876.0';
        acc.Email_Id__c = 'Mukesh.test@maail.com';
        acc.phone = '';
        //acc.Mobile_Number__c = '';
        acc.PAN_No__c = '';
        acc.Phone = '';
        acc.BillingCity = 'Bangalore';
        acc.BillingCountry = 'INdia';
        acc.BillingPostalCode = '560034';
        acc.BillingState = 'Karnataka';
        acc.BillingStreet = 'Commercial Street';
        return acc;
    }
    
    // =================================== Case Instance Creation ==================================
    public static case CreateCaseInstance(){
        Case c = new Case();
        c.Type = 'Complaint';
        c.Origin = 'Email';
        c.Status = 'New';
        return c;
    }
    
    // =================================== Financial Account Instance Creation ==================================
    Public static Financial_Account__c CreateFinancialAccountInstance(){
        
        Financial_Account__c FinancialRec = new Financial_Account__c();
        Account accounts = createaccountInstance();
        FinancialRec.Account_Name__c = accounts.Id;
        FinancialRec.Name = '34334';
        FinancialRec.Loan_Category__c = 'BTC';
        FinancialRec.Originating_System__c = 'Perdix';
       FinancialRec.Sanctioned_Amount__c = 478760;
        
        //FinancialRec.Receivables_Amount__c = 47876;
        //FinancialRec.Payable_Amount__c = 4787;
        insert FinancialRec;
        return FinancialRec;
    }
    
   // ==================================== Financial Account Instance for WelcomeLetterHandler================================
   Public static Financial_Account__c CreateFinancialAccountInstanceW(){
        
        Financial_Account__c FinancialRec = new Financial_Account__c();
        Account accounts = createaccountInstance();
        FinancialRec.Account_Name__c = accounts.Id;
        FinancialRec.Name = '34334';
        FinancialRec.Loan_Category__c = 'SBL';
        FinancialRec.Originating_System__c = 'Perdix';
        FinancialRec.Sanctioned_Amount__c = 478760;
        
        //FinancialRec.Receivables_Amount__c = 47876;
        //FinancialRec.Payable_Amount__c = 4787;
        
        return FinancialRec;
   }
     Public static Financial_Entity__c CreateFinancialEntityInstance(){
         Financial_Account__c testFA = CreateFinancialAccountInstance();
        Financial_Entity__c FinancialEntity = new Financial_Entity__c();
         
        FinancialEntity.Financial_Account__c =testFA.Id;
         //FinancialEntity.Account_Name__c = acc.Id;
        //insert FinancialEntity;
        return FinancialEntity;
    }
    
    
     public static Paybale__c createMODTInstance(){
        Financial_Account__c testFA =CreateFinancialAccountInstance();
		Financial_Entity__c  testFinancialEntity = CreateFinancialEntityInstance();
         insert testFinancialEntity;
        //Financial_Entity_AC_Detail__c FinancialEntityAccountDetail = CreateFiancialEntityAcctDetailInsatance();
        Paybale__c testMEMO = new Paybale__c();
        testMEMO.Amount__c=12345;
        //testMEMO.Financial_Entity_A_C_Details__c = FinancialEntityAccountDetail.Id;
        //testMEMO.Due_Date__c=system.today();
        testMEMO.IsActive__c=true;	
        testMEMO.Financial_Account__c=testFA.id;
         testMEMO.Task_Id__c = null;
         testMEMO.RBI_UTR_Reference_Number__c = '12345';
		testMemo.Finacial_Entity_Details__c = testFinancialEntity.Id;
        testMemo.Status__c ='Memo Created';
         insert testMEMO;
        return testMEMO;
    }
    
    // =================================== Group Instance Creation ==================================
    Public static Group CreateGroupInstance(){
        
        Group grp = new Group();
        grp.name = 'Business Team Do';
        grp.Type = 'queue';
        return grp;
    }
    
    // =================================== Group Member Instance Creation ==================================
    Public static GroupMember CreateGroupMemberInstance(){
        
        //Create Group Member
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        //grpMem1.GroupId = grp.Id;
        return grpMem1;
    }
    
    Public static Lead CreateLeadINstance(){
        Lead newLead = new Lead();
        newLead.FirstName = 'Test API';
        NewLead.LastName = 'Test Lead';
        NewLead.Company = 'Test Company';
        NewLead.Customer_Type__c = 'Partner';
        NewLead.ExternalId__c = '5887789878';
        NewLead.CustomerID__c = '3654547757657';
        NewLead.Product_Interested__c = 'Education Loan';
        return newLead;
    }
    
    Public static Opportunity CreateOppINstance(){
        Opportunity newOpp = new Opportunity();
        newOpp.type = 'Education loan Application';
        newOpp.Name = 'Test Opp';
        newOpp.CloseDate = system.today().adddays(2);
        newOpp.SubStatus__c = 'Education loan Details';
        newOpp.StageName = 'Aadhar Flow';
        newOpp.Customer_Type__c = 'Individual';
        //newOpp.Product_Interested__c = 'Education loan';
        newOpp.Opp_ExternalId__c = '2836287362846854';
        return newOpp;
    }
    
    Public static Contact CreateContactINstance(){
        Contact newCon = new Contact();
        newCon.FirstName = 'Test API';
        newCon.LastName = 'LastName';
        newCon.email = 'Test@mail.com';
        newCon.Phone = '64826462492';
        return newCon;
    }
    
    public static task CreateTaskInstance(){
        Process_Path_Task_Detail__c processPathTaskDetail = createPPTD();
        
        Task tsk = new Task();
        tsk.Process_Path_Task_Detail__c = processPathTaskDetail.Id;
        tsk.Subject = 'Call';
        tsk.Status = 'Open';
        tsk.Priority = 'Normal';
        tsk.ActivityDate = System.today();
        
        return tsk;
    }
    
    @testSetup
    public static void APICallingSystemDetails(){
        list<API_Calling_System_Details__c> acsdlist = new list<API_Calling_System_Details__c>();
        for(integer i=0; i<5; i++){
            API_Calling_System_Details__c acsd = new API_Calling_System_Details__c();
            //acsd.name = 'ACSD-001';
            acsd.System_Name__c = 'EL';
            acsd.Upsert_Related_To__c = 'Upsert_Related_To__c';
            acsdlist.add(acsd);
        }
        
        insert acsdlist;
        for(integer j=0; j<acsdlist.size(); j++){
            system.debug('acsdlist ===> ' + acsdlist[j].name);
        }
        
        
        APIFieldSystemDetails(acsdlist);
        //return acsdlist;
        
    }
    
    private static void APIFieldSystemDetails(list<API_Calling_System_Details__c> acsdlist){
        API_Field_Processing_Detail__c afpd = new API_Field_Processing_Detail__c();
        afpd.API_Calling_System_Details__c = acsdlist[2].id;
        insert afpd;
        
    }
    
    public static Document_Metadata__c createDocumentmetadata(){
        
        Document_Metadata__c testDocumentMetaData = new Document_Metadata__c();
        testDocumentMetaData.Document_Category__c='Cheque';
        testDocumentMetaData.Document_Id_Name__c='Cheque no.';
        testDocumentMetaData.Name = 'MEMO Executed';
        testDocumentMetaData.Document_Name__c='MEMO Executed';
       	testDocumentMetaData.Related_To_sObject__c = 'MODT_Details__c';
        return testDocumentMetaData;
    }
    
    // ====================== Might not be used =================================
    /*public static  Process_Path_Task_Detail__c createPPTD(){
        Process_Path__c  testPP=createTestProcessPath();
        Process_Task_Detail__c processTaskDetail = createMockProcessTaskDetail();
        Process_Path_Task_Detail__c testPPTD = new Process_Path_Task_Detail__c();
        testPPTD.isActive__c=true;
        testPPTD.Subject__c = 'Test Subject';
        testPPTD.Manual_API_Call_Out__c = true;
        testPPTD.Business_Step_No__c = 45;
        testPPTD.Task_Owner_Name__c = 'Test Owner';
        testPPTD.Process_Path__c=testPP.id;
        testPPTD.Process_Task_Detail__c = processTaskDetail.Id;
        testPPTD.Execution_Serial_No__c = '1';
        insert testPPTD;
        return testPPTD;
    }*/
    
    
    Public static Document_Handler__c createDocumentHandlerInstance(){
        Account accoundInstance= createTestAccount();
        Document_Metadata__c testDocumentMetaData =createDocumentmetadata(); 
        insert testDocumentMetaData;
        Paybale__c testMEMO =createMODTInstance();
        Task testTask=CreateTaskInstance();
        insert testTask;
        //Process_Attribute_Dcoument_Detail__c ProcessAtributeDocDetail = ProcessAttributeDocumentDetailInstance();
		//insert ProcessAtributeDocDetail;
        //system.debug('ProcessAtributeDocDetail Is_Alternate_Document_Upload_Applicable__c ===> ' + ProcessAtributeDocDetail.Is_Alternate_Document_Upload_Applicable__c);
        Document_Handler__c testDocument = new Document_Handler__c();
        //testDocument.Status__c = 'Draft';
        testDocument.Transfer_to__c=accoundInstance.id;
        testDocument.Extended_SObject_RecordId__c=testMEMO.id;
        testDocument.Document_Metadata__c=testDocumentMetaData.Id;
        testDocument.Document_Sharing_Task_Ids__c=testTask.id;
        testDocument.Tracking_Number__c='123456';
       // testDocument.Process_Attribute_Dcoument_Detail__c = ProcessAtributeDocDetail.Id;
        testDocument.Is_Alternate_Document_Uploded__c = true;
        return testDocument;
    }
    
    Public static Document_Handler_History__c createDHHInstance(){
        
        Document_Handler_History__c DHH = new Document_Handler_History__c();
        DHH.File_Name__c= 'ABDC';
        DHH.DMS_System_Name__c = 'Salesforce';
        DHH.Document_Path__c= 'a0I72000001boDNEAY';
       return DHH; 
    }
    
    
    
    
    public static Process_Attribute_Dcoument_Detail__c ProcessAttributeDocumentDetailInstance() {
        Process_Attribute_Dcoument_Detail__c ProcessAtributeDocDetail = new Process_Attribute_Dcoument_Detail__c();
        Process_Path_Task_Detail__c ProcessPathTaskDetail = createPPTD();
        Document_Metadata__c testDocumentMetaData = createDocumentmetadata();
        //testDocumentMetaData.Related_To_sObject__c ='Financial_Entity_AC_Detail__c';
        insert testDocumentMetaData;
        ProcessAtributeDocDetail.Process_Path_Task_Detail__c = ProcessPathTaskDetail.Id;
        ProcessAtributeDocDetail.Deviation_Approver__c  = 'User';
        ProcessAtributeDocDetail.Deviation_Approver_Type__c = 'queue';
        ProcessAtributeDocDetail.Reviewer_Name__c = 'Test';
        ProcessAtributeDocDetail.Reviewer_Type__c = 'User';
        ProcessAtributeDocDetail.Document_Metadata__c = testDocumentMetaData.Id;
        ProcessAtributeDocDetail.Is_Alternate_Document_Upload_Applicable__c = true;
        return ProcessAtributeDocDetail;
        
    }
    
    
    public static MODT_Details__c CreateMODTDetailInsatance(){
        MODT_Details__c ModtDetail = new MODT_Details__c();
        Financial_Account__c FinancialAccount= CreateFinancialAccountInstance();
        ModtDetail.Date_Of_Execution__c = Date.newInstance(2024, 12, 9);
        ModtDetail.Status__c = 'Draft';
        ModtDetail.Task_Id__c = '1234';
        ModtDetail.Financial_Account__c = FinancialAccount.id;
        //insert ModtDetail;
        return ModtDetail;
        
    }
    
    
    public static Financial_Entity_AC_Detail__c CreateFiancialEntityAcctDetailInsatance(){
        Financial_Entity_AC_Detail__c FianancialEntityAccDetail = new Financial_Entity_AC_Detail__c();
        //Id defaultRecordTypeId = Schema.SObjectType.Financial_Entity_AC_Detail__c.getRecordTypeInfosByName().get('Default_Record_Type').getRecordTypeId();
        //FianancialEntityAccDetail.RecordTypeId = defaultRecordTypeId;
        Financial_Account__c FinancialAccount  = CreateFinancialAccountInstance();
        Financial_Entity__c FinancialEntity = CreateFinancialEntityInstance();
        insert FinancialEntity;
        FianancialEntityAccDetail.Bank_Name__c = 'Test Bank';
        FianancialEntityAccDetail.Branch_Name__c = 'Bengaluru';
        FianancialEntityAccDetail.Verification_Status__c = 'Pending';
        FianancialEntityAccDetail.IFSC_Code__c = 'IFSC001234';
        //FianancialEntityAccDetail.Digitally_Verification_Method__c = 'Karza';
        FianancialEntityAccDetail.Task_ID__c = '1234';
        FianancialEntityAccDetail.Bank_Account_Number__c = '940234657813';
        FianancialEntityAccDetail.Bank_Account_Type__c = 'Savings';
        FianancialEntityAccDetail.Physically_verified__c = true;
        FianancialEntityAccDetail.Banking_Account_Name__c = 'Test Bank Account';
        FianancialEntityAccDetail.Financial_Entity__c = FinancialEntity.Id;
        FianancialEntityAccDetail.Financial_Account__c = FinancialAccount.Id;
        //insert FianancialEntityAccDetail;
        return FianancialEntityAccDetail;
    }
    
    Public static user createUserInstance(){
        Individual testIndividual=createIndividulaInstance();
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User testUser=new User(firstname = 'ABC', 
                               lastName = 'XYZ', 
                               email = uniqueName + '@test' + orgId + '.org', 
                               Username = uniqueName + '@test' + orgId + '.org', 
                               EmailEncodingKey = 'ISO-8859-1', 
                               Alias = uniqueName.substring(18, 23), 
                               TimeZoneSidKey = 'America/Los_Angeles', 
                               LocaleSidKey = 'en_US', 
                               LanguageLocaleKey = 'en_US', 
                               ProfileId = pf.Id,
                               IndividualId=testIndividual.Id
                              ); 
        
        
        return testUser;
        
    }

    Public static Individual createIndividulaInstance(){
        account testAccount=createaccountInstance();
        Individual testIndividual= new Individual(AccountId__c=testAccount.Id,firstname='test first name',LastName='tets last name');
        return testIndividual;
        
    }
    
     public static Process_Execution_Condition__c createPECinstance(){
        Process_Execution_Condition__c testPEC=new Process_Execution_Condition__c();
        testPEC.Name='test PEC';
        return testPEC;
    }
    
    public static Process_Execution_Condition_Detail__c createPECDinstance(){
        Process_Execution_Condition_Detail__c testPECD=new Process_Execution_Condition_Detail__c();
        testPECD.Name='test PECD';
        return testPECD;
    }
    
    
    
    
    
    /*public static Document_Metadata__c createDocumentmetadata(){
        
        Document_Metadata__c testDocumentMetaData = new Document_Metadata__c();
        testDocumentMetaData.Document_Category__c='Cheque';
        testDocumentMetaData.Document_Id_Name__c='Cheque no.';
        testDocumentMetaData.Document_Name__c='23456';
        return testDocumentMetaData;
    }*/
    
    /*Public static Document_Handler__c createDocumentHandlerInstance(){
        Account accoundInstance= createaccountInstance();
        Document_Metadata__c testDocumentMetaData =createDocumentmetadata(); 
        Paybale__c testMEMO =createMODTInstance();
        Task testTask=CreateTaskInstance();
        
        Document_Handler__c testDocument = new Document_Handler__c();
        testDocument.Status__c='Dispatched';
        testDocument.Transfer_to__c=accoundInstance.id;
        testDocument.Extended_SObject_RecordId__c=testMEMO.id;
        testDocument.Document_Metadata__c=testDocumentMetaData.Id;
        testDocument.Document_Sharing_Task_Ids__c=testTask.id;
        testDocument.Tracking_Number__c='123456';
        return testDocument;
    }*/
    
    /*public static Paybale__c createMODTInstance(){
        Financial_Account__c testFA =CreateFinancialAccountInstance();
		Financial_Entity__c  testFinancialEntity = CreateFinancialEntityInstance();
        Paybale__c testMEMO = new Paybale__c();
        testMEMO.Amount__c=123456;
        //testMEMO.Due_Date__c=system.today();
        testMEMO.IsActive__c=true;	
        testMEMO.Financial_Account__c=testFA.id;
		testMemo.Finacial_Entity_Details__c = testFinancialEntity.Id;
        return testMEMO;
    }*/
    
    Public static Process_Path__c createProcessPAthInstance(){
        Process_Path__c  testPP= new Process_Path__c();
        testPP.Name='1234';
        testPP.isActive__c=true;
        return testPP;
    }
    
    
    public static  Process_Path_Task_Detail__c createPPTD(){
        Process_Path__c  testPP=createProcessPAthInstance();
        Process_Path_Task_Detail__c testPPTD = new Process_Path_Task_Detail__c();
        testPPTD.isActive__c=true;
        testPPTD.Process_Path__c=testPP.id;
        return testPPTD;
    }
    
    Public static Process_Attribute_Review_Detail__c createPARDInstance(){
        Process_Attribute_Review_Detail__c PARD  = new Process_Attribute_Review_Detail__c();
        PARD.Approve_Level_Allowed__c = 'Next Level';
        PARD.Bulk_Approval__c = false;
        PARD.IsActive__c = true;
        PARD.Level__c = 1;
        PARD.Reviewer_Type__c = 'Queue';
        PARD.Reject_Level_Allowed__c = 'Just Previous';
        return PARD;
        
    }
    
    /*Public static user createUserInstance(){
        Individual testIndividual=createIndividulaInstance();
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User testUser=new User(firstname = 'ABC', 
                               lastName = 'XYZ', 
                               email = uniqueName + '@test' + orgId + '.org', 
                               Username = uniqueName + '@test' + orgId + '.org', 
                               EmailEncodingKey = 'ISO-8859-1', 
                               Alias = uniqueName.substring(18, 23), 
                               TimeZoneSidKey = 'America/Los_Angeles', 
                               LocaleSidKey = 'en_US', 
                               LanguageLocaleKey = 'en_US', 
                               ProfileId = pf.Id,
                               IndividualId=testIndividual.Id
                              ); 
        
        
        return testUser;
        
    }*/
    
    /*Public static Individual createIndividulaInstance(){
        account testAccount=createaccountInstance();
        Individual testIndividual= new Individual(AccountId__c=testAccount.Id,firstname='test first name',LastName='tets last name');
        return testIndividual;
        
    }*/
    
    Public static Process_Task_Detail__c createPTDinstance(){
        Process_Task_Detail__c testPTD = new Process_Task_Detail__c();
        testPTD.Subject__c='Escrow Account Opening';
        testPTD.Task_Record_Type__c='Admin';
        return testPTD;
    }
    
    /*Public static contact createContactInstancee(){
        account testAccount=createaccountInstance();
        contact testContact = new contact ();
        testContact.FirstName='Test contact';
        testContact.LastName='Last Name';
        testContact.AccountId=testAccount.id;
        return testContact;
    }*/
    
    /*public static Process_Component__c createPCinstance(){
        Process_Component__c testPC= new Process_Component__c();
        testPC.Name__C='CMP_DocumentUpload';
        testPC.Active__c=True;
        return testPC;
        
    }*/ 
    
    /*public static Process_Execution_Condition__c createPECinstance(){
        Process_Execution_Condition__c testPEC=new Process_Execution_Condition__c();
        testPEC.Name='test PEC';
        return testPEC;
    }*/
    
    
    //CREATING NEW DATA RELATED WITH ALL PROCESSES
    /*public static Process_Attribute__c creatPrpcessAttributeInstance(){
        Process_Attribute__c testPA = new Process_Attribute__c();
        testPA.Close_Previous_Task__c=false;
        testPA.Name='Opp - NuScoreRecalibrationInvoiceCreation';
        testPA.Object_Type__c='Opportunity';
        testPA.Opportunity_Type__c	='Recalibration Invoice Creation';
        testPA.Process_Path__c='a0hBl000000FG7jIAG';
       
        testPA.Sobject_RecordType_Name__c='NU Score Payment Schedule';
        return testPA;
        
    }*/
    
    /*public static Process_Path__c createPPinstance(){
        Process_Path__c testPP=new Process_Path__c();
        testPP.isActive__c=true;
        testPP.Name='Opp - NuScoreRecalibrationInvoiceCreation P0';
        return testPP;
    }*/
    
   /* public static Opportunity createOpportunityinstance(){
        Opportunity testOpp=new Opportunity();
        testOpp.AccountId='001Bl00000Ey2LVIAZ';
        testOpp.All_Stage_Completed__c=false;
        testOpp.Budget_Confirmed__c=false;
        testOpp.CloseDate=date.valueof('2024-03-12');
        //testOpp.Current_Stage_DateTime__c=2024-03-10T18:34:50.000Z;
        testOpp.Customer_Mobile_No__c='5';
        testOpp.Discovery_Completed__c=false;
        testOpp.Name='NU Score Account 5-2024-03-11';
        testOpp.Process_Attribute__c='a00Bl000009SGW5IAO';
        testOpp.ROI_Analysis_Completed__c=false;
        testOpp.StageName='New';
        testOpp.Type='Recalibration Invoice Creation';
        return testOpp;
        
    }*/
    /*Public static Process_Path_Task_Detail__c createPPTDinstance(){
        Process_Path_Task_Detail__c testPPTD=new Process_Path_Task_Detail__c();
        testPPTD.Action_Type__c='Component';
        testPPTD.Action_URL__c='CMP_TaskMaster';
        testPPTD.Business_Step_No__c=1.0;
        testPPTD.Execution_Serial_No__c='1';
        testPPTD.isMergeable__c=false;
        testPPTD.Name='Opp - NuScoreRecalibrationInvoiceCreation P0 T1';
        testPPTD.Partial_Closure_Allowed__c=false;
        testPPTD.Path_No__c='P0';
        testPPTD.Process_Path__c='a0hBl000000FG7jIAG';
        testPPTD.Process_Task_Detail__c='a0iBl000000OAizIAG';
        testPPTD.Subject__c='Start';
        
        testPPTD.Task_Owner_Name__c='N/A';
        testPPTD.Task_Owner_Type__c='System';
        testPPTD.Task_Record_Type__c='Admin';
        return testPPTD;
    }*/
    
    // ===============data used in test class =================

    public static User createStandardUser() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'
        );
        insert testUser;
        return testUser;
    }

    public static Group createBranchOperationsBangaloreGroup() {
        Group testGroup = new Group(Name = 'Branch_Operations_Bangalore', Type = 'Regular');
        insert testGroup;
        return testGroup;
    }

    public static GroupMember createGroupMemberForUser(Id groupId, Id userId) {
        GroupMember testGroupMember = new GroupMember(GroupID = groupId, UserOrGroupId = userId);
        insert testGroupMember;
        return testGroupMember;
    }

    public static Process_Task_Owner_Assignment_Matrix__c createProcessTaskOwnerAssignmentMatrix(Account testAccount) {
        Process_Task_Owner_Assignment_Matrix__c ptow = new Process_Task_Owner_Assignment_Matrix__c(
            Account__c = testAccount.Id,
            Queue_Name__c = 'Branch_Operations_Bangalore'
        );
        insert ptow;
        return ptow;
    }

    public static Document_Handler__c createDocumentHandler(Account testAccount, Paybale__c testMEMO, Document_Metadata__c testDocumentMetaData, Task testTask) {
        Document_Handler__c docHandler = new Document_Handler__c(
            Transfer_to__c = testAccount.Id,
            Status__c = 'To Be Dispatched',
            Transfer_By__c = testAccount.Id,
            Payable__c = testMEMO.Id,
            Document_Metadata__c = testDocumentMetaData.Id,
            Document_Name__c = 'Test Document',
            Extended_SObject_RecordId__c = testAccount.Id,
            Document_Sharing_Task_Ids__c = testTask.Id
        );
        insert docHandler;
        return docHandler;
    }
    
    
    
}