public class BoxFileUploadCallout implements Queueable,Database.AllowsCallouts{
    Public list<contentDocument> contentList;
    public list<Case> cslst;
    public string filename;
    Public String folderId;
    public BoxFileUploadCallout(list<contentDocument>contentList){
        this.contentList = contentList;
        
    }
    
    public void execute(QueueableContext context){
        //we are going to upload new file to box if duplicates files are there into parentId
        //https://support.box.com/hc/en-us/community/posts/360049139294-How-to-upload-multiple-files-in-single-request-
        set<Id> contentId = new set<Id>();
        for(contentDocument content : contentList){
            contentId.add(content.Id);
        }
        map<String,list<String>> fileParentMap = new  map<String,list<String>>();
        map<String,blob> fileVersionMap = new  map<String,blob>();
        map<String,list<String>> fileNamewithParent = new  map<String,list<String>>();
        map<String,String> FileIdWithLabel = new  map<String,String>();
        map<string,list<string>> fileNameWithBase64data = new map<string,list<string>>();
        list<String> fileBody = new list<String>();
        list<Id> parentIds = new list<Id>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        list<string> base64Datalist = new list<string> ();
        list<String> fileLabels = new list<String>();
        
        if(!contentList.isEmpty()){
            list<contentDocumentLink> contentLink = [SELECT ID,linkedEntityId,contentDocumentId,SystemModstamp,contentDocument.Title,contentDocument.FileExtension FROM contentDocumentLink 
                                                 WHERE contentDocumentId IN :contentId order by SystemModstamp DESC];
            system.debug('contentLink >> ' +contentLink);
            system.debug('contentLink >> ' +contentLink.size());
			
            list<contentVersion> conVersionData = [SELECT ID,VersionData,ContentDocumentId  FROM contentVersion 
                                                   WHERE ContentDocumentId  IN :contentId];
        	system.debug('contentVer in folderCreate '+conVersionData);
            system.debug('contentVer size '+conVersionData.size());
            
            for(contentDocumentLink link : contentLink){
               string ParentId = link.linkedEntityId;
                if(ParentId.startsWithIgnoreCase('500') || ParentId.startsWithIgnoreCase('003') || ParentId.startsWithIgnoreCase('001')){
                     if (!fileParentMap.containsKey(link.linkedEntityId)) {
                        fileParentMap.put(link.linkedEntityId, new List<String>());
                    }
                     ParentIds.add(link.linkedEntityId);
                     fileParentMap.get(link.linkedEntityId).add(link.contentDocumentId); //storing parentId with files Id
                    
                     String fileLabel = link.contentDocument.Title+'.'+link.contentDocument.FileExtension;
                 	 fileLabels.add(fileLabel);
					 
					 if(!fileNamewithParent.containsKey(link.linkedEntityId)){
						fileNamewithParent.put(link.linkedEntityId,new list<String>());
					}
                   
					if(fileLabels.contains(fileLabel)){
						Datetime systemModstampDatetime = link.SystemModstamp;
						String formattedDateString = systemModstampDatetime.format('MM_dd_yyyy_HH_mm_ss');
						fileLabel = link.contentDocument.Title+'_'+formattedDateString+'.'+link.contentDocument.FileExtension;
					}//duplicate file
                    

                   
				system.debug('fileLabel >> ' +fileLabel);
				fileNamewithParent.get(link.linkedEntityId).add(fileLabel); //storing parentId with updated file label
             	FileIdWithLabel.put(fileLabel,link.ContentDocumentId); //storing FileId with updated file label
			 }
            } //storing parentId with theirs contentDocument
            
			for(contentVersion version : conVersionData){
                fileVersionMap.put(version.contentDocumentId,version.versionData);
            }
			
			if(!parentIds.isEmpty()){
				for(String str : parentIds){
					if(str.startsWithIgnoreCase('500')){
						caseIds.add(str);
					}//case obj
                    
                    if(str.startsWithIgnoreCase('001')){
						accountIds.add(str);
					}//account obj
                    
                    if(str.startsWithIgnoreCase('003')){
						contactIds.add(str);
					}//contact obj
				}
			}
			system.debug('caseId >> '+caseIds);
            system.debug('accountIds >> '+accountIds);
            system.debug('contactIds >> '+contactIds);
            
        if(!caseIds.isEmpty()){
			list<case> caselist = [SELECT ID,Box_Folder_Id__c FROM Case WHERE ID IN:caseIds];
            system.debug('caselist'+caselist);
            For(case cs : caselist){
				string folderBody;
                string folderName = cs.Id;
                folderId = cs.Box_Folder_Id__c;
                this.folderId = folderId;
				
				//converting all versionData To base64
				 if(fileParentMap.containsKey(cs.Id)){
                    list<string> caseContentDocId = fileParentMap.get(cs.Id);
                    for(string csContent : caseContentDocId){
                        if(fileVersionMap.containsKey(csContent)){
                            system.debug('contentDocId >> ' +csContent);
                            String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(csContent));
                            base64Datalist.add(base64Data);
                        }
                        
                    }
                }
				
				//forming body
				 if(fileNamewithParent.containsKey(cs.Id)){
                    list<string> filenamelst = fileNamewithParent.get(cs.Id);
                    for(string fileNameStr : filenamelst){
                        if(folderId != null){
                     		folderBody = '"name": "' + fileNameStr + '",' +
                                                '"parent": {' +
                                                    '"id": "' + folderId + '"' +
                                                '}';
                		}
                         //existing folder
                		fileBody.add(folderBody);
                    }
                }
				
				//fileNamewithParent => caseId with fileName
				//fileParentMap => caseId with file Id
				//fileVersionMap => file Id with versionData
				
				if(fileParentMap.containsKey(cs.Id) || fileNamewithParent.containsKey(cs.Id) ){
					list<string> fileIds = fileParentMap.get(cs.Id);
                    list<string> filesName = fileNamewithParent.get(cs.Id);
					if(!fileIds.isEmpty()){
						for(string str : fileIds){
							String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(str));
							fileNameWithBase64data.put(base64Data,new list<string>());
                            fileNameWithBase64data.get(base64Data).addAll(filesName);
						}
					}
				}
				
			}
		}
        
        if(!accountIds.isEmpty()){
			list<Account> accountlist = [SELECT ID,Box_Folder_Id__c FROM Account WHERE ID IN:accountIds];
            system.debug('accountlist'+accountlist);
            For(Account acc : accountlist){
				string folderBody;
                string folderName = acc.Id;
                folderId = acc.Box_Folder_Id__c;
                this.folderId = folderId;
				
				//converting all versionData To base64
				 if(fileParentMap.containsKey(acc.Id)){
                    list<string> caseContentDocId = fileParentMap.get(acc.Id);
                    for(string csContent : caseContentDocId){
                        if(fileVersionMap.containsKey(csContent)){
                            system.debug('contentDocId >> ' +csContent);
                            String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(csContent));
                            base64Datalist.add(base64Data);
                        }
                        
                    }
                }
				
				//forming body
				 if(fileNamewithParent.containsKey(acc.Id)){
                    list<string> filenamelst = fileNamewithParent.get(acc.Id);
                    for(string fileNameStr : filenamelst){
                        if(folderId != null){
                     		folderBody = '"name": "' + fileNameStr + '",' +
                                                '"parent": {' +
                                                    '"id": "' + folderId + '"' +
                                                '}';
                		}
                         //existing folder
                		fileBody.add(folderBody);
                    }
                }
				
				//fileNamewithParent => caseId with fileName
				//fileParentMap => caseId with file Id
				//fileVersionMap => file Id with versionData
				
				if(fileParentMap.containsKey(acc.Id) || fileNamewithParent.containsKey(acc.Id) ){
					list<string> fileIds = fileParentMap.get(acc.Id);
                    list<string> filesName = fileNamewithParent.get(acc.Id);
					if(!fileIds.isEmpty()){
						for(string str : fileIds){
							String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(str));
							fileNameWithBase64data.put(base64Data,new list<string>());
                            fileNameWithBase64data.get(base64Data).addAll(filesName);
						}
					}
				}
				
			}
		}
            
        if(!contactIds.isEmpty()){
			list<Contact> contactlist = [SELECT ID,Box_Folder_Id__c FROM Contact WHERE ID IN:contactIds];
            system.debug('contactlist'+contactlist);
            For(Contact con : contactlist){
				string folderBody;
                string folderName = con.Id;
                folderId = con.Box_Folder_Id__c;
                this.folderId = folderId;
				
				//converting all versionData To base64
				 if(fileParentMap.containsKey(con.Id)){
                    list<string> caseContentDocId = fileParentMap.get(con.Id);
                    for(string csContent : caseContentDocId){
                        if(fileVersionMap.containsKey(csContent)){
                            system.debug('contentDocId >> ' +csContent);
                            String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(csContent));
                            base64Datalist.add(base64Data);
                        }
                        
                    }
                }
				
				//forming body
				 if(fileNamewithParent.containsKey(con.Id)){
                    list<string> filenamelst = fileNamewithParent.get(con.Id);
                    for(string fileNameStr : filenamelst){
                        if(folderId != null){
                     		folderBody = '"name": "' + fileNameStr + '",' +
                                                '"parent": {' +
                                                    '"id": "' + folderId + '"' +
                                                '}';
                		}
                         //existing folder
                		fileBody.add(folderBody);
                    }
                }
				
				//fileNamewithParent => caseId with fileName
				//fileParentMap => caseId with file Id
				//fileVersionMap => file Id with versionData
				
				if(fileParentMap.containsKey(con.Id) || fileNamewithParent.containsKey(con.Id) ){
					list<string> fileIds = fileParentMap.get(con.Id);
                    list<string> filesName = fileNamewithParent.get(con.Id);
					if(!fileIds.isEmpty()){
						for(string str : fileIds){
							String base64Data = EncodingUtil.base64Encode(fileVersionMap.get(str));
							fileNameWithBase64data.put(base64Data,new list<string>());
                            fileNameWithBase64data.get(base64Data).addAll(filesName);
						}
					}
				}
				
			}
		}    
            
        String finalBody =  '{'+String.join(fileBody, ',')+'}';
        system.debug('finalBody >> ' +finalBody);
        system.debug('fileNameWithBase64data >> ' +fileNameWithBase64data);
         system.debug('fileNameWithBase64data size>> ' +fileNameWithBase64data.size());
        system.debug('folderId >> ' +folderId);
            if(system.Test.isRunningTest()){
                system.debug('isRunningTest');
            }else{
                BoxApiCallout.uploadFileToBox(fileNameWithBase64data,folderId,finalBody,fileNamewithParent,FileIdWithLabel);
            }    
        
	}
}
    }