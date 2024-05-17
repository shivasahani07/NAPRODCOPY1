({
	doInit : function(component, event, helper) {
        debugger;
        var taskRec = component.get("v.taskRec");
        
            var action = component.get("c.getRecordEditFormDetails");
        action.setParams({
            padId	: component.get("v.PADID"),
            taskId 	: component.get("v.TaskId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tempList = response.getReturnValue();
                for(let i = 0; i < tempList.length; i++){
                    if(taskRec[tempList[i].Mapping_Field_API__c] != undefined){
                       tempList[i].Label_API__c =  taskRec[tempList[i].Mapping_Field_API__c];
                    }
                }
                component.set("v.actionFormList", tempList);
            }
        });
        
        $A.enqueueAction(action);
	},
    
    handleInputChange : function(component, event, helper){
        debugger;
        var name = event.getSource().get("v.value");
        console.log('name::'+name);
    },
    
    SubmitFormDetails : function(component, event, helper){
        debugger;
        var attributeValue = component.get("v.actionFormList");
        console.log('attributeValue::'+attributeValue);
        var action = component.get("c.upsertActionFormDetails");
        action.setParams({
            actionFormDetails : attributeValue,
            taskId : component.get("v.TaskId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.actionFormList", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    }
})