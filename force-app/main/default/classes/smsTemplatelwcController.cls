public class smsTemplatelwcController {

    @AuraEnabled(cacheable=true)
    public static List<smstemplateWrapper> fetchsmstemplate(Id recId){
        System.debug('recId =====> ' + recId);
        Schema.SObjectType sobjectType = recId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        System.debug('sobjectName ====> ' + sobjectName);
        //sObject sobjRecord = new sObject(); 
        List<Communication_Template__c> ComtempList = new List<Communication_Template__c>();
        List<Process_Attribute_Details__c> PADlist = new  List<Process_Attribute_Details__c>();
        Set<String> PADcomTempIds = new Set<String>();
        Map<String, Process_Attribute_Details__c> comtempIdwithPADList = new Map<String, Process_Attribute_Details__c>();

        List<smstemplateWrapper> smstemplateWrapList = new List<smstemplateWrapper>();

        String querystring;
        if(sobjectName != 'Task'){
        querystring = 'Select '+ 'id, Process_Attribute__c From ' + sobjectName + ' wHERE id=: recId';
        //string qString ='Select '+string.join(fieldAPINamesList,',')+ ' from OpportunityLineItem where id=\'00k90000002z4ml\'';
        }
        else if(sobjectName == 'Task'){
            querystring = 'Select '+ 'id, Process_Attribute_details__c From ' + sobjectName + ' wHERE id=: recId';
        
        }
        System.debug('querystring =====> ' + querystring);

        string PADId;
        string PAId;
        if(querystring.length() > 7){
            sObject sobjRecord = Database.query(querystring);
            System.debug('sobjRecord ====> ' + sobjRecord);
            if(sobjectName != 'Task'){
                PAId = string.valueof(sobjRecord.get('Process_Attribute__c'));
            }
            else{
                 PADId = string.valueof(sobjRecord.get('Process_Attribute_details__c'));
            }
        }

        if(PAId != null){
            PADlist = [Select id, Process_Attribute__c, Communication_Template__c , Task_Subject__c
                        from Process_Attribute_Details__c where Process_Attribute__c =: PAId and Sobject_RecordType__c= 'SMS Notification' AND Task_Automation__c = false];
            if(PADlist.size() >0){
                for (Process_Attribute_Details__c Padrec : PADlist) {
                    PADcomTempIds.add(Padrec.Communication_Template__c);
                    comtempIdwithPADList.put(Padrec.Communication_Template__c, Padrec);
                }
                if(PADcomTempIds.size() >0){
                    ComtempList = [Select id, Body__c, Channel_Type__c , Nimbus_Template_Id__c
                            from Communication_Template__c where ID IN: PADcomTempIds];
                            //Where Process_Attribute__c = : PAId and  Channel_Type__c = 'SMS'
                    if(ComtempList.size() >0){
                        for (Communication_Template__c comtemrec : ComtempList) {
                            smstemplateWrapper smstemplateWrap = new smstemplateWrapper();
                            smstemplateWrap.SmsSubject = comtempIdwithPADList.get(comtemrec.id).Task_Subject__c;
                            smstemplateWrap.smsBody = comtemrec.Body__c;
                            smstemplateWrap.ComtempId = comtemrec.id;
                            smstemplateWrap.NimbusId = comtemrec.Nimbus_Template_Id__c;
                            smstemplateWrapList.add(smstemplateWrap);
                        
                    }
                    
                    }
                    
                
                }
            }    
             
        }
        /*else  if(PADId != null){
            PADlist = [Select id, Process_Attribute__c, Communication_Template__c , Task_Subject__c
                        from Process_Attribute_Details__c where Id =: PAId and Task_Subject__c = 'Welcome SMS' AND Task_Automation__c = false];
            if(PADlist.size() >0){
                for (Process_Attribute_Details__c Padrec : PADlist) {
                    PADcomTempIds.add(Padrec.Communication_Template__c);
                    comtempIdwithPADList.put(Padrec.Communication_Template__c, Padrec);
                }
                if(PADcomTempIds.size() >0){
                    ComtempList = [Select id, Body__c, Channel_Type__c  
                            from Communication_Template__c where ID IN: PADcomTempIds];
                            //Where Process_Attribute__c = : PAId and  Channel_Type__c = 'SMS'
                     if(ComtempList.size() >0){
                        for (Communication_Template__c comtemrec : ComtempList) {
                            smstemplateWrapper smstemplateWrap = new smstemplateWrapper();
                            smstemplateWrap.SmsSubject = comtempIdwithPADList.get(comtemrec.id).Task_Subject__c;
                            smstemplateWrap.SmsBody = comtemrec.Body__c;
                            smstemplateWrap.ComtempId = comtemrec.id;
                            smstemplateWrap.NimbusId = comtemrec.Nimbus_Template_Id__c;
                            smstemplateWrapList.add(smstemplateWrap);
                        
                    }
                     }
                
                }
            }  
        }*/

        if(smstemplateWrapList.size() > 0){
            return smstemplateWrapList;
        }
        else{
            return null;
        }
    }

    @AuraEnabled
    public static String sendsmstemplate(String SmsSubject, String SmsBody, String RecId, string Smsvarvalue, string NimbusId){
        String msg = '';
        System.debug('SmsSubject ====> ' + SmsSubject);
        System.debug('SmsBody ====> ' + SmsBody);
        System.debug('RecId ====> ' + RecId);
        System.debug('Smsvarvalue ====> ' + Smsvarvalue);
        System.debug('NimbusId ====> ' + NimbusId);
        List<task> Tasklist = new List<Task>();
        Case CasRec = [Select id, account.Email_Id__c, Customer_Mobile_No__c,account.Phone From Case where Id =: RecId];

        if(SmsBody != null){
            Task tas = new Task();

            Map<String, String> fieldToValue = new Map<String, String> { 'subject' => SmsSubject, 'description' => SmsBody, 'whatId' => RecId, 'SMSVariablevalue__c' => Smsvarvalue, 'Mobile__c' => CasRec.Customer_Mobile_No__c };
            SObject So = populateByParameter(fieldToValue, tas);
            // tas.subject = SmsSubject;
            // tas.description = SmsBody;
            // tas.whatId = RecId;
            // tas.SMSVariablevalue__c = Smsvarvalue;
            // insert tas;
            // Id objId = tas.Id;
            // SObject record = objId.getSObjectType().newSObject(objId);
            List<Action_Form_Details__c> AFD = [SELECT Active__c,Editable__c,Id,Input_Type__c,Label_API__c,Label_Name__c,Mapping_Field_API__c,Name,Process_Attribute_Details__c FROM Action_Form_Details__c where Process_Attribute_Details__r.Communication_Template__r.Nimbus_Template_Id__c =:NimbusId LIMIT 1]; 
            if (AFD.size() >0){
                String MappingFieldAPIvalue = AFD[0].Mapping_Field_API__c;
                so.put(MappingFieldAPIvalue, Smsvarvalue);
            }
            // if (NimbusId == '10506') {
            //     tas.Attribute1__c = Smsvarvalue;
            // }
            // if (NimbusId == '10504') {
            //     tas.Attribute2__c = Smsvarvalue;
            // }
            //tas.Attribute2__c = CasRec.account.Email_Id__c;
            //update record;
            insert so;
            

            if(tas.Id != null){
                msg = 'SUCCESS';
                
            }
            
        }else{
        
        }
        return msg;
    }

    public class smstemplateWrapper{
        @AuraEnabled
        public String SmsSubject{get;set;}
        @AuraEnabled
        public String smsBody{get;set;}
        @AuraEnabled
        public String ComtempId{get;set;}
        @AuraEnabled
        public String NimbusId{get;set;}
    }

    public static SObject populateByParameter(Map<String,String> fMap, SObject so){

         Map<String,Schema.sObjectField> fieldMap=so.getSObjectType().getDescribe().fields.getMap();
         for(String key: fMap.KeySet()){
             if(key == 'RecordTypeName'){
                 try{
                     so.put('RecordTypeId',so.getSObjectType().getDescribe().getRecordTypeInfosByName().get(fMap.get(key)).getRecordTypeId());
                 }
                 catch(Exception e){
                    continue;
                }
             }
             else if(key != 'Id' && key !='RecordType' && fieldMap.get(key.toLowerCase()) != NULL && fieldMap.get(key.toLowerCase()).getDescribe().isUpdateable()){
                try{
                    String fieldType=String.ValueOf(fieldMap.get(key.toLowerCase()).getDescribe().getType()).toLowerCase();
                    if(fieldType == 'currency' || fieldType == 'double' || fieldType == 'percent' || fieldType == 'decimal'){
                        so.put(key, double.valueOf(fMap.get(key))); 
                    }
                    else if(fieldType == 'boolean'){
                        so.put(key, Boolean.valueOf(fMap.get(key))); 
                    }                   
                    else if(fieldType == 'date'){
                        Date d=date.parse(fMap.get(key));
                        so.put(key,d ); 
                    }  
                    else If(fieldType == 'datetime'){
                        DateTime dt=DateTime.parse(fMap.get(key));
                        so.put(key,dt);
                    }           
                    else{
                        so.put(key,fMap.get(key));
                    }
                }
                catch(Exception e){
                    continue;
                }
             }
         }
         return so;
    }
}