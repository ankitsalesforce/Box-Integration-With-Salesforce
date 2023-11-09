@IsTest
public class BoxApiCalloutTest {

    @IsTest
    public static void test_folderInfo(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;

        System.Test.setMock(HttpCalloutMock.Class, new BoxApiMockCallout());
        System.Test.startTest();
            BoxApiCallout.folderInfo(parentAccount2.Id);
            BoxApiCallout.folderInfo(testCase.Id);
            BoxApiCallout.downloadBoxFile(testCase.Id);
        System.Test.stopTest();
    }

    @IsTest
    public static void test_folderCreate(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;

        System.Test.setMock(HttpCalloutMock.Class, new BoxAccountApiMockCallout());
        System.Test.startTest();
           BoxApiCallout.folderCreate('Test');
        System.Test.stopTest();
    }

    @IsTest
    public static void test_AccountfolderCreate(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;

        System.Test.setMock(HttpCalloutMock.Class, new BoxCaseApiMockCallout());
        System.Test.startTest();
           BoxApiCallout.folderCreate('Test');
        System.Test.stopTest();
    }

    @IsTest
    public static void test_ContactfolderCreate(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;

        System.Test.setMock(HttpCalloutMock.Class, new BoxContactApiMockCallout());
        System.Test.startTest();
           BoxApiCallout.folderCreate('Test');
        System.Test.stopTest();
    }

    @isTest
    public static void test_uploadFileToBox_201(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;

        System.Test.setMock(HttpCalloutMock.Class, new BoxMultiFileUploadApiMockCallout_201());
        System.Test.startTest();
            map<string,list<string>> fileNameWithBase64data = new map<string,list<string>>();
            fileNameWithBase64data.put('Test', new List<String>{'Test'});
            String FolderId = 'Test';
            String fileBody = 'Test';
            map<String,list<String>> fileNamewithParent = new map<string,list<string>>();
            fileNamewithParent.put('Test', new List<String>{'Test'});
            map<String,String> FileIdWithLabel = new map<String,String>();
            FileIdWithLabel.put('Test', 'Test');
            BoxApiCallout.uploadFileToBox(fileNameWithBase64data, FolderId, fileBody,fileNamewithParent,FileIdWithLabel);
        System.Test.stopTest();
    }

    @isTest
    public static void test_uploadFileToBox_409(){
        // Create test data - Account and Case records
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;

        System.Test.setMock(HttpCalloutMock.Class, new BoxMultiFileUploadApiMockCallout_409());
        System.Test.startTest();
            map<string,list<string>> fileNameWithBase64data = new map<string,list<string>>();
            fileNameWithBase64data.put('Test', new List<String>{'Test'});
            String FolderId = 'Test';
            String fileBody = 'Test';
            map<String,list<String>> fileNamewithParent = new map<string,list<string>>();
            fileNamewithParent.put('Test', new List<String>{'Test'});
            map<String,String> FileIdWithLabel = new map<String,String>();
            FileIdWithLabel.put('Test', 'Test');
            BoxApiCallout.uploadFileToBox(fileNameWithBase64data, FolderId, fileBody,fileNamewithParent,FileIdWithLabel);
        System.Test.stopTest();
    }

    public class BoxApiMockCallout implements HttpCalloutMock{
    
        public HTTPResponse respond(HTTPRequest req){
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
        }
    }

    public class BoxAccountApiMockCallout implements HttpCalloutMock{
    
        public HTTPResponse respond(HTTPRequest req){
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Map<String, String> requestMap = new map<String, String>();
        requestMap.put('id','test');
        requestMap.put('name', parentAccount2.Id);
        res.setBody(System.JSON.serialize(requestMap));
        res.setStatusCode(200);
        return res;
        }
    } 

    public class BoxCaseApiMockCallout implements HttpCalloutMock{
    
        public HTTPResponse respond(HTTPRequest req){
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        
        Case testCase = new Case(
            Property_Name__c = testAccount.Id,
            AccountId = testAccount.Id,
            Location__c = testAccount.Id
        );
        insert testCase;
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Map<String, String> requestMap = new map<String, String>();
        requestMap.put('id','test');
        requestMap.put('name', testCase.Id);
        res.setBody(System.JSON.serialize(requestMap));
        res.setStatusCode(200);
        return res;
        }
    } 

    public class BoxContactApiMockCallout implements HttpCalloutMock{
    
        public HTTPResponse respond(HTTPRequest req){
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        Contact con=new Contact(FirstName='Test1', AccountId=testAccount.Id,LastName='Test2', Email='test@gmail.com',Phone='1234567890');
        insert con;

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Map<String, String> requestMap = new map<String, String>();
        requestMap.put('id','test');
        requestMap.put('name', con.Id);
        res.setBody(System.JSON.serialize(requestMap));
        res.setStatusCode(200);
        return res;
        }
    } 

    public class BoxMultiFileUploadApiMockCallout_201 implements HttpCalloutMock{
    
        public HTTPResponse respond(HTTPRequest req){
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        Contact con=new Contact(FirstName='Test1', AccountId=testAccount.Id,LastName='Test2', Email='test@gmail.com',Phone='1234567890');
        insert con;
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Map<String, String> requestMap = new map<String, String>();
        requestMap.put('id','test');
        requestMap.put('name', con.Id);
        res.setBody('{"entries":[{"name":"Test","parent":{"name":"Test","id":"Test"}}]}');
        res.setStatusCode(201);
        return res;
        }
    }

    public class BoxMultiFileUploadApiMockCallout_409 implements HttpCalloutMock{
    
        public HTTPResponse respond(HTTPRequest req){
        Account parentAccount2 = new Account(Name = 'Test Account', Box_Folder_Id__c='12345');
        insert parentAccount2;
        Account parentAccount = new Account(Name = 'Test Account',parentId = parentAccount2.Id,Owner_2__c=parentAccount2.Id);
        insert parentAccount;
        Account testAccount = new Account(Name = 'Test Account',parentId = parentAccount.Id,Owner_2__c=parentAccount.Id);
        insert testAccount;
        Contact con=new Contact(FirstName='Test1', AccountId=testAccount.Id,LastName='Test2', Email='test@gmail.com',Phone='1234567890');
        insert con;
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Map<String, String> requestMap = new map<String, String>();
        requestMap.put('id','test');
        requestMap.put('name', con.Id);
        res.setBody('{"context_info":{"conflicts":{"name":"Test"}}}');
        res.setStatusCode(409);
        return res;
        }
    }   
}