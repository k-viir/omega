/*
*********************************************************************************************************
@Name     Treatment_TriggerHandler
@Author   kaaviir@gmail.com
@Date     Created: 03/06/2025
@Group    Omega CRM
@Description This class assistes the automatic process of main specialist assignation when creating a treatment.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
03/06/2025        kaaviir@gmail.com                         Class creation.
*********************************************************************************************************
*/
public with sharing class Treatment_TriggerHandler {

    /*
    *********************************************************
    @Method Name    : onBeforeInsert
    @author         : kaaviir@gmail.com
    @description    : assigns the main specialist to the treatment if available, based on record type and availability
    @param          : List<Treatment__c> triggerNew : the trigger new records
    ********************************************************
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
    *********************************************************
    @Method Name    : onAfterInsert
    @author         : kaaviir@gmail.com
    @description    : creates the assigned specialist record for the specialist related to the treatment, if available
    @param          : List<Treatment__c> triggerNew : the trigger new records
    ********************************************************
    */
    public static void onAfterInsert(List<Treatment__c> triggerNew) {
        if (triggerNew[0].Main_Specialist__c != null) {
            List<Assigned_Specialist__c> assignedSpecialists = new List<Assigned_Specialist__c>{new Assigned_Specialist__c(Treatment__c = triggerNew[0].Id, Specialist__c = triggerNew[0].Main_Specialist__c)};
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, assignedSpecialists);
            insert securityDecision.getRecords();
        }
    }

   /*
    *********************************************************
    @Method Name    : findMainSpecialist
    @param          : List<Specialist__c> specialistsAndAssignmentsRel : the list of specialists with their assigned specialists
    @author         : kaaviir@gmail.com
    @description    : iterates over a list to find the specialist with the least amount of assigned treatments

    @return         : Specialist__c : the found specialist record or null value
    ********************************************************
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
        }

        return mainSpecialist;
    }
}