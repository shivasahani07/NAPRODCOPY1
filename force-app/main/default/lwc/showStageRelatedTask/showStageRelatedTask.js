import { LightningElement,api, track, wire } from 'lwc';
import getAllProcessAttributeDetails from '@salesforce/apex/showStageRelatedTasks.getAllProcessAttributeDetails';
import { NavigationMixin } from 'lightning/navigation';
import LightningAlert from 'lightning/alert';
import cloudfarecss from '@salesforce/resourceUrl/cloudfarecss';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
export default class ShowStageRelatedTask extends NavigationMixin(LightningElement) {

     //To load the ProgressBar
     renderedCallback() {
        Promise.all([
           loadStyle(this, cloudfarecss)
        ])
        .then(() => {
            console.log("All scripts and CSS are loaded. perform any initialization function.")
        })
        .catch(error => {
            console.log("failed to load the scripts");
        });
    }

    @api recordId;
    recordIdvalue;
    
    @track MetaDATA=[];
    @track section=[];

    @api showBackquote=false;
    @api Cardclass='cardInitStyle';
    @api InsidecardClass='initstyle';

    @api DynamicLabel='Expand All';

    @api ExpandingClass='allow-multiple-sections-open';

    @track Task_Values=[];
    @track Stage_Values=[];

    @track AllOpenTask=[];
    @track AllClosedTask=[];
    @track AllPendingTask=[];

    @track Open_Task_with_Stage=[];
    @track Closed_Task_with_Stage=[];
    @track Pending_Task_with_Stage=[];

    @track OverAll_Completed_Task="--value:0";

    @track styleforProgressbar='margin-left:0px;text-align:center;font-weight:bold;color:white;'

    @track LabelALLTask='All Task';
    @track LabelOpenTask='Open Task';
    @track LabelCloseTask='Closed Task';
    @track LabelPendingTask='Pending Task';
    
   

    @wire(getAllProcessAttributeDetails, { recordId: '$recordId'})
    wiredProcessAttributeDetails({ data, error }) {
        debugger;
        if (data) {
            this.recordIdvalue=this.recordId;
            for(var key in data){
                //if(key=='Term Sheet Finalization' || key=='Internal Stack Holder Signoff' || key=='Tech Integration')
                this.MetaDATA.push({key:key,value:(data)[key],progressvalue:[]});
                console.log('MetaDATA--',this.MetaDATA);
            }

            for(let i=0;i<this.MetaDATA.length;i++){
                this.Stage_Values.push(this.MetaDATA[i].key);
                    let TempArray=this.MetaDATA[i].value;
                    let EmptyArray=[];
                    if(TempArray){
                        for(let j=0;j<TempArray.length;j++){
                            const extendedObject = Object.assign({}, TempArray[j]);
                            if(extendedObject.TaskCreatedDate!='Yet to start'){
                                extendedObject.showCreatedDate=true;
                                extendedObject.TaskCreatedDate=new Date(extendedObject.TaskCreatedDate).toLocaleDateString('en-GB');
                            }else{
                               extendedObject.showCreatedDate=false; 
                            }
                            if(extendedObject.TaskDueDate!='Yet to start'){
                                extendedObject.showDueDate=true;
                                extendedObject.TaskDueDate=new Date(extendedObject.TaskDueDate).toLocaleDateString('en-GB');
                            }else{
                                extendedObject.showDueDate=false;
                            }
                            if(extendedObject.TaskCompletionDate!='Yet To Complete' && TempArray[j].TaskCompletionDate!='Closer Date OF Task'){
                                extendedObject.showCompletionDate=true;
                                extendedObject.TaskCompletionDate=new Date(extendedObject.TaskCompletionDate).toLocaleDateString('en-GB');
                            }else{
                                extendedObject.showCompletionDate=false;
                            }

                           if(extendedObject.ButtonLabel=='View'){
                              this.AllClosedTask.push(extendedObject);
                           }else if(extendedObject.ButtonLabel=='Edit'){
                               this.AllOpenTask.push(extendedObject);
                           }else if(extendedObject.ButtonLabel=='N/A'){
                               this.AllPendingTask.push(extendedObject);
                           }
                            EmptyArray.push(extendedObject);
                            this.Task_Values.push(extendedObject);  
                        }
                        this.MetaDATA[i].value=EmptyArray;
                        console.log('MetaDATA Values--',this.MetaDATA[i].value);
                        console.log('TempArray--'+JSON.stringify(EmptyArray));
                    }
                }
                console.log('MetaDATA--',this.MetaDATA);
                if(this.AllClosedTask.length > 0 || this.AllOpenTask.length > 0 || this.AllPendingTask.length > 0){
                      this.handleActive();
                }
                if(this.MetaDATA.length!=0 || this.MetaDATA.length>0){
                      this.CalculateProgressbarvalues();
                }
                
        } else if (error) {
            console.log('error--'+this.MetaDATA);
        }

        //this.section=this.Stage_Values;
    }

    HandleExpandCollapse(event){
        debugger;
        let label=event.target.label;
        if(label=='Expand All'){
            
        }
    }

    handleSectionToggle(event){
        debugger;
        let index;
        let Asection= event.detail.openSections;
        this.section =Asection;

       /* let selctedrecord=this.MetaDATA.find(item=>item.key===this.section);
        console.log('selctedrecord--'+JSON.stringify(selctedrecord));
         for(let i=0;i<this.MetaDATA.length;i++){
              if(this.MetaDATA[i].key==this.section){
                  index=i;
                  break;
              }
         }

        this.MetaDATA.splice(index, 1);
        if(selctedrecord!=null && selctedrecord!=undefined){
           this.MetaDATA.splice(0, 0, selctedrecord);
        }*/
     
       //Scroll To Top Of The Page Automatically
       //this.section.scrollIntoView({ behavior: 'smooth'});
       //window.scrollTo({ 0, behavior: "smooth"});
       //window.scroll(0, this.section);
        
    }

    HandleNavigate(event){
        debugger;
         event.preventDefault();
        let componentDef = {
            componentDef: "c:showStageRelatedTask",
            attributes: {
                recordId: this.recordIdvalue,
                showBackquote:true,
                Cardclass:'cardLunchStyle',
                InsidecardClass:'Lunchstyle'
            }
        };
        // Encode the componentDefinition JS object to Base64 format to make it url addressable
        let encodedComponentDef = btoa(JSON.stringify(componentDef));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedComponentDef
            }
        });
        
    }


    HandleNavigateToOpportunity(){
         debugger;  
         
        window.location.href='https://northernarc.lightning.force.com/lightning/r/Opportunity/'+this.recordIdvalue+'/view'
    }

    handleClickNextAction(event){
        debugger;
        let label=event.target.label;
        let recId=event.currentTarget.dataset.id;
        if(label!='N/A'){
              /* console.log('this.Task_Values--'+JSON.stringify(this.Task_Values));
               console.log('this.Task_Values length--'+this.Task_Values.length);
               let Action_Name=this.Task_Values.find(item=>item.TaskId==recId).Action_URL;
               let IsParentTask=this.Task_Values.find(item=>item.TaskId==recId).IsParentTask;
               if(Action_Name!=null && Action_Name!=undefined){
                   let CompName='c__'+Action_Name;

                    const navConfig = {
                            type: "standard__component",
                                attributes: {
                                    componentName: CompName,
                                },
                                state: {
                                    c__id:recId,
                                    c__RelatedId:this.recordId,
                                    c__show_Opp_Button:true,
                                    c__IsParentTask:IsParentTask
                                }   
                            };
                            //4. Invoke Naviate method
                            this[NavigationMixin.Navigate](navConfig);
               }*/
                            let Action_Name='TaskflowfromAura';
                            let CompName='c__'+Action_Name;

                            const navConfig = {
                            type: "standard__component",
                                attributes: {
                                    componentName: CompName,
                                },
                                state: {
                                    c__id:recId,
                                    c__RelatedId:this.recordId
                                }   
                            };
                            //4. Invoke Naviate method
                            this[NavigationMixin.Navigate](navConfig);

            }else{
               this.openAlertModal();
            }
        } 

         async openAlertModal() {
                        const result = await LightningAlert.open({
                            label: 'ALERT ⚠',
                            message: 'Waiting For Dependent Task To Complete Before This Task To Start !!!',
                            theme: 'alt-inverse'
                        });
                // Alert modal has been closed, user clicked 'OK' 
                } 


        //PROGRESS_BAR_VALUE_FOR_EVERY_STAGE
        @track ProgressArray=[];
        CalculateProgressbarvalues(){
            debugger;
           
            this.Stage_Values.forEach((item) => {
                if(item){
                   
                    let opentask=[];
                    let closedtask=[];
                    let pendingtask=[];
                    
                    for(let i=0;i<this.MetaDATA.length;i++){
                        if(this.MetaDATA[i].key==item){

                            let record=Object.assign({}, this.MetaDATA[i]);
                            console.log('record--'+JSON.stringify(record));

                            for(let j=0;j<record.value.length;j++){

                                 if(record.value[j].ButtonLabel=='View'){
                                     closedtask.push(record.value[j]);
                                 }else if(record.value[j].ButtonLabel=='Edit'){
                                     opentask.push(record.value[j]);
                                 }else if(record.value[j].ButtonLabel=='N/A'){
                                     pendingtask.push(record.value[j]);
                                 }

                            }
                               console.log('closedtask==>'+JSON.stringify(closedtask)+'Close task length--'+closedtask.length);
                               console.log('opentask==>'+JSON.stringify(opentask)+'Open task length--'+opentask.length);
                               console.log('pendingtask==>'+JSON.stringify(pendingtask)+'Pending task length--'+pendingtask.length);

                               let opentaskProgressvalues=[];
                               let closetaskProgressvalues=[];
                               let pendingtaskProgressvalues=[];
                              
                            if(opentask.length!=0){
                                let progressobj={status:null,percentage:null,progressbarstyle:null};

                                let open_Task_percent=((opentask.length/record.value.length)*100).toFixed(0);
                                progressobj.status='Open';
                                progressobj.percentage=open_Task_percent+'%'+' '+'('+opentask.length+'/'+record.value.length+')';
                                let style=this.styleforProgressbar+'width:'+open_Task_percent+'%'+';background-color:rgb(100,149,237)';
                                progressobj.progressbarstyle=style;
                                opentaskProgressvalues.push(progressobj);
                            }

                            if(closedtask.length!=0){
                                let progressobj={status:null,percentage:null,progressbarstyle:null};
                                let closed_Task_percent=((closedtask.length/record.value.length)*100).toFixed(0);
                                progressobj.status='Completed';
                                progressobj.percentage=closed_Task_percent+'%'+' '+'('+closedtask.length+'/'+record.value.length+')';
                                let style=this.styleforProgressbar+'width:'+closed_Task_percent+'%'+';background-color:rgb(144,238,144)';
                                progressobj.progressbarstyle=style;
                                closetaskProgressvalues.push(progressobj);
                            }

                            if(pendingtask.length!=0){
                                let progressobj={status:null,percentage:null,progressbarstyle:null};
                                let pending_Task_percent=((pendingtask.length/record.value.length)*100).toFixed(0);
                                progressobj.status='Pending';
                                progressobj.percentage=pending_Task_percent+'%'+' '+'('+pendingtask.length+'/'+record.value.length+')';
                                let style=this.styleforProgressbar+'width:'+pending_Task_percent+'%'+';background-color:#B8B8B8';
                                progressobj.progressbarstyle=style;
                                pendingtaskProgressvalues.push(progressobj);
                            }

                            if(opentaskProgressvalues.length!=0 || closetaskProgressvalues.length!=0 || pendingtaskProgressvalues.length!=0){
                                 this.ProgressArray=[...opentaskProgressvalues, ...closetaskProgressvalues, ...pendingtaskProgressvalues];
                            }
                               
                            console.log('ProgressArray==>'+JSON.stringify(this.ProgressArray)+'ProgressArray length--'+this.ProgressArray.length);
                             this.MetaDATA[i].progressvalue=this.ProgressArray; 
                             this.ProgressArray=[];
                        }
                    }
                    
                   
                }
            })
            console.log('this.MetaDATA--'+JSON.stringify(this.MetaDATA));
            
        }

            handleActive() {
                debugger;
                //OVER_ALL_COMPLETED_TASK
                  if(this.Task_Values.length!=0 && this.AllClosedTask.length!=0){
                      let PercentValue=(this.AllClosedTask.length/this.Task_Values.length)*100;
                      this.OverAll_Completed_Task='--value:'+(PercentValue.toFixed(0));

                      this.LabelALLTask=this.LabelALLTask+' '+'('+this.Task_Values.length+')';
                  }else{
                      this.LabelALLTask=this.LabelALLTask+' '+'('+this.Task_Values.length+')';
                  }
                  

                 
                //OPEN_TASK/CLOSE_TASK/PENDING_TASK
                //All Open Task
                if(this.AllOpenTask.length!=0){
                            this.Stage_Values.forEach((item) => {
                                if(item){
                                    console.log('item==>'+JSON.stringify(item));
                                    let obj;
                                    let stage_RelatedTaskArray=[];
                                    for(let k=0;k<this.AllOpenTask.length;k++){
                                        if(this.AllOpenTask[k].Stage_Step==item){
                                            stage_RelatedTaskArray.push(this.AllOpenTask[k]);
                                        }   
                                    }
                                        obj={key:item,value:stage_RelatedTaskArray};
                                         console.log('obj--'+JSON.stringify(obj));
                                         if(obj.value.length!=0){
                                                this.Open_Task_with_Stage.push(obj);
                                         }
                                }
                    })
                    console.log('Open_Task_with_Stage--'+JSON.stringify(this.Open_Task_with_Stage));
                    this.LabelOpenTask=this.LabelOpenTask+' '+'('+this.AllOpenTask.length+')';
                }else{
                     this.LabelOpenTask=this.LabelOpenTask+' '+'('+this.AllOpenTask.length+')';
                }
                  //All Closed Task
                if(this.AllClosedTask.length!=0){
                     this.Stage_Values.forEach((item) => {
                                if(item){
                                    console.log('item==>'+JSON.stringify(item));
                                    let obj;
                                    let stage_RelatedTaskArray=[];
                                    for(let k=0;k<this.AllClosedTask.length;k++){
                                        if(this.AllClosedTask[k].Stage_Step==item){
                                            stage_RelatedTaskArray.push(this.AllClosedTask[k]);
                                        }   
                                    }
                                        obj={key:item,value:stage_RelatedTaskArray};
                                         console.log('obj--'+JSON.stringify(obj));
                                         if(obj.value.length!=0){
                                                this.Closed_Task_with_Stage.push(obj);
                                         }
                                }
                    })
                    console.log('Closed_Task_with_Stage--'+JSON.stringify(this.Closed_Task_with_Stage));
                   this.LabelCloseTask=this.LabelCloseTask+' '+'('+this.AllClosedTask.length+')';
                }else{
                    this.LabelCloseTask=this.LabelCloseTask+' '+'('+this.AllClosedTask.length+')';
                }   
               //All Pending Task
                if(this.AllPendingTask.length!=0){
                     this.Stage_Values.forEach((item) => {
                                if(item){
                                    console.log('item==>'+JSON.stringify(item));
                                    let obj;
                                    let stage_RelatedTaskArray=[];
                                    for(let k=0;k<this.AllPendingTask.length;k++){
                                        if(this.AllPendingTask[k].Stage_Step==item){
                                            stage_RelatedTaskArray.push(this.AllPendingTask[k]);
                                        }   
                                    }
                                        obj={key:item,value:stage_RelatedTaskArray};
                                         console.log('obj--'+JSON.stringify(obj));
                                         if(obj.value.length!=0){
                                                this.Pending_Task_with_Stage.push(obj);
                                         }
                                }
                    })
                    console.log('Pending_Task_with_Stage--'+JSON.stringify(this.Pending_Task_with_Stage));
                    this.LabelPendingTask=this.LabelPendingTask+' '+'('+this.AllPendingTask.length+')';

                }else{
                    this.LabelPendingTask=this.LabelPendingTask+' '+'('+this.AllPendingTask.length+')';
                }                    
            }  
    }