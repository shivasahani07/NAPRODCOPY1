({
	getFinancialAccount : function(component, event, helper,whatId) {
        debugger;
        var action = component.get("c.getFinancialAccId");  
        action.setParams({  
            "whatId":whatId  
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                component.set("v.financialAccountId",response.Id);
                component.set("v.FinancialAccount",response); 
            }
        });
		$A.enqueueAction(action);  
	}
})