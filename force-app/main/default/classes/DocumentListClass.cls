public class DocumentListClass {
    
    @AuraEnabled  
    public static List<ContentDocument> getFiles(string recordId){  
        List<ContentDocument> DocumentList = new List<ContentDocument>();  
        Set<Id> documentIds = new Set<Id>();  //store file ids
        List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:recordId];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  // Document ids
        }      
        DocumentList = [select Id,Title,FileType,ContentSize,Description,CreatedDate from ContentDocument where id IN: documentIds];
        
        return DocumentList;  
    } 

}