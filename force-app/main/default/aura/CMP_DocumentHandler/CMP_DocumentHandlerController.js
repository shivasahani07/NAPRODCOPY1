({
	doInit: function(component, event, helper) {
          debugger;
        component.find('lWCComponent3').checkStatusOnLoad ();
    },
    /*handleLWCLaunched :function(component, event, helper) {
        debugger;
        
    },*/
    callLWCMethod:function(component, event, helper) {
        debugger;
        var lwcComponent = component.find("lWCComponent3");
        if (lwcComponent) {
            lwcComponent.HandleSavefromAura();
        } else {
            console.error("LWC component not found.");
        }
    },
    handleLWCLaunched:function(component, event, helper) {
        debugger;
        var isclosed = event.getParam('isclosed');
        var index = event.getParam('index');
        var compEvent=component.getEvent("compEvent");
        compEvent.setParams({
            "isclosed_comp_index" : index,
            "isclosed" : isclosed
        });
        compEvent.fire();
        //this.call_parent_event(component, event, helper,isclosed);
    }
})