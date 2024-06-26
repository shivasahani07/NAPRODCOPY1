import { LightningElement, api, wire, track } from 'lwc';
import getDocumentHandler from '@salesforce/apex/lwc_Handledocuments_Controller.getDocumentHandler';
import upsertDocumentHandler from '@salesforce/apex/lwc_Handledocuments_Controller.UpsertDocumentHandler';
import { NavigationMixin } from 'lightning/navigation'
import uploadFile from '@salesforce/apex/lwc_Handledocuments_Controller.uploadFile';
import insertTaskforReview from '@salesforce/apex/lwc_Handledocuments_Controller.insertTaskforReview';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import createFile from '@salesforce/apex/ProposalDocumentLWCController.createFile';
import update_dh_status from '@salesforce/apex/lwc_Handledocuments_Controller.update_dh_status';
import UpdateDMSId from '@salesforce/apex/lwc_Handledocuments_Controller.UpdateDMSId';

import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import TaskLabel from '@salesforce/label/c.Document_Handler_Status_Exempted';
import getRelatedtasks from '@salesforce/apex/reviewerLookupController.getRelatedtasks';
export default class Lwc_Handledocuments extends NavigationMixin(LightningElement) {

    label = { TaskLabel };


    @api recordId;
    @api initFunctionality;
    @api extendedSobjectRecordId;
    @api index
    @api isEdit;
    @api taskRec;
    @api documentSharingtaskid;
    @api isGrandChild = false;
    @api UploadtaskId;


    @track getDocumentHandlerRecords = [];
    @track getPADD = [];
    @track getloginuser_RelatedGroups = [];
    @track getchild_tasklist = [];
    @track selectedPADD = [];
    @track DHrecordsToInsert = [];
    @track DocumentList = [];
    @track contentIdRelatedToDocument = [];
    @track docHandlerhistory = [];
    @track AddDocumentHandler = false;
    @track addComments = false;
    @track UploadDocument = false;
    @track showReviewRecord = false;
    @track fileuploaddisable = true;
    @track save_disable_enable = false;
    @track ReviewDeviation = false;
    @track ApproveDisable = true;
    @track RejectDisable = false;
    @track disableAdddocument = true;
    @track isValidationRequired;
    @track comments;
    @track addCommentonRecordid;
    @track docmetaid;
    fileData
    @track Reviewrecord;
    @track contentmessage = '';
    @track fileName;
    @track loginuserId;
    @track isChildtask
    @track commentHistory;
    @track SelectedRecordForDeviation;
    @track currentTkRecord;
    @track tkdisable = false;
    @track sladisable = false;
    @track Exempteddisable = false;
    @track uploaddisable = false;
    @track isall_documents_closed = false;
    @track isAssociated_to_this_process = false;
    @track userId = Id;
    @track currentUserName;
    @track disabledeviation = false;
    @track today;
    @track documentUploadtaskid;
    @track DocumentUploadOn_DHrecord;
    @track sharepointurlLink;

    @track cssclasslist = ['slds-hint-parent blink', 'slds-hint-parent'];
    @track uploadDocButtonEnableVisibilityStatus = ['Draft', 'Submit For Review', 'Received', 'Uploded'];
    @track uploadDocButtonDisableVisibilityStatus = ['Submited For Review', 'Submitted for Devaition Approval'];
    @track recordStatusForDeviation = ['Draft', 'Document Upload Pending', 'Physical Document Pending'];
    @track reviewerButtonEnableVisibityStatus = ['Submit For Review'];
    @track reviewerButtonDisableVisibityStatus = ['Submited For Review', 'Submitted for Deviation Approval'];
    @track getIsNewDocumentAsPerStatus = ['Draft'];
    @track DeviationButtonvisibilityAsperStatus = ['Draft', 'Deviation Approved', 'Deviation Rejected'];
    @track ReviewButtonvisibilityAsperStatus = ['Draft', 'Approved']
    @track reviewerbutton_status_show_hide = ['Submited For Review'];
    @track deviationbutton_status_show_hide = ['Submitted for Deviation Approval'];
    @track physicalcheckboxEnable = ['Draft', 'Submit For Review', 'Received', 'Physical Document Pending'];
    @track Document_closed_status = ['Received', 'Approved', 'Exempted']
    @track Partially_Document_closed_status = ['Alternate Document Added']


    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD] })
    currentUserInfo({ error, data }) {
        debugger;
        if (data) {
            this.currentUserName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        debugger;
        this.isValidationRequired = this.isGrandChild == "true" ? false : true;
        this.documentUploadtaskid = this.UploadtaskId != null && this.UploadtaskId != undefined ? this.UploadtaskId : this.recordId;
        const date = new Date();
        date.setDate(date.getDate() + 1);
        let day = date.getDate();
        let month = date.getMonth() + 1;
        let year = date.getFullYear();
        let currentDate = `${year}-${month}-${day}`;
        this.today = currentDate
        this.getDocumentHandleRecords();
        this.getsobjectRecords();
    }

    @api checkStatusOnLoad() {
        debugger;
        console.log('initFunctionality::' + this.initFunctionality);
    }

    getDocumentHandleRecords() {
        debugger;
        getDocumentHandler({ TaskId: this.recordId, extendedSobjectRecordid: this.extendedSobjectRecordId, documentsharingTaskId: this.documentSharingtaskid })
            .then(result => {
                if (result != null && result != undefined) {
                    let DHList = result.ListDH;
                    DHList.forEach((element) => {
                        element.showPreview = true;
                        element.showDocUpload = true;
                        element.showreview = true;
                        element.showcomment = false;
                        element.newuploadedDoc = null;
                        element.fileuploadcount = 0;
                        if (element.Physical_Document_Mandatory__c == true && this.isEdit == true && ['Exempted', 'Approved', 'Submited For Review', 'Submitted for Deviation Approval', 'Alternate Document Added'].includes(element.Status__c) == false) {
                            element.isphysicaldocneed = false;
                        } else {
                            element.isphysicaldocneed = true;
                        }
                        element.isVisibleshowDocUpload = true
                        element.isVisibleshowreview = true
                        element.isReviewerVisible = false
                        element.isDeviationVisible = false
                        element.deviationdisable = true
                        element.reviewerdisable = true
                        element.isdocumentIdDisable = this.isEdit == true ? false : true;
                        element.isdisable_Alternatedocument = true;
                        element.isshowInfo = element.Process_Attribute_Dcoument_Detail__c != undefined && element.Process_Attribute_Dcoument_Detail__c != null && element.Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c == false ? true : false;
                        element.cssclass = 'slds-hint-parent';
                    })
                    this.getDocumentHandlerRecords = DHList;
                    this.getPADD = result.PADD;
                    this.getloginuser_RelatedGroups = result.currentUserRelated_Groups;
                    this.getchild_tasklist = result.parent_childtasklist_ifexist;
                    this.loginuserId = result.loginuserId;
                    this.isChildtask = result.isChildtask;
                    this.currentTkRecord = result.ParentTaskRecord;
                    this.docHandlerhistory = result.DocHandlerHistory;
                }
                this.save_disable_enable = result.isChildtask == true ? true : false;
                for (let key in result.DocumentList) {
                    this.contentIdRelatedToDocument.push({ key: key, value: result.DocumentList[key] });
                }
                this.checkcurrentUser_is_Reviewer_parentkowner_viewer();
                result.isChildtask == true ? this.checkDHhandlerVisibityAsperLoginUser() : 'Parent Task';
                this.checkForButtonsVisibilityAsPerDocumet();
                this.checkbuttonVisibilityAsPerStatus();
                console.log('contentIdRelatedToDocument--' + JSON.stringify(this.contentIdRelatedToDocument));
            })
            .catch(error => {
                console.log('Errorured:- ' + error);
            });
    }

    check_is_all_documents_closed() {
        debugger;
        let shouldSkip = false;
        if (this.getDocumentHandlerRecords.length > 0) {
            this.getDocumentHandlerRecords.forEach(currentItem => {
                if (currentItem && currentItem.Status__c != null && currentItem.Status__c != undefined) {
                    if (shouldSkip) {
                        return;
                    }
                    if (this.Document_closed_status.includes(currentItem.Status__c) == false && this.Partially_Document_closed_status.includes(currentItem.Status__c) == false) {
                        this.isall_documents_closed = false;
                        shouldSkip = true;
                        return;
                    } else {
                        this.isall_documents_closed = true;
                    }
                }
            });
        }
    }

    @track tkReviewer = false;
    @track tkDeviationReviewer = false;
    @track tkCreator = false;

    //Here To Find the status Of the Login user 1.Creator 2.Viewer 3.Reviewer/Approver 
    checkcurrentUser_is_Reviewer_parentkowner_viewer() {
        debugger;
        let tkrecord;
        let tkcreator = false;
        let shouldSkip = false;
        if (this.loginuserId != null) {
            if (this.currentTkRecord != null && this.currentTkRecord.OwnerId != null) {
                if (this.currentTkRecord.OwnerId.startsWith('00G') && this.getloginuser_RelatedGroups.includes(this.currentTkRecord.Owner.Name)) {
                    tkcreator = true;
                    tkrecord = this.currentTkRecord;
                } else if (this.currentTkRecord.OwnerId.startsWith('005') && this.currentTkRecord.OwnerId == this.loginuserId) {
                    tkcreator = true;
                    tkrecord = this.currentTkRecord;
                }
            }
            if (tkcreator == false) {
                if (this.getchild_tasklist.length > 0) {
                    this.getchild_tasklist.forEach(currentItem => {
                        if (currentItem) {
                            if (shouldSkip) {
                                return;
                            }
                            if (currentItem.OwnerId != null && currentItem.OwnerId.startsWith('00G') && this.getloginuser_RelatedGroups.includes(currentItem.Owner.Name) && (currentItem.Status == 'Submited For Review' || currentItem.Status == 'Submitted for Deviation Approval')) {
                                tkrecord = currentItem
                                shouldSkip = true;
                                return;
                            } else if (currentItem.OwnerId != null && currentItem.OwnerId.startsWith('005') && currentItem.OwnerId == this.loginuserId && (currentItem.Status == 'Submited For Review' || currentItem.Status == 'Submitted for Deviation Approval')) {
                                tkrecord = currentItem
                                shouldSkip = true;
                                return;
                            }
                        }
                    });
                }
            }
            if (tkrecord != null && tkrecord != undefined) {
                console.log('tkrecord',JSON.stringify(tkrecord));
                if (tkrecord.Status != null) {
                    if (tkrecord.Status == 'Open' && tkcreator == true) {
                        this.disableAdddocument = this.isGrandChild == false ? false : true;
                        this.isAssociated_to_this_process = true;
                        this.tkCreator = tkcreator
                    } else if (tkrecord.Status == 'Submited For Review') {
                        //this.disableAdddocument = false;
                        this.disableAdddocument = this.isGrandChild == false ? false : true;
                        this.isAssociated_to_this_process = true;
                          this.tkReviewer = true;
                    } else if (tkrecord.Status == 'Submitted for Deviation Approval') {
                        //this.disableAdddocument = false;
                        this.disableAdddocument = this.isGrandChild == false ? false : true;
                        this.isAssociated_to_this_process = true;
                        this.tkDeviationReviewer = true;
                    } else if (tkrecord.Status == 'Completed' || tkrecord.Status == 'Rejected') {
                        this.disableAdddocument = true;
                        this.isAssociated_to_this_process = false;
                    }
                }
            } else {
                this.disableAdddocument = true;
                this.isAssociated_to_this_process = false;
            }
        }

    }

    //Call this Method from Parent Component i.e. CMP_TaskMaster to call the save Button Functionality
    @api HandleSavefromAura() {
        debugger;
        this.Handleonclick(false);
    }

    //For All the Buttons exist in this component, As per the data-label Methods will be Implemented
    Handleonclick(event) {
        debugger;
        let buttonlabel
        if (event) {
            buttonlabel = event.currentTarget.dataset.label;
        } else {
            buttonlabel = 'UpdateDocumentHandler';
        }
        if (this.AddDocumentHandler == false && buttonlabel == 'AddDocuments') {
            this.AddDocumentHandler = true;
            this.closehighlightbar();
            this.checkDocumentExist();
            this.selectedPADD = [];
            this.handledisableAddDocument = this.selectedPADD.length > 0 ? false : true;
        } else if (this.AddDocumentHandler == true && buttonlabel == 'CancelAddDocuments') {
            this.AddDocumentHandler = false;
        } else if (buttonlabel == 'AddToDocumentsHandler') {
            if (this.selectedPADD.length > 0) {
                this.createDocumentHandlerJson(this.selectedPADD);
                if (this.DHrecordsToInsert.length > 0) {
                    console.log('Call Apex To Create DH Record');
                    this.UpsertDHRecords(this.DHrecordsToInsert, 'Insert/UpsertDocHandler');
                }
            }
        } else if (this.addComments == false && buttonlabel == 'AddComment') {
            this.closehighlightbar();
            this.addComments = true;
            this.addCommentonRecordid = event.target.accessKey;
            this.comments = '';
            this.commentHistory = '';
            this.commentHistory = this.getDocumentHandlerRecords.find(item => item.Id == this.addCommentonRecordid).Description__c;
        } else if (this.addComments == true && buttonlabel == 'AssignComment') {
            this.commentHandler();
        } else if (buttonlabel == 'UpdateDocumentHandler') {

            if (this.isValidationRequired) {
                if (this.checkvalidationforDeviation()) { //
                    if (this.checkvalidationsForDocumentIdvalue()) {
                        if (this.checkvalidationsIsNewDocument()) {
                            if (this.checkValidationsForReview(this.getDocumentHandlerRecords, 'On_Save')) {
                                if (this.checkDocumentApprovalPending()) {
                                    this.updateDhRecordStatus_If_Validations(this.getDocumentHandlerRecords);
                                    if (this.DHrecordsToInsert.length > 0) {
                                        console.log('Call Apex To Upsert DH Record');
                                        this.UpsertDHRecords(this.DHrecordsToInsert, 'Insert/UpsertDocHandler');
                                    }
                                    this.check_is_all_documents_closed();
                                    if (this.isall_documents_closed && this.getDocumentHandlerRecords.length > 0) {
                                        this.callEventToUpdateData(this.isall_documents_closed);
                                    } else if (this.isall_documents_closed == false && this.getDocumentHandlerRecords.length > 0) {
                                        this.contentmessage = 'Still Documents are not Closed';
                                    } else if (this.getDocumentHandlerRecords.length == 0) {
                                        this.callEventToUpdateData(this.isall_documents_closed);
                                    }
                                } else {
                                    this.contentmessage = 'Documents are Pending For Approval';
                                }
                            } else {
                                this.contentmessage = 'Submit Documents For Review';
                            }
                        } else {
                            this.contentmessage = 'Please Upload New Versions of the higlighted Documents';
                        }
                    } else {

                    }
                } else {

                }
            } else {
                this.callEventToUpdateData(true);
                // this.check_is_all_documents_closed();
                // if (this.isall_documents_closed && this.getDocumentHandlerRecords.length > 0) {
                //     this.callEventToUpdateData(this.isall_documents_closed);
                // }  else if (this.getDocumentHandlerRecords.length == 0) {
                //     this.callEventToUpdateData(this.isall_documents_closed);
                // }
            }

            // if (this.DHrecordsToInsert.length > 0) {
            //     console.log('Call Apex To Upsert DH Record');
            //     this.UpsertDHRecords(this.DHrecordsToInsert, 'Insert/UpsertDocHandler');
            // }
        } else if (buttonlabel == 'CancelAssignComment') {
            this.addComments = false;
        } else if (buttonlabel == 'UploadDocumentIcon') {
            this.closehighlightbar();
            this.docmetaid = event.target.accessKey;
            this.UploadDocument = true;
            this.DocumentUploadOn_DHrecord = this.getDocumentHandlerRecords.find(item => item.Id === this.docmetaid);
        } else if (buttonlabel == 'CancelUpload') {
            this.UploadDocument = false;
            this.DocumentUploadOn_DHrecord = '';
        } else if (buttonlabel == 'UploadDocument') {
            if(this.sharepointurlLink!=null && this.sharepointurlLink!=undefined && this.sharepointurlLink!=''){
                let selectedRecord = this.getDocumentHandlerRecords.find(item => item.Id == this.docmetaid);
                this.UploadDocumentOnDH(selectedRecord);
                this.fileuploaddisable = true;
            }else{
                if (this.checkvalidationForsameFilename(this.docmetaid)) {
                    this.fileuploaddisable = true;
                    let selectedRecord = this.getDocumentHandlerRecords.find(item => item.Id == this.docmetaid);
                    this.UploadDocumentOnDH(selectedRecord);
                } else {
                    this.showNotification('ERROR', 'File with Existing FileNames are Not Allowed To Upload', 'error');
                    this.fileuploaddisable = true;
                }
            }
        } else if (buttonlabel == 'PreviewDocuments') {
            this.closehighlightbar();
            this.DocumentList = [];
            this.docmetaid = event.target.accessKey
            this.createDocumentlistToPreview(this.docmetaid);
        } else if (buttonlabel == 'CancelshowDocuments') {
            this.DocumentList = [];
        } else if (buttonlabel == 'CreateReviewTask') {
            let ReviewerArray = [];
            this.closehighlightbar();
            let selectedRecId = event.target.accessKey;
            this.Reviewrecord = this.getDocumentHandlerRecords.find(item => item.Id == selectedRecId);
            ReviewerArray.push(this.Reviewrecord);
            let isvalidationsuccessonReviewer = ReviewerArray.length > 0 ? this.checkValidationsForReview(ReviewerArray, 'On_Review') : 'No Record Selected For review';
            this.showReviewRecord = isvalidationsuccessonReviewer == true ? true : false;

        } else if (buttonlabel == 'CancelReview') {
            this.showReviewRecord = false;
        } else if (buttonlabel == 'CreateReview') {
            this.HandleReviewerCreation();
        } else if (buttonlabel == 'CloseErrorMessage') {
            this.contentmessage = '';
        } else if (buttonlabel == 'createDeviation_UpsertDH') {
            this.disabledeviation = true;
            this.updateDocumentHandlerJson(this.DeviationApprovalRecords);
            if (this.DHrecordsToInsert.length > 0) {
                console.log('Call Apex To Upsert DH Record');
                this.UpsertDHRecords(this.DHrecordsToInsert, 'UpsertDocHandlerDeviation');
            }
        } else if (buttonlabel == 'cancelDeviation_UpsertDH') {
            this.DeviationApprovalRecords = [];
        } else if (buttonlabel == 'ReviewerApproved') {

            let recId = event.currentTarget.dataset.id
            let selectedrecId = this.getchild_tasklist.find(item => item.Review_Record_Id__c == recId && item.Subject.includes('Deviation') == false && item.IsClosed == false);
            let dhrecord = this.getDocumentHandlerRecords.find((item) => item.Id == selectedrecId.Review_Record_Id__c);
            if (dhrecord != null) { dhrecord.Status__c = 'Approved' }
            this.update_reviewer_deviation_approver(dhrecord, selectedrecId.Id, 'Approved');
        } else if (buttonlabel == 'ReviewerReAssign') {

            let recId = event.currentTarget.dataset.id
            let selectedrecId = this.getchild_tasklist.find(item => item.Review_Record_Id__c == recId && item.Subject.includes('Deviation') == false && item.IsClosed == false);
            let dhrecord = this.getDocumentHandlerRecords.find((item) => item.Id == selectedrecId.Review_Record_Id__c);
            if (dhrecord != null) { dhrecord.Status__c = 'Draft' }
            this.update_reviewer_deviation_approver(dhrecord, selectedrecId.Id, 'Rejected');
        } else if (buttonlabel == 'deviationApproved') {

            let recId = this.SelectedRecordForDeviation.Id;
            let selectedrecId = this.getchild_tasklist.find(item => item.Review_Record_Id__c == recId && item.Subject.includes('Deviation') == true && item.IsClosed == false);
            this.prepareDataforDeviation();
            if (this.SelectedRecordForDeviation.Task_Id__c != null) {
                this.SelectedRecordForDeviation.Status__c = 'Draft';
            }
            if (this.SelectedRecordForDeviation.Document_SLA__c != null) {
                this.SelectedRecordForDeviation.Status__c = 'Draft';
            }
            if (this.SelectedRecordForDeviation.Exempted__c) {
                this.SelectedRecordForDeviation.Status__c = 'Exempted';
            }
            this.update_reviewer_deviation_approver(this.SelectedRecordForDeviation, selectedrecId.Id, 'Approved');
        } else if (buttonlabel == 'deviationRejected') {

            let recId = this.SelectedRecordForDeviation.Id;
            let selectedrecId = this.getchild_tasklist.find(item => item.Review_Record_Id__c == recId && item.Subject.includes('Deviation') == true && item.IsClosed == false);
            this.prepareDataforDeviation();
            this.SelectedRecordForDeviation.Status__c = 'Draft';

            this.update_reviewer_deviation_approver(this.SelectedRecordForDeviation, selectedrecId.Id, 'Rejected');
        } else if (buttonlabel == 'ReviewDeviation_Approve_Reject') {
            let selectedRecId = event.currentTarget.dataset.id;
            this.SelectedRecordForDeviation = this.getDocumentHandlerRecords.find((item) => item.Id === selectedRecId);
            this.ReviewDeviation = true;
        } else if (buttonlabel == 'Canceldeviation') {
            this.ReviewDeviation = false;
            this.SelectedRecordForDeviation = null;
        }
    }

    checkvalidationsForDocumentIdvalue() {
        debugger;
        let shoulskip = false;
        this.getDocumentHandlerRecords.forEach((item) => {
            if (item.Document_Metadata__c && item.Document_Metadata__r.Is_DocumentId_Mandatory__c && (item.Document_Id_Value__c == null || item.Document_Id_Value__c == undefined || item.Document_Id_Value__c == '')) {
                item.cssclass = 'slds-hint-parent blink';
                this.contentmessage = 'Document Id Is Mandatory';
                shoulskip = true;
            }
        })
        return shoulskip == false ? true : false;
    }

    checkvalidationForsameFilename(documentId) {
        debugger;
        let getdocHistroryRecord = this.docHandlerhistory.map(makeSweeter => {
            if (makeSweeter.Document_Handler__c == documentId && makeSweeter.File_Name__c == this.fileData.filename) {
                return makeSweeter;
            }
        });
        getdocHistroryRecord = getdocHistroryRecord.filter(value => value !== null && value !== undefined);
        console.log('getdocHistroryRecord', getdocHistroryRecord);
        return getdocHistroryRecord.length > 0 ? false : true
    }

    //Checks which document are Pending for Approval/Review
    checkDocumentApprovalPending() {
        debugger;
        let pendingApproval = [];
        if (this.getDocumentHandlerRecords.length > 0) {
            this.getDocumentHandlerRecords.forEach(currentItem => {
                if (currentItem) {
                    if (currentItem.Status__c != null && this.reviewerButtonDisableVisibityStatus.includes(currentItem.Status__c) == true) {
                        currentItem.cssclass = 'slds-hint-parent blink';
                        pendingApproval.push(currentItem);
                    }
                }
            });
        }
        return pendingApproval.length > 0 ? false : true;
    }

    //Used For - Assigning the values for the selected Review Deviation Record
    prepareDataforDeviation() {
        debugger;
        const date = new Date();
        let currentDate = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
        if (this.SelectedRecordForDeviation != null && this.SelectedRecordForDeviation != undefined) {
            if (this.SelectedRecordForDeviation.selectedTaskId != null && this.SelectedRecordForDeviation.selectedTaskId != undefined) {
                this.SelectedRecordForDeviation.Task_Id__c = this.SelectedRecordForDeviation.selectedTaskId;
            }
            if (this.SelectedRecordForDeviation.updatedSladate != null && this.SelectedRecordForDeviation.updatedSladate != undefined) {
                this.SelectedRecordForDeviation.Document_SLA__c = this.SelectedRecordForDeviation.updatedSladate;
            }
        }
    }

    //Used For - As per document Uploded count Disable/Enable Preview Button
    checkForButtonsVisibilityAsPerDocumet() {
        debugger;
        //If File was Uploaded For the Document Handlers
        if (this.contentIdRelatedToDocument.length > 0) {
            for (let i = 0; i < this.contentIdRelatedToDocument.length; i++) {
                this.getDocumentHandlerRecords.find((item) => {
                    if (item.Id == this.contentIdRelatedToDocument[i].key) {
                        item.showPreview = false;
                        //item.fileuploadcount = (this.contentIdRelatedToDocument[i].value).length;
                        if (this.docHandlerhistory.length > 0) {
                            this.docHandlerhistory.forEach(dochistory_Item => {
                                if (dochistory_Item.task_id__c != null && dochistory_Item.task_id__c != undefined && dochistory_Item.task_id__c == this.documentUploadtaskid && dochistory_Item.Document_Handler__c == this.contentIdRelatedToDocument[i].key) {
                                    item.fileuploadcount = item.fileuploadcount + 1;
                                }
                            });
                        }
                    }
                })
            }
        }
    }


    //Used For - As per Status of the Record Enable/Disable other Buttons
    checkbuttonVisibilityAsPerStatus() {
        debugger;
        //Check As per Status
        this.getDocumentHandlerRecords.forEach((item) => {
            if (item.Status__c != null && item.Status__c != undefined) {
                if (((this.tkCreator == true && this.isEdit == true && ['Submited For Review', 'Submitted for Deviation Approval'].includes(item.Status__c) == false) || (this.tkReviewer == true && this.LoginUserAccess_RecordIds.includes(item.Id) && item.Status__c == 'Submited For Review') || (this.tkDeviationReviewer == true && this.LoginUserAccess_RecordIds.includes(item.Id) && item.Status__c == 'Submitted for Devaition Approval') || (this.documentUploadtaskid!=null && this.documentUploadtaskid!=undefined && this.documentUploadtaskid!='')) && ['Exempted', 'Approved'].includes(item.Status__c) == false) {
                    item.showDocUpload = false; //Upload Document 
                } else {
                    item.showDocUpload = true;
                }
                if (this.reviewerButtonEnableVisibityStatus.includes(item.Status__c) == true && this.isEdit == true) {
                    item.showreview = false;  //Review Document
                }
                if (this.reviewerButtonDisableVisibityStatus.includes(item.Status__c) == true) {
                    item.showreview = true;  //Review Document
                }
                if (this.DeviationButtonvisibilityAsperStatus.includes(item.Status__c) == true) {
                    item.deviationdisable = true;
                }
                if (this.ReviewButtonvisibilityAsperStatus.includes(item.Status__c) == true) {
                    item.reviewerdisable = true;
                }

                if (item.Process_Attribute_Dcoument_Detail__c && ((item.Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c == false) || (item.Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c == true && item.fileuploadcount > 0) || (item.Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c == true && item.fileuploadcount == 0 && item.Is_Alternate_Document_Uploded__c == true))) {
                    item.isdisable_Alternatedocument = true;
                } else {
                    item.isdisable_Alternatedocument = false;
                }
                if (item.Physical_Document_Mandatory__c == true && this.isEdit == true && ['Exempted', 'Approved', 'Submited For Review', 'Submitted for Deviation Approval', 'Alternate Document Added'].includes(item.Status__c) == false) {
                    item.isphysicaldocneed = false;
                } else {
                    item.isphysicaldocneed = true;
                }

            }
        })
    }

    @track LoginUserAccess_RecordIds = []
    //show_hide Buttons As Per Login User
    checkDHhandlerVisibityAsperLoginUser() {
        debugger;
        let LoginUserAccess_RecordIds = [];
        if (this.getchild_tasklist.length > 0) {
            if (this.getloginuser_RelatedGroups.length > 0) {
                this.getchild_tasklist.forEach((item) => {
                    console.log('item::', item);
                    if ((item.Review_Record_Id__c != null && this.getloginuser_RelatedGroups.includes(item.Owner.Name)) || (item.Review_Record_Id__c != null && item.OwnerId == this.loginuserId)) {
                        LoginUserAccess_RecordIds.push(item.Review_Record_Id__c);
                    }
                })
            }
            this.LoginUserAccess_RecordIds = LoginUserAccess_RecordIds;
            this.hideshowButtonsAsPerStatus(LoginUserAccess_RecordIds);
        }
    }

    hideshowButtonsAsPerStatus(loginuserAccess_recordIds) {
        debugger;
        if (loginuserAccess_recordIds.length > 0) {

            this.getDocumentHandlerRecords.forEach((item) => {
                console.log('item for  button access', item);
                if (this.tkReviewer == true || loginuserAccess_recordIds.includes(item.Id) && item.Status__c == 'Submited For Review') {
                    //For enable Disable
                    item.reviewerdisable = false;
                    item.isReviewerVisible = true;
                    item.isDeviationVisible = false

                } else if (this.tkDeviationReviewer == true || loginuserAccess_recordIds.includes(item.Id) && item.Status__c == 'Submitted for Deviation Approval') {
                    //For enable Disable
                    item.deviationdisable = false;
                    item.isReviewerVisible = false
                    item.isDeviationVisible = true
                }
                else {
                    item.isReviewerVisible = false
                    item.isDeviationVisible = false
                }
            })
        } else if (loginuserAccess_recordIds.length == 0 && this.isAssociated_to_this_process == false) {
            this.getDocumentHandlerRecords.forEach(currentItem => {
                if (currentItem) {
                    currentItem.reviewerdisable = true;
                    currentItem.deviationdisable = true;
                    currentItem.isReviewerVisible = false
                    currentItem.isDeviationVisible = false
                }
            });
        }

    }

    //Check Any newDocument is needed For Documents
    @track ErrorRecordForNewDocument = [];
    checkvalidationsIsNewDocument() {
        debugger;
        let ErrorRecordArray = [];
        if (this.getDocumentHandlerRecords.length > 0) {
            this.getDocumentHandlerRecords.forEach((item) => {
                let obj = item;
                if (obj.hasOwnProperty('Process_Attribute_Dcoument_Detail__r') == true) {
                    if (item.Process_Attribute_Dcoument_Detail__r.Is_New_Document__c != null && item.Process_Attribute_Dcoument_Detail__r.Is_New_Document__c != undefined && item.Process_Attribute_Dcoument_Detail__r.Is_New_Document__c == true && item.newuploadedDoc == null && this.getIsNewDocumentAsPerStatus.includes(item.Status__c) == true) {
                        item.cssclass = 'slds-hint-parent blink';
                        ErrorRecordArray.push(item);
                    }
                }
            })
            this.ErrorRecordForNewDocument = ErrorRecordArray;
        }
        return ErrorRecordArray.length > 0 ? false : true;
    }


    checkValidationsForReview(dhrecordList, on_operation) {
        debugger;
        let shouldSkip = false;
        let reviewerRecord = [];
        if (dhrecordList.length > 0 && on_operation == 'On_Review') {
            dhrecordList.forEach(currentItem => {
                if (currentItem) {
                    if (shouldSkip) { return }
                    if ((currentItem.Physical_Document_Mandatory__c == true && currentItem.Physical_Document_Received__c == false)) {
                        reviewerRecord.push(currentItem);
                        this.contentmessage = 'Collection Of Physical Document Is Mandatory';
                        shouldSkip = true;
                        if ((currentItem.Upload_Mandatory__c == true && currentItem.fileuploadcount == 0)) {
                            reviewerRecord.push(currentItem);
                            shouldSkip = true;
                            this.contentmessage = 'Upload Mandatory';
                        }
                    } else if (currentItem.Physical_Document_Mandatory__c == false) {
                        if ((currentItem.Upload_Mandatory__c == true && currentItem.fileuploadcount == 0)) {
                            reviewerRecord.push(currentItem);
                            shouldSkip = true;
                            this.contentmessage = 'Upload Mandatory';
                        }
                    }
                }
            });
        } else if (dhrecordList.length > 0 && on_operation == 'On_Save') {
            dhrecordList.forEach(currentItem => {
                if (currentItem) {
                    if (currentItem.Status__c == 'Submit For Review') {
                        currentItem.cssclass = 'slds-hint-parent blink';
                        reviewerRecord.push(currentItem);
                    }
                }
            });
            this.getDocumentHandlerRecords = dhrecordList;
        }
        console.log('reviewerRecord', reviewerRecord);
        return reviewerRecord.length > 0 ? false : true;

    }

    @track DeviationApprovalRecords = [];
    checkvalidationforDeviation() {
        debugger;
        let v_mandatoryAction = true;
        let shouldSkip = false;
        let DeviationApprovalForDHRecords = [];
        this.getDocumentHandlerRecords.forEach((item) => {
            if (shouldSkip) {
                return;
            }
            if (item.Status__c != 'Exempted' && item.Process_Attribute_Dcoument_Detail__c) {

                if ((item.Process_Attribute_Dcoument_Detail__c && item.Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c != undefined && item.Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c != null) && (item.Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c != null && item.Process_Attribute_Dcoument_Detail__r.Deviation_Approver_Type__c != undefined)) {
                    if (item.Physical_Document_Mandatory__c == true && item.Upload_Mandatory__c == false && item.Physical_Document_Received__c == false && this.recordStatusForDeviation.includes(item.Status__c) == true) {
                        item.cssclass = 'slds-hint-parent blink';
                        item.ErrorMessage = 'Collection Of Physical Document Mandatory'
                        DeviationApprovalForDHRecords.push(item);

                    } else if (item.Physical_Document_Mandatory__c == false && item.Upload_Mandatory__c == true && item.fileuploadcount == 0 && this.recordStatusForDeviation.includes(item.Status__c) == true) {
                        item.cssclass = 'slds-hint-parent blink';
                        item.ErrorMessage = 'Upload Mandatory';
                        DeviationApprovalForDHRecords.push(item);
                    } else if (item.Physical_Document_Mandatory__c == true && item.Upload_Mandatory__c == true && (item.fileuploadcount == 0 || item.Physical_Document_Received__c == false) && (this.recordStatusForDeviation.includes(item.Status__c) == true)) {
                        item.cssclass = 'slds-hint-parent blink';
                        item.ErrorMessage = 'Collection Of Physical Document & Upload Mandatory';
                        DeviationApprovalForDHRecords.push(item);
                    }
                } else if (item.Process_Attribute_Dcoument_Detail__c && item.Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c == null || item.Process_Attribute_Dcoument_Detail__r.Deviation_Approver__c == undefined) {
                    if (item.Physical_Document_Mandatory__c == true && item.Upload_Mandatory__c == false && item.Physical_Document_Received__c == false && this.Partially_Document_closed_status.includes(item.Status__c) == false) {
                        item.cssclass = 'slds-hint-parent blink';
                        this.contentmessage = 'Collection Of Physical Document Mandatory';
                        v_mandatoryAction = false;
                        shouldSkip = true;

                    } else if (item.Physical_Document_Mandatory__c == false && item.Upload_Mandatory__c == true && item.fileuploadcount == 0 && this.Partially_Document_closed_status.includes(item.Status__c) == false) {
                        item.cssclass = 'slds-hint-parent blink';
                        this.contentmessage = 'Upload Mandatory';
                        v_mandatoryAction = false;
                        shouldSkip = true;
                    } else if (item.Physical_Document_Mandatory__c == true && item.Upload_Mandatory__c == true && (item.fileuploadcount == 0 || item.Physical_Document_Received__c == false) && this.Partially_Document_closed_status.includes(item.Status__c) == false) {
                        item.cssclass = 'slds-hint-parent blink';
                        this.contentmessage = 'Collection Of Physical Document & Upload Mandatory';
                        v_mandatoryAction = false;
                        shouldSkip = true;
                    }
                }
            }

        })
        this.DeviationApprovalRecords = DeviationApprovalForDHRecords;
        return DeviationApprovalForDHRecords.length > 0 || v_mandatoryAction == false ? false : true;
    }

    //Creating Task For Review
    HandleReviewerCreation() {
        debugger;
        const date = new Date();
        let createCommentFormat = (date.toISOString()) + "   [" + this.currentUserName + "] - " + '' + this.Reviewrecord.Document_Metadata__r.Document_Name__c + ' ' + 'Is Under Review By' + ' ' + this.Reviewrecord.Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c + '\n';
        this.Reviewrecord.Description__c = createCommentFormat;
        insertTaskforReview({ DHRecord: this.Reviewrecord })
            .then(result => {
                if (result != null && result != undefined) {
                    let index = this.getDocumentHandlerRecords.findIndex((item) => item.Id == result.Id);
                    let obj = result;
                    this.getDocumentHandlerRecords[index] = obj//Object.assign(this.getDocumentHandlerRecords[index], obj);
                    this.checkbuttonVisibilityAsPerStatus();
                    this.showReviewRecord = false;
                    this.showNotification('success', 'Record Created For Review', 'success');
                }
            })
            .catch(error => {
                console.log('error--' + error);
            })
    }

    //Creating Document List To Preview
    createDocumentlistToPreview(documentId) {
        debugger;
        let Temparray = [];
        if (this.contentIdRelatedToDocument.length > 0) {
            let array = this.contentIdRelatedToDocument.find(item => item.key == documentId).value;
            if (array.length > 0) {
                for (var key in array) {
                    Temparray.push(array[key]);
                }
                if (Temparray.length > 0) {
                    for (let i = 0; i < Temparray.length; i++) {
                        let obj = Object.entries(Temparray[i]);
                        obj.map(([key, val] = entry) => {
                            this.DocumentList.push({ key: `${key}`, values: `${val}` });
                        });
                    }
                }
            }
        }

        if (this.DocumentList.length > 0) {
            this.DocumentList.forEach(item => {
                if (item && item.values) {
                    let selectedDhhRecord = this.docHandlerhistory.find((doc_item) => doc_item.Document_Path__c == item.values);
                    item.UploadedDateTime = selectedDhhRecord.CreatedDate;
                    item.Uploaded_By__c = selectedDhhRecord.CreatedBy.Name;
                    item.DMS_System__c = selectedDhhRecord.DMS_System_Name__c ? selectedDhhRecord.DMS_System_Name__c : null;
                }
            })
        }
    }

    //Add Comments
    commentHandler() {
        debugger;
        const date = new Date();
        let selectedId = this.addCommentonRecordid;
        let DHarray = this.getDocumentHandlerRecords;
        if (this.comments != null && this.comments != undefined) {
            let createCommentFormat = (date.toISOString()) + "   [" + this.currentUserName + "] - " + this.comments + '\n';
            DHarray.forEach((item) => {
                if (item.Id == selectedId) {
                    item.Description__c = item.Description__c != null && item.Description__c != undefined ? createCommentFormat + '\n' + item.Description__c : createCommentFormat;
                }
            })
        }
        this.getDocumentHandlerRecords = DHarray;
        this.addComments = false;
        this.UpsertDHRecords(this.getDocumentHandlerRecords, 'Insert/UpsertDocHandler');
    }

    //Handling For Duplicate Data
    checkDocumentExist() {
        debugger;
        let PADDarray = [...this.getPADD];
        if (this.getPADD.length > 0) {
            PADDarray.forEach((item) => {
                if (item.Document_Metadata__c != undefined && item.Document_Metadata__c != null && item.Multile_DM_Allowed__c == false) {
                    if (this.getDocumentHandlerRecords.find((DHitem) => {
                        if (this.extendedSobjectRecordId != null && this.extendedSobjectRecordId != undefined) {
                            if (DHitem.Document_Metadata__c == item.Document_Metadata__c) {
                                this.getPADD = this.getPADD.filter((PADD) => PADD.Document_Metadata__c != item.Document_Metadata__c);
                            }
                        } else {
                            if (DHitem.Document_Metadata__c == item.Document_Metadata__c) {
                                this.getPADD = this.getPADD.filter((PADD) => PADD.Document_Metadata__c != item.Document_Metadata__c);
                            }
                        }
                    })) {
                    }
                }
            })
        }
    }
    @track handledisableAddDocument = true;
    @track sladate;
    HandleChange(event) {
        debugger;
        let checked = event.target.checked;
        let selectedId = event.currentTarget.dataset.id;
        let label = event.currentTarget.dataset.label;
        if (label == 'inputcomment') {
            this.comments = event.target.value;
        } else if (label == 'checkboxSelection') {
            let selectedrecord = this.getPADD.find(item => item.Id == selectedId);
            console.log('selectedrecord--' + selectedrecord);
            if (this.selectedPADD.length > 0) {
                if (this.selectedPADD.find(item => item.Id == selectedId) && checked == false) {
                    this.selectedPADD = this.selectedPADD.filter((item) => item.Id != selectedId);
                } else if (this.selectedPADD.find(item => item.Id != selectedId) && checked == true) {
                    this.selectedPADD.push(selectedrecord);
                }
            } else {
                this.selectedPADD.push(selectedrecord);
            }
            this.handledisableAddDocument = this.selectedPADD.length > 0 ? false : true;
        } else if (label == 'AddPhysicalDocument') {
            this.getDocumentHandlerRecords.find((item) => {
                if (item.Id == selectedId) {
                    item.Physical_Document_Received__c = checked;
                    if (item.Physical_Document_Mandatory__c == true && !checked) {
                        item.Status__c = 'Physical Document Pending';
                    } else if (item.Physical_Document_Mandatory__c == true && ((item.Upload_Mandatory__c == true && item.fileuploadcount == 0))) {
                        item.Status__c = 'Document Upload Pending';
                    }
                    else if (item.Physical_Document_Mandatory__c == true && item.Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c == null && (item.Upload_Mandatory__c == false || (item.Upload_Mandatory__c == true && item.fileuploadcount > 0))) {
                        item.Status__c = 'Received';
                    }
                    else if (item.Physical_Document_Mandatory__c == true && item.Process_Attribute_Dcoument_Detail__r.Reviewer_Name__c != null && (item.Upload_Mandatory__c == false || (item.Upload_Mandatory__c == true && item.fileuploadcount > 0))) {
                        item.Status__c = 'Submit For Review';
                    }
                }
            })
            this.UpsertDHRecords(this.getDocumentHandlerRecords, 'Insert/UpsertDocHandler');
            this.closehighlightbar();
        } else if (label == 'UpdateSLADate') {
            var selectedDate = '';
            if (event.target.value != '') {
                selectedDate = new Date(event.target.value);
            }
            const currentDate = new Date(this.today);
            this.SelectedRecordForDeviation.updatedSladate = event.target.value;
            this.ApproveDisable = event.target.value != null && event.target.value != '' && event.target.value != undefined ? false : true;
            this.RejectDisable = !this.ApproveDisable;

            if (this.SelectedRecordForDeviation.updatedSladate && selectedDate > currentDate) {
                this.sladate = event.target.value;
                this.tkdisable = true;
                this.Exempteddisable = true;
                this.ApproveDisable = false;
            } else if (selectedDate != null && selectedDate != undefined && selectedDate != '') {
                this.tkdisable = false;
                this.Exempteddisable = false;
                this.ApproveDisable = true;
                this.showNotification('ERROR', 'Please Select Any Future Date', 'error');
            }

        } else if (label == 'Exempted') {
            this.ApproveDisable = checked == true ? false : true;
            this.RejectDisable = !this.ApproveDisable;
            this.SelectedRecordForDeviation.Exempted__c = checked;

            if (this.SelectedRecordForDeviation.Exempted__c) {
                this.tkdisable = true;
                this.sladisable = true;
            } else {
                this.tkdisable = false;
                this.sladisable = false;
            }
        } else if (label == 'deviationTask') {
            if (event.target.value != null && event.target.value != undefined && event.target.value != '') {
                this.SelectedRecordForDeviation.selectedTaskId = event.target.value;
                this.sladisable = true;
                this.Exempteddisable = true;
                this.ApproveDisable = false;
                this.RejectDisable = true;
            } else {
                this.SelectedRecordForDeviation.selectedTaskId = null;
                this.ApproveDisable = true;
                this.RejectDisable = false;
                this.sladisable = false;
                this.Exempteddisable = false;
            }

        } else if (label == 'AddDocumentIdvalue') {
            if (event.target.value != null && event.target.value != undefined && event.target.value != '') {
                this.getDocumentHandlerRecords.find((item) => {
                    if (item.Id == selectedId) {
                        item.Document_Id_Value__c = event.target.value;
                    }
                })
            }
        } else if (label == 'AlternateDocumentUpload') {
            debugger;
            let selectedDhRecord = [];
            this.getDocumentHandlerRecords.find((item) => {
                if (item.Id == selectedId) {
                    item.Is_Alternate_Document_Uploded__c = checked;
                    item.Status__c = 'Alternate Document Added';
                    selectedDhRecord.push(item);
                }
            })
            this.UpsertDHRecords(selectedDhRecord, 'AddMoreAlternativeDocuments');
        } else if(label == 'UploadSharepointlink'){
            debugger
            if (event.target.value != null && event.target.value != undefined && event.target.value != '') {
                 this.sharepointurlLink=event.target.value;
                 this.fileuploaddisable=false;
            }else{
                 this.fileuploaddisable=true;
                 this.sharepointurlLink=event.target.value;
            }
        }
    }

    updateDhRecordStatus_If_Validations(DHRecords) {
        debugger;
        this.DHrecordsToInsert = [];
        DHRecords.forEach((item) => {
            delete item.showPreview
            delete item.showDocUpload
            delete item.showreview
            delete item.showcomment
            delete item.newuploadedDoc
            delete item.fileuploadcount
            delete item.isphysicaldocneed
            delete item.cssclass
            this.DHrecordsToInsert.push(item);
        });
        return this.DHrecordsToInsert;
    }

    //Updation Of Document Handler
    updateDocumentHandlerJson(DHRecords) {
        debugger;
        this.DHrecordsToInsert = [];
        DHRecords.forEach((item) => {
            delete item.showPreview
            delete item.showDocUpload
            delete item.showreview
            delete item.showcomment
            delete item.newuploadedDoc
            delete item.fileuploadcount
            delete item.isphysicaldocneed
            delete item.cssclass
            this.DHrecordsToInsert.push(item);
        });
        return this.DHrecordsToInsert;
    }

    //Insertion Of Addition Document Records
    createDocumentHandlerJson(selectedRecords) {
        debugger;
        this.DHrecordsToInsert = [];
        selectedRecords.forEach((item) => {
            let DHJson = { Document_Metadata__c: null, Physical_Document_Mandatory__c: null, Upload_Mandatory__c: null, Task_Id__c: null, Review_Required__c: null, Description__c: null, Status__c: null, Process_Attribute_Dcoument_Detail__c: null }
            DHJson.Document_Metadata__c = item.Document_Metadata__c;
            DHJson.Physical_Document_Mandatory__c = item.Physical_Document_Mandatory__c;
            DHJson.Upload_Mandatory__c = item.Upload_Mandatory__c;
            DHJson.Task_Id__c = this.recordId;
            DHJson.Review_Required__c = item.Review_Required__c;
            DHJson.Description__c = item.Document_Metadata__r.Description__c;
            DHJson.Status__c = 'Draft';
            DHJson.Process_Attribute_Dcoument_Detail__c = item.Id;
            DHJson.Extended_SObject_RecordId__c = this.extendedSobjectRecordId != null && this.extendedSobjectRecordId != undefined ? this.extendedSobjectRecordId : null;
            this.DHrecordsToInsert.push(DHJson);
        });
        return this.DHrecordsToInsert;
    }

    UpsertDHRecords(DHrecordsToInsert, optoPerform) {
        debugger;
        //let DHArray = [];
        upsertDocumentHandler({ UpsertDHRecords: DHrecordsToInsert, operationToPerform: optoPerform })
            .then(result => {
                if (result != null && result != undefined) {
                    result.forEach((resultitem) => {
                        resultitem.showPreview = true;
                        resultitem.showDocUpload = true;
                        resultitem.showreview = true;
                        resultitem.showcomment = false;
                        resultitem.fileuploadcount = 0;
                        if (resultitem.Physical_Document_Mandatory__c == true && this.isEdit == true && ['Exempted', 'Approved', 'Submited For Review', 'Submitted for Deviation Approval', 'Alternate Document Added'].includes(resultitem.Status__c) == false) {
                            resultitem.isphysicaldocneed = false;
                        } else {
                            resultitem.isphysicaldocneed = true;
                        }
                        resultitem.cssclass = 'slds-hint-parent';
                        resultitem.isVisibleshowDocUpload = true;
                        resultitem.isVisibleshowreview = true;
                        resultitem.isReviewerVisible = false
                        resultitem.isDeviationVisible = false
                        if (this.getDocumentHandlerRecords.find((dhitem) => dhitem.Id === resultitem.Id)) {
                            this.getDocumentHandlerRecords.find((dhrec) => {
                                if (dhrec.Id === resultitem.Id) {
                                    dhrec = Object.assign(dhrec, resultitem);
                                }
                            })
                        } else {
                            this.getDocumentHandlerRecords.push(resultitem);
                        }
                        resultitem.isdisable_Alternatedocument = true;
                        resultitem.isshowInfo = resultitem.Process_Attribute_Dcoument_Detail__c != undefined && resultitem.Process_Attribute_Dcoument_Detail__c != null && resultitem.Process_Attribute_Dcoument_Detail__r.Is_Alternate_Document_Upload_Applicable__c == false ? true : false;
                    })
                    this.isChildtask == true ? this.checkDHhandlerVisibityAsperLoginUser() : 'Parent Task';
                    this.checkForButtonsVisibilityAsPerDocumet();
                    this.checkbuttonVisibilityAsPerStatus();
                    this.DeviationApprovalRecords = [];
                    this.DHrecordsToInsert = [];
                    this.AddDocumentHandler = false;
                    if (optoPerform == 'Insert/UpsertDocHandler') {
                        this.showNotification('SUCCESS', 'Record Created or Updated Successfully', 'success');
                    } else if (optoPerform == 'UpsertDocHandlerDeviation') {
                        this.showNotification('SUCCESS', 'Record Submitted for Deviation Approval Successfully', 'success');
                    }
                }
            })
            .catch(error => {
                console.log('Errorured:- ' + error);
            });
    }

    //Preview Functionality
    HandlePreview(event) {
        debugger;
        let contentId = event.target.accessKey;
        let DMSSystem = event.target.dataset.dmssystem;
        console.log('DMSSystem', DMSSystem);
        let substr = 'https://';
        if (DMSSystem == 'Sharepoint' || contentId.includes(substr) == true) {
            window.open(contentId, '_blank');
        } else if (DMSSystem == 'Salesforce') {

            // const fileId = contentId;
            // const fileUrl = `/sfc/servlet.shepherd/document/download/${fileId}`;
            // window.open(fileUrl, '_blank');

            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: contentId
                }
            })
        }
    }

    //Upload Document Call Apex
    UploadDocumentOnDH(dhrecord) {
        debugger;
        if(this.sharepointurlLink!=null && this.sharepointurlLink!=undefined && this.sharepointurlLink!=''){
             this.store_typed_sharepointLink(this.sharepointurlLink,'Sharepoint');
        }else{
            if (dhrecord.Process_Attribute_Dcoument_Detail__r.DMS_System__c != null || dhrecord.Process_Attribute_Dcoument_Detail__r.DMS_System__c != undefined) {
                if (dhrecord.Process_Attribute_Dcoument_Detail__r.DMS_System__c == 'Salesforce') {
                    this.storeDocumentInSfsystem(this.fileData,'Salesforce');
                } else if (dhrecord.Process_Attribute_Dcoument_Detail__r.DMS_System__c == 'Sharepoint') {
                    this.storeDocumentInSharePoint(this.fileData,'Sharepoint');
                }
            } else {
                this.showNotification('Error', 'DMS SYSTEM ID IS NULL & Please Contact Your System Admin', 'error');
            }
        }
    }


    store_typed_sharepointLink(sharepointpath_link,dmsPath){
        debugger;
        let fileName=null;
        UpdateDMSId({ uploadeFilePath: sharepointpath_link, uploadedrecId: this.docmetaid, filename: fileName, uploadedTaskId: this.documentUploadtaskid ,dmspath:dmsPath})
        .then(res => {
            if (res != null && res != undefined) {
                this.sharepointurlLink='';
                let Array_contentIdRelatedToDocument = this.updatecontentIdRelatedToDocument(this.contentIdRelatedToDocument, res.DocumentIdRelatedToDHId);
                this.contentIdRelatedToDocument = Array_contentIdRelatedToDocument;
                this.getDocumentHandlerRecords.find((item) => {
                    if (item.Id == res.dhrecord.Id) {
                        item.newuploadedDoc = res.uplodedRecordId;
                    }
                    if (item.Id == res.dhrecord.Id) {
                        item = Object.assign(item, res.dhrecord);
                    }
                });
                this.isChildtask == true ? this.checkDHhandlerVisibityAsperLoginUser() : 'Parent Task';
                this.checkForButtonsVisibilityAsPerDocumet();
                this.checkbuttonVisibilityAsPerStatus();
                this.UploadDocument = false;
                this.showNotification('SUCCESS', 'Document Uploaded Sucessfully', 'success');
                this.handleRemove();
                if(this.docHandlerhistory.length > 0 && res.DocHandlerHistory != null && res.DocHandlerHistory != undefined && res.DocHandlerHistory.length > 0){  
                    if (res.DocHandlerHistory != null && res.DocHandlerHistory != undefined && res.DocHandlerHistory.length > 0) {
                        res.DocHandlerHistory.forEach(item => {
                            if (item && item.Id) {
                                if (this.docHandlerhistory.find((docitem) => docitem.Id !== item.Id)) {
                                    this.docHandlerhistory.push(item);
                                }
                            }
                        })
                    }
                }else{
                    this.docHandlerhistory = [...res.DocHandlerHistory];
                }
            }
        })
        .catch(error => {
            console.log('error--', error);
        })

    }

    /* 
    * Upload Document On SharePoint still not Configured
    storeDocumentInSharePoint(fileData) {
        debugger;
        let base64 = fileData.base64;
        let fileName = fileData.filename.replaceAll(' ', '_');
        let path = '/sites/NortherArc/Shared%20Documents/Main%20Folder/Pdf%20Docs';
        createFile({ base64, fileName, path }).then(res => {
            console.log('res--', res);
            if (res != null || res != undefined) {
                let path = this.createPreviewPathlink(res);
                if (path != null || path != undefined) {
                    UpdateDMSId({ uploadeFilePath: path, uploadedrecId: this.docmetaid, filename: fileName, uploadedTaskId: this.documentUploadtaskid })
                        .then(res => {
                            if (res != null && res != undefined) {
                                let Array_contentIdRelatedToDocument = this.updatecontentIdRelatedToDocument(this.contentIdRelatedToDocument, res.DocumentIdRelatedToDHId);
                                this.contentIdRelatedToDocument = Array_contentIdRelatedToDocument;
                                this.getDocumentHandlerRecords.find((item) => {
                                    if (item.Id == res.dhrecord.Id) {
                                        item.newuploadedDoc = res.uplodedRecordId;
                                    }
                                    if (item.Id == res.dhrecord.Id) {
                                        item = Object.assign(item, res.dhrecord);
                                    }
                                });
                                this.isChildtask == true ? this.checkDHhandlerVisibityAsperLoginUser() : 'Parent Task';
                                this.checkForButtonsVisibilityAsPerDocumet();
                                this.checkbuttonVisibilityAsPerStatus();
                                this.UploadDocument = false;
                                this.showNotification('SUCCESS', 'Document Uploaded Sucessfully', 'success');
                                this.handleRemove();
                                if (result.DocHandlerHistory != null && result.DocHandlerHistory != undefined && result.DocHandlerHistory.length > 0) {
                                    result.DocHandlerHistory.forEach(item => {
                                        if (item && item.Id) {
                                            if (this.docHandlerhistory.find((docitem) => docitem.Id !== item.Id)) {
                                                this.docHandlerhistory.push(item);
                                            }
                                        }
                                    })
                                }
                            }
                        })
                        .catch(error => {
                            console.log('error--', error);
                        })
                }
            }
        }).catch(error => {
            console.log('Error to create the file----', error);
        })
    }

    createPreviewPathlink(uplodedFile) {
        debugger;
        console.log('SubFiles', uplodedFile);
        let filename = '/' + uplodedFile.Name;
        let id = encodeURIComponent(uplodedFile.ServerRelativeUrl);
        let parent = encodeURIComponent(uplodedFile.ServerRelativeUrl.replace(filename, ''));
        let path = 'https://utillabs.sharepoint.com/:w:/r/sites/NortherArc/_layouts/15/Doc.aspx?sourcedoc=' + id + '&parent=' + parent;
        return path;
    }
    */

    storeDocumentInSfsystem(fileData,dmsPath) {
        debugger;
        uploadFile({ base64: fileData.base64, filename: fileData.filename, recordId: this.docmetaid, uploadedTaskId: this.documentUploadtaskid,dmspath:dmsPath })
            .then(result => {
                if (result != null && result != undefined) {
                    //let Array_contentIdRelatedToDocument = this.contentIdRelatedToDocument;
                    let Array_contentIdRelatedToDocument = this.updatecontentIdRelatedToDocument(this.contentIdRelatedToDocument, result.DocumentIdRelatedToDHId);
                    this.contentIdRelatedToDocument = Array_contentIdRelatedToDocument;
                    this.getDocumentHandlerRecords.find((item) => {
                        if (item.Id == result.dhrecord.Id) {
                            item.newuploadedDoc = result.uplodedRecordId;
                        }
                        if (item.Id == result.dhrecord.Id) {
                            item = Object.assign(item, result.dhrecord);
                        }
                    })
                    this.isChildtask == true ? this.checkDHhandlerVisibityAsperLoginUser() : 'Parent Task';
                    if (this.docHandlerhistory.length > 0 && result.DocHandlerHistory != null && result.DocHandlerHistory != undefined && result.DocHandlerHistory.length > 0) {
                        result.DocHandlerHistory.forEach(item => {
                            if (item && item.Id) {
                                if (this.docHandlerhistory.find((docitem) => docitem.Id !== item.Id)) {
                                    this.docHandlerhistory.push(item);
                                }
                            }
                        })
                    } else {
                        this.docHandlerhistory = [...result.DocHandlerHistory];
                    }
                    this.checkForButtonsVisibilityAsPerDocumet();
                    this.checkbuttonVisibilityAsPerStatus();
                    this.UploadDocument = false;
                    this.showNotification('SUCCESS', 'Document Uploaded Sucessfully', 'success');
                    this.handleRemove();
                }
            }).catch(error => {
                console.log('error--', error);
            })
    }

    updatecontentIdRelatedToDocument(Array_contentIdRelatedToDocument, DocumentIdRelatedToDHId) {
        debugger;
        for (let key in DocumentIdRelatedToDHId) {
            if (Array_contentIdRelatedToDocument.length > 0) {
                Array_contentIdRelatedToDocument.find((item) => {
                    if (item.key == key) {
                        let index = Array_contentIdRelatedToDocument.findIndex((item) => item.key == key);
                        console.log('index--' + index);
                        let objassign = Object.assign({}, DocumentIdRelatedToDHId[key][0]);
                        const object2 = Object.fromEntries(
                            Object.entries(objassign).map(([key, val]) => [key, val]),
                        );
                        Array_contentIdRelatedToDocument[index].value.push(object2);
                        console.log('Exist In List');
                    } else {
                        let index = Array_contentIdRelatedToDocument.findIndex((item) => item.key == key);
                        if (index == -1) {
                            Array_contentIdRelatedToDocument.push({ key: key, value: DocumentIdRelatedToDHId[key] });
                        }
                    }
                })
            } else {
                Array_contentIdRelatedToDocument.push({ key: key, value: DocumentIdRelatedToDHId[key] });
            }
        }
        return Array_contentIdRelatedToDocument;
    }

    //For Uploading Document
    async openfileUpload(event) {
        debugger;
        const file = event.target.files[0];
        //this.fileName = file.name;
        try {
            const result = await this.readFileAsync(file);
            const base64 = result.split(',')[1];
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.docmetaid
            };
            this.fileName = this.fileData.filename;
            this.fileuploaddisable = false;
        } catch (error) {
            console.error('Error reading file:', error);
        }
    }

    async  readFileAsync(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                resolve(reader.result);
            };
            reader.onerror = (error) => {
                reject(error);
            };
            reader.readAsDataURL(file);
        });
    }

    handleRemove() {
        debugger;
        this.fileName = '';
        this.fileData = '';
        this.fileuploaddisable = true;
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    closehighlightbar() {
        debugger;
        this.getDocumentHandlerRecords.find((item) => {
            if (this.cssclasslist.includes(item.cssclass) == true) {
                item.cssclass = 'slds-hint-parent';
            }
        })
    }

    update_reviewer_deviation_approver(dhrecord, taskrecId, tkstatus) {
        update_dh_status({ dhrec: dhrecord, taskid: taskrecId, taskstatus: tkstatus })
            .then(res => {
                if (res != null && res != undefined) {
                    this.getDocumentHandlerRecords.find((item) => {
                        if (item.Id == res.dhrecord.Id) {
                            item = Object.assign(item, res.dhrecord);
                        }
                    });
                    this.checkcurrentUser_is_Reviewer_parentkowner_viewer();
                    this.isChildtask == true ? this.checkDHhandlerVisibityAsperLoginUser() : 'Parent Task';
                    this.checkForButtonsVisibilityAsPerDocumet();
                    this.checkbuttonVisibilityAsPerStatus();
                    this.ReviewDeviation = false;
                    this.SelectedRecordForDeviation = '';
                    this.tkdisable = false;
                    this.sladisable = false;
                    this.Exempteddisable = false;
                }
            })
            .catch(error => {
                console.log('error--', error);
            })
    }

    callEventToUpdateData(is_closed_boolean) {
        debugger;
        if (this.extendedSobjectRecordId == null || this.extendedSobjectRecordId == undefined) {
            const event = new CustomEvent('lwclaunched', {
                detail: {
                    isclosed: is_closed_boolean,
                    index: this.index
                }
            });
            this.dispatchEvent(event);
        } else {
            const event = new CustomEvent('lwclaunched', {
                detail: {
                    child_isclosed: is_closed_boolean,
                    index: this.index,
                    extendedsobjId: this.extendedSobjectRecordId,
                }
            });
            this.dispatchEvent(event);
        }

    }

    @track sobjectName = 'Task';
    @track taskList = [];
    getsobjectRecords() {
        debugger;
        getRelatedtasks({ objectName: this.sobjectName, taskrecord: this.taskRec })
            .then(result => {
                if (result != null && result != undefined) {
                    if (result.length > 0) {
                        result.forEach((item) => {
                            if (item) {
                                this.taskList.push({ label: item.Subject, value: item.Id })
                            }
                        })
                        this.taskList.unshift({ label: '--None--', value: "" })
                    }
                }
                console.log('result--', result);
                console.log('this.taskList.--', this.taskList);
            }).catch(error => {
                console.log('error--', error);
            })
    }

    get options() {
        return this.taskList;
    }
}