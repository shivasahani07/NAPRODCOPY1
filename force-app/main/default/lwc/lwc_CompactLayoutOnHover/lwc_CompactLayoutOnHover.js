import { LightningElement,api } from 'lwc';

export default class Lwc_CompactLayoutOnHover extends LightningElement {

    @api selectedrecordId;
    @api objectName;
    @api title;
    

    connectedCallback(){
        debugger;
        console.log('recordId',this.selectedrecordId);
       
    }

    hideModalBox() {  
        debugger;
        this.selectedrecordId="";
        const event = new CustomEvent('hidemodalbox', {
            detail: {
                isclosed: false,
            }
        });
        this.dispatchEvent(event);
    }
}