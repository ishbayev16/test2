import { LightningElement, track, wire } from 'lwc';

import getOrderRequests from '@salesforce/apex/GetOrderRequestDataController.getOrderRequests'

export default class TestLwc extends LightningElement {

    //@wire(getOrderRequests) wiredoOrderRequests;

    @track orderRequests;
     // Sample pickMonthOptions array
    pickMonthOptions = [
        { label: 'January', value: 'January' },
        { label: 'February', value: 'February' },
        { label: 'March', value: 'March' },
        { label: 'April', value: 'April' },
        { label: 'May', value: 'May' },
        { label: 'June', value: 'June' },
        { label: 'July', value: 'July' },
        { label: 'August', value: 'August' },
        { label: 'September', value: 'September' },
        { label: 'October', value: 'October' },
        { label: 'November', value: 'November' },
        { label: 'December', value: 'December' }
    ];

        // Tracked properties
    @track searchPickMonth = '';

    // Event handler
    handlePickMonthChange(event) {
        this.searchPickMonth = event.target.value;
    }

     // Constants
  pickStatusOptions = [
    { label: 'Option 1', value: 'Option 1' },
    { label: 'Option 2', value: 'Option 2' },
    { label: 'Option 3', value: 'Option 3' }
  ];

  // Tracked properties
  @track searchPickStatus = '';

  // Event handler
  handlePickStatusChange(event) {
    this.searchPickStatus = event.target.value;
  }

  // Constants
  pickUserOptions = [
    { label: 'User 1', value: 'User 1' },
    { label: 'User 2', value: 'User 2' },
    { label: 'User 3', value: 'User 3' }
  ];

  // Tracked properties
  @track searchPickUser = '';

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


  handleSearch() {
    // Perform search logic here

    console.log('search cliecked');
    getOrderRequests()
    .then(result => {
            this.orderRequests = result;
    })
    .catch( error=>{
        this.orderRequests = null;
    });

    console.log('fecthed results', this.orderRequests);

  }


  wrapList = [
    {
      Status: 'Pending',
      RiskGo: 'Low',
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


}