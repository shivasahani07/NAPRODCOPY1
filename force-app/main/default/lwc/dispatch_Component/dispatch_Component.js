import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import getDocumentsToBeCouriered from '@salesforce/apex/DispatchController.getDocumentsToBeCouriered';
import getAllreltedodcs from '@salesforce/apex/DispatchController.getAllreltedodcs';
 import UserNameFIELD from '@salesforce/schema/User.Name';
 import USERC_CITY from '@salesforce/schema/User.City';
 import USERC_STATE from '@salesforce/schema/User.State';
 import USERC_COUNTRY from '@salesforce/schema/User.Country';
import updateDocumentCourierDetail from '@salesforce/apex/DispatchController.updateDocumentCourierDetail';
import getGroupNameandGroupMembers from '@salesforce/apex/DispatchController.getGroupNameandGroupMembers';
import Child_components_Controller from '@salesforce/apex/Child_components_Controller.UpdateTaskStatus';
import getUserLocationAccounts from '@salesforce/apex/DispatchController.getUserLocationAccounts';

export default class DispatchComponent extends LightningElement {

    @api taskId
    @api taskRec;
    @track wrapperData = [];
    @api initFunctionality = false;
    @api validaStatusValue = 'To Be Dispatched';
    @track recipientAddressOptions;
    @track tempAccountUserOptions;
    @track accountIdNameMap;
    @track wiredDataList;
    @track isAllDocumentsSelected = false;
    @track isDisabledSelectedUser = true;
    @track isDisableddepartment = true;
    @track isHideSelectedUser = false;
    @track selectedRecipientAddress;
    @track shippingPartnerOptions;
    @track selectedShippingPartner;
    @track documentRecords;
    @track allContacts = [];
    @track selectedContactAddress;
    @track isDisabled = true;
    @track selectedUser;
    @track isShippingPartnerDisabled = true;
    @track isAWBDisabled = true;
    @track accoutIdNameMap;
    @track selectedRecipant;
    @track relatedContacsAdd;
    @track senderName;
    @track senderAddress;
    @track reciverName;
    @track selectedRecipantRecordSize = 0;
    @track isDispatchButtonDisabled = true;
    @track docCategoryMap = {};
    @track allSelectedRecord;
    @track isDocumentTypeCheque = false;
    @track iscommentMandatory = false;
    @track maskeddatalist = [];
    @track withFilterdata = [];
    @track tempmaskeddatalist = [];
    @api compIndex;
    @track showComments = false;
    @track Shipping_Partner_value = 'Inter Transfer';
    @track selectedDepartment;

    @track tempAccountDepartmentOptions = [];
    @track DepartmentWithDepartmentMembers = [];
    @track documentRelatedCurrentTaskIds = [];
    @track disPathingBranchMap;


    contactData = '';
    contactAddress;
    error;
    textValue;
    selectedDocIdList = [];
    @track selectedRecipientId;
    showButtonDispatch = false;

    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD,USERC_CITY,USERC_STATE,USERC_COUNTRY]})
    currentUserInfo({ error, data }) {
        debugger;
        if (data) {
            this.senderName = data.fields.Name.value;
            let city = data.fields.City.value ? data.fields.City.value : '';
            let state = data.fields.State.value ? data.fields.State.value : '';
            let country = data.fields.Country.value ? data.fields.Country.value : '';
            this.senderAddress = `${city}${city && state ? ', ' : ''}${state}${(city || state) && country ? ', ' : ''}${country}`;
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        this.getUserRelatedAccounts();
    }

    getUserRelatedAccounts(){
        debugger;
        getUserLocationAccounts()
            .then(response =>{
                console.log('response---',response);
                this.disPathingBranchMap=response.map(branch =>({
                    label:branch.Name,
                    value:branch.Id
                }))
                console.log('disPathingBranchMap---',JSON.stringify(this.disPathingBranchMap));
            })
            .catch(error=>{
                console.log('error---',error);
            })
    }

    

    doInitFromParentComp(taskRec, accountId) {
        debugger;
        getDocumentsToBeCouriered({ inp_Task: taskRec, accountId: accountId })
            .then(response => {
                console.log('response---', JSON.stringify(response));
                this.wiredDataList = response;

                const updatedDocuments = response.documents.map(document => {
                    if (response.paybles) {
                        for (let j = 0; j < response.paybles.length; j++) {
                            if (document.Extended_SObject_RecordId__c === response.paybles[j].Id) {
                                return {
                                    ...document,
                                    payeeName: response.paybles[j].Finacial_Entity_Details__r.Name,
                                    bankAccountNumber: response.paybles[j].Financial_Entity_A_C_Details__r.Bank_Account_Number__c,
                                    isChequeTrue: true,
                                    Amount__c: response.paybles[j].Amount__c,
                                    isCommentVisible: false
                                };
                            }
                        }
                    }
                    if (response.modtlist) {
                        for (let k = 0; k < response.modtlist.length; k++) {
                            if (document.Extended_SObject_RecordId__c === response.modtlist[k].Id) {
                                return {
                                    ...document,
                                    ismortager: true,
                                    mortager_name: response.modtlist[k].Mortgager_Name__r.Name,
                                    mortager_id: response.modtlist[k].Mortgager_Name__r.Id,
                                    isCommentVisible: false,
                                    isDisabled: true,
                                    transferByName: document.Transfer_To__r.Name,
                                    executed_on_date: response.modtlist[k].Date_Of_Execution__c,
                                    excecution_place: `${response.modtlist[k].Place__c.street},${response.modtlist[k].Place__c.state},${response.modtlist[k].Place__c.country}`
                                };
                            }
                        }
                    }
                    return document;
                });

                if (response.recepiantUsers) {
                    this.accountIdNameMap = {};
                    for (let i = 0; i < response.recepiantUsers.length; i++) {
                        const accountId = response.recepiantUsers[i].Branches_List_String_Literal__c;
                        const userId = response.recepiantUsers[i].Id;
                        const userName = response.recepiantUsers[i].Name;
                        if (this.accountIdNameMap.hasOwnProperty(accountId)) {
                            this.accountIdNameMap[accountId].push({ value: userId, label: userName });
                        } else {
                            this.accountIdNameMap[accountId] = [{ value: userId, label: userName }];
                        }
                    }
                    console.log('AccountIdNameMap:', this.accountIdNameMap);
                }

                this.documentsList = updatedDocuments.filter(result => result.Status__c == this.validaStatusValue);
                this.searchResultsByCategoryv1(this.documentsList);
                this.allContacts = response.contacts;
                this.accoutIdNameMap = response.recipants.map(partner => ({
                    label: partner.Name,
                    value: partner.Id
                }));
                this.relatedContacsAdd = response.showRelatedContacsAddress;
                this.shippingPartnerOptions = response.shippingpartner.map(partner => ({
                    label: partner.Name,
                    value: partner.Id
                }));

                this.showButtonDispatch = !taskRec;
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: "ERROR",
                    message: "No Documents Found!",
                    variant: "error",
                });
                this.dispatchEvent(evt);
                console.log('error--', error);
            });
    }


    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        this.activeSections = openSections;
    }

    dispatchingBranchChnageHandler(event) {
        debugger;
        let recipantId = event.detail.value;
        this.resetData();
        this.doInitFromParentComp(this.taskRec,recipantId);

    }
    addBooleanField(documents) {
        debugger;
        return documents.map(record => {
            const documentName = record.Document_Metadata__r.Document_Name__c.replace(/\s+/g, '_'); // Replace spaces with underscores
            return {
                ...record,
                [`is${documentName}`]: true // Dynamically adding a boolean field with the name is<Document_Name__c>
            };
        });
    }

    resetData(){
        debugger;
        this.accoutIdNameMap='';
        this.tempAccountDepartmentOptions='';
        this.tempAccountUserOptions='';
        this.shippingPartnerOptions='';
        this.textValue='';
        this.selectedRecipant='';
        this.selectedDepartment='';
        this.selectedUser='';
        this.selectedShippingPartner='';
        this.maskeddatalist=[];
        this.showButtonDispatch=false;
        this.isDispatchButtonDisabled=true;
    }



    handleRecipantChnageHandler(event) {
        debugger;
        let recipantId = event.detail.value;
        this.selectedRecipientId = recipantId;

        this.reciverName = '';
        this.selectedUser = '';
        this.isAWBDisabled = true;
        this.getAccountRelatedContact();
        let temDoc = this.withFilterdata;
        console.log('maskeddatalist', this.maskeddatalist);
        this.tempAccountUserOptions = this.accountIdNameMap[recipantId];
        if (!this.tempAccountUserOptions) {
            this.isHideSelectedUser = true;
            this.reciverName = this.findLabelByValue(this.accoutIdNameMap, recipantId);
            this.isDispatchButtonDisabled = true;
        } else {
            this.isDisableddepartment = false;
            this.isHideSelectedUser = false;
        }
        if (this.contactAddress != null && this.contactAddress != undefined && this.contactAddress.includes("undefined")) {
            this.contactAddress = ''
        }
        this.maskeddatalist = this.filterByTransferToId(temDoc, recipantId);
        let recepitantIds = [];
        recepitantIds.push(recipantId);
        this.getDepartments(recepitantIds)
    }

    getDepartments(recipantIds) {
        debugger;
        this.DepartmentWithDepartmentMembers=[];
        getGroupNameandGroupMembers({ AccountIds: recipantIds })
            .then(response => {
                if (response != null && response != undefined) {
                    for (var key in response) {
                        this.DepartmentWithDepartmentMembers.push({ value: response[key], key: key });
                    }
                    this.tempAccountDepartmentOptions = this.DepartmentWithDepartmentMembers.map(obj => ({ 'label': obj.key, 'value': obj.key }))
                }
            })
            .catch(error => {

            })
    }

    selectedUserChangeHandler(event) {
        debugger;
        this.selectedUser = event.detail.value;
        this.reciverName = this.findLabelByValue(this.tempAccountUserOptions, this.selectedUser);
    }

    findLabelByValue(options, value) {
        debugger;
        for (let i = 0; i < options.length; i++) {
            if (options[i].value === value) {
                return options[i].label;
            }
        }
        return null; // Value not found
    }


    filterByTransferToId(data, transferToValue) {
        debugger;
        const filteredData = data.map(category => ({
            ...category,
            documents: category.documents.filter(document => {
                console.log('document', document)
                if (document.Transfer_To__c === transferToValue) {
                    return document;
                }
            })
        }));
        console.log('filteredData', filteredData);
        return filteredData;
    }


    handleShippingPartnerChange(event) {
        debugger;
        let selectedShippingPartnerId = event.detail.value;
        let shipping_label = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.selectedShippingPartner = selectedShippingPartnerId;
        if (this.Shipping_Partner_value == shipping_label) {
            this.iscommentMandatory = true;
            let tracking_number = this.RandomTrackingNumber_generator();
            this.textValue = tracking_number;
            this.isAWBDisabled = true;
        } else {
            //this.showComments=false;
            this.textValue = '';
            this.isAWBDisabled = false;
            this.iscommentMandatory = false;
        }
    }
    handleTrackingNumberChange(event) {
        debugger;
        let trackingNumber = event.detail.value;
        this.textValue = trackingNumber;
    }

    selectAllCheckBox(event) {
        let checked = event.target.checked; // Get the checked status of the "Select All" checkbox
        let checkboxes = this.template.querySelectorAll('lightning-input[data-key="singleSelectColumnCheckbox"]');
        checkboxes.forEach(checkbox => {
            checkbox.checked = checked; // Set each checkbox's checked status to match the "Select All" checkbox
            this.handleCheckboxChange(checkbox); // Call your existing handleCheckboxChange method to update selected records
        });
    }

    handleCheckboxChange(event) {
        debugger;
        let totalDocumentsCount = 0;
        let currentTaskIdset = new Set();

        if (this.maskeddatalist.length > 0) {
            this.maskeddatalist.forEach((item) => {
                if (item.documents != null && item.documents != undefined && item.documents.length > 0) {
                    totalDocumentsCount = totalDocumentsCount + item.documents.length;
                }
            })
        }
        let selectedRecordList = [];
        let selectedRecord = '';
        let singleColumnCheckbox = this.template.querySelectorAll('lightning-input[data-key="singleSelectColumnCheckbox"]');
        singleColumnCheckbox.forEach(row => {
            if (row.type == 'checkbox' && row.checked) {
                selectedRecord = row.value;
                selectedRecordList.push(row.value);
            }
        });
        if (selectedRecordList.length > 0) {
            this.isDispatchButtonDisabled = false;
            this.isShippingPartnerDisabled = false;
            this.isAWBDisabled = false;
        }
        else {
            this.isDispatchButtonDisabled = true;
            this.isShippingPartnerDisabled = true;
            this.isAWBDisabled = true;
        }
        this.allSelectedRecord = selectedRecordList;

        this.allSelectedRecord.forEach(currentItem => {
            if (currentItem) {
                this.maskeddatalist.forEach((item) => {
                    if (item.documents != null && item.documents != undefined && item.documents.length > 0) {
                        item.documents.forEach(doc_item => {
                            if (doc_item.Id == currentItem && doc_item.Current_Task_ID__c) {
                                currentTaskIdset.add(doc_item.Current_Task_ID__c);
                            }
                        });
                    }
                })
            }
        });
        this.documentRelatedCurrentTaskIds = Array.from(currentTaskIdset);

    }

    getAccountRelatedContact() {
        debugger;
        let tempContactAdd = this.relatedContacsAdd;
        tempContactAdd.forEach(con => {
            if (con.AccountId == this.selectedRecipientId) {
                this.contactAddress = con.MailingStreet + ',' + con.MailingCity + ' ,' + con.MailingState + ' ,' + con.MailingCountry;
            } else {
                this.isShippingPartnerDisabled = true;
            }
        });
    }

    searchResultsByCategoryv1(tempsearchreasultarray) {
        debugger;
        var temparray = [];
        for (var i = 0; i < tempsearchreasultarray.length; i++) {
            if (temparray.length > 0) {
                let findresult = temparray.find(eachObj => eachObj.category === tempsearchreasultarray[i].Document_Metadata__r.Document_Name__c);
                if (findresult != null) {
                    const index = temparray.findIndex(item => item.category === tempsearchreasultarray[i].Document_Metadata__r.Document_Name__c);
                    var findresultdocarray = findresult.documents;
                    var tempobject = JSON.parse(JSON.stringify(tempsearchreasultarray[i]));
                    tempobject.maskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                    tempobject.unmaskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                    findresultdocarray.push(tempobject);
                    var tempfindresult = JSON.parse(JSON.stringify(findresult));
                    tempfindresult.documents = findresultdocarray;
                    temparray[index] = tempfindresult;
                } else {
                    var tempObj = {};
                    tempObj.category = tempsearchreasultarray[i].Document_Metadata__r.Document_Name__c;
                    if (tempObj.category == 'Cheque') {
                        tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "Select"];
                    } else if (tempObj.category.includes("MODT")) {
                        tempObj.Headervalues = ["MODT Id.", "To Be Handed Over", "Mortager Name", "Execution Date", "Execution Place", "Select"];
                    } else {
                        tempObj.Headervalues = ["Document No.", "Hand Over To", "Select"];
                    }
                    var tempobject = JSON.parse(JSON.stringify(tempsearchreasultarray[i]));
                    tempobject.maskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                    tempobject.unmaskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                    var innertemparry = [];
                    innertemparry.push(tempobject);
                    tempObj.documents = innertemparry;
                    temparray.push(tempObj);
                }
            } else {
                var tempObj = {};
                tempObj.category = tempsearchreasultarray[i].Document_Metadata__r.Document_Name__c;
                if (tempObj.category == 'Cheque') {
                    tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "Select"];
                } else if (tempObj.category.includes("MODT")) {
                    tempObj.Headervalues = ["MODT Id.", "To Be Handed Over", "Mortager Name", "Execution Date", "Execution Place", "Select"];
                } else {
                    tempObj.Headervalues = ["Document No.", "Hand Over To", "Select"];
                }
                var tempobject = JSON.parse(JSON.stringify(tempsearchreasultarray[i]));
                tempobject.maskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                tempobject.unmaskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                var innertemparry = [];
                innertemparry.push(tempobject);
                tempObj.documents = innertemparry;
                temparray.push(tempObj);
            }
        }
        this.withFilterdata = temparray
        console.log('formdata--', JSON.stringify(this.withFilterdata));
    }

    maskFirstLastLetters(str) {
        debugger;
        if (str.length <= 2) {
            // If the string has 2 or fewer characters, do not mask anything
            return str;
        }
        const firstLetter = str.charAt(0);
        const lastLetter = str.charAt(str.length - 1);
        const maskedCharacters = '*'.repeat(str.length - 2);
        return firstLetter + maskedCharacters + lastLetter;
    }

    get transformedData() {
        return Array.from(this.docCategoryMap, ([key, value]) => ({ key, value }));
    }

    @api updateDcuRecordS() {
        debugger;
        let validationobj
        validationobj = this.checkvalidationsBeforeUpdate(this.allSelectedRecord, this.selectedShippingPartner, this.textValue);
        if (validationobj != null && validationobj != undefined && validationobj.isValidation_success) {
            updateDocumentCourierDetail({ documentCourierId: this.allSelectedRecord, shippingPartnerId: this.selectedShippingPartner, awbNumber: this.textValue, userId: this.selectedUser ? this.selectedUser : null, comments: this.commentvalue, DepartmentName: this.selectedDepartment, AccountId: this.selectedRecipientId })
                .then(result => {
                    if (result) {
                        if (result == 'SUCCESS') {
                            // alert('SUCCESS'); 
                            const evt = new ShowToastEvent({
                                title: "SUCCESS",
                                message: "Document Dispatched Successfully!",
                                variant: "success",
                            });
                            this.dispatchEvent(evt);
                            if (this.taskRec != null && this.taskRec != undefined && this.taskRec.Id != null && this.taskRec.Id != undefined) {
                                this.sendClosedStatementToParent(true);
                            } else {
                                if (this.documentRelatedCurrentTaskIds.length > 0) {
                                    this.close_currentTaskIds_RelatedToDocuments();
                                }
                                location.reload();
                            }
                        }
                    }
                })
                .catch(error => {
                    this.error = error;
                })
        } else {
            if (validationobj != null && validationobj != undefined) {
                const evt = new ShowToastEvent({
                    title: "Title",
                    message: validationobj.errormessage,
                    variant: "Error",
                });
                this.dispatchEvent(evt);
            }
        }

    }


    close_currentTaskIds_RelatedToDocuments() {
        debugger;
        Child_components_Controller({ ApproverStatus: 'Completed', TaskIdset: this.documentRelatedCurrentTaskIds })
            .then(result => {

            })
            .catch(error => {

            })
    }

    checkvalidationsBeforeUpdate(selectedRecord, selected_shipping_partner, awb_value) {
        debugger;
        var errorobj = { isValidation_success: null, errormessage: null };
        if (selectedRecord != undefined && selectedRecord != null && selectedRecord.length > 0) {
            errorobj.isValidation_success = true;
            errorobj.errormessage = null;
            if (selected_shipping_partner != null && selected_shipping_partner != undefined && selected_shipping_partner != "") {
                errorobj.isValidation_success = true;
                errorobj.errormessage = null;
                if (awb_value != null && awb_value != undefined && awb_value != "") {
                    errorobj.isValidation_success = true;
                    errorobj.errormessage = null;
                    if (this.iscommentMandatory == true && this.commentvalue == null && this.commentvalue == undefined && this.commentvalue == '') {
                        errorobj.isValidation_success = false;
                        errorobj.errormessage = 'Comment Is Mandatory';
                    } else {
                        errorobj.isValidation_success = true;
                        errorobj.errormessage = null;
                    }if(this.selectedDepartment =="" || this.selectedDepartment ==undefined || this.selectedDepartment ==null){
                        errorobj.isValidation_success = false;
                        errorobj.errormessage = 'Please Select Department';
                    }
                } else {
                    errorobj.isValidation_success = false;
                    errorobj.errormessage = 'Provide the Tracking Number';
                }
            } else {
                errorobj.isValidation_success = false;
                errorobj.errormessage = 'Select Any Shipping Partner';
            }
        } else {
            errorobj.isValidation_success = false;
            errorobj.errormessage = 'Select Any Document to Proceed Further';
        }
        return errorobj;
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
    @track commentvalue;
    HandleOnChangeComments(event) {
        debugger;
        if (event.target.value != null && event.target.value != undefined && event.target.value != '') {
            this.commentvalue = event.target.value;
        }
    }

    AddhandleClick() {
        debugger;
        this.showComments = false;
    }

    selectedHandleDepartment(event) {
        debugger
        let value = event.detail.value;
        this.selectedDepartment = value;
        this.isDisabledSelectedUser = false;
        this.tempAccountUserOptions = this.DepartmentWithDepartmentMembers.find(item => item.key == value).value.map(obj => ({ 'label': obj, 'value': obj }));
    }





















    /// old codes
    getAllreltedodc() {
        debugger;
        getAllreltedodcs({ recipantId: this.selectedRecipant })
            .then(response => {
                this.documentRecords = response.documents.map(doc => ({
                    Id: doc.Id,
                    Document_ID_Name__c: doc.Document_Metadata__r.Name,
                    Document_ID_Value__c: doc.DMS_ID__c
                }));
            })
            .catch(error => {

            });
    }



    handleRecipientChange(event) {
        debugger;
        this.selectedRecipientId = event.detail.Id;
        var selectedValueName = event.detail.Name;
        for (let i = 0; i <= this.allContacts.length; i++) {
            if (this.selectedRecipientId == this.allContacts[i].Id) {
                this.selectedContactAddress = this.allContacts[i].MailingStreet;
                return;
            }
        }
    }





    handleRecipientAddressChange(event) {
        debugger;
        this.selectedRecipientAddress = event.detail.value;
        // Perform actions based on the selected recipient address
    }






    handleDispatch(event) {
        debugger;
        let selectedRecordList = [];
        let selectedRecord = '';
        if (this.taskId == null) {
            alert('Please Enter Task Is')
            return;
        }
        let singleColumnCheckbox = this.template.querySelectorAll('lightning-input[data-key="singleSelectColumnCheckbox"]');
        singleColumnCheckbox.forEach(row => {
            if (row.type == 'checkbox' && row.checked) {
                selectedRecord = row.value;
                selectedRecordList.push(row.value);

            }
        });
        if (this.selectedShippingPartner && this.textValue != null && this.selectedShippingPartner && this.textValue != undefined && selectedRecordList.length > 0) {
            this.selectedDocIdList = selectedRecordList;
            this.updateDcuRecordS();
        }
        else {
            //showNotification() {
            const evt = new ShowToastEvent({
                title: "Title",
                message: "Either of Shipping Partner And AWB is Empty Please Check it canno't be empty!",
                variant: "Error",
            });
            this.dispatchEvent(evt);

        }
        console.log('selectedRecordList : ' + selectedRecordList);
        //this.selectedDocIdList = selectedRecordList;
        //this.updateDcuRecordS();
    }

    RandomTrackingNumber_generator() {
        debugger
        var digits = '0123456789abcdefghijklmnopqrstuvwxyz';
        var otpLength = 8;
        var TrackingNumber = '';
        for (let i = 1; i <= otpLength; i++) {
            var index = Math.floor(Math.random() * (digits.length));

            TrackingNumber = TrackingNumber + digits[index];
        }

        return TrackingNumber;
    }

    Handleonclick() {
        debugger;
        this.showComments = true;
    }

    handleClick() {
        debugger;
        this.showComments = false;
    }


}