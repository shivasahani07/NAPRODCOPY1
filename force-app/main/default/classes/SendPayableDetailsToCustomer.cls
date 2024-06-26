public class SendPayableDetailsToCustomer {
    @future
    Public static void sendPayableDetails(List<Id> taskRecordIdList){
        List<Paybale__c> payableList 				= new List<Paybale__c>();
        List<Document_Handler__c> docHanlderTobeUpdate = new List<Document_Handler__c>();
        try{
            Set<Id> DependantTaskIdSet = new Set<Id>();
            for(Task taskRec : [select Id,Execution_Depended_Closed_Task_Ids__c,Parent_Task_Id__c from Task where Id in: taskRecordIdList]){
                DependantTaskIdSet.add(taskRec.Parent_Task_Id__c);
            }
            Map<ID,Paybale__c> mapofPayableIdByDet = new Map<ID,Paybale__c>();
            
            payableList		= [SELECT Id,Value_Date__c,Amount__C,Financial_Entity_A_C_Details__c,Financial_Entity_A_C_Details__r.Bank_Account_Number__c,
                               Financial_Account__r.Name,Payable_File_Name__c,Financial_Entity_A_C_Details__r.Banking_Account_Name__c,
                               Financial_Entity_A_C_Details__r.IFSC_Code__c,Mode__c,Task_Id__c,Financial_Entity_A_C_Details__r.Bank_Account_Type__c,
                               Financial_Account__r.Originating_Branch__r.Name,Financial_Entity_A_C_Details__r.Bank_Name__c	  
                               FROM Paybale__c 
                               Where Task_Id__c in: DependantTaskIdSet and Status__c =: Constants.PAYABLE_STATUS_MEMO_CREATED and Execution_Request_Processed__c = false];
            
            system.debug('payableList::'+payableList);
            if(!payableList.isEmpty()){
                for(Paybale__c payRec : payableList){
                    payRec.Execution_Request_Processed__c = true;
                    mapofPayableIdByDet.put(payRec.Id,payRec);
                }
                
                update payableList;               
                docHanlderTobeUpdate = [SELECT Id,Extended_SObject_RecordId__c
                                        from Document_Handler__c 
                                        where Extended_SObject_RecordId__c in: mapofPayableIdByDet.keySet()];
                if(!docHanlderTobeUpdate.isEmpty()){
                    for(Document_Handler__c docHandlerRec : docHanlderTobeUpdate){
                        docHandlerRec.Status__c = Constants.DOC_HANDLER_SUBMITTED_FOR_EXECUTION;
                    }
                    
                    update docHanlderTobeUpdate;
                }
            }
            List<Task>taskListTobeUpdate = new List<Task>();
            for(ID recID : taskRecordIdList){
                Task taskTobeUpdate = new Task();
                taskTobeUpdate.Id = recID;
                taskTobeUpdate.Status = Constants.TASK_STATUS_COMPLETED;
                taskListTobeUpdate.add(taskTobeUpdate);
            }
            
            if(!taskListTobeUpdate.isEmpty()){
                update taskListTobeUpdate;
            }
        }catch(Exception e){
            system.debug('exception::'+e);
            system.debug('exception line::'+e.getStackTraceString());
        }
    }
}