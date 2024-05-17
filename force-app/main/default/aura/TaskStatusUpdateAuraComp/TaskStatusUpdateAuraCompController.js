({
    fetchPicklistValues : function(component, event, helper) {
        debugger;
        let ref = component.get('v.pageReference'); 
        if(ref!=null && ref!=undefined){
            let RecId = ref.state.c__id;
            let Booleanvalue=ref.state.c__show_Opp_Button;
            component.set("v.recordId",RecId);
            component.set("v.NavigateToOpportunity",Booleanvalue);
        }
        var action= component.get("c.getAccRatings");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var mapValues = response.getReturnValue();
                component.set("v.mapPicklistValues", mapValues);
                let picklistValuesList = [];
                for(let key in mapValues){
                    picklistValuesList.push(mapValues[key]);
                }
                component.set("v.picklistValues", picklistValuesList);
            }
        });
        
            var newaction1 = component.get('c.CurrentUserEdit');
            $A.enqueueAction(newaction1);


         var newaction = component.get('c.CallProcessAttributeDetail');
         $A.enqueueAction(newaction);
        
        var ReviewerDetail = component.get('c.fetchReviewersDetail');
         $A.enqueueAction(ReviewerDetail);
        
        
        $A.enqueueAction(action); 
    },
    CallProcessAttributeDetail:function(component,event,helper){
        debugger;
         var action = component.get("c.returnWrapper");  
        action.setParams({  
            "TaskId":component.get("v.recordId")  
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('result: Process',result);
                
                console.log('result Reviewer: ',result.PrDetail.Task_Reviwer_Type__c);
                 component.set("v.TaskReviewerType",result.PrDetail.Task_Reviwer_Type__c);
                /*component.set("v.LoginUserId",result.LoginUserId);
                component.set("v.TaskOwnerId",result.TaskRecord.OwnerId);
                component.set("v.TaskStatus",result.TaskRecord.Status);*/
                component.set("v.TaskObject",result.TaskRecord);
                component.set("v.UserRec",result.UserRecord);
                
                 
            }  
        });
        $A.enqueueAction(action); 
    },
    fetchReviewersDetail:function(component, event, helper){
		debugger;
        var RecordId=component.get("v.recordId");
        var action = component.get("c.WrapperClassReviewerDetail");
        action.setParams({ 
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
              if(state==='SUCCESS'){
                    var responseValue = response.getReturnValue();
                      console.log('responseValue ReviewerList--',responseValue);
                      console.log('responseValue RecordId--',RecordId);
                      console.log('responseValue RecordId whatId--',responseValue.TaskRecord.WhatId);
                      component.set("v.ReviewerList",responseValue.UserRecList);
                      component.set("v.SelectedWhatId",responseValue.TaskRecord.WhatId);
                  
              }    
        });
        $A.enqueueAction(action);
	},
    handleSelected : function(component, event, helper){
        debugger;
        let currentValue = event.target.value;
        let mapValues = component.get("v.mapPicklistValues");
        let selectedValue;
        for(let key in mapValues){
            if(currentValue == mapValues[key]){
                selectedValue = key;
                break;
            }
        }
        component.set("v.selectedValue", selectedValue);
    },
    updateTask : function(component, event, helper){
        debugger;
        var action = component.get("c.updatetaskStatus");
        action.setParams({
            recordId : component.get("v.recordId"),
            status : component.get("v.selectedValue")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var data = response.getReturnValue();
                if(data !=null){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'SUCCESS',
                        message: 'Status updated Successfully !',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();
                    if(data.WhatId !=null && data.WhatId != undefined){
                        window.location.href='/lightning/r/Opportunity/'+data.WhatId+'/view';
                    }else{
                        alert("WhatId Not Found")
                    }
                }
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
            
        });
        $A.enqueueAction(action); 
    },
    
    Cancel : function(component, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    handleSelectedValue:function(component, event, helper){
        debugger;
        var selectedvalue=event.getSource().get("v.value");
        console.log('selectedvalue--',selectedvalue);
        //alert(selectedvalue);
        if(selectedvalue==null || selectedvalue==""){
           //component.set("v.EnableButton",true);
            component.set("v.ShowReviewerCmp",false);
             component.set("v.selectedValue",'');
            
        }else{
           //component.set("v.EnableButton",false);
            component.set("v.ShowReviewerCmp",true);
           component.set("v.selectedValue",selectedvalue);
            
        }
    },
    handleClick:function(component, event, helper){
        debugger;
        component.set("v.ModalPopUp",true); 
    },
    closeModel:function(component, event, helper){
        debugger;
         component.set("v.ModalPopUp",false);
    },
     handleClickApprove:function(component, event, helper){ 
        debugger;
         var action = component.get("c.UpdateTaskStatusInApprove");
        var Comment=component.get("v.CommentValue"); 
        action.setParams({  
            "TaskIdValue":component.get("v.recordId"),
            "ApproverStatus":'Approved', 
            "Comment":Comment
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                 $A.get("e.force:closeQuickAction").fire(); 
                var data = response.getReturnValue();
                    if(data.WhatId !=null && data.WhatId != undefined){
                        window.location.href='/lightning/r/Opportunity/'+data.WhatId+'/view';
                    }else{
                        alert("WhatId Not Found")
                    }
             }  
        });
        $A.enqueueAction(action);
    },
    handleClickReject:function(component, event, helper){ 
        debugger;
        var Comment=component.get("v.CommentValue");
        //component.set("v.ShowButtons",false);
        if(Comment==null){
            
            component.set("v.ShowCommentBox",true);
            
        }else{
            component.set("v.ShowCommentBox",false);
            var action = component.get("c.UpdateTaskStatusInApprove");
            action.setParams({  
                "TaskIdValue":component.get("v.recordId"),
                "ApproverStatus":'Rejected', 
                "Comment":Comment 
            });      
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state=='SUCCESS'){  
                    $A.get("e.force:closeQuickAction").fire(); 
                    var data = response.getReturnValue();
                    if(data.WhatId !=null && data.WhatId != undefined){
                        window.location.href='/lightning/r/Opportunity/'+data.WhatId+'/view';
                    }else{
                        alert("WhatId Not Found")
                    }
                }  
            });
            $A.enqueueAction(action);
        }
         
    },
    handleClickReAssign:function(component, event, helper){ 
        debugger;
        var Comment=component.get("v.CommentValue");
        component.set("v.Approve",true);
        component.set("v.RejectButton",true);
        if(Comment==null){
            
            component.set("v.ShowCommentBox",true);
            
        }else{
            component.set("v.ShowCommentBox",false);
            var action = component.get("c.UpdateTaskStatusInApprove");
            action.setParams({  
                "TaskIdValue":component.get("v.recordId"),
                "ApproverStatus":'ReAssign', 
                "Comment":Comment 
            });      
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state=='SUCCESS'){  
                    $A.get("e.force:closeQuickAction").fire();
                    var data = response.getReturnValue();
                    if(data.WhatId !=null && data.WhatId != undefined){
                        window.location.href='/lightning/r/Opportunity/'+data.WhatId+'/view';
                    }else{
                        alert("WhatId Not Found")
                    }
                }  
            });
            $A.enqueueAction(action);
        }
         
    },
    handleReviewer:function(component, event, helper){
        debugger;
        var selectedvalue=event.getSource().get("v.value");
        console.log('selectedvalue--',selectedvalue);
        //alert(selectedvalue);
        if(selectedvalue=='choose one'){
           component.set("v.SelectedReviewerId",null); 
        }else{
           component.set("v.SelectedReviewerId",selectedvalue); 
        }   
    },
    handleClickSave:function(component, event, helper){
        debugger;
            var action = component.get("c.PassValueForApproval");
            action.setParams({ 
                "TaskId" : component.get("v.recordId"),
                "SelectReviewer":component.get("v.SelectedReviewerId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state==='SUCCESS'){
                    $A.get("e.force:closeQuickAction").fire();
                    var data = response.getReturnValue();
                    if(data.WhatId !=null && data.WhatId != undefined){
                        window.location.href='/lightning/r/Opportunity/'+data.WhatId+'/view';
                    }else{
                        alert("WhatId Not Found")
                    }
                }    
            });
            $A.enqueueAction(action);  
       },
    CurrentUserEdit:function(component, event, helper){
        debugger;
         var action = component.get("c.CallCheckCurrentUserEditRight");  
        action.setParams({  
            "TaskId":component.get("v.recordId")  
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('Boolean Result::',result); 
                component.set("v.CurrentUserEdit",result); 
            }  
        });
        $A.enqueueAction(action); 
    },
    HandleNavigateToOpportunity:function(component, event, helper){
        debugger;
        let ref = component.get('v.pageReference'); 
        if(ref!=null && ref!=undefined){
            let RecId = ref.state.c__RelatedId;
            window.location.href='https://northernarc--narcdevpro.sandbox.lightning.force.com/'+RecId;
            //window.location.href='https://northernarc--narcdevpro.sandbox.lightning.force.com/one/one.app#eyJjb21wb25lbnREZWYiOiJjOnNob3dTdGFnZVJlbGF0ZWRUYXNrIiwiYXR0cmlidXRlcyI6eyJyZWNvcmRJZCI6IjAwNkJsMDAwMDA0U2NvMklBQyIsInNob3dCYWNrcXVvdGUiOnRydWUsIkNhcmRjbGFzcyI6ImNhcmRMdW5jaFN0eWxlIiwiSW5zaWRlY2FyZENsYXNzIjoiTHVuY2hzdHlsZSJ9LCJzdGF0ZSI6e319';
        }
    }
    
})