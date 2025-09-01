trigger TaxTrigger on tax__c (before insert) {
    System.debug('Tax__c Trigger Start =>' + Trigger.operationType);

    TaxTriggerHandler handler = new TaxTriggerHandler(
        Trigger.old,
        Trigger.new,
        Trigger.oldMap,
        Trigger.newMap
    );

    if(TaxTriggerHandler.isTriggerEnabled()) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert();
            }            
        }
    }
}