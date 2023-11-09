trigger BoxStatusTrigger on Box_Callout_Status__c (After insert,After Update) {
    
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
            BoxStatusHandler.getDeleteFile(trigger.new);
        }
    }

}