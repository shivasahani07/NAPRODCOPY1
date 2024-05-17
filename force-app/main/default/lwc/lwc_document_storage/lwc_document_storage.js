/* eslint-disable no-debugger */
import { LightningElement, api, wire, track } from 'lwc';
import docsWithdetailsforStorage from '@salesforce/apex/DocumentCourierDetailController.docsWithdetailsforStorage';
import getTaskRecirdbyId from '@salesforce/apex/DocumentCourierDetailController.getTaskRecirdbyId';
import updateDocumentStorageDetails from '@salesforce/apex/DocumentCourierDetailController.updateDocumentStorageDetails';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class Lwc_document_storage extends LightningElement {

    @track taskId = '00TBl000002Lz9AMAS' //00TBl000002JytpMAC;
    @api validaStatusValue = 'Document Storge';
    @track updateStatus = 'Physically Stored';
    @api initFunctionality = false;
    @track isRecordEditable = true;
    @api isCallingFromParent;
    @api compIndex;
    @api taskRec;
    @track todaysdate = new Date().toJSON().slice(0, 10);
    @track wiredDataList;
    @track documentsList;
    @track showButtonDispatch = true;
    @track isDispatchButtonDisabled = false;
    @track searchResults = [];
    @track updatedeWithStatsDocumentsList = [];
    @track commentReason;
    @track maskeddatalist = [];
    @track updatedStatusCount; // Track the number of status updates
    @track updatedVisibilityCount;
    @track ChequeCancellation_Reasons = [];
    @track isRecordDisabled;


    // @wire(getTaskRecirdbyId, { taskId: '$taskId' })
    // wiredData({ error, data }) {
    //     if (data) {
    //         debugger;
    //         if (this.isCallingFromParent) {

    //         } else {
    //             this.taskRec = data;
    //             this.doInitFromParentComp(this.taskRec);
    //         }

    //         console.log('Data', data);
    //     } else if (error) {
    //         console.error('Error:', error);
    //     }
    // }

    connectedCallback() {
        this.doInitFromParentComp(this.taskRec);
        if (this.isRecordEditable) {
            this.isRecordDisabled = false
        } else {
            this.isRecordDisabled = true
        }
    }

    doInitFromParentComp(taskRec) {
        // this.taskId = taskRec.Id;
        debugger;
        docsWithdetailsforStorage({ inp_Task: taskRec })
            .then(response => {
                //alert('done---'); 
                this.wiredDataList = response;
                console.log('response', JSON.stringify(response))
                const updatedDocuments = response.documents.map(document => {
                    if (response.paybles.length>0) {
                        for (let j = 0; j < response.paybles.length; j++) {
                            if (document.Extended_SObject_RecordId__c === response.paybles[j].Id) {
                                // Return a new object with the updated properties
                                return {
                                    ...document,
                                    showAll: true,
                                    dynamicClass: '',
                                    payeeName: response.paybles[j].Finacial_Entity_Details__r.Name,
                                    bankAccountNumber: response.paybles[j].Financial_Entity_A_C_Details__r.Bank_Account_Number__c,
                                    isChequeTrue: true,
                                    Amount__c: response.paybles[j].Amount__c,
                                    isCommentVisible: false,
                                    isEditable: false,
                                    isDisabled: true,
                                    isEditButtonDisabled: false,
                                    transferByName: document.Transfer_To__r.Name,
                                    isHideEditButton: this.updateStatus == document.Status__c
                                }
                            }
                        }
                    }
                    // If no match is found, return the original object
                    if (response.modtlist != null && response.modtlist != undefined && response.modtlist.length > 0) {
                        for (let k = 0; k < response.modtlist.length; k++) {
                            if (document.Extended_SObject_RecordId__c === response.modtlist[k].Id) {
                                // Return a new object with the updated properties
                                return {
                                    ...document,
                                    ismortager: true,
                                    mortager_name: response.modtlist[k].Mortgager_Name__r.Name,
                                    mortager_id: response.modtlist[k].Mortgager_Name__r.Id,
                                    isCommentVisible: false,
                                    isDisabled: true,
                                    transferByName: document.Transfer_To__r.Name,
                                    executed_on_date: response.modtlist[k].Date_Of_Execution__c,
                                    excecution_place: response.modtlist[k].Place__c.street + ',' + response.modtlist[k].Place__c.state + ',' + response.modtlist[k].Place__c.country
                                };
                            }
                        }
                    }
                    document.isHideEditButton = this.updateStatus == document.Status__c;
                    document.isEditable = false;
                    document.isDisabled = true;
                    document.isEditButtonDisabled = false;
                    document.dynamicClass = '';
                    document.transferByName = document.Transfer_To__r.Name;
                    return document;
                });
                
            const updatedDocumentsWithIndex = updatedDocuments.map((doc, index) => {
                doc.index = index;
                return doc;
            });
                this.documentsList = updatedDocumentsWithIndex;
                this.searchResultsByCategoryv1(this.documentsList);

            })
            .catch(error => {
                //alert('error---');
                console.error('An error occurred:', error);
            });
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        this.activeSections = openSections;
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
                    tempobject.maskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c;
                    tempobject.unmaskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c;

                    // Add isChecked field based on category's Headervalues
                    tempobject.isChecked = findresult.Headervalues.includes(tempobject.Document_Metadata__r.Document_Name__c);

                    findresultdocarray.push(tempobject);
                    var tempfindresult = JSON.parse(JSON.stringify(findresult));
                    tempfindresult.documents = findresultdocarray;
                    temparray[index] = tempfindresult;
                } else {
                    var tempObj = {};
                    tempObj.category = tempsearchreasultarray[i].Document_Metadata__r.Document_Name__c;
                    if (tempObj.category == 'CheckList') {
                        tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "File Barcode", "Box Barcode", "Date of storage", "Action"];
                    } else if (tempObj.category == 'Cheque') {
                        tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "File Barcode", "Box Barcode", "Date of storage", "Action"];
                    } else if(tempObj.category.includes("MODT")) {
                        tempObj.Headervalues = ["MODT Id.", "Hand Over To", "Mortager Name", "Execution Date", "Execution Place","File Barcode","Box Barcode", "Date of storage", "Action"];
                    }
                    else {
                        tempObj.Headervalues = ["Document No.", "Hand Over To", "File Barcode", "Box Barcode", "Date of storage", "Action"];
                    }

                    var tempobject = JSON.parse(JSON.stringify(tempsearchreasultarray[i]));
                    tempobject.maskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c;
                    tempobject.unmaskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c;

                    // Add isChecked field based on category's Headervalues
                    tempobject.isChecked = tempObj.Headervalues.includes(tempobject.Document_Metadata__r.Document_Name__c);
                    var innertemparry = [];
                    innertemparry.push(tempobject);
                    tempObj.documents = innertemparry;
                    temparray.push(tempObj);
                }
            } else {
                var tempObj = {};
                tempObj.category = tempsearchreasultarray[i].Document_Metadata__r.Document_Name__c;
                if (tempObj.category == 'CheckList') {
                    tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "File Barcode", "Box Barcode", "Date of storage", "Action"];
                } else if (tempObj.category == 'Cheque') {
                    tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "File Barcode", "Box Barcode", "Date of storage", "Action"];
                }else if (tempObj.category.includes("MODT")) {
                    tempObj.Headervalues = ["MODT Id.", "Hand Over To", "Mortager Name", "Execution Date", "Execution Place","File Barcode","Box Barcode", "Date of storage", "Action"];
                }
                else {
                    tempObj.Headervalues = ["Document No.", "Hand Over To", "File Barcode", "Box Barcode", "Date of storage", "Action"];
                }
                var tempobject = JSON.parse(JSON.stringify(tempsearchreasultarray[i]));
                tempobject.maskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c;
                tempobject.unmaskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c;

                // Add isChecked field based on category's Headervalues
                tempobject.isChecked = tempObj.Headervalues.includes(tempobject.Document_Metadata__r.Document_Name__c);

                var innertemparry = [];
                innertemparry.push(tempobject);
                tempObj.documents = innertemparry;
                temparray.push(tempObj);
            }
        }
        this.maskeddatalist = temparray;
        console.log('formdata--', JSON.stringify(this.maskeddatalist));
    }

    inputValueChangeHandler(event) {
        debugger;
        let eventName = event.target.name;
        if (eventName === 'fileBarcode') {
            this.genericChangeHandler(event, 'File_Barcode__c');
        } else if (eventName === 'boxBarcode') {
            this.genericChangeHandler(event, 'Box_Barcode__c');
        } else if (eventName === 'dateOfStorage') {
            this.genericChangeHandler(event, 'Date_of_storage__c');
        }
    }

    genericChangeHandler(event, field) {
        debugger;
        let recordId = event.target.dataset.id;
        let inputValue = event.target.value;
        let ddd = this.maskeddatalist;
        for (let i = 0; i < ddd.length; i++) {
            for (let j = 0; j < ddd[i].documents.length; j++) {
                if (ddd[i].documents[j].Id === recordId) {
                    ddd[i].documents[j].isEditable = true;
                    ddd[i].documents[j][field] = inputValue;
                    break;
                }
            }
        }
    }

    @api updateDocuemtStorageDetails() {
        debugger
        let documentsOnly = this.maskeddatalist;
        if (this.DocumentValidation(documentsOnly) === true) {
            this.prePareDocumentLIst(documentsOnly);
        } else {
            let nullValuesId = this.DocumentValidation(documentsOnly);
            console.log('nullValuesId--->', nullValuesId);
            this.AddErrorToSpecificRow(nullValuesId, documentsOnly);
        }
    }
    // THIS METHOD WILL ADD ERROR TO SPECIFIC ULTERD ROW WHICH HAS SOME NULL VALUES,
    AddErrorToSpecificRow(nullValuesId, documentsOnly) {
        debugger;
        for (let i = 0; i < documentsOnly.length; i++) {
            for (let j = 0; j < documentsOnly[i].documents.length; j++) {
                let document = documentsOnly[i].documents[j];
                if (document.Id == nullValuesId) {
                    document.dynamicClass = 'addError'
                }
            }
        }

    }

    prePareDocumentLIst(docs) {
        debugger
        var PreparedDocuments = [];

        docs.forEach(category => {
            category.documents.forEach(document => {
                if (document.isEditable === true) {
                    this.removeErrorToSpecificRow(document.Id)
                    let Document_Hanler__c = {};
                    Document_Hanler__c.Id = document.Id;
                    Document_Hanler__c.File_Barcode__c = document.File_Barcode__c;
                    Document_Hanler__c.Box_Barcode__c = document.Box_Barcode__c;
                    Document_Hanler__c.Date_of_storage__c = document.Date_of_storage__c;
                    Document_Hanler__c.Status__c = this.updateStatus;
                    PreparedDocuments.push(Document_Hanler__c);
                }
            });
        });
        if (PreparedDocuments.length > 0) {
            this.callUpdateApexMethod(PreparedDocuments);
        } else {
            // titel,message,variant
            this.showToast('No record to be updated', 'Please Edit Records', 'alert');
        }

    }

    // this method will run to check validation on submit before document prepararion
    DocumentValidation(ddd) {
        debugger;
        let shouldskip=false;
        for (let i = 0; i < ddd.length; i++) {
            if(shouldskip){return}
            for (let j = 0; j < ddd[i].documents.length; j++) {
                let document = ddd[i].documents[j];
                //document.isEditable === true && (document.File_Barcode__c === undefined || document.Box_Barcode__c === undefined || document.Date_of_storage__c === undefined)
                if (document.isEditable === true && (document.File_Barcode__c === undefined || document.Box_Barcode__c === undefined || document.Date_of_storage__c === undefined)) {
                    shouldskip=true;
                    return document.Id;
                }
            }
        }
        return shouldskip==true ?false:true;
    }

    // havent used yet
    sendClosedStatementToParent(isClosed) {
        debugger;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: {
                "isclosed": isClosed,
                "index": this.compIndex
            }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }

    callUpdateApexMethod(updatedDocLIst) {
        updateDocumentStorageDetails({ docsToBeupdatesList: updatedDocLIst })
            .then(response => {
                this.showToast('Scuccess', 'edited record updated', 'success');
                this.callEventToUpdateData(true);
            })
            .catch(error => {
                this.showToast('something went wrong', 'Error Please try again latter', 'error');
            })
    }

    removeErrorToSpecificRow(InputChangeValueId) {
        debugger;
        let documentsOnly = this.maskeddatalist;
        for (let i = 0; i < documentsOnly.length; i++) {
            for (let j = 0; j < documentsOnly[i].documents.length; j++) {
                let document = documentsOnly[i].documents[j];
                if (document.Id == InputChangeValueId) {
                    document.dynamicClass = ''
                }
            }
        }
    }

    //THIS METHOD WILL UNABLE EDIT SELECTED ROW 
    handleEnableEditRow(event) {
        debugger;
        let documentsOnly = this.maskeddatalist;
        let cureentId = event.target.dataset.id;
        for (let i = 0; i < documentsOnly.length; i++) {
            for (let j = 0; j < documentsOnly[i].documents.length; j++) {
                let document = documentsOnly[i].documents[j];
                if (document.Id == cureentId) {
                    if (document.isDisabled) {
                        document.isDisabled = false;
                        document.isEditable=true;
                    } else {
                        document.isDisabled = true;
                        document.isEditable=false;
                    }
                }
            }
        }
    }

    showToast(titel, message, variant) {
        const event = new ShowToastEvent({
            title: titel,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    callEventToUpdateData(is_closed_boolean){
        debugger;
        const event = new CustomEvent('valuechange', {
            detail: {
                isclosed: is_closed_boolean,
                index: this.compIndex
            }
        });
        this.dispatchEvent(event);
    }



    callDocumentHandlerFinalSubmit() {
        debugger;
        let child = this.template.querySelector('c-lwc_-handledocuments');
        child.HandleSavefromAura();
        //this.isShowMODTCOMP = true;
  }

  closeMODT(event){
    debugger;
    
  }
    

}