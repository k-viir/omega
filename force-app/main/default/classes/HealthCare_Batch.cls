/*
*********************************************************************************************************
@Name     HealthCare_Batch
@Author   kaaviir@gmail.com
@Date     Created: 06/03/2025
@Group    Omega CRM
@Description This class is defines the batch that will create a task for critical patients.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
06/03/2025       kaaviir@gmail.com           Class creation.
*********************************************************************************************************
*/
public with sharing class HealthCare_Batch implements DataBase.Batchable<SObject> {
    public Id urgentQueueId;

    /*
    *********************************************************
    @Method Name    : start
    @author         : kaaviir@gmail.com
    @description    : start method that sets queueId and returns queryLocator
    @return         : Database.QueryLocator : list of critical patients
    ********************************************************
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        urgentQueueId = [SELECT Id FROM Group WHERE DeveloperName = :System.Label.HC_Urgent].Id;
        String query = 'SELECT Id FROM Patient__c where Critical__c = true';
        return Database.getQueryLocator(String.escapeSingleQuotes(query));
    }
    /*
    *********************************************************
    @Method Name    : execute
    @author         : kaaviir@gmail.com
    @description    : execute method that creates the corresponding task and sets its queue
    ********************************************************
    */

    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<Task> tasks = new List<Task>();
      for(sobject eachRecord : scope){
        tasks.add(new Task(Subject = System.Label.HC_Normalization, WhatId = eachRecord.Id, ownerId = urgentQueueId));
      }
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, tasks);
        insert securityDecision.getRecords();

     }

    /*
    *********************************************************
    @Method Name    : finish
    @author         : kaaviir@gmail.com
    @description    : unused
    **********
    */
    public void finish(Database.BatchableContext bc){
    }
}