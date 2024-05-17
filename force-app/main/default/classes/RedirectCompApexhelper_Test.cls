@isTest
public class RedirectCompApexhelper_Test {
    @isTest
    Public static void RedirectCompApexhelper_TestMethod(){
        Account AccRec=new Account();
        AccRec.Name='Gautam Lohia123';
        AccRec.Email_Id__c='testemail12@gmail.com';
        insert AccRec;
        
        
        
        Financial_Account__c FARec1=new Financial_Account__c();
        FARec1.Name='6-1';
        FARec1.Account_Name__c=AccRec.Id;
        FARec1.Originating_System__c='Perdix';
        FARec1.Originating_System_URL_ID__c='12345678';
        Insert FARec1;

        
        Case Caserec=new Case();
        Caserec.Category__c='	Bureau Related';
        Caserec.Type='Request';
        Caserec.Status='New';
        Caserec.AccountId=AccRec.Id;
        Caserec.Financial_Account__c=FARec1.Id;
        Insert Caserec;
        
        string recid=Caserec.Id;

        RedirectCompApexhelper.reedirecttosite(recid);
                
    }

}