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
}