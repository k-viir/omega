public with sharing class HealtCare_Schedulable implements Schedulable{
    public void execute(SchedulableContext sc) {
       Id batchId =  Database.executeBatch(new HealthCare_Batch(), 200);
     }
}