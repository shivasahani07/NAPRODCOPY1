public class BulkMEMOExecutionSubmittion {
    public static API_Callout_Audit__c auditRec = new API_Callout_Audit__c();
    public static AuditResponseWrapperClass ExecutionProcess(Id taskId){
        Task taskDetail = [SELECT Id,Attribute1__c,Attribute2__c From Task Where Id =: taskId];
        List<String> payableIds = new List<String>();
        if(taskDetail.Attribute2__c != null){
            payableIds = taskDetail.Attribute2__c.split(',');
        }else{
            payableIds = null; 
        }
        return ExecutionProcessHandler(taskId,payableIds,taskDetail.Attribute1__c);
    }
    
    public static AuditResponseWrapperClass ExecutionProcessHandler(Id taskId,List<String> inp_list_payableids,String inp_mode){
        AuditResponseWrapperClass auditResponse = new AuditResponseWrapperClass();
        auditResponse.auditRec = new API_Callout_Audit__c();
        String auditResult = Label.AuditAPIFailedStatus;
        String debitAccountNo = '\''+System.Label.MEMODebitAccountNO;
        List<Paybale__c> payableList = new List<Paybale__c>();
        List<Document_Handler__c> docHandlerList 	= new List<Document_Handler__c>();
        List<Document_Handler__c> docHanlderTobeUpdate = new List<Document_Handler__c>();
        List<IDFC_Payout_Metadata__mdt> payoutMetaDataList = new List<IDFC_Payout_Metadata__mdt>();
        Map<String,IDFC_Payout_Metadata__mdt> mapOfCompareValueByResultValue = new Map<String,IDFC_Payout_Metadata__mdt>();
        String memoCreated = Constants.PAYABLE_STATUS_MEMO_CREATED;
        try{
            String query = 'SELECT Id, Value_Date__c, Amount__C, Financial_Entity_A_C_Details__c, ' +
                'Financial_Entity_A_C_Details__r.Bank_Account_Number__c, Financial_Account__r.Name,Financial_Entity_A_C_Details__r.Name, ' +
                'Payable_File_Name__c, Financial_Entity_A_C_Details__r.Banking_Account_Name__c, Financial_Entity_A_C_Details__r.Bank_Name__c,' +
                'Financial_Entity_A_C_Details__r.IFSC_Code__c, Mode__c, Task_Id__c, ' +
                'Financial_Entity_A_C_Details__r.Bank_Account_Type__c, Financial_Account__r.Originating_Branch__r.Name ' +
                'FROM Paybale__c ' +
                'WHERE Status__c =: memoCreated AND Execution_Request_Processed__c = true AND Execution_Request_Document_Handler__c = null AND Mode__c = :inp_mode';
            
            
            if (inp_list_payableids != null && !inp_list_payableids.isEmpty()) {
                query += ' AND Id IN :inp_list_payableids';
            }
            
            payableList = Database.query(query);
            system.debug('payableList::'+payableList);
            if(!payableList.isEmpty()){
                String csvContent = 'Client Code,Debit Account No,Transaction Type Code,Value Date,Amount,Beneficary Name,Beneficary Accunt no.,IFSC code,Customer Ref no.,Beneficary email id,Beneficary mobile no.,Remarks,Payment Type,Purpose code,Bene a/c type,Payable Location,Print Branch Name,Mode of delivery,Transaction currency,BENE_ADD1,BENE_ADD2,BENE_ADD3,BENE_ADD4,Beneficiary ID,Remote Printing,Print Branch Location,Nature Of Payment\n'; // Replace with actual field names
                
                for (Paybale__c payRec : payableList) {
                    system.debug('payRec::'+payRec);
                    if(payRec.Value_Date__c == null){
                        payRec.Value_Date__c = system.today();
                    }
                    if(payRec.Financial_Entity_A_C_Details__r.IFSC_Code__c == null){
                        payRec.Financial_Entity_A_C_Details__r.IFSC_Code__c = '';
                    }
                    if(payRec.Financial_Entity_A_C_Details__r.Banking_Account_Name__c == null){
                        payRec.Financial_Entity_A_C_Details__r.Banking_Account_Name__c = '';
                    }
                    String clientCode = 'NACLCH';
                    String transactionTypeCode = 'CC';
                    String paymentType = '';
                    String purposeCode = '';
                    String accountType = '';
                    String deliveryMode = 'BP'; 
                    String transactionType = 'INR';
                    if(!mapOfCompareValueByResultValue.isEMpty()){
                        if(mapOfCompareValueByResultValue.containsKey('NACL') && payRec.Mode__c != 'Cheque'){
                            clientCode = mapOfCompareValueByResultValue.get('NACL').Matching_Type__c;
                        }
                    } 
                    if(payRec.Mode__c != 'Cheque' && payRec.Financial_Entity_A_C_Details__r.Bank_Name__c.contains('IDFC')){
                        transactionTypeCode = 'BT';
                    }else if(payRec.Mode__c != 'Cheque'&& !payRec.Financial_Entity_A_C_Details__r.Bank_Name__c.contains('IDFC')){
                        transactionTypeCode = 'LBT';
                    }else if(payRec.Mode__c != 'Cheque'){
                        transactionTypeCode = 'CC';
                    }
                    system.debug('payRec.Mode__c::'+payRec.Mode__c);
                    if(payRec.Mode__c != 'Cheque' && (payRec.Mode__c == 'RTGS' || payRec.Mode__c == 'NEFT')){
                        
                        
                        if(payRec.Amount__c <= 200000){
                            paymentType = 'NEFT';
                            purposeCode = 'OTH';
                        }else if(payRec.Amount__c > 200000){
                            paymentType = 'RTGS';
                            purposeCode = 'CMS';
                        }
                    }
                    if(payRec.Financial_Entity_A_C_Details__r.Bank_Name__c.contains('IDFC')){
                        paymentType = '';
                        purposeCode = '';
                    }
                    
                    csvContent += '"' + String.valueOf(clientCode).escapeCsv() + '","' +//Client Code
                        String.valueOf(debitAccountNo).escapeCsv() + '","' +//Debit Account No
                        String.valueOf(transactionTypeCode).escapeCsv() + '","' +//Transaction Type Code
                        String.valueOf(payRec.Value_Date__c).escapeCsv() + '","' +//Value Date
                        String.ValueOf(payRec.Amount__c).escapeCsv() + '","' +//Amount
                        payRec.Financial_Entity_A_C_Details__r.Banking_Account_Name__c.escapeCsv() + '","';//Ben Name
                    system.debug('CSV1111:::'+csvContent);
                    if((payRec.Mode__c == 'RTGS' || payRec.Mode__c == 'NEFT')){
                        csvContent += '\''+String.valueOf(payRec.Financial_Entity_A_C_Details__r.Bank_Account_Number__c).escapeCsv() + '","' ;//Ben Account No
                        //payRec.Financial_Entity_A_C_Details__r.IFSC_Code__c.escapeCsv() + '","';//IFSC Code
                    }else{
                        csvContent += + '","' ;
                    }
                    
                    if((payRec.Mode__c == 'RTGS' || payRec.Mode__c == 'NEFT') && !payRec.Financial_Entity_A_C_Details__r.Bank_Name__c.contains('IDFC')){
                        csvContent +=payRec.Financial_Entity_A_C_Details__r.IFSC_Code__c.escapeCsv() + '","';//IFSC Code
                    }else{
                        csvContent += + '","';//IFSC Code
                    }
                    csvContent += String.valueOf(payRec.Payable_File_Name__c).escapeCsv() + '","' +//Customer ref No
                        + '","' +  // Beneficary Email Id
                        + '","' + // beneficary Mobile No.
                        + '","' ; // Remarks
                    if(payRec.Mode__c == 'RTGS' || payRec.Mode__c == 'NEFT'){
                        csvContent += String.valueOf(paymentType.escapeCsv())  + '","' +//payment type
                            String.valueOf(purposeCode).escapeCsv()  + '","' ;//Purpose Code
                    }else{
                        csvContent += + '","' +
                            + '","' ;  
                    }
                    csvContent += '","' + // Beneficary Account Type
                        + '","' + // Payable Location
                        + '","' + // Print Branch Name
                        + '","' ;//Mode of delivery
                    if(payRec.Mode__c == 'RTGS' || payRec.Mode__c == 'NEFT'){
                        csvContent += String.valueOf(transactionType).escapeCsv()  + '","' ;//Transaction Currency
                    }else{
                        csvContent += + '","' ;//Transaction Currency
                    }
                    
                    if(payRec.Mode__c == 'Cheque'){
                        csvContent +=  'Northern Arc Capital'.escapeCsv()  + '","' +//,
                            String.valueOf(payRec.Financial_Account__r.Originating_Branch__r.Name).escapeCsv()  + '","' + 
                            + '","' +
                            '\''+String.valueOf(payRec.Financial_Account__r.Name).escapeCsv()  + '","' +
                            + '","' +
                            'Y'.escapeCsv()  + '","' +
                            + '","' +
                            + '","' +
                            + '","' +  '"\n';
                        
                    }else{
                        csvContent +=  + '","' + // BENE_ADD1
                            + '","' + //BENE_ADD2
                            + '","' + //BENE_ADD3
                            + '","' + //BENE_ADD4
                            + '","' +
                            + '","' +
                            + '","' +
                            + '","' +
                            + '","' +  '"\n';
                    }
                }
                
                Document_Handler__c docHandler = new Document_Handler__c();
                Document_Metadata__c docMetaRec = [select id,Document_Name__c from Document_Metadata__c where Document_Name__c='MEMO Submitted For Request' limit 1];
                docHandler.Task_Id__c = taskId;
                docHandler.Status__c = Constants.DOC_HANDLER_SUBMITTED_FOR_EXECUTION;
                docHandler.Document_Metadata__c = docMetaRec.Id;
                insert docHandler;
                system.debug('docHandler::'+docHandler);
                ContentVersion file = new ContentVersion(
                    title = 'PayableAccount.csv'+taskId,
                    versionData = Blob.valueOf( csvContent ),
                    pathOnClient = '/PayableAccounts.csv',
                    FirstPublishLocationId = docHandler.Id
                );
                insert file;
                system.debug('file::'+file);
                
                auditResponse = EmailService.ExecuteEmailServices(taskId,docHandler.Id);
                if(auditResponse.auditRec.API_Status__c != 'Failed'){
                    for(Paybale__c payRec : payableList){
                        payRec.Execution_Request_Document_Handler__c = docHandler.Id;
                        payRec.Status__c = Constants.PAYABLE_SUBMITTED_FOR_EXECUTION; 
                    }
                    update payableList;
                }
                
                
            }
        }catch(Exception e){
            system.debug('Exception::'+e.getMessage());
            auditResponse.auditRec.API_Status__c = Label.AuditAPIFailedStatus;
            auditResponse.auditRec.Response__c = e.getMessage();
        }
        
        return auditResponse;
    }
}