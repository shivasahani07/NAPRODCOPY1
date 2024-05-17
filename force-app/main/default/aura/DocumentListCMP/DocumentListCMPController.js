({
	doInit:function(component,event,helper){  
        debugger;
        var action = component.get("c.getFiles");  
        action.setParams({  
            "recordId":component.get("v.recordId")  
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){
                var result = response.getReturnValue();  
                console.log('result:Files ',result);  
                component.set("v.files",result);
                component.set("v.count",result.length);
                if(result.length!=0){
                    
                }
            }  
        });
        $A.enqueueAction(action); 
    },
    OpenFile :function(component,event,helper){  
        var rec_id = event.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ //Lightning Openfiles event  
            recordIds: [rec_id] //file id  
        });  
    }
})