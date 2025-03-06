/*
*********************************************************************************************************
@Name     NewPatientTreatment
@Author   kaaviir@gmail.com
@Date     Created: 03/06/2025
@Group    Omega CRM
@Description This class defines the trigger for object Patient__c after insert. Automatically creates a
             necessary Treatment__c record.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
03/06/2025        kaaviir@gmail.com                         Class creation.
*********************************************************************************************************
*/
trigger NewPatientTreatment on Patient__c (after insert) {
    List<Treatment__c> treatmentsToInsert = new List<Treatment__c>();
    Schema.DescribeSObjectResult treatmentDescribe = Schema.SObjectType.Treatment__c;
    Map<String,Schema.RecordTypeInfo> rtMapByName = treatmentDescribe.getRecordTypeInfosByName();
    Schema.RecordTypeInfo recordTypeInfo =  rtMapByName.get(System.Label.HC_PreliminaryRT);

    for (Patient__c newPatient: Trigger.new){
        treatmentsToInsert.add(new Treatment__c (Name = System.Label.HC_PreliminaryName + ' ' + newPatient.Name, Patient__c = newPatient.Id, recordTypeId = recordTypeInfo.getRecordTypeId()));
    }

    SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, treatmentsToInsert);
    insert securityDecision.getRecords();

}