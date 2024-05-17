@isTest
public class CommunicationAPI_Nimbus_Helper_Test {
	
    @isTest(SeeAllData=true)
    public static void CommunicationAPITest(){
        Communication_Template__c ct = new Communication_Template__c();
        ct.Channel_Type__c = 'SMS';
        ct.Is_Active__c = true;
        ct.Nimbus_Template_Id__c = '1000';
        insert ct;
        Process_Attribute__c pa = new Process_Attribute__c();
        pa.name = 'c-call back';
        pa.Object_Type__c = 'Case';
        //pa.Case_Category__c = 'Customer Engagement';
        //pa.Case_Type__c = 'Query';
        //pa.Case_Sub_Category__c = 'Call Back';
        pa.isActive__c = true;
        insert pa;
        
        Process_Attribute_Details__c pad = new Process_Attribute_Details__c();
        pad.Process_Attribute__c = pa.Id;
        pad.Stage_Step__c = 'Communication';
        pad.Task_Subject__c = 'Communication - Email';
        pad.Task_Owner_Type__c = 'queue';
        pad.Task_Owner_Name__c = 'Call Back';
        pad.Delete_No_Of_Attempt__c = '1';
        //pad.Stage_Step__c = '1';
        pad.Task_Subject_Sl_No__c = '1';
        pad.isActive__c = true;
        pad.SLA__c = 1;
        pad.Communication_Template__c = ct.Id;
        pad.Stage_SL_No__c = '1';
        insert pad;
        
        Account acc = new Account();
        acc.Name	= 'Test Account';
        acc.Phone	= '9825157782';
        insert acc;
        
        Task ts = new Task();
        ts.WhatId = acc.Id;
        ts.Subject = 'Callback Test';
        ts.CrtObjectId__c = '123ert';
        ts.Process_Attribute_Details__c = pad.Id;
        ts.Mobile__c = '9825157781';
        insert ts;
        
       
        
        API_Callout_Audit__c aca = new API_Callout_Audit__c();
        //aca.Name = 'Test Name';
        aca.Processed__c = 'Outbound';
        aca.Status__c = 'New';
        aca.Task_ID__c = ts.Id;
        insert aca;
        
        CommunicationAPI_Nimbusv1.FlowInput fi = new CommunicationAPI_Nimbusv1.FlowInput();
        fi.inp_record = aca;
        CommunicationAPI_Nimbusv1.sendNotificationToCustomer(new List<CommunicationAPI_Nimbusv1.FlowInput>{fi});
        
        
        // ====== new JSON file =========== ======================
        
        Action_Form_Details__c AFD = new Action_Form_Details__c();
        AFD.Label_API__c = 'paymentLink1';
        AFD.Mapping_Field_API__c = 'Attribute1__c';
        AFD.Process_Attribute_Details__c = pad.Id;
        insert AFD;
        
        Financial_Account__c FA = new Financial_Account__c();
        FA.Account_Name__c = acc.Id;
        FA.External_ID__c = '454432345543';
        FA.Loan_Category__c = 'MFI';
        insert FA;
        
        case newcase = new Case();
        newcase.Category__c = 'loan Related';
        newcase.Sub_Category__c = 'loan Related';
        newcase.Customer_Mobile_No__c = '9825157782';
        newcase.Customer_Type__c = 'Partner';
        newcase.Cust_ID__c = '67898732678';
        newcase.Customer_Name__c = 'Amarnath';
        newcase.AccountId = acc.Id;
        newcase.Financial_Account__c = FA.Id;
        newcase.Loan_Category__c = 'MFI';
        newcase.Type = 'Query';
        insert newcase;
        
         Task castas = new Task();
        castas.WhatId = newcase.Id;
        castas.Subject = 'Callback Test';
        castas.CrtObjectId__c = '123ert';
        castas.Process_Attribute_Details__c = pad.Id;
        castas.Mobile__c = '9825157781';
        castas.Attribute1__c = 'testlink';
        insert castas;
        
        API_Callout_Audit__c Casaca = new API_Callout_Audit__c();
        //aca.Name = 'Test Name';
        Casaca.Processed__c = 'Outbound';
        Casaca.Status__c = 'New';
        Casaca.Task_ID__c = castas.Id;
        insert Casaca;
        
        CommunicationAPI_Nimbusv1.FlowInput fi1 = new CommunicationAPI_Nimbusv1.FlowInput();
        fi1.inp_record = Casaca;
        CommunicationAPI_Nimbusv1.sendNotificationToCustomer(new List<CommunicationAPI_Nimbusv1.FlowInput>{fi1});
        //CommunicationAPI_Nimbus.sendNotificationToCustomer(new List<Task>{ts});
        
    }
}