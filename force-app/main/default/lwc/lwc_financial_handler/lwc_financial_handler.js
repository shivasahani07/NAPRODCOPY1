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
import FinancialEntityACDetails_Verification_Status_inprogress from '@salesforce/label/c.FinancialEntityACDetails_Verification_Status_inprogress';
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
    @api taskId;
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
    @track isShowEsistingAccount = false;
    @track defaultSelect = 'Select';
    @track pennyDorpTaskSubject = 'Penny Drop - API Call Out';
    @track MapByBankdetailsMaxnumberexceed = new Map();

    connectedCallback() {
        this.configureObjectType();
    }

    @wire(getRelatedContactAccount, {
        financialAccountId: '$financialAccoundId',
        subject: '$pennyDorpTaskSubject',
        parentTaskId: '$taskId'
    })
    wiredData(result) {
        this.wrapperresult = result;
        debugger;
        if (result.data) {
            for (const [key, value] of Object.entries(result.data.MapByBankdetailsMaxnumberexceed)) {
                this.MapByBankdetailsMaxnumberexceed.set(key, value);
            }
            this.prepareData(result.data);

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

        this.accountTypePicklist = data.accountTypePicklist.map(
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
                isEditableDisabled: true,
                isDisabledDeleteButton: true,
                isEditbleButtonOn: entity.Task_ID__c !== this.taskId,
                Account_Name__c: account.Id,
                isShowEditableButton: true,
                isShowEditableButtonDisabled: entity.Task_ID__c !== this.taskId

            };
        });
        this.AddNewPayeeRowDisable = false;
        return newExixtingPayee;
    }

    tempRefresh() {
        debugger
        this.payeeAcdetailsList[parseInt(0)].isPayeeNameChanged = true;
        this.currentTobeUpdateBankdetailsId = this.payeeAcdetailsList[parseInt(0)].id;
        this.upperMethodforBankDetails(this.refreshApex());

    }

    refreshApex() {
        debugger;
        if (this.payeeAcdetailsList.length > 0) {
            let newpayeeAcdetailsList = [];
            let Financial_Entity_AC_Detail__c = {};
            Financial_Entity_AC_Detail__c.Id = this.payeeAcdetailsList[parseInt(0)].id;
            Financial_Entity_AC_Detail__c.isChanged__c = this.payeeAcdetailsList[parseInt(0)].isChanged__c == true ? false : true;
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
    reformBankDetails(detail, i) {
        debugger;
        const financialentity = detail.Financial_Entity__r || {};
        let tempBankDetailsOnject = {};
        tempBankDetailsOnject.id = detail.Id;
        tempBankDetailsOnject.index = i;
        tempBankDetailsOnject.selectedPayeeId = financialentity.Id;
        tempBankDetailsOnject.Task_ID__c = detail.Task_ID__c;
        tempBankDetailsOnject.isNotSameTask = detail.Task_ID__c != this.taskId;
        //    tempBankDetailsOnject.isSameTaskID= detail.Task_ID__c === this.taskId;
        tempBankDetailsOnject.isMaxTaskCreated = this.getValueByKey(tempBankDetailsOnject.id);
        tempBankDetailsOnject.isSameTaskID = detail.Task_ID__c === this.taskId && detail.Task_ID__c != null && detail.Task_ID__c != undefined;
        tempBankDetailsOnject.isEditableDisabled = detail.Digitally_Verified__c;
        tempBankDetailsOnject.newPayeeIdPicList = this.relatedFinancialMap;
        tempBankDetailsOnject.isDisabledPayeeNameEdit = (financialentity.Id !== undefined || tempBankDetailsOnject.isEditableDisabled);
        tempBankDetailsOnject.bankAccountName = detail.Verification_Status__c == 'Verified' ? detail.Name : detail.Banking_Account_Name__c;
        tempBankDetailsOnject.Banking_Account_Name__c = detail.Banking_Account_Name__c;
        tempBankDetailsOnject.isDisabledBankAccountHolderName = (tempBankDetailsOnject.isSameTaskID || tempBankDetailsOnject.isNotSameTask) || (!tempBankDetailsOnject.isDisabledPayeeNameEdit);
        tempBankDetailsOnject.bankNumber = detail.Bank_Account_Number__c;
        tempBankDetailsOnject.isDisabledBankAccountNumber = (tempBankDetailsOnject.isSameTaskID && detail.Bank_Account_Number__c) || (tempBankDetailsOnject.isNotSameTask) || (!tempBankDetailsOnject.isDisabledPayeeNameEdit);

        tempBankDetailsOnject.Bank_AccountTypePicklist = this.accountTypePicklist;
        tempBankDetailsOnject.Bank_Account_Type__c = detail.Bank_Account_Type__c;
        tempBankDetailsOnject.isDisabledAccountType = (tempBankDetailsOnject.isSameTaskID || tempBankDetailsOnject.isNotSameTask) || (!tempBankDetailsOnject.isDisabledPayeeNameEdit);
        tempBankDetailsOnject.IFSC = detail.IFSC_Code__c;
        tempBankDetailsOnject.isDisabledIFSCcode = (tempBankDetailsOnject.isSameTaskID || tempBankDetailsOnject.isNotSameTask) || (!tempBankDetailsOnject.isDisabledPayeeNameEdit);
        tempBankDetailsOnject.bankName = detail.Bank_Name__c;
        tempBankDetailsOnject.isDisabledBankName = true;
        tempBankDetailsOnject.branchName = detail.Branch_Name__c;
        tempBankDetailsOnject.isDisabledBrachName = true;
        tempBankDetailsOnject.Verification_Status__c = detail.Verification_Status__c;
        tempBankDetailsOnject.isDisabledAccountVerifyType = (tempBankDetailsOnject.isSameTaskID && detail.Digitally_Verified__c) || (!tempBankDetailsOnject.isDisabledPayeeNameEdit) || !tempBankDetailsOnject.isDisabledBankAccountNumber || (!detail.Bank_Account_Number__c || detail.Bank_Account_Number__c == 'Not Available');
        tempBankDetailsOnject.verificationTypePicklist = this.payMentverificationTypePicklist;
        // tempBankDetailsOnject.verificationType= ((tempBankDetailsOnject.isDisabledAccountVerifyType ==false ) || (!FinancialEntityACDetails_Verification_Status_inprogress.includes(tempBankDetailsOnject.Verification_Status__c)) ? detail.Digitally_Verification_Method__c:'');
        tempBankDetailsOnject.verificationType = ((tempBankDetailsOnject.isDisabledAccountVerifyType == true) || (FinancialEntityACDetails_Verification_Status_inprogress.includes(tempBankDetailsOnject.Verification_Status__c)) ? detail.Digitally_Verification_Method__c : '');

        tempBankDetailsOnject.Digitally_Verified__c = detail.Digitally_Verified__c || tempBankDetailsOnject.isNotSameTask;
        tempBankDetailsOnject.Physically_verified__c = detail.Physically_verified__c;
        tempBankDetailsOnject.VerifyPhysicallyCheckbox = detail.Physically_verified__c;
        tempBankDetailsOnject.isDisabledVerifyPhysicallyCheckbox = (tempBankDetailsOnject.isSameTaskID) || (!tempBankDetailsOnject.isDisabledPayeeNameEdit);
        tempBankDetailsOnject.isShowUpdateGreenButton = false;
        //    tempBankDetailsOnject.isDisabledEditButton=true;
        tempBankDetailsOnject.isDisabledEditButton = (!tempBankDetailsOnject.isSameTaskID || tempBankDetailsOnject.isNotSameTask) || (detail.Digitally_Verified__c || detail.Physically_verified__c) || (!tempBankDetailsOnject.isDisabledPayeeNameEdit);
        // tempBankDetailsOnject.isDisabledEditButton=(tempBankDetailsOnject.isSameTaskID ) && (detail.Digitally_Verified__c && detail.Physically_verified__c) || (!tempBankDetailsOnject.Verification_Status__c.includes(tempBankDetailsOnject.Verification_Status__c));
        tempBankDetailsOnject.isDisabledDeleteButton = true;
        tempBankDetailsOnject.isSendableForPennyDropVerification = !tempBankDetailsOnject.isDisabledAccountVerifyType || !tempBankDetailsOnject.isEditableDisabled || tempBankDetailsOnject.isNotSameTask;
        //    tempBankDetailsOnject.isSendableForPennyDropVerification= !tempBankDetailsOnject.isDisabledAccountVerifyType || !tempBankDetailsOnject.isEditableDisabled ||tempBankDetailsOnject.isNotSameTask;

        //    tempBankDetailsOnject.isShowPhycalyVerifyButton= !tempBankDetailsOnject.isSendableForPennyDropVerification && detail.Physically_verified__c;
        tempBankDetailsOnject.isShowPhycalyVerifyButton = detail.Physically_verified__c;
        tempBankDetailsOnject.verificationTypePiclist = this.payMentverificationTypePicklist;
        //    tempBankDetailsOnject.isDisabledPennyDropButton= (tempBankDetailsOnject.isDisabledAccountVerifyType ||tempBankDetailsOnject.isNotSameTask) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit) || !tempBankDetailsOnject.isDisabledBankAccountNumber ||tempBankDetailsOnject.isMaxTaskCreated;
        tempBankDetailsOnject.isDisabledPennyDropButton = true;
        //    tempBankDetailsOnject.isDisabledPennyDropButton= (!tempBankDetailsOnject.isDisabledAccountVerifyType ||tempBankDetailsOnject.isNotSameTask) ||(!tempBankDetailsOnject.isDisabledPayeeNameEdit) || !tempBankDetailsOnject.isDisabledBankAccountNumber;

        tempBankDetailsOnject.isChanged__c = detail.isChanged__c;
        tempBankDetailsOnject.isAllRequiredFiledClosed = (tempBankDetailsOnject.isDisabledPayeeNameEdit && tempBankDetailsOnject.isDisabledBankAccountHolderName && tempBankDetailsOnject.isDisabledBankAccountNumber && tempBankDetailsOnject.isDisabledAccountType && tempBankDetailsOnject.isDisabledIFSCcode && tempBankDetailsOnject.isDisabledBankName && tempBankDetailsOnject.isDisabledBrachName) && (tempBankDetailsOnject.Digitally_Verified__c || tempBankDetailsOnject.Physically_verified__c);
        //tempBankDetailsOnject.isDisabledisPhysicallyVerificationRequired=(!tempBankDetailsOnject.isDisabledPayeeNameEdit);
        tempBankDetailsOnject.isShowCheckBoxs = detail.Physically_verified__c || tempBankDetailsOnject.isMaxTaskCreated || (!detail.Bank_Account_Number__c || detail.Bank_Account_Number__c == 'Not Available');
        tempBankDetailsOnject.isShowPhysicallVerifiedCheckbox = detail.Physically_verified__c || tempBankDetailsOnject.isMaxTaskCreated || (!detail.Bank_Account_Number__c || detail.Bank_Account_Number__c == 'Not Available');
        tempBankDetailsOnject.isDisabledisPhysicallyVerificationRequired = false;
        return tempBankDetailsOnject;
    }

    getValueByKey(key) {
        debugger
        if (this.MapByBankdetailsMaxnumberexceed.has(key)) {
            return this.MapByBankdetailsMaxnumberexceed.get(key);
        }
        return false;
    }

    configureObjectType() {
        debugger;
        if (this.recordType == "newpayee") {
            this.isShowPayeeComp = true;
        } else if (this.recordType == "newacdetails") {
            this.isShowPayeeACdetailComp = true;
        }
    }

    editPayeeButton(event) {
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
        const minPhoneLength = 7;
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
        if (this.checkCompoLevelDuplicaton(inputValue, this.payeeList, 'name')) {
            this.payeeList[parseInt(currentIndex)].name = inputValue;
        } else {
            this.payeeList[parseInt(currentIndex)].name = '';
            return;
        }

    }

    selectEmailChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        if (this.checkCompoLevelDuplicaton(inputValue, this.payeeList, eventName)) {
            if (inputValue.length > 9) {
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
        this.payeeAcdetailsList[parseInt(currentIndex)].verificationType = inputValue;

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
            Account_Name__c: '',
        };
        tempPayeeObjectList = [...this.payeeList, tempPayeeObject];
        this.payeeList = tempPayeeObjectList;
        this.AddNewPayeeRowDisable = true;
    }


    newAddrowBankDetails() {
        debugger;
        let temppayeeAcdetailObjectList = [];
        let index = this.payeeAcdetailsList.length;
        let isEditableDisabled = true;
        let isDisabledPayeeNameEdit = true;
        let temppayeeAcdetailObject = {
            index: index,
            selectedPayeeId: '',
            Task_ID__c: this.taskId,
            isSameTaskID: true,
            isEditableDisabled: false,
            newPayeeIdPicList: this.relatedFinancialMap,
            isDisabledPayeeNameEdit: false,
            bankAccountName: '',
            isDisabledBankAccountHolderName: true,
            bankNumber: '',
            isDisabledBankAccountNumber: true,
            Bank_AccountTypePicklist: this.accountTypePicklist,
            Bank_Account_Type__c: '',
            isDisabledAccountType: true,
            IFSC: '',
            isDisabledIFSCcode: true,
            bankName: '',
            isDisabledBankName: true,
            branchName: '',
            isDisabledBrachName: true,
            verificationTypePiclist: this.payMentverificationTypePicklist,
            verificationType: '',
            isDisabledAccountVerifyType: true,
            Verification_Status__c: 'New',
            Digitally_Verified__c: '',
            Physically_verified__c: '',
            Banking_Account_Name__c: '',
            VerifyPhysicallyCheckbox: false,
            IsDisabledVerifyPhysicallyCheckbox: true,
            isShowUpdateGreenButton: true,
            isDisabledEditButton: true,
            isDisabledDeleteButton: false,
            isSendableForPennyDropVerification: false,
            isShowPhycalyVerifyButton: false,
            isShowCheckBoxs: false,

        };
        temppayeeAcdetailObjectList = [
            ...this.payeeAcdetailsList,
            temppayeeAcdetailObject
        ];
        this.payeeAcdetailsList = temppayeeAcdetailObjectList;
        this.disabledAddRow = true;
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
                    this.showToast("Scuccess", "already exists please check", "success");
                    this.payeeList[parseInt(checkedRecordIndex)].name = response.existingAccount[0].Name;
                    this.payeeList[parseInt(checkedRecordIndex)].phone = response.existingAccount[0].Phone;
                    this.payeeList[parseInt(checkedRecordIndex)].email = response.existingAccount[0].Email_Id__c;
                    // this.payeeList[parseInt(checkedRecordIndex)].Account_Name__c = response.existingAccount[0].Id;
                    this.isShowEsistingAccount = true;

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
        let isclose = event.detail.isclosed
        this.show_data_onHover = isclose;
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
        } else if (eventName == 'Bank_Account_Type__c') {
            this.selectBackAccountTypeChangeHandler(event);
        } else if (eventName == 'bankAccountName') {
            this.selectBackAccountNameChangeHandler(event);
        }
    }


    selectBackAccountNameChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        let isChecked = event.target.checked;
        this.payeeAcdetailsList[parseInt(currentIndex)].bankAccountName = inputValue;
        this.payeeAcdetailsList[parseInt(currentIndex)].Name = inputValue;
        if (inputValue == "" || inputValue == null) {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountNumber = true;
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountNumber = false;
        }


    }
    isShowEsistingAccountClosed(event) {
        this.isShowEsistingAccount = false;
    }

    selectBackAccountTypeChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        let isChecked = event.target.checked;
        this.payeeAcdetailsList[parseInt(currentIndex)].Bank_Account_Type__c = inputValue;
        if (this.payeeAcdetailsList[parseInt(currentIndex)].Bank_Account_Type__c) {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledIFSCcode = false;
            return;
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledIFSCcode = true;
        }
        if (!this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber) {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = true;
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = false;
        }

    }

    showPhysicalVerifyButton(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        let isChecked = event.target.checked;
        let recordId = event.target.dataset.id;

        if (isChecked) {
            if (recordId) {
                this.payeeAcdetailsList[parseInt(currentIndex)].isShowPhycalyVerifyButton = true;
                this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledisPhysicallyVerificationRequired = true;
                this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = true;
            } else {

            }
            this.payeeAcdetailsList[parseInt(currentIndex)].isEditbleButtonOn = true;
            // this.blockAllOthersRowsforBackDetails(currentIndex);
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = false;
            this.payeeAcdetailsList[parseInt(currentIndex)].isShowPhycalyVerifyButton = false;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledisPhysicallyVerificationRequired = false;
            this.payeeAcdetailsList[parseInt(currentIndex)].isEditbleButtonOn = false;
            // this.unblockAllOthersRowsforBackDetails(currentIndex);
        }
        this.unCheckAllotheCheckbox(currentIndex);
    }

    unCheckAllotheCheckbox(index) {
        debugger;
        // Determine if the specific payee at the given index meets the condition
        for (let i = 0; i < this.payeeAcdetailsList.length; i++) {
            let payee = this.payeeAcdetailsList[i];
            if (payee.index == index) {

            } else {
                payee.isDisabledisPhysicallyVerificationRequired = false;
                if (!payee.Physically_verified__c) {
                    payee.isShowPhycalyVerifyButton = false;
                }
            }
        }
    }




    selectAcPayeeNameHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        let cuurectRecordId = event.target.dataset.id;
        if (cuurectRecordId == null || cuurectRecordId == "") {
            if (inputValue == null || inputValue == "" || inputValue == undefined) {
                this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountHolderName = true;
                // this.payeeAcdetailsList[parseInt(currentIndex)].bankAccountName ="";
                // this.selectBackAccountNameChangeHandler(event);
            } else {
                this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountHolderName = false;
            }
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].selectedPayeeId = inputValue;
            this.submitforBackDetailsSelectedRow(currentIndex, true);

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
        if (event.target.dataset.id) {
            // this.isShowConfirmationComp = true;
            this.payeeAcdetailsList[parseInt(currentIndex)].isShowUpdateGreenButton = true;
            this.payeeAcdetailsList[parseInt(currentIndex)].selectedPayeeId = inputValue;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton = false;


        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBankAccountHolderName = false;
            this.payeeAcdetailsList[parseInt(currentIndex)].selectedPayeeId = inputValue;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton = false;
        }

    }

    selectAcbankNameHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        if (inputValue == "") {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBrachName = true;

        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledBrachName = false;
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
            this.resetBankDetailsAsPerIFSCcode(inputValue, currentIndex);
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
         if (inputValue == "") {
                this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber =inputValue;
            }
        JSON.stringify('bank number on change',this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber);
        if (inputValue.length < 1 || inputValue == null || inputValue == '0' || inputValue < 1) {
            // event.target.setCustomValidity('Please enter valid account number'); // Set custom error message
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = true;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountType = true;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledIFSCcode = true;
            return;
        }
        if (
            this.checkCompoLevelDuplicaton(
                inputValue,
                this.payeeAcdetailsList,
                eventName
            )
        ) {
            if (this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber == inputValue) {

            } else {
                this.payeeAcdetailsList[parseInt(currentIndex)].Bank_Account_Type__c = '';
                this.payeeAcdetailsList[parseInt(currentIndex)].IFSC = '';
                this.payeeAcdetailsList[parseInt(currentIndex)].bankName = '';
                this.payeeAcdetailsList[parseInt(currentIndex)].branchName = '';
                this.payeeAcdetailsList[parseInt(currentIndex)].verificationType = '';
            }
            this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber = inputValue;
            this.payeeAcdetailsList[parseInt(currentIndex)].isPayeeNameChanged = true;
            this.currentTobeUpdateBankdetailsId = event.target.dataset.id;
            if (this.payeeAcdetailsList[parseInt(currentIndex)].id) {
                // this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = false;
            }
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountType = false;

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
        let inputValue_IN_lowercase = inputValue.toLocaleLowerCase()
        if (inputValue == "" || inputValue == null || inputValue == undefined || !inputValue_IN_lowercase.includes("penny drop")) {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton = true;
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].verificationType = inputValue;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledPennyDropButton = this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber == 'Not Available';
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton = true;
            if (this.payeeAcdetailsList[parseInt(currentIndex)].isAllRequiredFiledClosed) {
                this.payeeAcdetailsList[parseInt(currentIndex)].isShowUpdateGreenButton = false;
                this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledEditButton = true;

            } else {

            }
        }

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
        if (this.ifscDetails.BANK == '') {
            this.showToast('details missing', 'enter bank name', 'error');
            return;
        } else if (this.ifscDetails.BRANCH == '') {
            this.showToast('details missing', 'enter branch name', 'error');
            return;
        }
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].branchName = this.ifscDetails.BRANCH;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].bankName = this.ifscDetails.BANK;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isDisabledAccountVerifyType = false;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isShowUpdateGreenButton = true;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isDisabledEditButton = false;
        this.isShowIfsc = false;

    }

    selectPayeeChangeHandler(event) {
        debugger;
    }

    checkToBeDisbursedAmount(currentIndex) {
        debugger;

        for (let i = 0; i < this.payeeList.length; i++) {
            if (this.payeeList[i].index == currentIndex) {
                if (
                    this.payeeList[i].type.includes(Financial_Entity_Disburse_Amount_Validation) &&
                    (this.payeeList[i].toBeDisbursedAmount == null || this.payeeList[i].toBeDisbursedAmount == undefined || this.payeeList[i].toBeDisbursedAmount == "" || parseInt(this.payeeList[i].toBeDisbursedAmount) == 0)
                ) {
                    this.showToast("Please enter a to be disbursed amount.", "Can not be null for financial institute", "error");
                    return false; // Return false if validation fails
                } else if (this.payeeList[i].type == undefined || this.payeeList[i].type == "") {
                    this.showToast("Please select Entity type", "details missing", "error");
                    return false;

                } else if (this.payeeList[i].name == undefined || this.payeeList[i].name == "") {
                    this.showToast("Please enter name", "details missing", "error");
                    return false

                } else if (this.payeeList[i].email == undefined || this.payeeList[i].email == "") {
                    this.showToast("Please enter email", "details missing", "error");
                    return false

                } else if (this.payeeList[i].phone == undefined || this.payeeList[i].phone == "") {
                    this.showToast("Please enter phone", "details missing", "error");
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
            this.pennyDorpTaskSubject,
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
            let distinctAccount = payee.bankNumber + payee.bankAccountName;
            if (uniqueBankNumbers.has(distinctAccount)) {
                duplicates.push(distinctAccount);
            } else {
                uniqueBankNumbers.add(distinctAccount);
            }
        });

        if (duplicates.length > 0) {
            const duplicateValues = duplicates.join(", ");
            this.showToast(
                "Duplicate Bank Number/Payee Name Found",
                `Duplicate Bank Number/Payee Name Found: ${duplicateValues}`,
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


    submitforBackDetailsSelectedRow(currentIndex, isValidationApplicable) {
        debugger
        let isAllowDML = this.findDuplicateBankNumbers(this.payeeAcdetailsList);
        if (isValidationApplicable == true) {
            if (this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber && isAllowDML) {
                if (!this.BankAccountNumberValidation(currentIndex)) {
                    this.upperMethodforBankDetails(this.prepareDataforPayeeBankDetailsRecordsFORdatabase(this.payeeAcdetailsList, currentIndex))
                } else {
                    return false;
                }
            } else {
                if (!this.BankAccountNumberValidation(currentIndex) && isAllowDML) {
                    this.upperMethodforBankDetails(this.prepareDataforPayeeBankDetailsRecordsFORdatabase(this.payeeAcdetailsList, currentIndex))
                } else {
                    return false;
                }
            }
        } else if (isValidationApplicable == false) {
            if (!this.BankAccountNumberValidation(currentIndex)) {
                this.upperMethodforBankDetails(this.prepareDataforPayeeBankDetailsRecordsFORdatabase(this.payeeAcdetailsList, currentIndex))
            } else {
                return false;
            }
        }
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
                    Account_Name__c: payee.Account_Name__c,
                };
                let AccountCOntactPayeewrapper = {
                    relatedFinancialEntity: Financial_Entity__c,
                    name: payee.name,
                    payeeEmail: payee.email,
                    payeePhone: payee.phone,
                    index: payee.index
                };
                AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
            } else {
                let Financial_Entity__c = {
                    Id: payee.id,
                    Name: payee.name,
                    Entity_Type__c: payee.type,
                    Task_ID__c: payee.Task_ID__c,
                    Financial_Account__c: this.financialAccoundId,
                    Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                    Account_Name__c: payee.Account_Name__c,
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

    prepareDataforPayeeRecordsFORdatabaseForCurrentIndex(payeeList, currentIndex) {
        debugger;
        let AccountCOntactPayeewrapperList = [];
        for (let i = 0; i < payeeList.length; i++) {
            let payee = payeeList[i];
            if (payee.index == currentIndex) {
                if (!payee.id) {
                    let Financial_Entity__c = {
                        Name: payee.name,
                        Entity_Type__c: payee.type,
                        Task_ID__c: payee.Task_ID__c,
                        Financial_Account__c: this.financialAccoundId,
                        Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                        Account_Name__c: payee.Account_Name__c,
                    };
                    let AccountCOntactPayeewrapper = {
                        relatedFinancialEntity: Financial_Entity__c,
                        name: payee.name,
                        payeeEmail: payee.email,
                        payeePhone: payee.phone,
                        index: payee.index
                    };
                    AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
                } else {
                    let Financial_Entity__c = {
                        Id: payee.id,
                        Name: payee.name,
                        Entity_Type__c: payee.type,
                        Task_ID__c: payee.Task_ID__c,
                        Financial_Account__c: this.financialAccoundId,
                        Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                        Account_Name__c: payee.Account_Name__c,
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

    prepareDataforPayeeBankDetailsRecordsFORdatabase(payeeAcdetailsList, currentIndex) {
        debugger;
        let newpayeeAcdetailsList = [];
        for (let i = 0; i < payeeAcdetailsList.length; i++) {
            if (payeeAcdetailsList[i].index == currentIndex) {
                if (payeeAcdetailsList[i].id == undefined) {
                    let Financial_Entity_AC_Detail__c = {};
                    Financial_Entity_AC_Detail__c.Financial_Entity__c =
                        payeeAcdetailsList[i].selectedPayeeId;
                    // Financial_Entity_AC_Detail__c.Name =
                    // payeeAcdetailsList[i].Name;
                    Financial_Entity_AC_Detail__c.Bank_Account_Number__c = payeeAcdetailsList[i].bankNumber == "" ? 'Not Available' : payeeAcdetailsList[i].bankNumber;
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
                    Financial_Entity_AC_Detail__c.Bank_Account_Type__c = payeeAcdetailsList[i].Bank_Account_Type__c;
                    Financial_Entity_AC_Detail__c.isChanged__c = payeeAcdetailsList[i].isChanged__c == true ? false : true;
                    newpayeeAcdetailsList.push(Financial_Entity_AC_Detail__c);
                }

                if (payeeAcdetailsList[i].id == this.currentTobeUpdateBankdetailsId && payeeAcdetailsList[i].isPayeeNameChanged == true && this.currentTobeUpdateBankdetailsId != undefined) {
                    let Financial_Entity_AC_Detail__c = {};
                    Financial_Entity_AC_Detail__c.Verification_Status__c = payeeAcdetailsList[i].Verification_Status__c;
                    Financial_Entity_AC_Detail__c.Physically_verified__c = payeeAcdetailsList[i].Physically_verified__c;
                    Financial_Entity_AC_Detail__c.Id = payeeAcdetailsList[i].id;
                    Financial_Entity_AC_Detail__c.Banking_Account_Name__c =
                        payeeAcdetailsList[i].bankAccountName;
                    Financial_Entity_AC_Detail__c.Name = payeeAcdetailsList[i].Verification_Status__c == 'Verified' ? payeeAcdetailsList[i].Banking_Account_Name__c : payeeAcdetailsList[i].Name;
                    Financial_Entity_AC_Detail__c.Financial_Entity__c =
                        payeeAcdetailsList[i].selectedPayeeId;
                    Financial_Entity_AC_Detail__c.Bank_Account_Number__c = payeeAcdetailsList[i].bankNumber == "" ? 'Not Available' : payeeAcdetailsList[i].bankNumber;
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
                    Financial_Entity_AC_Detail__c.Bank_Account_Type__c = payeeAcdetailsList[i].Bank_Account_Type__c;
                    Financial_Entity_AC_Detail__c.isChanged__c = payeeAcdetailsList[i].isChanged__c == true ? false : true;
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
                if (this.ifscDetails.STATE == 'Not found') {
                    this.showToast("ifsc details not found", "Please Enter details", "alert");
                    this.isIFSCAPIError = true;

                } else {
                    this.showToast("Success", "please check details", "success");
                    this.isIFSCAPIError = false;
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

    updateBankDetailsManually(event) {
        debugger;
        this.isShowIfsc = false;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isDisabledBrachName = false;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].isDisabledBankName = false;

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
        this.payeeAcdetailsList[parseInt(currentIndex)].isShowCheckBoxs = false;
        this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = true;
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
        this.submitforBackDetailsSelectedRow(currentIndex, true);
        // this.unblockAllOthersRowsforBackDetails(currentIndex);
        // this.findDuplicateBankNumbers(this.payeeAcdetailsList)


    }


    blockAllOthersRowsforBackDetails(currentIndex) {
        debugger;
        for (let i = 0; i < this.payeeAcdetailsList.length; i++) {
            if (i === parseInt(currentIndex)) {
                this.payeeAcdetailsList[i].isDisabledPayeeName = false;
                this.payeeAcdetailsList[i].isDisabledBankAccountHolderName = false;
                this.payeeAcdetailsList[i].isShowUpdateGreenButton = false;
                this.payeeAcdetailsList[i].isDisabledBankAccountNumber = false;
                this.payeeAcdetailsList[i].isDisabledIFSCcode = false;
                this.payeeAcdetailsList[i].isDisabledAccountVerifyType = false;
                this.payeeAcdetailsList[i].isDisabledPayeeNameEdit = false;


            } else {
                this.payeeAcdetailsList[i].isDisabledBankName = true;
                this.payeeAcdetailsList[i].isDisabledBrachName = true;
                this.payeeAcdetailsList[i].isDisabledIFSCcode = true;
                this.payeeAcdetailsList[i].isDisabledAccountType = true;
                this.payeeAcdetailsList[i].isDisabledAccountVerifyType = true;
                this.payeeAcdetailsList[i].isDisabledPayeeName = true;
                this.payeeAcdetailsList[i].isDisabledBankAccountHolderName = true;
                this.payeeAcdetailsList[i].isDisabledBankAccountNumber = true;
                this.payeeAcdetailsList[i].isShowUpdateGreenButton = false;
                this.payeeAcdetailsList[i].isDisabledEditButton = true;

            }
        }
    }

    unblockAllOthersRowsforBackDetails(currentIndex) {
        for (let i = 0; i < this.payeeAcdetailsList.length; i++) {
            if (i === parseInt(currentIndex)) {
                this.payeeAcdetailsList[i].isDisabledPayeeName = true;
                this.payeeAcdetailsList[i].isDisabledBankAccountHolderName = true;

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
                bankDetailsRecordId: sObjectRecordId,
                parentTaskId: parentTaskId
            })
            .then((response) => {
                this.refreshData();
                this.showToast("Success", "verification request sent", "success");
                // this.hardRefresh();
            })
            .catch((error) => {
                this.refreshData();
                this.showToast("Error", error.body.message, "error");
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
            if (this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].Task_ID__c == this.taskId) {
                if (this.currentTobeUpdateBankdetailsId) {
                    this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].isDisabledEditButton = false;
                    this.isShowConfirmationComp = false;
                    // this.submitforBackDetailsSelectedRow(this.currentTobeUpdateBankdetailsindex);
                }
            } else {
                if (this.currentTobeUpdateBankdetailsId) {
                    this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].isDisabledEditButton = false;
                    this.isShowConfirmationComp = false;
                    this.submitforBackDetailsSelectedRow(this.currentTobeUpdateBankdetailsindex, true);
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
            if (this.checkBankaccountNumber_Status_Verified(index)) {
                this.payeeAcdetailsList[parseInt(index)].isDocumentUploaded = true;
                this.payeeAcdetailsList[parseInt(index)].Verification_Status__c = 'Verified';
                this.currentTobeUpdateBankdetailsId = recordId;
                this.payeeAcdetailsList[parseInt(index)].isPayeeNameChanged = true;
                this.payeeAcdetailsList[parseInt(index)].Physically_verified__c = true;
                // this.payeeAcdetailsList[parseInt(index)].Name=this.payeeAcdetailsList[parseInt(index)].Banking_Account_Name__c;
                this.submitforBackDetailsSelectedRow(index, false);
            } else {
                this.showToast(
                    "Bank Account Exist with Verified",
                    `Duplicate bank numbers found: ${this.payeeAcdetailsList[parseInt(index)].bankNumber}`,
                    "error"
                );
            }
        } else {
            this.handleHighlightRow(index);
            this.payeeAcdetailsList[parseInt(index)].isDocumentUploaded = false;
        }
    }

    checkBankaccountNumber_Status_Verified(index) {
        debugger;
        let isverifiedBankAccount_with_sameBankNumber_exist = false;
        if (this.payeeAcdetailsList[parseInt(index)] && this.payeeAcdetailsList[parseInt(index)].bankNumber && this.payeeAcdetailsList[parseInt(index)].bankNumber !='Not Available') {
            this.payeeAcdetailsList.find((item) => {
                if (isverifiedBankAccount_with_sameBankNumber_exist) return;
                if (item.bankNumber && item.Verification_Status__c) {
                    if (item.bankNumber === this.payeeAcdetailsList[parseInt(index)].bankNumber && item.Verification_Status__c === 'Verified') {
                        isverifiedBankAccount_with_sameBankNumber_exist = true;
                    }
                }
            })
        }
        return isverifiedBankAccount_with_sameBankNumber_exist == true ? false : true;
    }

    enabledEditingPayee(currentIndex) {
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

    upatePayeeByRowUpdateButton(event) {
        debugger
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        if (!this.checkToBeDisbursedAmount(currentIndex)) {} else {
            if (this.findDuplicatePayeeName(this.payeeList)) {
                this.InsertMethodforPayeeDetails(
                    this.prepareDataforPayeeRecordsFORdatabaseForCurrentIndex(this.payeeList, currentIndex))
                this.disanabledEditingPayee(currentIndex);
            } else {
                return;
            }

        }

    }

    disanabledEditingPayee(currentIndex) {
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

    checkNullValidationForPayeeRows(currentIndex) {
        debugger;
        for (let i = 0; i < this.payeeList.length; i++) {
            if (this.payeeList[i].index == currentIndex) {

            }
        }
    }

    BankAccountNumberValidation(index) {
        debugger;
        for (let i = 0; i < this.payeeAcdetailsList.length; i++) {
            if (this.payeeAcdetailsList[i].index == index) {
                if (this.payeeAcdetailsList[i].bankNumber == undefined || this.payeeAcdetailsList[i].bankNumber == '' || this.payeeAcdetailsList[i].bankNumber <= 0 || this.payeeAcdetailsList[i].bankNumber =='Not Available') {
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

        const validationRules = [{
                prop: 'selectedPayeeId',
                message: 'Please select Payee'
            },


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

        const validationRules = [{
                prop: 'selectedPayeeId',
                message: 'Please select Payee'
            },
            {
                prop: 'bankAccountName',
                message: 'Please enter bank account holder name'
            },
            {
                prop: 'bankNumber',
                message: 'Please enter account number'
            },
            {
                prop: 'IFSC',
                message: 'Please enter IFSC CODE'
            },
            {
                prop: 'branchName',
                message: 'Please enter branch'
            },
            {
                prop: 'bankName',
                message: 'Please enter bank Name'
            },
            {
                prop: 'Verification_Status__c',
                message: 'Verification Status not defined'
            },
            // { prop: 'Task_ID__c', message: 'Task id not defined' },

        ];

        for (const rule of validationRules) {
            if (!tempPayee[rule.prop] || tempPayee[rule.prop] === '' || tempPayee[rule.prop] === 'Not Available') {
                this.showToast(rule.message, 'Details missing', 'error');
                return true;
            }
        }

        return false; // All validations passed
    }

    ifscOnChange(event) {
        debugger;
        let eventName = event.target.name;
        let eventValue = event.target.value;
        if (eventName == 'IFSCBANKNAME') {
            this.ifscDetails.BANK = eventValue;
        } else if (eventName == 'IFSCBRANCHNAME') {
            this.ifscDetails.BRANCH = eventValue;

        }
    }

}