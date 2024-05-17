import { LightningElement, api, wire, track } from 'lwc';
import docsWithdetails from '@salesforce/apex/DocumentCourierDetailController.docsWithdetails';
import updateDocumentCourierDetails from '@salesforce/apex/DocumentCourierDetailController.markAsReceived';
import updateDocumentRecord from '@salesforce/apex/DocumentCourierDetailController.updateDocumentRecord';
import chequecancellationreason from '@salesforce/label/c.Cheque_Cancellation_Reason';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class Lwc_hocument_handedover extends LightningElement {

    @api taskId;
    @api masterTaskId;
    @api validaStatusValue = 'To Be Handed Over';
    @api initFunctionality = false;
    @api compIndex;
    @api taskRec;
    @api UploadtaskId
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
    @track ChequeCancellation_Reasons=[];
    @track isShowMODTCOMP=false;
    @api currentRecordId;
    @api currentRecordindex;
    @api isTaskOwnerLogin;

    connectedCallback() {
        debugger;
        console.log('taskId',this.taskId);
        this.UploadtaskId=this.taskId;
        console.log('UploadtaskId',this.UploadtaskId);
        
         console.log('taskRec',JSON.stringify(this.taskRec));
        this.doInitFromParentComp(this.taskRec);
    }

    async doInitFromParentComp(taskRec) {
        debugger;
        try {
            this.taskId = taskRec.Id;
            const response = await docsWithdetails({ inp_Task: taskRec });
            const { paybles, modtlist } = response;
            console.log('response--->',JSON.stringify(response));
            const updatedDocuments = response.documents.map(document => {
                const payble = paybles.find(payble => document.Extended_SObject_RecordId__c === payble.Id);
                const modt = modtlist.find(modt => document.Extended_SObject_RecordId__c === modt.Id);
    
                if (payble) {
                    return {
                        ...document,
                        payeeName: payble.Finacial_Entity_Details__r.Name,
                        bankAccountNumber: payble.Financial_Entity_A_C_Details__r.Bank_Account_Number__c,
                        isChequeTrue: true,
                        Amount__c: payble.Amount__c,
                        isCommentVisible: false,
                        isDocumentRequired: false,
                        Task_Id__c:document.Task_Id__c,
                        isdocument_closed:false
                    };
                } else if (modt) {
                    return {
                        ...document,
                        ismortager: true,
                        mortager_name: modt.Mortgager_Name__r.Name,
                        mortager_id: modt.Mortgager_Name__r.Id,
                        isCommentVisible: false,
                        executed_on_date: modt.Date_Of_Execution__c,
                        Task_Id__c:document.Task_Id__c,
                        excecution_place: `${modt.Place__c.street}, ${modt.Place__c.state}, ${modt.Place__c.country}`,
                        isdocument_closed:false
                    };
                } else {
                    return document;
                }
            });
    
            const updatedDocumentsWithIndex = updatedDocuments.map((doc, index) => {
                doc.index = index;
                return doc;
            });
    
            this.documentsList = updatedDocumentsWithIndex.filter(doc => doc.Status__c === this.validaStatusValue);
            this.searchResultsByCategoryv1(this.documentsList);
        } catch (error) {
            console.error('An error occurred:', error);
        }
    }
    
    get options() {
        return [
            { label: 'Handed Over Successfully', value: 'Handed Over Successfully' },
            { label: 'Request Cancellation', value: 'Request Cancellation' },
        ];
    }

    @track selectedCurrentStatus
    statusHandler(event) {
        debugger;
        let SelectedDocId = event.target.dataset.id;
        let currentStatus = event.target.value;
        let tempList = this.maskeddatalist;
        let updatedStatusCount = 0; // Track the number of status updates
        let updatedVisibilityCount = 0; // Track the number of visibility updates
        this.selectedCurrentStatus = currentStatus;
        tempList.forEach(category => {
            category.documents.forEach(document => {
                if (document.Id === SelectedDocId) {
                    document.status = currentStatus;
                    if(document.status == 'Request Cancellation'){
                        document.isCommentVisible = true;
                        document.isDocumentRequired = true;
                        document.substatusOption = chequecancellationreason.split(",").map(obj=>({'label':obj,'value':obj}));;
                    }else{
                        document.isCommentVisible = false;
                         document.isDocumentRequired = false;
                    }
                    
                }
            });
        });

        this.maskeddatalist = tempList;
        this.updatedeWithStatsDocumentsList = tempList;
        console.log(`Updated ${updatedStatusCount} records with new status.`);
        console.log(`Updated ${updatedVisibilityCount} records with visibility change.`);
    }

    substatusHandler(event) {
        debugger;
        let SelectedDocId = event.target.dataset.id;
        let currentStatus = event.target.value;
        let tempList = this.maskeddatalist;

        tempList.forEach(category => {
            category.documents.forEach(document => {
                if (document.Id === SelectedDocId) {
                    document.Sub_Status__c = currentStatus;
                }
            });
        });
        this.maskeddatalist = tempList;
        this.updatedeWithStatsDocumentsList = tempList;
    }


    handleCommentChage(event) {
        debugger;
        let cuurentComment = event.target.value;
        let SelectedDocId = event.target.dataset.id;
        let tempList = this.maskeddatalist;
        //let tempList = this.updatedeWithStatsDocumentsList;
        tempList.forEach(category => {
            console.log('Category:', category.category);
            category.documents.forEach(document => {
                if (document.Id == SelectedDocId) {
                    document.comment = cuurentComment;
                }

            });
        });
        this.maskeddatalist=tempList;
        this.updatedeWithStatsDocumentsList = tempList
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
                    tempobject.maskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c
                    tempobject.unmaskedDocumentIDValue = tempsearchreasultarray[i].Document_Id_Value__c

                    findresultdocarray.push(tempobject);
                    var tempfindresult = JSON.parse(JSON.stringify(findresult));
                    tempfindresult.documents = findresultdocarray;
                    temparray[index] = tempfindresult;
                } else {
                    var tempObj = {};
                    tempObj.category = tempsearchreasultarray[i].Document_Metadata__r.Document_Name__c;
                    if (tempObj.category == 'CheckList') {
                        tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "Status", "Comment"];
                    } else if (tempObj.category == 'Cheque') {
                        tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "Status","Sub Status"];
                    }else if (tempObj.category.includes("MODT")) {
                        tempObj.Headervalues = ["MODT Id.", "Hand Over To", "Mortager Name", "Execution Date", "Execution Place", "Status"];
                    }
                    else {
                        tempObj.Headervalues = ["Document No.", "Hand Over To", "Status"];
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
                if (tempObj.category == 'CheckList') {
                    tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "Status", "Comment"];
                } else if (tempObj.category == 'Cheque') {
                    tempObj.Headervalues = ["Cheque No.", "Hand Over To", "Payee Name", "Bank Account No.", "Amount", "Status","Sub Status"];
                }else if (tempObj.category.includes("MODT")) {
                    tempObj.Headervalues = ["MODT Id.", "Hand Over To", "Mortager Name", "Execution Date", "Execution Place", "Status"];
                }
                else {
                    tempObj.Headervalues = ["Document No.", "Hand Over To", "Status"];
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
        this.maskeddatalist = temparray;
        console.log('formdata--', JSON.stringify(this.maskeddatalist));
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

    @api updateDcuRecordS(event) {
        debugger;
        let tempDocumentObjectList = [];
        //if (confirm("are you sure do want to submit!") == true) {
            this.maskeddatalist.forEach(category => {
                console.log('Category:', category.category);
                category.documents.forEach(document => {
                    let tempDocumentObject = {};
                    tempDocumentObject.Id = document.Id;
                    tempDocumentObject.Status__c = document.status;
                    tempDocumentObject.Comment_History__c = document.comment!==undefined || document.comment!==null?document.comment:null;
                    tempDocumentObject.Sub_Status__c= document.Sub_Status__c!==undefined || document.Sub_Status__c!==null?document.Sub_Status__c:null;
                    tempDocumentObject.isdocument_closed=document.isdocument_closed;
                    tempDocumentObjectList.push(tempDocumentObject);
                });
            });
            if(this.checkValidationBeforeUpdate(tempDocumentObjectList)){
                tempDocumentObjectList.forEach((item)=>{
                    delete item.isdocument_closed;
                })
                updateDocumentRecord({ docTobeUpdated: tempDocumentObjectList })
                .then(response => {
                   // alert('done---');
                      this.sendClosedStatementToParent(true);
                })
                .catch(error => {
                   // alert('error---');
                    console.error('An error occurred:', error.body.message);
                });
            }else{   
            }
        // } else {
        //     return;
        // }

    }

    checkValidationBeforeUpdate(tempDocumentObjectList){
        debugger;
        let shouldskip=false;
        if(tempDocumentObjectList.length>0){
            tempDocumentObjectList.forEach((item)=>{
                if(shouldskip){return}
                if(item.Status__c==null || item.Status__c == undefined || item.Status__c==''){
                    shouldskip=true 
                    this.showToastmessage('Please Select Status For All the Documents','error') 
                    return
                }
                if(item.Status__c == 'Request Cancellation' && (item.Sub_Status__c!=null && item.Sub_Status__c!=undefined && item.Sub_Status__c!='')){
                      if(item.Status__c == 'Request Cancellation' && item.Sub_Status__c && item.isdocument_closed==false){
                        shouldskip=true;
                        this.showToastmessage('Document Upload is Mandatory','error');
                            // const event = new ShowToastEvent({
                            //     title: 'Alert',
                            //     message: 'Document Upload is Mandatory',
                            //     variant: 'warning',
                            //     });
                            // this.dispatchEvent(event);
                      }
                }else if(item.Status__c == 'Request Cancellation' && (item.Sub_Status__c==null || item.Sub_Status__c==undefined && item.Sub_Status__c=='')){
                    shouldskip=true;
                    this.showToastmessage('Sub Status Is Mandatory','error');
                    // const event = new ShowToastEvent({
                    //     title: 'Alert',
                    //     message: 'Sub Status Is Mandatory',
                    //     variant: 'warning',
                    //     });
                    // this.dispatchEvent(event);
                }
            })
        }
        return shouldskip==false?true:false;
    }


    showToastmessage(message,variant){
        const event = new ShowToastEvent({
            title: 'Alert',
            message: message,
            variant: variant,
            });
        this.dispatchEvent(event);
    }

    sendClosedStatementToParent(isClosed) {
        debugger;
        //alert("Final Closed Method is Fired")
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: {
                "isclosed": isClosed,
                "index": this.compIndex
            }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }

    @track ExtendedSObjectRecordId;
    physicallyVerifyBabkDetails(event){
        debugger;
        let currentValue = event.target.value;
        let currentReccordId = event.target.dataset.id;
        let recordTaskId=event.target.dataset.mastertaskid;
        this.masterTaskId=recordTaskId;
        let currentReccordIndex=event.target.dataset.index;
        this.currentRecordId=currentReccordId;
        this.currentRecordindex=currentReccordIndex;
        this.ExtendedSObjectRecordId=event.target.dataset.extendedsobjectid;
        this.isShowMODTCOMP=true;
    }
    backTomodt(event){
        debugger;
        this.isShowMODTCOMP = false;
    }

    callDocumentHandlerFinalSubmit() {
        debugger;
        let child = this.template.querySelector('c-lwc_-handledocuments');
        child.HandleSavefromAura();
    }

     closeMODT(event) {
        debugger;
        let index = event.detail.index;
        let recordId = event.detail.extendedsobjId;
        let isDocumentClosed = event.detail.child_isclosed;
        if (isDocumentClosed) {
            this.maskeddatalist.forEach(category => {
                category.documents.forEach(document => {
                    if(document.index==index){
                        document.isdocument_closed=isDocumentClosed;
                    }
                })
            })
        } else {
           // this.handleHighlightRow(this.maskeddatalist,index);  
        }
    }

}