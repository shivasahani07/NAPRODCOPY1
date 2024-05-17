public class CheckCurrentUserEditRight {

    public static boolean currentUserEditRight(Id userId,Id objectId){
       /* Group Query  userid where type is group*/
        /*handle logged in user for task edit access based on type of queue*/
        
        Task tsRec = [select id,ownerId from task where id =: objectId];
        String queueId = '';
        boolean editAccess = false;
        Set<Id> publicGroupIdSet 	= new Set<Id>();
        Set<Id> UserGroudId			= new set<Id>();
        if(tsRec.ownerId != null && String.valueOf(tsRec.OwnerId).startsWith('00G')){
            queueId = tsRec.ownerId;
            system.debug('queueId::'+queueId);
            if(queueId != ''){
                Group grp = [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE Type ='queue' and id =: queueId];
                system.debug('grp::'+grp);
                if(grp != null){
                    for(GroupMember gm : grp.GroupMembers){
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
        }
        system.debug('UserGroudId::'+UserGroudId);
        if(!UserGroudId.isEmpty()){
            if(UserGroudId.contains(userId)){
                editAccess = true;
            }
        }
        system.debug('editAccess::'+editAccess);
        return editAccess;
    }
}