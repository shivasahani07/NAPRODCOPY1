global class GlobalMethod_Call {
    //THIS METHOD WILL GET ALL RELATED ACCOUNT FROM LOGIN USER/INPUT USER
    public static List<Account> getAllRelatedAccounts(String userId) {
        List<Account> assignedLocationAccountList = new List<Account>();
        if (userId == null) {
            system.debug('Please Enter User Id');
        } else {
            try {
                User userDetails = [SELECT Id, Name, Branches_List_String_Literal__c FROM User WHERE Id = :userId LIMIT 1];
                if (userDetails == null) {
                    system.debug('User not found with ID: ' + userId);
                }
                String branchesList = userDetails.Branches_List_String_Literal__c;
                if (branchesList != null) {
                    list<String> assignedLocationAccountNames = branchesList.split(',');
                    assignedLocationAccountList = [SELECT Id, Name FROM Account WHERE Name IN :assignedLocationAccountNames];
                } else {
                    system.debug('Location Not found for User: ' + userDetails.Name);
                }
            } catch (QueryException qe) {
                system.debug('Query Exception: ' + qe.getMessage());
            }
        } 
        system.debug('assignedLocationAccountList---'+assignedLocationAccountList);
        return assignedLocationAccountList;
    }
}