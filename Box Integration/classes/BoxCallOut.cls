public class BoxCallOut implements Queueable,Database.AllowsCallouts{
    
    public list<contentDocument> contentList;
    
    @testVisible
    private static Boolean doChainJob = true;
    
    public BoxCallOut(list<contentDocument> contentList){
        this.contentList = contentList;
    }
    
    public void execute(QueueableContext context){
        set<Id> contentId = new set<Id>();
        set<Id> linkedEntityIds = new set<Id>();
        List<String> bodyList = new List<String>();
        set<Id> caseList = new set<Id>();
        set<Id> accountList = new set<Id>();
        set<Id> contactList = new set<Id>();
        list<Case> cslst  = new  list<Case>(); 
        list<Account> Accountlst  = new  list<Account>(); 
        list<Contact> Contactlst  = new  list<Contact>(); 
        list<string> base64Datalist = new list<string> ();
        
        for(contentDocument content : contentList){
            contentId.add(content.Id);
        }
        list<contentDocumentLink> contentLink = [SELECT ID,linkedEntityId,contentDocumentId FROM contentDocumentLink 
                                                 WHERE contentDocumentId IN :contentId];
        list<contentVersion> contentVer = [SELECT ID,VersionData,ContentDocumentId  FROM contentVersion WHERE ContentDocumentId  IN :contentId];
        system.debug('contentVer in folderCreate '+contentVer);
        for(contentDocumentLink link : contentLink){
            linkedEntityIds.add(Link.linkedEntityId);
        }
        
        if(!linkedEntityIds.isEmpty()){
            for(Id recordId : linkedEntityIds){
                String folderName = String.valueOf(recordId);
                
                if(folderName.startsWithIgnoreCase('500')){
                    caseList.add(recordId); 
                }//case obj
                
              if(folderName.startsWithIgnoreCase('001')){
                    accountList.add(recordId); 
                }//Account obj
                
                if(folderName.startsWithIgnoreCase('003')){
                    contactList.add(recordId); 
                }//Contact obj
                
            }
        }
        
        if(!caseList.isEmpty()){
             cslst = [SELECT Id,Box_Folder_Id__c FROM Case WHERE ID IN:caseList];
        }
        
        if(!accountList.isEmpty()){
             Accountlst = [SELECT Id,Box_Folder_Id__c FROM Account WHERE ID IN:accountList];
        }
        
        if(!contactList.isEmpty()){
             Contactlst = [SELECT Id,Box_Folder_Id__c FROM Contact WHERE ID IN:contactList];
        }
        
        
        if(!cslst.isEmpty()){
            string caseBoxFolder;
            string caseId;
           for(case cs : cslst){
                caseBoxFolder = cs.Box_Folder_Id__c;
                caseId = cs.Id;
                     if(caseBoxFolder != null){
                         system.debug('existing box folder');
                        
                    }//existing box folder 
                    else{
                        system.debug('creating new box folder');
                        String folderBody = 
                                            '"name": "' + caseId + '",' +
                                            '"parent": {' +
                                                '"id": "0"' +
                                            '}';
                                        
                            bodyList.add(folderBody); 
                    }//creating new box folder 
                        
            }
        }
        
        if(!Accountlst.isEmpty()){
           string accountBoxFolder;
           string AccountId;
           for(Account acc : Accountlst){
                accountBoxFolder = acc.Box_Folder_Id__c;
                AccountId = acc.Id;
                     if(accountBoxFolder != null){
                         system.debug('existing box folder');
                        
                    }//existing box folder 
                    else{
                        system.debug('creating new box folder');
                        String folderBody = 
                                            '"name": "' + AccountId + '",' +
                                            '"parent": {' +
                                                '"id": "0"' +
                                            '}';
                                        
                            bodyList.add(folderBody); 
                    }//creating new box folder 
                        
            }
        }  
        
        if(!Contactlst.isEmpty()){
           string contactBoxFolder;
           string ContactId;
           for(Contact con : Contactlst){
                contactBoxFolder = con.Box_Folder_Id__c;
                ContactId = con.Id;
                     if(contactBoxFolder != null){
                         system.debug('existing box folder');
                        
                    }//existing box folder 
                    else{
                        system.debug('creating new box folder');
                        String folderBody = 
                                            '"name": "' + ContactId + '",' +
                                            '"parent": {' +
                                                '"id": "0"' +
                                            '}';
                                        
                            bodyList.add(folderBody); 
                    }//creating new box folder 
                        
            }
        }  
        
        String finalBody =  '{'+String.join(bodyList, ',')+'}';
        system.debug('finalBody >> ' +finalBody);
        if(finalBody != '{}' && finalBody != null){
            system.debug('inside finalBody');
            BoxApiCallout.folderCreate(finalBody); //calling folder create callout
        }
        system.debug('contentVer at 71 line folderCreate '+contentVer);
        
        if(doChainJob) {
             system.enqueueJob(new BoxFileUploadCallout(contentList));
        }
       
	}

}