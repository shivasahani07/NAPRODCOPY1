trigger TriggeronTask on Task (after insert,before insert,before update) {
    
    if(trigger.isBefore && trigger.isInsert){
        TaskTriggerHandler.tagDefaultNumber(trigger.new);
    }
}