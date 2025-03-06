public with sharing class Treatment_TriggerHandler {

    /*
    * Handles the before insert trigger event for Treatment__c records.
    *
    * @param triggerNew List of new Treatment__c records being inserted.
    */
    public static void onBeforeInsert(List<Treatment__c> triggerNew) {
        if (triggerNew.size() == 1) {
            Schema.DescribeSObjectResult treatmentDescribe = Schema.SObjectType.Treatment__c;
            Map<Id,Schema.RecordTypeInfo> rtMapById = treatmentDescribe.getRecordTypeInfosById();
            Schema.RecordTypeInfo recordTypeInfo =  rtMapById.get(triggerNew[0].recordtypeid);
            Specialist__c mainSpecialist;
            String rtName = recordTypeInfo.getName();
            String query = 'select Id, name, Specialty_types__c, (select Specialist__c from Assigned_specialists__r) from Specialist__c where specialty_types__c INCLUDES (:rtName)';
            List<Specialist__c> specialistsAndAssignmentsRel = database.query(String.escapeSingleQuotes(query));

            mainSpecialist = findMainSpecialist(specialistsAndAssignmentsRel);
            if (mainSpecialist != null) {
                triggerNew[0].Main_Specialist__c = mainSpecialist.Id;
            }

        } // TODO add logic for bulk records
    }

    /*
    * Handles the after insert trigger event for Treatment__c records.
    *
    * @param triggerNew List of new Treatment__c records that were inserted.
    */
    public static void onAfterInsert(List<Treatment__c> triggerNew) {
        if (triggerNew[0].Main_Specialist__c != null) {

            List<Assigned_Specialist__c> assignedSpecialists = new List<Assigned_Specialist__c>{new Assigned_Specialist__c(Treatment__c = triggerNew[0].Id, Specialist__c = triggerNew[0].Main_Specialist__c)};
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, assignedSpecialists);
            insert securityDecision.getRecords();

        }
    }

    /*
    * Finds the main specialist from a list of specialists based on the number of assigned specialists.
    *
    * @param specialistsAndAssignmentsRel List of Specialist__c records with their related Assigned_specialists__r.
    * @return The Specialist__c record with the fewest assigned specialists or the first specialist with no assigned specialists.
    */
    public static Specialist__c findMainSpecialist(List<Specialist__c> specialistsAndAssignmentsRel) {
        Boolean auxFound = false;
        Integer auxCounter = 0;
        Specialist__c mainSpecialist;

        while(!auxFound && auxCounter < specialistsAndAssignmentsRel.size()) {
            if (specialistsAndAssignmentsRel[auxCounter].Assigned_specialists__r.size() == 0) {
                auxFound = true;
                mainSpecialist = specialistsAndAssignmentsRel[auxCounter];
            } else {
                if (mainSpecialist != null) {
                    if (specialistsAndAssignmentsRel[auxCounter].Assigned_specialists__r.size() < mainSpecialist.Assigned_specialists__r.size()) {
                        mainSpecialist = specialistsAndAssignmentsRel[auxCounter];
                    }
                } else {
                    mainSpecialist = specialistsAndAssignmentsRel[auxCounter];
                }

                auxCounter++;
            }
            system.debug('false?: ' + auxFound);
            system.debug('fails?: auxcounter ' + auxCounter);
            system.debug('what: ' + specialistsAndAssignmentsRel.size());
        }

        return mainSpecialist;
    }
}