@isTest

public class testCaseTriggerHelper {
    
    static testmethod void updateWebEmail(){
        
        List<Case> caseList = new List<Case>();
        
        Case newCase = new Case();
        newCase.SuppliedEmail = 'reachus@northernarc.com';
        newCase.Description = 'First Name : Challa Last Name : Srikanth Email : shubhi.v@utilitarianlab.com Contact Number : 7013092538';
        newCase.Status = 'New';
        
        caseList.add(newCase);
        
        Case newCase1 = new Case();
        newCase1.SuppliedEmail = 'reachus@northernarc.com';
        newCase1.Description = 'First Name : Siddhant Last Name : Tyagi Email : sid.tyagi@gmail.com Contact Number : 6573769473';
        newCase1.Status = 'New';
        
        caseList.add(newCase1);
        
        insert caseList;
        
        caseTriggerHelper.updateWebEmail(caseList);
        
    }
    
}