({
    //On Page Load this function executes
    myAction : function(component, event, helper) {
        debugger; 
        console.log('tkcreator',component.get("v.tkcreator"));
        console.log('tkreviewer',component.get("v.tkreviewer"));
        console.log('IsEdit',component.get("v.IsEdit"));
        
        helper.fetchReviewersDetail(component, event, helper); 
        
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
                let QueueList=result.queueOptionList;
                let UserList=result.userOPtionList;
                component.set("v.AllUserList",UserList);
                component.set("v.AllQueueList",QueueList);
                component.set("v.currentUserName", result.login_user_UserName);

                var TempArr=[];
                if(result.ChildTaskRecords == undefined){
                    var ReviewerType_ReviewerName=component.get("v.ReviewerType_ReviewerName");
                    var data = component.get("v.data");
                    if(ReviewerType_ReviewerName.length >0){
                        for(let i=0;i<ReviewerType_ReviewerName.length;i++){
                            let value=ReviewerType_ReviewerName[i].value;
                            if(value.length>0){
                                for(let j=0;j<value.length;j++){
                                    let arrD=[];
                                    if(ReviewerType_ReviewerName[i].key=='Queue'){
                                        let GroupId=QueueList.find(item=>item.Name==value[j]).Id;
                                        arrD.push({name:value[j],id:GroupId});
                                    }else{
                                        let UserId=UserList.find(item=>item.Name==value[j]).Id; 
                                        arrD.push({name:value[j],id:UserId});
                                    }
                                    data.push({ type:ReviewerType_ReviewerName[i].key, userOrQueue:value[j], userOrQueueOptions:arrD,selectedUserOrQueueId:arrD[0].id,disabled:true});
                                    finaluserIds.push(arrD[0].id);
                                }
                            }
                        }
                        component.set("v.data",data);
                        component.set("v.finalUserIds",finaluserIds);
                    }     
                }
                if(result.ChildTaskRecords!=null && result.ChildTaskRecords!=undefined){             
                    var ChildTaskOwnerName=result.ChildTaskRecords;
                    if(ChildTaskOwnerName.length!=0){
                        for(let j=0;j<ChildTaskOwnerName.length;j++){
                            if(ChildTaskOwnerName[j].Status=='Submited For Review'){
                                ChildTaskOwnerName[j].RowBackgroundColor='color:orange;font-weight:bold;';
                                ChildTaskOwnerName[j].Selected=false;
                                ChildTaskOwnerName[j].disableCheckbox=false;
                                
                            }else if(ChildTaskOwnerName[j].Status=='Rejected'){
                                ChildTaskOwnerName[j].RowBackgroundColor='color:Red;font-weight:bold;';
                                ChildTaskOwnerName[j].Selected=false;
                                ChildTaskOwnerName[j].disableCheckbox=false;
                                
                            }else if(ChildTaskOwnerName[j].Status=='Completed' || ChildTaskOwnerName[j].Status=='Approved'){
                                ChildTaskOwnerName[j].RowBackgroundColor='color:Green;font-weight:bold;';
                                ChildTaskOwnerName[j].Selected=false;
                                ChildTaskOwnerName[j].disableCheckbox=false;
                                
                            }else if(ChildTaskOwnerName[j].Status=='Open'){
                                ChildTaskOwnerName[j].RowBackgroundColor='color:yellow;font-weight:bold;';
                                ChildTaskOwnerName[j].Selected=false;
                                ChildTaskOwnerName[j].disableCheckbox=false;
                            }
                        }
                        console.log('ChildTaskOwnerName After backgroundColor--'+JSON.stringify(ChildTaskOwnerName));
                        component.set("v.ChildTaskOwnerName",ChildTaskOwnerName);
                        helper.check_login_user_access_on_task_level(component, event, helper,result.TaskRecord)
                    }
                }
            }  
        });
        $A.enqueueAction(action);  
    },
    //For adding New Reviewers
    addNewRow: function(component, event, helper) {
        //debugger;
        var data = component.get("v.data");
        data.push({ type: "", userOrQueue: "", userOrQueueOptions: [] ,selectedUserOrQueueId:null,disabled:false});
        component.set("v.data", data);
    },
    //For Deleting the 
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
                    }else if(selectedType=='Individual'){
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
                }else{
                    if(QueueListToshow.length>0){
                        if(QueueListToshow.find(item=>item.id!==QueueList[i].Id)){
                            let Obj={name:QueueList[i].Name,id:QueueList[i].Id}
                            QueueListToshow.push(Obj);
                        }
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
        if(selectedType=='Individual'){
            for(let i=0;i<UserList.length;i++){
                if(ChildTaskOwnerName.length>0){
                    if(ChildTaskOwnerName.find(item=>item.OwnerId===UserList[i].Id)){
                        console.log('This User Exist');
                    }else{
                        let Obj={name:UserList[i].Name,id:UserList[i].Id}
                        UserListToshow.push(Obj);
                    }
                }else{
                    if(UserListToshow.length>0){
                        if(UserListToshow.find(item=>item.id!==UserList[i].Id)){
                            let Obj={name:UserList[i].Name,id:UserList[i].Id}
                            UserListToshow.push(Obj);
                        } 
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
    },
    updateUserSelection : function(component, event, helper){
        debugger;
        var rowIndex = event.getSource().get("v.name");
        var selectedUser = event.getSource().get("v.value");
        var finaluserIds = component.get("v.finalUserIds");
        var data = component.get("v.data");
        if(data.length>0){
            for(let i=0;i<data.length;i++){
                if(i==rowIndex){
                    data[i].selectedUserOrQueueId=selectedUser;
                }
            }
        }
        finaluserIds= data.map((item) => item.selectedUserOrQueueId);
        component.set("v.data",data);
        component.set("v.finalUserIds",finaluserIds);
        console.log('finalUserIds::'+finaluserIds);
    },
    //Executes Creates new Reviewer
    handleClickSave:function(component, event, helper){
        debugger;
        var ReviewerId=component.get("v.finalUserIds");
        let Insert_tasklist=helper.Prepare_data_for_Review(component, event, helper);
        var index = component.get("v.Index");
        if(ReviewerId==null){
            
        }else{
           component.set("v.disablesubmitforReview",true);
           helper.fetchData(component, event, helper,Insert_tasklist,'Submited For Review',function(result, error) {
            debugger;
            if (error) {
                console.error(error);
            } else {
                console.log(result);
                if(result.Id != undefined){
                    location.reload();
                }
            }
          });
        }  
    },
    //Executes on checkbox selection
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
    //Final Method From Parent Component CMP_TaskMaster
    callLWCMethod:function(component, event, helper){
       debugger;
        var isRejectavailable=false;
        var taskRec=component.get("v.taskRec");
        var CheckList_Fact=component.get("v.CheckList_Fact");
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        var ReviewerList=component.get("v.ReviewerList");
        if(ChildTaskOwnerName.find((item)=>item.Status=='Rejected')){
            isRejectavailable=true
        }
        if(taskRec.Id!=null && taskRec.Status=='Open' && ChildTaskOwnerName.length>0 && ReviewerList.length>0 && isRejectavailable==true){
            if(CheckList_Fact!=null && CheckList_Fact!=undefined && CheckList_Fact.length>0){
                 var v_ReviewtaskIds_Statusclosed_Related_to_fact=helper.checkvalidation_reviewtaskIds_onFact(component,event,helper);
                    if(v_ReviewtaskIds_Statusclosed_Related_to_fact){
                         var targetMethod = component.get('c.checkCreatorLevel_ApproverList')
                         $A.enqueueAction(targetMethod);  
                    }
            }else{
                 var targetMethod = component.get('c.checkCreatorLevel_ApproverList')
                 $A.enqueueAction(targetMethod);
            }      
        }else if(taskRec.Id!=null && taskRec.Status=='Open' && ChildTaskOwnerName.length > 0 && ReviewerList.length>0 && isRejectavailable==false){
                 var targetMethod = component.get('c.checkCreatorLevel_ApproverList')
                 $A.enqueueAction(targetMethod);  
        }else if(taskRec.Id!=null && taskRec.Status=='Open' && ChildTaskOwnerName.length ==0 && ReviewerList.length==0){
                helper.senddata_toParent_task(component, event, helper);  
        }
        
        //Commeted Code For BackUp
        /*if(taskRec.Id!=null && taskRec.Status=='Open' && ChildTaskOwnerName.length>0 && isRejectavailable==true){
            if(CheckList_Fact!=null && CheckList_Fact!=undefined && CheckList_Fact.length>0){
                 var v_ReviewtaskIds_Statusclosed_Related_to_fact=helper.checkvalidation_reviewtaskIds_onFact(component,event,helper);
                    if(v_ReviewtaskIds_Statusclosed_Related_to_fact){
                         var targetMethod = component.get('c.checkCreatorLevel_ApproverList')
                         $A.enqueueAction(targetMethod);  
                    }
            }else{
                 var targetMethod = component.get('c.checkCreatorLevel_ApproverList')
                 $A.enqueueAction(targetMethod);
            }      
        }else{
            helper.senddata_toParent_task(component, event, helper);  
        }*/
    },
    //Executes on Reject Button
    handleClickReject:function(component, event, helper){
        debugger;
        var selectedTaskId = component.get("v.selectedTaskId");
        let reviewer_threadId_taskid_array = helper.createChildCompArray(component, event, helper);
        let approver_Rejection_list = helper.RejectApprover(component, event, helper);
        component.set("v.show_Reviewer_checklist",false);
        component.set("v.IsEditable",true);
        component.set("v.Is_Approve_review",false);
        component.set("v.Is_Reject_review",true);
        if(approver_Rejection_list.length==0){
            //helper.handleApproveReject(component, event, helper,'Reject_button','Rejected');
            helper.handleApproveReject(component, event, helper,'Reject_button','Rejected',function(result, error){
                if(error){
                    console.error(error);
                }else{
                    console.log(result); 
                    if(result!=null && result!=undefined && result.length>0){
                        location.reload();
                    }
                }
            });
        }else{
            if(reviewer_threadId_taskid_array!=null && reviewer_threadId_taskid_array!=undefined && reviewer_threadId_taskid_array.length>0){
                  component.set("v.child_comp_array",reviewer_threadId_taskid_array);   
            }
            component.set("v.show_Reviewer_checklist",false);
            component.set("v.IsEditable",true);
            component.set("v.Is_Approve_review",false);
            component.set("v.Is_Reject_review",true);
             component.set("v.Is_Compliance_review",false);
            component.set("v.task_Id",selectedTaskId);
            component.set("v.Approver_OR_Rejection_array",approver_Rejection_list);
            component.set("v.NextApproverList",approver_Rejection_list);
        }
    },
    //Executes on Approve Button
    handleClickApprove:function(component, event, helper){
        debugger;
        var selectedTaskId = component.get("v.selectedTaskId");
        let reviewer_threadId_taskid_array = helper.createChildCompArray(component, event, helper);
        let approver_Rejection_list=helper.NextApprover(component, event, helper);
        if(approver_Rejection_list.length==0){
            helper.handleApproveReject(component, event, helper,'Approve_button','Approved',function(result, error){
                if(error){
                    console.error(error);
                }else{
                    console.log(result); 
                    if(result!=null && result!=undefined && result.length>0){
                        helper.senddata_toParent_task(component, event, helper);
                    }
                }
            });
        }else{
            if(reviewer_threadId_taskid_array!=null && reviewer_threadId_taskid_array!=undefined && reviewer_threadId_taskid_array.length>0){
                  component.set("v.child_comp_array",reviewer_threadId_taskid_array);   
            }
            component.set("v.show_Reviewer_checklist",false);
            component.set("v.IsEditable",true);
            component.set("v.Is_Approve_review",true);
            component.set("v.Is_Reject_review",false);
            component.set("v.Is_Compliance_review",false);
            component.set("v.task_Id",selectedTaskId);
            component.set("v.Approver_OR_Rejection_array",approver_Rejection_list);
            component.set("v.NextApproverList",approver_Rejection_list);
           
        } 
    },
    handleComments:function(component, event, helper){
        debugger;
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        var task_id=event.getSource().get("v.value");
        component.set("v.Isshowcomment",true);
        let selectedRecord=ChildTaskOwnerName.find(item => item.Id==task_id);
        component.set("v.historyCommentValue",selectedRecord.Description); 
        component.set("v.selectedRecord",selectedRecord);
    },
    cancel:function(component, event, helper){
        debugger;
        component.set("v.Isshowcomment",false);
    },
    AddComment:function(component, event, helper){
        debugger;
        helper.addcommentToApex(component, event, helper);
    },
    handleChecklist:function(component, event, helper){
      debugger; 
        let reviewer_threadId_taskid_array=[]
        let reviewer_thread_array=[];
        let taskid_array=[];
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        var ReviewerList=component.get("v.ReviewerList");
        var task_recordId = event.getSource().get("v.value");
        let childtaskRelated_Process_Reviewer_detailId
        if(ChildTaskOwnerName.find((item)=>item.Id==task_recordId)){
            childtaskRelated_Process_Reviewer_detailId=ChildTaskOwnerName.find((item)=>item.Id==task_recordId).Process_Attribute_Review_Detail__c;
        }    
        let Related_Process_ReviewerId
            if(ReviewerList.find((item)=>item.Id==childtaskRelated_Process_Reviewer_detailId)){
                Related_Process_ReviewerId=ReviewerList.find((item)=>item.Id==childtaskRelated_Process_Reviewer_detailId).Process_Attribute_Review_Detail__c;
            }  
        reviewer_thread_array.push(Related_Process_ReviewerId);
        taskid_array.push(task_recordId);
        let obj={reviewer_thread_Id:Related_Process_ReviewerId,task_id:task_recordId};
        if(obj.reviewer_thread_Id!=null && obj.reviewer_thread_Id!=undefined && obj.task_id!=null && obj.task_id!=undefined){
            reviewer_threadId_taskid_array.push(obj);
        }
        console.log('reviewer_thread_array',reviewer_thread_array);
        console.log('taskid_array',taskid_array);
        console.log('reviewer_threadId_taskid_array',reviewer_threadId_taskid_array);
        component.set("v.child_comp_array",reviewer_threadId_taskid_array);
        component.set("v.Reviewer_thread_Id",reviewer_thread_array);
        component.set("v.task_Id",task_recordId);
        component.set("v.IsEditable",false);
        component.set("v.Is_Approve_review",false);
        component.set("v.Is_Reject_review",false);
        component.set("v.Is_Compliance_review",true);
        if(reviewer_threadId_taskid_array.length>0){
            component.set("v.show_Reviewer_checklist",true);
        }
        
    },
    handleChecklistEvent:function(component, event, helper){
       debugger;
        var isclosed_Approve_RejectModal=event.getParam("isCloseModal");
        var isclose_compliance_checklist=event.getParam("isCloseModal_compliance_checklist");
        var Is_Approve_review=event.getParam("Is_Approve_review");
        var Is_Reject_review=event.getParam("Is_Reject_review");
        var reviewer_Ids=event.getParam("reviewer_Ids");
        var checklist_Fact=event.getParam("Checklist_Fact");
        if(isclosed_Approve_RejectModal){
            component.set("v.Approver_OR_Rejection_array",[]);
        }
        if(isclose_compliance_checklist){
            component.set("v.show_Reviewer_checklist",false);
            if(checklist_Fact!=null && checklist_Fact!=undefined && checklist_Fact.length>0){
                component.set("v.CheckList_Fact",checklist_Fact);
            } 
        }
        if(Is_Approve_review==true && Is_Reject_review==false && reviewer_Ids.length>0){
            console.log('Is_Approve_review',Is_Approve_review);
            console.log('Is_Reject_review',Is_Reject_review);
            console.log('reviewer_Ids',reviewer_Ids);
            component.set("v.finalUserIds",reviewer_Ids);
            var targetMethod = component.get('c.handleClickNextApprover')
            $A.enqueueAction(targetMethod);
        }
        if(Is_Approve_review==false && Is_Reject_review==true && reviewer_Ids.length>0){
            console.log('Is_Approve_review',Is_Approve_review);
            console.log('Is_Reject_review',Is_Reject_review);
            console.log('reviewer_Ids',reviewer_Ids);
            component.set("v.finalUserIds",reviewer_Ids);
            var targetMethod = component.get('c.handleClickPreviousApprover')
            $A.enqueueAction(targetMethod);
        }
    },
    handleClickNextApprover:function(component, event, helper){
        debugger;
        var ReviewerId=component.get("v.finalUserIds");
        let Insert_tasklist=helper.Prepare_data_for_Review(component, event, helper);
        helper.fetchData(component, event, helper,Insert_tasklist,'Approved',function(result, error) {
            debugger;
            if (error) {
                console.error(error);
            } else {
                console.log(result);
                if(result.Id != undefined){ 
                    helper.handleApproveReject(component, event, helper,'Approve_button','Approved',function(result, error){
                        if(error){
                            console.error(error);
                        }else{
                           console.log(result); 
                            if(result!=null && result!=undefined && result.length>0){
                                location.reload();
                            }
                        }
                    });
                }
            }
        });
    },
    handleClickPreviousApprover:function(component, event, helper){
        debugger;
        var ReviewerId=component.get("v.finalUserIds");
        let Insert_tasklist=helper.Prepare_data_for_Review(component, event, helper);
        helper.fetchData(component, event, helper,Insert_tasklist,'Rejected',function(result, error) {
            debugger;
            if (error) {
                console.error(error);
            } else {
                console.log(result);
                if(result.Id != undefined){ 
                     helper.handleApproveReject(component, event, helper,'Reject_button','Rejected',function(result, error){
                        if(error){
                            console.error(error);
                        }else{
                           console.log(result); 
                            if(result!=null && result!=undefined && result.length>0){
                                location.reload();
                            }
                        }
                    });
                }
            }
        });
    },
    checkCreatorLevel_ApproverList:function(component, event, helper){
        debugger;
        var nextLevel_ReviewRecord
        var ReviewerList=component.get("v.ReviewerList");
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        var finalUserIds=component.get("v.finalUserIds");
        var getReviewerRecord_level_0=ReviewerList.find((item)=>item.Level__c==0);
        console.log('getReviewerRecord_level_0',getReviewerRecord_level_0);
            if(getReviewerRecord_level_0!=null && getReviewerRecord_level_0!=undefined && getReviewerRecord_level_0.Approve_Level_Allowed__c!=null && getReviewerRecord_level_0.Approve_Level_Allowed__c!=undefined){
                if(getReviewerRecord_level_0.Approve_Level_Allowed__c=='Next Level'){
                    nextLevel_ReviewRecord=ReviewerList.find((item)=>item.Process_Attribute_Review_Detail__c==getReviewerRecord_level_0.Id && item.Level__c==1);
                    if(nextLevel_ReviewRecord!=null && nextLevel_ReviewRecord!=undefined){
                        let childTask_relatedTo_nextLevel_ReviewRecord=ChildTaskOwnerName.find((item)=>item.Process_Attribute_Review_Detail__c==nextLevel_ReviewRecord.Id);
                        if(childTask_relatedTo_nextLevel_ReviewRecord!=null && childTask_relatedTo_nextLevel_ReviewRecord!=undefined && childTask_relatedTo_nextLevel_ReviewRecord.Id){
                            finalUserIds.push(childTask_relatedTo_nextLevel_ReviewRecord.OwnerId);
                        }
                    }
                }else if(getReviewerRecord_level_0.Approve_Level_Allowed__c=='Current Reject Level'){
                    let childTask_relatedTo_current_Reject_level=ChildTaskOwnerName.find((item)=>item.Status=='Rejected');
                    finalUserIds.push(childTask_relatedTo_current_Reject_level.OwnerId);
                }
            }
            component.set("v.finalUserIds",finalUserIds);
            let Insert_tasklist=helper.Prepare_data_for_Review(component, event, helper);
            helper.fetchData(component, event, helper,Insert_tasklist,'Submited For Review',function(result, error) {
                debugger;
                if (error) {
                    console.error(error);
                } else {
                    console.log(result);
                    if(result.Id != undefined){
                        helper.senddata_toParent_task(component, event, helper); 
                        location.reload(); 
                    }
                }
            });                                
    }      
})