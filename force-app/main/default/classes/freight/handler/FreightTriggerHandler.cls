public with sharing class FreightTriggerHandler {
    private static Boolean isEnabled;

    static {
        isEnabled = true; // Set to false to disable the trigger
    }

    public static Boolean isTriggerEnabled() {
        return isEnabled;
    }

    public static void disableTrigger() {
        isEnabled = false;
    }

    public static void enableTrigger() {
        isEnabled = true;
    }

    List<freight__c> oldRecordLists {get; set;}
    List<freight__c> newRecordLists {get; set;}
    Map<Id, freight__c> oldRecordMaps {get; set;}
    Map<Id, freight__c> newRecordMaps {get; set;}

    public FreightTriggerHandler(List<freight__c> oldRecords,
                                List<freight__c> newRecords, 
                                Map<Id, freight__c> oldRecordMaps, 
                                Map<Id, freight__c> newRecordMaps) {
        this.oldRecordLists = oldRecords;
        this.newRecordLists = newRecords;
        this.oldRecordMaps = oldRecordMaps;
        this.newRecordMaps = newRecordMaps;
    }

    public void beforeInsert(){
        FreightTriggerHelper.handleBeforeInsertFreight(this.newRecordLists);
    }
}
