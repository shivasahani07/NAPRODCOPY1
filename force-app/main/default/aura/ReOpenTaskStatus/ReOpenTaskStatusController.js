({
	doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.StatusUpadteToReopen");
        action.setParams({ 
            "TaskId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
               $A.get("e.force:closeQuickAction").fire();
                window.location.reload();
            }else{
                $A.get("e.force:closeQuickAction").fire()
            }    
        });
        $A.enqueueAction(action);
		
	}
})