public class JSONGenerator {
    
    public static string notificationJSONGenerator(Process_Attribute_Details__c padRec,String phoneNumber){
        System.debug('padRec =====> ' + padRec);
        List<String> ccEmailList = new List<String>{};
            List<String> toUserEmailList = new List<String>{};
                list<String> bccUserEmails = new List<String>{};
                    list<String> toUserMobileNumbers = new List<String>();
                    if(System.Label.Activate_Communication_Template == 'True'){
                        toUserMobileNumbers.add(phoneNumber);
                            }else{
                                toUserMobileNumbers.add(System.Label.Default_Communication_Number);
                            }
                    
                        List<String> channelList = new List<String>{padRec.Communication_Template__r.Channel_Type__c};
                            system.JSONGenerator jsGen = system.JSON.createGenerator(true);
        
        jsGen.writeStartObject();
        jsGen.writeObjectField('appId','SF');
        jsGen.writeObjectField('typeId',padRec.Communication_Template__r.Nimbus_Template_Id__c); // details from PAD tamplate ID
        jsGen.writeFieldName('content');
        jsGen.writeStartObject();
        
        jsGen.writeStringField('name','Kishan');
        jsGen.writeStringField('shortAccNo','20011101015011');
        jsGen.writeStringField('disbursedAmount','10000');
        jsGen.writeStringField('utrReferenceNumber','IDFBH89135621673');
        jsGen.writeEndObject();
        
        jsGen.writeObjectField('ccUserEmails',ccEmailList);
        jsGen.writeObjectField('toUserEmails',toUserEmailList);
        //jsGen.writeObjectField('bccUserEmails',bccUserEmails);
        jsGen.writeObjectField('toUserMobileNumbers',toUserMobileNumbers);
        jsGen.writeObjectField('channels',channelList); //Details From PAD
        jsGen.writeEndObject();
        
        String jsonData = jsGen.getAsString();
        system.debug('jsonData::'+jsonData);
        
        return jsonData;
    }

    public static String CaseSMSnotificationJSONGenerator(Process_Attribute_Details__c padRec,String phoneNumber, task taskrecord){

        List<AttachmentsClass> attachEMptylist = new List<AttachmentsClass>();
        List<String> PhoneNumberList = new List<String>();
        PhoneNumberList.add(phoneNumber);

        List<String> channelList = new List<String>{padRec.Communication_Template__r.Channel_Type__c};

        PaylinkSMSNotificationwrapperClass PlinkSMSNotWrap = new PaylinkSMSNotificationwrapperClass();
        PlinkSMSNotWrap.appId = 'SF';

        PlinkSMSNotWrap.Attachments = attachEMptylist;
        PlinkSMSNotWrap.toUserMobileNumbers = PhoneNumberList;
        PlinkSMSNotWrap.channels = channelList;
        PlinkSMSNotWrap.typeId = padRec.Communication_Template__r.Nimbus_Template_Id__c;

        ContentClass conwrap = new ContentClass();
        List<Action_Form_Details__c> ActFormDetails = [SELECT Active__c,CreatedDate,Editable__c,Id,Input_Type__c,Label_API__c,Label_Name__c,Mapping_Field_API__c,Name,Process_Attribute_Details__c 
                                                        FROM Action_Form_Details__c
                                                        where Process_Attribute_Details__c =:padRec.Id  ];
        Map<String, String> content = new Map<String, String>();
        if (ActFormDetails.size() > 0) {
            
            if (ActFormDetails[0].Label_Name__c != null) {
                String SelectedAttribute = ActFormDetails[0].Mapping_Field_API__c;
                
                String LabelAPI = ActFormDetails[0].Label_API__c;
               List<String> LabelAPIlst = LabelAPI.split(',');
               Integer NoofParameters= Integer.valueOf(Math.floor(String.valueOf(taskrecord.get(SelectedAttribute)).length()/30));
               Integer Lengthofstr=Integer.valueOf(String.valueOf(taskrecord.get(SelectedAttribute)).length());
               for(Integer i=0;i<=NoofParameters;i++){
                   //LabelAPIlst[i] = String.valueOf(taskrecord.get(SelectedAttribute)).substring(i*30 , (i*30)+29);
                    content.put( LabelAPIlst[i] , String.valueOf(taskrecord.get(SelectedAttribute)).substring(i*30 , Math.min(Lengthofstr,(i*30)+30)));
               }
                  
                /* (String.valueOf(taskrecord.get(SelectedAttribute)).length() >30) {
                    
                    If(String.valueOf(taskrecord.get(SelectedAttribute)).length() >30 && String.valueOf(taskrecord.get(SelectedAttribute)).length() < 60){
                        integer intialindex =0;
                        integer endindex =29;
                        for(String str : LabelAPIlst){
                            String paylink1 = String.valueOf(taskrecord.get(SelectedAttribute)).substring(intialindex, endindex); 
                            content.put( LabelAPIlst[0] , paylink1);
                            intialindex += 30;
                            endindex += 30;
                        }
                    }
                    else if (String.valueOf(taskrecord.get(SelectedAttribute)).length() <30) {
                        content.put( LabelAPIlst[0] , String.valueOf(taskrecord.get(SelectedAttribute)));
                    }
                }
                else {
                    content.put( LabelAPI , String.valueOf(taskrecord.get(SelectedAttribute)));
                }*/
            }
        }
        PlinkSMSNotWrap.content = content;

        String jsonData = JSON.serialize(PlinkSMSNotWrap);
        System.debug('jsonData ====> ' + jsonData);
        return jsonData;

    }
    

    public class PaylinkSMSNotificationwrapperClass {

        public String appId;
        public List<AttachmentsClass> attachments;
        public List<String> toUserMobileNumbers;
        public List<String> channels;
        public Map<String, String> content ;
        public String typeId;
    }

    public class ContentClass {
        public String paymentLink;
        public String accountNumber;
        public string address;
    }

    public class AttachmentsClass {
    }
}