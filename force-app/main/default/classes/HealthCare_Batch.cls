public with sharing class HealthCare_Batch implements DataBase.Batchable<SObject> {
    public Id urgentQueueId;


    public Database.QueryLocator start(Database.BatchableContext bc){
        urgentQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Urgent'].Id;
        String query = 'SELECT Id FROM Patient__c where Critical__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<Task> tasks = new List<Task>();
      for(sobject eachRecord : scope){
        tasks.add(new Task(Subject = 'Normalization of urgency', WhatId = eachRecord.Id, ownerId = urgentQueueId));
      }
        insert tasks;
     }

    public void finish(Database.BatchableContext bc){
    }
}