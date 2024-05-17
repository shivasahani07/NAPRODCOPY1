({
    doInit : function(component, event, helper) {
        debugger;
        var IndexCompName=component.get("v.IndexCompName");
        var mapOfIndexByCompName = [];
        var RecId=component.get("v.recordId");
        var Index=component.get("v.componentIndex");
        var CompName=component.get("v.CompName")
        var getCompNameByIndex;
        var ListCompName=[];
        var IsParentTaskId = component.get("v.IsParentTaskId");
        
        var action = component.get("c.getPRocessAttributeDetails");
        action.setParams({
            "recId": RecId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                let progressbarvalues = [];
                helper.loginuser_button_access(component, event, helper,response.childTasklist,response.loginUser_associated_Groups,component.get("v.TaskObject"));
                let isreviewer_isDeviation_isviewer=component.get("v.IsEdit");
                if(response.listOfProcessComp.length > 0){
                    for(let i=0;i<response.listOfProcessComp.length;i++){
                        progressbarvalues.push(response.listOfProcessComp[i].Name__c);
                        if(i==0){
                            CompName.push({index:i,isvisible:true,islaunched:false,cmpName:response.listOfProcessComp[i].Name__c});
                        }else{
                            if(isreviewer_isDeviation_isviewer==false){
                               CompName.push({index:i,isvisible:true,islaunched:false,cmpName:response.listOfProcessComp[i].Name__c,isClosed:false}); 
                            }else{
                               CompName.push({index:i,isvisible:false,islaunched:false,cmpName:response.listOfProcessComp[i].Name__c,isClosed:false});  
                            } 
                        }
                        component.set("v.CompName",CompName);
                        mapOfIndexByCompName.push({value:progressbarvalues[i], key:i});

                        let cmp='c:'+ response.listOfProcessComp[i].Name__c; 
                        let array=[];
                        //array.push(cmp,{"recordId":response.taskRec.Id,"taskRec":response.taskRec,"initFunctionalityFlag":true,"IsParentTaskId":component.get("v.IsParentTaskId"),"currentTaskId":component.get("v.currentTaskId"),"LoginUserRelatedGroup":response.loginUser_associated_Groups,"IsSubmitVisible":component.get("v.IsSubmitVisible"),"Index":i})
                        array.push(cmp,{"recordId":response.taskRec.Id,"taskRec":response.taskRec,"initFunctionalityFlag":true,"LoginUserRelatedGroup":response.loginUser_associated_Groups,"IsEdit":component.get("v.IsEdit"),"Index":i,"tkcreator":component.get("v.tkcreator"),"tkreviewer":component.get("v.tkreviewer"),"UploadtaskId":component.get("v.currentTaskId")});
                        ListCompName.push(array);
                    }
                    if(ListCompName.length>0)
                      helper.CreateDynamiccmp(component, event, helper,ListCompName,ListCompName.length);
                }
                console.log('progressbarvalues::'+progressbarvalues);
                component.set("v.taskRec",response.taskRec);
                component.set("v.recordId",response.taskRec.Id);
                component.set("v.IndexCompName",mapOfIndexByCompName);
                component.set("v.ProgressBarValues",progressbarvalues);
            } else {
                console.error('Error calling Apex method.');
            }
        });
        
        $A.enqueueAction(action);
    },
    HandleNext:function(component, event, helper) {
        debugger;
        var CompName =component.get("v.CompName");
        var compNameList = [];
        var Index=component.get("v.componentIndex");
        console.log('CompName::'+CompName[Index].cmpName);
        var childComponents = CompName[Index].cmpName;
        var dynamicChildComponents = component.get("v.DynamicCmp");
        if (dynamicChildComponents && dynamicChildComponents.length> 0) {
            dynamicChildComponents[Index].callChildAuraMethod();
        }
        
        /* Commented on 20-02-2023 By Amar 
         * if(CompName[Index].isClosed){
            var Nextindex;
            var IndexCompName=component.get("v.IndexCompName");
            var getCompNameByIndex;
            Nextindex=Index+1;
            component.set("v.componentIndex",Nextindex);
            CompName[Index].isvisible=false;
            CompName[Nextindex].isvisible=true;
            CompName[Index].islaunched=true;
            component.set("v.CompName",CompName);
        }*/
    },
    HandlePrevious:function(component, event, helper) {
        debugger;
        var CompName =component.get("v.CompName");
        var Index=component.get("v.componentIndex");
        var PreviousIndex;
        var IndexCompName=component.get("v.IndexCompName");
        var getCompNameByIndex;
        if(Index>=1){
            PreviousIndex=Index-1;
        }
        component.set("v.componentIndex",PreviousIndex);
        CompName[Index].isvisible=false;
        CompName[PreviousIndex].isvisible=true;
        CompName[PreviousIndex].isClosed=false; //New add 19-02-2023 By Amar
        CompName[Index].islaunched=true;
        component.set("v.CompName",CompName);
        
    },
    handleCmpEvent: function(component, event,helper) {
        debugger;
        var Parent_TaskRec=component.get("v.TaskObject");
        let Counter=0;
        var index = event.getParam("isclosed_comp_index");
        var isclosed = event.getParam("isclosed");
        var CompName =component.get("v.CompName");
        CompName[index].isClosed=isclosed;    
        component.set("v.CompName",CompName); 
        
        if(CompName.length>0){
            for(let i=0;i<CompName.length;i++){ 
                if(CompName[i].isClosed==true){
                    Counter++
                } 
            }
        }
        if(Parent_TaskRec.Id!=null && Parent_TaskRec.Id!=undefined && Parent_TaskRec.Status=='Submited For Review'){
            let lastcomp_isclosed_value = CompName[CompName.length - 1].isClosed;
            if(lastcomp_isclosed_value){
                 helper.close_master_task(component, event, helper);
            }
        }else{
            if(CompName.length==Counter){
                helper.close_master_task(component, event, helper);
            }else if(CompName.length!=Counter && component.get("v.IsEdit")==true){
                helper.handle_next_on_event(component, event, helper); //New Added By Amar
            } 
        }
    },
    HandleSave:function(component, event, helper){
        debugger;
        let Counter=0;
        var CompName =component.get("v.CompName");
        var Index=component.get("v.componentIndex");
        console.log('CompName::'+CompName[Index].cmpName);
        var childComponents = CompName[Index].cmpName;
        var dynamicChildComponents = component.get("v.DynamicCmp");
        if (dynamicChildComponents && dynamicChildComponents.length > 0) {
            dynamicChildComponents[Index].callChildAuraMethod();
        }
    },
    Handleclose:function(component, event, helper){
        debugger;
        $A.get("e.force:closeQuickAction").fire();
        var taskrec=component.get("v.TaskObject");
        var SourceOrgURL = $A.get("$Label.c.OpportunityUrl");
        window.location.href=SourceOrgURL+taskrec.WhatId;
    },
    Preview:function(component, event, helper){
        debugger;
        var CompName =component.get("v.CompName");
        if(CompName.length>0){
            for(let i=0;i<CompName.length;i++){
                CompName[i].isvisible=true;
            }
        }
        component.set("v.CompName",CompName);
    }
})