public without sharing class DynamicRecordDeletion {
    @AuraEnabled
    public static void deleteRecords(List<Id> recordIds) {
        try {
            // Map to store object API names for each record Id
            Map<Id, String> objectApiNames = new Map<Id, String>();
            for (Id recordId : recordIds) {
                String objectApiName = getObjectApiName(recordId);
                objectApiNames.put(recordId, objectApiName);
            }
            // Process each record Id
            for (Id recordId : recordIds) {
                String objectApiName = objectApiNames.get(recordId);
                if (String.isNotBlank(objectApiName)) {
                    Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
                    if (sObjectType != null) {
                        SObject record = sObjectType.newSObject(recordId);
                        delete record;
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting records: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getObjectApiName(Id recordId) {
        String objectApiName;
        try {
            // Get the SObjectType of the record Id
            Schema.SObjectType sObjectType = recordId.getSObjectType();
            if (sObjectType != null) {
                // Get the API name of the object
                objectApiName = sObjectType.getDescribe().getName();
            }
        } catch (Exception e) {
            // Handle any exceptions
            objectApiName = 'Error: ' + e.getMessage();
        }
        return objectApiName;
    }
    
    //THIS METHOD WILL GET ALL RELATED ACCOUNT FROM LOGIN USER/INPUT USER
    public virtual class BaseException extends Exception {}
    public static List<Account> getAllRelatedAccounts(String userId) {
        List<Account> assignedLocationAccountList = new List<Account>();
        if (userId == null) {
            throw new BaseException('Please Enter User Id');
        } else {
            try {
                User userDetails = [SELECT Id, Name, Branches_List_String_Literal__c FROM User WHERE Id = :userId LIMIT 1];
                if (userDetails == null) {
                    throw new BaseException('User not found with ID: ' + userId);
                }
                String branchesList = userDetails.Branches_List_String_Literal__c;
                if (branchesList != null) {
                    list<String> assignedLocationAccountNames = branchesList.split(',');
                    assignedLocationAccountList = [SELECT Id, Name FROM Account WHERE Name IN :assignedLocationAccountNames];
                } else {
                    throw new BaseException('Location Not found for User: ' + userDetails.Name);
                }
            } catch (QueryException qe) {
                throw new BaseException('Query Exception: ' + qe.getMessage());
            }
        }
        system.debug('assignedLocationAccountList---'+assignedLocationAccountList);
        return assignedLocationAccountList;
    }
}