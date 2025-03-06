trigger NewPatientTreatment on Patient__c (after insert) {
    List<Treatment__c> treatmentsToInsert = new List<Treatment__c>();
    Schema.DescribeSObjectResult treatmentDescribe = Schema.SObjectType.Treatment__c;
    Map<String,Schema.RecordTypeInfo> rtMapByName = treatmentDescribe.getRecordTypeInfosByName();
    Schema.RecordTypeInfo recordTypeInfo =  rtMapByName.get('Preliminary Regime');

    for (Patient__c newPatient: Trigger.new){
        treatmentsToInsert.add(new Treatment__c (Name = 'Preliminary Regime for ' + newPatient.Name, Patient__c = newPatient.Id, recordTypeId = recordTypeInfo.getRecordTypeId()));
    }

    insert treatmentsToInsert;
}