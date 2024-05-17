({
    createChildCompArray:function(component, event, helper){
        debugger;
        let reviewer_threadId_taskid_array=[] 
        var selectedTaskId = component.get("v.selectedTaskId");
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        var ReviewerList = component.get("v.ReviewerList");
        if(selectedTaskId.length>0){
            selectedTaskId.forEach((tId_item)=>{
                let childtaskRelated_Process_Reviewer_detailId;
                let Related_Process_ReviewerId;
                let obj={reviewer_thread_Id:null,task_id:null};
                if(tId_item){
                    if(ChildTaskOwnerName.find((item)=>item.Id==tId_item)){
                        childtaskRelated_Process_Reviewer_detailId=ChildTaskOwnerName.find((item)=>item.Id==tId_item).Process_Attribute_Review_Detail__c;
                    }
                    if(childtaskRelated_Process_Reviewer_detailId!=null && childtaskRelated_Process_Reviewer_detailId!=undefined && ReviewerList.find((item)=>item.Id==childtaskRelated_Process_Reviewer_detailId)){
                        Related_Process_ReviewerId =ReviewerList.find((item)=>item.Id==childtaskRelated_Process_Reviewer_detailId).Process_Attribute_Review_Detail__c; 
                    }
                    obj.reviewer_thread_Id=Related_Process_ReviewerId;
                    obj.task_id=tId_item;
                    reviewer_threadId_taskid_array.push(obj);
                }
            })
        }
        return reviewer_threadId_taskid_array;
     }, 
    // On Page Load  
    fetchReviewersDetail:function(component, event, helper){
        debugger;
        var ReviewerType_ReviewerName=component.get("v.ReviewerType_ReviewerName");
        var action = component.get("c.WrapperClassReviewerDetailFromApex");
        action.setParams({ 
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                if(responseValue !=null && responseValue!=undefined && responseValue!={}){     
                    console.log('responseValue ReviewerList--',responseValue);
                    let reviewervalue=responseValue.ReviewerTypeRelatedToReviewerName;
                    let Process_path_reviewer_details=responseValue.ProcessPathTaskDetail_ReviewerType;
                    let Process_path_reviewer_checklist=responseValue.ProcessAttributeReviewer_ReviewerChecklist;
                    let Process_path_reviewer_checklist_fact=responseValue.ProcessAttributeReviewer_ReviewerChecklistFact;
                    let Opportunity_related_tasks = responseValue.Opportunity_Related_Tasks;
                    for(var key in responseValue.ReviewerTypeRelatedToReviewerName){
                        ReviewerType_ReviewerName.push({value:reviewervalue[key], key:key});
                    }
                    if(ReviewerType_ReviewerName!=null && ReviewerType_ReviewerName!=undefined){
                           if(ReviewerType_ReviewerName.length>0){
                            component.set("v.ReviewerType_ReviewerName",ReviewerType_ReviewerName); 
                           } 
                    }
                    if(Process_path_reviewer_details!=null && Process_path_reviewer_details!=undefined){
                            if(Process_path_reviewer_details.length>0){
                              component.set("v.ReviewerList",Process_path_reviewer_details);
                            }
                    }
                    if(Process_path_reviewer_checklist!=null && Process_path_reviewer_checklist!=undefined){
                        if(Process_path_reviewer_checklist.length>0){
                            component.set("v.CheckList",Process_path_reviewer_checklist);
                        }
                    }
                    if(Process_path_reviewer_checklist_fact!=null && Process_path_reviewer_checklist_fact!=undefined){
                        if(Process_path_reviewer_checklist_fact.length>0){
                            component.set("v.CheckList_Fact",Process_path_reviewer_checklist_fact);
                        }
                    }
                    if(Opportunity_related_tasks!=null && Opportunity_related_tasks!=undefined){
                        if(Opportunity_related_tasks.length>0){
                            component.set("v.Opportunity_Related_task",Opportunity_related_tasks);
                        }
                    }
                    
                }
            }
             else if(state === "ERROR"){

            }
        });
        $A.enqueueAction(action);
    },
    //On_Approve_Reject_Functionality
    handleApproveReject:function(component, event, helper,buttonlabel,Statusvalue,callback){ 
        debugger;
            var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName")
            var selectedTaskId=component.get("v.selectedTaskId");
            component.set("v.ShowCommentBox",false);
        
            var action = component.get("c.UpdateTaskStatus");
            action.setParams({  
                "ParentTaskIdValue":component.get("v.recordId"),
                "ApproverStatus":Statusvalue, 
                "TaskIdset":selectedTaskId 
            });      
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state=='SUCCESS'){   
                    var data = response.getReturnValue();
                    console.log('data--',data);
                    if(data && data.length>0){
                        data.forEach((item)=>{
                            if(item && item.Id){
                                ChildTaskOwnerName.find((element) =>{ if(element.Id==item.Id){ element.Status= item.Status; } });
                            }
                        })
                       component.set("v.ChildTaskOwnerName",ChildTaskOwnerName);
                       callback(response.getReturnValue(), null);
                    }
                } else if(state === "ERROR"){
                     message='Error';
                     callback(null, response.getError());
                }
            });
            $A.enqueueAction(action);
    },
    //Login user Access As a Creator/Reviewer_Approver/Viewer
    check_login_user_access_on_task_level:function(component, event, helper,ParentTask){
        debugger;
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var ChildTaskOwnerName = component.get("v.ChildTaskOwnerName");
        var LoginUserRelatedGroup = component.get("v.LoginUserRelatedGroup");
        let tkcreator = false;
        let show_close_button;
        if(userId!=null){
            if (ParentTask != null && ParentTask.OwnerId != null) {
                if (ParentTask.OwnerId.startsWith('00G') && LoginUserRelatedGroup.includes(ParentTask.Owner.Name)) {
                    tkcreator = true;
                } else if (ParentTask.OwnerId.startsWith('005') && ParentTask.OwnerId == userId) {
                    tkcreator = true;
                }else {
                    tkcreator = false;
                }
            }
            this.setaccess_records_for_login_user(component, event, helper,tkcreator,LoginUserRelatedGroup); 
        }
    },
    setaccess_records_for_login_user:function(component, event, helper,isCreator_loginuser,LoginUserRelatedGroup){
        debugger;
        var ChildTaskOwnerName = component.get("v.ChildTaskOwnerName");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
       if(isCreator_loginuser){ //If Creator is the login_user
            if(ChildTaskOwnerName.length!=0){
                for(let j=0;j<ChildTaskOwnerName.length;j++){
                    if(ChildTaskOwnerName[j].Status=='Submited For Review'){
                        ChildTaskOwnerName[j].disableCheckbox=true;         
                    }else if(ChildTaskOwnerName[j].Status=='Rejected'){
                        /*if(ChildTaskOwnerName[j].OwnerId.startsWith('00G')){
                            ChildTaskOwnerName[j].disableCheckbox = LoginUserRelatedGroup.includes(ChildTaskOwnerName[j].Owner.Name)==true?false:true;
                        }else if(ChildTaskOwnerName[j].OwnerId.startsWith('005')){
                            ChildTaskOwnerName[j].disableCheckbox = ChildTaskOwnerName[j].OwnerId==userId?false:true;
                        }*/
                        ChildTaskOwnerName[j].disableCheckbox=true;
                    }else if(ChildTaskOwnerName[j].Status=='Completed' ||  ChildTaskOwnerName[j].Status=='Approved'){
                        ChildTaskOwnerName[j].disableCheckbox=true;
                    }else if(ChildTaskOwnerName[j].Status=='Open'){
                        ChildTaskOwnerName[j].disableCheckbox=false;
                    }
                }
                console.log('login user is parent task owner--'+JSON.stringify(ChildTaskOwnerName));
            }
        }else if(isCreator_loginuser==false){  
            if(ChildTaskOwnerName.length!=0){
                for(let j=0;j<ChildTaskOwnerName.length;j++){
                    if(ChildTaskOwnerName[j].Status=='Submited For Review' && ChildTaskOwnerName[j].OwnerId!=null){
                        if(ChildTaskOwnerName[j].OwnerId.startsWith('00G')){
                             ChildTaskOwnerName[j].disableCheckbox = LoginUserRelatedGroup.includes(ChildTaskOwnerName[j].Owner.Name)==true?false:true;
                        }else if(ChildTaskOwnerName[j].OwnerId.startsWith('005')){
                              ChildTaskOwnerName[j].disableCheckbox = ChildTaskOwnerName[j].OwnerId==userId?false:true;
                        }            
                    }else if(ChildTaskOwnerName[j].Status=='Rejected' || ChildTaskOwnerName[j].Status=='Completed' || ChildTaskOwnerName[j].Status=='Open' || ChildTaskOwnerName[j].Status=='Approved'){
                        ChildTaskOwnerName[j].disableCheckbox=true
                    }
                }
                console.log('login user is not parent task owner--'+JSON.stringify(ChildTaskOwnerName));
            }
        }
         component.set("v.ChildTaskOwnerName",ChildTaskOwnerName);
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
            }else{  
            }
        });  
        $A.enqueueAction(action);
    },
    addcommentToApex:function(component, event, helper){
        debugger;
        var ChildTaskOwnerName   =component.get("v.ChildTaskOwnerName");
        var selectedRecord       =component.get("v.selectedRecord");
        var Comment              =component.get("v.CommentValue");
        let currentUserName      =component.get("v.currentUserName");
        const date               = new Date();
        let createCommentFormat  = (date.toISOString()) + "   [" + currentUserName + "] - " + Comment + '\n';
        selectedRecord.Description = selectedRecord.Description!=null && selectedRecord.Description!=undefined ? createCommentFormat +'\n' + selectedRecord.Description:createCommentFormat;
        var action = component.get("c.updateComment");   
        action.setParams({
            "taskrec":selectedRecord,
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if(state=='SUCCESS'){
                let index = ChildTaskOwnerName.findIndex((item) => item.Document_Metadata__c == responseValue.Document_Metadata__c);
                ChildTaskOwnerName[index] = Object.assign(ChildTaskOwnerName[index], JSON.stringify(responseValue));
                component.set("v.Isshowcomment",false); 
                component.set("v.CommentValue",'');
            }else{ 
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
    Prepare_data_for_Review:function(component, event, helper){
        debugger;
        var taskList=[];
        var ReviewerList= component.get("v.ReviewerList");
        var ReviewerId=   component.get("v.finalUserIds"); 
        var UserList =    component.get("v.AllUserList");
        var QueueList=    component.get("v.AllQueueList");
        var ChildTaskOwnerName= component.get("v.ChildTaskOwnerName");
        var taskRec = component.get("v.taskRec");
        
        if(ReviewerId.length>0){
            for(let i=0;i<ReviewerId.length;i++){
                 let taskObj={OwnerId:null,Current_Review_Level__c:null}
                if(ReviewerId[i]){
                    let Review_User_name;
                    if(ReviewerId[i].startsWith('005')){
                        Review_User_name=UserList.find((item)=>item.Id==ReviewerId[i]).Name;
                    }else if(ReviewerId[i].startsWith('00G')){
                        Review_User_name=QueueList.find((item)=>item.Id==ReviewerId[i]).Name;
                    }
                    if(Review_User_name!=null){
                        let getReviewerLevel;
                        let Process_Reviewer_detailId;
                        if(ReviewerList.length>0){
                            if(ReviewerList.find((item)=>item.Reviewer_Name__c==Review_User_name)){
                                let level  = ReviewerList.find((item)=>item.Reviewer_Name__c==Review_User_name).Level__c;
                                let Rev_Id = ReviewerList.find((item)=>item.Reviewer_Name__c==Review_User_name).Id;
                                if(level!=null && level!=undefined){
                                     getReviewerLevel=level;
                                }
                                if(Rev_Id!=null && Rev_Id!=undefined){
                                    Process_Reviewer_detailId=Rev_Id;
                                }
                            } 
                        }
                        let tsId;
                        if(ChildTaskOwnerName.length>0){
                           if(ChildTaskOwnerName.find((item)=>item.OwnerId==ReviewerId[i])){
                                tsId=ChildTaskOwnerName.find((item)=>item.OwnerId==ReviewerId[i]).Id;
                           }else{
                               tsId=null;
                           }
                        }
                        if(tsId==null && taskRec!=null){
                            if(taskRec.OwnerId==ReviewerId[i]){
                                tsId=taskRec.Id;
                            }
                        }
                        taskObj.Id=tsId;
                        taskObj.OwnerId=ReviewerId[i];
                        taskObj.Current_Review_Level__c=getReviewerLevel!=null && getReviewerLevel!=undefined ? getReviewerLevel:null;
                        taskObj.Process_Attribute_Review_Detail__c=Process_Reviewer_detailId!=null && Process_Reviewer_detailId!=undefined ? Process_Reviewer_detailId:null;
                        taskObj.No_Of_Times_Reviewed_Count__c=tsId!=null && tsId!=undefined && ChildTaskOwnerName.find(item=>item.Id==tsId) ? ChildTaskOwnerName.find(item=>item.Id==tsId).No_Of_Times_Reviewed_Count__c:null;
                        taskList.push(taskObj);
                    }
                }
            }
        }
        return taskList;
    },
        //Data Preparation In Case Of Approve
    NextApprover:function(component, event, helper){
        debugger;
        var NextApproverList=component.get("v.NextApproverList");
        var approver_Rejection_list=[];
        var selectedTaskId=component.get("v.selectedTaskId");
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        var ReviewerList=component.get("v.ReviewerList");
        if(selectedTaskId.length>0){
            for(let j=0;j<selectedTaskId.length;j++){
                let Approver_Rejection_obj={rv_taskId:null,approver_Rejection_list:[],approver_RejectionIds:[],isApprove:true,isReject:false,isCompliance:false}
                let NextApprover;
                let taskId=selectedTaskId[j];
                let childtaskRelated_Process_Reviewer_detailId;
                let Related_Process_ReviewerId;
                let task_Reviewer_level;
                if(ChildTaskOwnerName.find((item)=>item.Id==taskId)){
                    childtaskRelated_Process_Reviewer_detailId=ChildTaskOwnerName.find((item)=>item.Id==taskId).Process_Attribute_Review_Detail__c;
                }
                if(childtaskRelated_Process_Reviewer_detailId!=null && childtaskRelated_Process_Reviewer_detailId!=undefined){
                     Related_Process_ReviewerId=ReviewerList.find((item)=>item.Id==childtaskRelated_Process_Reviewer_detailId).Process_Attribute_Review_Detail__c;
                     task_Reviewer_level=ChildTaskOwnerName.find((item)=>item.Id==taskId).Current_Review_Level__c;
                }
                if(Related_Process_ReviewerId!=null && Related_Process_ReviewerId!=undefined && task_Reviewer_level!=null && task_Reviewer_level!=undefined){
                     NextApprover = ReviewerList.map((num) => {
                            if (num.Process_Attribute_Review_Detail__c!=null && num.Process_Attribute_Review_Detail__c==Related_Process_ReviewerId && num.Level__c==(task_Reviewer_level+1)) {
                            if(num!=undefined && num!=null){
                                return num;
                             }   
                        }
                     });
                }
                 console.log('NextApprover--',NextApprover);
                let prepared_data
                if(NextApprover!=null && NextApprover!=undefined && NextApprover.length>0){
                    prepared_data=this.prepareData_for_approve(component, event, helper,NextApprover);
                }
                 Approver_Rejection_obj.rv_taskId=taskId;
                if(prepared_data!=null && prepared_data!=undefined && prepared_data.nextApprover!=null && prepared_data.nextApprover!=undefined){
                    Approver_Rejection_obj.approver_Rejection_list=prepared_data.nextApprover;
                }
                if(prepared_data!=null && prepared_data!=undefined && prepared_data.apprpverId!=null && prepared_data.apprpverId!=undefined){
                    Approver_Rejection_obj.approver_RejectionIds=prepared_data.apprpverId;
                }
                if(Approver_Rejection_obj.rv_taskId!=null && (Approver_Rejection_obj.approver_Rejection_list!=undefined && Approver_Rejection_obj.approver_Rejection_list!=null && Approver_Rejection_obj.approver_Rejection_list.length) && (Approver_Rejection_obj.approver_RejectionIds!=undefined && Approver_Rejection_obj.approver_RejectionIds!=null && Approver_Rejection_obj.approver_RejectionIds.length)){
                    approver_Rejection_list.push(Approver_Rejection_obj);
                } 
            } 
            console.log('approver_Rejection_list',approver_Rejection_list);
            return approver_Rejection_list;
        }
    },
        //Data Preparation In Case Of Reject As Per the Reject Level
    RejectApprover:function(component, event, helper){
        debugger;
        var approver_Rejection_list=[];
        var taskRec=component.get("v.taskRec");
        var selectedTaskId=component.get("v.selectedTaskId");
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        var ReviewerList=component.get("v.ReviewerList");
        var RejectApproverList=[];
        if(selectedTaskId.length>0){
            for(let j=0;j<selectedTaskId.length;j++){
                let Approver_Rejection_obj={rv_taskId:null,approver_Rejection_list:[],approver_RejectionIds:[],isApprove:false,isReject:true,isCompliance:false}
                let taskId=selectedTaskId[j];
                 let childtaskRelated_Process_Reviewer_detailId=ChildTaskOwnerName.find((item)=>item.Id==taskId).Process_Attribute_Review_Detail__c;
                 let task_Reviewer_level=ChildTaskOwnerName.find((item)=>item.Id==taskId).Current_Review_Level__c;
                 let Reject_level=ReviewerList.find((item)=>item.Id==childtaskRelated_Process_Reviewer_detailId).Reject_Level_Allowed__c;
                    if(Reject_level=='Just Previous'){
                        let previous_reviewer_detail_id=ReviewerList.find((item)=>item.Id==childtaskRelated_Process_Reviewer_detailId).Process_Attribute_Review_Detail__c;
                        RejectApproverList=this.getAllPrevious_Based_on_Reject_level(component, event, helper,Reject_level,previous_reviewer_detail_id,task_Reviewer_level);
                    }else if(Reject_level=='All Previous'){ 
                        let previous_reviewer_detail_id=ReviewerList.find((item)=>item.Id==childtaskRelated_Process_Reviewer_detailId).Process_Attribute_Review_Detail__c;
                        RejectApproverList=this.getAllPrevious_Based_on_Reject_level(component, event, helper,Reject_level,previous_reviewer_detail_id,task_Reviewer_level);
                    }else if(Reject_level=='Creator'){
                        let previous_reviewer_detail_id=ReviewerList.find((item)=>item.Id==childtaskRelated_Process_Reviewer_detailId).Process_Attribute_Review_Detail__c;
                        RejectApproverList=this.getAllPrevious_Based_on_Reject_level(component, event, helper,Reject_level,previous_reviewer_detail_id,task_Reviewer_level);
                    }
                    console.log('RejectApproverList--',RejectApproverList);
                    let prepared_data;
                    if(RejectApproverList!=null && RejectApproverList!=undefined && RejectApproverList.length>0){
                        prepared_data=this.prepareData_for_approve(component, event, helper,RejectApproverList);
                        console.log('prepared_data--',prepared_data);
                    }
                    Approver_Rejection_obj.rv_taskId=taskId;
                    if(prepared_data!=null && prepared_data!=undefined && prepared_data.nextApprover!=null && prepared_data.nextApprover!=undefined){
                           if(prepared_data.nextApprover){
                                if(prepared_data.nextApprover.length==1){
                                    prepared_data.nextApprover[0].Selected=true;
                                    prepared_data.nextApprover[0].disableCheckbox=true;
                                    
                                }else if(prepared_data.nextApprover.length>1){
                                    
                                    prepared_data.nextApprover.forEach((element) => {
                                        element.Selected=false;
                                        element.disableCheckbox=false;
                                    });
                                }
                                Approver_Rejection_obj.approver_Rejection_list=prepared_data.nextApprover;
                         }
                    }
                    if(prepared_data!=null && prepared_data!=undefined && prepared_data.apprpverId!=null && prepared_data.apprpverId!=undefined){
                           Approver_Rejection_obj.approver_RejectionIds=prepared_data.apprpverId;         
                    }   
                    if(Approver_Rejection_obj.rv_taskId!=null && (Approver_Rejection_obj.approver_Rejection_list!=undefined && Approver_Rejection_obj.approver_Rejection_list!=null && Approver_Rejection_obj.approver_Rejection_list.length>0) && (Approver_Rejection_obj.approver_RejectionIds!=undefined && Approver_Rejection_obj.approver_RejectionIds!=null && Approver_Rejection_obj.approver_RejectionIds.length>0)){
                        approver_Rejection_list.push(Approver_Rejection_obj);
                    }
            }
        }
        return approver_Rejection_list;
    },
    getAllPrevious_Based_on_Reject_level:function(component, event, helper,reject_level,reviewer_detail_id,task_Reviewer_level){
        debugger;
        var ReviewerList=component.get("v.ReviewerList");
        console.log('ReviewerList',JSON.stringify(ReviewerList));
        console.log('reviewer_detail_id',JSON.stringify(reviewer_detail_id));
        var taskRec=component.get("v.taskRec");
        let Next_Reject_Approver=[];
        if(reject_level=='Just Previous'){
            Next_Reject_Approver = ReviewerList.map((num) => {
                if ((num.Process_Attribute_Review_Detail__c!=null && num.Process_Attribute_Review_Detail__c==reviewer_detail_id && num.Level__c==(task_Reviewer_level-1))) {
                     if(num!=undefined && num!=null)
                         return num;
                }
            });
        }else if(reject_level=='All Previous'){
           Next_Reject_Approver = ReviewerList.map((num) => {
                if ((num.Process_Attribute_Review_Detail__c!=null && num.Process_Attribute_Review_Detail__c==reviewer_detail_id && num.Level__c<task_Reviewer_level)) {
                     if(num!=undefined && num!=null)
                         return num;
                }
            });
        }
        if(reject_level=='Creator' || reject_level=='All Previous'){
             
             let ProcessReviewerData={Id:null,Reviewer_Name__c:null,Reviewer_Type__c:null,Level__c:null};
             ProcessReviewerData.Id=reviewer_detail_id;
             ProcessReviewerData.Reviewer_Name__c=taskRec.Owner.Name;
             ProcessReviewerData.Reviewer_Type__c=taskRec.OwnerId!=null && taskRec.OwnerId.startsWith('00G')?'Queue':taskRec.OwnerId!=null && taskRec.OwnerId.startsWith('005')?'Individual':'None';            
             ProcessReviewerData.Level__c=ReviewerList.find((item)=>item.Id==reviewer_detail_id).Level__c;
             Next_Reject_Approver.push(ProcessReviewerData);
        }
        console.log('Next_Reject_Approver--',Next_Reject_Approver);
        return Next_Reject_Approver;
    },
    prepareData_for_approve:function(component, event, helper,NextApprover){
        debugger;
        var UserList =    component.get("v.AllUserList");
        var QueueList=    component.get("v.AllQueueList");
        var nextApprover= NextApprover;
        var finaluserIds=[];
        let data=[];
        let returnApproverdata={nextApprover:null,apprpverId:null}
        if(nextApprover.length>0){
            for(let j=0;j<nextApprover.length;j++){
                if(nextApprover[j]==undefined || nextApprover[j]==null){continue}
                let arrD=[];
                if(nextApprover[j].Reviewer_Type__c=='Queue'){
                    let GroupId=QueueList.find(item=>item.Name==nextApprover[j].Reviewer_Name__c).Id;
                    arrD.push({name:nextApprover[j].Reviewer_Name__c,id:GroupId});
                }else{
                    let UserId=UserList.find(item=>item.Name==nextApprover[j].Reviewer_Name__c).Id; 
                    arrD.push({name:nextApprover[j].Reviewer_Name__c,id:UserId});
                }
                data.push({ type:nextApprover[j].Reviewer_Type__c, userOrQueue:nextApprover[j].Reviewer_Name__c, userOrQueueOptions:arrD,selectedUserOrQueueId:arrD[0].id,disabled:true});
                finaluserIds.push(arrD[0].id);
            }
            returnApproverdata.nextApprover=data;
            returnApproverdata.apprpverId=finaluserIds;
        } 
        return returnApproverdata;
    },
    SubmitForReviewHelper:function(component, event, helper,Insert_tasklist,approver_action){
        debugger;
        this.fetchData(component,event, helper,Insert_tasklist,approver_action)
        .then(function(data) {   
        })
        .catch(function(error) {
            console.error(error);
        });
    },
    fetchData : function(component, event, helper,Insert_tasklist, approver_action,callback ) {
        debugger;
            let message;
            var action = component.get("c.PassValueForApproval");
            action.setParams({
                "TaskId": component.get("v.recordId"),
                "tasklist": Insert_tasklist,
                "approver_action":approver_action
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state==='SUCCESS'){
                    callback(response.getReturnValue(), null);
                }else if(state === "ERROR"){
                     message='Error';
                     callback(null, response.getError());
                }    
            });
            $A.enqueueAction(action);
    },
    handleFor_Approve_Reject_Review:function(component, event, helper,buttonLabel,Statusvalue){
        debugger;  
        this.handleApproveReject(component, event, helper,buttonLabel,Statusvalue)
        .then(function(data) {
            
        })
        .catch(function(error) {
            console.error(error);
        });
    },
    senddata_toParent_task:function(component, event, helper){
       debugger;
        var selectedTaskId=component.get("v.selectedTaskId");
        var index = component.get("v.Index");
        let shouldskip=false
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        if(ChildTaskOwnerName.length>0){
            for(let i=0;i<ChildTaskOwnerName.length;i++){
                if(shouldskip) {return}
                if(ChildTaskOwnerName[i].Status && ChildTaskOwnerName[i].Status!='Approved'){
                    shouldskip=true
                }
            }
            if(selectedTaskId.length>0 && shouldskip==true){
                this.handleResubmitted(component, event, helper);
                this.passcomponent_status_to_Parent(component, event, helper,index,false);
            }else if(shouldskip==true){
                this.passcomponent_status_to_Parent(component, event, helper,index,false);
            }else{
                 this.passcomponent_status_to_Parent(component, event, helper,index,true);
            }
        }
   },
    checkvalidation_reviewtaskIds_onFact:function(component,event,helper){
       debugger;
       var shouldskip=false;
       var Opportunity_Related_task = component.get("v.Opportunity_Related_task");
       var CheckList_Fact=component.get("v.CheckList_Fact");
        if(CheckList_Fact!=null && CheckList_Fact!=undefined && CheckList_Fact.length>0){
            CheckList_Fact.forEach((fact_item)=>{ 
                if(fact_item.Id!=null && fact_item.Review_Related_TaskId__c!=null && fact_item.Review_Related_TaskId__c!=undefined){
                    if(shouldskip){return}
                    let reviewrelated_task = Opportunity_Related_task.find((item)=>item.Id==fact_item.Review_Related_TaskId__c);
                    if(reviewrelated_task!=null && reviewrelated_task!=undefined){
                        if(reviewrelated_task.Status=='Completed'){
                            shouldskip = false;
                        }else if(reviewrelated_task.Status!='Completed'){
                            shouldskip = true; 
                            this.showWarning(component, event, helper,'Please Close The '+reviewrelated_task.Subject+' Task Before Procedding To Submit For Review');
                        }
                    }
                }     
            })
         }
      return  shouldskip==true?false:true;                                                              
  },
    showWarning : function(component, event, helper,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'sticky'
        });
        toastEvent.fire();
    }                                                                   
})