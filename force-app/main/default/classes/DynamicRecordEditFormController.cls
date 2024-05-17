public class DynamicRecordEditFormController {
	@AuraEnabled
    public static List<Action_Form_Details__c> getRecordEditFormDetails(Id padId){
        
        return [SELECT id,Editable__c,Input_Type__c,Label_API__c,Label_Name__c,Mapping_Field_API__c
                From Action_Form_Details__c 
                Where Process_Attribute_Details__c =: padId and Active__c = true];
    }
    
    @AuraEnabled
    public static void upsertActionFormDetails(List<Action_Form_Details__c> actionFormDetails,Id taskId){
        Task ts = new Task();
        ts.Id = taskId;
        for(Action_Form_Details__c afd : actionFormDetails){
            system.debug('Data::'+afd.Label_API__c);
            
            ts.put(afd.Mapping_Field_API__c, afd.Label_API__c);
        }
        Update ts;
        //system.debug(ts);
     }
    
    
}