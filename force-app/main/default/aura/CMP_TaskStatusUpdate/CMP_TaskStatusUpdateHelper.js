({  
    updateTask : function(component, event, helper){
        debugger;
        var index = component.get("v.Index")
        var recordId = component.get("v.recordId");
        var tKids=[];  tKids.push(recordId);
        var action = component.get("c.UpdateTaskStatus");
        action.setParams({
            ApproverStatus : component.get("v.selectedValue"),
            TaskIdset      : tKids
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var data = response.getReturnValue();
                if(data !=null && data !=undefined && data.length>0){
                    this.showWarning(component, event, helper,'Status updated Successfully !','success','SUCCESS');
                    this.passcomponent_status_to_Parent(component, event, helper,index,true);
                }
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {alert(errors[0].message);}
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }  
        });
        $A.enqueueAction(action); 
    },
    passcomponent_status_to_Parent:function(component, event, helper,index,isclosed_value){
        debugger;
        var compEvent=component.getEvent("compEvent");
        compEvent.setParams({
            "isclosed_comp_index" : index,
            "isclosed":isclosed_value
        });
        compEvent.fire();
    },
    showWarning : function(component, event, helper,message,type,title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'sticky'
        });
        toastEvent.fire();
    }
})