public without sharing class FileAttchmentRead {
    
    @AuraEnabled
    Public Static String ReadFile(String Base64){
        Document_Metadata__c docMetaRec = [select id,Document_Name__c from Document_Metadata__c where Document_Name__c='MEMO Executed' limit 1];
        List<Task> taskListTobeUpdate = new List<Task>();
        try{
            ContentVersion file = new ContentVersion();
            List<ContentVersion> fileTobeInsertList = new List<ContentVersion>();
            Blob csvBlob = EncodingUtil.base64Decode(Base64);
            String csvString = csvBlob.toString();
            List<String> rows = csvString.split('\n');
            
            integer sampleCounter = rows.Size();
            List<Paybale__c> payableListTobeUpdate = new List<Paybale__c>();
            Set<String> newPayblesFilesId=new  Set<String>();
            map<string,Paybale__c> payablesIdByfilesnames=new map<string,Paybale__c>(); 
            Set<Id> existingPayableIds = new Set<Id>();
            Set<Id> extendedIdSet = new Set<Id>();
            List<Id> currentTaskIdSet = new List<Id>();
            for(integer i=0;i<rows.Size();i++){
                integer v_commacount = rows[i].countmatches('"')/2;
                for (integer lv_commacounter =0;lv_commacounter<v_commacount;lv_commacounter++)
                {
                    List<String> res = rows[i].split('"', 3);
                    res[1] =  res[1].replaceAll(',','');
                    rows[i] =  string.join(res,''); 
                }
                List<String> csvColumns = rows[i].split(',');
                if(!csvColumns.isEmpty()){
                    
                    for(integer j=0;j<csvColumns.size();j++){
                        system.debug('csvColumns[j]::'+csvColumns[j]);
                        
                        if(csvColumns[j] == 'Value Date'){
                            for(integer k=i+1;k<sampleCounter;k++){
                                system.debug('Value Date::'+rows[k].split(',')[j]);
                            }
                        }
                        if(csvColumns[j] == 'Amount'){
                            for(integer k=i+1;k<sampleCounter;k++){
                                integer v_commacount1 = rows[k].countmatches('"')/2;
                                system.debug('v_commacount::'+v_commacount1);
                                for (integer lv_commacounter =0;lv_commacounter<v_commacount1;lv_commacounter++)
                                {
                                    List<String> res = rows[k].split('"', 3);
                                    res[1] =  res[1].replaceAll(',','');
                                    rows[k] =  string.join(res,''); 
                                }
                            }
                        }
                        if(csvColumns[j] == 'Customer Reference Number'){
                            system.debug('inside customer reference numver::');
                            system.debug('sampleCounter::'+sampleCounter);
                            for(integer k=i+1;k<sampleCounter;k++){
                                Paybale__c payableRec = new Paybale__c();
                                payableRec.Name = rows[k].split(',')[j];
                                newPayblesFilesId.add(rows[k].split(',')[j]);
                                system.debug('newPayblesFilesId--->'+newPayblesFilesId);
                                //extendedIdSet.add(payableRec.Id);
                                system.debug('extendedIdSet::'+extendedIdSet);
                                payableListTobeUpdate.add(payableRec);
                            }
                        }
                        
                        if(csvColumns[j] == 'RBI/UTR Reference Number'){
                            system.debug('Inside RBI UTR');
                            integer tempCount = 0;
                            for(integer k=i+1;k<sampleCounter;k++){
                                for(integer d=0;d<payableListTobeUpdate.size();d++){
                                    if(tempCount == d){
                                        payableListTobeUpdate[d].RBI_UTR_Reference_Number__c =  rows[k].split(',')[j];
                                    }
                                }
                                ++tempCount;
                            }
                        }
                        if(csvColumns[j] == 'Instrument Number'){
                            system.debug('Inside RBI UTR');
                            integer tempCount = 0;
                            for(integer k=i+1;k<sampleCounter;k++){
                                
                                for(integer d=0;d<payableListTobeUpdate.size();d++){
                                    if(tempCount == d){
                                        payableListTobeUpdate[d].Instrument_Number__c =  String.ValueOf(rows[k].split(',')[j]);
                                    }
                                }
                                ++tempCount;
                            }
                        }
                        if(csvColumns[j] == 'STATUS'){
                            system.debug('Inside STATUS');
                            integer tempCount = 0;
                            for(integer k=i+1;k<sampleCounter;k++){
                                
                                for(integer d=0;d<payableListTobeUpdate.size();d++){
                                    if(tempCount == d){
                                        if(rows[k].split(',')[j] == 'Successful' || rows[k].split(',')[j] == 'Accepted By Bank'){
                                            payableListTobeUpdate[d].Status__c = 'Accepted By Bank';
                                        }else{
                                            payableListTobeUpdate[d].Status__c =  rows[k].split(',')[j];
                                        }
                                        
                                    }
                                }
                                ++tempCount;
                            }
                        }
                    }
                }
            }
            System.debug('newPayblesFilesId ===> ' + newPayblesFilesId);
            List<Paybale__c> existingPayableList = [SELECT Id, Name,CreatedById, Task_Id__c, Instrument_Number__c, 
                                                    Payable_File_Name__c 
                                                    FROM Paybale__c 
                                                    WHERE Payable_File_Name__c IN :newPayblesFilesId];
            system.debug('existingPayableList::'+existingPayableList.size());
            if(!existingPayableList.Isempty()){
                for (Paybale__c pay : existingPayableList) {
                    payablesIdByfilesnames.put(pay.Payable_File_Name__c, pay);
                    system.debug('payablesIdByfilesnames::'+payablesIdByfilesnames);
                }
            }
            
            
            if (!payableListTobeUpdate.isEmpty()) {
                
                for (Paybale__c pay : payableListTobeUpdate) {
                    system.debug('pay.Name::'+pay.Name);
                    system.debug('payablesIdByfilesnames.get(pay.Name)::'+payablesIdByfilesnames.get(pay.Name));
                    if(payablesIdByfilesnames.get(pay.Name)!=null && payablesIdByfilesnames.get(pay.Name).Id!=null){
                        pay.Id = payablesIdByfilesnames.get(pay.Name).Id;
                        extendedIdSet.add(pay.Id);
                        pay.Name=payablesIdByfilesnames.get(pay.Name).Name;
                    }
                }
                
                // Debugging the list of Paybale__c records to be updated
                System.debug('payableListTobeUpdate::' + payableListTobeUpdate);
                System.debug('payableListTobeUpdate.size()::' + payableListTobeUpdate.size());
                // Update the list of Paybale__c records
                update payableListTobeUpdate;  
            }
            
            system.debug('extendedIdSet::'+extendedIdSet);
            if(!extendedIdSet.isEmpty()){
                List<Paybale__c> payableRecList = new List<Paybale__c>();
                Map<ID,Paybale__c> mapOfRecIdByPayRec = new Map<Id,Paybale__c>();
                Map<Id,Id> mapOfRequestParentIdByChildId = new Map<ID,Id>();
                Map<Id,Id> mapOfExecutedParentIdByChildId = new Map<ID,Id>();
                Set<Id> requestIDSet = new Set<ID>();
                payableRecList = [SELECT Id,CreatedbyId,Task_Id__c,Instrument_Number__c FROM Paybale__c WHERE ID in: extendedIdSet];
                
                if(!payableRecList.isEmpty()){
                    Set<ID> memoTaskIdSet = new Set<ID>();
                    
                    for(Paybale__c payRec : payableRecList){
                        mapOfRecIdByPayRec.put(payRec.Id,payRec);
                        memoTaskIdSet.add(payRec.Task_Id__c);
                    }
                    
                    if(!memoTaskIdSet.isEmpty()){
                        List<Task> requestTaskList = [SELECT ID,Execution_Depended_on_Task_Ids__c,Parent_Task_Id__c FROM Task Where
                                                      Parent_Task_Id__c in: memoTaskIdSet and status='Completed'];
                        for(Task ts : requestTaskList){
                            mapOfRequestParentIdByChildId.put(ts.Parent_Task_Id__c,ts.ID);
                            requestIDSet.add(ts.Id);
                        }
                        system.debug('requestTaskList'+requestTaskList);
                    }
                    
                    if(!requestIDSet.isEmpty()){
                        List<Task> ExecutedTaskList = [SELECT ID,Execution_Depended_on_Task_Ids__c,Parent_Task_Id__c FROM Task Where
                                                       Parent_Task_Id__c in: requestIDSet and status='Open'];
                        for(Task ts : ExecutedTaskList){
                            mapOfExecutedParentIdByChildId.put(ts.Parent_Task_Id__c,ts.ID);
                        }
                    }
                    
                    system.debug('mapOfExecutedParentIdByChildId::'+mapOfExecutedParentIdByChildId);
                    system.debug('memoTaskIdSet::'+memoTaskIdSet);
                    system.debug('requestIDSet::'+requestIDSet);
                    
                    if(!memoTaskIdSet.isEmpty()){
                        String executedTaskId = '';
                        
                        List<Document_Handler__c> docHandlerTobeInsert = new List<Document_Handler__c>();
                        For(ID taskId : memoTaskIdSet){
                            Task ts = new Task();
                            ts.Id = mapOfExecutedParentIdByChildId.get(mapOfRequestParentIdByChildId.get(taskId));
                            if(executedTaskId == ''){
                                executedTaskId = mapOfExecutedParentIdByChildId.get(mapOfRequestParentIdByChildId.get(taskId));
                            }else{
                                executedTaskId = executedTaskId + ',' + mapOfExecutedParentIdByChildId.get(mapOfRequestParentIdByChildId.get(taskId));
                            }
                            
                            system.debug('executedTaskId::'+executedTaskId);
                            ts.Status = 'Completed';
                            taskListTobeUpdate.add(ts);
                            
                            
                        }
                        system.debug('executedTaskId::'+executedTaskId);
                        Document_Handler__c docHandler = new Document_Handler__c();
                        docHandler.Proceed_Task_Ids__c = executedTaskId;
                        docHandler.Status__c = 'Completed';
                        docHandler.Document_Metadata__c = docMetaRec.Id;
                        docHandlerTobeInsert.add(docHandler);
                        if(!docHandlerTobeInsert.isEmpty()){
                            List<Database.SaveResult> insertResults = Database.insert(docHandlerTobeInsert, false);
                            for(Integer i = 0; i < insertResults.size(); i++) {
                                if(insertResults[i].isSuccess()) {
                                    // Success: Record was inserted successfully
                                    System.debug('Account inserted successfully: ' + docHandlerTobeInsert[i].Id);
                                    System.debug('Task Id ' + docHandlerTobeInsert[i].Task_Id__c);
                                    file.title = 'PayableAccount.csv';
                                    file.versionData = Blob.valueOf(Base64);
                                    file.pathOnClient = '/PayableAccounts.csv';
                                    file.FirstPublishLocationId = docHandlerTobeInsert[i].Id;
                                    fileTobeInsertList.add(file);
                                } else {
                                    // Failure: Record failed to insert
                                    for(Database.Error error : insertResults[i].getErrors()) {
                                        System.debug('Error message: ' + error.getMessage());
                                    }
                                }
                            }
                            if(!fileTobeInsertList.isEmpty()){
                                insert fileTobeInsertList;
                            }  
                        }
                        system.debug('taskListTobeUpdate::'+taskListTobeUpdate);
                    }
                    
                    if(!extendedIdSet.isEmpty()){
                        List<Document_Handler__c> listofDocHanlderTobeUpdate = new List<Document_Handler__c>();
                        listofDocHanlderTobeUpdate = [SELECT Id,Extended_SObject_RecordId__c
                                                      from Document_Handler__c 
                                                      where Extended_SObject_RecordId__c in: extendedIdSet];
                        system.debug('listofDocHanlderTobeUpdate::'+listofDocHanlderTobeUpdate);
                        if(!listofDocHanlderTobeUpdate.isEmpty()){
                            for(Document_Handler__c docHandler : listofDocHanlderTobeUpdate){
                                docHandler.Status__c = Constants.DOC_HANDLER_MEMO_EXECUTED;
                                docHandler.Document_Created__c = true;
                                docHandler.Physical_Document_Received__c = true;
                                docHandler.Document_Id_Value__c = String.valueOf(mapOfRecIdByPayRec.get(docHandler.Extended_SObject_RecordId__c).Instrument_Number__c);
                            }
                            
                            update listofDocHanlderTobeUpdate;
                            if(!taskListTobeUpdate.isEmpty()){
                                update taskListTobeUpdate;
                            }
                        }
                    }
                }   
            }
            return 'SUCCESS';
        }catch(Exception e){
            system.debug('exception::'+e);
            system.debug('exception line::'+e.getStackTraceString());
            System.debug('The following exception has occurred: ' + e.getMessage());
            return e.getMessage();
        }
    }
}