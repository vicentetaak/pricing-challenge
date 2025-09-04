public with sharing class OrderItemTriggerHandler {
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

    List<OrderItem> oldRecordLists {get; set;}
    List<OrderItem> newRecordLists {get; set;}
    Map<Id, OrderItem> oldRecordMaps {get; set;}
    Map<Id, OrderItem> newRecordMaps {get; set;}

    public OrderItemTriggerHandler(List<OrderItem> oldRecords,
                                List<OrderItem> newRecords, 
                                Map<Id, OrderItem> oldRecordMaps, 
                                Map<Id, OrderItem> newRecordMaps) {
        this.oldRecordLists = oldRecords;
        this.newRecordLists = newRecords;
        this.oldRecordMaps = oldRecordMaps;
        this.newRecordMaps = newRecordMaps;
    }

    public void beforeInsert(){
        OrderItemTriggerHelper.handleBeforeInsertOrderItem(this.newRecordLists);
    }

    public void beforeUpdate(){
        OrderItemTriggerHelper.handleBeforeUpdateOrderItem(this.newRecordLists, this.oldRecordMaps);
    }
}