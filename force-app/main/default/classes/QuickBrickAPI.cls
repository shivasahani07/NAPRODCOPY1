public class QuickBrickAPI {
    @Auraenabled
    public static AuditResponseWrapperClass sendGetRequest(Financial_Account__c fa_Details) {
        system.debug('fa_Details');
        Id recordTypeId = Schema.SObjectType.Receivable__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId();
        
        
        /*Financial_Account__c fa_Details = [SELECT Id,Tenuer__c,Name,
(Select Id 
From Receivables__r 
WHERE RecordTypeId =:recordTypeId)
From Financial_Account__c 
WHERE Id =: finacialAccountId];*/
        
        AuditResponseWrapperClass auditResponse = new AuditResponseWrapperClass();
        auditResponse.auditRec = new API_Callout_Audit__c();
        
        if(fa_Details.Receivables__r.isEmpty()){
            QuickBrickAuthDetails__mdt quickBrickDetails = [SELECT Id,Authentication_Key__c,Cookie_Key__c,End_Point_URL__c
                                                            From QuickBrickAuthDetails__mdt 
                                                            WHERE Label = 'Production'];
            String auditResult = Label.AuditAPIFailedStatus;
            List<Receivable__c> input_receivable = new List<Receivable__c>();
            String endpoint = quickBrickDetails.End_Point_URL__c + fa_Details.Name;
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('Authorization', quickBrickDetails.Authentication_Key__c);  
            request.setHeader('Cookie', quickBrickDetails.Cookie_Key__c);
            system.debug('request::'+request);
            system.debug('request::::'+String.valueOf(request));
            String apiRequest = String.valueOf(request);
            Http http = new Http();
            try {
                HttpResponse response = http.send(request);            
                if (response.getStatusCode() == 200) {
                    System.debug('Response Body: ' + response.getBody());
                    Object jsonResponse = JSON.deserializeUntyped(response.getBody());
                    system.debug('jsonResponse:::'+jsonResponse);
                    Map<String, Object> accountMap = (Map<String, Object>) jsonResponse;
                    system.debug('data::'+accountMap.get('data'));
                    system.debug('data::'+accountMap.get('data'));
                    Map<String,object> loan_account_schedule = (map<String,object>) accountMap.get('data');
                    system.debug(loan_account_schedule.get('loan_account_schedule'));
                    List<Object> objectList = (List<Object>)loan_account_schedule.get('loan_account_schedule');
                    
                    if(!objectList.isEmpty()){
                        
                        for(Object obj : objectList){
                            Receivable__c input_receivable_rec = new Receivable__c();
                            Map<String, Object> tempObj = (Map<String, Object>) obj;
                            
                            if(String.valueOf(tempObj.get('installment_no')) != null){
                                input_receivable_rec.Series__c = String.valueOf(tempObj.get('installment_no'));
                            }
                            
                            if(tempObj.get('installment_date') != null && tempObj.get('installment_no') != '[Rescheduled]'){
                                system.debug('date::'+tempObj.get('installment_date'));
                                String myDateStr = String.valueOf(tempObj.get('installment_date'));
                                List<String> myDateList = myDateStr.split('-');
                                Integer yearVal = Integer.valueOf(myDateList.get(2));
                                Integer monthVal = Integer.valueOf(myDateList.get(1));
                                Integer dayVal = Integer.valueOf(myDateList.get(0));
                                date mydate = date.newinstance(yearVal, monthVal, dayVal);
                                input_receivable_rec.Receivable_Date__c = mydate;
                            }
                            
                            if (tempObj.get('installment_amount') != null && tempObj.get('installment_no') != '[Rescheduled]') {
                                String installmentAmountString = String.valueOf(tempObj.get('installment_amount'));
                                // Remove commas from the string
                                installmentAmountString = installmentAmountString.replaceAll(',', '');
                                input_receivable_rec.Amount__c = Double.valueOf(installmentAmountString);
                            }
                            
                            if (tempObj.get('interest') != null) {
                                Decimal tempAmount = 0;
                                String intrestAmountString = String.valueOf(tempObj.get('interest'));
                                // Remove commas from the string
                                if(intrestAmountString.contains('+')){
                                    input_receivable_rec.Intrest_Amount_In_Text__c = intrestAmountString;
                                    List<String> formattedAmount = intrestAmountString.split('\\s*\\+\\s*');
                                    system.debug('formattedAmount::'+formattedAmount);
                                    for(String str : formattedAmount){
                                        str = str.replaceAll(',', '');
                                        tempAmount += Decimal.valueOf(str);
                                    }
                                }else{
                                    intrestAmountString = intrestAmountString.replaceAll(',', '');
                                    tempAmount = Decimal.valueOf(intrestAmountString);
                                }
                                
                                input_receivable_rec.Intrest_Amount__c = Double.valueOf(tempAmount);
                            }
                            if (tempObj.get('principal') != null && tempObj.get('installment_no') != '[Rescheduled]') {
                                String principalAmountString = String.valueOf(tempObj.get('principal'));
                                // Remove commas from the string
                                principalAmountString = principalAmountString.replaceAll(',', '');
                                input_receivable_rec.Principal_Amount__c = Double.valueOf(principalAmountString);
                            }
                            if (tempObj.get('principal_outstanding') != null && tempObj.get('installment_no') != '[Rescheduled]') {
                                String principalOutAmountString = String.valueOf(tempObj.get('principal_outstanding'));
                                // Remove commas from the string
                                principalOutAmountString = principalOutAmountString.replaceAll(',', '');
                                input_receivable_rec.Principal_Outstanding__c = Double.valueOf(principalOutAmountString);
                            }
                            input_receivable_rec.Financial_Account__c = fa_Details.Id;
                            input_receivable_rec.recordtypeId = recordTypeId;
                            input_receivable.add(input_receivable_rec);
                        }
                        
                        if(!input_receivable.isEmpty()){
                            Insert input_receivable;
                            Financial_Account__c faRec = new Financial_Account__c();
                            faRec.EMI_Amount__c = input_receivable[1].Amount__c;
                            faRec.Tenuer__c = input_receivable.size();
                            faRec.First_EMI_Date__c = input_receivable[0].Receivable_Date__c;
                            faRec.Id = fa_Details.Id;
                            update faRec;
                        }
                    }
                    auditResponse.auditRec.API_Status__c = Label.AuditAPIStatus;
                    auditResponse.auditRec.Request__c = String.valueOf(request);
                    auditResponse.auditRec.Response__c = response.getBody();
                    auditResponse.auditRec.Status_Code__c = String.valueOf(response.getStatusCode());
                    auditResult = Label.AuditAPIStatus;
                    
                } else {
                    System.debug('Error Response: ' + response.getBody());
                    auditResponse.auditRec.Request__c = String.valueOf(request);
                    auditResponse.auditRec.Response__c = response.getBody();
                    auditResponse.auditRec.API_Status__c = Label.AuditAPIFailedStatus;
                    auditResponse.auditRec.Status_Code__c = String.valueOf(response.getStatusCode());
                }
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
                auditResponse.auditRec.Request__c = String.valueOf(request);
                auditResponse.auditRec.Response__c = e.getMessage();
                auditResponse.auditRec.API_Status__c = Label.AuditAPIFailedStatus;
                auditResponse.auditRec.Status_Code__c = '201';
            }
        }
        
        return auditResponse;
    }
    
}