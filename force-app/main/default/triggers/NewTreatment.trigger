trigger NewTreatment on Treatment__c (before insert, after insert) {
    String recordTypeId;
    try {
        if (Trigger.isBefore) {
            Treatment_TriggerHandler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isAfter) {
            Treatment_TriggerHandler.onAfterInsert(Trigger.new);
        }
    } catch (Exception e) {
        Trigger.new[0].addError(e.getMessage());
    }
}