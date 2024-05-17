import { LightningElement,track,api } from 'lwc';
export default class Lwc_Previewdocuments extends LightningElement {

    @api isEdit
    @api taskId
    @api index

    @api checkStatusOnLoad(){
        debugger;
        console.log('isEdit',this.isEdit);
        console.log('taskId',this.taskId);
        console.log('index',this.index);
    }

    @api HandleSavefromAura(){
        debugger;
        let child = this.template.querySelector('c-lwc_-handledocuments');
        child.HandleSavefromAura();
    }

    closepreview(event) {
        debugger;
       let isclosed = event.detail.isclosed;
       this.sendClosedStatementToParent(isclosed);
    }

     sendClosedStatementToParent(isClosed) {
        debugger;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: {
                "isclosed": isClosed,
                "index": this.index
            }
        });
        this.dispatchEvent(valueChangeEvent);
    }

}