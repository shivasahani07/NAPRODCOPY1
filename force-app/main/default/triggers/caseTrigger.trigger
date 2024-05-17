trigger caseTrigger on Case (before insert) {
    
    if(trigger.isBefore && trigger.isInsert){
        if(label.Case_Trigger_Handler == 'True'){
            caseTriggerHelper.updateWebEmail(Trigger.new);
        }
        
    }
}