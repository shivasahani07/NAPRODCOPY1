@isTest
public class GlobalMethod_CallTest {
    @isTest
    static void testValidUserWithAccounts() {
        Account userAccDett = new Account(Name = 'chennai', Product_Bussiness_Line__c='NU Score');
        Account userAccDet = new Account(Name = 'Bangelore', Product_Bussiness_Line__c='NU Score');
        insert userAccDet;
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = userAccDet.Id, IsActive__c = true);
        insert testContact;
        User testUser = TestUtility.createUserInstance();
        testUser.Branches_List_String_Literal__c='Bangelore';
        insert testUser;
        Test.startTest();
        System.runAs(testUser){
            List<Account> result = GlobalMethod_Call.getAllRelatedAccounts(testUser.Id);
        Test.stopTest();
            
        }

    }
}