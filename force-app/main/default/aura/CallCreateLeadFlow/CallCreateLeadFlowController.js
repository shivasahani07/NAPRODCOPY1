({
	doInit : function(component, event, helper) {
        debugger;
        var flow = component.find("CreateLeadFlow");
        flow.startFlow("SF_New_Lead_Creation");
		
	},
    statusChange : function(component, event, helper){
        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "message",
                type: "success"
            });
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();
        } else if (event.getParam('status') === "ERROR") {
            component.set("v.hasError", true);
        }
    }
})