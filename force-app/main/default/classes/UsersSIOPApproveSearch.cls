/* mz 7/3/2020 CO193841
* Search return 100
allow search with date range system.today().addDays(-31) and with following AND search fields
            //1 searchPickUser/SearchPickStatus/searchAltAccount/searchSKU
            //2 searchPickUser/SearchPickStatus/searchAltAccount
            //3 searchPickUser/SearchPickStatus/searchSKU
            //4 searchPickUser/searchAltAccount/searchSKU
            //5 SearchPickStatus/searchAltAccount/searchSKU
            //6 searchPickUser/SearchPickStatus
            //7 SearchPickStatus/searchAltAccount
            //8 SearchPickStatus/searchSKU
            //9 searchPickUsers/SearchAltAccount
            //10 searchPickUser/searchSKU
            //11 searchAltAccount/searchSKU
            //12 searchPickUser
            //13 SearchPickStatus
            //14 searchAltAccount
            //15 searchSKU
            //16 all blank
            
mz 9/30/2021 CO#273476   
mz 11/15/2021 .setScale(0)  
mz 1/20/2022 - CO299852 add final Approval   
mz 4/1/2022 CO #315291    
issue Incident #339816
mz 4/22/2023 Point to Order group
*/
public with sharing class UsersSIOPApproveSearch {
   private ApexPages.StandardController stdCtrl{get; set;}
   public Integer totRecord {get;set;}
   
   public PageReference runSearch() {   
           
         PageReference  redirecturl = new PageReference('/apex/UsersSIOPApproveSearchPage');
         
         WrapList = getWrapList();
         
         return redirecturl;
         
         
    }
    
   public Boolean isCurrSalesConsoleApp {get;set;} 
   public Boolean isSalesConsoleApp() {
        String appName = 'Sales Console';

        // Get tab set describes for each app
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        // Iterate through each tab set describe for each app and display the info
        boolean selected = false;
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
            if (tsr.getLabel() == appName) {
                selected = tsr.isSelected();
                break;   
            }           
        }       

        // Selected?
        return selected ? true : false;
   } 
  
   public UsersSIOPApproveSearch (ApexPages.StandardController controller) {
   
        isCurrSalesConsoleApp = isSalesConsoleApp();
                
        SKUwidthlengthLabel ='SKU Width/Length'; 
        
        Map<Integer,String> pickMonthMap = new Map<Integer,String>{1 => 'January', 2 => 'February', 3 => 'March',4 => 'April',5 => 'May',6 => 'June',7 => 'July',8 => 'August',9 => 'September',10 => 'October',11 => 'November',12 => 'December'};  
        
        PickMonthLabel0 ='Current - '+pickMonthMap.get(System.today().month());
        PickMonthLabel1  =(date.today().addmonths(-1)).Year() +' - ' + pickMonthMap.get((date.today().addmonths(-1)).month());
        PickMonthLabel2  =(date.today().addmonths(-2)).Year() +' - ' +pickMonthMap.get((date.today().addmonths(-2)).month());
        PickMonthLabel3 = (date.today().addmonths(-3)).Year() +' - ' +pickMonthMap.get((date.today().addmonths(-3)).month());
        PickMonthLabel4  =(date.today().addmonths(-4)).Year() +' - ' +pickMonthMap.get((date.today().addmonths(-4)).month());
        PickMonthLabel5 = (date.today().addmonths(-5)).Year() +' - ' +pickMonthMap.get((date.today().addmonths(-5)).month());
   
        wrapList = getWrapList();
    
        //search altAccount
        searchAltAccount ='';
         
        //search SKU
        searchSKU ='';
        
        //pick Approve status
        pickStatus = new List<SelectOption>();
             
        //default Pending
        searchPickStatus ='Pending';
        ////pickStatus.add(new SelectOption('',''));
        pickStatus.add(new SelectOption('Pending','Pending'));
        pickStatus.add(new SelectOption('Approved','Approved'));
        pickStatus.add(new SelectOption('Rejected','Rejected'));
        pickStatus.add(new SelectOption('Recalled','Recalled'));
     
     
        //pick Month
        pickMonth = new List<SelectOption>();
             
        //default Current 
        searchPickMonth ='0';
        pickMonth.add(new SelectOption('0',PickMonthLabel0 ));
        pickMonth.add(new SelectOption('1',PickMonthLabel1));
        pickMonth.add(new SelectOption('2',PickMonthLabel2 ));
        pickMonth.add(new SelectOption('3',PickMonthLabel3));
        pickMonth.add(new SelectOption('4',PickMonthLabel4));
        pickMonth.add(new SelectOption('5',PickMonthLabel5));
        //pick Object
        pickObject = new List<SelectOption>();
             
        //default Forecast
        searchPickObject ='Order Request';
        pickObject.add(new SelectOption('Order Request','Order Request'));
        
        
        //pickUser
        pickUser =new List<SelectOption>();
        pickUser.add(new SelectOption('',''));
          
        for(user u: [select id, name from User where IsActive = true and Region__c != 'Ryerson China' and (User_Type__c ='ISM' or User_Type__c ='OSM' or User_Type__c ='GM' or User_Type__c ='RPM' or User_Type__c ='EMP'or User_Type__c ='EXM' or User_Type__c ='PDM') order by name]) {
          pickUser.add(new SelectOption(u.id,u.name));
        }
      
        
        totRecord =wrapList.size();
         
        if (searchPickStatus == null && searchPickStatus =='')
          searchPickStatus='Pending';
        
        //get approve seting key
        Gbl_Utl_Lkup__c[] sysEnvList =[select By_Environment__c, report_link__c, report_link2__c,report_link3__c,report_link4__c,report_link5__c from Gbl_Utl_Lkup__c where apex_name__c ='UsersSIOPApproveSearch' and Email_Flag__c ='Y' limit 1 ];
        for(Gbl_Utl_Lkup__c aEnv:sysEnvList ){   
          if (aEnv.By_Environment__c!= null)
            sysEnv =aEnv.By_Environment__c;    
           if (aEnv.Report_Link__c!= null)
             forecastApproveKey = aEnv.report_link__c;
             
           if (aEnv.Report_Link2__c!= null)
             ordReqApproveKey = aEnv.Report_Link2__c;
             
           if (aEnv.Report_Link3__c!= null)
             ordReqApproveMMKey = aEnv.Report_Link3__c;  
           
           if (aEnv.Report_Link4__c!= null)
             ordReqApproveMMOldKey = aEnv.Report_Link4__c;  
             
           if (aEnv.Report_Link5__c!= null)
             ordReqApproveMMOld2Key = aEnv.Report_Link5__c;      

        }    
        
        SearchDate = system.today().addDays(-90);
   
        runSearch();

   }
   public List<wrapperclass> wrapList = new List<wrapperclass>();
   
   public String ActionComments{get;set;}
   
   public String searchPickStatus {get;set;}
   
   public String searchPickMonth {get;set;}
   
   
   public String searchOrdReqStatus {get;set;}
   
   public String searchPickObject {get;set;}
   public String searchAltAccount {get;set;}
   public String searchSKU {get;set;}
   public String forecastApproveKey {get;set;}
   public String ordReqApproveKey {get;set;}
   public String ordReqApproveMMKey {get;set;}
   public String ordReqApproveMMOldKey {get;set;}
   public String ordReqApproveMMOld2Key {get;set;}
   
   
   public String sysEnv{get;set;}
   public Date searchDate{get;set;}
   public String SearchTotal {get;set;}
   
   
   public List<SelectOption> pickObject {
     get {
         return pickObject;
     }
    set;
   }
   
   public List<SelectOption> pickStatus {
     get {
         return pickStatus;
     }
    set;
   }
   
   public List<SelectOption> pickMonth {
     get {
         return pickMonth;
     }
    set;
   }
   public String searchPickUser {get;set;}
   
   public List<SelectOption> pickUser {
     get {
         return pickUser;
     }
    set;
   }
   
   
   
   public String addMsg{get;set;}
   
   public boolean hasMsg{get;set;}
   
   public String ForecastLabel {get;set;}
   
   public String PickMonthLabel0 {get;set;}
   public String PickMonthLabel1 {get;set;}
   public String PickMonthLabel2 {get;set;}
   public String PickMonthLabel3 {get;set;}
   public String PickMonthLabel4 {get;set;}
   public String PickMonthLabel5 {get;set;}
   
   public String SuggestForecastLabel {get;set;}
   public String SKUwidthlengthLabel {get;set;}
   public String ApproverLabel {get;set;}
   
   
   
   Public Map<String,String> userMap = new Map<String,String>();     
   Public Map<String,String> checkMap = new Map<String,String>();    
   
   public List<wrapperclass> getWrapList() {
        Date startDate;
        Date endDate;
        
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
                   
      return wrapList;
  } //end getWrapList

    public class wrapperClass{
        Public Boolean selected{get;set;}
        public String Status {get; set;}
        public String RecordName {get; set;}
        public String RecordId {get; set;}
        public String RecordObject {get; set;}
        public String AssignedToName {get; set;}
        public String ApproverName {get; set;}
        public String ApproverId{get;set;}
        public String CreatedDate {get; set;}
        public String COMPLETEDDATE{get;set;}
        public String LASTMODIFIEDDATE{get;set;}
        
        
        public String AccountName {get;set;}
        public String AccountId {get;set;}
        public String AltAccountNumber {get;set;}
        
        public String SKU {get;set;}
        public String SKUDesc {get;set;}
        public String OnHand {get;set;}
        public String Month3Avg {get;set;}
        
        public String Forecasts{get;set;}
        public String ForecastCurr{get;set;}
        public String ForecastNext{get;set;}
        public String ForecastNextPlus1{get;set;}
        public String ForecastNextPlus2{get;set;}
        
        public String Suggesteds{get;set;}
        public String SuggestedNext{get;set;}
        public String SuggestedNextPlus1{get;set;}
        public String SuggestedNextPlus2{get;set;}
        
        public String Reserved{get;set;}
        public String InTransit{get;set;}
        public String OnOrder{get;set;}
        public String DOS{get;set;}
        public String SKUWidthLength {get;set;}
        
        public String SKUWidth{get;set;}
        public String SKULength{get;set;}
          
        public String id {get;set;}
        public String Reassign {get;set;}
        public String ApproveReject {get;set;}
        public String processOne{get;set;}
        public String SalesApproverBK{get;set;}
        public String SalesApprover{get;set;}     
        public String ApproverBKApprover {get;set;}      
        
        public String OrderRequestQty {get;set;}
        public String UnitofMeasure {get;set;}
        public String SuggestedQty {get;set;}
        public String DesiredArrivalDate {get;set;}
        //CASE(Risk_Level__c , '0', 'Go', '1', 'Low','2','Med','3','High','')
        public String Risk {get;set;}
        public String RiskGo {get;set;}
        public String RiskLow {get;set;}
        public String RiskMed {get;set;}
        public String RiskHigh {get;set;}
        
        public String UPI {get;set;}
        public String MRI {get;set;}
        
        public String OrderNumber {get;set;}
        public String OrderDate {get;set;}
        public String PurchaseOrderStatus {get;set;}
        
        //try it
        public boolean hasMsg{get;set;}
        public String myMsg {get;set;}
   
    }
    
   private String getSearchOrdReqStatus(String SearchPickStatus){
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

  }