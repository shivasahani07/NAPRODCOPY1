({
    InitAction : function(component,event,helper) {
        debugger;
        var tkStatus = $A.get("$Label.c.Task_Status_Completed");
        if(tkStatus!=null && tkStatus!=undefined){
            var arr = tkStatus.split(",");
            component.set("v.picklistValues",arr);
        }
    },
    callLWCMethod:function(component,event,helper){
        debugger;
        helper.updateTask(component,event,helper);
    },
    handleSelectedValue:function(component,event,helper){
        debugger;
        var selectedvalue=event.getSource().get("v.value");
        console.log('selectedvalue--',selectedvalue);
        if(selectedvalue==null || selectedvalue==""){
            component.set("v.selectedValue",'');
        }else{
           component.set("v.selectedValue",selectedvalue);  
        }
    }
})