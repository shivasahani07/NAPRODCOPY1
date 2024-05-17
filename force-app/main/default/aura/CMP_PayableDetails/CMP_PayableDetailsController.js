({
    doInit: function(component, event, helper) {
        debugger;
         var taskRec=component.get("v.taskRec");
         component.set("v.opportunityId", taskRec.WhatId);
         console.log('recordid Aura',component.get("v.recordId"));
         component.find('lWCComponent2').checkStatusOnLoad ();
         console.log('taskRec',taskRec); 
    },
    handleLWCLaunched: function(component, event, helper) {
        debugger;
        var isLWCLaunched = event.getParam('isLWCLaunched');
        var payAblesList= event.getParam('payAblesList');
        var finalData= event.getParam('finalData');
        console.log('payAblesList--'+payAblesList);
        component.set("v.initFunctionality", isLWCLaunched);
        
        component.set("v.payAblesList", payAblesList);
        component.set("v.finalData", finalData);
    },
    callLWCMethod: function(component, event, helper) {
        // Get the reference to the LWC component
        debugger;
        var lwcComponent = component.find("lWCComponent2");
        
        // Call the LWC method
        if (lwcComponent) {
            lwcComponent.handleSaveAction();
        } else {
            console.error("LWC component not found.");
        }
    },
    getValueFromLwc : function(component, event, helper) {
        //component.set("v.IsClosed",event.getParam('value'));
        var isclosed = event.getParam('isclosed');
        var index = event.getParam('index');
        var compEvent=component.getEvent("compEvent");
        compEvent.setParams({
            "isclosed_comp_index" : index,
            "isclosed" : isclosed
        });
        compEvent.fire();
    }
})