public with sharing class UsersSIOPApproveSearchNew {

 
     static List<wrapperclass> wrapList = new List<wrapperclass>();
     static returnResult ReturnResult = new ReturnResult();
        
    
    
    
    static String searchOrdReqStatus {get;set;}
    
    static String searchPickObject {get;set;}
       
    
    static String SearchTotal {get;set;}
    
    
    
    
    
     static String ForecastLabel {get;set;}
    
    
     static String SuggestForecastLabel {get;set;}
   
    
    
     static Map<String,String> userMap = new Map<String,String>();     
     static Map<String,String> checkMap = new Map<String,String>();    
    

    @AuraEnabled
    public static ReturnResult getWrapList(String searchAltAccount, String searchSKU, 
               String searchPickUser, String ordReqApproveKey, 
               String ordReqApproveMMKey, String searchPickStatus, String searchPickMonth ) {
         Date startDate;
         Date endDate;

         system.debug('getWraplist run');
         
         Map<Integer,String> forecastMonthsMap = new Map<Integer,String>{1 => 'Jan/Fab/Mar/Apr', 2 => 'Fab/Mar/Apr/May', 3 => 'Mar/Apr/May/Jun',4 => 'Apr/May/Jun/Jul',5 => 'May/Jun/Jul/Aug',6 => 'Jun/Jul/Aug/Sep',7 => 'Jul/Aug/Sep/Oct',8 => 'Aug/Sep/Oct/Nov',9 => 'Sep/Oct/Nov/Dec',10 => 'Oct/Nov/Dec/Jan',11 => 'Nov/Dec/Jan/Feb',12 => 'Dec/Jan/Feb/Mar'};  
         Map<Integer,String> suggestMonthsMap = new Map<Integer,String>{1 => 'Fab/Mar/Apr', 2 => 'Mar/Apr/May', 3 => 'Apr/May/Jun',4 => 'May/Jun/Jul',5 => 'Jun/Jul/Aug',6 => 'Jul/Aug/Sep',7 => 'Aug/Sep/Oct',8 => 'Sep/Oct/Nov',9 => 'Oct/Nov/Dec',10 => 'Nov/Dec/Jan',11 => 'Dec/Jan/Feb',12 => 'Jan/Feb/Mar'};  
         
         if (searchPickMonth =='0') {
            startDate = System.today().toStartOfMonth();
            endDate = System.today();
            ForecastLabel = 'FC:'+forecastMonthsMap.get(System.today().month()); 
            SuggestForecastLabel = 'Sugg:'+suggestMonthsMap.get(System.today().month()); 
         } else if (searchPickMonth =='1') {
            //date.today().addmonths(-1)
            startDate = System.today().toStartOfMonth().addmonths(-1);
            endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month()) - 1);
            ForecastLabel = 'FC:'+forecastMonthsMap.get(System.today().addMonths(-1).month()); 
            SuggestForecastLabel = 'Sugg:'+suggestMonthsMap.get(System.today().addMonths(-1).month()); 
         } else if (searchPickMonth =='2') {
            //date.today().addmonths(-2)
            ForecastLabel = 'FC:'+forecastMonthsMap.get(System.today().addMonths(-2).month()); 
            SuggestForecastLabel = 'Sugg:'+suggestMonthsMap.get(System.today().addMonths(-2).month()); 
            startDate = System.today().toStartOfMonth().addmonths(-2);
            endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month()) - 1);
         } else if (searchPickMonth =='3') {
            //date.today().addmonths(-3)
            startDate = System.today().toStartOfMonth().addmonths(-3);
            endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month()) - 1);
            ForecastLabel = 'FC:'+forecastMonthsMap.get(System.today().addMonths(-3).month()); 
            SuggestForecastLabel = 'Sugg:'+suggestMonthsMap.get(System.today().addMonths(-3).month()); 
         } else if (searchPickMonth =='4') {
            //date.today().addmonths(-4)
            startDate = System.today().toStartOfMonth().addmonths(-4);
            endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month()) - 1);
            ForecastLabel = 'FC:'+forecastMonthsMap.get(System.today().addMonths(-4).month()); 
            SuggestForecastLabel = 'Sugg:'+suggestMonthsMap.get(System.today().addMonths(-4).month()); 
         } else if (searchPickMonth =='5') {
            //date.today().addmonths(-5)
            startDate = System.today().toStartOfMonth().addmonths(-5);
            endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month()) - 1);
            ForecastLabel = 'FC:'+forecastMonthsMap.get(System.today().addMonths(-5).month()); 
            SuggestForecastLabel = 'Sugg:'+suggestMonthsMap.get(System.today().addMonths(-5).month()); 
       } 
        
       system.debug('searchPickMonth '+searchPickMonth);
       system.debug('startDate '+ startDate);
       system.debug('endDate '+ endDate);
       system.debug('ForecastLabel '+ ForecastLabel);
       system.debug('SuggestForecastLabel '+ SuggestForecastLabel);
         
         wrapList = new List<wrapperclass>();
          
         String aApprover ='';
         Set<Id> forecastIds= new Set<Id>();
         Set<Id> ordReqIds= new Set<Id>();
         Map<Id,SIOP_2_Forecast__c> forecastFieldsMap = new Map<Id,SIOP_2_Forecast__c>();
         Map<Id,Order_Request__c> ordReqFieldsMap = new Map<Id,Order_Request__c>();
         
         list<ProcessInstance> ProcessInstanceList = new list<ProcessInstance> ();
         
         //trim()
         if (searchAltAccount != null && searchAltAccount !='')
           searchAltAccount = searchAltAccount.trim();
           
         if (searchSKU!= null && searchSKU!='')
           searchSKU= searchSKU.trim();
           
         searchOrdReqStatus ='';  
         
         
         Map<Id,Order_Group__c> ordGroupFieldsMap = new Map<Id,Order_Group__c>();
         Map<Id,List<Order_Request__c>> ordIdAndRequestMap = new Map<Id,List<Order_Request__c>>();
         Map<Id,Order_Group__c> orderIdRecordMap = new Map<Id, Order_Group__c>();
         Set<Id> ordGroupIdSet = new Set<Id>();
         
         //point to order group
         
         searchPickObject ='Order Request';
         String Status; 
         String RecordName;
         String RecordId;
         String RecordObject;
        
         //1 searchPickUser/SearchPickStatus/searchAltAccount/searchSKU
         if (searchPickUser != null && searchPickUser !=''
                && searchSKU != null && searchSKU !=''
                && searchAltAccount != null && searchAltAccount !=''
                && SearchPickStatus != null && SearchPickStatus !='' ) {
                
                  searchOrdReqStatus =getSearchOrdReqStatus(SearchPickStatus);       
                
                  system.debug('mzcheck case 1 searchOrdReqStatus ='+searchOrdReqStatus );
                       
                       
                  for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and SIOP_2_Forecast__r.Account__r.Alt_Customer_Number__c=: searchAltAccount and Material_number__c =:SearchSKU 
                                                 and status__c =:searchOrdReqStatus
                                                 and (Supply_Chain_Approver__c = :searchPickUser or Supply_Chain_Approver_bk__c = :searchPickUser
                                                 or Sales_Approver__c = :searchPickUser or Sales_Approver_bk__c = :searchPickUser 
                                                 or MMGM_Approver__c = :searchPickUser or MMGM_Approver_bk__c = :searchPickUser) 
                                                 and Material_Number__c =:searchSKU
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord
            //2 searchPickUser/SearchPickStatus/searchAltAccount  
            } else if (searchPickUser != null && searchPickUser !=''
                && SearchPickStatus != null && SearchPickStatus !=''
                && searchAltAccount != null && searchAltAccount !=''
                && (searchSKU == null || searchSKU =='') ) {
                 searchOrdReqStatus =getSearchOrdReqStatus(SearchPickStatus);       
                
                  system.debug('mzcheck case 2 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                  for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and SIOP_2_Forecast__r.Account__r.Alt_Customer_Number__c=: searchAltAccount  
                                                 and status__c =:searchOrdReqStatus
                                                 and (Supply_Chain_Approver__c = :searchPickUser or Supply_Chain_Approver_bk__c = :searchPickUser
                                                 or Sales_Approver__c = :searchPickUser or Sales_Approver_bk__c = :searchPickUser 
                                                 or MMGM_Approver__c = :searchPickUser or MMGM_Approver_bk__c = :searchPickUser) 
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord
           //3 searchPickUser/SearchPickStatus/searchSKU
           } else if (searchPickUser != null && searchPickUser !=''
                && SearchPickStatus != null && SearchPickStatus !=''
                && (searchAltAccount == null || searchAltAccount =='')
                && searchSKU != null && searchSKU !='' ) { 
                searchOrdReqStatus =getSearchOrdReqStatus(SearchPickStatus);       
                
                system.debug('mzcheck case 3 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                  for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and Material_number__c =:SearchSKU 
                                                 and status__c =:searchOrdReqStatus
                                                 and (Supply_Chain_Approver__c = :searchPickUser or Supply_Chain_Approver_bk__c = :searchPickUser
                                                 or Sales_Approver__c = :searchPickUser or Sales_Approver_bk__c = :searchPickUser 
                                                 or MMGM_Approver__c = :searchPickUser or MMGM_Approver_bk__c = :searchPickUser)
                                                 ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord
           //4 searchPickUser/searchAltAccount/searchSKU
           } else if (searchPickUser != null && searchPickUser !=''
                && (SearchPickStatus == null || SearchPickStatus =='')
                && searchAltAccount != null && searchAltAccount !=''
                && searchSKU != null && searchSKU !='') {     
                
                system.debug('mzcheck case 4 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                       
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and SIOP_2_Forecast__r.Account__r.Alt_Customer_Number__c=: searchAltAccount and Material_number__c =:SearchSKU 
                                                 and (Supply_Chain_Approver__c = :searchPickUser or Supply_Chain_Approver_bk__c = :searchPickUser
                                                 or Sales_Approver__c = :searchPickUser or Sales_Approver_bk__c = :searchPickUser 
                                                 or MMGM_Approver__c = :searchPickUser or MMGM_Approver_bk__c = :searchPickUser)
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord     
           //5 SearchPickStatus/searchAltAccount/searchSKU
           } else if ((searchPickUser == null || searchPickUser =='')
                && SearchPickStatus != null && SearchPickStatus !=''
                && searchAltAccount != null && searchAltAccount !=''
                && searchSKU != null && searchSKU !='') {
                
                searchOrdReqStatus =getSearchOrdReqStatus(SearchPickStatus);    
                
                system.debug('mzcheck case 5 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                     
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and SIOP_2_Forecast__r.Account__r.Alt_Customer_Number__c=: searchAltAccount and Material_number__c =:SearchSKU 
                                                 and status__c =:searchOrdReqStatus
                                                  ]){                      
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord     
            //6 searchPickUser/SearchPickStatus 
            } else if (searchPickUser != null && searchPickUser !='' 
                && SearchPickStatus != null && SearchPickStatus !=''
                && (searchAltAccount == null || searchAltAccount =='') 
                && (searchSKU == null || searchSKU =='') ) {
            
                searchOrdReqStatus =getSearchOrdReqStatus(SearchPickStatus);    
                system.debug('mzcheck case 6 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                     
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                  and status__c =:searchOrdReqStatus
                                                  and (Supply_Chain_Approver__c = :searchPickUser or Supply_Chain_Approver_bk__c = :searchPickUser
                                                   or Sales_Approver__c = :searchPickUser or Sales_Approver_bk__c = :searchPickUser 
                                                   or MMGM_Approver__c = :searchPickUser or MMGM_Approver_bk__c = :searchPickUser) 
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord     
            //7 SearchPickStatus/searchAltAccount
            } else if ((searchPickUser == null || searchPickUser =='')
                && SearchPickStatus != null && SearchPickStatus !=''
                && searchAltAccount != null && searchAltAccount !=''
                && (searchSKU == null || searchSKU =='') ) {
                
                searchOrdReqStatus =getSearchOrdReqStatus(SearchPickStatus);   
                system.debug('mzcheck case 7 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                      
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and SIOP_2_Forecast__r.Account__r.Alt_Customer_Number__c=: searchAltAccount
                                                 and status__c =:searchOrdReqStatus
                                                 ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord     
            //8 SearchPickStatus/searchSKU
            } else if ((searchPickUser == null || searchPickUser =='')
                && SearchPickStatus != null && SearchPickStatus !=''
                && (searchAltAccount == null || searchAltAccount =='')
                && searchSKU != null && searchSKU !='') {  
                
                searchOrdReqStatus =getSearchOrdReqStatus(SearchPickStatus);     
                system.debug('mzcheck case 8 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                    
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and Material_number__c =:SearchSKU 
                                                 and status__c =:searchOrdReqStatus
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord 
            //9 searchPickUsers/SearchAltAccount
            } else if (searchPickUser != null && searchPickUser !=''
                && (SearchPickStatus == null || SearchPickStatus =='')
                && searchAltAccount != null && searchAltAccount !=''
                && (searchSKU == null || searchSKU =='') ) {
                
                system.debug('mzcheck case 9 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                  
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and SIOP_2_Forecast__r.Account__r.Alt_Customer_Number__c=: searchAltAccount
                                                 and (Supply_Chain_Approver__c = :searchPickUser or Supply_Chain_Approver_bk__c = :searchPickUser
                                                 or Sales_Approver__c = :searchPickUser or Sales_Approver_bk__c = :searchPickUser 
                                                 or MMGM_Approver__c = :searchPickUser or MMGM_Approver_bk__c = :searchPickUser) 
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord       
            //10 searchPickUser/searchSKU
            } else if (searchPickUser != null && searchPickUser !=''
                && (SearchPickStatus == null || SearchPickStatus =='')
                && (searchAltAccount == null || searchAltAccount =='')
                && searchSKU != null && searchSKU !='') {
                
                system.debug('mzcheck case 10 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                  
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and Material_number__c =:SearchSKU 
                                                 and (Supply_Chain_Approver__c = :searchPickUser or Supply_Chain_Approver_bk__c = :searchPickUser
                                                 or Sales_Approver__c = :searchPickUser or Sales_Approver_bk__c = :searchPickUser 
                                                 or MMGM_Approver__c = :searchPickUser or MMGM_Approver_bk__c = :searchPickUser) 
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord       
            //11 searchAltAccount/searchSKU
            } else if ((searchPickUser == null || searchPickUser =='')
                && (SearchPickStatus == null || SearchPickStatus =='')
                && searchAltAccount != null && searchAltAccount !=''
                && searchSKU != null && searchSKU !='') {   
                
                system.debug('mzcheck case 11 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and SIOP_2_Forecast__r.Account__r.Alt_Customer_Number__c=: searchAltAccount and Material_number__c =:SearchSKU 
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
              
                  } //end of for(Order_Request__c ordReqRecord   
               //12 searchPickUser
               } else if (searchPickUser != null && searchPickUser !='' 
                && (SearchPickStatus == null || SearchPickStatus =='')
                && (searchAltAccount == null || searchAltAccount =='') 
                && (searchSKU == null || searchSKU =='') ) {        
                system.debug('mzcheck case 12 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                     
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and (Supply_Chain_Approver__c = :searchPickUser or Supply_Chain_Approver_bk__c = :searchPickUser
                                                 or Sales_Approver__c = :searchPickUser or Sales_Approver_bk__c = :searchPickUser 
                                                 or MMGM_Approver__c = :searchPickUser or MMGM_Approver_bk__c = :searchPickUser) 
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
                  } //end of for(Order_Request__c ordReqRecord  
            //13 SearchPickStatus 
            } else if (SearchPickStatus != null && SearchPickStatus !=''
                && (searchPickUser == null || searchPickUser =='') 
                && (searchAltAccount == null || searchAltAccount =='') 
                && (searchSKU == null || searchSKU =='') ) {
                
                searchOrdReqStatus =getSearchOrdReqStatus(SearchPickStatus);  
                  
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and status__c =:searchOrdReqStatus
                                                ]){ 
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);

                       system.debug('mzcheck case 13 searchOrdReqStatus ='+searchOrdReqStatus );  
                
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
                  } //end of for(Order_Request__c ordReqRecord   
            //14 searchAltAccount
            } else if ((searchPickUser == null || searchPickUser =='')
                && (SearchPickStatus == null || SearchPickStatus =='')
                && searchAltAccount != null && searchAltAccount !=''
                && (searchSKU == null || searchSKU =='') ) {
                
                system.debug('mzcheck case 14 searchOrdReqStatus ='+searchOrdReqStatus );
                  
                  
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and SIOP_2_Forecast__r.Account__r.Alt_Customer_Number__c=: searchAltAccount
                                                ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
                  } //end of for(Order_Request__c ordReqRecord       
           //15 searchSKU
           } else if ((searchPickUser == null || searchPickUser =='')
                && (SearchPickStatus == null || SearchPickStatus =='')
                && (searchAltAccount == null || searchAltAccount =='')
                && searchSKU != null && searchSKU !='') {  
              
                system.debug('mzcheck why case 15 SearchPickStatus ='+SearchPickStatus);
              
                system.debug('mzcheck case 15 only searchOrdReqStatus ='+searchOrdReqStatus );
                  
                  
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                                 and Material_number__c =:SearchSKU 
                                                 ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
                  } //end of for(Order_Request__c ordReqRecord    
           //16 all      
           } else {         
           system.debug('mzcheck ALL searchOrdReqStatus ='+searchOrdReqStatus );
                  
                  
                for(Order_Request__c ordReqRecord : [Select Purchase_Order__r.Order_Date__c ,Purchase_Order__r.Order_Number__c,Purchase_Order_Status__c, SIOP_2_Forecast__r.UPI_Indicator__c,SIOP_2_Forecast__r.MRI__c,Risk_Level_Label__c, Order_Submission_Group__c, Id,Alt_Account_Number__c,Account_Name__c,SIOP_2_Forecast__r.Account__c,Material_Number__c,Material_Description__c,On_Hand__c,X3_Month_Average_lbs__c,
                                                     Forecast_Current_Month__c,Forecast_Next_Month__c,Forecast_Next_Month_plus_1__c,Forecast_Next_Month_plus_2__c,
                                                     Suggested_Forecast_Next_Month__c,Suggested_Forecast_Next_Month_Plus_1__c,Suggested_Forecast_Next_Month_Plus_2__c,
                                                     Reserved_Lbs__c,In_Transit__c,On_Order__c,DOS_OH__c,SKU_Width__c,SKU_Length__c,
                                                     Sales_Approver__r.name,Sales_Approver_BK__r.name,Supply_Chain_Approver__r.name, Supply_Chain_Approver_BK__r.name,
                                                     MMGM_Approver__r.name,MMGM_Approver_BK__r.name,VP_Approver__r.name, VP_Approver_BK__r.name,
                                                     Order_Request_Qty__c,Unit_of_Measure__c,Suggested_Qty__c,Desired_Arrival_Date__c,Date_of_Submittal__c 
                                               from Order_Request__c 
                                               where SIOP_2_Forecast__r.Is_DW__c = TRUE and Order_Submission_Group__c != null
                                               ]){ 
                                             
                        ordReqFieldsMap.put(ordReqRecord.id,ordReqRecord);
               
               
                       if(ordIdAndRequestMap.containsKey(ordReqRecord.Order_Submission_Group__c)) {
                          List<Order_Request__c> ordList = ordIdAndRequestMap.get(ordReqRecord.Order_Submission_Group__c);
                          ordList.add(ordReqRecord);
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, ordList);
                       } else {
                          ordIdAndRequestMap.put(ordReqRecord.Order_Submission_Group__c, new List<Order_Request__c> { ordReqRecord});
                       }  //end of ordIdAndRequestMap
                  } //end of for(Order_Request__c ordReqRecord                       
           } // end of if search cases
           
           Integer totalCount =0;
         
         
           for (ProcessInstance pi: [SELECT Id, Status, TargetObjectId, TargetObject.Name, 
                                          (SELECT Id, ActorId, Actor.Name, OriginalActorId, OriginalActor.Name, StepStatus, Comments, ProcessNode.Name, CreatedDate 
                                             FROM StepsAndWorkitems 
                                             WHERE StepStatus =: SearchPickStatus
                                             )   
                                     FROM ProcessInstance WHERE CreatedDate >=:startDate and CreatedDate <=:endDate and Status =: SearchPickStatus and (PROCESSDEFINITIONID =:ordReqApproveKey OR PROCESSDEFINITIONID =:ordReqApproveMMKey)                                   
                                     ORDER BY CreatedDate desc,TargetObject.Name] ) {
                  for (ProcessInstanceHistory pih : pi.StepsAndWorkItems) {
                     if(ordIdAndRequestMap.containsKey(String.valueOf(pi.TargetObjectId)) || ordIdAndRequestMap.containsKey(String.valueOf(pi.TargetObjectId))){  
                        Status = pih.StepStatus;
                        RecordId = String.valueOf(pi.TargetObjectId);
                        
                        
                        RecordObject = String.valueOf(pi.TargetObjectId.getSObjectType()).split('__')[0];
                        if (RecordObject == 'Order_Request') 
                          RecordName = 'Order:'+String.valueOf(pi.TargetObject.Name);
                        else if(RecordObject == 'Order_Group'){
                           RecordName = 'Order:'+String.valueOf(pi.TargetObject.Name);
                     } // end of if(ordIdAndRequestMap
             
                     wrapperClass pendingApprovalWrap = new wrapperClass();

                     pendingApprovalWrap.selected=false;
                     pendingApprovalWrap.Status = pi.Status;
                       
                     pendingApprovalWrap.RecordId = String.valueOf(pi.TargetObjectId);
                     pendingApprovalWrap.RecordObject = String.valueOf(pi.TargetObjectId.getSObjectType()).split('__')[0];
                     pendingApprovalWrap.RecordName =String.valueOf(pi.TargetObject.Name);
                        
                     pendingApprovalWrap.AssignedToName = String.valueOf(pih.OriginalActor.Name);
                     pendingApprovalWrap.ApproverName = pih.Actor.Name;
                     pendingApprovalWrap.ApproverId = searchPickUser;
                        
                     pendingApprovalWrap.id =pih.id;
                     
                        
                     if (ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)!= null) {
                          //order req get from Date_of_Submittal__c
                          if (ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Date_of_Submittal__c != null)
                            pendingApprovalWrap.CreatedDate =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Date_of_Submittal__c.format();
                          else
                            pendingApprovalWrap.CreatedDate ='';
                          
                          pendingApprovalWrap.AccountId=ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].SIOP_2_Forecast__r.Account__c;
                          pendingApprovalWrap.AccountName=ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Account_Name__c;
                          pendingApprovalWrap.orderReqId = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].id;
                          
                          pendingApprovalWrap.AltAccountNumber =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Alt_Account_Number__c;
                         
                          pendingApprovalWrap.SKU =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Material_Number__c;
                          
                          pendingApprovalWrap.SKUDesc =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Material_Description__c;
                          pendingApprovalWrap.OnHand=String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].On_Hand__c.format());
                          pendingApprovalWrap.Month3Avg=String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].X3_Month_Average_lbs__c.format());
                       
                          //format -> .setScale(0)
                          pendingApprovalWrap.ForecastCurr= ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Forecast_Current_Month__c != null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Forecast_Current_Month__c.setScale(0).format()) : '';
                          pendingApprovalWrap.ForecastNext= ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Forecast_Next_Month__c!= null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Forecast_Next_Month__c.setScale(0).format()) : '';
                          pendingApprovalWrap.ForecastNextPlus1 =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Forecast_Next_Month_plus_1__c!= null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Forecast_Next_Month_plus_1__c.setScale(0).format()) : '';
                          pendingApprovalWrap.ForecastNextPlus2 = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Forecast_Next_Month_plus_2__c!= null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Forecast_Next_Month_plus_2__c.setScale(0).format()) : '';                               
                                                                                          
                          
                          pendingApprovalWrap.Forecasts = pendingApprovalWrap.ForecastCurr
                                                 +' / ' + pendingApprovalWrap.ForecastNext
                                                 +' / ' + pendingApprovalWrap.ForecastNextPlus1 
                                                 +' / ' + pendingApprovalWrap.ForecastNextPlus2;
                                                 
                          pendingApprovalWrap.SuggestedNext= ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Suggested_Forecast_Next_Month__c!= null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Suggested_Forecast_Next_Month__c.format()) : '';
                          pendingApprovalWrap.SuggestedNextPlus1 =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Suggested_Forecast_Next_Month_Plus_1__c!= null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Suggested_Forecast_Next_Month_Plus_1__c.format()) : '';
                          pendingApprovalWrap.SuggestedNextPlus2 = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Suggested_Forecast_Next_Month_Plus_2__c!= null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Suggested_Forecast_Next_Month_Plus_2__c.format()) : '';                               
                       
                       
                                                         
                          pendingApprovalWrap.Suggesteds=pendingApprovalWrap.SuggestedNext
                                                 +' / ' + pendingApprovalWrap.SuggestedNextPlus1 
                                                 +' / ' + pendingApprovalWrap.SuggestedNextPlus2;
                          
                          pendingApprovalWrap.Reserved=String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Reserved_Lbs__c.format());
                          pendingApprovalWrap.InTransit=String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].In_Transit__c.format());
                          pendingApprovalWrap.DOS=String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].DOS_OH__c.intValue());
                          
                          if (ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].SKU_Width__c != null)
                            pendingApprovalWrap.SKUWidth=String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].SKU_Width__c.intValue());
                          else
                            pendingApprovalWrap.SKUWidth=''; 
                          
                          if (ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].SKU_Length__c != null)
                            pendingApprovalWrap.SKULength=String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].SKU_Length__c.intValue());
                          else
                            pendingApprovalWrap.SKULength='';
                            
                          pendingApprovalWrap.SKUWidthLength = pendingApprovalWrap.SKUWidth +'/'+ pendingApprovalWrap.SKULength;  
                            
                          pendingApprovalWrap.OnOrder=String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].On_Order__c.format());
                          
                          pendingApprovalWrap.Reassign =pih.id+'/e?et=REASSIGN&retURL=%2Fhome%2Fhome.jsp'; 
                          pendingApprovalWrap.ApproveReject='/p/process/ProcessInstanceWorkitemWizardStageManager?id='+pih.id; 
                          
                          if (pendingApprovalWrap.ApproverName == ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Sales_Approver__r.name) {
                              pendingApprovalWrap.SalesApprover = pendingApprovalWrap.ApproverName;
                              pendingApprovalWrap.SalesApproverBK = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Sales_Approver_BK__r.name;
                          } else if (pendingApprovalWrap.ApproverName == ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Sales_Approver_bk__r.name) {
                              pendingApprovalWrap.SalesApproverBK = pendingApprovalWrap.ApproverName;
                              pendingApprovalWrap.SalesApprover = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Sales_Approver__r.name;
                          } else if (pendingApprovalWrap.ApproverName == ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Supply_Chain_Approver__r.name) {
                              pendingApprovalWrap.SalesApprover = pendingApprovalWrap.ApproverName; 
                              pendingApprovalWrap.SalesApproverBK = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Supply_Chain_Approver_BK__r.name;
                          } else if (pendingApprovalWrap.ApproverName == ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Supply_Chain_Approver_BK__r.name) {
                              pendingApprovalWrap.SalesApproverBK = pendingApprovalWrap.ApproverName;
                              pendingApprovalWrap.SalesApprover = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Supply_Chain_Approver__r.name;
                          
                          } else if (pendingApprovalWrap.ApproverName == ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].MMGM_Approver__r.name) {
                              pendingApprovalWrap.SalesApprover = pendingApprovalWrap.ApproverName; 
                              pendingApprovalWrap.SalesApproverBK = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].MMGM_Approver_BK__r.name;
                   
                          } else if (pendingApprovalWrap.ApproverName == ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].MMGM_Approver_BK__r.name) {
                              pendingApprovalWrap.SalesApproverBK = pendingApprovalWrap.ApproverName;
                              pendingApprovalWrap.SalesApprover = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].MMGM_Approver__r.name;
                              
                          } else if (pendingApprovalWrap.ApproverName == ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].VP_Approver__r.name) {
                              pendingApprovalWrap.SalesApprover = pendingApprovalWrap.ApproverName; 
                              pendingApprovalWrap.SalesApproverBK = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].VP_Approver_BK__r.name;
                          } else if (pendingApprovalWrap.ApproverName == ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].VP_Approver_BK__r.name) {
                              pendingApprovalWrap.SalesApproverBK = pendingApprovalWrap.ApproverName;
                              pendingApprovalWrap.SalesApprover = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].VP_Approver__r.name;
                          } else { 
                              pendingApprovalWrap.SalesApproverBK ='';
                              pendingApprovalWrap.SalesApprover ='';
                          }  
                         
                          if (pendingApprovalWrap.SalesApproverBK == null)
                            pendingApprovalWrap.SalesApproverBK ='';
                         
                          pendingApprovalWrap.ApproverBKApprover = pendingApprovalWrap.SalesApprover;
                                                      
                          pendingApprovalWrap.OrderRequestQty =  ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Order_Request_Qty__c!= null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Order_Request_Qty__c.format()) : '';
                          pendingApprovalWrap.UnitofMeasure =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Unit_of_Measure__c;
                         
                          pendingApprovalWrap.SuggestedQty =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Suggested_Qty__c != null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Suggested_Qty__c .format()) : '';
         
                          pendingApprovalWrap.DesiredArrivalDate = ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Desired_Arrival_Date__c != null ?
                                                          String.valueOf(ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Desired_Arrival_Date__c.format()) : '';
                                                          
                          //add Risk_Level__c//CASE(Risk_Level__c , '0', 'Go', '1', 'Low','2','Med','3','High','')
                          if (ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Risk_Level_Label__c == 'Go')
                            pendingApprovalWrap.RiskGo =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Risk_Level_Label__c;
                          
                          if (ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Risk_Level_Label__c == 'Low')
                            pendingApprovalWrap.RiskLow =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Risk_Level_Label__c;
                          
                          if (ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Risk_Level_Label__c == 'Med')
                            pendingApprovalWrap.RiskMed =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Risk_Level_Label__c;
                          
                          if (ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Risk_Level_Label__c == 'High')
                            pendingApprovalWrap.RiskHigh =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Risk_Level_Label__c;
                            
                          
                          pendingApprovalWrap.UPI=ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].SIOP_2_Forecast__r.UPI_Indicator__c;
                          pendingApprovalWrap.MRI=ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].SIOP_2_Forecast__r.MRI__c;
                          
                          pendingApprovalWrap.PurchaseOrderStatus=ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Purchase_Order_Status__c ;
                          pendingApprovalWrap.OrderNumber =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Purchase_Order__r.Order_Number__c;
                          
                          if (ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Purchase_Order__r.Order_Date__c != null)
                            pendingApprovalWrap.OrderDate =ordIdAndRequestMap.get(pendingApprovalWrap.RecordId)[0].Purchase_Order__r.Order_Date__c.format();
                          else
                            pendingApprovalWrap.OrderDate ='';
                          
                            
                          
                          totalCount = totalCount + 1;
                     } //end of if (ordIdAndRequestMap
                     
                     if (totalCount <= 100)
                       wrapList.add(pendingApprovalWrap);
                  } //end of for (ProcessInstanceHistory pih 
           } // end of for (ProcessInstance pi          
       } // end of search cases
         
       if(wrapList.size()==100)
               SearchTotal='Max return search is 100, please narrow down your search!';
       else
               SearchTotal= 'Total Search results:'+string.valueof(wrapList.size()); 
                    
       //return wrapList;
      
       ReturnResult.wrapList = wrapList;
       ReturnResult.ForecastLabel = ForecastLabel;
       ReturnResult.SuggestForecastLabel = SuggestForecastLabel;
       return ReturnResult;
   } //end getWrapList
 

   public class returnResult{
      @AuraEnabled public List<wrapperclass> wrapList{get;set;}
      @AuraEnabled public String ForecastLabel{get;set;}
      @AuraEnabled public String SuggestForecastLabel{get;set;}
   }

   public class wrapperClass{
       @AuraEnabled public Boolean selected{get;set;}
       @AuraEnabled public String Status {get; set;}
       @AuraEnabled public String RecordName {get; set;}
       @AuraEnabled public String RecordId {get; set;}
       @AuraEnabled public String RecordObject {get; set;}
       @AuraEnabled public String AssignedToName {get; set;}
       @AuraEnabled public String ApproverName {get; set;}
       @AuraEnabled public String ApproverId{get;set;}
       @AuraEnabled public String CreatedDate {get; set;}
       @AuraEnabled public String COMPLETEDDATE{get;set;}
       @AuraEnabled public String LASTMODIFIEDDATE{get;set;}
         
         
       @AuraEnabled public String AccountName {get;set;}
       @AuraEnabled public String AccountId {get;set;}
       @AuraEnabled public String AltAccountNumber {get;set;}
         
       @AuraEnabled public String SKU {get;set;}
       @AuraEnabled public String SKUDesc {get;set;}
       @AuraEnabled public String OnHand {get;set;}
       @AuraEnabled public String Month3Avg {get;set;}
         
       @AuraEnabled public String Forecasts{get;set;}
       @AuraEnabled public String ForecastCurr{get;set;}
       @AuraEnabled public String ForecastNext{get;set;}
       @AuraEnabled public String ForecastNextPlus1{get;set;}
       @AuraEnabled public String ForecastNextPlus2{get;set;}
         
       @AuraEnabled public String Suggesteds{get;set;}
       @AuraEnabled public String SuggestedNext{get;set;}
       @AuraEnabled public String SuggestedNextPlus1{get;set;}
       @AuraEnabled public String SuggestedNextPlus2{get;set;}
         
       @AuraEnabled public String Reserved{get;set;}
       @AuraEnabled public String InTransit{get;set;}
       @AuraEnabled public String OnOrder{get;set;}
       @AuraEnabled public String DOS{get;set;}
       @AuraEnabled public String SKUWidthLength {get;set;}
         
       @AuraEnabled public String SKUWidth{get;set;}
       @AuraEnabled public String SKULength{get;set;}
       
       @AuraEnabled public String orderReqId {get;set;}
       @AuraEnabled public String id {get;set;}
       @AuraEnabled public String Reassign {get;set;}
       @AuraEnabled public String ApproveReject {get;set;}
       @AuraEnabled public String processOne{get;set;}
       @AuraEnabled public String SalesApproverBK{get;set;}
       @AuraEnabled public String SalesApprover{get;set;}     
       @AuraEnabled public String ApproverBKApprover {get;set;}      
         
       @AuraEnabled public String OrderRequestQty {get;set;}
       @AuraEnabled public String UnitofMeasure {get;set;}
       @AuraEnabled public String SuggestedQty {get;set;}
       @AuraEnabled public String DesiredArrivalDate {get;set;}
         //CASE(Risk_Level__c , '0', 'Go', '1', 'Low','2','Med','3','High','')
         @AuraEnabled  public String Risk {get;set;}
         @AuraEnabled public String RiskGo {get;set;}
         @AuraEnabled public String RiskLow {get;set;}
         @AuraEnabled public String RiskMed {get;set;}
         @AuraEnabled public String RiskHigh {get;set;}
         
         @AuraEnabled public String UPI {get;set;}
         @AuraEnabled public String MRI {get;set;}
         
         @AuraEnabled public String OrderNumber {get;set;}
         @AuraEnabled public String OrderDate {get;set;}
         @AuraEnabled public String PurchaseOrderStatus {get;set;}
         
         //try it
         @AuraEnabled public boolean hasMsg{get;set;}
         @AuraEnabled public String myMsg {get;set;}
    
     }
     
 
 
 
    public static String getSearchOrdReqStatus(String SearchPickStatus){
       if (SearchPickStatus =='Approved') 
          return 'Sent to ERP';
       else if (SearchPickStatus =='Pending')
          return 'Awaiting Approval';
       else if (SearchPickStatus =='Rejected')
          return 'Rejected';
       else if (SearchPickStatus =='Recalled')
          return 'Recalled';
                  
       return 'Pending';
   }    
   
   @AuraEnabled(cacheable=true)
   public static List<User> getUsers() {
       return [
           SELECT Id, Name
           FROM User
           WHERE IsActive = true
               AND Region__c != 'Ryerson China'
               AND (User_Type__c = 'ISM' OR User_Type__c = 'OSM' OR User_Type__c = 'GM' OR User_Type__c = 'RPM' OR User_Type__c = 'EMP' OR User_Type__c = 'EXM' OR User_Type__c = 'PDM')
           ORDER BY Name
       ];
   }


   @AuraEnabled(cacheable=true)
   public static Gbl_Utl_Lkup__c getGbl_Utl_Lkup() {
       return [
         Select By_Environment__c, report_link__c, report_link2__c,report_link3__c,
               report_link4__c,report_link5__c from Gbl_Utl_Lkup__c 
               where apex_name__c ='UsersSIOPApproveSearch' and Email_Flag__c ='Y' limit 1
       ];
   }

 
 
   }