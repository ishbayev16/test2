import { LightningElement, track, wire, api } from 'lwc';
import getUsers from '@salesforce/apex/UsersSIOPApproveSearchNew.getUsers';
import getWrapList from '@salesforce/apex/UsersSIOPApproveSearchNew.getWrapList';

const CHUNK_SIZE = 50;

export default class TestLwc extends LightningElement {

    //@wire(getOrderRequests) wiredoOrderRequests;  


    // variables used in the controller logic
    isCurrSalesConsoleApp;
    SKUwidthlengthLabel;
    pickMonthMap;
    PickMonthLabel0;
    PickMonthLabel1;
    PickMonthLabel2;
    PickMonthLabel3;
    PickMonthLabel4;
    PickMonthLabel5;
    wrapList;
    searchAltAccount;
    searchSKU;
    pickStatus;
    searchPickStatus;
    pickMonth;
    searchPickMonth;
    pickObject;
    searchPickObject;
    @track pickUser = [];
    allpickUserLoaded;
    totRecord;
    sysEnv;
    forecastApproveKey;
    ordReqApproveKey;
    ordReqApproveMMKey;
    ordReqApproveMMOldKey;
    ordReqApproveMMOld2Key;
    SearchDate;

    tempPickUser;
    
    @track SearchPickUser;

    @track wrapList;


    connectedCallback() {
      //this.isCurrSalesConsoleApp = this.isSalesConsoleApp();

      this.wrapList = [];

      this.SKUwidthlengthLabel = 'SKU Width/Length';

      this.pickMonthMap = {
          1: 'January',
          2: 'February',
          3: 'March',
          4: 'April',
          5: 'May',
          6: 'June',
          7: 'July',
          8: 'August',
          9: 'September',
          10: 'October',
          11: 'November',
          12: 'December'
      };

      this.PickMonthLabel0 = 'Current - ' + this.pickMonthMap[new Date().getMonth() + 1];
      this.PickMonthLabel1 = new Date().getFullYear() + ' - ' + this.pickMonthMap[new Date().getMonth()];
      this.PickMonthLabel2 = new Date().getFullYear() + ' - ' + this.pickMonthMap[new Date().getMonth() - 1];
      this.PickMonthLabel3 = new Date().getFullYear() + ' - ' + this.pickMonthMap[new Date().getMonth() - 2];
      this.PickMonthLabel4 = new Date().getFullYear() + ' - ' + this.pickMonthMap[new Date().getMonth() - 3];
      this.PickMonthLabel5 = new Date().getFullYear() + ' - ' + this.pickMonthMap[new Date().getMonth() - 4];

      //this.wrapList = this.getWrapList();

      this.searchAltAccount = '';

      this.searchSKU = '';

      this.pickStatus = [
          { label: 'Pending', value: 'Pending' },
          { label: 'Approved', value: 'Approved' },
          { label: 'Rejected', value: 'Rejected' },
          { label: 'Recalled', value: 'Recalled' }
      ];

      this.searchPickStatus = 'Pending';

      this.pickMonth = [
          { label: this.PickMonthLabel0, value: '0' },
          { label: this.PickMonthLabel1, value: '1' },
          { label: this.PickMonthLabel2, value: '2' },
          { label: this.PickMonthLabel3, value: '3' },
          { label: this.PickMonthLabel4, value: '4' },
          { label: this.PickMonthLabel5, value: '5' }
      ];

      this.searchPickMonth = '0';

      this.pickObject = [{ label: 'Order Request', value: 'Order Request' }];

      this.searchPickObject = 'Order Request';

      //this.SearchPickUser = 'null';
      this.allpickUserLoaded = false;
      //his.pickUser = [{ label: 'null1', value: 'null' },{ label: 'null2', value: 'null2' }];

      this.tempPickUser = [];
      this.tempPickUser.push({label: '', value: ''});
      this.pickUser = [];
      //this.pickUser.push({label: '', value: 'null'});

      getUsers()
        .then( result =>{

          for(let u of result){
            console.log('u ', u);
            this.tempPickUser.push({label: u.Name, value: u.Id});
            //this.pickUser.push({label: u.Name, value: u.Id});
            console.log('pickuserrrr', this.pickUser); 
          }

          this.pickUser = this.tempPickUser;
          this.SearchPickUser = this.tempPickUser[0].value;
          //this.SearchPickUser = this.pickUser[0].value;
          //this.SearchPickUser = 'null';
          this.allpickUserLoaded = result.length === 0;

        }).catch(error =>{
          console.log('Error user ', error )
        })
        
       console.log('pickuser', this.pickUser); 

  }

    // Event handler
    handlePickMonthChange(event) {
        this.searchPickMonth = event.target.value;
    }

  // Event handler
  handlePickStatusChange(event) {
    this.searchPickStatus = event.target.value;
  }

  // Event handler
  handlePickUserChange(event) {
    this.searchPickUser = event.target.value;
  }

  // Tracked properties
  @track searchAltAccount = '';

  // Event handler
  handleSearchAltAccountChange(event) {
    this.searchAltAccount = event.target.value;
  }

  // Tracked properties
  @track searchSKU = '';

  // Event handler
  handleSearchSKUChange(event) {
    this.searchSKU = event.target.value;
  }


  handleSearch= async() => {
    console.log('pickuser', this.SearchPickUser, 'pickuser', this.pickUser , this.userOptions); 

    getWrapList()
      .then(result =>{
          console.log("wrp " , this.wrapList);
          console.log("result wrap ", result);
          this.wrapList = result;
      })
      .catch(error =>{
        console.log("error get wraplist",error);
      })

  }

  /*
  wrapList = [
    {
      Status: 'Pending',
      RiskGo: '',
      RiskLow: 'Medium',
      RiskMed: 'High',
      RiskHigh: 'Critical',
      UPI: '123456',
      MRI: '789012',
      AccountId: '001XXXXXXXXXXXXXXX',
      AccountName: 'Sample Account 1',
      ApproverName: 'John Doe',
      OrderRequestQty: 10,
      UnitofMeasure: 'EA',
      SKU: 'ABC123',
      SKUDesc: 'Sample SKU 1',
      OrderNumber: 'ORD001',
      PurchaseOrderStatus: 'Open',
      DesiredArrivalDate: '2023-06-01',
      OrderDate: '2023-05-30',
      SuggestedQty: 5,
      Month3Avg: 7,
      Forecasts: '10, 8, 9',
      Suggesteds: '6, 7, 5',
      OnHand: 15,
      Reserved: 3,
      InTransit: 2,
      OnOrder: 4,
      SKUWidthLength: '1x2',
      CreatedDate: '2023-05-29',
      RecordId: '001XXXXXXXXXXXXXXX',
      AltAccountNumber: 'ALT001'
    },
    {
      Status: 'Approved',
      RiskGo: 'Low',
      RiskLow: 'Medium',
      RiskMed: 'High',
      RiskHigh: 'Critical',
      UPI: '654321',
      MRI: '210987',
      AccountId: '002XXXXXXXXXXXXXXX',
      AccountName: 'Sample Account 2',
      ApproverName: 'Jane Smith',
      OrderRequestQty: 8,
      UnitofMeasure: 'EA',
      SKU: 'DEF456',
      SKUDesc: 'Sample SKU 2',
      OrderNumber: 'ORD002',
      PurchaseOrderStatus: 'Closed',
      DesiredArrivalDate: '2023-06-02',
      OrderDate: '2023-05-28',
      SuggestedQty: 4,
      Month3Avg: 6,
      Forecasts: '8, 6, 7',
      Suggesteds: '5, 4, 6',
      OnHand: 12,
      Reserved: 2,
      InTransit: 1,
      OnOrder: 3,
      SKUWidthLength: '2x4',
      CreatedDate: '2023-05-27',
      RecordId: '002XXXXXXXXXXXXXXX',
      AltAccountNumber: 'ALT002'
    }
  ];
  */


}