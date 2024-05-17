trigger TriggerOnWelcomeCallingDetails on Welcome_Calling_Details__c (before insert,after update) {
	
    if(trigger.isInsert && trigger.isBefore){
        WelcomeCallingDetailsTriggerHandler.checkActiveWCDRecord(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isAfter){
        //WelcomeCallingDetailsTriggerHandler.tagWCDRecordToTask(trigger.new,trigger.oldMap);
    }
}