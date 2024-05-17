public without sharing class PayableDetailsController{
    @AuraEnabled(cacheable = true)
    public static getAllpicklistvalues getAllFinancialEntityWithDetails(Id Financial_AccountId){
        getAllpicklistvalues prepareValues = new getAllpicklistvalues();
        prepareValues.entityTypesValue = getEntityTypes();
        prepareValues.payAbleStatus = getpayAbleStatus();
        prepareValues.paymentModeTypesValues = getPaymentModeTypes();
        prepareValues.relatedFinancialEntity = getRelatedFinancialEntities(Financial_AccountId);
        prepareValues.EntityACDetailsList = getrelatedEntityACdetails(Financial_AccountId);
        prepareValues.PayablesLIst = getRelatedPayables(Financial_AccountId);
        return prepareValues;
    }
    
    @AuraEnabled(cacheable = true)
    public static getAllpicklistvalues getAllFinancialEntityWithDetailsModt(Id Financial_AccountId){
        getAllpicklistvalues prepareValues = new getAllpicklistvalues();
        prepareValues.entityTypesValue = getEntityTypes();
        prepareValues.payAbleStatus = getpayMODTStatus();
        prepareValues.paymentModeTypesValues = getPaymentModeTypes();
        prepareValues.relatedFinancialEntity = getRelatedFinancialEntities(Financial_AccountId);
        prepareValues.EntityACDetailsList = getrelatedEntityACdetails(Financial_AccountId);
        prepareValues.PayablesLIst = getRelatedPayables(Financial_AccountId);
        prepareValues.modtlist = getRelatedMODTs(Financial_AccountId);
        return prepareValues;
    }
    
    
    Public static List<Financial_Entity__c> AllowedEntityForMemoCreation(Id Financial_AccountId){
        
        List<Financial_Entity__c> ReturnFEntityDetails = new List<Financial_Entity__c>();
        List<Financial_Entity__c> ReturnFEntityDetailsBT = new List<Financial_Entity__c>();
        Boolean FinancialInstitutecheckbox=false;
        List<Financial_Entity__c> FEntityDetails = [SELECT Id, Name, Account_Name__c, Contact__c, Entity_Type__c, Task_ID__c, Financial_Account__c,Financial_Account__r.Loan_Category__c,Financial_Account__r.Id,Financial_Account__r.Name,Financial_Account__r.Amount_Available_For_Disbursement__c,
                                                    Amount_To_Be_Disbursed__c, Amount_Disbursed__c, Account_Name__r.Phone, Account_Name__r.Email_Id__c,Financial_Account__r.Payable_Amount__c, 
                                                    (SELECT Id, name, Bank_Name__c, Branch_Name__c, IFSC_Code__c, Digitally_Verification_Method__c, Task_ID__c, Banking_Account_Name__c, Financial_Entity__c, Bank_Account_Number__c, Verification_Status__c
                                                     FROM Financial_Entity_AC_Details__r
                                                     Where Verification_Status__c = 'Verified' AND Financial_Entity__c != null),CreatedDate
                                                    FROM Financial_Entity__c
                                                    WHERE Financial_Account__c = :Financial_AccountId AND Amount_To_Be_Disbursed__c != 0
                                                    ORDER BY Amount_To_Be_Disbursed__c DESC
                                                    NULLS LAST];
        set<string> l_loanCategory = new set<string> (label.MemoCreation_BT_Eligible_LoanCategories.split(','));
        set<string> l_entitytypeBT	 = new set<string> (label.MemoCreatione_EntityType_BT_Eligible.split(','));
        set<string> l_entitytypeDebt	 = new set<string> (label.MemoCreatione_EntityType_Debt_Eligible.split(','));
        boolean BTpayment = false;
        boolean IsBTCase = false;
        boolean HasBTEntity = false;
        
        for (Financial_Entity__c FE : FEntityDetails){
            if ( FE.Financial_Account__r.Amount_Available_For_Disbursement__c > 0)
            {
                If (l_loanCategory.contains(FE.Financial_Account__r.Loan_Category__c))
                {
                    IsBTCase = true;
                    IF(l_entitytypeBT.contains(FE.Entity_Type__c))
                    {
                        HasBTEntity = true;
                        if (FE.Amount_Disbursed__c < FE.Amount_To_Be_Disbursed__c)
                        {
                            ReturnFEntityDetailsBT.add(FE);
                            BTpayment = true;
                        }
                    }
                    else if (l_entitytypeDebt.contains(FE.Entity_Type__c))
                    {
                        if (FE.Amount_Disbursed__c < FE.Amount_To_Be_Disbursed__c)
                        {
                            ReturnFEntityDetails.add(FE);
                        }
                        
                    }
                    else{
                        
                        ReturnFEntityDetails.add(FE);
                    }
                }
                else if (!l_entitytypeBT.contains(FE.Entity_Type__c))
                {
                    if (l_entitytypeDebt.contains(FE.Entity_Type__c))
                    {
                        if (FE.Amount_Disbursed__c < FE.Amount_To_Be_Disbursed__c)
                        {
                            ReturnFEntityDetails.add(FE);
                        }
                        
                    }
                    else{
                        
                        ReturnFEntityDetails.add(FE);
                    } 
                }
            }
            if (IsBTCase == true && HasBTEntity == false)
            {
                ReturnFEntityDetails.Clear();
            }
            /*if (FE.Amount_To_Be_Disbursed__c == null && ReturnFEntityDetails.size() == 0){
ReturnFEntityDetailsFI.add(FE);
} else{
if (FE.Amount_To_Be_Disbursed__c != null && ((FE.Amount_To_Be_Disbursed__c >= FE.Amount_Disbursed__c) || FE.Amount_Disbursed__c == null)){
ReturnFEntityDetailsFI.add(FE);
}
}
if(FE.Entity_Type__c=='Financial Institute'){
FinancialInstitutecheckbox=true;
}*/
        }
        /*if(ReturnFEntityDetailsFI.size()>0 && FinancialInstitutecheckbox==false){
ReturnFEntityDetailsFI.clear();
} */
        return BTpayment == true ? ReturnFEntityDetailsBT : ReturnFEntityDetails;
    }
    
    private static List<String> getEntityTypes(){
        List<String> entityTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult = Financial_Entity__c.Entity_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistValues){
            entityTypes.add(entry.getLabel());
        }
        return entityTypes;
    }
    
    Public static List<Financial_Entity__c> getFinancialEntittyForNewPayee(Id Financial_AccountId){
        List<Financial_Entity__c> FEntityDetails = [SELECT Id, Name, Account_Name__c, Contact__c, Entity_Type__c, Task_ID__c, Financial_Account__c,Financial_Account__r.Loan_Category__c,Financial_Account__r.Id,Financial_Account__r.Name,
                                                    Amount_To_Be_Disbursed__c, Amount_Disbursed__c, Account_Name__r.Phone, Account_Name__r.Email_Id__c,Financial_Account__r.Payable_Amount__c, 
                                                    (SELECT Id, name, Bank_Name__c, Branch_Name__c, IFSC_Code__c, Digitally_Verification_Method__c, Task_ID__c, Banking_Account_Name__c, Financial_Entity__c, Bank_Account_Number__c, Verification_Status__c
                                                     FROM Financial_Entity_AC_Details__r
                                                    ),CreatedDate
                                                    FROM Financial_Entity__c
                                                    WHERE Financial_Account__c = :Financial_AccountId
                                                    ORDER BY Amount_To_Be_Disbursed__c DESC
                                                    NULLS LAST];
        return FEntityDetails;
    }
    
    private static List<String> getPaymentModeTypes(){
        List<String> paymentModeTypes = new List<String>();
        Schema.DescribeFieldResult modeValue = Paybale__c.Mode__c.getDescribe();
        List<Schema.PicklistEntry> modePickListValue = modeValue.getPicklistValues();
        for (Schema.PicklistEntry entry : modePickListValue){
            paymentModeTypes.add(entry.getLabel());
        }
        return paymentModeTypes;
    }
    
    private static List<String> getpayAbleStatus(){
        List<String> payAbleStatusList = new List<String>();
        Schema.DescribeFieldResult modeValue = Paybale__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> modePickListValue = modeValue.getPicklistValues();
        for (Schema.PicklistEntry entry : modePickListValue){
            payAbleStatusList.add(entry.getLabel());
        }
        return payAbleStatusList;
    }
    
    private static List<String> getpayMODTStatus(){
        List<String> payAbleStatusList = new List<String>();
        Schema.DescribeFieldResult modeValue = MODT_Details__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> modePickListValue = modeValue.getPicklistValues();
        for (Schema.PicklistEntry entry : modePickListValue){
            payAbleStatusList.add(entry.getLabel());
        }
        return payAbleStatusList;
    }
    
    private static List<Financial_Entity__c> getRelatedFinancialEntities(String Financial_AccountId){
        return [SELECT Id, Name, Account_Name__c, Contact__c, Entity_Type__c, Task_ID__c, Financial_Account__c, (SELECT Id, name, Bank_Name__c, Branch_Name__c, IFSC_Code__c, Digitally_Verification_Method__c, Task_ID__c, Bank_Account_Number__c, Financial_Entity__c
                                                                                                                 FROM Financial_Entity_AC_Details__r), CreatedDate
                FROM Financial_Entity__c
                WHERE Financial_Account__c = :Financial_AccountId];
    }
    
    public static List<Paybale__c> getRelatedPayables(String Financial_AccountId){
        return [SELECT Id, Amount__c, Finacial_Entity_Details__c, Financial_Account__c, Financial_Entity_A_C_Details__c, IsActive__c, Mode__c, Status__c, Task_Id__c, Name, Finacial_Entity_Details__r.Entity_Type__c, Financial_Entity_A_C_Details__r.Bank_Account_Number__c, Finacial_Entity_Details__r.Name, CreatedDate, Finacial_Entity_Details__r.Id
                FROM Paybale__c
                WHERE Financial_Account__c = :Financial_AccountId];
    }
    
    private static list<Financial_Entity_AC_Detail__c> getrelatedEntityACdetails(String Financial_AccountId){
        return [SELECT Financial_Entity__r.Id, Financial_Entity__r.Name, Financial_Entity__r.Account_Name__c, Banking_Account_Name__c, Financial_Entity__r.Contact__c, Financial_Entity__r.Entity_Type__c, Financial_Entity__r.Task_ID__c, Financial_Account__c, Financial_Entity__r.Financial_Account__c, Id, Name, Bank_Name__c, Branch_Name__c, Verification_Status__c, IFSC_Code__c, Digitally_Verification_Method__c, Task_ID__c, Bank_Account_Number__c, Financial_Entity__c, CreatedDate
                FROM Financial_Entity_AC_Detail__c
                WHERE Financial_Entity__r.Financial_Account__c = :Financial_AccountId];
    }
    

    private static list<Financial_Entity_AC_Detail__c> getrelatedEntityACdetailsnew(String Financial_AccountId){
        return [SELECT Financial_Entity__r.Id, Financial_Entity__r.Name, Financial_Entity__r.Account_Name__c, Banking_Account_Name__c, Financial_Entity__r.Contact__c, Financial_Entity__r.Entity_Type__c, Financial_Entity__r.Task_ID__c, Financial_Account__c, Financial_Entity__r.Financial_Account__c, Id, Name, Bank_Name__c, Branch_Name__c, Verification_Status__c, IFSC_Code__c,
                Digitally_Verification_Method__c, Task_ID__c, Bank_Account_Number__c, Financial_Entity__c, CreatedDate,Physically_verified__c,Bank_Account_Type__c,Digitally_Verified__c,isChanged__c
                FROM Financial_Entity_AC_Detail__c
                WHERE Financial_Account__c = :Financial_AccountId];
    }
    
    Public Static List<MODT_Details__c> getRelatedMODTs(String FinancialAccountId){
        RETURN [SELECT Id, Date_Of_Execution__c, Financial_Account__c, Mortgager_Name__c, Name, Place__c, Task_Id__c, MODT_ID__c, Mortgager_Name__r.Name, Mortgager_Name__r.Entity_Type__c, CreatedDate, Status__c, Is_Document_Closed__c, Financial_Account__r.Sanctioned_Amount__c, MODT_Value__c
                FROM MODT_Details__c
                WHERE Financial_Account__c = :FinancialAccountId];
    }
    
    public class getAllpicklistvalues{
        @AuraEnabled
        public List<String> entityTypesValue;
        @AuraEnabled
        public List<String> paymentModeTypesValues;
        @AuraEnabled
        public List<String> payAbleStatus;
        @AuraEnabled
        public List<Financial_Entity__c> relatedFinancialEntity;
        @AuraEnabled
        public List<Paybale__c> PayablesLIst;
        @AuraEnabled
        public List<Financial_Entity_AC_Detail__c> EntityACDetailsList;
        @AuraEnabled
        public list<MODT_Details__c> modtlist;
        @AuraEnabled
        public Decimal sanctionedAmount;
    }
    
    @AuraEnabled
    Public static List<Paybale__c> upsertPayableRecord(List<Paybale__c> PayablesLIst){
        system.debug('PayablesLIst' + PayablesLIst);
        try{
            upsert PayablesLIst;
        } catch (Exception e){
            system.debug('Error is' + e.getMessage());
            system.debug('Error at' + e.getLineNumber());
        }
        
        return PayablesLIst;
    }
    
    @AuraEnabled
    Public static string deletePayableRecord(String recordId){
        system.debug('recordId' + recordId);
        try{
            Paybale__c ToBeDeleted = [select Id, Name, CreatedDate
                                      FROM Paybale__c
                                      where id = :recordId];
            delete ToBeDeleted;
        } catch (Exception e){
            system.debug('e---' + e);
        }
        
        return 'success';
    }
    
    @AuraEnabled(cacheable = true)
    Public static verifyDataWrapper getRelatedContactAccount(string financialAccountId){
        verifyDataWrapper recordsEntry = new verifyDataWrapper();
        recordsEntry.entityTypesValue = getEntityTypes();
        recordsEntry.accountTypePicklist = getAccountTypePicklistValue();
        recordsEntry.verificationTypesValue = getDigitallyVerificationMethodTypes();
        recordsEntry.relatedFinancialEntity = getFinancialEntittyForNewPayee(financialAccountId);
        recordsEntry.EntityACDetailsList = getrelatedEntityACdetailsnew(financialAccountId);
        recordsEntry.existingContact = [SELECT id, Name, Accountid
                                        from contact
                                        where IsActive__c = true and accountid = :[
                                            select Account_Name__c
                                            FROM Financial_Account__c
                                            WHERE id = :financialAccountId].Account_Name__c];
        system.debug('--->' + recordsEntry.existingContact);
        return recordsEntry;
    }
    
    @AuraEnabled
    public static getAllpicklistvalues getAllFinancialEntityWithDetailsDups(Id Financial_AccountId){
        
        
        getAllpicklistvalues prepareValues = new getAllpicklistvalues();
        system.debug('Financial_AccountId' + Financial_AccountId);
        prepareValues.sanctionedAmount = [Select Id, Sanctioned_Amount__c
                                          from Financial_Account__c
                                          where id = :Financial_AccountId].Sanctioned_Amount__c;
        
        prepareValues.entityTypesValue = getEntityTypes();
        prepareValues.payAbleStatus = getpayAbleStatus();
        prepareValues.paymentModeTypesValues = getPaymentModeTypes();
        //prepareValues.relatedFinancialEntity = getRelatedFinancialEntities(Financial_AccountId);
        prepareValues.relatedFinancialEntity = AllowedEntityForMemoCreation(Financial_AccountId);
        prepareValues.EntityACDetailsList = getrelatedEntityACdetails(Financial_AccountId);
        prepareValues.PayablesLIst = getRelatedPayables(Financial_AccountId);
        return prepareValues;
    }
    
    @AuraEnabled
    Public static Utility_Wrapperclass.ApexResponse_Wrapper upsertMODTRecords(List<MODT_Details__c> MODTLIst){
        system.debug('MODTLIst' + MODTLIst);
        Utility_Wrapperclass.ApexResponse_Wrapper ARW = new Utility_Wrapperclass.ApexResponse_Wrapper();
        try{
            upsert MODTLIst;
            ARW.ObjectList = MODTLIst;
            ARW.Responsemessage = 'SUCCESS';
            ARW.isSuccess = true;
        } catch (Exception e){
            system.debug('e---' + e);
            ARW.ObjectList = null;
            ARW.Responsemessage = e.getMessage();
            ARW.isSuccess = false;
        }
        return ARW;
    }
    
    @AuraEnabled
    Public static string deleteMODTRecord(String recordId){
        system.debug('recordId' + recordId);
        try{
            MODT_Details__c ToBeDeleted = [select Id, Name, CreatedDate
                                           FROM MODT_Details__c
                                           where id = :recordId];
            delete ToBeDeleted;
        } catch (Exception e){
            system.debug('e---' + e);
        }
        
        return 'success';
    }
    
    @AuraEnabled
    Public static string updateMODT(String MODTId, boolean closeddoc, String status){
        system.debug('MODTRec' + MODTId);
        system.debug('closeddoc' + closeddoc);
        String message;
        try{
            if (MODTId != null){
                MODT_Details__c MODTRec = new MODT_Details__c();
                MODTRec.Id = MODTId;
                MODTRec.Is_Document_Closed__c = closeddoc;
                MODTRec.Status__c = status;
                update MODTRec;
            }
            message = 'success';
        } catch (Exception e){
            system.debug('e---' + e);
            message = e.getMessage();
        }
        return message;
    }
    
    @AuraEnabled(cacheable = true)
    public static getAllpicklistvalues fetchDataFromWire(Id Financial_AccountId){
        getAllpicklistvalues prepareValues = new getAllpicklistvalues();
        system.debug('Financial_AccountId' + Financial_AccountId);
        prepareValues.sanctionedAmount = [Select Id, Sanctioned_Amount__c
                                          from Financial_Account__c
                                          where id = :Financial_AccountId].Sanctioned_Amount__c;
        prepareValues.entityTypesValue = getEntityTypes();
        prepareValues.payAbleStatus = getpayAbleStatus();
        prepareValues.paymentModeTypesValues = getPaymentModeTypes();
        prepareValues.relatedFinancialEntity = getRelatedFinancialEntities(Financial_AccountId);
        prepareValues.EntityACDetailsList = getrelatedEntityACdetails(Financial_AccountId);
        prepareValues.PayablesLIst = getRelatedPayables(Financial_AccountId);
        return prepareValues;
    }
    
    private static List<String> getDigitallyVerificationMethodTypes(){
        List<String> entityTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult = Financial_Entity_AC_Detail__c.Digitally_Verification_Method__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistValues){
            entityTypes.add(entry.getLabel());
        }
        return entityTypes;
    }
    
    private static List<String> getAccountTypePicklistValue(){
        List<String> entityTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult = Financial_Entity_AC_Detail__c.Bank_Account_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistValues){
            entityTypes.add(entry.getLabel());
        }
        return entityTypes;
    }
    
    @AuraEnabled
    public static verifyDataWrapper verifyExistingRecord(String emailORphone){
        verifyDataWrapper recordsEntry = new verifyDataWrapper();
        String sanitizedEmail = String.escapeSingleQuotes(emailORphone);
        List<Account> existingAccounts = [SELECT Id, Email_Id__c, Phone, Name
                                          FROM Account
                                          WHERE Email_Id__c = :sanitizedEmail OR Phone = :sanitizedEmail
                                          LIMIT 100];
        if (existingAccounts.size() > 0){
            recordsEntry.existingAccount = existingAccounts;
            list<Financial_Entity__c> relatedFinancialEntity = [SELECT Id, Name, Account_Name__c, Contact__c, Entity_Type__c, Task_ID__c, Financial_Account__c, (SELECT Id, name, Bank_Name__c, Branch_Name__c, IFSC_Code__c, Digitally_Verification_Method__c, Task_ID__c, Bank_Account_Number__c, Financial_Entity__c
                                                                                                                                                                 FROM Financial_Entity_AC_Details__r), CreatedDate
                                                                FROM Financial_Entity__c
                                                                WHERE Account_Name__c IN:existingAccounts];
            if (relatedFinancialEntity.size() > 0){
                recordsEntry.relatedFinancialEntity = relatedFinancialEntity;
            }
            
        }
        List<Contact> existingContacts = [SELECT Id, FirstName, LastName
                                          FROM Contact
                                          WHERE Email = :sanitizedEmail OR Phone = :sanitizedEmail
                                          LIMIT 100];
        if (existingContacts.size() > 0){
            recordsEntry.existingContact = existingContacts;
            list<Financial_Entity__c> relatedFinancialEntity = [SELECT Id, Name, Account_Name__c, Contact__c, Entity_Type__c, Task_ID__c, Financial_Account__c, (SELECT Id, name, Bank_Name__c, Branch_Name__c, IFSC_Code__c, Digitally_Verification_Method__c, Task_ID__c, Bank_Account_Number__c, Financial_Entity__c
                                                                                                                                                                 FROM Financial_Entity_AC_Details__r), CreatedDate
                                                                FROM Financial_Entity__c
                                                                WHERE Contact__c IN:existingContacts];
            if (relatedFinancialEntity.size() > 0){
                recordsEntry.relatedFinancialEntity = relatedFinancialEntity;
            }
        }
        return recordsEntry;
    }
    
    @auraEnabled
    public static string uppesertSobject(List<Financial_Entity_AC_Detail__c> listTobeUppsert){
        System.debug('listTobeUppsert--->' + listTobeUppsert);
        try{
            upsert listTobeUppsert;
            return 'Success';
        } catch (Exception e){
            System.debug('Error at line number: ' + e.getLineNumber());
            System.debug('Error message: ' + e.getMessage());
            return e.getMessage();
        }
    }
    
    public class verifyDataWrapper{
        @auraEnabled
        public list<account> existingAccount;
        @auraEnabled
        public list<contact> existingContact;
        @AuraEnabled
        public List<String> entityTypesValue;
        @AuraEnabled
        public List<String> verificationTypesValue;
        @AuraEnabled
        public list<Financial_Entity__c> relatedFinancialEntity;
        @AuraEnabled
        public List<Financial_Entity_AC_Detail__c> EntityACDetailsList;
        @AuraEnabled
        public List<String> accountTypePicklist;
        
    }
    
    @auraEnabled
    public static void createAccountContactDetailsOnBehalofPayeeNumber(List<AccountCOntactPayeewrapper> wrapperData){
        system.debug('wrapperData---->' + wrapperData);
        
        List<Financial_Entity__c> financialEntitiesToInsert = new List<Financial_Entity__c>();
        for (AccountCOntactPayeewrapper wrap : wrapperData){
            Account newAccount;
            Contact newContact;
            Financial_Entity__c financialEntity = wrap.relatedFinancialEntity;
            if(financialEntity.Account_Name__c !=null||financialEntity.Account_Name__c !='' || !String.isBlank(financialEntity.Account_Name__c)||!String.isEmpty(financialEntity.Account_Name__c)){
                newAccount = getOrUpdateExistingAccountRecord(financialEntity.Account_Name__c);
                if(newAccount.Id !=NULL){
                    newContact=getOrUpdateExistingContactRecord(newAccount.Id);
                    system.debug('financialEntity.Account_Name__c---'+financialEntity.Account_Name__c);
                    system.debug('wrap.index---'+wrap.index);
                    newAccount.Name=wrap.Name;
                    newAccount.Email_Id__c=wrap.payeeEmail;
                    newAccount.Phone= wrap.payeePhone;
                    update newAccount;
                    financialEntity.Contact__c =newContact.id;
                }else{
                    
                    newAccount = createAccount(wrap.Name, wrap.payeeEmail, wrap.payeePhone);
                }
                
            }else if(financialEntity.Account_Name__c ==null||financialEntity.Account_Name__c !=''){
                newAccount = createAccount(wrap.Name, wrap.payeeEmail, wrap.payeePhone);
            }
            financialEntitiesToInsert.add(financialEntity);
            try{
                financialEntity.Account_Name__c = newAccount.Id;
                newContact=getOrUpdateExistingContactRecord(newAccount.Id);
                financialEntity.Contact__c =newContact.id;
            } catch (Exception e){
                System.debug('Error creating account: ' + e.getMessage());
                // Roll back the Financial_Entity__c creation
                financialEntitiesToInsert.remove(financialEntitiesToInsert.size() - 1);
            }
        }
        upsert financialEntitiesToInsert;
    }
    
    public static Account createAccount(String name, String email, String phone){
        verifyDataWrapper recordsEntry = new verifyDataWrapper();
        try{
            
            system.debug('recordsEntry-------->'+recordsEntry);
            Account newAcc = new Account();
            newAcc.Name = name;
            newAcc.Email_Id__c = email;
            newAcc.Phone = phone;
            newAcc.Product_Bussiness_Line__c = 'LAP';
            insert newAcc;
            createContact(name, email, phone, newAcc);
            return newAcc;
            
        } catch (Exception e){
            System.debug('Error at line number: ' + e.getLineNumber());
            System.debug('Error message: ' + e.getMessage());
            return null;
        }
    }
    
    public static contact createContact(String name, String email, String phone, account pAccount){
        try{
            contact newCon = new contact();
            newCon.lastName = name;
            newCon.Email = email;
            newCon.Phone = phone;
            newCon.AccountId = pAccount.id;
            insert newCon;
            return newCon;
            
        } catch (Exception e){
            System.debug('Error at line number: ' + e.getLineNumber());
            System.debug('Error message: ' + e.getMessage());
            return null;
        }
    }
    
    public static account getOrUpdateExistingAccountRecord(string accountId){
        system.debug('accountId---'+accountId);
        Account newAccount;
        try{
            newAccount=[select id,Name,Email_Id__c,Phone FROM Account where id=:accountId limit 1];
        }catch(Exception e){
            newAccount = new account();
            newAccount.addError('No record found with Id: ' + accountId);
        }
        return newAccount;
    }
    
    public static contact getOrUpdateExistingContactRecord(string accountId){
        system.debug('accountId---'+accountId);
        Contact newCon;
        try{
            newCon=[select id,Name,Email,Phone FROM Contact where accountId=:accountId limit 1];
        }catch(Exception e){
            newCon= new contact();
            newCon.addError('No record found with Id: ' + accountId);
        }
        return newCon;
    }
    
    public class AccountCOntactPayeewrapper{
        @auraEnabled
        public String payeeEmail{ get; set; }
        
        @auraEnabled
        public String payeePhone{ get; set; }
        
        @auraEnabled
        public Integer index{ get; set; }
        
        @auraEnabled
        public String name{ get; set; }
        
        @auraEnabled
        public Financial_Entity__c relatedFinancialEntity{ get; set; }
        
        public AccountCOntactPayeewrapper(){
            // No-argument constructor
        }
        
        public AccountCOntactPayeewrapper(String payeeEmail, String payeePhone, Integer index, String name, Financial_Entity__c relatedFinancialEntity){
            this.payeeEmail = payeeEmail;
            this.payeePhone = payeePhone;
            this.index = index;
            this.name = name;
            this.relatedFinancialEntity = relatedFinancialEntity;
        }
        
    }
    
    public class NoTaskDetailFoundException extends Exception{
    }
    
    @auraEnabled
    public static Id createTask(String subject, String backDetailsRecordId, string parentTaskId){
        
        try{
            task parentTask = [SELECT id, Process_Path_Task_Detail__c, Parent_Task_Id__c, Process_Attribute_Object_Type__c, Process_Attribute__c, WhatId, whoId
                               FROM task
                               where id = :parentTaskId
                               limit 1];
            Process_Path_Task_Detail__c pptaskDtails = [select id, subject__c
                                                        from Process_Path_Task_Detail__c
                                                        where process_task_detail__r.subject__c = :subject AND Manual_API_Call_Out__c = true AND isActive__c = true
                                                        order by createdDate ASC
                                                        limit 1];
            Task newTask = new Task();
            newTask.Attribute1__c = backDetailsRecordId;
            newTask.Status = 'Open';
            newTask.Subject = pptaskDtails.subject__c;
            // Only proceed if there is exactly one record found
            if (parentTask != null){
                newTask.Process_Path_Task_Detail__c = pptaskDtails.id;
                //newTask.Process_Attribute_Object_Type__c = parentTask.Process_Attribute_Object_Type__c;
                newTask.Process_Attribute__c = parentTask.Process_Attribute__c;
                newTask.Parent_Task_Id__c = parentTask.id;
                newTask.WhatId = parentTask.WhatId;
                newTask.whoId = parentTask.whoId;
            } else{
                // Handle the case where no matching record is found
                throw new NoTaskDetailFoundException('No parentTask found for --->: ' + parentTaskId);
            }
            
            insert newTask;
            return newTask.Id;
        } catch (NoTaskDetailFoundException e){
            // Handle the custom exception
            System.debug('Custom Exception occurred: ' + e.getMessage());
            System.debug('Custom Exception occurred at line Number: ' + e.getlineNumber());
            // You can choose to throw the exception further or return null
            return null;
        }
    }
    
    
    //For Dependent Picklistvalues
    @AuraEnabled
    public static Map<Object, List<String>> getDependentPicklistValues(String SFobject, String fieldApiName){
        
        System.debug('SFobject ===> ' + SFobject);
        System.debug('fieldApiName ===> ' + fieldApiName);
        
        SObjectField dependentField = Schema.getGlobalDescribe().get(SFobject).getDescribe().fields.getMap().get(fieldApiName);
        Map<Object, List<String>> dependentPicklistValues = new Map<Object, List<String>>();
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        System.debug('dependentFieldResult ===> ' + dependentFieldResult);
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        System.debug('controllerField ===> ' + controllerField);
        if (controllerField == null){
            return null;
        }
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
        System.debug('controllerValues ===> ' + controllerValues);
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            System.debug('entry ===> ' + entry);
            if (entry.isActive()){
                List<String> base64chars = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                System.debug('base64chars ===> ' + base64chars);
                System.debug('controllerValues ===> ' + controllerValues);
                //if (controllerValues.size() >0 && base64chars.size() >0) {
                for (Integer i = 0; i < controllerValues.size(); i++){
                    if (base64chars.size() > 0){
                        Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                        Integer bitIndex = i / 6;
                        Integer bitShift = 5 - Math.mod(i, 6);
                        if (controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                            continue;
                        }
                        if (!dependentPicklistValues.containsKey(controllerValue)){
                            dependentPicklistValues.put(controllerValue, new List<String>());
                        }
                        dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                    }
                    else {
                        dependentPicklistValues.put(controllerValues[i], new List<String>());
                    }
                    
                }
                // }
                // else {
                //     dependentPicklistValues.put(controllerValues, new List<String>());
                
                // }
                
            }
        }
        system.debug('dependentPicklistValues ---' + dependentPicklistValues);
        return dependentPicklistValues;
    }
    
}