({  
    doInit:function(component,event,helper){  
        debugger;
        let ref = component.get('v.pageReference'); 
        if(ref!=null && ref!=undefined){
            let RecId = ref.state.c__id;
            let Booleanvalue=ref.state.c__show_Opp_Button;
            let IsParentTaskValue=ref.state.c__IsParentTask;
            component.set("v.recordId",RecId);
            component.set("v.NavigateToOpportunity",Booleanvalue);
            component.set("v.IsParentTaskId",IsParentTaskValue);
        }
        //component.set("v.IsParentTaskId",isParentTask);
        var BoolaeanIdValue=component.get("v.IsParentTaskId");
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
                
                if(result.length!=0){
                     component.set("v.HandleResubmittedDisable",false); 
                }else{
                    component.set("v.HandleResubmittedDisable",true); 
                }
            }  
        });
        
        var newaction1 = component.get('c.CurrentUserEdit');
        $A.enqueueAction(newaction1);
        
        var PickListDetail = component.get('c.fetchPicklistValues');
        $A.enqueueAction(PickListDetail);
        
        var newaction = component.get('c.CallProcessAttributeDetail');
        $A.enqueueAction(newaction);
        
        
        var ReviewerDetail = component.get('c.fetchReviewersDetail');
        $A.enqueueAction(ReviewerDetail);
        
        
        
        $A.enqueueAction(action);  
    },  
    //Open File onclick event
    CallProcessAttributeDetail:function(component,event,helper){
        debugger;
        var finaluserIds = component.get("v.finalUserIds");
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
                console.log('result Reviewer: ',result.PrDetail.Task_Reviewer_Name__c);
                component.set("v.TaskReviewerType",result.PrDetail.Task_Reviwer_Type__c); 
                component.set("v.LoginUserId",result.LoginUserId);
                component.set("v.TaskOwnerId",result.TaskRecord.OwnerId);
                component.set("v.TaskStatus",result.TaskRecord.Status);
                component.set("v.TaskObject",result.TaskRecord);
                component.set("v.UserRec",result.UserRecord);
                component.set("v.RelatedId",result.TaskRecord.WhatId);
                
                let QueueList=result.queueOptionList;
                let UserList=result.userOPtionList;
                
                component.set("v.AllUserList",UserList);
                component.set("v.AllQueueList",QueueList);
                
                var TempArr=[];
                if(result.ChildTaskRecords == undefined){
                    if((result.PrDetail.Task_Reviwer_Type__c!=null || result.PrDetail.Task_Reviwer_Type__c!=undefined)&&(result.PrDetail.Task_Reviewer_Name__c!=null || result.PrDetail.Task_Reviewer_Name__c!=undefined)){
                        let arr=result.PrDetail.Task_Reviewer_Name__c.split(',');
                        
                        if(arr.length>0){
                            var data = component.get("v.data");
                            for(let i=0;i<arr.length;i++){
                                let arrD=[];
                                if(result.PrDetail.Task_Reviwer_Type__c=='Queue'){
                                    let GroupId=QueueList.find(item=>item.Name==arr[i]).Id;
                                    arrD.push({name:arr[i],id:GroupId});
                                }else{
                                    let UserId=UserList.find(item=>item.Name==arr[i]).Id; 
                                    arrD.push({name:arr[i],id:UserId});
                                }
                                data.push({ type:result.PrDetail.Task_Reviwer_Type__c, userOrQueue:arr[i], userOrQueueOptions:arrD,selectedUserOrQueueId:arrD[0].id,disabled:true});
                                finaluserIds.push(arrD[0].id);
                            }
                        }
                        component.set("v.data",data);
                        component.set("v.finalUserIds",finaluserIds);
                    } 
                }
                if(result.TaskRecord.Process_Attribute_Details__r.Task_Reviewer_Name__c==null || result.TaskRecord.Process_Attribute_Details__r.Task_Reviewer_Name__c==undefined){
                    component.set("v.IsTaskReviewerNameExist",false);
                }else if(result.TaskRecord.Process_Attribute_Details__r.Task_Reviewer_Name__c!=null || result.TaskRecord.Process_Attribute_Details__r.Task_Reviewer_Name__c!=undefined){
                    component.set("v.IsTaskReviewerNameExist",true);
                }
                
                if(result.ChildTaskRecords!=null && result.ChildTaskRecords!=undefined){             
                    var ChildTaskOwnerName=result.ChildTaskRecords;
                    if(ChildTaskOwnerName.length!=0){
                        for(let j=0;j<ChildTaskOwnerName.length;j++){
                            if(ChildTaskOwnerName[j].Status=='Submited For Review'){
                                ChildTaskOwnerName[j].RowBackgroundColor='background-color:grey';
                                ChildTaskOwnerName[j].Selected=false;
                                ChildTaskOwnerName[j].disableCheckbox=true;
                                
                            }else if(ChildTaskOwnerName[j].Status=='Rejected'){
                                ChildTaskOwnerName[j].RowBackgroundColor='background-color:Red';
                                ChildTaskOwnerName[j].Selected=false;
                                ChildTaskOwnerName[j].disableCheckbox=true;
                                
                            }else if(ChildTaskOwnerName[j].Status=='Completed'){
                                ChildTaskOwnerName[j].RowBackgroundColor='background-color:Green';
                                ChildTaskOwnerName[j].Selected=false;
                                ChildTaskOwnerName[j].disableCheckbox=true;
                                
                            }else if(ChildTaskOwnerName[j].Status=='ReAssign'){
                                ChildTaskOwnerName[j].RowBackgroundColor='background-color:Orange';
                                ChildTaskOwnerName[j].Selected=false;
                                ChildTaskOwnerName[j].disableCheckbox=false;
                                
                            }else if(ChildTaskOwnerName[j].Status=='Open'){
                                ChildTaskOwnerName[j].RowBackgroundColor='background-color:yellow';
                                ChildTaskOwnerName[j].Selected=false;
                                ChildTaskOwnerName[j].disableCheckbox=true;
                            }
                        }
                        console.log('ChildTaskOwnerName After backgroundColor--'+JSON.stringify(ChildTaskOwnerName));
                        component.set("v.ChildTaskOwnerName",ChildTaskOwnerName);
                    }
                }
                
            }  
        });
        $A.enqueueAction(action); 
    },
    selectSingleOptionRec:function(component, event, helper){
        debugger;
        var selectedTaskId=component.get("v.selectedTaskId");
        var checkbox = event.getSource();
        console.log(checkbox.get("v.value"));
        var selIdx = event.getSource().get("v.text");
        if(checkbox.get("v.value")==true){
            
            selectedTaskId.push(selIdx);
            
        }else if(checkbox.get("v.value")==false){
            if(selectedTaskId.find(item=>item==selIdx)){
                selectedTaskId = selectedTaskId.filter(item => item !== selIdx);
            }
        }
        console.log('selectedTaskId--'+JSON.stringify(selectedTaskId));
        component.set("v.selectedTaskId",selectedTaskId);
    },
    fetchReviewersDetail:function(component, event, helper){
        debugger;
        var action = component.get("c.WrapperClassReviewerDetailFromApex");
        action.setParams({ 
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                console.log('responseValue ReviewerList--',responseValue);
                console.log('responseValue Reviewer User List--',responseValue.UserRecList);
                //console.log('responseValue RecordId--',RecordId);
                console.log('responseValue RecordId whatId--',responseValue.TaskRecord.WhatId);
                component.set("v.ReviewerList",responseValue.UserRecList);
                component.set("v.SelectedWhatId",responseValue.TaskRecord.WhatId);
                component.set("v.QueueList",responseValue.QueueList);
                component.set("v.AllTeamMembers",responseValue.QueueList);
                
            }    
        });
        $A.enqueueAction(action);
    },
    OpenFile :function(component,event,helper){  
        var rec_id = event.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ //Lightning Openfiles event  
            recordIds: [rec_id] //file id  
        });  
    },  
    UploadFinished : function(component, event, helper) {  
        var uploadedFiles = event.getParam("files"); 
        var reveiewerType=component.get("v.TaskReviewerType")
        if(uploadedFiles!=null && (reveiewerType!=null || reveiewerType!=undefined)){
            component.set("v.EnableButton",false);
        }
        var documentId = uploadedFiles[0].documentId;  
        var fileName = uploadedFiles[0].name;
        component.set("v.FileName",fileName);
        helper.UpdateDocument(component,event,documentId);  
        var toastEvent = $A.get("e.force:showToast");  
        toastEvent.setParams({  
            "title": "Success!",  
            "message": "File "+fileName+" Uploaded successfully."  
        });  
        toastEvent.fire();  
        /* Open File after upload  
     $A.get('e.lightning:openFiles').fire({  
       recordIds: [documentId]  
     });*/  
    },
    handleClick:function(component, event, helper){ 
        debugger;
        component.set("v.ShowReviewerCmp",true);
        component.set("v.ModalPopUp",true);
        
        var childTaskRecord = event.currentTarget.dataset.value;
        debugger;
    },
    handleClickApprove:function(component, event, helper){ 
        debugger;
        var action = component.get("c.UpdateTaskStatus");
        var currentTaskId = component.get("v.currentTaskId");
        var Comment=component.get("v.CommentValue"); 
        action.setParams({  
            "TaskIdValue":component.get("v.recordId"),
            "ApproverStatus":'Approved', 
            "Comment":Comment,
            "currentTaskId":currentTaskId
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
        var currentTaskId = component.get("v.currentTaskId");
        //component.set("v.ShowButtons",false);
        if(Comment==null){
            
            component.set("v.ShowCommentBox",true);
            
        }else{
            component.set("v.ShowCommentBox",false);
            var action = component.get("c.UpdateTaskStatus");
            
            action.setParams({  
                "TaskIdValue":component.get("v.recordId"),
                "ApproverStatus":'Rejected', 
                "Comment":Comment,
                "currentTaskId":currentTaskId 
            });      
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state=='SUCCESS'){  
                    $A.get("e.force:closeQuickAction").fire();
                    var data = response.getReturnValue();
                    console.log('data--',data);
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
        var currentTaskId = component.get("v.currentTaskId");
        if(Comment==null){
            
            component.set("v.ShowCommentBox",true);
            
        }else{
            component.set("v.ShowCommentBox",false);
            var action = component.get("c.UpdateTaskStatus");
            action.setParams({  
                "TaskIdValue":component.get("v.recordId"),
                "ApproverStatus":'ReAssign', 
                "Comment":Comment,
                "currentTaskId":currentTaskId
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
    closeModel:function(component, event, helper){
        debugger;
        component.set("v.ModalPopUp",false);
    },
    //Need To Delete
    handleReviewer:function(component, event, helper){
        debugger;
        var SelectedMember=component.get("v.SelectedTeamMembers");
        var selectedvalue=event.getSource().get("v.value");
        console.log('selectedvalue--',selectedvalue);
        //alert(selectedvalue);
        if(selectedvalue=='choose one'){
            component.set("v.SelectedReviewerId",null); 
        }else{
            component.set("v.SelectedReviewerId",selectedvalue);
            
            if(selectedvalue!=''){
                if(!SelectedMember.includes(selectedvalue))
                    SelectedMember.push(selectedvalue);
                component.set("v.SelectedTeamMembers",SelectedMember); 
            }
            helper.ModifyOption(component, event, helper);
        }   
        
    },
    //Need To Delete
    clear:function(component, event, helper) {
        debugger;
        var SelectedMember = component.get("v.SelectedTeamMembers");
        var selectedPillName = event.getSource().get("v.name");
        SelectedMember.splice(SelectedMember.indexOf(selectedPillName),1);
        component.set("v.SelectedTeamMembers",SelectedMember);
        helper.ModifyOption(component, event, helper);
        
    },
    updateTask : function(component, event, helper){
        debugger;
        var action = component.get("c.updatetaskStatusValue");
        action.setParams({
            recordId :component.get("v.recordId"),
            status : 'Completed'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var data = response.getReturnValue();
                if(data==null){
                    component.set("v.ErrorMessageInMarkCompleteed",true); 
                    window.setTimeout(
                        $A.getCallback(function() {
                            component.set("v.ErrorMessageInMarkCompleteed",false);
                        }),900     
                    );
                }
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
    handleClickSave:function(component, event, helper){
        debugger;
        var ReviewerId=component.get("v.finalUserIds");
        var reviewerTeamName = component.get("v.SelectedTeamMembers");
        if(ReviewerId==null){
            
        }else{
            var action = component.get("c.PassValueForApproval");
            action.setParams({ 
                "TaskId" : component.get("v.recordId"),
                "SelectReviewer":component.get("v.finalUserIds")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state==='SUCCESS'){
                    var data = response.getReturnValue();
                    if(data==null){
                        component.set("v.ErrorMessageInMarkCompleteed",true); 
                        window.setTimeout(
                            $A.getCallback(function() {
                                component.set("v.ErrorMessageInMarkCompleteed",false);
                            }),900     
                        );
                    }
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
    fetchPicklistValues : function(component, event, helper) {
        debugger;
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
        $A.enqueueAction(action); 
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
    Description:function(component, event, helper){
        debugger;
        var value= event.getSource().get("v.value");
        component.set("v.fileDescription",value);
    },
    CurrentUserEdit:function(component, event, helper){
        debugger;
        var PassRecordId;
        var action = component.get("c.CallCheckCurrentUserEditRight"); 
        var BoolaeanValue=component.get("v.IsParentTaskId");
        var currentTaskId = component.get("v.currentTaskId");
        var parentTaskId = component.get("v.recordId");
        if(BoolaeanValue==true){
            PassRecordId=parentTaskId;
        }else if(BoolaeanValue==false){
            PassRecordId=currentTaskId
        }
        action.setParams({  
            "TaskId":PassRecordId  
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
    handleCancel:function(component, event, helper){
        debugger;
        $A.get("e.force:closeQuickAction").fire();
        let ref = component.get('v.pageReference'); 
        if(ref!=null && ref!=undefined){
            let RecId = ref.state.c__RelatedId;
            window.location.href='https://northernarc--narcdevpro.sandbox.lightning.force.com/'+RecId;
        }else{
            var RecId=component.get("v.RelatedId");
            window.location.href='https://northernarc--narcdevpro.sandbox.lightning.force.com/'+RecId; 
        }
    },
    
    addNewRow: function(component, event, helper) {
        //debugger;
        var data = component.get("v.data");
        data.push({ type: "", userOrQueue: "", userOrQueueOptions: [] ,selectedUserOrQueueId:null,disabled:false});
        component.set("v.data", data);
    },
    
    deleteRow: function(component, event, helper) {
        debugger;
        var finalUserIds=component.get("v.finalUserIds");
        var index = event.getSource().get("v.value");
        var data = component.get("v.data");
        let Record=data[index];
        data.splice(index, 1);
        component.set("v.data", data);
        if(Record){
            const result = finalUserIds.filter((word) => word!=Record.selectedUserOrQueueId);
            console.log('result--'+JSON.stringify(result));
            component.set("v.finalUserIds",result);
        }
    },
    
    updateUserSelection : function(component, event, helper){
        debugger;
        var rowIndex = event.getSource().get("v.name");
        var selectedUser = event.getSource().get("v.value");
        //var SelectedUserIdList=component.get("v.SelectedUserIdList");
        //var SelectedQueueIdList=component.get("v.SelectedQueueIdList");
        var finaluserIds = component.get("v.finalUserIds");
        var data = component.get("v.data");
        if(data.length>0){
            for(let i=0;i<data.length;i++){
                if(i==rowIndex){
                    data[i].selectedUserOrQueueId=selectedUser;
                    finaluserIds.push(data[i].selectedUserOrQueueId);
                }
            }
        }
        component.set("v.data",data);
        
        //var finalUserIdList = [];
        /*if(finaluserIds.find(item=>item!=selectedUser)){
            finaluserIds.push(selectedUser); 
        }*/
        component.set("v.finalUserIds",finaluserIds);
        console.log('finalUserIds::'+finaluserIds);
    },
    
    updateOptions: function(component, event, helper) {
        debugger;
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        var UserList=component.get("v.AllUserList");
        var QueueList=component.get("v.AllQueueList");
        var selectedUserOrQueueId=[];
        var rowIndex = event.getSource().get("v.name");  
        var selectedType = event.getSource().get("v.value");
        var data = component.get("v.data");
        let QueueListToshow=[];
        let UserListToshow=[];
        if(data.length>0){
            for(let i=0;i<data.length;i++){
                if(data[i].selectedUserOrQueueId){
                    if(selectedType=='Queue'){
                        if(data[i].selectedUserOrQueueId.startsWith('00G')){
                            selectedUserOrQueueId.push(data[i].selectedUserOrQueueId); 
                        }  
                    }else if(selectedType=='Self'){
                        if(data[i].selectedUserOrQueueId.startsWith('005')){
                            selectedUserOrQueueId.push(data[i].selectedUserOrQueueId); 
                        }
                    }
                }
            }
        }
        console.log('selectedUserOrQueueId--'+JSON.stringify(selectedUserOrQueueId));
         //For Queues
        if(selectedType=='Queue'){
            for(let i=0;i<QueueList.length;i++){
                if(ChildTaskOwnerName.length>0){
                    if(ChildTaskOwnerName.find(item=>item.OwnerId===QueueList[i].Id)){
                         console.log('This Queue Exist');
                    }else{
                         let Obj={name:QueueList[i].Name,id:QueueList[i].Id}
                        QueueListToshow.push(Obj);
                    }
                }
            }
            if(selectedUserOrQueueId.length>0){
                for(let k=0;k<QueueListToshow.length;k++){
                    if(selectedUserOrQueueId.find(item=>item===QueueListToshow[k].id)){
                        delete QueueListToshow[k];
                    }
                } 
            }
            let TempQueueList=[]
            QueueListToshow.forEach((element) =>{
                if(element){
                   TempQueueList.push(element);
                }
            });
            data[rowIndex].userOrQueueOptions=TempQueueList; 
            component.set("v.data", data);
        }
        
        //For Users
         if(selectedType=='Self'){
            for(let i=0;i<UserList.length;i++){
                if(ChildTaskOwnerName.length>0){
                    if(ChildTaskOwnerName.find(item=>item.OwnerId===UserList[i].Id)){
                         console.log('This Queue Exist');
                    }else{
                         let Obj={name:UserList[i].Name,id:UserList[i].Id}
                         UserListToshow.push(Obj);
                    }
                }
            }
             if(selectedUserOrQueueId.length>0){
                for(let k=0;k<UserListToshow.length;k++){
                    if(selectedUserOrQueueId.find(item=>item===UserListToshow[k].id)){
                        delete UserListToshow[k];
                    }
                } 
            }
            let TempQueueList=[]
            UserListToshow.forEach((element) =>{
                if(element){
                   TempQueueList.push(element);
                }
            });
            data[rowIndex].userOrQueueOptions=TempQueueList; 
            component.set("v.data", data);
        }
        
        /*var action = component.get("c.getOwnerOptions");
        action.setParams({ 
            ownerType: selectedType,
            SelectedUserORQueues:selectedUserOrQueueId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var ownerOptions = response.getReturnValue();
                
                if(ownerOptions.userOPtionList != undefined){
                    data[rowIndex].userOrQueueOptions = [];
                    // component.set("v.ownerOptions", ownerOptions.userOPtionList);
                    for(var i=0;i<ownerOptions.userOPtionList.length;i++){
                        var myObject = {'name':ownerOptions.userOPtionList[i].Name,'id':ownerOptions.userOPtionList[i].Id};
                        let ownerNameExist;
                        if(ChildTaskOwnerName.length>0 && ChildTaskOwnerName!=undefined){
                            for(let i=0;i<ChildTaskOwnerName.length;i++){
                                if(ChildTaskOwnerName[i].Owner.Name==myObject.name){
                                    ownerNameExist=true;
                                    break;
                                }else{
                                    ownerNameExist=false;
                                }
                            }
                            if(ownerNameExist==false){
                                data[rowIndex].userOrQueueOptions.push(myObject); 
                            }
                        }else{
                            data[rowIndex].userOrQueueOptions.push(myObject); 
                        }
                        
                    }
                    component.set("v.data", data);
                }
                
                if(ownerOptions.queueOptionList != undefined){
                    data[rowIndex].userOrQueueOptions = [];
                    for(var i=0;i<ownerOptions.queueOptionList.length;i++){
                        var myObject = {'name':ownerOptions.queueOptionList[i].Name,'id':ownerOptions.queueOptionList[i].Id};
                        let ownerNameExist;
                        if(ChildTaskOwnerName.length>0 && ChildTaskOwnerName!=undefined){
                            for(let i=0;i<ChildTaskOwnerName.length;i++){
                                if(ChildTaskOwnerName[i].Owner.Name==myObject.name){
                                    ownerNameExist=true;
                                    break;
                                }else{
                                    ownerNameExist=false;
                                }
                            } 
                            if(ownerNameExist==false){
                                data[rowIndex].userOrQueueOptions.push(myObject); 
                            } 
                        }else{
                            data[rowIndex].userOrQueueOptions.push(myObject);  
                        }
                    }
                    data[rowIndex].userOrQueue = ''; // Reset the selected value
                    // Update the component's attribute
                    component.set("v.data", data);
                }
                
            }
        })
        
        $A.enqueueAction(action);*/
        
    },
    Save : function(component, event, helper){
        debugger;
        var finalData = component.get("v.finalUserIds");
        console.log('finalData::'+finalData);
    },
    handleResubmitted:function(component, event, helper){
        debugger;
        var selectedTaskId=component.get("v.selectedTaskId");
        var action = component.get("c.UpdateTasks");   
        action.setParams({
            "TaskIdset":selectedTaskId,
            "ParentTaskId":component.get("v.recordId"),
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){    
                location.reload();  
            }else{
                location.reload();  
            }
        });  
        $A.enqueueAction(action);
    }
    
    
    
    
})