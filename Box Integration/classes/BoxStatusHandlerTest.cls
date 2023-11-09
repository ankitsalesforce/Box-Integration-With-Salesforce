@isTest
public class BoxStatusHandlerTest {
    
    @isTest
    public static void getBoxstatusHandler(){
        ContentVersion objCV1 = new ContentVersion( Title = 'Sample File A',PathOnClient = 'sample.pdf',VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert objCV1;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Box_Callout_Status__c boxstatus = new Box_Callout_Status__c();
        boxstatus.Name='test';
        boxstatus.Status_Code__c = 201;
        boxstatus.Operation_Status__c = 'Copy to BOX';
        boxstatus.salesforce_File_Id__c = documents[0].Id;
        insert boxstatus;
        
        boxstatus.Operation_Status__c = 'Deleted From Salesforce';
        Update boxstatus;
    }

}