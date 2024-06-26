@isTest(SeeAllData=true)
public class MEMOScheduleClassTest2 {
    
    @isTest
    static void testScheduleOnWeekday() {
        Test.startTest();
        String cronExp = '0 0 13 * * ?';
        MEMOScheduleClass scheduleJob = new MEMOScheduleClass();
        System.schedule('Test MEMOScheduleClass Job', cronExp, scheduleJob);
        
        Test.stopTest();
    }
}