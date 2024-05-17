({
    CreateDynamiccmp:function(component, event, helper,comp,Compcount){
        var CompName=component.get("v.CompName");
        debugger;
        console.log('comp::'+JSON.stringify(comp));
        $A.createComponents(
            comp,
            function(lwcCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    var DynamicCmp = component.get("v.DynamicCmp");
                    for(let i=0;i<Compcount;i++){
                        DynamicCmp.push(lwcCmp[i]);
                    }
                    component.set("v.DynamicCmp", DynamicCmp);
                    console.log('lwcCmp'+(lwcCmp));
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                    else if (status === "ERROR") {
                        console.error("Error: " + errorMessage);
                    }
            }
        );
    },
    loginuser_button_access:function(component, event, helper,childtasklist,loginuser_Related_Group,ParentTask){
        debugger;
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        let tkrecord;
        
        let tkcreator = false;
        let tkreviewer = false;
        
        let shouldSkip = false;
        let show_close_button;
        let Reviewtaskrecords=[]; //Task level review
        let Reviewdocumenttaskrecords=[]; //Document level review
        let deviationdocumenttaskrecords=[]; //documentleveldeviation
        
        if (userId != null) {
            if (ParentTask != null && ParentTask.OwnerId != null) {
                if (ParentTask.OwnerId.startsWith('00G') && loginuser_Related_Group.includes(ParentTask.Owner.Name)) {
                    tkcreator = true;
                    tkrecord = ParentTask;
                } else if (ParentTask.OwnerId.startsWith('005') && ParentTask.OwnerId == userId) {
                    tkcreator = true;
                    tkrecord = ParentTask;
                }
                if(tkrecord!=null && tkrecord!=undefined && tkrecord.Status!=null && tkrecord.Status!=undefined && tkrecord.Status=='Open' && tkcreator==true){
                        component.set("v.IsEdit",true); 
                        component.set("v.tkcreator",true);     
                }
            }
            
            if (tkcreator == false) {
                if (childtasklist.length > 0) {
                    childtasklist.forEach(currentItem => {
                     tkrecord = null;
                     if (currentItem) {
                         if (currentItem.OwnerId != null && currentItem.OwnerId.startsWith('00G') && loginuser_Related_Group.includes(currentItem.Owner.Name)) {
                               tkrecord = currentItem;
                               tkreviewer=true;
                               component.set("v.tkreviewer",true);
                            
                        } else if (currentItem.OwnerId != null && currentItem.OwnerId.startsWith('005') && currentItem.OwnerId == userId) {
                              tkrecord = currentItem 
                              tkreviewer=true;
                              component.set("v.tkreviewer",true);
                        }
                       
                        if (tkrecord != null && tkrecord != undefined) {
                            if(tkrecord.Status!=null && tkrecord.Status=='Submited For Review' && tkrecord.Review_Record_Id__c==null){
                                      Reviewtaskrecords.push(tkrecord);
                            }else if(tkrecord.Status!=null && tkrecord.Status=='Submited For Review' && tkrecord.Review_Record_Id__c!=null){
                                      Reviewdocumenttaskrecords.add(tkrecord);
                            }else if(tkrecord.Status!=null && tkrecord.Status=='Submitted for Deviation Approval' && tkrecord.Review_Record_Id__c!=null){
                                     deviationdocumenttaskrecords.push(tkrecord);
                            }
                       }
                   }
             });
         }
      }
  }
},
    close_master_task:function(component, event, helper){
        debugger;
        var action = component.get("c.close_ParentTask");
        action.setParams({
            "taskid":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                location.reload(); 
            }   
        });
        $A.enqueueAction(action);
    },
    handle_next_on_event:function(component, event, helper){
       debugger;
        var Nextindex;
        var CompName =component.get("v.CompName");
        var Index=component.get("v.componentIndex");
        Nextindex=Index+1;
        CompName[Index].isvisible=false;
        if((CompName.length - 1)>=Nextindex){
            CompName[Nextindex].isvisible=true;
            CompName[Index].islaunched=true;
            component.set("v.CompName",CompName);
            component.set("v.componentIndex",Nextindex);
        }
    }              
})