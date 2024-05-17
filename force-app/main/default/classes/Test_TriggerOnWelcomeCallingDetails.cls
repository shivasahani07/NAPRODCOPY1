@isTest
public class Test_TriggerOnWelcomeCallingDetails {
	@isTest
    public static void testMethodWCD(){
        Welcome_Calling_Details__c wcd = new Welcome_Calling_Details__c();
        wcd.Account_Number__c = 'testAccount';
        insert wcd;
    }
}