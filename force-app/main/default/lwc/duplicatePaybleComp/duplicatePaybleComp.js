import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import fetchPayabledata from '@salesforce/apex/PayableDetailsController.getAllFinancialEntityWithDetailsDups';
import upsertPayableRecord from '@salesforce/apex/PayableDetailsController.upsertPayableRecord';
import deletePayableRecord from '@salesforce/apex/PayableDetailsController.deletePayableRecord';
import getFinancialAccId from '@salesforce/apex/Child_components_Controller.getFinancialAccId';
import getDependentPicklistValues from '@salesforce/apex/PayableDetailsController.getDependentPicklistValues';
import StatusFailedValue from '@salesforce/label/c.Payable_IsActive_False_Status';
import OpportunityUrl from '@salesforce/label/c.OpportunityUrl';

export default class DuplicatePaybleComp extends LightningElement {
    
    debugger;
    @track finalSansctionAmount = 0;
    @api recordId;
    @api initFunctionality = false;
    @api payeeAblesList = [];
    @api isTaskOwnerLogin = false;
    @api isCalledFromParent = false;
    @api isClosed = false
    @api compIndex;
    @api opportunityId;
    @api TaskId;
    @api finalData;
    @api dependentValuesObject = {};

    @track isAttributeRequired = true;
    @track isLoading = false;
    @track records;
    @track entityTpye;
    @track payeeNameData;
    @track paymentMode;
    @track financial_Entity_AC_details;
    @track payAblesList = [];
    @track relatedFinancialEntity
    @track totalGivenAmount = 0;
    @track AvailableAmount = 0;
    @track selectedValues = [];
    @track testFEDWithAC;
    @track payAbleStatus;
    @track isDisabledAddRowButton = false;
    @track eveFinalRecord;
    @track TotalGivenAmountInWords;
    @track finalSansctionAmountInWords;
    @track Receivables_Amount__In_Words;
    @track AvailableAmountInWord;
    @track isShowNewPayeeCom = false;
    @track isShowNewPayeeACCom = false;
    @track isModalOpen = false;
    @track newObjectType;
    @track totalClosedRecordsCount;
    @track FinancialAccountRecord
    @track FinancialAccountId;
    @track show_data_onHover=false;
    @track createRecevables=false;
    @track disableReceivable_Save=false;


    wiredRecords;
    error;
    @track deleteConatctIds = '';
    @track payAbleObject;
    completeWrapData;
    @track bankEntityPicklist = [];
    @track wiredCompleteData;


    @track entityList = [];
    @track entityMap = new Map();
    @track bankAccMap = new Map();
    @track statusList = [];
    @track simpleMap=[];

    modalClass = 'modal';

    @track checknull_values_for_Keys = ['selectedentitytype', 'selectedpayeename', 'selectedbankacc','selectedpaymode'];

    @track MeMoField_values_Before_submit=[
        {FieldName:'selectedentitytype',errorMessage:'EntityType Name is Missing'},
        {FieldName:'selectedpayeename',errorMessage:'PayeeName is Missing'},
        {FieldName:'selectedbankacc',errorMessage:'BankAccount is Missing'},
        {FieldName:'selectedpaymode',errorMessage:'PaymentMode is Missing'},
        {FieldName:'Amount__c',errorMessage:'Amount is Missing'},
    ];

    //to close quick action
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    @api checkStatusOnLoad() {
        debugger;
        console.log('initFunctionality::' + this.initFunctionality);
        if (this.initFunctionality) {
            this.initFunctionality = false;
        }
    }

     connectedCallback() {
        debugger;
        this.getDependent_PicklistValues();
        getFinancialAccId({ whatId: this.opportunityId })
            .then(result => {
                this.FinancialAccountId = result.Id;
                this.FinancialAccountRecord = result;
                console.log('taskId', this.TaskId);
                console.log('FinancialAccountRecord', this.FinancialAccountRecord);
                this.AvailableSanctionedAmount = parseInt(this.FinancialAccountRecord.Sanctioned_Amount__c) - parseInt(this.FinancialAccountRecord.Receivables_Amount__c)
                this.Receivables_Amount__In_Words=this.numberTOwordsIndianCur(parseInt(this.FinancialAccountRecord.Receivables_Amount__c));
                this.AvailableSanctionedAmountInWords= this.numberTOwordsIndianCur(parseInt(this.AvailableSanctionedAmount));
                if (this.initFunctionality) {
                    this.fetchPaybleData();
                }else{
                    this.callingApex(this.FinancialAccountId); 
                } 
            })
            .catch(error => {
                console.log('In connected call back error....');
            });
        console.log('initFunctionality::' + this.initFunctionality);
    }


     getDependent_PicklistValues(){
        debugger;
         getDependentPicklistValues({SFobject:'Paybale__c',fieldApiName:'Mode__c'})
        .then(result => {
           if(result){
            for (var key in result) {
                this.simpleMap.push({ key: key, value: result[key] });
                console.log('key', key, result[key]);
            }
               console .log('result DependentPicklist',result);
               console .log('result DependentPicklist',result);
           }
        })
        .catch(error => {
            console.log('In connected call back error....');
        });
     }
    //to add row
    fetchPaybleData() {
        debugger;
        this.payAblesList = [];
        this.dependentValuesObject
        let parentEntityType = this.dependentValuesObject.entityType;
        let parentPayeName = this.dependentValuesObject.payeName;
        let parentbankAccount = this.dependentValuesObject.bankAccount;
        let parentAmount = this.dependentValuesObject.amount;

        if (this.initFunctionality) {
            this.callingApex(this.FinancialAccountId)
        }
    }
    callingApex(financialAccountId) {
        debugger;
        this.payAblesList = [];
        fetchPayabledata({ Financial_AccountId: financialAccountId })
            .then(result => {
                this.finalData = result;
                if (this.finalData) {
                    console.log('finalData', JSON.stringify(this.finalData));
                    this.processFinalData(this.finalData);
                    const event = new CustomEvent('lwclaunched', {
                        detail: {
                            isLWCLaunched: false,
                            payAblesList: this.payAblesList,
                            finalData: this.finalData
                        }
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    ////FROM HERE
    processFinalData(completeData) {
           //alert('in processFinalData sep ')
        debugger;
        let tempPayableStatus = completeData.payAbleStatus.map(type => ({ label: type, value: type }));
        this.payAbleStatus = tempPayableStatus;
        let temppaymentMode = completeData.paymentModeTypesValues.map(type => ({ label: type, value: type }));
        this.paymentMode = temppaymentMode;
        let tempentityTpye = completeData.relatedFinancialEntity.map(type => ({ label: type.Entity_Type__c, value: type.Entity_Type__c })).filter((type, index, self) => index === self.findIndex(t => (  t.label === type.label && t.value === type.value )));;
        console.log('tempentityTpye',JSON.stringify(tempentityTpye));
        //let tempentityTpye = completeData.entityTypesValue.map(type => ({ label: type, value: type }));
        this.entityTpye = tempentityTpye;
        this.finalSansctionAmount = this.FinancialAccountRecord.Sanctioned_Amount__c;
        this.reformData(completeData);
        this.finalData.payAbleStatus = completeData.payAbleStatus.map(status => ({ label: status, value: status }));
        this.finalData.entityTypesValue = completeData.entityTypesValue.map(type => ({ label: type, value: type }));
        this.finalData.paymentModeTypesValues = completeData.paymentModeTypesValues.map(mode => ({ label: mode, value: mode }));
        let bankEntityList = [];
        let allDetails = [];
        console.log('completeData.relatedFinancialEntity',completeData.relatedFinancialEntity);
        completeData.relatedFinancialEntity.forEach(entity => {
            console.log('entity',entity);
            if (entity.Financial_Entity_AC_Details__r) {
                entity.Financial_Entity_AC_Details__r.forEach(item => {
                    bankEntityList.push({ label: item.Bank_Account_Number__c, value: item.Id });
                });
                allDetails = allDetails.concat(entity.Financial_Entity_AC_Details__r);
            }
        });
        console.log('bankEntityList',bankEntityList);
        let setOfEnityTypePayeeName = new Map();
        completeData.EntityACDetailsList.forEach(item => {
            let tempSelectedEntityType = item.Financial_Entity__r?.Entity_Type__c;
            let tempFinancialEntityId = item.Financial_Entity__r?.Id;
            let tempFinancialEntityName = item.Financial_Entity__r?.Name;
            if (tempSelectedEntityType && !setOfEnityTypePayeeName.has(tempSelectedEntityType)) {
                setOfEnityTypePayeeName.set(tempSelectedEntityType, []);
            }
            if (tempSelectedEntityType && tempFinancialEntityName && !setOfEnityTypePayeeName.get(tempSelectedEntityType).includes(tempFinancialEntityName)) {
                setOfEnityTypePayeeName.get(tempSelectedEntityType).push({ label: tempFinancialEntityName, value: tempFinancialEntityName });
            }
        });

        //loop
        completeData.PayablesLIst.forEach((item, index) => {
            
            let payAbleObjectTemp = {
                index: index + 1,
                Id: item.Id || null,
                selectedentitytype: item.Finacial_Entity_Details__r?.Entity_Type__c || null,
                entityTypePicklist: setOfEnityTypePayeeName.get(item.Finacial_Entity_Details__r?.Entity_Type__c) || null,
                selectedpayeename: item.Finacial_Entity_Details__r?.Id || null,
                selectedbankacc: item.Financial_Entity_A_C_Details__r?.Id || null,
                IFSC_Code:item.Financial_Entity_A_C_Details__r ?.IFSC_Code__c ||null,
                selectedpaymode: item.Mode__c || null,
                Status__c: item.Status__c || null,
                Amount__c: item.Amount__c || null,
                //payMentModePiclist: completeData.paymentModeTypesValues || null,getPaymentModeAsPer_Entity
                payMentModePiclist: this.getPaymentModeAsPer_Entity(item.Finacial_Entity_Details__r.Entity_Type__c),
                PayeeName: this.entityMap.get(item.Finacial_Entity_Details__r?.Entity_Type__c) || null,
                bankAccList: this.bankAccMap.get(item.Finacial_Entity_Details__r?.Name) || null,
                createdon: item.CreatedDate || null,
                entityList: this.entityList || null,
                statusList: this.statusList || null,
                Task_Id__c: item.Task_Id__c || null,
                isEntityTpeDisabled: item.Status__c !== 'Draft',
                isPayeNameDisabled: item.Status__c !== 'Draft',
                isPaymentModeDisabled: item.Status__c !== 'Draft',
                isBankAccountDisabled: item.Status__c !== 'Draft',
                isAmountDisabled: item.Status__c !== 'Draft',
                isActionDisabled: item.Status__c !== 'Draft',
                isRecordExixst: true,
                isCreatdOnDisabled: true,
                isStatusDisabled: true,
                iseditDisabled : item.Task_Id__c==this.TaskId && item.Id!=null && item.Status__c !== 'Draft' && this.isTaskOwnerLogin==true?false:true,
                isShowsave:false,
                IsActive__c:item.IsActive__c
            };

            if (item.Amount__c && item.IsActive__c) {
                this.totalGivenAmount = this.totalGivenAmount+parseInt(item.Amount__c);
            }

            this.payAblesList.push({ ...payAbleObjectTemp });
        });
        this.AvailableAmount = this.AvailableSanctionedAmount - this.totalGivenAmount;
        this.AvailableAmountInWord = this.numberTOwordsIndianCur(this.AvailableAmount);
        this.finalSansctionAmountInWords = this.numberTOwordsIndianCur(this.finalSansctionAmount);
        this.Receivables_Amount__cWords=this.numberTOwordsIndianCur(this.finalSansctionAmount);
        this.TotalGivenAmountInWords = this.numberTOwordsIndianCur(this.totalGivenAmount);
        

        this.financial_Entity_AC_details = allDetails;
        this.eveFinalRecord = allDetails;
        this.bankEntityPicklist = bankEntityList;
        console.log('this.payAblesList--->', JSON.stringify(this.payAblesList));
    }

    getPaymentModeAsPer_Entity(entityType){
        debugger;
        let values=[];
        if(this.simpleMap.length >0 && entityType){
            if(this.simpleMap.find((item)=>item.key == entityType)){
                values =this.simpleMap.find((mapkey)=>mapkey.key == entityType).value;
            }
        }
        return values.length >0 ? Array.from(values).map(key=>({label: key, value: key })):null;
    }
    //TO HERE
    handleDeleteAction(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        //if (confirm(" are you Sure want to delete memo") == true) {
            if (currentIndex!="" && currentIndex!=null && currentIndex!=undefined) {
                deletePayableRecord({ recordId: currentIndex })
                    .then(response => {
                        if(response=='success'){
                            this.showToast('SUCCESS', 'MEMO deleted Successfully', 'success', 'dismissable');
                            this.payAblesList=this.payAblesList.filter(item=>item.index!=cureentId);
                            this.isDisabledAddRowButton=false;
                            this.calculateAvailableAmount(); 
                        }
                    })
                    .catch(error => {
                        console.error('An error occurred:', error.body.message);
                        this.showToast('ERROR', error.body.message, 'error', 'dismissable');
                    });
            }else{
               this.payAblesList=this.payAblesList.filter(item=>item.index!=cureentId);
               this.showToast('SUCCESS', 'MEMO deleted Successfully', 'success', 'dismissable');
               this.isDisabledAddRowButton=false;
               this.calculateAvailableAmount();
            }
        this.CheckforEditButtonVisibility('On Save/On_Delete');
    }

    //show/hide spinner
    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    selectionChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;

        let prevValue = prevIndex >= 0 ? this.selectedValues[prevIndex] : null;
        if (eventName == "enityName") {
            this.entityTpyeChangeHandler(event);
        }
        else if (eventName == "payeName") {
            this.payeeNameChangeHandler(event);
        }
        else if (eventName == "bankAccount") {
            this.bankAccountChangeHandler(event);
        }
        else if (eventName == "paymentMode") {
            this.paymentModeChangeHandler(event);
        }
        else if (eventName == "amount") {
            this.amountChangeHandler(event);    
        }
        else if (eventName == "status") {
            this.statusChangeHandler(event);
        }

    }

    entityTpyeChangeHandler(event) {
        debugger;
        let currentValue = event.target.value;
        let currentIndex = event.target.dataset.index;
        let intIndexNumber = parseInt(currentIndex);
        var temppayAblesList = this.payAblesList;
        var tempcompleteWrapData = this.finalData;
        var temprelatedFinancialEntitylist = [];
        this.payAblesList[intIndexNumber - 1].selectedentitytype = currentValue;
        temprelatedFinancialEntitylist = this.finalData[0].relatedFinancialEntity;
        var tempPayeeName = [];
        for (var i = 0; i < temprelatedFinancialEntitylist.length; i++) {
            if (temprelatedFinancialEntitylist[i].Entity_Type__c == currentValue) {
                tempPayeeName.push({ label: temprelatedFinancialEntitylist[i].Name, value: temprelatedFinancialEntitylist[i].Id });
            }
        }
        debugger;

        this.payAblesList[intIndexNumber - 1].selectedbankacc = '';
        this.payAblesList[intIndexNumber - 1].selectedpayeename = '';
        this.payAblesList[intIndexNumber - 1].selectedpaymode = '';
        //this.payAblesList[intIndexNumber - 1].Amount__c = '';
        this.payAblesList[intIndexNumber - 1].isPayeNameDisabled = false;
        this.payAblesList[intIndexNumber - 1].isBankAccountDisabled = true;
        this.payAblesList[intIndexNumber - 1].isPaymentModeDisabled = true;
        this.payAblesList[intIndexNumber - 1].PayeeName = tempPayeeName;
        this.payAblesList[intIndexNumber - 1].payMentModePiclist = this.getPaymentModeAsPer_Entity(currentValue)
        //this.Check_mandatory_field_validation(this.payAblesList,intIndexNumber);
    }

    payeeNameChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        let valueName = event.target.key;
        let payId = event.target.value;
        let tempObj = this.financial_Entity_AC_details;
        var tempselectedfinancialentityACList = [];

        for (let i = 0; i < this.payAblesList.length; i++) {
            if (this.payAblesList[i].index == currentIndex) {
                if (tempObj != null && tempObj != undefined) {
                    tempselectedfinancialentityACList = tempObj.filter((dtl) => dtl.Financial_Entity__c == payId);
                }
                this.payAblesList[i].isBankAccountDisabled = false;
            } if (currentValue == 'Select') {
                this.payAblesList[i].isBankAccountDisabled = true;
            }
        }
        var ActualselectedfinancialentityACList = [];
        if (tempselectedfinancialentityACList.length > 0) {
            for (var j = 0; j < tempselectedfinancialentityACList.length; j++) {
                ActualselectedfinancialentityACList.push({ label: tempselectedfinancialentityACList[j].Bank_Account_Number__c, value: tempselectedfinancialentityACList[j].Id });
            }
        }
        this.payAblesList[parseInt(currentIndex) - 1].selectedpayeename = currentValue;
        this.payAblesList[parseInt(currentIndex) - 1].bankAccList = ActualselectedfinancialentityACList;
        console.log('BankPicklist', this.bankEntityPicklist);
        //this.Check_mandatory_field_validation(this.payAblesList,(parseInt(currentIndex)));
    }

    bankAccountChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        this.payAblesList[parseInt(currentIndex) - 1].selectedbankacc = currentValue;
        debugger;
        for (let i = 0; i < this.payAblesList.length; i++) {
            if (this.payAblesList[i].index == currentIndex) {
                this.payAblesList[i].isPaymentModeDisabled = false;
                if (currentValue == 'Select') {
                    this.payAblesList[i].isPaymentModeDisabled = true;
                }
            }
        }

        //this.Check_mandatory_field_validation(this.payAblesList,(parseInt(currentIndex)));
    }

    paymentModeChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        this.payAblesList[parseInt(currentIndex) - 1].selectedpaymode = currentValue;
        for (let i = 0; i < this.payAblesList.length; i++) {
            if (this.payAblesList[i].index == currentIndex) {
                this.payAblesList[i].selectedpaymode = currentValue;
                this.payAblesList[i].isAmountDisabled = this.FinancialAccountRecord.Product__r.Disbursal_Type__c=='Full disbursal'?true:false;
                if (currentValue == 'Select') {
                    this.payAblesList[i].isAmountDisabled = true;
                }
            }
        }
        //this.Check_mandatory_field_validation(this.payAblesList,(parseInt(currentIndex)));
    }
    setTimeoutId;
    amountChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        debugger;
        this.payAblesList[parseInt(currentIndex) - 1].Amount__c=currentValue != null || currentValue != '' ? parseInt(currentValue) : 0;
        if(currentValue==null || currentValue==undefined || currentValue ==''){
            this.calculateAvailableAmount();
        }else if(currentValue!=undefined && currentValue != null && currentValue != '' ){
            if(this.calculateAmountInMemo(this.payAblesList,(parseInt(currentIndex) - 1))==false){
                this.calculateAvailableAmount();
             }
        }
        // if (currentValue <= 0 || currentValue == null) {
        //      this.isDisabledAddRowButton = true;
        //      currentValue==null || currentValue==undefined || currentValue ==''?this.calculateAvailableAmount():null;
        // } else {
        //     this.payAblesList[parseInt(currentIndex) - 1].Amount__c = currentValue != null || currentValue != '' ? parseInt(currentValue) : 0;
        //     if(this.calculateAmountInMemo(this.payAblesList,(parseInt(currentIndex) - 1))==false){
        //         this.calculateAvailableAmount();
        //     }
           
        // }
        // setTimeout(() => {
        //     this.Check_mandatory_field_validation(this.payAblesList,(parseInt(currentIndex)));           
        // }, 4000);   
    }

    statusChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.index;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        let prevIndex = currentIndex - 1;
        for (let i = 0; i < this.payAblesList.length; i++) {
            if (this.payAblesList[i].index == currentIndex) {
                this.payAblesList[i].isAmountDisabled = false;
                this.payAblesList[i].Status__c = currentValue;
                if (currentValue == 'Select') {
                    this.payAblesList[i].isAmountDisabled = true;
                }
            }
        }

        //this.Check_mandatory_field_validation(this.payAblesList,(parseInt(currentIndex)));
    }

    calculateAvailableAmount() {
        debugger;
        let givenAmount = 0;
        this.finalSansctionAmount = parseInt(this.AvailableSanctionedAmount)//this.FinancialAccountRecord.Sanctioned_Amount__c;
        this.payAblesList.forEach(item => {
            if (item.Amount__c && !StatusFailedValue.includes(item.Status__c) && item.IsActive__c==true) {
                givenAmount += item.Amount__c;
            }
        })
        this.totalGivenAmount = givenAmount;
        this.AvailableAmount = parseInt(this.finalSansctionAmount) - parseInt(this.totalGivenAmount)
        let totalGivenAmmountInwprds = this.numberTOwordsIndianCur(this.totalGivenAmount);
        this.TotalGivenAmountInWords = totalGivenAmmountInwprds;
        let AvailableAmountInWord = this.numberTOwordsIndianCur(this.AvailableAmount);
        this.AvailableAmountInWord = AvailableAmountInWord;

    }

    calculateAmountInMemo(Payablelist,currentIndex){
        debugger;
        let sanctionedAmount =parseInt(this.AvailableSanctionedAmount);

        let v_TotalGivenAmount=0;
        let v_RemaingAmount=0;
        let shouldskip;
         if(Payablelist.length>0){
            Payablelist.forEach(item => {
                if (item.Amount__c && !StatusFailedValue.includes(item.Status__c) && item.IsActive__c==true) {
                    v_TotalGivenAmount += item.Amount__c;
                }
            })
         }
        
        if((sanctionedAmount!=null && sanctionedAmount!=undefined) && (v_TotalGivenAmount!=null && v_TotalGivenAmount!=undefined)){
            v_RemaingAmount= sanctionedAmount-v_TotalGivenAmount;
            if((v_RemaingAmount<0)){
                this.payAblesList[parseInt(currentIndex)].Amount__c='';
                this.showToast('Error','MEMO Value Is Greater Than Sanction Amount','error');
                shouldskip=true;
            }else{
                this.totalGivenAmount=v_TotalGivenAmount;
                this.TotalGivenAmountInWords=this.numberTOwordsIndianCur(this.totalGivenAmount)
                this.AvailableAmount=v_RemaingAmount;
                this.AvailableAmountInWord=this.numberTOwordsIndianCur(this.AvailableAmount)
                shouldskip=false;
            }
        }
       return shouldskip==true ?false:true;
    }

    blockAddRow() {
        debugger;
        let addRowErrorMessage = { isenableBlock: false, errorMessage: null, type: null };
        let enableBlock = false;
        if (this.FinancialAccountRecord != null && this.FinancialAccountRecord != undefined) {
            if (this.FinancialAccountRecord.Product__c != null && this.FinancialAccountRecord.Product__c != undefined) {
                if (this.FinancialAccountRecord.Product__r.Disbursal_Type__c != null && this.FinancialAccountRecord.Product__r.Disbursal_Type__c != undefined && this.FinancialAccountRecord.Product__r.Disbursal_Type__c == 'Full disbursal' && this.payAblesList.length == 1) {
                    addRowErrorMessage.isenableBlock = true;
                    addRowErrorMessage.errorMessage = 'No More Amount is Pending for Disbursement';
                    addRowErrorMessage.type = 'error';
                    this.isDisabledAddRowButton = true;
                } else if (this.FinancialAccountRecord.Product__r.Disbursal_Type__c != 'Full disbursal') {
                    if(parseInt(this.AvailableAmount)>0 && parseInt(this.AvailableAmount)!=0){
                        this.payAblesList.forEach(item => {
                            if ((!item.Amount__c || item.Amount__c == 0) && !enableBlock) {
                                enableBlock = true;
                                addRowErrorMessage.isenableBlock = true;
                                addRowErrorMessage.errorMessage = 'Please enter the amount in each row to proceed further';
                                addRowErrorMessage.type = 'warning';
                            } else {
                                addRowErrorMessage.isenableBlock = false;
                                addRowErrorMessage.errorMessage = null;
                                addRowErrorMessage.type = null;
                            }
                        })
                    }else{
                        addRowErrorMessage.isenableBlock = true;
                        addRowErrorMessage.errorMessage = 'No More Amount is Pending for Disbursement';
                        addRowErrorMessage.type = 'error'; 
                    }
                }
            }
        }
        return addRowErrorMessage;
    }


    //Method On Save
    @api
    handleSaveAction() {
        debugger;
        // this.handleIsLoading(true);
        let get_TaskId_Related_payableRecord = this.payAblesList.filter((item) => item.Task_Id__c == this.TaskId);
        console.log('get_TaskId_Related_payableRecord', get_TaskId_Related_payableRecord);
        if(get_TaskId_Related_payableRecord.length == 0){this.showToast('ERROR', 'No MEMO is Created For this Process To Proceed Further', 'error'); return}

        if (this.check_memo_closed_validation(get_TaskId_Related_payableRecord)) {
            this.payAblesList;
            let totalClosedCount = 0;
            console.log(JSON.stringify(this.payAblesList));
            let Paybale__cList = [];
            for (let i = 0; i < this.payAblesList.length; i++) {
                let Paybale__c = {}
                if (this.payAblesList[i].isRecordExixst == false && (this.payAblesList[i].Id=='' || this.payAblesList[i].Id==null)) {
                    Paybale__c.Amount__c = this.payAblesList[i].Amount__c;
                    Paybale__c.Task_Id__c = this.TaskId;
                    Paybale__c.Name = this.payAblesList[i].selectedpayeename;
                    Paybale__c.Entity_Type__c = this.payAblesList[i].selectedentitytype;
                    Paybale__c.Financial_Account__c = this.FinancialAccountId;
                    Paybale__c.Finacial_Entity_Details__c = this.payAblesList[i].selectedpayeename;
                    Paybale__c.Financial_Entity_A_C_Details__c = this.payAblesList[i].selectedbankacc;
                    Paybale__c.Mode__c = this.payAblesList[i].selectedpaymode;
                    Paybale__c.Status__c = this.payAblesList[i].Status__c=='Draft'?'Memo Created':this.payAblesList[i].Status__c;
                    totalClosedCount = totalClosedCount + 1
                    Paybale__cList.push(Paybale__c);
                } else if (this.payAblesList[i].isRecordExixst == true) {
                    Paybale__c.Id = this.payAblesList[i].Id;
                    Paybale__c.Amount__c = this.payAblesList[i].Amount__c;
                    Paybale__c.Task_Id__c = this.payAblesList[i].Task_Id__c;
                    Paybale__c.Name = this.payAblesList[i].selectedpayeename;
                    Paybale__c.Entity_Type__c = this.payAblesList[i].selectedentitytype;
                    Paybale__c.Financial_Account__c = this.FinancialAccountId;
                    Paybale__c.Finacial_Entity_Details__c = this.payAblesList[i].selectedpayeename;
                    Paybale__c.Financial_Entity_A_C_Details__c = this.payAblesList[i].selectedbankacc;
                    Paybale__c.Mode__c = this.payAblesList[i].selectedpaymode;
                    Paybale__c.Status__c = this.payAblesList[i].Status__c=='Draft'?'Memo Created':this.payAblesList[i].Status__c;
                    totalClosedCount = totalClosedCount + 1
                    Paybale__cList.push(Paybale__c);
                }
            }
            this.totalClosedRecordsCount = totalClosedCount;


            upsertPayableRecord({ PayablesLIst: Paybale__cList })
                .then(response => {
                    if (this.totalClosedRecordsCount == Paybale__cList.length) {
                        this.isClosed = true;
                        const event = new CustomEvent('lwclaunched', {
                            detail: {
                                isLWCLaunched: false,
                                payAblesList: this.payAblesList,
                                finalData: this.finalData
                            }
                        });
                        this.dispatchEvent(event);
                        this.sendClosedStatementToParent(this.isClosed);
                    }
                })
                .catch(error => {
                    console.error('An error occurred:', error);
                });
        } 
    }

    addRow() {
        debugger;
        let BlockaddRowObj = this.blockAddRow();
        if (BlockaddRowObj != null && BlockaddRowObj != undefined && BlockaddRowObj.isenableBlock) {
            this.showToast('Validation', BlockaddRowObj.errorMessage, BlockaddRowObj.type, 'dismissable'); // show toast won't work in lightning page, please implement other things to show the toast
            return;
        }
        this.isDisabledAddRowButton = true;
        this.createMemoRows();
        this.calculateAvailableAmount();
        
    }

    createMemoRows(){
         debugger;
         // New row add detais started
                var tempentityTypePicklist = this.entityTpye;
                var temppaymentModePicklist = this.paymentMode;
                var temPpstatusList = this.payAbleStatus;
                var temppayAblesList = this.payAblesList;
                let newPayableObject = {
                    index: this.payAblesList.length + 1,
                    Name: '',
                    Id: '',
                    Amount__c: this.FinancialAccountRecord.Product__r.Disbursal_Type__c=='Full disbursal'?parseInt(this.AvailableAmount):'',
                    Due_Date__c: '',
                    Finacial_Entity_Details__c: '',
                    Financial_Account__c: '',
                    Financial_Entity_A_C_Details__c: '',
                    Mode__c: '',
                    IsActive__c: true,
                    Reason__c: '',
                    Task_Id__c: this.TaskId,
                    isEditable: true,
                    isRecordExixst: false,
                    isDisabled: false,
                    isEntityTpeDisabled: false,
                    isPayeNameDisabled: true,
                    isBankAccountDisabled: true,
                    isPaymentModeDisabled: true,
                    isAmountDisabled: true,
                    isActionDisabled: false,
                    isCreatdOnDisabled: true,
                    isStatusDisabled: true,
                    entityTypePicklist: tempentityTypePicklist,
                    payMentModePiclist: temppaymentModePicklist,
                    selectedentitytype: '',
                    selectedpayeename: '',
                    selectedbankacc: '',
                    selectedpaymode: '',
                    selectedamount: '',
                    Status__c: 'Draft',
                    PayeeName: [],
                    createdon: new Date().toJSON().slice(0, 10),
                    isEditButtonDisabled: true,
                    bankAccList: this.bankEntityPicklist,
                    statusList: this.payAbleStatus,
                    entityList: this.entityTpye,
                    iseditDisabled:true,
                    isShowsave:false,
                    
                }

                temppayAblesList = [...temppayAblesList, newPayableObject];
                this.payAblesList = temppayAblesList;
                this.CheckforEditButtonVisibility('Create Disbursement Memo',newPayableObject.index);
                // New Row details ended
    }

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

    reformData(data) {
        debugger;
        let status = [];
        if (data.EntityACDetailsList) {
            data.EntityACDetailsList.forEach(item => {
                if (item.Financial_Entity__r) {
                    if (this.entityMap.has(item.Financial_Entity__r.Entity_Type__c)) {
                        this.entityMap.get(item.Financial_Entity__r.Entity_Type__c).push({ label: item.Financial_Entity__r.Name, value: item.Financial_Entity__r.Id })
                    } else {
                        this.entityMap.set(item.Financial_Entity__r.Entity_Type__c, [{ label: item.Financial_Entity__r.Name, value: item.Financial_Entity__r.Id }])
                    }
                    if (this.bankAccMap.has(item.Financial_Entity__r.Name)) {
                        this.bankAccMap.get(item.Financial_Entity__r.Name).push({ label: item.Bank_Account_Number__c, value: item.Id });
                    } else {
                        this.bankAccMap.set(item.Financial_Entity__r.Name, [{ label: item.Bank_Account_Number__c, value: item.Id }]);
                    }
                }
            })
            this.entityList = Array.from(this.entityMap.keys()).map(key => ({ label: key, value: key })).filter(item => item.label !== null && item.label !== undefined && item.value !== null && item.value !== undefined);
            console.log('entityList', this.entityList);
        }
        if (data.payAbleStatus) {
            data.payAbleStatus.forEach(item => { status.push({ label: item, value: item }) });
            this.statusList = status;
        }
    }

    newDrop(event) {
        debugger;
        this.newObjectType = 'newacdetails';
        this.isShowNewPayeeCom = true;
    }

    handleMenuSelect(event) {
        const selectedItemValue = event.detail.value;
        this.newObjectType = selectedItemValue
        this.isShowNewPayeeCom = true;
    }

    closeModal() {
        this.isShowNewPayeeCom = false;
        this.createRecevables=false;
    }

    sendClosedStatementToParent(isClosed) {
        debugger;
        //alert("Final Closed Method is Fired")
        const event = new CustomEvent('valuechange', {
            detail: {
                isclosed: isClosed,
                index: this.compIndex
            }
        });
        this.dispatchEvent(event);
    }

    /**
     * Receivables Functionality
     */
    @track Receivables=[];
    @track showReceivableAccount=false;
    HandleReceivable(){
        debugger;
        console.log('financialAccount',JSON.stringify(this.FinancialAccountRecord));
        if(this.FinancialAccountRecord!=null && this.FinancialAccountRecord!=undefined){
            if(this.FinancialAccountRecord.Receivables__r!=null && this.FinancialAccountRecord.Receivables__r!=undefined && this.FinancialAccountRecord.Receivables__r.length>0){
                  this.Receivables=this.FinancialAccountRecord.Receivables__r;
                  this.showReceivableAccount=true;
                  console.log('this.Receivables',JSON.stringify(this.Receivables));
            }
        }
    }

    handleCloseFAccount(){
        debugger;
        if(this.showReceivableAccount){
            this.showReceivableAccount=false;
        } 
    }

    /**
     * HyperLink For Financial Account
     */
    handleFinancialAccount(){
        debugger;
        let fId=this.FinancialAccountRecord.Id;
        window.open(OpportunityUrl+fId,'_blank')
    }

    /**
     * 
     */
    Check_mandatory_field_validation(memolist, rowindex) {
        debugger;
        let list_Memo_To_Create_Update = [];
        let shouldSkip=false;
        if (memolist.length > 0) {
            console.log('memolist',memolist);
            for(let i=0;i<memolist.length;i++){
                if(shouldSkip){return}
                if(memolist[i] && memolist[i].index == parseInt(rowindex)){
                    let currentObj = memolist[i];
                    list_Memo_To_Create_Update.push(memolist[i]);
                    this.checknull_values_for_Keys.forEach(key => {
                        if (key && shouldSkip==false) {
                            if (currentObj[key] != null && currentObj[key] != undefined && currentObj[key] != '') {
                                shouldSkip = false
                            } else {
                                shouldSkip = true;
                            }
                        }
                    });
                    break;
                }else{
                    console.log('Condition NOT Satisfied');
                }
            }
        }

        if (shouldSkip == false) {
            let counter =0;
            console.log('list_Memo_To_Create_Update',list_Memo_To_Create_Update);
            console.log('list_Memo_To_Create_Update',list_Memo_To_Create_Update.length);
            for (let i=0;i<list_Memo_To_Create_Update.length;i++){
                      if(list_Memo_To_Create_Update[i].isShowsave==false){
                        counter++;
                      }
            }
            if(counter==list_Memo_To_Create_Update.length){
                this.PrepareDataforUpsert(list_Memo_To_Create_Update,rowindex); 
            }
        }
    }

    handleSave(event){
        debugger;
        let memolist=[];
        let currentIndex = event.target.dataset.index;
        let cureentId = event.target.dataset.id;
        this.payAblesList.find((item)=>{
            if(item.index==cureentId){
                memolist.push(item);
            }
        })
        if(this.check_memo_closed_validation(memolist)){
            this.PrepareDataforUpsert(memolist,cureentId);
        }
    }


    PrepareDataforUpsert(memolist,rowindex){
       debugger;
       let Paybale__cList=[];
       for (let i = 0; i < memolist.length; i++) {
        let Paybale__c = {}
        if (memolist[i].isRecordExixst == false ) {
                Paybale__c.Amount__c = memolist[i].Amount__c;
                Paybale__c.Task_Id__c = this.TaskId;
                Paybale__c.Name = memolist[i].selectedpayeename;
                Paybale__c.Entity_Type__c = memolist[i].selectedentitytype;
                Paybale__c.Financial_Account__c = this.FinancialAccountId;
                Paybale__c.Finacial_Entity_Details__c = memolist[i].selectedpayeename;
                Paybale__c.Financial_Entity_A_C_Details__c = memolist[i].selectedbankacc;
                Paybale__c.Mode__c = memolist[i].selectedpaymode;
                Paybale__c.Status__c = memolist[i].Status__c;
                Paybale__cList.push(Paybale__c);
        }else if(memolist[i].isRecordExixst == true && memolist[i].Id!=null && memolist[i].Id!=undefined && memolist[i].Id!=""){
                Paybale__c.Id=memolist[i].Id;
                Paybale__c.Amount__c = memolist[i].Amount__c;
                Paybale__c.Task_Id__c = this.TaskId;
                Paybale__c.Name = memolist[i].selectedpayeename;
                Paybale__c.Entity_Type__c = memolist[i].selectedentitytype;
                Paybale__c.Financial_Account__c = this.recordId;
                Paybale__c.Finacial_Entity_Details__c = memolist[i].selectedpayeename;
                Paybale__c.Financial_Entity_A_C_Details__c = memolist[i].selectedbankacc;
                Paybale__c.Mode__c = memolist[i].selectedpaymode;
                Paybale__c.Status__c = memolist[i].Status__c;
                Paybale__cList.push(Paybale__c);
        } 
    }
        
       upsertPayableRecord({ PayablesLIst: Paybale__cList })
       .then(response => {

             if(this.payAblesList[(parseInt(rowindex)-1)].isRecordExixst==false && (this.payAblesList[(parseInt(rowindex)-1)].Id =="" || this.payAblesList[(parseInt(rowindex)-1)].Id ==null || this.payAblesList[(parseInt(rowindex)-1)].Id ==undefined)){   
                this.payAblesList[(parseInt(rowindex)-1)].Id = response[0].Id;
                this.payAblesList[(parseInt(rowindex)-1)].isRecordExixst = true;
                this.payAblesList[(parseInt(rowindex)-1)].iseditDisabled = this.payAblesList[(parseInt(rowindex)-1)].Task_Id__c==this.TaskId && this.payAblesList[(parseInt(rowindex)-1)].Id!=null && this.payAblesList[(parseInt(rowindex)-1)].Id!=undefined && this.payAblesList[(parseInt(rowindex)-1)].Id!='' && this.payAblesList[(parseInt(rowindex)-1)].Status__c!=='Draft'?false:true;
             }else if(this.payAblesList[(parseInt(rowindex)-1)].isRecordExixst==true && (this.payAblesList[(parseInt(rowindex)-1)].Id !="" && this.payAblesList[(parseInt(rowindex)-1)].Id !=null && this.payAblesList[(parseInt(rowindex)-1)].Id !=undefined)){
                console.log('Record Exist');
                this.payAblesList[(parseInt(rowindex)-1)].iseditDisabled = this.payAblesList[(parseInt(rowindex)-1)].Task_Id__c==this.TaskId && this.payAblesList[(parseInt(rowindex)-1)].Id!=null && this.payAblesList[(parseInt(rowindex)-1)].Id!=undefined && this.payAblesList[(parseInt(rowindex)-1)].Id!='' && this.payAblesList[(parseInt(rowindex)-1)].Status__c!=='Draft'?false:true;
                    if(this.payAblesList[(parseInt(rowindex)-1)].Status__c =='Memo Created'){
                        this.payAblesList[(parseInt(rowindex)-1)].isEntityTpeDisabled=true;
                        this.payAblesList[(parseInt(rowindex)-1)].isPayeNameDisabled=true;
                        this.payAblesList[(parseInt(rowindex)-1)].isBankAccountDisabled=true;
                        this.payAblesList[(parseInt(rowindex)-1)].isPaymentModeDisabled=true;
                        this.payAblesList[(parseInt(rowindex)-1)].isAmountDisabled=true;
                    }
             }
             this.isDisabledAddRowButton=false;
             this.isLoading=false;
             this.CheckforEditButtonVisibility('On Save/On_Delete');
       })
       .catch(error => {
           console.log('An error occurred:',error);
       });
    }

        check_memo_closed_validation(memolist) {
            debugger;
            let shouldskip = false;
            if (memolist.length > 0) {
                memolist.forEach(currentItem => {
                    if (shouldskip) { return }
                    if (currentItem != null && currentItem.isEditable) {
                        this.MeMoField_values_Before_submit.forEach((item)=>{
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

        handleEditAction(event){
            debugger;
            let currentIndex = event.target.dataset.index;
            let cureentId = event.target.dataset.id;
            
            console.log('currentIndex',currentIndex);
            console.log('cureentId',cureentId);
            if(this.payAblesList.length>0){
                this.payAblesList.forEach(item=>{
                    if(item.index == cureentId && item.Id == currentIndex){
                        item.isEntityTpeDisabled=false;
                        item.isPayeNameDisabled=false;
                        item.isBankAccountDisabled=false;
                        item.isPaymentModeDisabled=false;
                        item.isAmountDisabled= this.FinancialAccountRecord.Product__r.Disbursal_Type__c=='Full disbursal' ?true:false;
                        item.iseditDisabled=true;
                        item.isShowsave=true;
                    }else{
                        item.iseditDisabled=true; 
                    }
                })
            }
            this.isDisabledAddRowButton=true;
        }

        @track financialEntityACdetailId;
        showPophover(event){
          debugger;
            this.financialEntityACdetailId=event.currentTarget.dataset.value;
            this.show_data_onHover=true;
           console.log('financialEntityACdetailId',event.target.value);
        }
    
        hidePopHover(event) { 
           debugger 
           let isclose= event.detail.isclosed
           this.show_data_onHover=isclose;
        }


        CheckforEditButtonVisibility(ActionType,index){
            debugger;
            if(ActionType=='On Save/On_Delete'){ 
                this.payAblesList.forEach((item)=>{
                    if(item.Task_Id__c==this.TaskId && item.Id!=null){
                        item.isEntityTpeDisabled=true;
                        item.isPayeNameDisabled=true;
                        item.isBankAccountDisabled=true;
                        item.isPaymentModeDisabled=true;
                        item.isAmountDisabled= true;
                        item.iseditDisabled=false;
                        item.isShowsave=false;
                    }
               })
            }else if(ActionType=='Create Disbursement Memo'){
                this.payAblesList.forEach((item)=>{
                    if(item.Task_Id__c==this.TaskId && item.Id!=null && item.index !== index){
                       item.iseditDisabled=true;
                    }else if(item.Task_Id__c==this.TaskId && item.Id!=null && item.index == index){
                        item.isShowsave=true;
                    }
               })
            }
           
        }

        handleSuccess(){
            debugger;
            this.createRecevables=false;
        }

        handledisable(){
            debugger;
            this.disableReceivable_Save=true;
        }



    /**
     * NOW NOT IN USE
     */
    numberToWords(number) {
        const units = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];
        const teens = ["eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"];
        const tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"];
        const scales = ["", "thousand", "Lakh", "Crore", "trillion"];

        let words;

        if (number === 0) {
            words = "zero";
        } else {
            let groups = [];
            while (number > 0) {
                groups.push(number % 1000);
                number = Math.floor(number / 1000);
            }

            words = groups.map((group, index) => {
                if (group === 0) {
                    return "";
                }

                let hundreds = Math.floor(group / 100);
                let tensAndOnes = group % 100;
                let groupWords = [];

                if (hundreds > 0) {
                    groupWords.push(units[hundreds] + " hundred");
                }

                if (tensAndOnes > 10 && tensAndOnes < 20) {
                    groupWords.push(teens[tensAndOnes - 11]);
                } else {
                    let tensDigit = Math.floor(tensAndOnes / 10);
                    let onesDigit = tensAndOnes % 10;

                    if (tensDigit > 0) {
                        groupWords.push(tens[tensDigit]);
                    }

                    if (onesDigit > 0) {
                        groupWords.push(units[onesDigit]);
                    }
                }

                if (index > 0) {
                    groupWords.push(scales[index]);
                }

                return groupWords.join(" ");
            }).reverse().join(" ");
        }

        return words.trim();
    }

    old_handleEditAction(event) {
        debugger;
        let eventName = event.target.name;
        let currentIndex = event.target.dataset.id;
        let currentValue = event.target.value;
        let cureentId = event.target.dataset.id;
        // let currentIndex = event.target.Id;
        let prevIndex = currentIndex - 1;
        this.payAblesList[parseInt(currentIndex) - 1].isRecordExixst = false;

        for (let i = 0; i < this.payAblesList.length; i++) {
            if (this.payAblesList[i].index == currentIndex) {
                if (this.payAblesList[i].isRecordExixst == false) {
                    this.payAblesList[i].isRecordExixst = true;
                } else {
                    this.payAblesList[i].isRecordExixst = false;
                }

            }

        }
    }

    showNewRecevabls(event){
        debugger;
        this.createRecevables=true;
    }

}