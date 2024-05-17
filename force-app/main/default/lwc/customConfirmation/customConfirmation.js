import { LightningElement, api, track } from 'lwc';
export default class CustomConfirmation extends LightningElement {
    @api variant;
    @api heading;
    @api message;
    @api intractionResponse = false;


    connectedCallback() {
        debugger;
        if (this.variant == 'error') {

        } else if (this.variant == 'success') {

        } else if (this.variant == 'alert') {

        }
    }

    get containerClass() {
        debugger;
        return `slds-modal ${this.variant ? 'slds-modal_' + this.variant : ''}`;
    }

    handleConfirm() {
        debugger;
        // Dispatch event to confirm action
        this.dispatchEvent(new CustomEvent('response',{
            detail:{
                message:true
            }
        }));
        this.intractionResponse = true;
    }

    handleCancel() {
        debugger;
        // Dispatch event to cancel action
        this.dispatchEvent(new CustomEvent('response',{
            detail:{
                message:false
            }
        }));
        this.intractionResponse = false;
    }

   

}