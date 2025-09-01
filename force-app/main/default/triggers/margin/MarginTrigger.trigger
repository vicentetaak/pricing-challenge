trigger MarginTrigger on margin__c (before insert) {
    System.debug('Margin__c Trigger Start =>' + Trigger.operationType);

    MarginTriggerHandler handler = new MarginTriggerHandler(
        Trigger.old,
        Trigger.new,
        Trigger.oldMap,
        Trigger.newMap
    );

    if(MarginTriggerHandler.isTriggerEnabled()) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert();
            }            
        }
    }
}