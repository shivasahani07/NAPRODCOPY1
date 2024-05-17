@isTest
public class CheckCurrentUserEditRight_Test {
    
     @isTest
    Public static void UserEditAccessTestClass(){
        
        system.runAs(new user(Id=userinfo.getUserId())){
        
            Group grp = new Group();
            grp.name = 'Business Team Do';
            grp.Type = 'queue'; 
            insert grp;
            
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId=Grp.Id;
            insert grpMem1;
        
            Task TaskRec=new Task();
            TaskRec.Status='Open';
            TaskRec.OwnerId=Grp.Id;
            TaskRec.Priority='Normal';
            TaskRec.Subject='Call';
            insert TaskRec;
            
            Set<Id> publicGroupIdSet 	= new Set<Id>();
            Set<Id> UserGroudId			= new set<Id>();
            
            if(TaskRec.ownerId != null && String.valueOf(TaskRec.OwnerId).startsWith('00G')){
                string  queueId=TaskRec.ownerId;
                system.debug('queueId--'+queueId);
                Group grpRec=[SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE Type ='queue' and id =: queueId];
                
                if(grpRec != null){
                    for(GroupMember gm : grpRec.GroupMembers){
                        publicGroupIdSet.add(gm.UserOrGroupId);
                    }
                    
                    if(!publicGroupIdSet.isEmpty()){
                        List<GroupMember> gmList = new List<GroupMember>();
                        gmList = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId in: publicGroupIdSet];
                        system.debug('gmList::'+gmList);
                        if(!gmList.isEmpty()){
                            for(GroupMember gm : gmList){
                                system.debug('inside');
                                UserGroudId.add(gm.UserOrGroupId);
                            }
                        }
                    }
                }
                
            }
            boolean editAccess=false;
            string LoginUserId= UserInfo.getUserId();
            system.debug('UserGroudId::'+UserGroudId);
            if(!UserGroudId.isEmpty()){
                if(UserGroudId.contains(LoginUserId)){
                    editAccess = true;
                }
            }
            CheckCurrentUserEditRight.currentUserEditRight(LoginUserId,TaskRec.Id);
            system.debug('editAccess::'+editAccess);
        }
        
       // return editAccess;
    }

}