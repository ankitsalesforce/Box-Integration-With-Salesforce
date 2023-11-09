trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    
    if(system.isBatch()){
        return;
    }else{
       If(trigger.isAfter){
        if(trigger.isInsert){
             ContentDocumentHandler.duplicateFileCheck(Trigger.New); 
        }
      } 
    }
    
	//Trigger_Fire_Decision__mdt AccountDecision = Trigger_Fire_Decision__mdt.getInstance('Account'); 
   // Trigger_Fire_Decision__mdt ContactDecision = Trigger_Fire_Decision__mdt.getInstance('Contact');
    //Trigger_Fire_Decision__mdt CaseDecision = Trigger_Fire_Decision__mdt.getInstance('Case');
    
    // Check if isActive is true for AccountDecision
    /*if (AccountDecision != null && AccountDecision.isActive__c) {
        ContentDocumentHandler.duplicateFileCheck(Trigger.New); 
    }
    
    // Check if isActive is true for ContactDecision
    if (ContactDecision != null && ContactDecision.isActive__c) {
        ContentDocumentHandler.duplicateFileCheck(Trigger.New); 
    }
    
    // Check if isActive is true for CaseDecision
    if (CaseDecision != null && CaseDecision.isActive__c) {
        ContentDocumentHandler.duplicateFileCheck(Trigger.New); 
    }*/
}