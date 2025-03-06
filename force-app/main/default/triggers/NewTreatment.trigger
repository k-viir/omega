/*
*********************************************************************************************************
@Name     NewTreatment
@Author   kaaviir@gmail.com
@Date     Created: 03/06/2025
@Group    Omega CRM
@Description This class defines the trigger that processes treatment records, calling to handler class 
             depending on context.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
03/06/2025        kaaviir@gmail.com                         Class creation.
*********************************************************************************************************
*/
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