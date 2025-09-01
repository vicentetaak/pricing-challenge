public with sharing class TaxTriggerHandler {
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

    List<tax__c> oldRecordLists {get; set;}
    List<tax__c> newRecordLists {get; set;}
    Map<Id, tax__c> oldRecordMaps {get; set;}
    Map<Id, tax__c> newRecordMaps {get; set;}

    public TaxTriggerHandler(List<tax__c> oldRecords,
                                List<tax__c> newRecords, 
                                Map<Id, tax__c> oldRecordMaps, 
                                Map<Id, tax__c> newRecordMaps) {
        this.oldRecordLists = oldRecords;
        this.newRecordLists = newRecords;
        this.oldRecordMaps = oldRecordMaps;
        this.newRecordMaps = newRecordMaps;
    }

    public void beforeInsert(){
        TaxTriggerHelper.handleBeforeInsertTax(this.newRecordLists);
    }
}