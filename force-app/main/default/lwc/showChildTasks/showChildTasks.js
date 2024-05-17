import { LightningElement, api, track } from 'lwc';
import getChildTasks from '@salesforce/apex/childTaskDataTable.getChildTasks';
import approveTask from '@salesforce/apex/childTaskDataTable.approveTask';
import rejectedTask from '@salesforce/apex/childTaskDataTable.rejectedTask';
import { NavigationMixin } from 'lightning/navigation'
    ;
import { ShowToastEvent } from "lightning/platformShowToastEvent";
const columns = [{ label: 'Task Subject', fieldName: 'Task_Id__c', sortable: "true" },
{ label: 'Payee Type', fieldName: 'Payee_Type__c', sortable: "true" },
{ label: 'Payee Name', fieldName: 'PayeeName', sortable: "true" },
{ label: 'Bank Account', fieldName: 'BankAccount', sortable: "true" },
{ label: 'Payment Mode', fieldName: 'Mode__c', sortable: "true" },
{ label: 'Amount', fieldName: 'Amount__c', sortable: "true" },
{ label: 'Status', fieldName: 'Status__c', sortable: "true" },

    //{ label: 'Type', fieldName: 'Type', sortable: "true" },
];

export default class ShowChildTasks extends NavigationMixin(LightningElement) {
    @api recordId;
    @track columns = columns;
    @track data = [];
    @track error;
    @track selectedRowIds = [];

    connectedCallback() {
        debugger;
        let currentUrl = window.location.href;
        this.extractRecordId(currentUrl);
    }

    extractRecordId(url) {
        const regex = /\/([a-zA-Z0-9]{15}|[a-zA-Z0-9]{18})\//;
        const match = url.match(regex);
        if (match && match.length > 1) {
            this.recordId = match[1];
            this.childTasks(this.recordId);
        }
    }

    childTasks(recordId) {
        getChildTasks({ taskId: recordId })
            .then(result => {
                debugger;
                if (result) {
                    this.data = result.map(value => {
                        return { ...value, PayeeName: value.Finacial_Entity_Details__r.Name, BankAccount: value.Financial_Entity_A_C_Details__r.Bank_Account_Number__c,v_checked:false}
                    });
                    this.error = undefined;
                }
            })
            .catch(error => {
                this.data = [];
                this.error = error;
            });
    }

    getSelectedName(event) {
        debugger;
        let tkId = this.data.find((item) => item.Id == event.target.dataset.id).Name;
        if(this.selectedRowIds.includes(tkId)){
            this.selectedRowIds = this.selectedRowIds.filter(item => item !== tkId);
        }else{
            this.selectedRowIds.push(tkId);
        }
        
        console.log('selected Task Ids ==> ', this.selectedRowIds);
    }

    handleApprove() {
        approveTask({ approveTaskIds: this.selectedRowIds })
            .then(result => {
                if (result === 'SUCCESS') {
                    this.showSuccessToast();
                    // Refresh data after successful approval
                    this.childTasks(this.recordId);
                }
               this.dispatchCloseQuickAction();
               this.navigateToHomePage();
            })
            .catch(error => {
                console.error('Error in approving tasks:', error);
                this.dispatchCloseQuickAction();
            });
    }

    handleReject() {
        rejectedTask({ approveTaskIds: this.selectedRowIds })
            .then(result => {
                if (result === 'SUCCESS') {
                    this.showSuccessToast();
                    // Refresh data after successful rejection
                    this.childTasks(this.recordId);
                }
                this.dispatchCloseQuickAction();
                this.navigateToHomePage();
            })
            .catch(error => {
                console.error('Error in rejecting tasks:', error);
                this.dispatchCloseQuickAction();
            });

    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Record update successful',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    dispatchCloseQuickAction() {
        const closeQAEvent = new CustomEvent('closequickaction');
        this.dispatchEvent(closeQAEvent);
    }

    redirectToMasterComp(event) {
        debugger;
        console.log(event.target.dataset.id);
        let tkId = this.data.find((item) => item.Id == event.target.dataset.id).Name;
        let Action_Name = 'TaskflowfromAura';
        let CompName = 'c__' + Action_Name;
        const navConfig = {
            type: "standard__component",
            attributes: {
                componentName: CompName,
            },
            state: {
                c__id: tkId
            }
        };
        this[NavigationMixin.Navigate](navConfig);
    }

    navigateToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }

    selectAllRows(event) {
        debugger;
        const isChecked = event.target.checked;
        this.data.forEach((item)=>{
            item.v_checked=isChecked;
        })
        if(isChecked){
            this.data.forEach((item)=>{ if(item.Name && item.v_checked){ this.selectedRowIds.push(item.Name);}})  
        }else{
           this.selectedRowIds=[];
        }
    }

}