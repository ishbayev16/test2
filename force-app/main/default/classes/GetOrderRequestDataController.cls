public with sharing class GetOrderRequestDataController {

    @AuraEnabled(cacheable=true)
    public static List<Order_Request__c> getOrderRequests(){
    
            
                return [Select id, name, Purchase_Order_Status__c, Purchase_Order_Status_Style__c,Status__c from Order_Request__c];
            
    
    }
}