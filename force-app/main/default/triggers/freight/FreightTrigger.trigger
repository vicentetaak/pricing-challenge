trigger FreightTrigger on freight__c (before insert) {
    System.debug('Freight__c Trigger Start =>' + Trigger.operationType);

    FreightTriggerHandler handler = new FreightTriggerHandler(
        Trigger.old,
        Trigger.new,
        Trigger.oldMap,
        Trigger.newMap
    );

    if(FreightTriggerHandler.isTriggerEnabled()) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert();
            }            
        }
    }
}