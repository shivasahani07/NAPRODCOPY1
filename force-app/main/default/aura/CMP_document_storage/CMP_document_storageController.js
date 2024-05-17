({
    doInit: function(component, event, helper) {
        debugger;
        component.find('lWCComponent2');
        /*var action = component.get("c.getTaskRecirdbyId");
        action.setParams({ taskId : component.get("v.taskRecId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set("v.taskRec",response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
         $A.enqueueAction(action);*/
    },
    handleLWCLaunched: function(component, event, helper) {
        debugger;
        var isLWCLaunched = event.getParam('isLWCLaunched');
        var wrapperData= event.getParam('wrapperData');
        console.log('wrapperData--'+wrapperData);
        component.set("v.initFunctionality", isLWCLaunched);
        
        component.set("v.wrapperData", wrapperData);
    },
    callLWCMethod: function(component, event, helper) {
        // Get the reference to the LWC component
        debugger;
        var lwcComponent = component.find("lWCComponent2");
        
        // Call the LWC method
        if (lwcComponent) {
            lwcComponent.updateDocuemtStorageDetails();
        } else {
            console.error("LWC component not found.");
        }
    },
    getValueFromLwc:function(component, event, helper) {
        debugger;
        var isclosed = event.getParam('isclosed');
        var index = event.getParam('index');
        var compEvent=component.getEvent("compEvent");
        compEvent.setParams({
            "isclosed_comp_index" :index,
            "isclosed" : isclosed
        });
        compEvent.fire();
    }
})