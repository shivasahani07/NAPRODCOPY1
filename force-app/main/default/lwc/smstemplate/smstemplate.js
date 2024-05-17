import { LightningElement, track, wire, api } from 'lwc';
import fetchsmstemplate from '@salesforce/apex/smsTemplatelwcController.fetchsmstemplate';
import sendsmstemplate from '@salesforce/apex/smsTemplatelwcController.sendsmstemplate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Smstemplate extends LightningElement {

    @api recordId;
    @track smstemplateRecords = [];
    @track templateSubjects = [];
    @track Selectedsmstempbody;
    @track SMSvariablevalue;

    @wire(fetchsmstemplate, { recId: '$recordId' })
    wiredsmsTemplateResponse({ data, error }) {
        debugger;
        if (data) {
            this.smstemplateRecords = data;
            var tempArray = [];
            if (this.smstemplateRecords != null && this.smstemplateRecords.length > 0) {
                for (var i = 0; i < this.smstemplateRecords.length; i++) {
                    tempArray.push({ label: this.smstemplateRecords[i].SmsSubject, value: this.smstemplateRecords[i].SmsSubject });
                }
            }

            this.templateSubjects = tempArray;
        }
        else if (error) {
            //console.log('error--'+this.MetaDATA);
        }
    }

    handleBodyChange(event){

    }

    handlevarvalueChange(event){

        var inputSMSvarvalue= event.detail.value;
        this.SMSvariablevalue = inputSMSvarvalue;
    }

    @track smsTempNimbusId;
    smsTempSubjecthandleChange(event) {
        debugger;
        var selectedTemp = event.detail.value;
        this.SelectedSmsTempSubject = selectedTemp;
        let SelectedTsmsTemp = this.smstemplateRecords.find(eachsmstemp => eachsmstemp.SmsSubject === selectedTemp);
        this.Selectedsmstempbody = SelectedTsmsTemp.smsBody;
        this.smsTempNimbusId = SelectedTsmsTemp.NimbusId;


        //console.log(sachinrecord);
    }

    SendSmshandler(event) {
        debugger;
        sendsmstemplate({ SmsSubject: this.SelectedSmsTempSubject, SmsBody : this.Selectedsmstempbody, RecId : this.recordId, Smsvarvalue : this.SMSvariablevalue, NimbusId : this.smsTempNimbusId  })
            .then((result) => {
                if(result== 'SUCCESS'){
                    this.showSuccessToast();
                    
                }
            })
            .catch((error) => {
                // this.error = error;
                // this.contacts = undefined;
            });
        debugger;

    }

    showSuccessToast() {
    const evt = new ShowToastEvent({
        title: 'SMS Delivered',
        message: 'SMS will be delivered successfully!',
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}
}