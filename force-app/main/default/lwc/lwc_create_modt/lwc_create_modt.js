import { LightningElement, wire, api, track } from 'lwc';
import googleapiKey from '@salesforce/label/c.GoogleApikey';
import getModtRecord from '@salesforce/apex/PayableDetailsController.getAllFinancialEntityWithDetailsModt';
import upsertMODTRecords from '@salesforce/apex/PayableDetailsController.upsertMODTRecords';
import deleteMODTRecord from '@salesforce/apex/PayableDetailsController.deleteMODTRecord';
import updateMODT from '@salesforce/apex/PayableDetailsController.updateMODT';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_create_modt extends LightningElement {

     /**
      * JS Variables
      */
    @api wrapperDataList = [];
    @api FinancialAccountId; 
    @api isTaskOwnerLogin = false;
    @api initFunctionality = false;
    @api isCalledFromParent = false;
    @api isClosed = false;
    @api compIndex
    @api taskRec;
    @api FinancialAccountRec;
    @api taskId; 

    @track indePendentModtObjectList = [];
    @track modtObject;
    @track tempMOdtStatus;
    @track tempentityTpye;
    @track deleteConatctIds = '';
    @track isClosedMosal = false;
    @track lastFalseRecordId;
    @track isDisabledAddRowButton = false;
    _country = 'IN';
    @track state;
    @track stateCode;
    @track wiredDataa = [];
    @track city;
    @track country;
    @track countryCode;
    @track googleapiKey = googleapiKey;
    @track isShowMODTCOMP = true;
    @track totalClosedRecordsCount;
    @track buttonLabelHandler;
    @track isrecordLevelEdit=false;
    @track TotalGivenAmount=0;
    @track TotalRemaingAmount=0;
    @track showFinancialAccount=false;
    @track AvailableSanctionedamount=0;

    @track SanctionedAmountInwords;
    @track ReceivableAmountInWords;
    @track AvailableSanctionedamountInWords;
    @track TotalGivenAmountInWords;
    @track TotalRemainingAmountInWords;

    @track checknull_values_for_Keys = [{FieldName:'Mortgager_Id__c',errorMessage:'Mortgager Name is Missing'},
    {FieldName:'MODT_Value__c',errorMessage:'MODT Value is Missing'},
    {FieldName:'postalCode',errorMessage:'Postal Code is Missing'},
    {FieldName:'street',errorMessage:'Postal Code Street is Missing'},
    {FieldName:'Date_Of_Execution__c',errorMessage:'Date Of Execution is Missing'}];

    @track ExcludeEntityTypevalues=['Financial Institute','Financial Institute (BT)','Financial Institute (Debt)'];

    @track ModtField_values_Before_submit=[
            {FieldName:'Mortgager_Id__c',errorMessage:'Mortgager Name is Missing'},
            {FieldName:'MODT_Value__c',errorMessage:'MODT Value is Missing'},
            {FieldName:'postalCode',errorMessage:'Postal Code is Missing'},
            {FieldName:'street',errorMessage:'Postal Code Street is Missing'},
            {FieldName:'Date_Of_Execution__c',errorMessage:'Date Of Execution is Missing'},
            {FieldName:'Is_Document_Closed__c',errorMessage:'Document Action Pending'}
    ];

    @track AddressValidations=[
        {FieldName:'postalCode',errorMessage:'Postal Code is Missing'},
        {FieldName:'street',errorMessage:'Postal Code Street is Missing'},
    ];


    @track cssclasslist = ['slds-hint-parent blink', 'slds-hint-parent'];
    
    /**
     * On Page Load This Method will Work
     */
    @wire(getModtRecord, { Financial_AccountId: '$FinancialAccountId' })
    async wiredData(result) {
        this.wiredDataa = result;
        this.TotalRemaingAmount=0;
        this.TotalGivenAmount=0;
        debugger;
        if (result.data) {
            try {
                this.wrapperDataList = result.data;
                let tempData = result.data;
                this.reformData(tempData);
                console.log('Data', result.data);
                console.log('isTaskOwnerLogin', this.isTaskOwnerLogin);
                if (this.isTaskOwnerLogin) {
                    this.isDisabledAddRowButton = false;
                }
                this.AvailableSanctionedamount = parseInt(this.FinancialAccountRec.Sanctioned_Amount__c) - parseInt(this.FinancialAccountRec.Receivables_Amount__c);
                this.TotalRemaingAmount= parseInt(this.FinancialAccountRec.Sanctioned_Amount__c) - parseInt(this.TotalGivenAmount);
                this.SanctionedAmountInwords = this.numberTOwordsIndianCur(this.FinancialAccountRec.Sanctioned_Amount__c);
                this.ReceivableAmountInWords = this.numberTOwordsIndianCur(this.FinancialAccountRec.Receivables_Amount__c);
                this.AvailableSanctionedamountInWords = this.numberTOwordsIndianCur(this.AvailableSanctionedamount);
                this.TotalGivenAmountInWords = this.numberTOwordsIndianCur(this.TotalGivenAmount);
                this.TotalRemainingAmountInWords = this.numberTOwordsIndianCur(this.TotalRemaingAmount);
            } catch (error) {
                
            }   
        } else if (result.error) {
            
        }
    }

    /**
     *  This Method Is Used For Preparing MODT Data
     */
    reformData(tempData) {
        debugger;
        let totalMODTcount = tempData.modtlist.length;
        let modtCreatedCount = tempData.modtlist.filter(item => item.Status__c !== 'Draft').length;
        console.log('MODT Created count:', modtCreatedCount);
        debugger;
        let temOBjectKist = []
        let ListOfEditableModt_records = []
        let tempentityTpye = tempData.entityTypesValue.map(type => ({ label: type, value: type }));
        console.log('tempentityTpye From Apex',tempentityTpye);
        tempentityTpye=tempentityTpye.filter(type => {
              return !this.ExcludeEntityTypevalues.includes(type.label);
         });
         console.log('tempentityTpye After Filter',tempentityTpye);
        let tempPayableStatus = tempData.payAbleStatus.map(type => ({ label: type, value: type }));
        let temppaymentMode = tempData.paymentModeTypesValues.map(type => ({ label: type, value: type }));
        this.tempMOdtStatus = tempPayableStatus;
        this.tempentityTpye = tempentityTpye;
        for (let i = 0; i < tempData.modtlist.length; i++) {

            let elem = tempData[i];
            let indePendentModtObject = {};
            indePendentModtObject.index = i;
            indePendentModtObject.relatedFinancialEntity = this.groupByEntityType(tempData.relatedFinancialEntity);
            indePendentModtObject.modtStatusList = tempPayableStatus;
            indePendentModtObject.Status__c = tempData.modtlist[i].Status__c;
            indePendentModtObject.tempentityTpye = tempentityTpye;
            indePendentModtObject.Id = tempData.modtlist[i].Id;
            indePendentModtObject.Date_Of_Execution__c = tempData.modtlist[i].Date_Of_Execution__c;
            indePendentModtObject.Financial_Account__c = tempData.modtlist[i].Financial_Account__c;
            indePendentModtObject.Mortgager_Name__c = tempData.modtlist[i].Mortgager_Name__r.Name;
            indePendentModtObject.Name = tempData.modtlist[i].Name;
            indePendentModtObject.MODT_ID__c = tempData.modtlist[i].MODT_ID__c;
            indePendentModtObject.MODT_Value__c=tempData.modtlist[i].MODT_Value__c!=null && tempData.modtlist[i].MODT_Value__c!=undefined ? tempData.modtlist[i].MODT_Value__c:0 ;

            this.TotalGivenAmount=this.TotalGivenAmount+indePendentModtObject.MODT_Value__c;
            indePendentModtObject.Date_Of_Execution__c = tempData.modtlist[i].Date_Of_Execution__c;
            indePendentModtObject.selectedEntitype = tempData.modtlist[i].Mortgager_Name__r.Entity_Type__c;
            indePendentModtObject.selectedMODTtName = '';
            indePendentModtObject.relatedTypeEnityMap = this.getEntityIdNameMap(indePendentModtObject.selectedEntitype, indePendentModtObject.relatedFinancialEntity)
            indePendentModtObject.Mortgager_Id__c = tempData.modtlist[i].Mortgager_Name__c;
            indePendentModtObject.isStatusDisabled = true;
            indePendentModtObject.isRecordExixst = true;
            indePendentModtObject.isAddressEditabled = true;
            indePendentModtObject.isExecutedOnDisabled = false;
            indePendentModtObject.Is_Document_Closed__c = tempData.modtlist[i].Is_Document_Closed__c;
            indePendentModtObject.Task_Id__c = tempData.modtlist[i].Task_Id__c;
            indePendentModtObject.cssclass = "slds-hint-parent"
            indePendentModtObject.isDisabledAttachement = false;
            
            if (indePendentModtObject.Status__c == 'Draft') {
                if (this.isTaskOwnerLogin && indePendentModtObject.Task_Id__c == this.taskId) {
                    indePendentModtObject.isDisabledAllInput = true
                    indePendentModtObject.isEditable = this.isTaskOwnerLogin==true?true:false;
                    indePendentModtObject.isdeletedisable = false
                    indePendentModtObject.isshoweditButton = true
                    indePendentModtObject.isshowSavebutton = false
                   
                } else {
                    indePendentModtObject.isDisabledAllInput = true
                    indePendentModtObject.isdeletedisable = true
                    indePendentModtObject.isshoweditButton = false
                    indePendentModtObject.isshowSavebutton = false
                }
            } else {
                indePendentModtObject.isDisabledAllInput = true;
                indePendentModtObject.isdeletedisable = true
                indePendentModtObject.isEditable = this.isTaskOwnerLogin==true?true:false;
                indePendentModtObject.isshoweditButton = indePendentModtObject.Task_Id__c == this.taskId && this.isTaskOwnerLogin==true?true:false;
                indePendentModtObject.isshowSavebutton = false;
            }
            //address related fields---
            indePendentModtObject.Place__c = tempData.modtlist[i].Place__c
            indePendentModtObject.postalCode = tempData.modtlist[i].Place__c.postalCode
            indePendentModtObject.state = tempData.modtlist[i].Place__c.state
            indePendentModtObject.CountryCode = tempData.modtlist[i].Place__c.CountryCode
            indePendentModtObject.country = tempData.modtlist[i].Place__c.country
            indePendentModtObject.street = tempData.modtlist[i].Place__c.street
            indePendentModtObject.city = tempData.modtlist[i].Place__c.city

            indePendentModtObject.address = tempData.modtlist[i].Place__c.street + ',' + tempData.modtlist[i].Place__c.city + ',' + tempData.modtlist[i].Place__c.state + ',' + tempData.modtlist[i].Place__c.country + ',' + tempData.modtlist[i].Place__c.postalCode + '-'
            temOBjectKist.push(indePendentModtObject);
        }

        this.indePendentModtObjectList = temOBjectKist
        console.log('this.indePendentModtObjectList', this.indePendentModtObjectList);
    }

    refresh() {
        debugger;
        return refreshApex(this.wiredDataa);
    }

    /**
     * FOR ADDING MODT ROWS
     */
    addRow() {
        debugger;
        if((parseInt(this.FinancialAccountRec.Sanctioned_Amount__c) == this.TotalGivenAmount) && this.TotalRemaingAmount==0){ 
            this.showToast('ERROR','Not Applicable','error');
            this.isDisabledAddRowButton = true;
            return
        }
        this.isDisabledAddRowButton = true;
        let temprelatedFinancialEntity;
        if (this.wrapperDataList.relatedFinancialEntity != null && this.wrapperDataList.relatedFinancialEntity != undefined) {
            temprelatedFinancialEntity = this.groupByEntityType(this.wrapperDataList.relatedFinancialEntity);
        }
        let tempindePendentModtObjectList = this.indePendentModtObjectList;

        let newindePendentModtObject = {
            index: this.indePendentModtObjectList.length,
            relatedFinancialEntity: temprelatedFinancialEntity,
            modtStatusList: this.tempMOdtStatus,
            tempentityTpye: this.tempentityTpye,
            Id: '',
            Date_Of_Execution__c: '',
            Financial_Account__c: this.FinancialAccountId,
            Mortgager_Id__c: '',
            Mortgager_Name__c: '',
            MODT_ID__c: '',
            createdon: new Date().toJSON().slice(0, 10),
            selectedEntitype: '',
            selectedMODTtName: '',
            relatedTypeEnityMap: '',
            isStatusDisabled: true,
            Status__c: 'Draft',
            isRecordExixst: false,
            isExecutedOnDisabled: true,
            isAddressEditabled: true,
            Place__c: '',
            address: 'Please Enter Address',
            postalCode: '',
            city: '',
            country: '',
            proviance: '',
            stateCode: '',
            street: '',
            state: '',
            Is_Document_Closed__c: false,
            isEditable: true,
            Task_Id__c:this.taskId,
            MODT_Value__c:'',
            isshowSavebutton:true

        }
        tempindePendentModtObjectList = [...tempindePendentModtObjectList, newindePendentModtObject];
        this.indePendentModtObjectList = tempindePendentModtObjectList;
        this.HandleDisable_Enable_ActionItems(this.indePendentModtObjectList,newindePendentModtObject.index,'OnAddRow')
    }

    /**
     * FOR DELETING THE MODT RECORDS
     */
    handleDeleteAction(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        if (confirm(" are you Sure want to delete MODT") == true) {
            if (currentIndex) {
                this.deleteRecordBackend(currentIndex);
            }else{
                this.indePendentModtObjectList=this.indePendentModtObjectList.filter(item=>item.index!=cureentId);
                this.showToast('SUCCESS', 'MODT deleted Successfully', 'success', 'dismissable');
                this.HandleDisable_Enable_ActionItems(this.indePendentModtObjectList,cureentId,'OnSave');
                this.validations_for_ModtValue(this.indePendentModtObjectList); 
            }
        } else {
            return;
        }
        // if (isNaN(event.target.dataset.id)) {
        //     this.deleteConatctIds = this.deleteConatctIds + ',' + event.target.dataset.id;
        // }
        // const itemIndex = this.indePendentModtObjectList.findIndex(row => row.index === parseInt(event.target.dataset.id, 10));

        // if (itemIndex !== -1) {
        //     this.indePendentModtObjectList.splice(itemIndex, 1);
        // } else {
        //     // Handle case where item is not found
        //     console.error('Item not found in indePendentModtObjectList');
        // }
        this.isDisabledAddRowButton=false;
    }

    /**
     * COMMON METHOD FOR ONCHANGE Function
     */
    selectionChangeHandler(event) {
        debugger;
        this.closehighlightbar();
        this._country = event.detail.country;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        if (eventName == 'enityName') {
            this.entityTpyeChangeHandler(event);
        } else if (eventName == 'MODTName') {
            this.mODTNameChangeHandeler(event);
        } else if (eventName == 'MODTidName') {
            // this.mODTidNameChangeHandeler(event);
        } else if (eventName == "address") {
            this.addressChangeHandler(event);
        } else if (eventName == "street") {
            this.streetOnChangeaHandler(event);
        } else if (eventName == "DateOfExecution") {
            this.executionDateOnChangeHandler(event)
        }else if (eventName == "MODTValue") {
            this.MODTValueOnChangeHandler(event)
        }
        
    }


    entityTpyeChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        for (let i = 0; i < this.indePendentModtObjectList.length; i++) {
            if (currentIndex == this.indePendentModtObjectList[i].index) {
                this.indePendentModtObjectList[i].relatedTypeEnityMap = this.getEntityIdNameMap(currentValue, this.indePendentModtObjectList[i].relatedFinancialEntity);
            }
        }

    }

    MODTValueOnChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        for (let i = 0; i < this.indePendentModtObjectList.length; i++) {
            if (currentIndex == this.indePendentModtObjectList[i].index) {
                if(currentValue==undefined || currentValue==null || currentValue==''){currentValue=0}
                this.indePendentModtObjectList[i].MODT_Value__c = currentValue;
                break;
            }
        }
       
        let booleanShouldskip=this.validations_for_ModtValue(this.indePendentModtObjectList,currentIndex);
        if(booleanShouldskip==false){
                 this.calculateModtValue(this.indePendentModtObjectList);
        }
    }

    executionDateOnChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        for (let i = 0; i < this.indePendentModtObjectList.length; i++) {
            if (currentIndex == this.indePendentModtObjectList[i].index) {
                this.indePendentModtObjectList[i].Date_Of_Execution__c = currentValue;
                break;
            }
        }
        // this.Check_mandatory_field_validation(this.indePendentModtObjectList, currentIndex);
    }

    mODTNameChangeHandeler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        for (let i = 0; i < this.indePendentModtObjectList.length; i++) {
            if (currentIndex == this.indePendentModtObjectList[i].index) {
                this.indePendentModtObjectList[i].Mortgager_Id__c = currentValue;
            }
        }
        // this.Check_mandatory_field_validation(this.indePendentModtObjectList, currentIndex);
    }

    mODTidNameChangeHandeler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        if (this.validateMODTid(this.indePendentModtObjectList, currentValue)) {
            for (let i = 0; i <= this.indePendentModtObjectList.length; i++) {
                if (currentIndex == this.indePendentModtObjectList[i].index) {
                    this.indePendentModtObjectList[i].MODT_ID__c = currentValue;
                    break;
                }
            }
        } else {
            for (let i = 0; i <= this.indePendentModtObjectList.length; i++) {
                if (currentIndex == this.indePendentModtObjectList[i].index) {
                    this.indePendentModtObjectList[i].MODT_ID__c = '';
                    this.isDisabledAddRowButton = true;
                    return;
                }
            }
        }

        setTimeout(() => {
            this.Check_mandatory_field_validation(this.indePendentModtObjectList, currentIndex);
          }, 3000);
    }

    showAddressInputFomratPOPUP(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let currentTitle = event.target.title
        let prevIndex = currentIndex - 1;
        let tabClosedModal = false;
        for (let i = 0; i < this.indePendentModtObjectList.length; i++) {
            if (currentIndex == this.indePendentModtObjectList[i].index) {
                this.indePendentModtObjectList[i].isAddressEditabled = false;
                this.lastFalseRecordId = i;
                tabClosedModal = true

            }
        }
        if (tabClosedModal) {
            this.isClosedMosal = true;
        }

    }
    @track postalCode;
    addressChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        if (currentValue.length == 6) {
            this.handlePincodeChange(event, currentIndex);
        }
    }

    streetOnChangeaHandler(event) {
        debugger
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        for (let i = 0; i < this.indePendentModtObjectList.length; i++) {
            if (this.lastFalseRecordId == this.indePendentModtObjectList[i].index) {
                this.indePendentModtObjectList[i].street = currentValue;

            }
        }
        // this.Check_mandatory_field_validation(this.indePendentModtObjectList, this.lastFalseRecordId);
    }


    mapAddressRelatedFiledFromApiValues(city, stateCode, province, country, pincode, index) {
        debugger;
        var tempindpendentmodtList = [...this.indePendentModtObjectList];
        for (let i = 0; i < tempindpendentmodtList.length; i++) {
            if (index == tempindpendentmodtList[i].index) {
                tempindpendentmodtList[i].city = city;
                tempindpendentmodtList[i].country = country;
                tempindpendentmodtList[i].province = province;
                tempindpendentmodtList[i].stateCode = stateCode;
                tempindpendentmodtList[i].state = stateCode;
                tempindpendentmodtList[i].postalCode = pincode;
                tempindpendentmodtList[i].isAddressEditabled = false;
                this.lastFalseRecordId = index;
                setTimeout(() => {
                    this.isClosedMosal = true;
                }), "5000"
            }
        }
        this.indePendentModtObjectList = tempindpendentmodtList;
        // this.Check_mandatory_field_validation(this.indePendentModtObjectList, index);
    }

    closeAddressModal(event) {
        debugger
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        const index = event.target.dataset.index; // Get the index from the button's dataset
        const id = event.target.dataset.id;
        for (let i = 0; i < this.indePendentModtObjectList.length; i++) {
            if (this.lastFalseRecordId == this.indePendentModtObjectList[i].index) {
                this.indePendentModtObjectList[i].isAddressEditabled = true;
                this.isClosedMosal = false;
            }
        }
    }

    validations_for_ModtValue(modtlist,currentIndex){
        debugger;
        let sanctionedAmount =parseInt(this.FinancialAccountRec.Sanctioned_Amount__c);

        let v_TotalGivenAmount=0;
        let v_RemaingAmount=0;
        let v_pastTotalGivenAmount=this.TotalGivenAmount;
        let v_TotalRemaingAmount=this.TotalRemaingAmount;
        let shouldskip=false;

        if(modtlist.length>0){
            modtlist.forEach((item)=>{
                v_TotalGivenAmount=v_TotalGivenAmount+parseInt(item.MODT_Value__c); 
            })
        }

        if((sanctionedAmount!=null && sanctionedAmount!=undefined) && (v_TotalGivenAmount!=null && v_TotalGivenAmount!=undefined)){
            console.log('TotalGivenAmount',v_TotalGivenAmount);
            console.log('sanctionedAmount',sanctionedAmount);
            v_RemaingAmount= sanctionedAmount-v_TotalGivenAmount
            console.log('RemaingAmount',v_RemaingAmount);

            if((v_RemaingAmount<0)){

                this.showToast('Error','MODT Value Is Greater Than Sanction Amount','error');
                this.indePendentModtObjectList[currentIndex].MODT_Value__c='';
                this.TotalGivenAmount=v_pastTotalGivenAmount;
                this.TotalRemaingAmount=v_TotalRemaingAmount;
                shouldskip=true;
            }else{
                this.TotalGivenAmount=v_TotalGivenAmount;
                this.TotalGivenAmountInWords=this.numberTOwordsIndianCur(this.TotalGivenAmount)
                this.TotalRemaingAmount=v_RemaingAmount;
                this.TotalRemainingAmountInWords=this.numberTOwordsIndianCur(this.TotalRemaingAmount)
                shouldskip=false;
            }
        }
       return shouldskip==true ?false:true;
    }

    calculateModtValue(modtlist){
        debugger;
        let sanctionedAmount =parseInt(this.FinancialAccountRec.Sanctioned_Amount__c);

        let v_TotalGivenAmount=0;
        let v_RemaingAmount=0;
       
        if(modtlist.length>0){
            modtlist.forEach((item)=>{
                if(item.MODT_Value__c){
                    v_TotalGivenAmount=v_TotalGivenAmount+parseInt(item.MODT_Value__c);  
                }
            })
        }
        if((sanctionedAmount!=null && sanctionedAmount!=undefined) && (v_TotalGivenAmount!=null && v_TotalGivenAmount!=undefined)){
             
                console.log('TotalGivenAmount',v_TotalGivenAmount);
                console.log('sanctionedAmount',sanctionedAmount);
                v_RemaingAmount= sanctionedAmount-v_TotalGivenAmount
                console.log('RemaingAmount',v_RemaingAmount);
            
                this.TotalGivenAmount=v_TotalGivenAmount;
                this.TotalGivenAmountInWords=this.numberTOwordsIndianCur(this.TotalGivenAmount);
                this.TotalRemaingAmount=v_RemaingAmount;
                this.TotalRemainingAmountInWords=this.numberTOwordsIndianCur(this.TotalRemaingAmount)
        }
        
    }

    @track choosenRecordId;
    @track choosenDocumentHandlerId;
    openDocumentCOMP(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let currentTitle = event.target.title
        let prevIndex = currentIndex - 1;
        this.choosenRecordId = currentValue;
        this.choosenDocumentHandlerId = currentIndex;
        this.isShowMODTCOMP = false
        let isrecordleveledit=this.indePendentModtObjectList.find((item)=>item.Id==currentIndex).isEditable;
         this.isrecordLevelEdit=isrecordleveledit;
    }

    // Function to create a map based on Financial_Entity__r.Entity_Type__c
    groupByEntityType(list) {
        debugger
        const groupedMap = new Map();
        list.forEach((item) => {
            const entityType = item.Entity_Type__c;
            if (!groupedMap.has(entityType)) {
                groupedMap.set(entityType, []);
            }
            groupedMap.get(entityType).push(item);
        });
        return groupedMap;
    }

    getEntityIdNameMap(entityType, groupedMap) {
        debugger;
        let entityMapList = [];

        if (groupedMap.has(entityType)) {
            const entities = groupedMap.get(entityType);
            entities.forEach((entity) => {
                const label = entity.Name; // Assuming Name is the label
                const value = entity.Id; // Assuming Id is the value
                const entityObj = { label, value };
                entityMapList.push(entityObj);
            });
        }
        return entityMapList;
    }

    createIdNameMapByEntityType(list, entityType) {
        debugger;
        const entityMap = new Map();
        list.forEach((item) => {
            if (item.Financial_Entity__r.Entity_Type__c === entityType) {
                entityMap.set(item.Id, item.Name);
            }
        });
        return entityMap;
    }

    @api handleSaveAction(event) {
        debugger

        this.buttonLabelHandler = 'Save Button Handler';
        let get_TaskId_Related_Modt=this.indePendentModtObjectList.filter((item)=>item.Task_Id__c == this.taskId);
        console.log('get_TaskId_Related_Modt', get_TaskId_Related_Modt);
        if(get_TaskId_Related_Modt.length == 0) {  this.buttonLabelHandler=''; this.showToast('ERROR', 'No MODT is Created For this Process To Proceed Further', 'error'); return}
        let returnbooleanvalue = this.check_modt_closed_validation(get_TaskId_Related_Modt);

        if (returnbooleanvalue == true && this.TotalRemaingAmount==0) {
            let status = 'MODT Created'
            this.processDataMethod(get_TaskId_Related_Modt, status);
            // if (confirm(" are you Sure want to proceed") == true) {
                
            // }
            // else {

            // }
        } else if(this.TotalRemaingAmount!=0){
            this.showToast('ERROR','MODT Value Should Be Equals To The Sanctioned Amount','error')
            this.buttonLabelHandler = '';
         }//else{
        //     this.showToast('ERROR','Something Went Wrong Please Contact System Admin','error')
        //     this.buttonLabelHandler = '';
        // }
    }

    closehighlightbar() {
        debugger;
        this.indePendentModtObjectList.find((item) => {
            if (this.cssclasslist.includes(item.cssclass) == true) {
                item.cssclass = 'slds-hint-parent';
            }
        })
    }
           
    check_modt_closed_validation(modtlist) {
        debugger;
        let shouldskip = false;
        if (modtlist.length > 0) {
            modtlist.forEach(currentItem => {
                if (shouldskip) { return }
                if (currentItem != null && currentItem.isEditable) {
                     this.ModtField_values_Before_submit.forEach((item)=>{
                        if (shouldskip) { return }
                        if(currentItem[item.FieldName]==null || currentItem[item.FieldName]==undefined || currentItem[item.FieldName]==''){
                            shouldskip = true;
                            currentItem.cssclass = 'slds-hint-parent blink';
                            this.showToast('ERROR', item.errorMessage, 'error');
                        }
                     })
                }
            });
        }
        return shouldskip == false ? true : false;
    }

    processDataMethod(processData, status) {
        debugger;
        let totalClosedCount = 0;
        let modtObjectToUppsertList = [];
        for (let i = 0; i < processData.length; i++) {
            let modtObjectToUppsert = {

            };
            let Place__c = {
                city: "",
                street: '',
                proviance: "",
                postalCode: "",
                country: ""
            }

            if (processData[i].isRecordExixst == true) {
                modtObjectToUppsert.Id = processData[i].Id
                modtObjectToUppsert.Financial_Account__c = this.FinancialAccountId;
                modtObjectToUppsert.Mortgager_Name__c = processData[i].Mortgager_Id__c;
                modtObjectToUppsert.Status__c = status;
                modtObjectToUppsert.MODT_ID__c = processData[i].MODT_ID__c
                modtObjectToUppsert.Place__c = processData[i].Place__c
                modtObjectToUppsert.Task_Id__c = this.taskId;
                modtObjectToUppsert.Place__City__s = processData[i].city;
                modtObjectToUppsert.Place__Street__s = processData[i].street;
                modtObjectToUppsert.Place__StateCode__s = processData[i].stateCode;
                modtObjectToUppsert.Place__PostalCode__s = processData[i].postalCode;
                modtObjectToUppsert.Place__CountryCode__s = 'IN';
                modtObjectToUppsert.Place__c = Place__c;
                modtObjectToUppsert.Date_Of_Execution__c = processData[i].Date_Of_Execution__c;
                modtObjectToUppsert.MODT_Value__c=processData[i].MODT_Value__c;
                totalClosedCount = totalClosedCount + 1
             
                modtObjectToUppsertList.push(modtObjectToUppsert);
            } else if (processData[i].isRecordExixst == false) {
                modtObjectToUppsert.Financial_Account__c = this.FinancialAccountId;
                modtObjectToUppsert.Mortgager_Name__c = processData[i].Mortgager_Id__c;
                modtObjectToUppsert.Status__c = status;
                modtObjectToUppsert.MODT_ID__c = processData[i].MODT_ID__c
                modtObjectToUppsert.Place__c = processData[i].Place__c
                modtObjectToUppsert.Task_Id__c = this.taskId;
                modtObjectToUppsert.Date_Of_Execution__c = processData[i].Date_Of_Execution__c;
                modtObjectToUppsert.MODT_Value__c=processData[i].MODT_Value__c;
              
                modtObjectToUppsert.Place__City__s = processData[i].city;
                modtObjectToUppsert.Place__Street__s = processData[i].street;
                modtObjectToUppsert.Place__StateCode__s = processData[i].stateCode;
                modtObjectToUppsert.Place__PostalCode__s = processData[i].postalCode;
                modtObjectToUppsert.Place__CountryCode__s = 'IN'

              
                totalClosedCount = totalClosedCount + 1
              
                modtObjectToUppsertList.push(modtObjectToUppsert);
            }
        }
        this.totalClosedRecordsCount = totalClosedCount;
        this.uppsertMODTList(modtObjectToUppsertList);
    }

    processDataMethodUpdate(processData, status) {
        debugger;
        let totalClosedCount = 0;
        let modtObjectToUppsertList = [];
        for (let i = 0; i < processData.length; i++) {
            let modtObjectToUppsert = {

            };
            let Place__c = {
                city: "",
                street: '',
                proviance: "",
                postalCode: "",
                country: ""
            }

            if (processData[i].isRecordExixst == true) {
                modtObjectToUppsert.Id = processData[i].Id
                modtObjectToUppsert.Financial_Account__c = this.FinancialAccountId;
                modtObjectToUppsert.Mortgager_Name__c = processData[i].Mortgager_Id__c;
                modtObjectToUppsert.Status__c = processData[i].Status__c;
                modtObjectToUppsert.MODT_ID__c = processData[i].MODT_ID__c
                modtObjectToUppsert.Place__c = processData[i].Place__c
                modtObjectToUppsert.Task_Id__c = this.taskId;
                modtObjectToUppsert.Place__City__s = processData[i].city;
                modtObjectToUppsert.Place__Street__s = processData[i].street;
                modtObjectToUppsert.Place__StateCode__s = processData[i].stateCode;
                modtObjectToUppsert.Place__PostalCode__s = processData[i].postalCode;
                modtObjectToUppsert.Place__CountryCode__s = 'IN';
                modtObjectToUppsert.Place__c = Place__c;
                modtObjectToUppsert.Date_Of_Execution__c = processData[i].Date_Of_Execution__c;
                modtObjectToUppsert.MODT_Value__c=processData[i].MODT_Value__c;
                totalClosedCount = totalClosedCount + 1
                
                modtObjectToUppsertList.push(modtObjectToUppsert);
            } else if (processData[i].isRecordExixst == false) {
                modtObjectToUppsert.Financial_Account__c = this.FinancialAccountId;
                modtObjectToUppsert.Mortgager_Name__c = processData[i].Mortgager_Id__c;
                modtObjectToUppsert.Status__c = status;
                modtObjectToUppsert.MODT_ID__c = processData[i].MODT_ID__c
                modtObjectToUppsert.Place__c = processData[i].Place__c
                modtObjectToUppsert.Task_Id__c = this.taskId;
                modtObjectToUppsert.Date_Of_Execution__c = processData[i].Date_Of_Execution__c;
                modtObjectToUppsert.MODT_Value__c=processData[i].MODT_Value__c;
                
                modtObjectToUppsert.Place__City__s = processData[i].city;
                modtObjectToUppsert.Place__Street__s = processData[i].street;
                modtObjectToUppsert.Place__StateCode__s = processData[i].stateCode;
                modtObjectToUppsert.Place__PostalCode__s = processData[i].postalCode;
                modtObjectToUppsert.Place__CountryCode__s = 'IN'

 
                totalClosedCount = totalClosedCount + 1
                modtObjectToUppsertList.push(modtObjectToUppsert);
            }
        }
        this.totalClosedRecordsCount = totalClosedCount;
      
        this.uppsertMODTList(modtObjectToUppsertList);

    }

    uppsertMODTList(modtObjectToUppsertList) {
        debugger;
        upsertMODTRecords({ MODTLIst: modtObjectToUppsertList })
            .then(result => {
                if (result) {
                    if(result!=null && result!=undefined){
                        if(result.isSuccess){
                            this.showToast('SUCCESS',result.Responsemessage,'success');
                            this.refresh();
                            if (this.buttonLabelHandler == 'Save Button Handler') {
                                this.isClosed = true;
                                this.sendClosedStatementToParent(this.isClosed);
                                this.buttonLabelHandler = '';
                            }
                        }else{
                            this.showToast('ERROR',result.Responsemessage,'error');
                        }
                    }
                } else {
                    
                }
            })
            .catch(error => {
                this.showToast('ERROR', 'error on memo added', 'error');
                console.error('An error occurred:', error.body.message);
            });
    }

    @api deleteRecordBackend(currentIndex) {
        deleteMODTRecord({ recordId: currentIndex })
            .then(response => {
                this.showToast('ERROR', 'memo deleted Successfully', 'success');
                this.refresh();
            })
            .catch(error => {
                this.showToast('ERROR', error.body.message, 'error');
                console.error('An error occurred:', error.body.message);
            });
    }



    validateMODTid(mmodtlist, cuurentMODTValue) {
        debugger;
        if (cuurentMODTValue) {
            for (let i = 0; i < mmodtlist.length; i++) {
                if (cuurentMODTValue == mmodtlist[i].MODT_ID__c) {
                    this.showToast('ERROR', 'MODT Number cannot be a duplicate', 'error');
                    return false;
                }
            }
            return true;
        } else {
            this.showToast('warning', 'Please enter a valid MODT Number', 'warning');
            
            return false;
        }
    }

    isDuplicateMODT(mmodtlist) {
        debugger;
        const seen = new Set();
        for (const item of mmodtlist) {
            if (seen.has(item.MODT_ID__c)) {
                return true; // Found a duplicate
            }
            seen.add(item.MODT_ID__c);
        }
        return false; // No duplicates found
    }

    // BELOW FUCTION WILL BE USED IN TO GET CITY AND  STATE AS PER PINCODE INPUT 
    async handlePincodeChange(event, lastRecordIndex) {
        debugger;
        const pincode = event.target.value;
        const apiKey = this.googleapiKey; // Replace with your actual API key
        const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${pincode}&key=${apiKey}`;
        try {
            const response = await fetch(url);
            const data = await response.json();

            if (data.results && data.results.length > 0) {
                // Assuming the first result contains the relevant information
                const addressComponents = data.results[0].address_components;
                for (let component of addressComponents) {
                    if (component.types.includes('administrative_area_level_1')) {
                        this.state = component.long_name;
                        let state = component.long_name;
                        this.stateCode = component.short_name;
                        let stateCode = component.short_name;
                    } else if (component.types.includes('locality')) {
                        this.city = component.long_name;
                        let city = component.long_name;
                        if (this.city) {
                            // this.isClosedMosal = true;
                        }
                    } else if (component.types.includes('country')) {
                        this.country = component.long_name;
                        let country = component.long_name;
                        this.countryCode = component.short_name;
                        let countryCode = component.short_name;
                    }
                }
                this.mapAddressRelatedFiledFromApiValues(this.city, this.stateCode, this.state, this.countryCode, pincode, lastRecordIndex)
            } else {
                console.error('No results found');
            }
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    }

    backTomodt(event) {
        this.isShowMODTCOMP = true;
    }

    callDocumentHandlerFinalSubmit() {
        debugger;
        let child = this.template.querySelector('c-lwc_-handledocuments');
        child.HandleSavefromAura();
        //this.isShowMODTCOMP = true;
    }


    sendClosedStatementToParent(isClosed) {
        debugger;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: {
                "isclosed": isClosed,
                "index": this.compIndex
            }
        });
        this.dispatchEvent(valueChangeEvent);
    }

    closeMODT(event) {
        debugger;
        let selectedMODTrecord = [];
        let isclosed = event.detail.child_isclosed;
        let extendedId = event.detail.extendedsobjId;
        if (this.indePendentModtObjectList.length > 0) {
            this.indePendentModtObjectList.forEach(currentItem => {
                if (currentItem && currentItem.Id == extendedId) {
                    currentItem.Is_Document_Closed__c = isclosed;
                    selectedMODTrecord.push(currentItem);
                }
            });
        }
        //let Status = "MODT Created"
        if (isclosed) {
            console.log('selectedMODTrecord', selectedMODTrecord);
            this.closedMOdtStatus(extendedId, true, 'MODT Created')
        }

    }
    //modtId, isclosed
    closedMOdtStatus(modtId, booleanvalue, status) {
        debugger;
        updateMODT({ MODTId: modtId, closeddoc: booleanvalue, status: status })
            .then(result => {
                if (result == 'success') {
                    this.refresh();
                }
            })
            .catch(error => {
                console.log('An error occurred:', error);
            });
    }

    showToast(title, message, success) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: success,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    /*
     *hyperlink For Financial Account
     */
    handleFinancialAccount(){
        debugger;
        let fId=this.FinancialAccountRec.Id;
        
        window.open('https://northernarc--dev240320.sandbox.lightning.force.com/'+fId,'_blank');
    }

    /*
     * To Close ModalPOPUp Associated With Receivable and Payables
     */
    handleCloseFAccount(){
        debugger;
        if(this.showReceivableAccount){
            this.showReceivableAccount=false;
        }
        if(this.showPayableAccount){
            this.showPayableAccount=false;
        }
        
    }
    /*
     *To Show Receivables Associated With that Financial Account
     */
    @track Receivables=[];
    @track showReceivableAccount=false;
    HandleReceivable(){
        debugger;
        console.log('financialAccount',JSON.stringify(this.FinancialAccountRec));
        if(this.FinancialAccountRec!=null && this.FinancialAccountRec!=undefined){
            if(this.FinancialAccountRec.Receivables__r!=null && this.FinancialAccountRec.Receivables__r!=undefined && this.FinancialAccountRec.Receivables__r.length>0){
                  this.Receivables=this.FinancialAccountRec.Receivables__r;
                  this.showReceivableAccount=true;
                  console.log('this.Receivables',JSON.stringify(this.Receivables));
            }
        }
    }
    /*
     *To Show Payables Associated With that Financial Account
     */
    @track Payables=[];
    @track showPayableAccount=false;
    HandleDisburedAmount(){
        debugger;
        console.log('financialAccount',JSON.stringify(this.FinancialAccountRec));
        if(this.FinancialAccountRec!=null && this.FinancialAccountRec!=undefined){
            if(this.FinancialAccountRec.Paybales__r!=null && this.FinancialAccountRec.Paybales__r!=undefined && this.FinancialAccountRec.Paybales__r.length>0){
                  this.Payables=this.FinancialAccountRec.Paybales__r;
                  this.showPayableAccount=true;
                  console.log('this.Payables',JSON.stringify(this.Payables));
            }
        }
    }

    /**
     * USED FOR NUMBER TO WORDS CURRENCY
     */
    numberTOwordsIndianCur(num) {
        debugger
        var a = ['', 'one ', 'two ', 'three ', 'four ', 'five ', 'six ', 'seven ', 'eight ', 'nine ', 'ten ', 'eleven ', 'twelve ', 'thirteen ', 'fourteen ', 'fifteen ', 'sixteen ', 'seventeen ', 'eighteen ', 'nineteen '];
        var b = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];
        if ((num = num.toString()).length > 9) return 'overflow';
        let n = ('000000000' + num).substr(-9).match(/^(\d{2})(\d{2})(\d{2})(\d{1})(\d{2})$/);
        if (!n) return; var str = '';
        str += (n[1] != 0) ? (a[Number(n[1])] || b[n[1][0]] + ' ' + a[n[1][1]]) + 'crore ' : '';
        str += (n[2] != 0) ? (a[Number(n[2])] || b[n[2][0]] + ' ' + a[n[2][1]]) + 'lakh ' : '';
        str += (n[3] != 0) ? (a[Number(n[3])] || b[n[3][0]] + ' ' + a[n[3][1]]) + 'thousand ' : '';
        str += (n[4] != 0) ? (a[Number(n[4])] || b[n[4][0]] + ' ' + a[n[4][1]]) + 'hundred ' : '';
        str += (n[5] != 0) ? ((str != '') ? 'and ' : '') + (a[Number(n[5])] || b[n[5][0]] + ' ' + a[n[5][1]]) + 'only ' : '';
        return str;
    }


    handleEditAction(event){
        debugger;
        let currentIndex = event.target.dataset.index; 
        let cureentId = event.target.dataset.id;

        console.log('currentIndex',currentIndex);
        console.log('cureentId',cureentId);
        this.HandleDisable_Enable_ActionItems(this.indePendentModtObjectList,cureentId,'OnEdit');
    }

    HandleDisable_Enable_ActionItems(modtlist,index,Actiontype){
        debugger;
        if(Actiontype=='OnEdit' || Actiontype=='OnAddRow'){
            if(modtlist.length>0){
                modtlist.forEach((item)=>{
                    if(item.index==index){
                       item.isDisabledAllInput=false;
                       item.isshowSavebutton=true;
                       item.isshoweditButton=false;
                       item.isDisabledAttachement=false;
                       item.isdeletedisable=false;
                    }else{
                       item.isDisabledAllInput=true;
                       item.isshowSavebutton=false;
                       item.isshoweditButton=false;
                       item.isDisabledAttachement=true;
                       item.isdeletedisable=true;
                    }
                })
            }
        } else if(Actiontype=='OnSave'){
           if(modtlist.length>0){
                modtlist.forEach((item)=>{
                    if(item.Task_Id__c == this.taskId){
                        item.isshowSavebutton=false;
                        item.isshoweditButton=true;
                        item.isDisabledAttachement=false;
                        item.isDisabledAllInput=true;
                        item.isdeletedisable=item.Task_Id__c == this.taskId && item.Status__c=='Draft' ? false:true;
                    }
                })
           }
        }
    }

    handleSave(event){
        debugger;
        let currentIndex = event.target.dataset.index; 
        let cureentId = event.target.dataset.id;

        console.log('currentIndex',currentIndex);
        console.log('cureentId',cureentId);
        let returnedObj=this.Check_mandatory_field_validation(this.indePendentModtObjectList,cureentId);
        if(returnedObj.v_shouldskip==false && returnedObj.successlist!=null){
            let status = 'Draft'
            this.HandleDisable_Enable_ActionItems(this.indePendentModtObjectList,cureentId,'OnSave');
            this.processDataMethodUpdate(returnedObj.successlist, status);
        }
    }

    
    Check_mandatory_field_validation(modtlist, rowindex) {
        debugger;
        let SuccessObj={v_shouldskip:null,successlist:null};
        let list_Modt_To_Create_Update = [];
        let shouldSkip;
        if (modtlist.length > 0) {
            modtlist.forEach((currentItem) => {
                if (currentItem.index == parseInt(rowindex)) { 
                    let currentObj = currentItem;
                    list_Modt_To_Create_Update.push(currentObj);
                    this.checknull_values_for_Keys.forEach(key => {
                        if(shouldSkip) {return}
                        if (key) {
                            if (currentObj[key.FieldName] != null && currentObj[key.FieldName] != undefined && currentObj[key.FieldName] != '') {
                                shouldSkip = false
                            } else {
                                shouldSkip = true;
                                this.showToast('ERROR', key.errorMessage, 'error');
                            }
                        }
                    });
                } else {
                    console.log('Condition NOT Satisfied');
                }
            });
        } 
         if(shouldSkip==false){
            SuccessObj.v_shouldskip = shouldSkip;
            SuccessObj.successlist = list_Modt_To_Create_Update;
         }else{
            SuccessObj.v_shouldskip = shouldSkip;
            SuccessObj.successlist = null;
         }
        return SuccessObj;
    }

    handleCloseAddress(event){
        debugger;
        let currentIndex = event.target.dataset.index; 
        let cureentId = event.target.dataset.id;
        let shouldSkip;
        var tempindpendentmodtList = [...this.indePendentModtObjectList];
        for (let i = 0; i < tempindpendentmodtList.length; i++) {
            if (currentIndex == tempindpendentmodtList[i].index) {
                let currentObj = tempindpendentmodtList[i];
                 this.AddressValidations.forEach(key=>{
                    if(shouldSkip) {return}
                    if (key) {
                        if (currentObj[key.FieldName] != null && currentObj[key.FieldName] != undefined && currentObj[key.FieldName] != '') {
                            shouldSkip = false
                        } else {
                            shouldSkip = true;
                            this.showToast('ERROR', key.errorMessage, 'error');
                        }
                    }
                 })
            }
        }
        this.isClosedMosal = shouldSkip==true?true:false;
        tempindpendentmodtList[currentIndex].isAddressEditabled = this.isClosedMosal==true?false:true;
    }
   
}