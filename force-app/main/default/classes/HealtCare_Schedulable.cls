/*
*********************************************************************************************************
@Name     HealtCare_Schedulable
@Author   kaaviir@gmail.com
@Date     Created: 06/03/2025
@Group    Omega CRM
@Description This class is scheduled to execute the batch that creates a task for critical patients.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
06/03/2025       kaaviir@gmail.com           Class creation.
*********************************************************************************************************
*/
public with sharing class HealtCare_Schedulable implements Schedulable{
    /*
    *********************************************************
    @Method Name    : execute
    @author         : kaaviir@gmail.com
    @description    : main scheduled method that calls batch class
    ********************************************************
    */
    public void execute(SchedulableContext sc) {
       Id batchId =  Database.executeBatch(new HealthCare_Batch(), 200);
     }
}