public class RedirectCompApexhelper{
    @auraEnabled
    Public static CaseOriginatingSystemWrapper reedirecttosite(String recId){

        system.debug('recId ====> ' + recId);
        Case casrec = new Case();
        Account accRec = new Account();
        CaseOriginatingSystemWrapper CasOrigSystemWrap = new CaseOriginatingSystemWrapper();



        if (recId != null){

            casrec = [SELECT id, AccountId, Account_Email__c, Financial_Account__c, Financial_Account__r.Originating_System__c, Financial_Account__r.Originating_System_URL_ID__c
                      FROM Case
                      where Id = :recId ]; //AND (Financial_Account__r.Originating_System__c != null AND Financial_Account__r.Originating_System_URL_ID__c != null)
                      
            if (casrec.AccountId != null){
                accRec = [Select id, Originating_System__c, Originating_System_URL_ID__c
                          from Account
                          where id = :casrec.AccountId ]; //AND (Originating_System__c != null AND Originating_System_URL_ID__c != null)
                          //CasOrigSystemWrap.AccRecDetail =accrec;
            }

            if (casrec != null) {
                CasOrigSystemWrap.CaseRecdetail = casRec;
            }
            else {
                CasOrigSystemWrap.CaseRecdetail = null;
            }
            if (accRec != null) {
                CasOrigSystemWrap.AccRecDetail =accrec;
            }
            else {
                CasOrigSystemWrap.AccRecDetail =null;
            }

        }

        return CasOrigSystemWrap;
    }

    public class CaseOriginatingSystemWrapper{
        @AuraEnabled
        public Case CaseRecdetail{ get; set; }
        @AuraEnabled
        public Account AccRecDetail{ get; set; }

    }

}