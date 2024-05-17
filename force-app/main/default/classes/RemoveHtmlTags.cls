public class RemoveHtmlTags {
    
    @InvocableMethod(label ='Remove HTML Tags')
    Public static List<String> TextconversionToPlaintext(List<string> richtextlist){
        String richtext = richtextlist[0];
        List<string> plaintextList=new List<string>();
        
        richtext=richtext.stripHtmlTags();
        plaintextList = richtext.split('\r\n');
        system.debug('plaintextList'+plaintextList);
        return plaintextList;
    }

}