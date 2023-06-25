@isTest
public class UsersSIOPApproveSearchNewTest {
	@IsTest
    public static void testGetUsers() {
        // Create test data
        List<User> testUsers = new List<User>();
        testUsers.add(new User(
            FirstName = 'User1',
            LastName = 'lastname1',
            IsActive = true,
            Region__c = 'Region1',
            User_Type__c = 'ISM',
            Username = 'testusr1@example.com',
            Email = 'testuser1@example.com',
            Alias = 'ttuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = '00e0h000001D1q7AAC', // Replace with the actual Profile Id
            LanguageLocaleKey = 'en_US'
        ));
        testUsers.add(new User(
           FirstName = 'User2',
            LastName = 'lastname2',
            IsActive = true,
            Region__c = 'Region2',
            User_Type__c = 'OSM',
            Username = 'testusr2@example.com',
            Email = 'testuser2@example.com',
            Alias = 'ttuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = '00e0h000001D1q7AAC', // Replace with the actual Profile Id
            LanguageLocaleKey = 'en_US'
        ));
        insert testUsers;

        Test.startTest();
        // Call the method to be tested
        List<User> result = UsersSIOPApproveSearchNew.getUsers();
        Test.stopTest();

    }
    
    @IsTest
    public static void testGetGblUtlLkup() {
        // Create test data
        Gbl_Utl_Lkup__c testRecord = new Gbl_Utl_Lkup__c(
            By_Environment__c = 'Test Environment',
            report_link__c = 'Test Report Link',
            report_link2__c = 'Test Report Link 2',
            report_link3__c = 'Test Report Link 3',
            report_link4__c = 'Test Report Link 4',
            report_link5__c = 'Test Report Link 5',
            apex_name__c = 'UsersSIOPApproveSearch',
            Email_Flag__c = 'Y'
        );
        insert testRecord;

        Test.startTest();
        // Call the method to be tested
        Gbl_Utl_Lkup__c result = UsersSIOPApproveSearchNew.getGbl_Utl_Lkup();
        Test.stopTest();

    }
    
    @IsTest
    public static void testGetSearchOrdReqStatus() {
        // Test with 'Approved' status
        String approvedStatus = UsersSIOPApproveSearchNew.getSearchOrdReqStatus('Approved');
        System.assertEquals('Sent to ERP', approvedStatus, 'Status should be "Sent to ERP"');

        // Test with 'Pending' status
        String pendingStatus = UsersSIOPApproveSearchNew.getSearchOrdReqStatus('Pending');
        System.assertEquals('Awaiting Approval', pendingStatus, 'Status should be "Awaiting Approval"');

        // Test with 'Rejected' status
        String rejectedStatus = UsersSIOPApproveSearchNew.getSearchOrdReqStatus('Rejected');
        System.assertEquals('Rejected', rejectedStatus, 'Status should be "Rejected"');

        // Test with 'Recalled' status
        String recalledStatus = UsersSIOPApproveSearchNew.getSearchOrdReqStatus('Recalled');
        System.assertEquals('Recalled', recalledStatus, 'Status should be "Recalled"');

        // Test with an unknown status
        String unknownStatus = UsersSIOPApproveSearchNew.getSearchOrdReqStatus('Unknown');
        System.assertEquals('Pending', unknownStatus, 'Status should be "Pending"');
    }
       
       
    
    
      @IsTest(SeeAllData=true)
    public static void testGetWrapList() {
        String PickMonthLabel0;
        String PickMonthLabel1;
        String PickMonthLabel2;
        String PickMonthLabel3;
        String PickMonthLabel4;
        String PickMonthLabel5;
        
        Map<Integer,String> pickMonthMap = new Map<Integer,String>{1 => 'January', 2 => 'February', 3 => 'March',4 => 'April',5 => 'May',6 => 'June',7 => 'July',8 => 'August',9 => 'September',10 => 'October',11 => 'November',12 => 'December'};  
        
        PickMonthLabel0 ='Current - '+pickMonthMap.get(System.today().month());
        PickMonthLabel1  =(date.today().addmonths(-1)).Year() +' - ' + pickMonthMap.get((date.today().addmonths(-1)).month());
        PickMonthLabel2  =(date.today().addmonths(-2)).Year() +' - ' +pickMonthMap.get((date.today().addmonths(-2)).month());
        PickMonthLabel3 = (date.today().addmonths(-3)).Year() +' - ' +pickMonthMap.get((date.today().addmonths(-3)).month());
        PickMonthLabel4  =(date.today().addmonths(-4)).Year() +' - ' +pickMonthMap.get((date.today().addmonths(-4)).month());
        PickMonthLabel5 = (date.today().addmonths(-5)).Year() +' - ' +pickMonthMap.get((date.today().addmonths(-5)).month());
        
        String searchAltAccount;
        String searchSKU;
       	String searchPickUser;
        String ordReqApproveKey; 
        String ordReqApproveMMKey;
        String searchPickStatus;
        String searchPickMonth;
        
        String sysEnv;
        String forecastApproveKey;
        String ordReqApproveMMOldKey;
        String ordReqApproveMMOld2Key;
        
        List<User> users = UsersSIOPApproveSearchNew.getUsers();
        Gbl_Utl_Lkup__c gbl_utl_lkup = UsersSIOPApproveSearchNew.getGbl_Utl_Lkup();
        
        if (gbl_utl_lkup.By_Environment__c!= null)
            sysEnv =gbl_utl_lkup.By_Environment__c;    
        if (gbl_utl_lkup.Report_Link__c!= null)
            forecastApproveKey = gbl_utl_lkup.report_link__c;
        
        if (gbl_utl_lkup.Report_Link2__c!= null)
            ordReqApproveKey = gbl_utl_lkup.Report_Link2__c;
        
        if (gbl_utl_lkup.Report_Link3__c!= null)
            ordReqApproveMMKey = gbl_utl_lkup.Report_Link3__c;  
        
        if (gbl_utl_lkup.Report_Link4__c!= null)
            ordReqApproveMMOldKey = gbl_utl_lkup.Report_Link4__c;  
        
        if (gbl_utl_lkup.Report_Link5__c!= null)
            ordReqApproveMMOld2Key = gbl_utl_lkup.Report_Link5__c; 
        
        
        
        searchPickStatus = 'Pending';
        searchPickMonth = '0';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
         searchPickMonth = '1';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
         searchPickMonth = '2';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
         searchPickMonth = '3';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
         searchPickMonth = '4';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
         searchPickMonth = '5';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        //1
        searchPickUser = users[0].id;
        searchAltAccount = 'test';
        searchSKU = 'test';
        searchPickStatus = 'Pending';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
        //2
        searchSKU = '';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
        //3
        searchAltAccount = '';
        searchSKU = 'test';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
        //4
        SearchPickStatus = null;
        searchSKU = 'test';
        searchAltAccount = 'test';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
        //5
        searchPickUser = null;
         SearchPickStatus = 'Recalled';
        searchSKU = 'test';
        searchAltAccount = 'test';
       
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
        //6
        searchPickUser = users[0].id;
        SearchPickStatus = 'Rejected';
        searchSKU = null;
        searchAltAccount = null;
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        //7    
        searchPickUser = null;
        searchSKU = null;
        SearchPickStatus = 'Approved';
        searchAltAccount = 'test';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
        searchPickUser = users[0].id;
        SearchPickStatus = null;
        searchSKU = null;
        searchAltAccount = 'test';
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
         searchPickUser = null;
        SearchPickStatus = 'Pending';
        searchSKU = 'test';
        searchAltAccount = null;
        
        UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
        //9
          searchPickUser = users[0].id;
        SearchPickStatus = null;
        searchSKU = 'test';
        searchAltAccount = null;

          UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
        //10
          searchPickUser = null;
        SearchPickStatus = null;
        searchSKU = 'test';
        searchAltAccount = 'test';
        
        
          UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        //11
         searchPickUser = users[0].id;
        SearchPickStatus = null;
        searchSKU = null;
        searchAltAccount = null;
        
         UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        //12
         searchPickUser = null;
        SearchPickStatus = null;
        searchSKU = null;
        searchAltAccount = 'test';
        
         UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        //13
         searchPickUser = null;
        SearchPickStatus = null;
        searchSKU = 'test';
        searchAltAccount = null;
        
         UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);
        
        searchPickUser = null;
        SearchPickStatus = null;
        searchSKU = null;
        searchAltAccount = null;
        
         UsersSIOPApproveSearchNew.getWrapList(searchAltAccount, searchSKU, searchPickUser , 
            ordReqApproveKey , ordReqApproveMMKey , searchPickStatus,
            searchPickMonth);

    }
    
}