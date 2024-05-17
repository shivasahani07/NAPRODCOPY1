global class Batch_UpdateAccountPIIData implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        // collect the batches of records or objects to be passed to execute

        String query = 'SELECT AADHAAR_No__c,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,Email_Id__c,Id,PAN_No__c,Phone FROM Account'; //Masked_Mobile_Number__c, Mobile_Number__Where  Mobile_Number__c != Null
        return Database.getQueryLocator(query);
    }
    //Masked_AADHAAR_No__c,Masked_BillingCIty__c,Masked_BillingCountry__c,Masked_BillingPostalCode__c,Masked_BillingState__c,Masked_BillingStreet__c,Masked_Email__c

    global void execute(Database.BatchableContext BC, List<Account> AccList){

        // process each batch of records default size is 200
        List<Account> UpdatedAcclist = new List<Account>();
        if (AccList.size() > 0){
            for (Account acc : AccList){
                account updatedacc = new Account();

                /*if (acc.AADHAAR_No__c != null){
                    updatedacc.Id = acc.Id;
                    updatedacc.Masked_AADHAAR_No__c = String.valueOf(acc.AADHAAR_No__c);
                }
                if (acc.Email_Id__c != null){
                    updatedacc.Id = acc.Id;
                    updatedacc.Masked_Email__c = String.valueof(acc.Email_Id__c);
                }*/
                /*if (acc.Mobile_Number__c != null){
                    updatedacc.Id = acc.Id;
                    if ((acc.Phone != null && acc.Phone != acc.Mobile_Number__c) || (acc.Phone == null)) {
                        updatedacc.Phone = String.valueof(acc.Mobile_Number__c);
                        updatedacc.Masked_Phone__c = String.valueof(acc.Mobile_Number__c);
                    }
                    
                    //updatedacc.Masked_Mobile_Number__c = String.valueof(acc.Mobile_Number__c);
                }*/
                /*if (acc.PAN_No__c != null){
                    updatedacc.Id = acc.Id;
                    updatedacc.Masked_PAN_No__c = String.valueof(acc.PAN_No__c);
                }
                if (acc.Phone != null){
                    updatedacc.Id = acc.Id;
                    //updatedacc.Masked_Phone__c = String.valueof(acc.Phone);
                }
                if (acc.BillingCity != null){
                    updatedacc.Id = acc.Id;
                    updatedacc.Masked_BillingCIty__c = String.valueof(acc.BillingCity);
                }
                if (acc.BillingStreet != null){
                    updatedacc.Id = acc.Id;
                    updatedacc.Masked_BillingStreet__c = String.valueof(acc.BillingStreet);
                }
                if (acc.BillingState != null){
                    updatedacc.Id = acc.Id;
                    updatedacc.Masked_BillingState__c = String.valueof(acc.BillingState);
                }
                if (acc.BillingCountry != null){
                    updatedacc.Id = acc.Id;
                    updatedacc.Masked_BillingCountry__c = String.valueof(acc.BillingCountry);
                }
                if (acc.BillingPostalCode != null){
                    updatedacc.Id = acc.Id;
                    updatedacc.Masked_BillingPostalCode__c = String.valueof(acc.BillingPostalCode);
                }*/
                if (updatedacc.Id != null){
                    UpdatedAcclist.add(updatedacc);
                }
            }
        }
        if (!UpdatedAcclist.isempty()){
            update UpdatedAcclist;
        }
    }

    global void finish(Database.BatchableContext BC){
        // execute any post-processing operations like sending email

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
        JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob
        WHERE Id = :bc.getJobId()];
        System.debug('job =====> ' + job);
    }

}