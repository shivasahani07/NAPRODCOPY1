public class CommunicationAPI_Nimbusv1 {
    public class FlowInput{
        @InvocableVariable public sObject inp_record;
    }
    
    @InvocableMethod(label='Send Nimbus Notification' description='Send Notification to customer' category='Task')
    Public static void sendNotificationToCustomer(List<FlowInput> params){
        Set<Id> taskIdSet = new Set<Id>();
        String auditRecId = '';
        for(FlowInput param : params){
            system.debug('param::'+param);
            taskIdSet.add((string) param.inp_record.get('Task_ID__c'));
            auditRecId = (string) param.inp_record.get('Id');
        }
        
        if(!taskIdSet.isEmpty()){
            List<Task> taskList = [select id,SMSVariablevalue__c,Mobile__c,Process_Attribute_Details__c,whatId,whoId,Subject, Attribute1__c,Attribute2__c,Attribute3__c,Attribute4__c from task where id in: taskIdSet];
            CommunicationAPI_Nimbus.sendNotificationToCustomer(taskList,auditRecId);
            
        }
        
    }
}