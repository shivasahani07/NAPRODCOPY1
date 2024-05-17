({
	prepareChecklist_data : function(component, event, helper,reviewer_item,v_index) {
        debugger;
		var checklist            =  component.get("v.checklists");
        var userList             =  component.get("v.userList");
        var QueueList            =  component.get("v.QueueList");
        var isEditable           =  component.get("v.IsEditable");
        var Is_Approve_review    =  component.get("v.Is_Approve_review");
        var Is_Reject_review     =  component.get("v.Is_Reject_review");
        var CheckList_Fact       =  component.get("v.CheckList_Fact");
        var childTaskList        =  component.get("v.ChildTaskOwnerName");
        var LoginUserRelatedGroup=  component.get("v.LoginUserRelatedGroup");
        
        var Reviewer_names       =  [];
        var Reviewer_id          =  [];
        var reviewer_checklist   =  [];
        var final_checklist      =  [];
        var selected_child_task  =  [];
        var reviewer_list        =  [];
        var taskId_related_fact  =  [];
        
        var task_Id;
        var reviewer_threadId;
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        let obj_finalchecklist={taskOwnerName:null,reviewer_threadId:null,v_taskId:null,index:v_index,checklist_Header:[],v_checklists:[],v_Reviewerlist:[],v_ReviewerIds:[],isApprove:false,isReject:false,isCompliance:false}
        if(reviewer_item){
            console.log('reviewer_item',JSON.stringify(reviewer_item));
            reviewer_list=reviewer_item.reviewerList;
            task_Id=reviewer_item.task_id;
            reviewer_threadId=reviewer_item.reviewer_thread_Id;
            
            obj_finalchecklist.reviewer_threadId=reviewer_threadId;
            obj_finalchecklist.v_taskId=task_Id;
        }
        console.log('reviewer_list',reviewer_list);
        console.log('task_Id',task_Id);
        if(reviewer_threadId!=null && reviewer_threadId!=undefined){
            taskId_related_fact= CheckList_Fact.map((x) =>{if(x && x.Process_Attribute_Review_Detail__c==reviewer_threadId){return x;}});
            taskId_related_fact = taskId_related_fact.filter(value => value !== null && value !== undefined);
        }
        if(task_Id!=null && task_Id!=undefined){
            let tkrecord=childTaskList.find((item)=>{
                if(item.Id==task_Id){
                    return item;
                }
            });
             obj_finalchecklist.taskOwnerName=tkrecord.Owner.Name;
        }
         console.log('taskId_related_fact',JSON.stringify(taskId_related_fact));
        
        if(reviewer_list.length>0){
            reviewer_list.forEach((element)=>{
                if(element && element.Reviewer_Name__c){
                    Reviewer_names.push(element.Reviewer_Name__c);
                }
            })
            obj_finalchecklist.checklist_Header = Reviewer_names;
        }
        
        if(taskId_related_fact.length>0){
            //Create Checklist array to show
            taskId_related_fact.forEach((element)=>{
                    if(element && element.Process_Review_Checklist_Detail__r.Checklist_Name__c){
                            let checklist_obj ={checklistName:element.Process_Review_Checklist_Detail__r.Checklist_Name__c,checklist_reviewer_array:[]}
                                 let each_checklist_reviewerlist=[];
                                 Reviewer_names.forEach((item)=>{
                                    let reviewer_obj={}; 
                                    reviewer_obj ['reviewerName']         =item;
                                    reviewer_obj ['checklistfactId']      =null;
                                    if(item && userList.find((useritem)=>useritem.Name==item)){
                                        reviewer_obj['reviewerId']        =userList.find((useritem)=>useritem.Name==item).Id;
                                    }else if(item && QueueList.find((queueitem)=>queueitem.Name==item)){
                                        reviewer_obj['reviewerId']        =QueueList.find((queueitem)=>queueitem.Name==item).Id;
                                    }
                                    reviewer_obj['isAccessible']          =false;
                                    reviewer_obj['isEditAllowed']         =false;
                                    reviewer_obj['Selected']              =false;
                                    reviewer_obj['Process_Review_Details']=element.Process_Attribute_Review_Detail__c;
                                    reviewer_obj['related_task_id']       =null;
                                    reviewer_obj['review_related_taskid'] =null;
                                    reviewer_obj['comments']              =null;
                                    reviewer_obj['Issessioncommentavailable']    =false;
                                    console.log('reviewer_obj',JSON.stringify(reviewer_obj));
                                    each_checklist_reviewerlist.push(reviewer_obj);
                                }) 
                                checklist_obj.checklist_reviewer_array=each_checklist_reviewerlist;
                                 console.log('checklist_obj',JSON.stringify(checklist_obj));
                                    if(final_checklist.length > 0){
                                        if(final_checklist.find((item)=>item.checklistName==checklist_obj.checklistName)){
                                            console.log('item Exist');
                                        }else{
                                            final_checklist.push(checklist_obj); 
                                        }
                                    }else{
                                        final_checklist.push(checklist_obj);
                                    }
                                console.log('final_checklist',JSON.stringify(final_checklist));
                    }
            })
            //Assign Task Id as Per Checklist Detail
            console.log('taskId_related_fact Before Assigning Values',JSON.stringify(taskId_related_fact));
            taskId_related_fact.forEach((element)=>{
                    if(element && element.Process_Review_Checklist_Detail__r.Checklist_Name__c && element.Task_ID__c){
                        console.log('element',JSON.stringify(element));
                        if(final_checklist.length>0){
                            final_checklist.forEach((item)=>{
                                    if(item.checklistName==element.Process_Review_Checklist_Detail__r.Checklist_Name__c){
                                        let getchecklist_reviewer_array=item.checklist_reviewer_array;
                                        let task_rec=childTaskList.find((ts_item)=>ts_item.Id==element.Task_ID__c);
                                          if(getchecklist_reviewer_array.length>0){
                                                 getchecklist_reviewer_array.find((rv_item)=>{
                                                        if(task_rec!=null && task_rec!=undefined && task_rec.OwnerId!=null && task_rec.OwnerId!=undefined && rv_item.reviewerId==task_rec.OwnerId){
                                                            rv_item.related_task_id=task_rec.Id;
                                                            rv_item.isAccessible=true;
                                                            rv_item.checklistfactId=element.Id;
                                                            rv_item.review_related_taskid=element.Review_Related_TaskId__c;
                                                            rv_item.Selected=element.Checklist_Reviewer_value__c;
                                                            rv_item.comments=element.Comment_History__c;
                                                            rv_item.last_Commented_Date_On_Fact=element.Last_Commented_Date__c;
                                                            rv_item.last_task_reopen_date=task_rec.Last_Open_Date__c;
                                                            if(rv_item.reviewerId.startsWith('005')){
                                                                 rv_item.isEditAllowed =rv_item.reviewerId==userId?true:false
                                                            }else if(rv_item.reviewerId.startsWith('00G') && LoginUserRelatedGroup!=null && LoginUserRelatedGroup!=undefined && LoginUserRelatedGroup.length>0){
                                                                 rv_item.isEditAllowed =LoginUserRelatedGroup.includes(task_rec.Owner.Name)?true:false
                                                            }
                                                            if(task_rec.Last_Open_Date__c!=null && task_rec.Last_Open_Date__c!=undefined && element.Last_Commented_Date__c!=null && element.Last_Commented_Date__c!=undefined){
                                                                if (element.Last_Commented_Date__c > task_rec.Last_Open_Date__c) {
                                                                      rv_item.Issessioncommentavailable=true; 
                                                                }else if(task_rec.Last_Open_Date__c > element.Last_Commented_Date__c){
                                                                      rv_item.Issessioncommentavailable=false;
                                                                }          
                                                            }
                                                            
                                                        }
                                                })
                                          }
                                          item.checklist_reviewer_array=getchecklist_reviewer_array;
                                   }
                            })
                        }
                    }
            }) 
            console.log('final_checklist After Task Id Assignment',JSON.stringify(final_checklist));
            obj_finalchecklist.v_checklists=final_checklist; 
        }
        console.log('obj_finalchecklist',JSON.stringify(obj_finalchecklist));
        return obj_finalchecklist;
	},
    update_process_fact:function(component, event, helper,process_fact_record) {
        debugger;
        var taskRec=component.get("v.taskRec");
        var CheckList_Fact = component.get("v.CheckList_Fact");
        var Selected_task_checklist = component.get("v.Selected_task_checklist");
        var current_index_value = component.get("v.current_index_value");
        var action = component.get("c.upsert_PRCF");   
        action.setParams({
            "PRCFRecord":process_fact_record,
            "RelatedId":taskRec.WhatId
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                var result = response.getReturnValue();
                if(result!=null && result!=undefined && result.length>0){
                    let checklistJson=Selected_task_checklist.find((item)=>item.index==current_index_value);
                    if(checklistJson){
                        let reviewer_array=checklistJson.v_checklists;
                        if(reviewer_array!=null && reviewer_array!=undefined && reviewer_array.length>0){
                            reviewer_array.find((item)=>{
                                if(item.checklist_reviewer_array!=null && item.checklist_reviewer_array!=undefined){
                                    item.checklist_reviewer_array.forEach((currentItem)=>{
                                    let processFact_record=result.find(r_item=>r_item.Id==currentItem.checklistfactId);
                                        if(processFact_record!=null && processFact_record!=undefined && processFact_record.Id==currentItem.checklistfactId){
                                             currentItem.Selected=processFact_record.Checklist_Reviewer_value__c;
                                             currentItem.comments=processFact_record.Comment_History__c!=null && processFact_record.Comment_History__c!=undefined?processFact_record.Comment_History__c:''
                                        }
                                    })
                                }
                          })
                            checklistJson.v_checklists=reviewer_array;
                        }
                        Selected_task_checklist[current_index_value-1]=checklistJson;
                    }
                    component.get("v.Selected_task_checklist",Selected_task_checklist);
                }          
                if(result!=null && result!=undefined && result.length>0){
                    if(CheckList_Fact.length>0){
                        CheckList_Fact.find((item)=>{
                            let processFact_record=result.find(r_item=>r_item.Id==item.Id);
                            if(processFact_record!=null && processFact_record!=undefined && processFact_record.Id==item.Id){
                                item.Checklist_Reviewer_value__c=processFact_record.Checklist_Reviewer_value__c;
                                item.Comment_History__c=processFact_record.Comment_History__c!=null && processFact_record.Comment_History__c!=undefined ? processFact_record.Comment_History__c:'';
                                item.Last_Commented_Date__c=processFact_record.Last_Commented_Date__c!=null && processFact_record.Last_Commented_Date__c!=undefined?processFact_record.Last_Commented_Date__c:null;
                                component.set("v.checklisthistoryCommentValue",processFact_record.Comments__c);
                             }
                        })
                        console.log('CheckList_Fact',CheckList_Fact);
                        component.set("v.CheckList_Fact",CheckList_Fact);
                        component.set("v.CommentValue",'');
                    }
                    component.set("v.Isshowcomment",false)
                }
            }
			else if(state=='ERROR'){
              
            }            
        });  
        $A.enqueueAction(action);
    },
    checklistValidation_onSubmitForReview:function(component, event, helper,v_checklist) {
       debugger;
        var Is_Approve_review =component.get("v.Is_Approve_review");
        var Is_Reject_review  =component.get("v.Is_Reject_review");
        var v_isSkip=false;
        let counter=0;
        let recordAllowedForEdit=0;
        if(v_checklist.length>0){
            if(Is_Approve_review==true && Is_Reject_review==false){
                 v_checklist.forEach((item)=>{ 
                     if(item.checklist_reviewer_array!=null && item.checklist_reviewer_array!=undefined && item.checklist_reviewer_array.length>0){
                           item.checklist_reviewer_array.forEach((currentItem)=>{
                                    if(currentItem.isEditAllowed==true){ recordAllowedForEdit++ }
                                    if(currentItem.isEditAllowed==true && currentItem.Selected==true){counter++ }
                           })
                      }
                 })
                 //if(this.checkselectedRelatedtask_Status(component, event, helper,v_checklist)){return};
                  v_isSkip=recordAllowedForEdit==counter ?true:false
            }else if(Is_Approve_review==false && Is_Reject_review==true){
                   let addedCommentcount=0;
                   v_checklist.forEach((item)=>{ 
                     if(item.checklist_reviewer_array!=null && item.checklist_reviewer_array!=undefined && item.checklist_reviewer_array.length>0){
                           item.checklist_reviewer_array.forEach((currentItem)=>{
                                    if(currentItem.isEditAllowed==true){ recordAllowedForEdit++ }
                                    if(currentItem.isEditAllowed==true && currentItem.Selected==true){ counter++ }
                                    if(currentItem.isEditAllowed==true && currentItem.Selected==false && currentItem.Issessioncommentavailable==true){ addedCommentcount++}
                           })
                      }
                 })
                  v_isSkip=recordAllowedForEdit!=counter && ((recordAllowedForEdit-counter)==addedCommentcount) ?true:false
            }
        }
        return  v_isSkip;
    } ,
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
    },
    addComment_basisOf_Checklist:function(component, event, helper,cheklistFact_records) {
        debugger;
        
        var currentDatetime = new Date();
        var formattedDatetime = currentDatetime.toISOString()
        let currentUserName      =component.get("v.currentUserName");
        const date               = new Date();
        let Process_fact_array   =[];
        var comments             =component.get("v.CommentValue");
        var checklisthistoryCommentValue = component.get("v.checklisthistoryCommentValue");
        let editAllowedRecord;
        if(cheklistFact_records.length>0){
           // let comment_processfact=(new Date(date.toISOString()).toLocaleString(undefined, {timeZone: 'Asia/Kolkata'})) + "   [" + currentUserName + "] - " + comments + '\n' ;
             cheklistFact_records.forEach((item)=>{ 
                 let process_fact_object  ={Id:null,Checklist_Reviewer_value__c:false,Comments__c:null,Last_Commented_Date__c:null};                 
                     if(item){
                         process_fact_object.Id=item.checklistfactId;
                         process_fact_object.Checklist_Reviewer_value__c=item.Selected;
                         process_fact_object.Comments__c= comments;
                         /*if(checklisthistoryCommentValue!= null && checklisthistoryCommentValue!=undefined){
                             process_fact_object.Comments__c= comment_processfact + '\n' + checklisthistoryCommentValue;
                         }else{
                             process_fact_object.Comments__c= comment_processfact + '\n'  
                         }*/ 
                         if(item.isEditAllowed){
                             process_fact_object.Last_Commented_Date__c=formattedDatetime;
                         }
                         Process_fact_array.push(process_fact_object);
                     }
             })
        }
        
        if(Process_fact_array!=null && Process_fact_array!=undefined && Process_fact_array.length>0){
            this.update_process_fact(component, event, helper,Process_fact_array);
        }
    },
    handleSessionvalues:function(component, event, helper) {
       debugger;
       var checklistIndex_id=component.get("v.current_checklistindex_value");
       var index_based_checklist=component.get("v.index_based_checklist");
        if(index_based_checklist!=null && index_based_checklist!=undefined && index_based_checklist.length>0){
            index_based_checklist.forEach((item)=>{
                if(item.v_checklists!=null && item.v_checklists!=undefined && item.v_checklists[checklistIndex_id].checklist_reviewer_array!=null && item.v_checklists[checklistIndex_id].checklist_reviewer_array!=undefined){
                    item.v_checklists[checklistIndex_id].checklist_reviewer_array.forEach((c_item)=>{
                        if(c_item){
                            c_item.Issessioncommentavailable=true;
                            
                        }
                    })
                }
            })
        }
        component.set("v.index_based_checklist",index_based_checklist);
    },
     //Shifted This Validation On Reviewer Component
    checkselectedRelatedtask_Status:function(component, event, helper,checklists_records) {
       debugger;
        var shouldskip=false;
        var Opportunity_Related_task = component.get("v.Opportunity_Related_task");
        console.log('checklists_records',checklists_records);
        if(checklists_records.length>0){
            checklists_records.forEach((item)=>{ 
               if(item.checklist_reviewer_array!=null && item.checklist_reviewer_array!=undefined && item.checklist_reviewer_array.length>0){
                     item.checklist_reviewer_array.forEach((currentItem)=>{
                        if(shouldskip) {return}
                        if(currentItem.review_related_taskid!=null && currentItem.review_related_taskid!=undefined && currentItem.isEditAllowed==true){
                            let reviewrelated_task = Opportunity_Related_task.find((item)=>item.Id==currentItem.review_related_taskid);
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
            })     
        } 
        return shouldskip;
    } ,
    getUniquecomments:function(component, event, helper,comments) {
       debugger;
       let uniqueStringVariable = "";
        if(comments!=null && comments!=undefined && comments.length>0){
            let uniqueStrings = new Set();
            comments.forEach(str => {
                if (!uniqueStrings.has(str)) {
                    uniqueStrings.add(str);
                    uniqueStringVariable += str + "\n";
                }
            });
       }
       return uniqueStringVariable;
    },
    
})