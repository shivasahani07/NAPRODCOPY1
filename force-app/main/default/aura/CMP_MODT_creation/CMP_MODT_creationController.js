({
    doInit: function(component, event, helper) {
        debugger;
        
        var getMODTCMP= component.find('getMODTCMP');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var taskRec=component.get("v.taskRec");
        helper.getFinancialAccount(component, event, helper,taskRec.WhatId);
    },
    handleLWCLaunched: function(component, event, helper) {
        debugger;
        
    },
    callLWCMethod:function(component, event, helper) {
        debugger;
        var lwcComponent = component.find("getMODTCMP");
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