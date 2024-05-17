public class AutoResponseEmail {
    
    @InvocableMethod
    Public static void Send_Autoresponse_Email(List<Case> CaseList){
        system.debug('CaseList--'+CaseList);
        String caseId='';
        String caseNumber='';
        String caseSubject='';
        for (case cas:CaseList){
              system.debug('cas Id ::'+Cas.Id);
              caseId = Cas.Id;
              caseNumber=cas.caseNumber;
              caseSubject=cas.Subject;
            
        } 
        string whatid = caseId;
        string fromadd =[Select Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:System.Label.Orgwide_emailAddress].Id;
        ID caserecId = Id.valueOf(whatid);
        EmailMessage em=[Select id,Subject,TextBody,HtmlBody,MessageIdentifier,ThreadIdentifier,FromAddress,ClientThreadIdentifier,ToAddress,RelatedToId  from EmailMessage where ParentId=:whatid order by CreatedDate desc Limit 1];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='Case Auto Response'];
        String formattedToken = EmailMessages.getFormattedThreadingToken(caseId);
        system.debug(formattedToken);
        string emailBody=emailTemplate.body;
        
        system.debug('Case.CaseNumber =====>  ' + CaseNumber);
        emailBody=emailBody.replace('{!Case.CaseNumber}',caseNumber);
        Messaging.SingleEmailMessage email_Custom =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {em.FromAddress};
           
        string plainBody=emailBody+formattedToken+'\n\n' +'--------------- Original Message ---------------'+'\n'+
            'From: '+em.ToAddress+'['+em.ToAddress+']'+'\n'+'To: '+em.FromAddress+'\n'+'Subject: '+em.Subject+'\n\n'+em.TextBody;
        string InReplyTo =em.MessageIdentifier;
        system.debug('toAddresses--'+toAddresses);
        system.debug('plainBody--'+plainBody);
        system.debug('InReplyTo--'+InReplyTo);
        
        email_Custom.setTemplateID(emailTemplate.Id);  
        email_Custom.setSubject('RE:'+em.Subject);
        email_Custom.setPlainTextBody(plainBody);
        email_Custom.setToAddresses(toAddresses);
        email_Custom.setInReplyTo(InReplyTo);
        email_Custom.setWhatId(whatid);
        email_Custom.setOrgWideEmailAddressId( fromadd );
       
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email_Custom});
        system.debug('r --> ' + r);        
    }
    
}