public class caseTriggerHelper {
    
    public static void updateWebEmail(List<Case> newCaseList){
        
        for(Case newcase : newCaseList){
            
            if(newcase.SuppliedEmail == 'reachus@northernarc.com' && newcase.Description.contains('Email :')){
                system.debug('newcase.Description' + newcase.Description);
                List<String> caseEmail = newcase.Description.split('Email :');
                system.debug('newcase.Description' + caseEmail[1]);
                List<String> webEmailValue = caseEmail[1].split('Contact');
                system.debug('caseEmail' + webEmailValue[0]);
                
                newcase.SuppliedEmail = webEmailValue[0].replaceAll('(\\s+)', '');
                system.debug('newcase.SuppliedEmail' + newcase.SuppliedEmail);
            }
        }
        
    }
}