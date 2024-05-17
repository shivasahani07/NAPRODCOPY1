public class WelcomeCallingDetailsTriggerHandler {
	
    public static void checkActiveWCDRecord(List<Welcome_Calling_Details__c> listOfWCD){
        Set<String> accontNumberSet = new Set<String>();
        for(Welcome_Calling_Details__c wcd : listOfWCD){
            accontNumberSet.add(wcd.Account_Number__c);
        }
        
        List<Welcome_Calling_Details__c> listOfActiveWCD = new List<Welcome_Calling_Details__c>();
        Set<String> activeAccountNumberSet = new Set<String>();
        listOfActiveWCD = [select id,Account_Number__c from Welcome_Calling_Details__c where Account_Number__c in: accontNumberSet and Is_Active__c = true];
        if(!listOfActiveWCD.isEmpty()){
            for(Welcome_Calling_Details__c wcd : listOfActiveWCD){
                activeAccountNumberSet.add(wcd.Account_Number__c);
            }
        }
        for(Welcome_Calling_Details__c wcd : listOfWCD){
            
            if(!activeAccountNumberSet.isEmpty() && activeAccountNumberSet.contains(wcd.Account_Number__c)){
                continue;
            }
            wcd.Is_Active__c = true;
        }
    }
    
    
}