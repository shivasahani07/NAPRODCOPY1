({
	myAction : function(component, event, helper) {
        debugger;
		console.log('checklists',component.get("v.checklists"));
        console.log('ReviewerList',component.get("v.ReviewerList"));
        console.log('Reviewer_thread_Id',component.get("v.Reviewer_thread_Id"));
        console.log('task_Id',component.get("v.task_Id"));
        console.log('CheckList_Fact',component.get("v.CheckList_Fact"));
        console.log('child_comp_array',component.get("v.child_comp_array"));
        console.log('Approver_OR_Rejection_array',component.get("v.Approver_OR_Rejection_array"));
        console.log('Opportunity_Related_task',component.get("v.Opportunity_Related_task"));
        console.log('IsEdit',component.get("v.IsEdit"));
        
        
        
        var LoginUserRelatedGroup=component.get("v.LoginUserRelatedGroup");
        var ReviewerList = component.get("v.ReviewerList");
        var Reviewer_thread_Id = component.get("v.Reviewer_thread_Id");
        var child_comp_array = component.get("v.child_comp_array");
        var Approver_OR_Rejection_array = component.get("v.Approver_OR_Rejection_array");
        var multiple_reviewer_checklist=[];
        var prepare_thread_related=[];
        
        if(child_comp_array.length>0){
            child_comp_array.forEach((item)=>{
                if(item.reviewer_thread_Id){
                    var Thread_related_reviewerlist = ReviewerList.map((r_item) => {
                        if(r_item.Process_Attribute_Review_Detail__c==item.reviewer_thread_Id){return r_item}
                    });
                    if(Thread_related_reviewerlist!=null && Thread_related_reviewerlist!=undefined && Thread_related_reviewerlist.length>0){
                        Thread_related_reviewerlist = Thread_related_reviewerlist.filter(value => value !== null && value !== undefined);
                        item.reviewerList=Thread_related_reviewerlist; 
                    }
                }
            })
            console.log('child_comp_array After Reviewer List',component.get("v.child_comp_array"));
        }
 
         if(child_comp_array!=null && child_comp_array!=undefined && child_comp_array.length>0){
            for(let i=0;i<child_comp_array.length;i++){
                if(child_comp_array[i]){  
                   let createed_checklist_obj=helper.prepareChecklist_data(component, event, helper,child_comp_array[i],i+1); 
                    if(createed_checklist_obj && Approver_OR_Rejection_array.length>0){
                        let getReviewerlist=Approver_OR_Rejection_array.find((rv_item)=>{
                            if(rv_item.rv_taskId==createed_checklist_obj.v_taskId){
                               return rv_item;
                        }
                     })  
                        createed_checklist_obj.v_Reviewerlist=[...getReviewerlist.approver_Rejection_list];
                        createed_checklist_obj.v_ReviewerIds=[...getReviewerlist.approver_RejectionIds];
                        createed_checklist_obj.isApprove=getReviewerlist.isApprove;
                        createed_checklist_obj.isReject=getReviewerlist.isReject;
                        createed_checklist_obj.isCompliance=getReviewerlist.isCompliance;
                        console.log('createed_checklist_obj',createed_checklist_obj);
                    }else{
                        createed_checklist_obj.isCompliance=true; 
                    }
                    multiple_reviewer_checklist.push(createed_checklist_obj);
                }
            }
            console.log('multiple_reviewer_checklist',JSON.stringify(multiple_reviewer_checklist));
            console.log('multiple_reviewer_checklist Size',JSON.stringify(multiple_reviewer_checklist.length));
            component.set("v.Selected_task_checklist",multiple_reviewer_checklist);
    
            if(multiple_reviewer_checklist.length>0){
                   let checklist_index=[];
                    multiple_reviewer_checklist.forEach((item)=>{
                            let first_index_checklist=[]
                            if(item && item.index!=null){
                                   let obj={'label':item.index, 'value':item.index};
                                   checklist_index.push(obj);
                                   if(item.index==1){ component.set("v.current_index_value",item.index); first_index_checklist.push(item); }
                            }
                            if(first_index_checklist.length>0){ 
                                console.log('first_index_checklist',JSON.stringify(first_index_checklist));
                                component.set("v.index_based_checklist",first_index_checklist); } 
                    })
                    if(checklist_index.length>0){  console.log('checklist_index',checklist_index); component.set("v.options",checklist_index); }
            }
        }
	},
    selectSingleOptionRec: function(component, event, helper){
        debugger;
        var CheckList_Fact     =component.get("v.CheckList_Fact");
        let process_fact_object={Id:null,Checklist_Reviewer_value__c:false,Process_Review_Checklist_Detail__c:null,Comments__c:null}
        var ChildTaskOwnerName=component.get("v.ChildTaskOwnerName");
        var selIdx = event.getSource().get("v.text");
        var checkbox = event.getSource();
        console.log(checkbox.get("v.value"));
        process_fact_object.Id=selIdx;
        process_fact_object.Checklist_Reviewer_value__c=checkbox.get("v.value");
        process_fact_object.Process_Review_Checklist_Detail__c=CheckList_Fact.find(item=>item.Id==selIdx).Process_Review_Checklist_Detail__c;
        //process_fact_object.Comments__c=CheckList_Fact.find(item=>item.Id==selIdx).Comments__c;
        if(process_fact_object && process_fact_object.Id!=null && process_fact_object.Id!=undefined){
            let processfact_array=[]; processfact_array.push(process_fact_object);
            helper.update_process_fact(component, event, helper,processfact_array);
        }
    },
    handleChange:function(component, event, helper){
        debugger; 
        var Selected_task_checklist=component.get("v.Selected_task_checklist");
        var selectedOptionValue = event.getParam("value");
        let index_based_checklist=[];
        if(selectedOptionValue!=null && selectedOptionValue!=undefined){
            component.set("v.current_index_value",parseInt(selectedOptionValue));
            let selected_index_checklist=Selected_task_checklist.find((item)=>item.index==selectedOptionValue);
            if(selected_index_checklist){
                index_based_checklist.push(selected_index_checklist);
            }
            component.set("v.index_based_checklist",index_based_checklist);
        }
    },
    HadlecancelApprover_Reject:function(component, event, helper){
        debugger;
        var compEvent = component.getEvent("childToParentCommunicationEvent");
        compEvent.setParams({
            "isCloseModal" : true,
            "isCloseModal_compliance_checklist":false
         });
        compEvent.fire();
    },
    handleClick_checklist_close:function(component, event, helper){
            debugger;
            var Checklist_Fact=component.get("v.CheckList_Fact");
            var compEvent = component.getEvent("childToParentCommunicationEvent");
            compEvent.setParams({
                 "isCloseModal" : false,
                 "isCloseModal_compliance_checklist":true,
                 "Checklist_Fact":Checklist_Fact
            });
            compEvent.fire();
    },
    handleClickNextApprover:function(component, event, helper){
        debugger;
        var finalUserIds=[];
        component.set("v.disablesubmitforReview",true);
        var index_based_checklist=component.get("v.index_based_checklist");
        console.log('index_based_checklist',index_based_checklist);
        var Is_Approve_review =component.get("v.Is_Approve_review");
        var Is_Reject_review  =component.get("v.Is_Reject_review");
        var v_isChecklistValidtionSuccess;
        var v_ReviewtaskIds_Statusclosed;

            if(index_based_checklist.length>0){ 
                index_based_checklist.forEach((item)=>{ 
                    //v_ReviewtaskIds_Statusclosed = helper.checkselectedRelatedtask_Status(component, event, helper,item.v_checklists);
                    v_isChecklistValidtionSuccess = helper.checklistValidation_onSubmitForReview(component, event, helper,item.v_checklists);
                        if(v_isChecklistValidtionSuccess){
                                    if(Is_Approve_review==true && Is_Reject_review==false){
                                         if(item.v_ReviewerIds!=null && item.v_ReviewerIds!=undefined && item.v_ReviewerIds.length>0){
                                            finalUserIds=[...item.v_ReviewerIds];
                                          }
                                   }else if(Is_Approve_review==false && Is_Reject_review==true){
                                           if(item.v_Reviewerlist!=null && item.v_Reviewerlist!=undefined && item.v_Reviewerlist.length>0){
                                                finalUserIds = item.v_Reviewerlist.map((item) => { if(item.Selected){  return item.selectedUserOrQueueId; }});  
                                           }
                                   }
                        }  
               })
            } 
        console.log('finalUserIds',finalUserIds);
        //if(v_ReviewtaskIds_Statusclosed){return component.set("v.disablesubmitforReview",false);};
        if(finalUserIds.length>0 && v_isChecklistValidtionSuccess==true){
            var compEvent = component.getEvent("childToParentCommunicationEvent");
            compEvent.setParams({
                 "isCloseModal" : false,
                 "isCloseModal_compliance_checklist":false,
                 "Is_Approve_review":Is_Approve_review,
                 "Is_Reject_review":Is_Reject_review,
                 "reviewer_Ids":finalUserIds
            });
            compEvent.fire();
        }else{
            if(Is_Approve_review==true && Is_Reject_review==false){
                helper.showWarning(component, event, helper,'Please check all the checklists to proceed further');  
            }else if(Is_Approve_review==false && Is_Reject_review==true){
                helper.showWarning(component, event, helper,'Please uncheck atleast one checklist And Add Comment to the Unchecked Checklists to proceed further');  
            }
            component.set("v.disablesubmitforReview",false);
        }
    },
    selectRejectApprover:function(component, event, helper){
     debugger;
        var reviewerlist=[];
        var checkbox = event.getSource();
        console.log(checkbox.get("v.value"));
        var selIdx = event.getSource().get("v.text");  
        console.log('selIdx',selIdx);
        var index_based_checklist=component.get("v.index_based_checklist");
        reviewerlist=index_based_checklist[0].v_Reviewerlist;
        console.log('reviewerlist',reviewerlist);
        reviewerlist.forEach((element) => {
            if(element.selectedUserOrQueueId==selIdx){
                  element.Selected=checkbox.get("v.value");
                  element.disableCheckbox=checkbox.get("v.value")==true?false:false;
             }else{
                 element.Selected=false;
                 element.disableCheckbox=checkbox.get("v.value")==false?false:true;                  
            }
        });
        index_based_checklist[0].v_ReviewerIds=reviewerlist;
        component.set("v.index_based_checklist",index_based_checklist);
   },
    handleComments:function(component, event, helper){
        debugger;
        var IsEdit=component.get("v.IsEdit")
        var checklistIndex_id=event.getSource().get("v.value");
        component.set("v.current_checklistindex_value",checklistIndex_id);
        component.set("v.Isshowcomment",true);
        var index_based_checklist=component.get("v.index_based_checklist");
        console.log('index_based_checklist',index_based_checklist);
        var dummy_array=index_based_checklist[0].v_checklists;
           if(dummy_array.length>0){
               let checklistName=dummy_array[checklistIndex_id].checklistName;
               component.set("v.Selected_Checklist_Name",checklistName);
               console.log('checklistName',checklistName);
               let checklist_reviewer_array=dummy_array[checklistIndex_id].checklist_reviewer_array;
               if(checklist_reviewer_array.length>0){
                   let all_comments=[];
                   let uniquecomments;
                   checklist_reviewer_array.forEach(item=>{
                         //item.comments!=null && item.comments!=undefined && (item.isEditAllowed==true || (item.isEditAllowed==false && IsEdit==true))
                       if(item.comments!=null && item.comments!=undefined){
                            all_comments.push(item.comments)
                           //all_comments= all_comments!=null &&  all_comments!=undefined ? all_comments+ item.comments : item.comments;
                        }
                        uniquecomments=helper.getUniquecomments(component,event,helper,all_comments);
                   })
                   console.log('all_comments',all_comments);
                   console.log('uniquecomments',uniquecomments);
                   component.set("v.checklisthistoryCommentValue",uniquecomments);
               }
           }
    },

    cancel:function(component, event, helper){
       debugger;
       component.set("v.Isshowcomment",false);
    },
    AddComment:function(component, event, helper){
         debugger; 
        var inputCmp = component.find("commentInput");
        let stringlength = component.get("v.CommentValue").length;
            if(parseInt(stringlength) > 255){
                inputCmp.setCustomValidity("You have exceeded the limit of 255 characters");
                inputCmp.reportValidity();
                return;
            }
         var checklistIndex_id=component.get("v.current_checklistindex_value");
         var index_based_checklist=component.get("v.index_based_checklist");
         console.log('index_based_checklist',index_based_checklist);
         component.set("v.disableaddcomment",true);
         var dummy_array=index_based_checklist[0].v_checklists;
         let checklist_reviewer_array=dummy_array[checklistIndex_id].checklist_reviewer_array;
         helper.handleSessionvalues(component, event, helper);
         helper.addComment_basisOf_Checklist(component, event, helper,checklist_reviewer_array);
    }
})