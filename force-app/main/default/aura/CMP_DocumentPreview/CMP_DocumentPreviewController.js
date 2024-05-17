({
	doInit : function(component, event, helper) {
		  debugger;
        var recordId=component.get("v.recordId");
        console.log('recordId',recordId);
        component.find('lWCComponent3').checkStatusOnLoad ();
	},
    callLWCMethod:function(component, event, helper) {
        debugger;
        var lwcComponent = component.find("lWCComponent3");
        if (lwcComponent) {
            lwcComponent.HandleSavefromAura();
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
            "isclosed_comp_index" : index,
            "isclosed" : isclosed
        });
        compEvent.fire();
    }
})