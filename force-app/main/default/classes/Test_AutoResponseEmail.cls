@isTest(seeAllData = true)
public class Test_AutoResponseEmail {
    @isTest
    Public static void sendAutoResponse_Test(){
       
        List<case> caselist=new List<case>();
        
        Case caserec=new Case();
        caserec.Subject='Test Case';
        caserec.Origin='Email';
        caserec.Priority='Medium';
        Insert caserec;
        
        EmailMessage Emrec=new EmailMessage();
        Emrec.ParentId=caserec.Id;
        Emrec.TextBody='Test Email';
        Emrec.Subject='Test Subject';
        Emrec.HtmlBody='<div>Test Subject</div>';
        Emrec.FromAddress='amarnathsabat5@gmail.com';
        Emrec.ToAddress='sabatamarnath7@gmail.com';
        
        Insert Emrec;
        
        caselist.add([select id, casenumber,Subject from case where id = : caserec.id]);
        System.debug('case number' + caserec.casenumber);
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='Case Auto Response'];
        system.debug('caselist =====>' + caselist);
        
        AutoResponseEmail.Send_Autoresponse_Email(caselist);
        
    }

}