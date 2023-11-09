public class ContentDocumentHandler {
	public static List<ContentDocument> contentDocDeleteFinalList;
   
    public static void duplicateFileCheck(list<ContentDocumentLink> documentLinkList){
        Box_Trigger_Decision__mdt AccountDecision = Box_Trigger_Decision__mdt.getInstance('Account'); 
        Box_Trigger_Decision__mdt ContactDecision = Box_Trigger_Decision__mdt.getInstance('Contact');
        Box_Trigger_Decision__mdt CaseDecision = Box_Trigger_Decision__mdt.getInstance('Case');
        
        set<Id> ParentIdSet = new set<Id>();
        List<ContentDocumentLink> contentDocumentLinkList= new  List<ContentDocumentLink>(); 
        map<String, Set<Id>> FileIdMap = new map<String, Set<Id>>();
        
        set<string> objectlst = new set<string>();
        if(AccountDecision != null && AccountDecision.isActive__c == true){
            objectlst.add(AccountDecision.Object_Name__c);
        }
        if(ContactDecision != null && ContactDecision.isActive__c == true){
            objectlst.add(ContactDecision.Object_Name__c);
        }
        if(CaseDecision != null && CaseDecision.isActive__c == true){
            objectlst.add(CaseDecision.Object_Name__c);
        }
        List<Id> contentDocToDeleteList = new List<Id>();
        contentDocDeleteFinalList = new List<ContentDocument>();
        String linkedEntityId;
        String linkId;
        String fileFullName;
        String contentDocumentId;
        String fullFileExtension;
        list<String> contentDocumentIds;
        for(ContentDocumentLink newLink: documentLinkList){
            system.debug('linkedEntityId >> '+newLink.linkedEntityId);
		  if(CaseDecision.isActive__c){
              if(string.valueOf(newLink.linkedEntityId).startsWithIgnoreCase('500')){
                  ParentIdSet.add(newLink.linkedEntityId);
                  contentDocumentId = newLink.ContentDocumentId;
                  //ntentDocumentIds.add(newLink.ContentDocumentId);
              }   
            }
          if(AccountDecision.isActive__c){
              system.debug('inside account'+newLink.linkedEntityId);
              if(string.valueOf(newLink.linkedEntityId).startsWithIgnoreCase('001')){
                ParentIdSet.add(newLink.linkedEntityId);
                contentDocumentId = newLink.ContentDocumentId;
                //ntentDocumentIds.add(newLink.ContentDocumentId);  
              } 
            }  
            if(ContactDecision.isActive__c){
                if(string.valueOf(newLink.linkedEntityId).startsWithIgnoreCase('003')){
                    ParentIdSet.add(newLink.linkedEntityId);
                    contentDocumentId = newLink.ContentDocumentId;
                   //ontentDocumentIds.add(newLink.ContentDocumentId);
                }
            } 
        }
        if(contentDocumentId != null){
           //Query ContentDocument based on ContentDocumentLink from above
        ContentDocument docObj = [SELECT Id, FileExtension, FileType, ContentSize, Title FROM ContentDocument WHERE Id=:contentDocumentId LIMIT 1]; 
        
        
            if(docObj != null){
                fileFullName = docObj.Title + docObj.FileExtension;
                System.debug('fileFullName: '+ fileFullName);
            }
        }
        //Query all ContentDocumentLink for matching LinkedEntityId and store matching FileName & FileExtension records
        /*List<ContentDocumentLink> contentDocumentLinkList = [SELECT id, LinkedEntityId,LinkedEntity.type, ContentDocumentId, ContentDocument.ContentSize, ContentDocument.FileExtension,  ContentDocument.Title, ContentDocument.LastModifiedDate 
                                                            from ContentDocumentLink 
                                                            WHERE Id != null AND
                                                            LinkedEntityId=:linkedEntityId
                                                            ORDER BY ContentDocument.LastModifiedDate ASC];*/
        //Query all ContentDocumentLink for matching LinkedEntityId and store matching FileName & FileExtension records
       system.debug('ParentIdSet >> '+ParentIdSet);
        String parentIdList = '';
        for (Id parentId : ParentIdSet) {
            parentIdList += '\'' + parentId + '\',';
        }
        
        if (parentIdList.endsWith(',')) {
            parentIdList = parentIdList.removeEnd(',');
        }
        system.debug('parentIdList >> '+parentIdList);
        string objectList='';
        for(String objectName : objectlst) {
            objectList += '\'' + objectName + '\',';
        }
        
        if (objectList.endsWith(',')) {
            objectList = objectList.removeEnd(',');
        } 
        if(!string.isBlank(parentIdList)){
            String dynamicSOQL = 'SELECT ContentDocumentId, ContentDocument.FileType, ContentDocument.FileExtension,ContentDocument.Title, LinkedEntityId ' +
									 'FROM ContentDocumentLink ' +
									 ' WHERE LinkedEntityId IN (' + parentIdList + ') ' +
              						 ' AND LinkedEntity.Type IN (' + objectList + ') ' +
            						 ' AND Id != null '+
									 ' ORDER BY ContentDocument.LastModifiedDate ASC' ;
            
            system.debug('dynamicSOQL >> ' +dynamicSOQL);
            contentDocumentLinkList = database.query(dynamicSOQL);
        }
        
        System.debug('contentDocumentLinkList: '+ contentDocumentLinkList);
        
        for(ContentDocumentLink link: contentDocumentLinkList){
           fullFileExtension = link.LinkedEntityId + link.ContentDocument.Title + link.ContentDocument.FileExtension;
            if(fullFileExtension.contains(fileFullName)){
                //contentDocToDeleteList.add(link.ContentDocumentId);
                if (!FileIdMap.containsKey(fullFileExtension)) {
           			 FileIdMap.put(fullFileExtension, new Set<Id>());
                }
                FileIdMap.get(fullFileExtension).add(link.ContentDocumentId);
              }
        }
		
        for(string Key : FileIdMap.keySet()){
                Set<Id> documentIdSet = FileIdMap.get(key);
                    if(documentIdSet != null && documentIdSet.size() > 0){
                        List<Id> allIdsList = new List<Id>();
                        allIdsList.addAll(documentIdSet);
                        for(Integer index=0; index < allIdsList.size() - 1; index++)
                            contentDocToDeleteList.add(allIdsList[index]); //Store the first ContentDocumentId since thats the oldest one
                    }
         }
        
        System.debug('contentDocToDeleteList: '+ contentDocToDeleteList);
        if(!contentDocToDeleteList.isEmpty()){
            for(Integer i = 0; i < contentDocToDeleteList.size(); i++){
                ContentDocument docTemp = new ContentDocument(Id=contentDocToDeleteList[i]);
                contentDocDeleteFinalList.add(docTemp);
            }    
        }
       
         System.debug('contentDocDeleteFinalList: '+ contentDocDeleteFinalList);
        if(!contentDocDeleteFinalList.isEmpty()){
             
            try{
                if(system.Test.isRunningTest()){
                    system.debug('isRunningTest');
                }else{
                     System.enqueueJob(new BoxCallOut(contentDocDeleteFinalList));  
                }
                                 
            }catch(Exception e){
                system.debug('Error Message '+e.getMessage());
            }
            
        }
    }
}