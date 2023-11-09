public class BoxStatusHandler {

    public static void getDeleteFile(list<Box_Callout_Status__c> boxCallOutList){
        
        set<String> SFDCFileIds = new set<String>();
        set<string> boxIdToBeUpdate = new set<String>();
        list<Box_Callout_Status__c> boxToBeUpdate = new list<Box_Callout_Status__c>();
        for(Box_Callout_Status__c box : boxCallOutList){
            if(box.Status_Code__c == 201 && box.Operation_Status__c == 'Copy to BOX'){
                if(box.salesforce_File_Id__c != null){
                    SFDCFileIds.add(box.salesforce_File_Id__c);
                    boxIdToBeUpdate.add(box.Id);
                }
            }
        }
        system.debug('SFDCFileIds' +SFDCFileIds);
        deleteFilesFromSalesforce(SFDCFileIds); //deleting files from salesforce
        list<ContentDocument> filesToBeDeleted = [SELECT Id FROM ContentDocument WHERE ID IN :SFDCFileIds];
        
        system.debug('filesToBeDeleted size >> '+filesToBeDeleted.size());
        if(filesToBeDeleted.size() == 0){
            for(Box_Callout_Status__c box : [SELECT ID,Status_Code__c,Operation_Status__c,salesforce_File_Id__c FROM Box_Callout_Status__c 
                                             WHERE ID IN:boxIdToBeUpdate]){
                   if(box.Operation_Status__c == 'Copy to BOX' ){
                        box.Operation_Status__c = 'Deleted From Salesforce';   
                       	boxToBeUpdate.add(box);
					}
            }
        }
        system.debug('boxToBeUpdate size >> '+boxToBeUpdate.size());
        system.debug('boxToBeUpdate >> '+boxToBeUpdate);
        if(boxToBeUpdate.size()>0){
            try{
                update boxToBeUpdate;
            }catch(Exception e){
                system.debug('Error in box status Update '+e.getMessage());
            }
        }
    }
    
    public static void deleteFilesFromSalesforce(set<String> SFDCFileIds){
        list<ContentDocument> filesToBeDeleted = [SELECT Id FROM ContentDocument WHERE ID IN :SFDCFileIds];
        
        if(filesToBeDeleted.size()>0){
            try{
            Delete filesToBeDeleted;
            filesToBeDeleted.clear();    
        }Catch(Exception e){
            system.debug('Error in deleting files '+e.getMessage());
            system.debug('Error in deleting files at line Number '+e.getLineNumber());
        	}
        } 
        
        
        system.debug('filesToBeDeleted size >> '+filesToBeDeleted.size());
    }

}