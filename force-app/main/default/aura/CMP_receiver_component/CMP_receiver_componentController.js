({
    doInit: function(component, event, helper) {
          debugger;
        component.find('lWCComponent2');
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
        var lwcComponent = component.find("dispatchComp");

        // Call the LWC method
        if (lwcComponent) {
            lwcComponent.updateDcuRecordS();
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