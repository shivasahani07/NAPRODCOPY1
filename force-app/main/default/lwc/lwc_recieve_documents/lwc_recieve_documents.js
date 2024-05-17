import { LightningElement, track, wire, api } from 'lwc';
import getDocumentCourierDetails from '@salesforce/apex/DocumentCourierDetailController.getDocumentCourierDetails';
import updateDocumentCourierDetails from '@salesforce/apex/DocumentCourierDetailController.markAsReceived';
import Child_components_Controller from '@salesforce/apex/Child_components_Controller.UpdateTaskStatus';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class Lwc_recieve_documents extends LightningElement {
    @api taskId;
    @api wrapperData;
    @api taskRec;
    @api initFunctionality = false;
    @api compIndex;
    @track awbNumber;
    @track enteredDocumentIdValue = '';
    @track showInformation = false;
    @track searchResults = [];
    @track maskeddatalist = [];
    @track newList = [];
    @track isHideCheckBoxInput = false;//for mask functionality, after enter the document number unmask and received? 
    @track isDocumentIdValueEditable = true;
    @track showreceive_button = false;
    @track isAllDocumentsSelected = false;
    @track documentRecords;
    @track Doc_array = [];
    @track documentRelatedCurrentTaskIds=[];

    connectedCallback(){
        this.doInitFromParentComp(this.taskRec);
    }

    doInitFromParentComp(taskRec){
        debugger;
        getDocumentCourierDetails({inp_Task:taskRec})
            .then(result => {
                if (result) {
                    console.log('result data', JSON.stringify(result));
                    const updatedDocuments = result.documents.map(document => {
                        if (result.paybles != null && result.paybles != undefined && result.paybles.length > 0) {
        
                            for (let j = 0; j < result.paybles.length; j++) {
                                if (document.Extended_SObject_RecordId__c === result.paybles[j].Id) {
                                    // Return a new object with the updated properties
                                    return {
                                        ...document,
                                        payeeName: result.paybles[j].Finacial_Entity_Details__r.Name,
                                        bankAccountNumber: result.paybles[j].Financial_Entity_A_C_Details__r.Bank_Account_Number__c,
                                        isChequeTrue: true,
                                        Amount__c: result.paybles[j].Amount__c,
                                        isCommentVisible: false,
                                        transfer_to_name: document.Transfer_To__r.Name,
                                        transfer_to_id: document.Transfer_To__r.Id,
                                    };
                                }
                            }
                        }
                        if (result.modtlist != null && result.modtlist != undefined && result.modtlist.length > 0) {
                            for (let k = 0; k < result.modtlist.length; k++) {
                                if (document.Extended_SObject_RecordId__c === result.modtlist[k].Id) {
                                    // Return a new object with the updated properties
                                    return {
                                        ...document,
                                        ismortager: true,
                                        mortager_name: result.modtlist[k].Mortgager_Name__r.Name,
                                        mortager_id: result.modtlist[k].Mortgager_Name__r.Id,
                                        isCommentVisible: false,
                                        executed_on_date: result.modtlist[k].Date_Of_Execution__c,
                                        excecution_place: result.modtlist[k].Place__c.street + ',' + result.modtlist[k].Place__c.state + ',' + result.modtlist[k].Place__c.country
                                    };
                                }
                            }
                        }
        
                        // If no match is found, return the original object
                        return document;
                    });
                    this.Doc_array = updatedDocuments;
                    const updatedDocumentsWithIndex = updatedDocuments.map((doc, index) => {
                        doc.index = index;
                        return doc;
                    });
                    // this.searchResults=updatedDocuments;
                    this.searchResultsByName(updatedDocumentsWithIndex);
                    this.getAll_tracking_numbers();

                    if(taskRec==null || taskRec==undefined){
                        this.showreceive_button=true;
                    }
        
                } else if (result.error) {
                    console.log(error.body.message);
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    searchResultsByName(tempsearchreasultarray) {
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
                    // tempobject.maskedDocumentIDValue = this.maskFirstLastLetters(tempsearchreasultarray[i].Document_Id_Value__c);
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
                    } else if (tempObj.category == 'MODT') {
                        tempObj.Headervalues = ["MODT Id.", "To Be Handed Over", "Mortager Name", "Execution Date", "Execution Place", "Status"];
                    } else {
                        tempObj.Headervalues = [tempsearchreasultarray[i].Document_Metadata__r.Document_Id_Name__c, "To Be Handed Over To", 'Select'];
                    }

                    var tempobject = JSON.parse(JSON.stringify(tempsearchreasultarray[i]));
                    tempobject.maskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                    // tempobject.maskedDocumentIDValue = this.maskFirstLastLetters(tempsearchreasultarray[i].Document_Id_Value__c);
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
                    tempObj.Headervalues = [tempsearchreasultarray[i].Document_Metadata__r.Document_Id_Name__c, "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "Select"];
                } else if (tempObj.category == 'MODT') {
                    tempObj.Headervalues = ["MODT Id.", "To Be Handed Over", "Mortager Name", "Execution Date", "Execution Place", "Status"];
                } else {
                    tempObj.Headervalues = [tempsearchreasultarray[i].Document_Metadata__r.Document_Id_Name__c, "To Be Handed Over To", 'Select'];
                }
                var tempobject = JSON.parse(JSON.stringify(tempsearchreasultarray[i]));
                tempobject.maskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                //tempobject.maskedDocumentIDValue = this.maskFirstLastLetters(tempsearchreasultarray[i].Document_Id_Value__c);
                tempobject.unmaskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                var innertemparry = [];
                innertemparry.push(tempobject);
                tempObj.documents = innertemparry;
                temparray.push(tempObj);
            }
        }
        //this.searchResults = temparray
        this.Doc_array = temparray;
        console.log('formdata--', JSON.stringify(this.searchResults));
    }
    trackingOptions=[];
    getAll_tracking_numbers(){
        debugger;
        const mySet = new Set();
        let dummaryArray=[]
        if(this.Doc_array.length>0){
            this.Doc_array.forEach(currentItem => {
                if (currentItem && currentItem.documents) {
                    let documents = currentItem.documents;
                    if(documents.length>0){
                         documents.forEach((item)=>{
                            if(item.Tracking_Number__c!=null){
                                mySet.add(item.Tracking_Number__c);
                            }
                         })
                    }
                }
            });
        }
         console.log('mySet',mySet)
         this.trackingOptions=Array.from(mySet).map(obj=>({'label':obj,'value':obj}));
         console.log('trackingOptions',this.trackingOptions);
    }

    handleDocumentIdValueChange(event) {
        debugger;
        let docId = event.target.value;
        var tempListWithOutDocId = JSON.parse(JSON.stringify(this.searchResults));
        for (var i = 0; i < tempListWithOutDocId.length; i++) {
            for (var j = 0; j < tempListWithOutDocId[i].documents.length; j++) {
                if (tempListWithOutDocId[i].documents[j].Document_Id_Value__c === docId) {
                    tempListWithOutDocId[i].documents[j].maskedDocumentIDValue = docId;
                } else {
                    tempListWithOutDocId[i].documents[j].maskedDocumentIDValue = this.maskFirstLastLetters(tempListWithOutDocId[i].documents[j].Document_Id_Value__c);
                }
                // Set the checkbox state based on the unmasked Document ID Value
                if (tempListWithOutDocId[i].documents[j].Document_Id_Value__c === docId) {
                    tempListWithOutDocId[i].documents[j].isChecked = true;
                    tempListWithOutDocId[i].documents[j].isDisabled = true;
                } else {
                    tempListWithOutDocId[i].documents[j].isChecked = false;
                    tempListWithOutDocId[i].documents[j].isDisabled = true; // Set all checkboxes disabled by default
                }
            }
        }
        this.searchResults = tempListWithOutDocId;
    }


    handleAwbNumberChange(event) {
        debugger;
        this.searchResults = this.Doc_array;
        let all_documents = [];
        this.awbNumber = event.target.value;
        this.showInformation = false;
        if (this.searchResults) {
            this.maskeddatalist = this.searchResults;

            this.searchResults.forEach(currentItem => {
                if (currentItem && currentItem.documents) {
                    let documents = currentItem.documents;
                    if (documents.find((item) => item.Tracking_Number__c == event.target.value)) {
                        let filteredDoc = documents.filter((result) => result.Tracking_Number__c != null && result.Tracking_Number__c != undefined && result.Tracking_Number__c == event.target.value);
                        let docObj = currentItem;
                        docObj.documents = filteredDoc;
                        all_documents.push(docObj);
                    }
                }
            });

            console.log('all_documents--', JSON.stringify(all_documents));

            let filteredArray = all_documents.filter(value => value !== null && value !== undefined);

            console.log('filteredArray--', JSON.stringify(filteredArray));

            this.searchResults = filteredArray;
            //this.searchResults = this.searchResults.filter(result => result.documents.Tracking_Number__c == this.awbNumber);
            if (this.maskeddatalist.length > 0) {
                this.showInformation = false;
                //this.searchResultsByName( this.maskeddatalist);
                this.isDocumentIdValueEditable = false;
            } else {
                this.showInformation = true;
                this.isDocumentIdValueEditable = true;
            }
        } else {
            alert('No Records Found')
        }
    }


    handleRemove() {
        debugger;
        this.awbNumber = '';
        this.searchResults = [];
        //this.searchResultsByName(this.searchResults);
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        this.activeSections = openSections;
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

    handleCheckboxChange(event) {
        debugger;
        let selectedRecordList = [];
        let selectedRecord = '';
        this.showButtonDispatch = true;
        let currentTaskIdset = new Set();

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
            this.documentRecords = selectedRecordList;

        }
        else {
            this.isDispatchButtonDisabled = true;
            this.isShippingPartnerDisabled = true;
            this.isAWBDisabled = true;
        }

        this.documentRecords.forEach(currentItem => {
            if (currentItem) {
                this.searchResults.forEach((item) => {
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
       
        console.log('selectedRecordList--->', JSON.stringify(selectedRecordList));
    }

    @api updateDcuRecordS() {
        debugger;
        //if (this.checkvalidation_before_update()) {
            updateDocumentCourierDetails({ documentIds: this.documentRecords })
                .then(result => {
                    if (result && result == 'success') {
                        if(this.taskRec!=null && this.taskRec!=undefined && this.taskRec.Id!=null && this.taskRec.Id!=undefined){
                            this.callEventToUpdateData(true);
                        }else{
                            if(this.documentRelatedCurrentTaskIds.length>0){
                                this.close_currentTaskIds_RelatedToDocuments();
                            }
                            location.reload();
                        }
                        
                    }
                })
                .catch(error => {
                    console.log('error', error);
                })
       /* } else {
            const evt = new ShowToastEvent({
                title: "Title",
                message: 'Please Select All Records',
                variant: "Error",
            });
            this.dispatchEvent(evt);
        }*/

    }

    close_currentTaskIds_RelatedToDocuments(){
        debugger;
         Child_components_Controller({ApproverStatus:'Completed',TaskIdset:this.documentRelatedCurrentTaskIds})
         .then(result=>{

         })
         .catch(error=>{

         })
    }

    checkvalidation_before_update() {
        let shouldSkip = false;
        let singleColumnCheckbox = this.template.querySelectorAll('lightning-input[data-key="singleSelectColumnCheckbox"]');
        singleColumnCheckbox.forEach(row => {
            if (shouldSkip) { return; }
            if (row.type == 'checkbox' && row.checked) {
                shouldSkip = false;
            } else {
                shouldSkip = true;
            }
        });
        return shouldSkip == true ? false : true;
    }

    callEventToUpdateData(is_closed_boolean) {
        debugger;
        const event = new CustomEvent('valuechange', {
            detail: {
                isclosed: is_closed_boolean,
                index: this.compIndex
            }
        });
        this.dispatchEvent(event);
    }

}