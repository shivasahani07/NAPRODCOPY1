({  
    UpdateDocument : function(component,event,Id) {
        debugger;
        var action = component.get("c.UpdateFiles");  
        //var fName = component.find("fileName").get("v.value");  
        //alert('File Name'+fName);  
        action.setParams({"documentId":Id,  
                          "title": component.get("v.FileName"),  
                          "recordId": component.get("v.recordId"),
                          "Description":component.get("v.fileDescription")
                         });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('Result Returned: ' +result);  
                //component.find("fileName").set("v.value", " ");  
                component.set("v.files",result); 
                if(result.length!=0){
                    component.set("v.HandleResubmittedDisable",false); 
                }else{
                    component.set("v.HandleResubmittedDisable",true); 
                }
            }  
        });  
        $A.enqueueAction(action);  
    }, 
    //Need To Delete
    ModifyOption:function(component, event, helper){
        debugger;
        var Team=component.get("v.QueueList");
        var TempTeamList= component.get("v.AllTeamMembers");
        var SelectedMember=component.get("v.SelectedTeamMembers");
        Team=TempTeamList.filter(elem=>{
            if(!SelectedMember.includes(elem))
            return elem;
        }) 
        component.set("v.QueueList",Team); 
    }
})