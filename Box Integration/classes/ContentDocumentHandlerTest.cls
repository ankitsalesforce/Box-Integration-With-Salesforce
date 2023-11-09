@isTest
public class ContentDocumentHandlerTest {

    @isTest
    public static void accDeleteduplicateFile(){
        String ownType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        
        //Account Record
        Account objAcc = new Account(Name='Hello Owner', RecordTypeId = ownType);
        insert objAcc;
        
        
        List<ContentVersion> cvlist = new List<ContentVersion>();
        ContentVersion objCV1 = new ContentVersion( Title = 'Sample File A',PathOnClient = 'sample.pdf',VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert objCV1;
        
        ContentVersion objCV2 = new ContentVersion( Title = 'Sample File A',PathOnClient = 'sample.pdf',VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
  		insert objCV2;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        list<string> contentDocumentLinkList = new  list<string>();
        ContentDocumentLink objCdAcc1 = New ContentDocumentLink();
        objCdAcc1.LinkedEntityId = objAcc.id;  // Account ID added
        objCdAcc1.ContentDocumentId = documents[0].Id;
        objCdAcc1.shareType = 'V';
        objCdAcc1.visibility = 'AllUsers';
        insert objCdAcc1;
        contentDocumentLinkList.add(objCdAcc1.Id);
        
        ContentDocumentLink objCdAcc2 = New ContentDocumentLink();
        objCdAcc2.LinkedEntityId = objAcc.id;  // Account ID added
        objCdAcc2.ContentDocumentId = documents[1].Id;
        objCdAcc2.shareType = 'V';
        objCdAcc2.visibility = 'AllUsers';
        insert objCdAcc2;
        
       
        
        contentDocumentLinkList.add(objCdAcc2.Id);
        list<contentDocumentLink> contentDocumentLinks = [SELECT ID FROM contentDocumentLink WHERE ID IN :contentDocumentLinkList];
        system.assertEquals(2,contentDocumentLinks.size());
        
    }
    
    /*@isTest
    public static void accountContentDocument(){
        String ownType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        
        //Account Record
        Account objAcc = new Account(Name='Hello Owner', RecordTypeId = ownType);
        insert objAcc;
        
        List<ContentVersion> documentsList = [SELECT Id, ContentDocumentId from ContentVersion];
        system.debug('ContentVersionID  //// '+documentsList[0].Id);
        //Content Document Link Record for Account 1 
        
        List<ContentDocumentLink> docuListAccount = new list<ContentDocumentLink>();
       
        
        //Content Document Link Record for Account 2
        ContentDocumentLink objCdAcc2 = New ContentDocumentLink();
        objCdAcc2.LinkedEntityId = objAcc.id;  // Account ID added
        objCdAcc2.ContentDocumentId = documentsList[1].ContentDocumentId;
        objCdAcc2.shareType = 'V';
        objCdAcc2.visibility = 'AllUsers';
        insert objCdAcc2;
        
   		//Run Schedulable Class
        system.Test.startTest();
        ContentDocumentHandler.duplicateFileCheck(new list<ContentDocumentLink> {objCdAcc2});
       system.test.stopTest();        
        
        List<ContentVersion> docList = [SELECT Id, ContentDocumentId,Title from ContentVersion];
        system.debug('docList >> '+docList);
        System.assertEquals(1, docList.size());
        /*System.assertEquals('Sample File A', docList[0].Title);
        System.assertEquals('Sample File B', docList[1].Title);
        System.assertEquals('Sample File C', docList[2].Title);*/
    //}
}