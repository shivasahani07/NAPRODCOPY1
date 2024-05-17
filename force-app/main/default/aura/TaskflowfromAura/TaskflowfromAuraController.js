({
    doInit : function(component, event, helper) {
        debugger;
        let RelatedId;
        let ref = component.get('v.pageReference'); 
        console.log(ref);
        if(ref!=null && ref!=undefined){
            let RecId = ref.state.c__id;
            RelatedId=RecId;
        }else{
            RelatedId= component.get("v.recordId");
        }
        var compName = '';
        var recordId = component.get("v.recordId");
        var flowName = '';
        var action = component.get("c.GettaskDetail");
        action.setParams({ 
            "recordId" : RelatedId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                debugger; 
                var responseValue = response.getReturnValue();
                let obj=responseValue.taskRec;
                if(responseValue.taskRec.hasOwnProperty('Process_Path_Task_Detail__c')==true && responseValue.taskRec.Process_Path_Task_Detail__r.Action_Type__c != null && responseValue.taskRec.Process_Path_Task_Detail__r.Action_Type__c == 'Flow'){
                    flowName = responseValue.taskRec.Process_Path_Task_Detail__r.Action_URL__c;
                }else if(responseValue.taskRec.hasOwnProperty('Process_Attribute_Details__c')==true && responseValue.taskRec.Process_Attribute_Details__r.Action_Type__c == 'Flow'){
                    flowName = responseValue.taskRec.Process_Attribute_Details__r.Action_URL__c;
                }else if(responseValue.taskRec.hasOwnProperty('Process_Path_Task_Detail__c')==true && responseValue.taskRec.Process_Path_Task_Detail__r.Action_Type__c != undefined && responseValue.taskRec.Process_Path_Task_Detail__r.Action_Type__c == 'Component'){
                    compName = 'c:'+responseValue.taskRec.Process_Path_Task_Detail__r.Action_URL__c;
                }else if(responseValue.taskRec.hasOwnProperty('Process_Attribute_Details__c')==true && responseValue.taskRec.Process_Attribute_Details__r.Action_Type__c == 'Component'){
                    compName = 'c:'+responseValue.taskRec.Process_Attribute_Details__r.Action_URL__c;
                }
                if(responseValue.taskRec.hasOwnProperty('Process_Path_Task_Detail__c')==true && responseValue.taskRec.Process_Path_Task_Detail__r.Action_Type__c != undefined){
                    component.set("v.actionType",responseValue.taskRec.Process_Path_Task_Detail__r.Action_Type__c);
                }else{
                    component.set("v.actionType",responseValue.taskRec.Process_Attribute_Details__r.Action_Type__c);
                }
                
                if((responseValue.taskRec.hasOwnProperty('Process_Attribute_Details__c') && responseValue.taskRec.Process_Attribute_Details__r.Action_Type__c == 'Flow')||(responseValue.taskRec.hasOwnProperty('Process_Attribute_Details__c') && responseValue.taskRec.Process_Attribute_Details__r.Action_Type__c == 'Flow')){
                    var inputVariables = [
                        {
                            name : "rv_Task_io",
                            type : "SObject",
                            value : responseValue.taskRec
                        },
                        {
                            name : "v_trigger_object_name_io",
                            type : "String",
                            value : "Task"
                        }
                    ];
                    
                    if(responseValue.taskRec.IsClosed==false){
                        
                        var flow = component.find("OnOpenStatus");
                        console.log ("Delete - SF event status :" + event.getParam('status'));
                        flow.startFlow(flowName,inputVariables);
                        
                    }else if(responseValue.taskRec.IsClosed==true){
                        var Tempflow = component.find("OnOpenStatus");
                        Tempflow.startFlow(flowName, inputVariables);
                        
                    }
                }
                if((responseValue.taskRec.hasOwnProperty('Process_Path_Task_Detail__c') && responseValue.taskRec.Process_Path_Task_Detail__r.Action_Type__c == 'Flow')||(responseValue.taskRec.hasOwnProperty('Process_Path_Task_Detail__c') && responseValue.taskRec.Process_Path_Task_Detail__r.Action_Type__c == 'Flow')){
                    var inputVariables = [
                        {
                            name : "rv_Task_io",
                            type : "SObject",
                            value : responseValue.taskRec
                        },
                        {
                            name : "v_trigger_object_name_io",
                            type : "String",
                            value : "Task"
                        }
                    ];
                    
                    if(responseValue.taskRec.IsClosed==false){
                        
                        var flow = component.find("OnOpenStatus");
                        console.log ("Delete - SF event status :" + event.getParam('status'));
                        flow.startFlow(flowName,inputVariables);
                        
                    }else if(responseValue.taskRec.IsClosed==true){
                        var Tempflow = component.find("OnOpenStatus");
                        Tempflow.startFlow(flowName, inputVariables);
                        
                    }
                }
                if( (responseValue.taskRec.hasOwnProperty('Process_Attribute_Details__c') && responseValue.taskRec.Process_Attribute_Details__r.Action_Type__c == 'Component')||(responseValue.taskRec.hasOwnProperty('Process_Path_Task_Detail__c') && responseValue.taskRec.Process_Path_Task_Detail__r.Action_Type__c == 'Component')){
                    var comp = compName;
                    var RecId=responseValue.taskRec.Id;
                    var isParentTask=responseValue.isParentTask;                        
                        $A.createComponent(
                            comp,{recordId : RecId,IsParentTaskId:isParentTask,currentTaskId:responseValue.currentRecordId,PADID:responseValue.taskRec.Process_Attribute_Details__c,TaskObject:responseValue.taskRec},
                            function(lwcCmp, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    var body = component.get("v.body");
                                    body.push(lwcCmp);
                                    component.set("v.body", body);
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.");
                                }
                                    else if (status === "ERROR") {
                                       console.log("Error: " + errorMessage);
                                    }
                            }
                        );
                    
                }
            } 
        });
        debugger;
        /**/
        
        $A.enqueueAction(action);
        
        
    },
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    statusChange : function (component, event, helper) {
        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Task Updated successfully!",
                type: "success"
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        } else if (event.getParam('status') === "ERROR") {
            component.set("v.hasError", true);
        }
    },
    navigateToMyComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:TaskflowfromAura",
            componentAttributes: {
                recordId : RelatedId
            }
        });
        evt.fire();
    }
    
})