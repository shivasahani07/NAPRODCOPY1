/* eslint-disable no-empty */
/* eslint-disable no-debugger */
import {
    LightningElement,
    api,
    wire,
    track
} from "lwc";
import getRelatedContactAccount from "@salesforce/apex/PayableDetailsController.getRelatedContactAccount";
import verifyExistingRecord from "@salesforce/apex/PayableDetailsController.verifyExistingRecord";
import upsertSObject from "@salesforce/apex/PayableDetailsController.uppesertSobject";
import dynamicRecordDeletion from "@salesforce/apex/DynamicRecordDeletion.deleteRecords";
import createTask from "@salesforce/apex/PayableDetailsController.createTask";
import getIFSCDetails from "@salesforce/apex/IFSCService.getIFSCDetails";
import FinancialEntityACDetails_Verification_Status_inprogress  from '@salesforce/label/c.FinancialEntityACDetails_Verification_Status_inprogress';
import Financial_Entity_Disburse_Amount_Validation from '@salesforce/label/c.Financial_Entity_Disburse_Amount_Validation';
import {
    refreshApex
} from '@salesforce/apex';
import createAccountContactDetailsOnBehalofPayeeNumber from "@salesforce/apex/PayableDetailsController.createAccountContactDetailsOnBehalofPayeeNumber";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";

export default class Lwc_financial_handler extends LightningElement {
    @api financialAccoundId;
    @api recordType;
    @api currentPayeId;
    @api taskId = "00TBl000002NKWSMA4";
    @track payeeList = [];
    @track payeeAcdetailsList = [];
    @track EntityTypePicklist;
    @track payMentverificationTypePicklist;
    @track accountTypePicklist;
    @track isShowPayeeComp = false;
    @track isShowPayeeACdetailComp;
    @track relatedContacts = [];
    @track relatedAccount = [];
    @track relatedFianancialEntity = [];
    @track relatedFianancialEntityAccountDetails = [];
    @track relatedFinancialMap;
    @track disabledAddRow = false;
    @track AddNewPayeeRowDisable = false;
    @track accountListExistsByphoneORemail = [];
    @track contactListExistsByphoneORemail = [];
    @track isBlockAllOtherEdit = false;
    @track ifscDetails;
    @track isShowIfsc;
    @track lastIFSCveirfiedIndex;
    @track wrapperresult;
    @track isDisabledSubmitButton = true;
    @track isShowMODTCOMP = false;
    @api currentBankDetailsRecordId;
    @track currentTobeUpdateBankdetailsId;
    @track currentTobeUpdateBankdetailsindex
    @track currentTobeUpdateBankdetailsValue;
    @track loaded = false;
    @track isShowConfirmationComp = false;
    @api confirmationVariant = 'success'
    @track isResponsePositive = false;
    @api isTaskOwnerLogin;
    @track isShowEsistingAccount=false;
    @track defaultSelect='Select';

    connectedCallback() {
        this.configureObjectType();
    }

    @wire(getRelatedContactAccount, {
        financialAccountId: '$financialAccoundId'
    })
    wiredData(result) {
        this.wrapperresult = result;
        debugger;
        if (result.data) {
            this.prepareData(result.data);
            console.log("Data", result.data);
        } else if (result.error) {
            console.error("Error:", result.error);
        }
    }

    hardRefresh() {
        debugger;
        // location.replace(location.href);
        // eval("$A.get('e.force:refreshView').fire();");
        // location.reload(true);
    }

    refreshData() {
        debugger;
        // this.hardRefresh();
        return refreshApex(this.wrapperresult);
    }

    

    prepareData(data) {
        debugger;
        // Mapping entity types
        this.isDisabledSubmitButton = true;
        this.EntityTypePicklist = data.entityTypesValue.map((value) => ({
            label: value,
            value
        }));

        // Mapping payment verification types
        this.payMentverificationTypePicklist = data.verificationTypesValue.map(
            (value) => ({
                label: value,
                value
            })
        );

        this.accountTypePicklist=data.accountTypePicklist.map(
          (value) => ({
                label: value,
                value
            })
        );

        // Mapping related financial entities to a map for easy access
        this.relatedFinancialMap = data.relatedFinancialEntity.map((value) => ({
            label: value.Name,
            value: value.Id
        }));
        this.relatedFianancialEntity = data.relatedFinancialEntity;

        // Mapping existing payee list
        this.payeeList = this.prepareFinancialEntityData(
            data.relatedFinancialEntity
        );
        // Mapping existing payee AC details list
        this.payeeAcdetailsList = this.prepareFinancialEntityACData(
            data.EntityACDetailsList
        );
    }

    prepareFinancialEntityData(relatedFinancialEntity) {
        debugger;
        let newExixtingPayee = relatedFinancialEntity.map((entity, i) => {
            const account = entity.Account_Name__r || {};
            return {
                id: entity.Id,
                index: i,
                email: account.Email_Id__c || null,
                name: entity.Name,
                phone: account.Phone || null,
                typePiclist: this.EntityTypePicklist,
                type: entity.Entity_Type__c,
                Task_ID__c: entity.Task_ID__c,
                disbursedAmount: entity.Amount_Disbursed__c,
                toBeDisbursedAmount: entity.Amount_To_Be_Disbursed__c,
                isEditable: false,
                isEditableDisabled:true,
                isDisabledDeleteButton: true,
                isEditbleButtonOn: entity.Task_ID__c !== this.taskId,
                Account_Name__c:account.Id,
                isShowEditableButton:true,
                isShowEditableButtonDisabled:entity.Task_ID__c !== this.taskId
                
            };
        });
        this.AddNewPayeeRowDisable = false;
        return newExixtingPayee;
    }

    tempRefresh(){
        debugger
        this.payeeAcdetailsList[parseInt(0)].isPayeeNameChanged=true;
        this.currentTobeUpdateBankdetailsId=this.payeeAcdetailsList[parseInt(0)].id;
        this.upperMethodforBankDetails(this.refreshApex());
        
    }

    refreshApex() {
        debugger;
        if (this.payeeAcdetailsList.length > 0) {
            let newpayeeAcdetailsList = [];
                let Financial_Entity_AC_Detail__c = {};
                Financial_Entity_AC_Detail__c.Id = this.payeeAcdetailsList[parseInt(0)].id;
                Financial_Entity_AC_Detail__c.isChanged__c =this.payeeAcdetailsList[parseInt(0)].isChanged__c == true ? false : true;
                newpayeeAcdetailsList.push(Financial_Entity_AC_Detail__c);
            return newpayeeAcdetailsList;
        } else {
            this.showToast('No records to refresh', 'empty ', 'alert');
            return false;
        }
   
   
    }



    prepareFinancialEntityACData(EntityACDetailsList) {
         debugger;
         let newExixtingPayeeAC = EntityACDetailsList.map((detail, i) => {
            // const financialentity = detail.Financial_Entity__r || {};
            return this.reformBankDetails(detail, i);
         });
         this.disabledAddRow = false;
         return newExixtingPayeeAC;
     }

     //new method for backEntryData preparetion
     reformBankDetails(detail,i){
        debugger;
        const financialentity = detail.Financial_Entity__r || {};
        let tempBankDetailsOnject={};
               tempBankDetailsOnject.id=detail.Id;
               tempBankDetailsOnject.index=i;
               tempBankDetailsOnject.selectedPayeeId= financialentity.Id;
               tempBankDetailsOnject.Task_ID__c= detail.Task_ID__c;
               tempBankDetailsOnject.isNotSameTask=detail.Task_ID__c != this.taskId;
            //    tempBankDetailsOnject.isSameTaskID= detail.Task_ID__c === this.taskId;
               tempBankDetailsOnject.isSameTaskID = detail.Task_ID__c === this.taskId && detail.Task_ID__c != null && detail.Task_ID__c != undefined;
               tempBankDetailsOnject.isEditableDisabled= detail.Digitally_Verified__c;
               tempBankDetailsOnject.newPayeeIdPicList= this.relatedFinancialMap;
               tempBankDetailsOnject.isDisabledPayeeNameEdit= (financialentity.Id !== undefined || tempBankDetailsOnject.isEditableDisabled);
               tempBankDetailsOnject.bankAccountName= detail.Name;
               tempBankDetailsOnject.isDisabledBankAccountHolderName=(tempBankDetailsOnject.isSameTaskID || tempBankDetailsOnject.isNotSameTask) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit);
               tempBankDetailsOnject.bankNumber= detail.Bank_Account_Number__c;
               tempBankDetailsOnject.isDisabledBankAccountNumber= ( tempBankDetailsOnject.isSameTaskID && detail.Bank_Account_Number__c )||(tempBankDetailsOnject.isNotSameTask) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit);
               tempBankDetailsOnject.Bank_AccountTypePicklist= this.accountTypePicklist;
               tempBankDetailsOnject.Bank_Account_Type__c= detail.Bank_Account_Type__c;
               tempBankDetailsOnject.isDisabledAccountType=( tempBankDetailsOnject.isSameTaskID ||tempBankDetailsOnject.isNotSameTask) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit);
               tempBankDetailsOnject.IFSC= detail.IFSC_Code__c;
               tempBankDetailsOnject.isDisabledIFSCcode= ( tempBankDetailsOnject.isSameTaskID ||tempBankDetailsOnject.isNotSameTask) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit);
               tempBankDetailsOnject.bankName= detail.Bank_Name__c;
               tempBankDetailsOnject.isDisabledBankName= true;
               tempBankDetailsOnject.branchName= detail.Branch_Name__c;
               tempBankDetailsOnject.isDisabledBrachName= true;
               tempBankDetailsOnject.Verification_Status__c=  detail.Verification_Status__c;
               tempBankDetailsOnject.isDisabledAccountVerifyType= (tempBankDetailsOnject.isSameTaskID && detail.Digitally_Verified__c ) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit) || !tempBankDetailsOnject.isDisabledBankAccountNumber;
               tempBankDetailsOnject.verificationTypePicklist=this.payMentverificationTypePicklist;
            // tempBankDetailsOnject.verificationType= ((tempBankDetailsOnject.isDisabledAccountVerifyType ==false ) || (!FinancialEntityACDetails_Verification_Status_inprogress.includes(tempBankDetailsOnject.Verification_Status__c)) ? detail.Digitally_Verification_Method__c:'');
               tempBankDetailsOnject.verificationType= ((tempBankDetailsOnject.isDisabledAccountVerifyType ==true ) || (FinancialEntityACDetails_Verification_Status_inprogress.includes(tempBankDetailsOnject.Verification_Status__c)) ? detail.Digitally_Verification_Method__c:'');

               tempBankDetailsOnject.Digitally_Verified__c= detail.Digitally_Verified__c ||tempBankDetailsOnject.isNotSameTask;
               tempBankDetailsOnject.Physically_verified__c= detail.Physically_verified__c;
               tempBankDetailsOnject.VerifyPhysicallyCheckbox= detail.Physically_verified__c;
               tempBankDetailsOnject.isDisabledVerifyPhysicallyCheckbox= ( tempBankDetailsOnject.isSameTaskID) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit);
               tempBankDetailsOnject.isShowUpdateGreenButton= false;
            //    tempBankDetailsOnject.isDisabledEditButton=true;
               tempBankDetailsOnject.isDisabledEditButton= (!tempBankDetailsOnject.isSameTaskID || tempBankDetailsOnject.isNotSameTask) || (detail.Digitally_Verified__c || detail.Physically_verified__c) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit);
            // tempBankDetailsOnject.isDisabledEditButton=(tempBankDetailsOnject.isSameTaskID ) && (detail.Digitally_Verified__c && detail.Physically_verified__c) || (!tempBankDetailsOnject.Verification_Status__c.includes(tempBankDetailsOnject.Verification_Status__c));
               tempBankDetailsOnject.isDisabledDeleteButton= true;
               tempBankDetailsOnject.isSendableForPennyDropVerification= !tempBankDetailsOnject.isDisabledAccountVerifyType || !tempBankDetailsOnject.isEditableDisabled ||tempBankDetailsOnject.isNotSameTask;
            //    tempBankDetailsOnject.isShowPhycalyVerifyButton= !tempBankDetailsOnject.isSendableForPennyDropVerification && detail.Physically_verified__c;
               tempBankDetailsOnject.isShowPhycalyVerifyButton=detail.Physically_verified__c && tempBankDetailsOnject.isSameTaskID;
               tempBankDetailsOnject.verificationTypePiclist=this.payMentverificationTypePicklist;
               tempBankDetailsOnject.isDisabledPennyDropButton= (!tempBankDetailsOnject.isDisabledAccountVerifyType ||tempBankDetailsOnject.isNotSameTask) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit) || !tempBankDetailsOnject.isDisabledBankAccountNumber;
               tempBankDetailsOnject.isShowPhysicallVerifiedCheckbox=detail.Physically_verified__c;
               tempBankDetailsOnject.isChanged__c=detail.isChanged__c;
               tempBankDetailsOnject.isAllRequiredFiledClosed=( tempBankDetailsOnject.isDisabledPayeeNameEdit &&  tempBankDetailsOnject.isDisabledBankAccountHolderName && tempBankDetailsOnject.isDisabledBankAccountNumber && tempBankDetailsOnject.isDisabledAccountType && tempBankDetailsOnject.isDisabledIFSCcode && tempBankDetailsOnject.isDisabledBankName && tempBankDetailsOnject.isDisabledBrachName) &&(tempBankDetailsOnject.Digitally_Verified__c || tempBankDetailsOnject.Physically_verified__c);
               tempBankDetailsOnject.isDisabledisPhysicallyVerificationRequired=(!tempBankDetailsOnject.isDisabledPayeeNameEdit);
               tempBankDetailsOnject.isShowCheckBoxs=true;
              
               console.log('tempBankDetailsOnject--->',tempBankDetailsOnject);
               return tempBankDetailsOnject;
           }
     
    //  reformBankDetails(detail,i){
    //      debugger;
    //      const financialentity = detail.Financial_Entity__r || {};
    //      let tempBankDetailsOnject={};
    //             tempBankDetailsOnject.id=detail.Id;
    //             tempBankDetailsOnject.index=i;
    //             tempBankDetailsOnject.selectedPayeeId= financialentity.Id;
    //             tempBankDetailsOnject.Task_ID__c= detail.Task_ID__c;
    //             tempBankDetailsOnject.isSameTaskID= detail.Task_ID__c === this.taskId;
    //             tempBankDetailsOnject.isEditableDisabled= detail.Digitally_Verified__c;
    //             tempBankDetailsOnject.newPayeeIdPicList= this.relatedFinancialMap;
    //             tempBankDetailsOnject.isDisabledPayeeNameEdit= financialentity.Id !== undefined || tempBankDetailsOnject.isEditableDisabled;
    //             tempBankDetailsOnject.bankAccountName= detail.Name;
    //             tempBankDetailsOnject.isDisabledBankAccountHolderName= (detail.Name !== undefined && tempBankDetailsOnject.isDisabledPayeeNameEdit) || (tempBankDetailsOnject.isEditableDisabled || !tempBankDetailsOnject.isSameTaskID);
    //             tempBankDetailsOnject.bankNumber= detail.Bank_Account_Number__c;
    //             tempBankDetailsOnject.isDisabledBankAccountNumber= (detail.Bank_Account_Number__c !== undefined && tempBankDetailsOnject.isDisabledBankAccountHolderName) || (tempBankDetailsOnject.isEditableDisabled || !tempBankDetailsOnject.isSameTaskID);
    //             tempBankDetailsOnject.Bank_AccountTypePicklist= this.accountTypePicklist;
    //             tempBankDetailsOnject.Bank_Account_Type__c= detail.Bank_Account_Type__c;
    //             tempBankDetailsOnject.isDisabledAccountType= (detail.Bank_Account_Type__c !== undefined && tempBankDetailsOnject.isDisabledBankAccountHolderName) || (tempBankDetailsOnject.isEditableDisabled || !tempBankDetailsOnject.isSameTaskID);
    //             tempBankDetailsOnject.IFSC= detail.IFSC_Code__c;
    //             tempBankDetailsOnject.isDisabledIFSCcode= (detail.IFSC_Code__c !== undefined && tempBankDetailsOnject.isDisabledAccountType) || (tempBankDetailsOnject.isEditableDisabled || !tempBankDetailsOnject.isSameTaskID);
    //             tempBankDetailsOnject.bankName= detail.Bank_Name__c;
    //             tempBankDetailsOnject.isDisabledBankName= true;
    //             tempBankDetailsOnject.branchName= detail.Branch_Name__c;
    //             tempBankDetailsOnject.isDisabledBrachName= true;
    //             tempBankDetailsOnject.verificationTypePicklist= this.payMentverificationTypePicklist;
    //             tempBankDetailsOnject.verificationType= detail.Digitally_Verification_Method__c;
    //             tempBankDetailsOnject.isDisabledAccountVerifyType= (tempBankDetailsOnject.isDisabledIFSCcode) || (tempBankDetailsOnject.isEditableDisabled || !tempBankDetailsOnject.isSameTaskID);
    //             tempBankDetailsOnject.Verification_Status__c= detail.Verification_Status__c;
    //             tempBankDetailsOnject.Digitally_Verified__c= detail.Digitally_Verified__c;
    //             tempBankDetailsOnject.Physically_verified__c= detail.Physically_verified__c;
    //             tempBankDetailsOnject.VerifyPhysicallyCheckbox= detail.Physically_verified__c;
    //             tempBankDetailsOnject.isDisabledVerifyPhysicallyCheckbox= detail.Physically_verified__c || detail.Verification_Status__c !== 'Failed' || detail.Bank_Account_Number__c !== undefined || (tempBankDetailsOnject.isEditableDisabled);
    //             tempBankDetailsOnject.isShowUpdateGreenButton= false;
    //             tempBankDetailsOnject.isDisabledEditButton= !tempBankDetailsOnject.isDisabledPayeeNameEdit || !tempBankDetailsOnject.isSameTaskID || tempBankDetailsOnject.isEditableDisabled;
    //             tempBankDetailsOnject.isDisabledDeleteButton= true;
    //             tempBankDetailsOnject.isSendableForPennyDropVerification= !tempBankDetailsOnject.isDisabledAccountVerifyType || !tempBankDetailsOnject.isEditableDisabled;
    //             tempBankDetailsOnject.isShowPhycalyVerifyButton= !tempBankDetailsOnject.isSendableForPennyDropVerification && detail.Physically_verified__c;
    //             tempBankDetailsOnject.verificationTypePiclist=this.payMentverificationTypePicklist;
    //             tempBankDetailsOnject.isShowPhysicallVerifiedCheckbox=detail.Physically_verified__c
    //             console.log('tempBankDetailsOnject--->',tempBankDetailsOnject);
    //             return tempBankDetailsOnject;
    //         }
    
    


    configureObjectType() {
        debugger;
        if (this.recordType == "newpayee") {
            this.isShowPayeeComp = true;
        } else if (this.recordType == "newacdetails") {
            this.isShowPayeeACdetailComp = true;
        }
    }

    editPayeeButton(event){
        debugger
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.enabledEditingPayee(currentIndex);

    }
   

    handleInputChange(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        const minPhoneLength =7;
        const minEmailLength = 5;

        if (eventName == "type") {
            this.selectTypeChangeHandler(event);
        } else if (eventName == "phone") {
            this.selectEmailChangeHandler(event);
            if (inputValue.length >= minPhoneLength) {
               
            }
        } else if (eventName == "email") {
            if (inputValue.length >= minEmailLength) {
                this.selectEmailChangeHandler(event);
            }
        } else if (eventName == "name") {
            this.selectNameChangehandler(event);
        } else if (eventName == "Amount_to_be_disbursed") {
            this.ToBedisbursedAmountChangeHandler(event);
        } else if (eventName == "disbursed_Amount") {
            this.disbursedAmountChangeHandler(event);
        } else {}
    }

    selectNameChangehandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        if(this.checkCompoLevelDuplicaton(inputValue,this.payeeList,'name')){
            this.payeeList[parseInt(currentIndex)].name = inputValue;
        }else{
            this.payeeList[parseInt(currentIndex)].name ='';
            return;
        }
        
    }

    selectEmailChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        if (this.checkCompoLevelDuplicaton(inputValue, this.payeeList, eventName)) {
            if(inputValue.length>9){
                this.verifyExistingRecordFromBackend(inputValue, currentIndex);
            if (eventName == "email") {
                this.payeeList[parseInt(currentIndex)].email = inputValue;
            } else if (eventName == "phone") {
                this.payeeList[parseInt(currentIndex)].phone = inputValue;
            }
            }
        } else {
            this.verifyExistingRecordFromBackend(inputValue, currentIndex);
            if (eventName == "email") {
                this.payeeList[parseInt(currentIndex)].email = inputValue;
            } else if (eventName == "phone") {
                this.payeeList[parseInt(currentIndex)].phone = inputValue;
            }
        }
    }
    payMentverificationTypePicklistm(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        this.payeeAcdetailsList[parseInt(currentIndex)].verificationType =inputValue;
        
    }

    checkCompoLevelDuplicaton(currentValue, dataList, field) {
        debugger;
        for (let i = 0; i < dataList.length; i++) {
            if (dataList[i][field] == currentValue) {
                this.showToast(`${field} duplicate value found`, "details alert", "error");
                // alert("Duplicate value found");
                return false; // Duplicate found, so return false
            }
        }
        return true; // No duplicates found, return true
    }

    handleDeleteAction(event) {
        debugger;
        let recordIdsTobeDeleted = [];
        let currentIndex = event.target.dataset.index;
        let recordId = event.target.dataset.id;
        this.DeletePayeeRow(currentIndex);
        if (recordId) {
            recordIdsTobeDeleted.push(recordId);
            this.dynamicallyRecordsDeletion(recordIdsTobeDeleted);
        }
        this.AddNewPayeeRowDisable = false;
    }

    DeletePayeeRow(index) {
        debugger;
        let parseIndex = parseInt(index);
        this.payeeList.splice(parseIndex, 1);

        this.payeeList = [...this.payeeList]; // Ensure reactivity
    }

    // new methods for custom comp

    AddNewPayeeRow() {
        debugger;
        let tempPayeeObjectList = [];
        let index = this.payeeList.length;
        let tempPayeeObject = {
            index: index,
            email: "",
            phone: "",
            name: "",
            typePiclist: this.EntityTypePicklist,
            type: "",
            isEditable: true,
            isEditableDisabled: false,
            disbursedAmount: 0,
            toBeDisbursedAmount: "",
            isDisabledDeleteButton: false,
            Financial_Account__c: this.financialAccoundId,
            Task_ID__c: this.taskId,
            Account_Name__c:'',
        };
        tempPayeeObjectList = [...this.payeeList, tempPayeeObject];
        this.payeeList = tempPayeeObjectList;
        this.AddNewPayeeRowDisable = true;
    }


    newAddrowBankDetails(){
        debugger;
        let temppayeeAcdetailObjectList = [];
        let index = this.payeeAcdetailsList.length;
        let isEditableDisabled =true;
        let isDisabledPayeeNameEdit=true;
        let temppayeeAcdetailObject = {
                index:index,
                selectedPayeeId:'',
                Task_ID__c:this.taskId,
                isSameTaskID:true,
                isEditableDisabled:false,
                newPayeeIdPicList:this.relatedFinancialMap,
                isDisabledPayeeNameEdit:false,
                bankAccountName:'',
                isDisabledBankAccountHolderName:true,
                bankNumber:'',
                isDisabledBankAccountNumber:true,
                Bank_AccountTypePicklist:this.accountTypePicklist,
                Bank_Account_Type__c:'',
                isDisabledAccountType:true,
                IFSC:'',
                isDisabledIFSCcode:true,
                bankName:'',
                isDisabledBankName:true,
                branchName:'',
                isDisabledBrachName:true,
                verificationTypePiclist: this.payMentverificationTypePicklist,
                verificationType:'',
                isDisabledAccountVerifyType:true,
                Verification_Status__c:'New',
                Digitally_Verified__c: '',
                Physically_verified__c:'',
                VerifyPhysicallyCheckbox:false,
                IsDisabledVerifyPhysicallyCheckbox:true,
                isShowUpdateGreenButton: true,
                isDisabledEditButton:true,
                isDisabledDeleteButton: false,
                isSendableForPennyDropVerification:false,
                isShowPhycalyVerifyButton:false,
                isShowCheckBoxs:false,
                
        };
        temppayeeAcdetailObjectList = [
            ...this.payeeAcdetailsList,
            temppayeeAcdetailObject
        ];
        this.payeeAcdetailsList = temppayeeAcdetailObjectList;
        this.disabledAddRow = true;
        // this.isBlockAllOtherEdit = true;
        // this.blockAllOthersRowsforBackDetails(index);
    }

    AddNewPayeeRowAcDet() {
        debugger;
        let temppayeeAcdetailObjectList = [];
        let index = this.payeeAcdetailsList.length;
        let temppayeeAcdetailObject = {
            index: index,
            isEditable: true,
            isEditableDisabled: true,
            // name: "",
            // payeeName: "",
            bankNumber: "",
            branchName: "",
            bankName: "",
            IFSC: "",
            Verification_Status__c: "New",
            selectedPayeeId: "",
            newPayeeIdPicList: this.relatedFinancialMap,
            verificationTypePiclist: this.payMentverificationTypePicklist,
            verificationType: "",
            Task_ID__c: this.taskId,
            isDisabledDeleteButton: false,
            Financial_Account__c: this.financialAccoundId,
            // isPhysicallyVerificationRequiredDisabled: true,
            isRedRow: 'green',
            Bank_AccountTypePicklist:this.accountTypePicklist,
            Bank_Account_Type__c:'',
            bankAccountName:'',
            isPhysicallyVerificationRequiredDisabled: false,
            isDisabledVerifyButton: true,
            isDisabledPayeeNameEdit: true,
            isShowUpdateGreenButton: true,
            isDisabledAccountVerifyType:true,
            isDisabledAccountType:true,
            isDisabledIFSCcode:true,
            isDisabledBrachName:true,
            isDisabledBankName:true,
            isDisabledPayeeName:true,
            isDisabledBankAccountHolderName:true,
            isDisabledBankAccountNumber:true,
            isPayeeNameChanged:true,
        };
        temppayeeAcdetailObjectList = [
            ...this.payeeAcdetailsList,
            temppayeeAcdetailObject
        ];
        this.payeeAcdetailsList = temppayeeAcdetailObjectList;
        this.disabledAddRow = true;
        // this.isBlockAllOtherEdit = true;
        // this.blockAllOthersRowsforBackDetails(index);
    }

    handleDeleteActionACDetailsRow(event) {
        debugger;
        let recordIdsTobeDeleted = [];
        let currentIndex = event.target.dataset.index;
        let recordId = event.target.dataset.id;
        this.DeletePayeeRowACDetails(currentIndex);
        if (recordId) {
            recordIdsTobeDeleted.push(recordId);
            this.dynamicallyRecordsDeletion(recordIdsTobeDeleted);
        }
        this.disabledAddRow = false;
    }

    DeletePayeeRowACDetails(index) {
        debugger;
        let parseIndex = parseInt(index);
        this.payeeAcdetailsList.splice(parseIndex, 1);
        this.payeeAcdetailsList = [...this.payeeAcdetailsList];
    }

    verifyExistingRecordFromBackend(emailORphone, recordIndex) {
        debugger;
        let checkedRecordIndex = recordIndex;
        verifyExistingRecord({
                emailORphone: emailORphone
            })
            .then((response) => {
                if (response)
                    this.accountListExistsByphoneORemail = response.existingAccount;
                this.contactListExistsByphoneORemail = response.existingContact;
                if (
                    this.accountListExistsByphoneORemail ||
                    this.contactListExistsByphoneORemail
                ) {
                    console.log('response.existingAccount--->', response.existingAccount);
                    console.log('response.existingContact--->', response.existingContact);
                    this.showToast("Scuccess", "already exists please check", "success");
                    this.payeeList[parseInt(checkedRecordIndex)].name = response.existingAccount[0].Name;
                    this.payeeList[parseInt(checkedRecordIndex)].phone = response.existingAccount[0].Phone;
                    this.payeeList[parseInt(checkedRecordIndex)].email = response.existingAccount[0].Email_Id__c;
                    // this.payeeList[parseInt(checkedRecordIndex)].Account_Name__c = response.existingAccount[0].Id;
                    this.isShowEsistingAccount=true;

                } else {}
            })
            .catch((error) => {
                this.showToast(
                    "something went wrong",
                    "Error Please try again latter",
                    "error"
                );
            });
    }

    hidePopHover(event) { 
        debugger 
        let isclose= event.detail.isclosed
        this.show_data_onHover=isclose;
     }

    showToast(titel, message, variant) {
        const event = new ShowToastEvent({
            title: titel,
            message: message,
            variant: variant,
            mode: "dismissable"
        });
        this.dispatchEvent(event);
    }

    handleChangePayeeRecordPicker(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        this.payeeAcdetailsList[parseInt(currentIndex)].payeeName = selectedRecord;
    }

    handleInputChangeACdetails(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let itemValue = event.target.value;
        if (eventName == "bankNumber") {
            this.selectAcbankNumberHandler(event);
        } else if (eventName == "selectPayee") {
            this.selectAcPayeeNameHandler(event);
        } else if (eventName == "bankName") {
            this.selectAcbankNameHandler(event);
        } else if (eventName == "IFSC") {
            this.selectAcIFSCHandler(event);
        } else if (eventName == "branchName") {
            this.selectAcbranchNameHandler(event);
        } else if (eventName == "verificationType") {
            this.selectAcverificationTypeHandler(event);
        } else if (eventName == "isVerifiedPhysically") {
            this.showPhysicalVerifyButton(event);
        } else if (eventName == "selectPayeeEdit") {
            this.selectAcPayeeNameHandlerEditable(event);
        }else if(eventName=='Bank_Account_Type__c'){
            this.selectBackAccountTypeChangeHandler(event);
        }else if(eventName=='bankAccountName'){
            this.selectBackAccountNameChangeHandler(event);
        }
    }


    selectBackAccountNameChangeHandler(event){
      debugger;
      let currentIndex = event.target.dataset.index;
      let eventName = event.target.name;
      let inputValue = event.target.value;
      let isChecked = event.target.checked;
      this.payeeAcdetailsList[parseInt(currentIndex)].bankAccountName = inputValue;
      this.payeeAcdetailsList[parseInt(currentIndex)].Name = inputValue;
      if(inputValue == "" || inputValue  == null){
        this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountNumber =true;
      }else{
        this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountNumber =false;
      }
      

    }
    isShowEsistingAccountClosed(event){
        this.isShowEsistingAccount=false;
    }

    selectBackAccountTypeChangeHandler(event){
      debugger;
      let currentIndex = event.target.dataset.index;
      let eventName = event.target.name;
      let inputValue = event.target.value;
      let isChecked = event.target.checked;
      this.payeeAcdetailsList[parseInt(currentIndex)].Bank_Account_Type__c = inputValue;
      if(this.payeeAcdetailsList[parseInt(currentIndex)].Bank_Account_Type__c){
        this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledIFSCcode =false;
        return ;
      }else{
        this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledIFSCcode =true;
      }
      if(!this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber){
          this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType =true;
      }else{
          this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = false;
      }

    }

    showPhysicalVerifyButton(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        let isChecked = event.target.checked;
        let recordId=event.target.dataset.id;
     
        if (isChecked) {
            if(recordId){
                this.payeeAcdetailsList[parseInt(currentIndex)].isShowPhycalyVerifyButton = true;
            }else{

            }
            this.payeeAcdetailsList[parseInt(currentIndex)].isEditbleButtonOn = true;
            // this.blockAllOthersRowsforBackDetails(currentIndex);
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].isShowPhycalyVerifyButton = false;
            this.payeeAcdetailsList[parseInt(currentIndex)].isEditbleButtonOn = false;
            // this.unblockAllOthersRowsforBackDetails(currentIndex);
        }
    }

    selectAcPayeeNameHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        let cuurectRecordId=event.target.dataset.id;
        if(cuurectRecordId ==null || cuurectRecordId==""){
            if(inputValue ==null|| inputValue ==""|| inputValue ==undefined ){
                this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountHolderName=true;
                // this.payeeAcdetailsList[parseInt(currentIndex)].bankAccountName ="";
                // this.selectBackAccountNameChangeHandler(event);
            }else{
                this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountHolderName=false;
            }
        }else{
            this.payeeAcdetailsList[parseInt(currentIndex)].selectedPayeeId = inputValue;
            this.submitforBackDetailsSelectedRow(currentIndex);

        }
                
        
    }

    selectAcPayeeNameHandlerEditable(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        this.currentTobeUpdateBankdetailsId = event.target.dataset.id;
        this.currentTobeUpdateBankdetailsindex = currentIndex;
        this.currentTobeUpdateBankdetailsValue = inputValue;
        if(event.target.dataset.id){
            // this.isShowConfirmationComp = true;
            this.payeeAcdetailsList[parseInt(currentIndex)].isShowUpdateGreenButton =true;
            this.payeeAcdetailsList[parseInt(currentIndex)].selectedPayeeId = inputValue;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton=false;
            

        }else{
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountHolderName =false;
            this.payeeAcdetailsList[parseInt(currentIndex)].selectedPayeeId = inputValue;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton =false;
        }
       
    }

    selectAcbankNameHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        if(inputValue ==""){
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBrachName =true;
            
        }else{
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBrachName =false;
            this.payeeAcdetailsList[parseInt(currentIndex)].bankName = inputValue;
        }
        
    }

    selectAcIFSCHandler(event) {
        debugger;
        const ifscRegex = /^[A-Z]{4}0[A-Z0-9]{6}$/; // Regex for IFSC code format
        const currentIndex = parseInt(event.target.dataset.index, 10);
        const inputValue = event.target.value.trim();
        const isValidIfsc = ifscRegex.test(inputValue);
    
        this.payeeAcdetailsList[currentIndex].isDisabledAccountVerifyType = true;
        this.payeeAcdetailsList[currentIndex].verificationType = "";
    
        if (!isValidIfsc || inputValue == "") {
            this.resetBankDetails(currentIndex);
            return;
        }
    
        this.payeeAcdetailsList[currentIndex].IFSC = inputValue;
    
        if (inputValue.length === 11) {
            this.verifyIFSCCode(inputValue, currentIndex);
            this.resetBankDetailsAsPerIFSCcode(inputValue,currentIndex);
        } else {
            this.resetBankDetails(currentIndex);
        }
    }
    
    resetBankDetails(index) {
        this.payeeAcdetailsList[index].bankName = "";
        this.payeeAcdetailsList[index].isDisabledBankName = true;
        this.payeeAcdetailsList[index].isDisabledBrachName = true;
        this.payeeAcdetailsList[index].branchName = "";
    }
    

    resetBankDetailsAsPerIFSCcode(newIFSCcode, index) {
        debugger;
        if (!newIFSCcode == this.payeeAcdetailsList[parseInt(index)].IFSC) {
            this.payeeAcdetailsList[parseInt(index)].branchName = '';
            this.payeeAcdetailsList[parseInt(index)].bankName = '';
        }
    }



    selectAcbankNumberHandler(event) {
        debugger;
        // let numericRegex = /^[0-9]*$/; // Regex for numeric values only
        let inputValue = event.target.value;
        // let isValidInput = numericRegex.test(inputValue);
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        if (inputValue.length<1 || inputValue=="" || inputValue ==null || inputValue=='0' ||inputValue<1) {
            // event.target.setCustomValidity('Please enter valid account number'); // Set custom error message
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = true;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountType = true;
            return;
        }
        if (
            this.checkCompoLevelDuplicaton(
                inputValue,
                this.payeeAcdetailsList,
                eventName
            )
        ) {
            if(this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber==inputValue){

            }else{
                this.payeeAcdetailsList[parseInt(currentIndex)].Bank_Account_Type__c='';
            }
            this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber = inputValue;
            this.payeeAcdetailsList[parseInt(currentIndex)].isPayeeNameChanged = true;
            this.currentTobeUpdateBankdetailsId = event.target.dataset.id;
            if(this.payeeAcdetailsList[parseInt(currentIndex)].id){
                this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = false;
            }
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountType= false;
            
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber = 0;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = true;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountType = true;
        }
    }

    selectAcbranchNameHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        this.payeeAcdetailsList[parseInt(currentIndex)].branchName = inputValue;
    }

    selectAcverificationTypeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        if(inputValue =="" || inputValue==null || inputValue ==undefined){
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton =true;
            
        }else{
            this.payeeAcdetailsList[parseInt(currentIndex)].verificationType = inputValue;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledPennyDropButton =false;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton =false;
            if(this.payeeAcdetailsList[parseInt(currentIndex)].isAllRequiredFiledClosed){
                this.payeeAcdetailsList[parseInt(currentIndex)].isShowUpdateGreenButton=false;
                this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton =true;

            }else{
                // this.payeeAcdetailsList[parseInt(currentIndex)].isShowUpdateGreenButton=true;
                // this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton =true;
            }

            
        }

        // if(this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountNumber){
        //     // this.ifBackAccountNumberisNull(currentIndex);
        // }else{
        //     // this.ifBackAccountNumberisNOTNull(currentIndex);
        // }
        
        
    }

    selectTypeChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.payeeList[parseInt(currentIndex)].type = inputValue;
    }

    disbursedAmountChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        if (!this.checkToBeDisbursedAmount()) {
            return; // Stop further processing if validation fails
        } else {
            this.payeeList[parseInt(currentIndex)].disbursed_Amount = inputValue;
        }
    }
    ToBedisbursedAmountChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.payeeList[parseInt(currentIndex)].toBeDisbursedAmount = inputValue;
        if (!this.checkToBeDisbursedAmount()) {
            return; // Stop further processing if validation fails
        } else {}
    }

    populateBankDetails() {
        debugger;
        if(this.ifscDetails.BANK==''){
            this.showToast('details missing','enter bank name','error');
            return ;
        }else if(this.ifscDetails.BRANCH==''){
            this.showToast('details missing','enter branch name','error');
            return;
        }
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].branchName =this.ifscDetails.BRANCH;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].bankName = this.ifscDetails.BANK;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isDisabledAccountVerifyType=false;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isShowUpdateGreenButton=true;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isDisabledEditButton=false;
        this.isShowIfsc = false;
        
    }

    selectPayeeChangeHandler(event) {
        debugger;
    }

    checkToBeDisbursedAmount(currentIndex) {
        debugger;

        for (let i = 0; i < this.payeeList.length; i++) {
            if (this.payeeList[i].index==currentIndex) {
                if (
                    this.payeeList[i].type.includes(Financial_Entity_Disburse_Amount_Validation) &&
                    (this.payeeList[i].toBeDisbursedAmount == null ||this.payeeList[i].toBeDisbursedAmount == undefined ||this.payeeList[i].toBeDisbursedAmount == "" || parseInt(this.payeeList[i].toBeDisbursedAmount) == 0)
                ) {
                    this.showToast("Please enter a to be disbursed amount.","Can not be null for financial institute","error"
                    );
                    return false; // Return false if validation fails
                } else if (this.payeeList[i].type == undefined ||this.payeeList[i].type == ""){
                    this.showToast("Please select Entity type","details missing","error");
                    return false;

                } else if(this.payeeList[i].name == undefined || this.payeeList[i].name == "") {
                    this.showToast("Please enter name","details missing","error");
                    return false

                } else if( this.payeeList[i].email == undefined || this.payeeList[i].email == "")   {
                    this.showToast("Please enter email","details missing","error");
                    return false

                } else if(this.payeeList[i].phone == undefined || this.payeeList[i].phone == ""){
                    this.showToast("Please enter phone","details missing","error");
                    return false;

                }   

            }
        }
        return true; // Return true if all validations pass
    }
    approrovedSelectedBankDetails(event) {
        debugger;
        this.loaded = true;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        let currentBankRcordid = event.target.dataset.id;
        this.VennyDropVerify(
            "Penny Drop - API Call Out",
            currentBankRcordid,
            this.taskId
        );
        setTimeout(() => {
            this.loaded = false;    
            this.refreshData();
            this.hardRefresh();
        }, "5000");
    }


    findDuplicateBankNumbers(payeeAcdetailsList) {
        debugger;
        const uniqueBankNumbers = new Set();
        const duplicates = [];
        payeeAcdetailsList.forEach((payee) => {
            if (payee.bankNumber !== undefined && uniqueBankNumbers.has(payee.bankNumber)) {
                duplicates.push(payee.bankNumber);
            } else {
                uniqueBankNumbers.add(payee.bankNumber);
            }
        });
    
        if (duplicates.length > 0) {
            const duplicateValues = duplicates.join(", ");
            this.showToast(
                "Duplicate Bank Numbers Found",
                `Duplicate bank numbers found: ${duplicateValues}`,
                "error"
            );
            return false;
        }
        return true;
    }
    

    findDuplicatePayeeName(payeeAcdetailsList) {
        debugger;
        const uniqueBankNumbers = new Set();
        const duplicates = [];
        payeeAcdetailsList.forEach((payee) => {
            if (uniqueBankNumbers.has(payee.name)) {
                duplicates.push(payee.name);
            } else {
                uniqueBankNumbers.add(payee.name);
            }
        });

        if (duplicates.length > 0) {
            const duplicateValues = duplicates.join(", ");
            this.showToast(
                "duplicate Payee Name Found",
                `duplicate Payee Name Found: ${duplicateValues}`,
                "error"
            );
            return false;
        }
        return true;
    }    

    findDuplicates(payeeList) {
        debugger;
        const duplicates = [];
        const uniqueValues = new Set();

        payeeList.forEach((payee) => {
            if (uniqueValues.has(payee.email) || uniqueValues.has(payee.phone)) {
                duplicates.push(payee);
            } else {
                uniqueValues.add(payee.email);
                uniqueValues.add(payee.phone);
            }
        });

        return duplicates.length === 0;
    }


    submitforBackDetailsSelectedRow(currentIndex){
        debugger
        if(this.findDuplicateBankNumbers(this.payeeAcdetailsList)){
            if(!this.BankAccountNumberValidation(currentIndex)){
                this.upperMethodforBankDetails(this.prepareDataforPayeeBankDetailsRecordsFORdatabase(this.payeeAcdetailsList,currentIndex))
            }else {
                // this.showToast("Please enter all details", "details missing", "error");
                return false;
        }
    }
    }

   
    // this method will be used to transaction for all record
    // NOT IN USE  
    submitForBankDetails(event) {
        debugger;
        if (this.findDuplicateBankNumbers(this.payeeAcdetailsList)) {
            if (!this.nullValueValidationForBankDetails(this.payeeAcdetailsList)) {
                this.upperMethodforBankDetails(
                    this.prepareDataforPayeeBankDetailsRecordsFORdatabase(
                        this.payeeAcdetailsList
                    )
                );
            } else {
                this.showToast("Please enter all details", "details missing", "error");
                return false;
                // alert('else zone bro please check your code something you messed in it 🦸🦸')
            }
        } else {}
    }

    // NOT IN USE
    nullValueValidationForBankDetails(payeeAcdetailsList,currentIndex) {
    debugger;
        for (const obj of payeeAcdetailsList) {
            for (const key in obj) {
                if (obj.id == undefined) {
                    for (const key in obj) {
                    if (key != "bankNumber") {
                        if (obj.hasOwnProperty(key) && (obj[key] === null || obj[key] === undefined || obj[key] === "")) {
                            return true; // If any key has no value, return true
                        }
                    }

                    }
                }
                if (obj.isShowPhycalyVerifyButton) {
                    if (obj.isDocumentUploaded) {

                    } else {
                    this.handleHighlightRow(obj.index);
                    this.showToast("Error", "Please upload Documents", "error");

                    }
                }

            }
        }
    return false; // If all properties have values, return false
    }

    
    // NOT IN USE
    submitForPayeeDetails(event) {
        debugger;
        if (!this.checkToBeDisbursedAmount()) {
            return; // Stop further processing if validation fails
        }
        this.InsertMethodforPayeeDetails(
            this.prepareDataforPayeeRecordsFORdatabase(this.payeeList)
        );
    }

    upperMethodforBankDetails(listToBeUpsert) {
        if (listToBeUpsert && listToBeUpsert.length > 0) {
            debugger;
            upsertSObject({
                    listTobeUppsert: listToBeUpsert
                })
                .then((response) => {
                    if (response == "Success") {
                        this.hardRefresh();
                        this.refreshData();
                        this.disabledAddRow = false;
                        this.isShowConfirmationComp = false;
                        this.showToast("Success", "Records updated successfully", "success");
                    } else if (response != "Success") {
                        this.showToast(
                            "Got some security issues",
                            response,
                            "error"
                        );
                    }

                })
                .catch((error) => {
                    this.showToast(
                        "Something went wrong",
                        "Error. Please try again later",
                        "error"
                    );
                });
        } else {
            this.showToast(
                "No records to update",
                "The list of records to be updated is empty",
                "warning"
            );
        }
    }

    prepareDataforPayeeRecordsFORdatabase(payeeList) {
        debugger;
        let AccountCOntactPayeewrapperList = [];
        for (let i = 0; i < payeeList.length; i++) {
            let payee = payeeList[i];
            if (!payee.id) {
                let Financial_Entity__c = {
                    Name: payee.name,
                    Entity_Type__c: payee.type,
                    Task_ID__c: payee.Task_ID__c,
                    Financial_Account__c: this.financialAccoundId,
                    Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                    Account_Name__c:payee.Account_Name__c,
                };
                let AccountCOntactPayeewrapper = {
                    relatedFinancialEntity: Financial_Entity__c,
                    name: payee.name,
                    payeeEmail: payee.email,
                    payeePhone: payee.phone,
                    index: payee.index
                };
                AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
            }else {
                let Financial_Entity__c = {
                    Id:payee.id,
                    Name: payee.name,
                    Entity_Type__c: payee.type,
                    Task_ID__c: payee.Task_ID__c,
                    Financial_Account__c: this.financialAccoundId,
                    Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                    Account_Name__c:payee.Account_Name__c,
                };
                let AccountCOntactPayeewrapper = {
                    relatedFinancialEntity: Financial_Entity__c,
                    name: payee.name,
                    payeeEmail: payee.email,
                    payeePhone: payee.phone,
                    index: payee.index
                };
                AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
            }
        }
        return AccountCOntactPayeewrapperList;
    }

    prepareDataforPayeeRecordsFORdatabaseForCurrentIndex(payeeList,currentIndex){
        debugger;
        let AccountCOntactPayeewrapperList = [];
        for (let i = 0; i < payeeList.length; i++) {
            let payee = payeeList[i];
            if(payee.index==currentIndex){
            if (!payee.id) {
                let Financial_Entity__c = {
                    Name: payee.name,
                    Entity_Type__c: payee.type,
                    Task_ID__c: payee.Task_ID__c,
                    Financial_Account__c: this.financialAccoundId,
                    Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                    Account_Name__c:payee.Account_Name__c,
                };
                let AccountCOntactPayeewrapper = {
                    relatedFinancialEntity: Financial_Entity__c,
                    name: payee.name,
                    payeeEmail: payee.email,
                    payeePhone: payee.phone,
                    index: payee.index
                };
                AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
            }else {
                let Financial_Entity__c = {
                    Id:payee.id,
                    Name: payee.name,
                    Entity_Type__c: payee.type,
                    Task_ID__c: payee.Task_ID__c,
                    Financial_Account__c: this.financialAccoundId,
                    Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                    Account_Name__c:payee.Account_Name__c,
                };
                let AccountCOntactPayeewrapper = {
                    relatedFinancialEntity: Financial_Entity__c,
                    name: payee.name,
                    payeeEmail: payee.email,
                    payeePhone: payee.phone,
                    index: payee.index
                };
                AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
            }
        }
       }
        return AccountCOntactPayeewrapperList;
    }

    prepareDataforPayeeBankDetailsRecordsFORdatabase(payeeAcdetailsList,currentIndex) {
        debugger;
        let newpayeeAcdetailsList = [];
        for (let i = 0; i < payeeAcdetailsList.length; i++) {
            if(payeeAcdetailsList[i].index==currentIndex){
            if (payeeAcdetailsList[i].id==undefined) {
                let Financial_Entity_AC_Detail__c = {};
                Financial_Entity_AC_Detail__c.Financial_Entity__c =
                    payeeAcdetailsList[i].selectedPayeeId;
                    Financial_Entity_AC_Detail__c.Name =
                    payeeAcdetailsList[i].Name;
                Financial_Entity_AC_Detail__c.Bank_Account_Number__c =
                    payeeAcdetailsList[i].bankNumber;
                Financial_Entity_AC_Detail__c.Banking_Account_Name__c =
                    payeeAcdetailsList[i].bankAccountName;
                Financial_Entity_AC_Detail__c.Branch_Name__c =
                    payeeAcdetailsList[i].branchName;
                Financial_Entity_AC_Detail__c.IFSC_Code__c = payeeAcdetailsList[i].IFSC;
                // Financial_Entity_AC_Detail__c.Id = payeeAcdetailsList[i].Id;
                Financial_Entity_AC_Detail__c.Task_ID__c =
                    payeeAcdetailsList[i].Task_ID__c;
                Financial_Entity_AC_Detail__c.Financial_Account__c =
                    this.financialAccoundId;
                Financial_Entity_AC_Detail__c.Digitally_Verification_Method__c =
                    payeeAcdetailsList[i].verificationType;
                Financial_Entity_AC_Detail__c.Bank_Name__c =
                    payeeAcdetailsList[i].bankName;
                Financial_Entity_AC_Detail__c.Verification_Status__c = "New";
                 Financial_Entity_AC_Detail__c.Bank_Account_Type__c =payeeAcdetailsList[i].Bank_Account_Type__c;
                 Financial_Entity_AC_Detail__c.isChanged__c=payeeAcdetailsList[i].isChanged__c==true ? false:true;
                newpayeeAcdetailsList.push(Financial_Entity_AC_Detail__c);
            }
            
            if (payeeAcdetailsList[i].id == this.currentTobeUpdateBankdetailsId && payeeAcdetailsList[i].isPayeeNameChanged == true && this.currentTobeUpdateBankdetailsId !=undefined) {
                let Financial_Entity_AC_Detail__c = {};
                Financial_Entity_AC_Detail__c.Verification_Status__c = payeeAcdetailsList[i].Verification_Status__c;
                Financial_Entity_AC_Detail__c.Physically_verified__c = payeeAcdetailsList[i].Physically_verified__c;
                Financial_Entity_AC_Detail__c.Id = payeeAcdetailsList[i].id;
                Financial_Entity_AC_Detail__c.Banking_Account_Name__c =
                    payeeAcdetailsList[i].bankAccountName;
                    Financial_Entity_AC_Detail__c.Name =
                    payeeAcdetailsList[i].Name;
                Financial_Entity_AC_Detail__c.Financial_Entity__c =
                    payeeAcdetailsList[i].selectedPayeeId;
                Financial_Entity_AC_Detail__c.Bank_Account_Number__c =
                    payeeAcdetailsList[i].bankNumber;
                Financial_Entity_AC_Detail__c.Branch_Name__c =
                    payeeAcdetailsList[i].branchName;
                Financial_Entity_AC_Detail__c.IFSC_Code__c = payeeAcdetailsList[i].IFSC;
                // Financial_Entity_AC_Detail__c.Id = payeeAcdetailsList[i].Id;
                Financial_Entity_AC_Detail__c.Task_ID__c =
                    payeeAcdetailsList[i].Task_ID__c;
                Financial_Entity_AC_Detail__c.Financial_Account__c =
                    this.financialAccoundId;
                Financial_Entity_AC_Detail__c.Digitally_Verification_Method__c =
                    payeeAcdetailsList[i].verificationType;
                Financial_Entity_AC_Detail__c.Bank_Name__c =
                    payeeAcdetailsList[i].bankName;
                     Financial_Entity_AC_Detail__c.Bank_Account_Type__c =payeeAcdetailsList[i].Bank_Account_Type__c;
                     Financial_Entity_AC_Detail__c.isChanged__c=payeeAcdetailsList[i].isChanged__c==true ? false:true;
                newpayeeAcdetailsList.push(Financial_Entity_AC_Detail__c);
            }
        }
        }
        return newpayeeAcdetailsList;
    }

    InsertMethodforPayeeDetails(listTobeUpsert) {
        debugger;
        if (listTobeUpsert.length > 0) {
            createAccountContactDetailsOnBehalofPayeeNumber({
                    wrapperData: listTobeUpsert
                })
                .then((response) => {
                    this.showToast("Success", "Records updated successfully", "success");
                    this.refreshData();
                    this.hardRefresh();
                    this.AddNewPayeeRowDisable = false;
                })
                .catch((error) => {
                    this.showToast(
                        "Error",
                        "Something went wrong. Please try again later.",
                        "error"
                    );
                });
        } else {
            this.showToast("Info", "No new records to update.", "info");
        }
    }

    @track isIFSCAPIError;
    verifyIFSCCode(ifscCode, index) {
        debugger;
        this.lastIFSCveirfiedIndex = index;
        getIFSCDetails({
                ifscCode: ifscCode
            })
            .then((response) => {
                this.ifscDetails = response;
                this.isShowIfsc = true;
                if(this.ifscDetails.STATE=='Not found'){
                    this.showToast("ifsc details not found", "Please Enter details", "alert");
                    this.isIFSCAPIError=true;

                }else{
                    this.showToast("Success", "please check details", "success");
                    this.isIFSCAPIError=false;
                }
                
            })
            .catch((error) => {
                this.showToast("Error", "ifsc details not found", "error");
            });
    }

    // THIS METHOD WILL DELETE IN ANY SOBJECTS RECORD BY ITS ID list<ids>
    dynamicallyRecordsDeletion(recordsIds) {
        debugger;
        dynamicRecordDeletion({
                recordIds: recordsIds
            })
            .then((response) => {
                this.showToast("Success", "records deleted", "success");
                this.refreshData();
                this.hardRefresh();
            })
            .catch((error) => {
                this.showToast("Error", " getting error deletion", "error");
            });
    }

    closeModalIFSC(event) {
        debugger;
        this.isShowIfsc = false;
       

    }

    updateBankDetailsManually(event){
        debugger;
        this.isShowIfsc = false;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isDisabledBrachName =false;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isDisabledBankName =false;

    }

   



    handleHighlightRow(rowIndex) {
        debugger;
        this.payeeAcdetailsList[parseInt(rowIndex)].isRedRow = 'red-row';

    }

    physicallyVerifyBabkDetails(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.currentTobeUpdateBankdetailsindex = currentIndex;
        let currentBankRcordid = event.target.dataset.id;
        this.showToast("opening documents handler", "Please upload documents ", "success");
        this.isShowMODTCOMP = true;
        this.currentBankDetailsRecordId = currentBankRcordid;
    }


    physicallyViewBabkDetails(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.currentTobeUpdateBankdetailsindex = currentIndex;
        let currentBankRcordid = event.target.dataset.id;
        this.isShowMODTCOMP = true;
        this.currentBankDetailsRecordId = currentBankRcordid;
        this.isTaskOwnerLogin = false;
    }

    handleUpdateACDetailsRow(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        let currentBankRcordid = event.target.dataset.id;
        this.currentTobeUpdateBankdetailsId = currentBankRcordid;
        this.blockAllOthersRowsforBackDetails(currentIndex);
        this.payeeAcdetailsList[parseInt(currentIndex)].isShowUpdateGreenButton = true;
    }

    isShowUpdateGreenButtonGreen(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        let currentBankRcordid = event.target.dataset.id;
        this.currentTobeUpdateBankdetailsId = currentBankRcordid;
        this.currentTobeUpdateBankdetailsindex = currentIndex;
        this.currentTobeUpdateBankdetailsValue = inputValue;
        // this.payeeAcdetailsList[parseInt(currentIndex)].isShowUpdateGreenButton = false;
        this.payeeAcdetailsList[parseInt(currentIndex)].isPayeeNameChanged = true;
        this.submitforBackDetailsSelectedRow(currentIndex);
        // this.unblockAllOthersRowsforBackDetails(currentIndex);
       

    }


    blockAllOthersRowsforBackDetails(currentIndex) {
        debugger;
        for (let i = 0; i < this.payeeAcdetailsList.length; i++) {
            if (i === parseInt(currentIndex)) {
                this.payeeAcdetailsList[i].isDisabledPayeeName= false;
                this.payeeAcdetailsList[i].isDisabledBankAccountHolderName=false;
                this.payeeAcdetailsList[i].isShowUpdateGreenButton=false;
                this.payeeAcdetailsList[i].isDisabledBankAccountNumber=false;
                this.payeeAcdetailsList[i].isDisabledIFSCcode= false;
                this.payeeAcdetailsList[i].isDisabledAccountVerifyType= false;
                this.payeeAcdetailsList[i].isDisabledPayeeNameEdit= false;
                
                
            } else {
                this.payeeAcdetailsList[i].isDisabledBankName= true;
                this.payeeAcdetailsList[i].isDisabledBrachName= true;
                this.payeeAcdetailsList[i].isDisabledIFSCcode= true;
                this.payeeAcdetailsList[i].isDisabledAccountType= true;
                this.payeeAcdetailsList[i].isDisabledAccountVerifyType= true;
                this.payeeAcdetailsList[i].isDisabledPayeeName= true;
                this.payeeAcdetailsList[i].isDisabledBankAccountHolderName= true;
                this.payeeAcdetailsList[i]. isDisabledBankAccountNumber=true;
                this.payeeAcdetailsList[i]. isShowUpdateGreenButton=false;
                this.payeeAcdetailsList[i]. isDisabledEditButton=true;
               
            }
        }
    }

    unblockAllOthersRowsforBackDetails(currentIndex){
        for (let i = 0; i < this.payeeAcdetailsList.length; i++) {
            if (i === parseInt(currentIndex)) {
                this.payeeAcdetailsList[i].isDisabledPayeeName= true;
                this.payeeAcdetailsList[i].isDisabledBankAccountHolderName=true;
                
            } else {
                
            }
        }
    }

    blockAllOthersRowsforPayeeDetails(currentIndex) {
        debugger;
        for (let i = 0; i < this.this.payeeList.length; i++) {
            if (i === parseInt(currentIndex)) {
                if (this.this.payeeList[i].isEditableDisabled) {
                    this.this.payeeList[i].isEditableDisabled = false;
                    this.this.payeeList[i].isShowUpdateGreenButton = false;
                } else if (this.this.payeeList[i].isShowUpdateGreenButton) {
                    this.this.payeeList[i].isEditableDisabled = true;
                } else {
                    this.this.payeeList[i].isEditableDisabled = true;
                }
            } else {
                this.this.payeeList[i].isEditableDisabled = true;
                this.this.payeeList[i].isShowUpdateGreenButton = false;
            }
        }
    }

    // subject ,sobjectrecordId,parentTaskId
    VennyDropVerify(subject, sObjectRecordId, parentTaskId) {
        debugger;
        createTask({
                subject: subject,
                backDetailsRecordId: sObjectRecordId,
                parentTaskId: parentTaskId
            })
            .then((response) => {
                console.log("VennyDropVerify response --->" + response);
                this.refreshData();
                this.showToast("Success", "verification request sent", "success");
                // this.hardRefresh();
            })
            .catch((error) => {
                this.showToast("Error", " verification failed", "error");
            });
    }

    backTomodt(event) {
        debugger;
        this.isShowMODTCOMP = false;
    }

    handleConfirmationResponse(event) {
        debugger;
        this.isResponsePositive = event.detail.message;
        if (!event.detail.message) {
            this.isShowConfirmationComp = false
            this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].selectedPayeeId = '';
        } else {
            this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].isPayeeNameChanged = true;
            this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].selectedPayeeId = this.currentTobeUpdateBankdetailsValue;
            if(this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].Task_ID__c==this.taskId){
                if(this.currentTobeUpdateBankdetailsId){
                    this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].isDisabledEditButton=false;
                    this.isShowConfirmationComp=false;
                    // this.submitforBackDetailsSelectedRow(this.currentTobeUpdateBankdetailsindex);
                }
            }else{
                if(this.currentTobeUpdateBankdetailsId){
                    this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].isDisabledEditButton=false;
                    this.isShowConfirmationComp=false;
                    this.submitforBackDetailsSelectedRow(this.currentTobeUpdateBankdetailsindex);
                }
            }
            
            
        }
    }

    //DOCUMENT HANDLER EVENT 
    callDocumentHandlerFinalSubmit() {
        debugger;
        let child = this.template.querySelector('c-lwc_-handledocuments');
        child.HandleSavefromAura();
        //this.isShowMODTCOMP = true;
    }

    closeMODT(event) {
        debugger;
        let index = event.detail.index;
        let recordId = event.detail.extendedsobjId;
        let isDocumentClosed = event.detail.child_isclosed;
        if (isDocumentClosed) {
            this.payeeAcdetailsList[parseInt(index)].isDocumentUploaded = true;
            this.payeeAcdetailsList[parseInt(index)].Verification_Status__c = 'Verified';
            this.currentTobeUpdateBankdetailsId = recordId;
            this.payeeAcdetailsList[parseInt(index)].isPayeeNameChanged = true;
            this.payeeAcdetailsList[parseInt(index)].Physically_verified__c = true;
            this.submitforBackDetailsSelectedRow(index);

        } else {
            this.handleHighlightRow(index);
            this.payeeAcdetailsList[parseInt(index)].isDocumentUploaded = false;
        }
    }

    enabledEditingPayee(currentIndex){
        debugger;
        for (let i = 0; i < this.payeeList.length; i++) {
            if (i == parseInt(currentIndex)) {
                this.payeeList[i].isEditableDisabled = false;
                this.payeeList[i].isShowEditableButton = false;
            } else {
                this.payeeList[i].isEditableDisabled = true;
                this.payeeList[i].isShowEditableButton = true;
                
            }
        }
        
    }

    upatePayeeByRowUpdateButton(event){
        debugger
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        if (!this.checkToBeDisbursedAmount(currentIndex)){
        }else{
            if(this.findDuplicatePayeeName(this.payeeList)){
                this.InsertMethodforPayeeDetails(
                    this.prepareDataforPayeeRecordsFORdatabaseForCurrentIndex(this.payeeList,currentIndex))
                    this.disanabledEditingPayee(currentIndex);
            }else{
                return;
            }
            
        }

    }

    disanabledEditingPayee(currentIndex){
        debugger
        for (let i = 0; i < this.payeeList.length; i++) {
            if (i == parseInt(currentIndex)) {
                this.payeeList[i].isEditableDisabled = true;
                this.payeeList[i].isShowEditableButton = true;
            } else {
                this.payeeList[i].isEditableDisabled = true;
                this.payeeList[i].isShowEditableButton = true;
                
            }
        }
    }

    checkNullValidationForPayeeRows(currentIndex){
        debugger;
        for(let i = 0; i < this.payeeList.length; i++){
            if(this.payeeList[i].index==currentIndex){
                
            }
        }
    }

    BankAccountNumberValidation(index) {
        debugger;
        for (let i = 0; i < this.payeeAcdetailsList.length; i++) {
            if (this.payeeAcdetailsList[i].index == index) {
                if (this.payeeAcdetailsList[i].bankNumber == undefined || this.payeeAcdetailsList[i].bankNumber == '' || this.payeeAcdetailsList[i].bankNumber <= 0) {
                    return this.BankDetailsRuleIfBankAccountNumberisNull(this.payeeAcdetailsList, index);
                } else {
                    return this.BankDetailsRuleIfBankAccountNumberisNotNull(this.payeeAcdetailsList, index);
                }
            }
        }
    }
    
    BankDetailsRuleIfBankAccountNumberisNull(payeeAcdetailsList, currentIndex) {
        debugger;
        const tempPayee = payeeAcdetailsList.find(payee => payee.index == currentIndex);
        if (!tempPayee) {
            return false; // currentIndex not found in the payeeAcdetailsList
        }
    
        const validationRules = [
            { prop: 'selectedPayeeId', message: 'Please select Payee' },
            // { prop: 'bankAccountName', message: 'Please enter bank account holder name' },
            // { prop: 'bankNumber', message: 'Please enter account number' },
            // { prop: 'IFSC', message: 'Please enter IFSC CODE' },
            // { prop: 'branchName', message: 'Please enter branch' },
            // { prop: 'bankName', message: 'Please enter bank Name' },
            // { prop: 'Verification_Status__c', message: 'Verification Status not defined' },
            // { prop: 'Task_ID__c', message: 'Task id not defined' },
    
        ];
    
        for (const rule of validationRules) {
            if (!tempPayee[rule.prop] || tempPayee[rule.prop] === '') {
                this.showToast(rule.message, 'Details missing', 'error');
                return true;
            }
        }
    
        return false; // All validations passed
    }
    
    BankDetailsRuleIfBankAccountNumberisNotNull(payeeAcdetailsList, currentIndex) {
        debugger;
        const tempPayee = payeeAcdetailsList.find(payee => payee.index == currentIndex);
        if (!tempPayee) {
            return false; // currentIndex not found in the payeeAcdetailsList
        }
    
        const validationRules = [
            { prop: 'selectedPayeeId', message: 'Please select Payee' },
            { prop: 'bankAccountName', message: 'Please enter bank account holder name' },
            { prop: 'bankNumber', message: 'Please enter account number' },
            { prop: 'IFSC', message: 'Please enter IFSC CODE' },
            { prop: 'branchName', message: 'Please enter branch' },
            { prop: 'bankName', message: 'Please enter bank Name' },
            { prop: 'Verification_Status__c', message: 'Verification Status not defined' },
            // { prop: 'Task_ID__c', message: 'Task id not defined' },
    
        ];
    
        for (const rule of validationRules) {
            if (!tempPayee[rule.prop] || tempPayee[rule.prop] === '') {
                this.showToast(rule.message, 'Details missing', 'error');
                return true;
            }
        }
    
        return false; // All validations passed
    }

    ifscOnChange(event){
        debugger;
        let eventName=event.target.name;
        let eventValue=event.target.value;
        if(eventName=='IFSCBANKNAME'){
            this.ifscDetails.BANK=eventValue;
        }else if(eventName=='IFSCBRANCHNAME'){
            this.ifscDetails.BRANCH=eventValue;

        }
    }
    

    //this method will run when bacnkAccountnumber is null
    ifBackAccountNumberisNull(index){
        debugger;
        this.payeeAcdetailsList[parseInt(index)].isDisabledAccountVerifyType = true;
        if(!this.payeeAcdetailsList[parseInt(index)].Physically_verified__c){
            this.payeeAcdetailsList[parseInt(index)].isShowPhysicallVerifiedCheckbox=true;
        }else{
            this.payeeAcdetailsList[parseInt(index)].isShowPhycalyVerifyButton=true;
            this.payeeAcdetailsList[parseInt(index)].Verification_Status__c="Verified";
            this.payeeAcdetailsList[parseInt(index)].isShowPhycalyVerifyButton=true;
            
        }
    }
    //this method will run when bacnkAccountnumber is not null
    ifBackAccountNumberisNOTNull(index){
        debugger;
        if(this.payeeAcdetailsList[parseInt(index)].Digitally_Verified__c && !this.payeeAcdetailsList[parseInt(index)].Verification_Status__c.includes('In Progess')){
            this.payeeAcdetailsList[parseInt(index)].isDisabledAccountVerifyType=false;
            this.payeeAcdetailsList[parseInt(index)].isSendableForPennyDropVerification=true;
        }else{
            this.payeeAcdetailsList[parseInt(index)].isDisabledAccountVerifyType=true;
        }
        

    }
    

}