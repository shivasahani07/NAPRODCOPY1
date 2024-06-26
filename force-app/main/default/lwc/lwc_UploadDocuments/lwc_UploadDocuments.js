import { LightningElement ,api} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import FileAttchmentRead from '@salesforce/apex/FileAttchmentRead.ReadFile';
export default class Lwc_UploadDocuments extends LightningElement {

     fileData
     fileName
     file
        @api index
        @api recordId

     @api checkStatusOnLoad(){
         debugger;
         console.log('Got Access');
     }
     //For Uploading Document
    async openfileUpload(event) {
        debugger;
        const file = event.target.files[0];
        try {
            const result = await this.readFileAsync(file);
            const base64 = result.split(',')[1];
            this.fileData = {
                'filename': file.name,
                'base64': base64,
            };
               this.fileName = this.fileData.filename;
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
    }

    @api HandleSavefromAura(){
        debugger;
          if(this.fileData!=null && this.fileData!=undefined && this.fileData!=''){
                  FileAttchmentRead({Base64:this.fileData.base64})
                  .then(result=>{
                        if(result=='SUCCESS'){
                            this.showNotification('SUCCESS','Memo Updated Successfully','success');
                        }else{
                            this.showNotification('Error',result,'error');
                        }
                  }).error(error=>{
                      this.showNotification('Error','error','error');
                  })
          }else{
              this.showNotification('Error','Please Upload File To Proceed Further','error');
          }
    }

    callEventToUpdateData(is_closed_boolean){
       debugger;
       const event = new CustomEvent('lwclaunched', {
                detail: {
                    isclosed: is_closed_boolean,
                    index: this.index
                }
            });
        this.dispatchEvent(event);
    }

     showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}