/* testclass(MEMOScheduleClassTest2) cover
MEMOScheduleClass
MEMOJobQueueable
SystemSchedualMEMOGeneration
*/
public class MEMOScheduleClass implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        // Enqueue Queueable jobs for both Cheque and RTGS modes
        boolean isSaturday = false;
        Datetime currentDateTime = Date.today();
        /*if(currentDateTime.format('EEEE') == 'Saturday'){
            isSaturday = true;
        }*/
        
        Datetime checkCurrentDateTime = Datetime.now();
        Boolean isgreater430 = false;
        Date currentDate = Date.today();
        Datetime fourThirtyPM = Datetime.newInstance(currentDate, Time.newInstance(16, 40, 0, 0));
        /*if(currentDateTime > fourThirtyPM){
            isgreater430 = true;
        }*/
        
        if(currentDateTime.format('EEEE') != 'Saturday' && currentDateTime < fourThirtyPM){
            System.enqueueJob(new MEMOJobQueueable('Cheque'));
            System.enqueueJob(new MEMOJobQueueable('RTGS'));
        }else if(currentDateTime.format('EEEE') != 'Saturday' && currentDateTime > fourThirtyPM){
            System.enqueueJob(new MEMOJobQueueable('RTGS'));
        }else{
            System.enqueueJob(new MEMOJobQueueable('RTGS'));
        }
        
    }
}