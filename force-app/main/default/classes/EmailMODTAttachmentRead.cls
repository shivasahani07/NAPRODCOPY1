global class EmailMODTAttachmentRead implements Messaging.InboundEmailHandler{
    List<MODTWrapper> listOfMODTWrapperRec = new List<MODTWrapper>();
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try{
            Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
            Messaging.InboundEmail.textAttachment[] bAttachmentsText = email.textAttachments;
            
            
            
            if(bAttachmentsText !=null){
                for(Messaging.InboundEmail.textAttachment btt :bAttachmentsText){
                    String attachmentContent = btt.body;
                    List<String> rows = attachmentContent.split('\n');
                    integer sampleCounter = rows.Size();
                    for(integer i=0;i<rows.Size();i++){
                        Integer openParenIndex = rows[i].indexOf('(');
                        if (openParenIndex != -1) {
                            Integer closeParenIndex = rows[i].indexOf(')', openParenIndex);
                            if (closeParenIndex != -1) {
                                String insideParentheses = rows[i].substring(openParenIndex + 1, closeParenIndex);
                                insideParentheses = insideParentheses.replace(',', ';');
                                rows[i] = rows[i].substring(0, openParenIndex + 1) + insideParentheses + rows[i].substring(closeParenIndex);
                            }
                        }
                        List<String> csvColumns = rows[i].split(',');
                        if(!csvColumns.isEmpty()){
                            for(integer j=0;j<csvColumns.size();j++){
                                if(csvColumns[j] == 'LOANNO'){
                                    for(integer k=i+1;k<sampleCounter;k++){
                                        MODTWrapper MODTWrapperRec = new MODTWrapper();
                                        MODTWrapperRec.loanNo = rows[k].split(',')[j];
                                        listOfMODTWrapperRec.add(MODTWrapperRec);
                                    }
                                }
                                if(csvColumns[j] == 'PDD / OTC'){
                                    integer tempCount = 0;
                                    for(integer k=i+1;k<sampleCounter;k++){
                                        for(integer d=0;d<listOfMODTWrapperRec.size();d++){
                                            if(tempCount == d){
                                                listOfMODTWrapperRec[d].loanType =  rows[k].split(',')[j];
                                            }
                                        }
                                        ++tempCount;
                                    }
                                }
                                if(csvColumns[j] == 'CATEGORY OF OTC/PDD'){
                                    integer tempCount = 0;
                                    for(integer k=i+1;k<sampleCounter;k++){
                                        for(integer d=0;d<listOfMODTWrapperRec.size();d++){
                                            if(tempCount == d){
                                                Integer openParenIndex1 = rows[k].indexOf('(');
                                                if (openParenIndex1 != -1) {
                                                    Integer closeParenIndex = rows[k].indexOf(')', openParenIndex1);
                                                    if (closeParenIndex != -1) {
                                                        String insideParentheses = rows[k].substring(openParenIndex1 + 1, closeParenIndex);
                                                        insideParentheses = insideParentheses.replace(',', ';');
                                                        rows[k] = rows[k].substring(0, openParenIndex1 + 1) + insideParentheses + rows[k].substring(closeParenIndex);
                                                    }
                                                }
                                                listOfMODTWrapperRec[d].category =  rows[k].split(',')[j];
                                            }
                                        }
                                        ++tempCount;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            system.debug('listOfMODTWrapperRec::'+listOfMODTWrapperRec);
            
            if(!listOfMODTWrapperRec.isEmpty()){
                for(MODTWrapper modtRec : listOfMODTWrapperRec){
                    if(modtRec.category != null){
                        system.debug('modtRec.category::'+modtRec.category);
                        system.debug('modtRec.category.trim::'+modtRec.category.trim());
                        String str = modtRec.category;
                        str = str.replaceAll('"', '');
                        str = str.replace('|', ','); 
                        system.debug('str.trim::'+str.trim());
                        modtRec.category = str;
                    }
                }
                createMODTDocHandler(listOfMODTWrapperRec);
                
            }
        }catch(Exception e){
            system.debug('exception::'+e);
            system.debug('exception line::'+e.getStackTraceString());
            return result;
        }
        
        return result;
    }
    
    public static void createMODTDocHandler(List<MODTWrapper> listOfMODTWrapper){
        Set<String> setOfFinancialAccountId = new Set<String>();
        Map<String,list<String>> mapofFAIByListOfCat = new Map<String,List<String>>();
        Set<Id> opportunityIdSet = new Set<Id>();
        Map<String,String> mapOfLoanIdByLoanType = new Map<String,String>();
        for(MODTWrapper modtRec : listOfMODTWrapper){
            setOfFinancialAccountId.add(modtRec.loanNo);
            mapOfLoanIdByLoanType.put(modtRec.loanNo,modtRec.loanType);
            for(String str : modtRec.category.split(',')){
                if(mapofFAIByListOfCat.containsKey(modtRec.loanNo)){
                    mapofFAIByListOfCat.get(modtRec.loanNo).add(str);
                }else{
                    mapofFAIByListOfCat.put(modtRec.loanNo,new List<String>{str});
                }
            }
            
            if(!mapofFAIByListOfCat.isEmpty()){
                for(String str : mapofFAIByListOfCat.keySet()){
                    List<String> tempStringList = new List<String>();
                    tempStringList =  mapofFAIByListOfCat.get(str);
                    Integer tempIndex = 0;
                    for(String catStr : mapofFAIByListOfCat.get(str)){
                        Integer openParenIndex = catStr.indexOf('(');
                        if (openParenIndex != -1) {
                            Integer closeParenIndex = catStr.indexOf(')', openParenIndex);
                            if (closeParenIndex != -1) {
                                String insideParentheses = catStr.substring(openParenIndex + 1, closeParenIndex);
                                insideParentheses = insideParentheses.replace(';', ','); 
                                catStr = catStr.substring(0, openParenIndex) + '(' + insideParentheses + ')' + catStr.substring(closeParenIndex + 1);
                                catStr = catStr.replaceAll('"', '');
                                tempStringList[tempIndex] = catStr;
                            }
                        }
                        
                        system.debug('catStr: after execution'+catStr);
                        tempIndex++;
                        //modtRec.category = str;
                    }
                    mapofFAIByListOfCat.put(str,tempStringList);
                }
                
                system.debug('mapofFAIByListOfCat::'+mapofFAIByListOfCat);
            }
        }
        
        if(!setOfFinancialAccountId.isEmpty()){
            List<Financial_Account__c> listOfFinancialAccount = new List<Financial_Account__c>();
            Map<ID,Financial_Account__c> mapOfOpportunityIDByFinanicialRec = new map<Id,Financial_Account__c>();
            listOfFinancialAccount = [SELECT Id,Opportunity__c,LOS_Application_ID__c
                                      From Financial_Account__c 
                                      WHERE LOS_Application_ID__c in: setOfFinancialAccountId];
            if(!listOfFinancialAccount.isEmpty()){
                for(Financial_Account__c fa : listOfFinancialAccount){
                    opportunityIdSet.add(fa.Opportunity__c);
                    mapOfOpportunityIDByFinanicialRec.put(fa.Opportunity__c,fa);
                }
                
                if(!opportunityIdSet.isEmpty()){
                    Set<Id> pptdIdSet = new Set<Id>();
                    List<Task> taskListTobeFetch = New List<Task>();
                    List<Task> taskListTobeConsiderForOperation = new List<Task>();
                    taskListTobeFetch = [SELECT Id,Process_Path_Task_Detail__c,whatId,Subject
                                         From Task 
                                         Where whatId In:opportunityIdSet and isclosed = false 
                                         and (Subject =: Constants.OTC_DOCUMENT_COLLECTION 
                                              or Subject =:Constants.PDD_DOCUMENT_COLLECTION )];
                    
                    if(!taskListTobeFetch.isEmpty()){
                        Map<Id,Id> mapOfPPTDIdby = new Map<Id,Id>();
                        Map<Id,Task> mapofTaskIdByTask = new Map<Id,Task>();
                        for(Task ts : taskListTobeFetch){
                            pptdIdSet.add(ts.Process_Path_Task_Detail__c);
                            if(mapOfLoanIdByLoanType.get(mapOfOpportunityIDByFinanicialRec.get(ts.whatId).LOS_Application_ID__c) == Constants.OTC_DOC_TYPE && ts.Subject == Constants.OTC_DOCUMENT_COLLECTION){
                                mapOfPPTDIdby.put(ts.Process_Path_Task_Detail__c,ts.Id);
                                taskListTobeConsiderForOperation.add(ts);
                                mapofTaskIdByTask.put(ts.Id,ts);
                            }else if(mapOfLoanIdByLoanType.get(mapOfOpportunityIDByFinanicialRec.get(ts.whatId).LOS_Application_ID__c) == Constants.PDD_DOC_TYPE  && ts.Subject == Constants.PDD_DOCUMENT_COLLECTION){
                                mapOfPPTDIdby.put(ts.Process_Path_Task_Detail__c,ts.Id);
                                taskListTobeConsiderForOperation.add(ts);
                                mapofTaskIdByTask.put(ts.Id,ts);
                            }
                        }
                        if(!pptdIdSet.isEmpty()){
                            List<Process_Attribute_Dcoument_Detail__c> listOfPADD = new List<Process_Attribute_Dcoument_Detail__c>();
                            Map<String,List<Process_Attribute_Dcoument_Detail__c>> mapOfRecIdByRec = new Map<String,List<Process_Attribute_Dcoument_Detail__c>>();
                            listOfPADD = [SELECT Id,Document_Metadata__c,Document_Metadata__r.Description__c,Process_Path_Task_Detail__c,Document_Metadata__r.Document_Name__c,
                                          Document_Metadata__r.Physical_Document_Mandatory__c,Document_Metadata__r.Upload_Mandatory__c
                                          From Process_Attribute_Dcoument_Detail__c 
                                          WHERE Process_Path_Task_Detail__c in: pptdIdSet];
                            if(!listOfPADD.isEmpty()){
                                for(Process_Attribute_Dcoument_Detail__c pptdRec : listOfPADD){
                                    if(mapOfRecIdByRec.containsKey(pptdRec.Process_Path_Task_Detail__c)){
                                        mapOfRecIdByRec.get(pptdRec.Process_Path_Task_Detail__c).add(pptdRec);
                                    }else{
                                        mapOfRecIdByRec.put(pptdRec.Process_Path_Task_Detail__c,new List<Process_Attribute_Dcoument_Detail__c>{pptdRec});
                                    }
                                }
                            }
                            Set<Id> excludeDocMetaId = new Set<Id>();
                            List<Document_Handler__c> docHandlerTobeInsert = new List<Document_Handler__C>();
                            Map<Id,List<Id>> mapofTaskIdByListofDocMetaId = new Map<Id,List<ID>>();
                            Map<Id,List<Process_Attribute_Dcoument_Detail__c>> mapOfTaskIdByListOfPADDDocId = new Map<Id,List<Process_Attribute_Dcoument_Detail__c>>();
                            if(!taskListTobeConsiderForOperation.isEmpty()){
                                List<Document_Handler__C> docHandlerList = new List<Document_Handler__C>();
                                
                                docHandlerList = [SELECT Id,Document_Metadata__r.Id,Task_Id__c 
                                                  FROM Document_Handler__c 
                                                  where Task_Id__c in: mapofTaskIdByTask.keySet()];
                                if(!docHandlerList.isEmpty()){
                                    for(Document_Handler__c docHandler : docHandlerList){
                                        if(mapofTaskIdByListofDocMetaId.containsKey(docHandler.Task_Id__c)){
                                            mapofTaskIdByListofDocMetaId.get(docHandler.Task_Id__c).add(docHandler.Document_Metadata__c);
                                        }else{
                                            mapofTaskIdByListofDocMetaId.put(docHandler.Task_Id__c,new list<Id>{docHandler.Document_Metadata__c});
                                        }
                                    }
                                }
                            }
                            for(Task ts : taskListTobeConsiderForOperation){
                                for(Process_Attribute_Dcoument_Detail__c padd : mapOfRecIdByRec.get(ts.Process_Path_Task_Detail__c)){
                                    if(mapOfTaskIdByListOfPADDDocId.containsKey(ts.Id)){
                                        mapOfTaskIdByListOfPADDDocId.get(ts.Id).add(padd);
                                    }else{
                                        mapOfTaskIdByListOfPADDDocId.put(ts.Id,new list<Process_Attribute_Dcoument_Detail__c>{padd});
                                    }
                                }
                                for(String str : mapofFAIByListOfCat.get(mapOfOpportunityIDByFinanicialRec.get(ts.WhatId).LOS_Application_ID__c)){
                                    if(mapOfRecIdByRec.get(ts.Process_Path_Task_Detail__c) != null){
                                        for(Process_Attribute_Dcoument_Detail__c padd : mapOfRecIdByRec.get(ts.Process_Path_Task_Detail__c)){
                                            
                                            if(padd.Document_Metadata__r.Description__c.contains(str.trim())){
                                                excludeDocMetaId.add(padd.Document_Metadata__r.Id);
                                                
                                            }
                                        }
                                    }
                                }
                                
                                system.debug('mapofTaskIdByListofDocMetaId::'+mapofTaskIdByListofDocMetaId);
                                /*for(Process_Attribute_Dcoument_Detail__c padd : mapOfTaskIdByListOfPADDDocId.get(ts.Id)){
system.debug('padd::'+padd.Document_Metadata__c);
if(!mapofTaskIdByListofDocMetaId.get(ts.Id).contains(padd.Document_Metadata__c)){
Document_Handler__c docHandlerRec = new Document_Handler__c();
docHandlerRec.Task_Id__c = ts.Id;
docHandlerRec.Document_Metadata__c = padd.Document_Metadata__c;
docHandlerRec.Name = padd.Document_Metadata__r.Document_Name__c;
docHandlerRec.Upload_Mandatory__c = padd.Document_Metadata__r.Upload_Mandatory__c;
docHandlerRec.Physical_Document_Mandatory__c = padd.Document_Metadata__r.Physical_Document_Mandatory__c;
docHandlerRec.Status__c = Constants.DOC_HANDLER_DRAFT;
docHandlerRec.Process_Attribute_Dcoument_Detail__c = padd.Id;
docHandlerRec.Document_Sharing_Task_Ids__c = ts.ID;
docHandlerTobeInsert.add(docHandlerRec);
}
}*/
                            }
                            system.debug('docHandlerTobeInsert::'+docHandlerTobeInsert);
                            system.debug('excludeDocMetaId::'+excludeDocMetaId);
                            List<Document_Metadata__c> listOfProcessDocumentMeta = new List<Document_Metadata__c>();
                            listOfProcessDocumentMeta = [SELECT Id,Description__c,Physical_Document_Mandatory__c,Upload_Mandatory__c
                                                         From Document_Metadata__c Where Id not in: excludeDocMetaId];
                            
                            system.debug('taskListTobeConsiderForOperation::'+taskListTobeConsiderForOperation);
                            for(Task ts : taskListTobeConsiderForOperation){
                                for(String str : mapofFAIByListOfCat.get(mapOfOpportunityIDByFinanicialRec.get(ts.WhatId).LOS_Application_ID__c)){
                                    for(Document_Metadata__c docMeta : listOfProcessDocumentMeta){
                                        if(docMeta.Description__C != null && !mapofTaskIdByListofDocMetaId.get(ts.Id).contains(docMeta.Id) &&  docMeta.Description__C.contains(str.trim())){
                                            Document_Handler__c docHandlerRec = new Document_Handler__c();
                                            docHandlerRec.Task_Id__c = ts.ID;
                                            docHandlerRec.Name = str.trim();
                                            docHandlerRec.Document_Metadata__c = docMeta.Id;
                                            docHandlerRec.Physical_Document_Mandatory__c = docMeta.Physical_Document_Mandatory__c;
                                            docHandlerRec.Upload_Mandatory__c = docMeta.Upload_Mandatory__c;
                                            docHandlerRec.Description__c = docMeta.Description__c;
                                            docHandlerRec.Status__c = Constants.DOC_HANDLER_DRAFT;
                                            docHandlerRec.Document_Sharing_Task_Ids__c = ts.ID;
                                            docHandlerTobeInsert.add(docHandlerRec);
                                        }
                                    } 
                                }
                            }
                            system.debug('docHandlerTobeInsert::'+docHandlerTobeInsert);
                            if(!docHandlerTobeInsert.isEmpty()){
                                insert docHandlerTobeInsert;
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    public class MODTWrapper{
        public String loanNo;
        public String loanType;
        public String category;
    }
    
}