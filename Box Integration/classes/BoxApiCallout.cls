public class BoxApiCallout {
    
    @AuraEnabled
    public static string folderInfo(string recordId){
        system.debug('folderId >> ' +recordId);
        string folderId;
        if(recordId.startswithIgnorecase('500')){
           folderId = [SELECT Box_Folder_Id__c FROM Case WHERE ID=:recordId LIMIT 1].Box_Folder_Id__c; 
        }
        if(recordId.startswithIgnorecase('001')){
           folderId = [SELECT Box_Folder_Id__c FROM Account WHERE ID=:recordId LIMIT 1].Box_Folder_Id__c; 
        }
         if(recordId.startswithIgnorecase('003')){
           folderId = [SELECT Box_Folder_Id__c FROM Contact WHERE ID=:recordId LIMIT 1].Box_Folder_Id__c; 
        }
        
        if(!string.isBlank(folderId)){
             //folder creation with recordId
            HttpRequest request=new HttpRequest();
            request.setEndpoint('callout:Box_Connect/2.0/folders/'+folderId); 
            request.setMethod('GET');
            //request.setHeader('Authorization', 'Bearer ' + authToken);
            //request.setBody(finalBody);
            
            Http p = new Http();
            HttpResponse response = p.send(request);
            System.debug(System.LoggingLevel.ERROR, response.getStatusCode());
            System.debug(System.LoggingLevel.ERROR, response.getStatus());
            System.debug(System.LoggingLevel.ERROR, response.getBody());
            
            string result = response.getBody();
            system.debug('folder info response >> ' +result);
            return result;
        }
        return '';
        
    }

    @AuraEnabled
    public static string downloadBoxFile(string fileId){
        system.debug('fileId >> '+fileId);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'callout:Box_Connect/2.0/files/';
        endPointValue=endPointValue+fileId+'/content';
        req.setEndpoint(endPointValue);
        req.setMethod('GET');
       
        //req.setHeader('Authorization', 'Bearer '+bparser.access_token);
        HttpResponse res = h.send(req);
        System.debug(System.LoggingLevel.ERROR, res.getStatusCode());
        System.debug(System.LoggingLevel.ERROR, res.getStatus());
         

        // If it's not a redirection, you can handle the response as usual
        System.debug(System.LoggingLevel.ERROR, res.getBody());
        return res.getHeader('location');
    }
    
    public static void folderCreate(string finalBody){
        system.debug('finalBody >> ' +finalBody);
         //folder creation with recordId
        HttpRequest request=new HttpRequest();
        request.setEndpoint('callout:Box_Connect/2.0/folders'); 
        request.setMethod('POST');
        //request.setHeader('Authorization', 'Bearer ' + authToken);
        request.setBody(finalBody);
        
        Http p = new Http();
        HttpResponse response = p.send(request);
        System.debug(System.LoggingLevel.ERROR, response.getStatusCode());
        System.debug(System.LoggingLevel.ERROR, response.getStatus());
        System.debug(System.LoggingLevel.ERROR, response.getBody());
        
        string result = response.getBody();
        String folderId;
		String folderName;
        // Parse the JSON data
        Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        // Extract the 'id' and 'name' fields
        folderId = (String) jsonData.get('id');
        folderName = (String) jsonData.get('name');
        

        // Now, you have the 'id' and 'name' values in the folderId and folderName variables
        System.debug('Folder ID: ' + folderId);
        System.debug('Folder Name: ' + folderName);
        
        if(folderName != null){
            if(folderName.startsWithIgnoreCase('500')){
                case cs = new case();
                cs.Id = Id.valueOf(folderName);
                cs.Box_Folder_Id__c = folderId;
                try{
                    update cs;
                }
                catch(Exception e){
                    system.debug('error on case update ' +e.getMessage());
                }
           }//storing case box folder Id
            
           if(folderName.startsWithIgnoreCase('001')){
                Account acc = new Account();
                acc.Id = Id.valueOf(folderName);
                acc.Box_Folder_Id__c = folderId;
                try{
                    update acc;
                }
                catch(Exception e){
                    system.debug('error on case update ' +e.getMessage());
                }
           }//storing Account box folder Id
            
           if(folderName.startsWithIgnoreCase('003')){
                Contact con = new Contact();
                con.Id = Id.valueOf(folderName);
                con.Box_Folder_Id__c = folderId;
                try{
                    update con;
                }
                catch(Exception e){
                    system.debug('error on case update ' +e.getMessage());
                }
           }//storing Contact box folder Id 
        } 
       if(folderName != null){
        		Box_Callout_Status__c status = new Box_Callout_Status__c();
                status.Name = folderName;
                status.Box_FolderId__c = folderId;
           		status.Status_Code__c = response.getStatusCode();
                if(response.getStatusCode() == 201){
                   status.Operation_Status__c = 'Created Folder';
                }else{
                    status.Error__c = response.getStatus();
                }
        try{
            insert status;
        }catch(Exception e){
            system.debug('error to create box status record');
        }
       }
    }

    public static void uploadFileToBox(map<string,list<string>> fileNameWithBase64data,String FolderId,String fileBody,map<String,list<String>> fileNamewithParent,map<String,String> FileIdWithLabel){
        List<HttpRequest> requests = new List<HttpRequest>();
        for(string base64 : fileNameWithBase64data.keySet()){
           	    List<String> fileNamelist = fileNameWithBase64data.get(base64);
            for(integer i=0;i<fileNamelist.size();i++){
                blob base64EncodeFile = BoxController.base64EncodeFileContent(EncodingUtil.base64Decode(base64), fileNamelist[i]);
            	String uploadEndPointURL='callout:Box_FileUpload/api/2.0/files/content?parent_id='+FolderId;
                String boundary = '----------------------------741e90d31eff';
                String body = fileBody;
                HttpRequest req = new HttpRequest();
                req.setBody(body);
                req.setBodyAsBlob(base64EncodeFile);
                req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
                //req.setHeader('Authorization', 'Bearer ' + accessToken);
                req.setMethod('POST');
                req.setEndpoint(uploadEndPointURL);
                req.setTimeout(120000);
                requests.add(req);
            }
        }
        List<HttpResponse> responses = new List<HttpResponse>();
        // Send the requests and capture the responses
            for (HttpRequest request : requests) {
                HttpResponse response = new Http().send(request);
                responses.add(response);
            }
        	System.debug(System.LoggingLevel.ERROR, responses[0].getStatusCode());
            System.debug(System.LoggingLevel.ERROR, responses[0].getStatus());
            System.debug(System.LoggingLevel.ERROR, responses[0].getBody());
        
       
        if(!responses.isEmpty()){
            list<string> BoxfolderIds = new list<string>();
            map<string,list<string>> parentIdwithFileName = new map<string,list<string>>();
            list<string> salesforceFileId = new list<String>();
            list<String> ParentIds = new List<String>();
            
            list<Box_Callout_Status__c> boxstageToBeUpdate = new list<Box_Callout_Status__c>();
            for(HttpResponse res : responses){
                system.debug('response in box upload >> ' +res);
            	 String result = res.getBody();
                 system.debug('response Body >> ' +result);
                 String FolderResId;
                 String fileName;
                 String parentId;
                 String parentFolderId;
                 String SFDCfileId;
                // Parse the JSON data
             Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(result);
            
              if(res.getStatusCode() == 201){
                // Check if the payload contains the "entries" key
                if (payload.containsKey('entries')) {
                    List<Object> entries = (List<Object>) payload.get('entries');
                    
                    for (Object entry : entries) {
                        Map<String, Object> fileEntry = (Map<String, Object>) entry;
                        String entryName = (String) fileEntry.get('name');
                        system.debug('entryName >> ' +entryName);
                        Map<String, Object> entryMap = (Map<String, Object>) entry;
                        // Access the "parent" object within each entry
                        Map<String, Object> parent = (Map<String, Object>) entryMap.get('parent');
                        // Loop through the entries to find the file with the desired name
                        // Access the "name" value from the "parent" object
                        parentId = (String) parent.get('name');
                        parentFolderId = (String) parent.get('id');
                        BoxfolderIds.add(parentFolderId);
                        parentIdwithFileName.put(parentId,new list<string>());
                        system.debug('parentName >> ' +parentId);
                        system.debug('folderId >> ' +folderId);
                        parentIdwithFileName.get(parentId).add(entryName);
                        }
                    }
                system.debug('parentIdwithFileName >> ' +parentIdwithFileName); //containing parentId with FileName
                system.debug('parentName >> ' +parentId);
               
                     system.debug('201 status');
                     if(parentIdwithFileName.containsKey(parentId)){
                         list<String> successFileName = parentIdwithFileName.get(parentId);
                         system.debug('inside box stage Update');
                         for(string fileStr : successFileName){
                             system.debug('fileID in box stage Update >> ' +fileStr);
                             Box_Callout_Status__c status = new Box_Callout_Status__c();
                             status.Name = parentId;
                             status.Box_FolderId__c = parentFolderId;
                             status.salesforce_File_Id__c = FileIdWithLabel.get(fileStr);
                             status.Status_Code__c = res.getStatusCode();
                             status.Operation_Status__c = 'Copy to BOX';
                             //status.Error__c = res.getStatus();
                             boxstageToBeUpdate.add(status);
                         }
                	}
               system.debug('boxstageToBeUpdate at 201 >>' +boxstageToBeUpdate.size());
              }
              if(res.getStatusCode() == 409){
                      system.debug('409 status');
                      string ExistingFilename;
                
                      Set<String> matchingKeys = new Set<String>();
                      if (payload.containsKey('context_info')) {
                            Map<String, Object> contextInfo = (Map<String, Object>) payload.get('context_info');
                        
                            if (contextInfo.containsKey('conflicts')) {
                                Map<String, Object> conflicts = (Map<String, Object>) contextInfo.get('conflicts');
                        
                                if (conflicts.containsKey('name')) {
                                    ExistingFilename = (String) conflicts.get('name');
                                    
                                }
                                system.debug('ExistingFilename >> '+ExistingFilename);
                               
                                for(string key : fileNamewithParent.keySet()){
                                    List<String> values = fileNamewithParent.get(key);
                                    if (values.contains(ExistingFilename)) {
                                         matchingKeys.add(key);
                                           
                                      }
                                }
                                system.debug('matching Parent ID >> '+matchingKeys);
                                system.debug('FileIdWithLabel >> ' +FileIdWithLabel);
                                //FileIdWithLabel => fileId and fileLabel
                                for(string str : matchingKeys){
                                    system.debug('existed file Id >>' +FileIdWithLabel.get(ExistingFilename));
                                     Box_Callout_Status__c status = new Box_Callout_Status__c();
                                     status.Name = str;
                                     status.Box_FolderId__c = '';
                                     status.salesforce_File_Id__c = FileIdWithLabel.get(ExistingFilename);
                                     status.Status_Code__c = res.getStatusCode();
                                     status.Error__c = res.getStatus();
                                     boxstageToBeUpdate.add(status);
                                }
                            }
                        }
                       system.debug('boxstageToBeUpdate at 409 >>' +boxstageToBeUpdate.size());
                  }
                
                if(res.getStatusCode() != 201 || res.getStatusCode() != 409){
                    String message;
                    if (payload.containsKey('context_info')) {
                         Map<String, Object> contextInfo = (Map<String, Object>) payload.get('context_info');
                         if (contextInfo.containsKey('message')) {
                            message = (String) contextInfo.get('message');
                            System.debug('Message inside context_info: ' + message);
                        }
                        String requestId = (String) payload.get('request_id');
                         Box_Callout_Status__c status = new Box_Callout_Status__c();
                    	 status.Name = requestId;
                     	 status.Box_FolderId__c = '';
                         status.salesforce_File_Id__c = '';
                         status.Status_Code__c = res.getStatusCode();
                         status.Error__c = message;
                         boxstageToBeUpdate.add(status);
                    }
                    				
                }
            }
            
            system.debug('Total boxstageToBeUpdate >>' +boxstageToBeUpdate.size());
                if(boxstageToBeUpdate.size()> 0){
                    try{
                        Insert boxstageToBeUpdate;
                        }catch(Exception e){
                            system.debug('Error occure in box stage update '+e.getMessage());
                            system.debug('Error occure in box stage update at line '+e.getLineNumber());
                        }
                    }
            
        }
        
      
    }
   
    
}