public with sharing class MarginTriggerHandler {
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

    List<margin__c> oldRecordLists {get; set;}
    List<margin__c> newRecordLists {get; set;}
    Map<Id, margin__c> oldRecordMaps {get; set;}
    Map<Id, margin__c> newRecordMaps {get; set;}

    public MarginTriggerHandler(List<margin__c> oldRecords,
                                List<margin__c> newRecords, 
                                Map<Id, margin__c> oldRecordMaps, 
                                Map<Id, margin__c> newRecordMaps) {
        this.oldRecordLists = oldRecords;
        this.newRecordLists = newRecords;
        this.oldRecordMaps = oldRecordMaps;
        this.newRecordMaps = newRecordMaps;
    }

    public void beforeInsert(){
        MarginTriggerHelper.handleBeforeInsertMargin(this.newRecordLists);
    }
}