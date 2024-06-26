public class SystemExecutedApex {
    public class FlowInput {
        @InvocableVariable(label='actionName' required=true)
        public String actionName;
        @InvocableVariable(label='taskRecordId' required=true)
        public String taskRecordId;
    }
    
    @InvocableMethod(label='SystemExecutedApex' description='Process records using Apex')
    public static void processRecords(List<FlowInput> flowInputs){
        if(!flowInputs.isEmpty()){
            List<Id> taskRecIdList = new List<Id>();
            for(FlowInput input : flowInputs){
                taskRecIdList.add(input.taskRecordId);
            }
            if(flowInputs[0].actionName == 'SendPayableDetailsToCustomer'){
                SendPayableDetailsToCustomer.sendPayableDetails(taskRecIdList);
            }
        }
    }
}