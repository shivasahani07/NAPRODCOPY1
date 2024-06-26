public class MEMOScheduleRTGS implements Schedulable{
    public void execute(SchedulableContext sc) {
        boolean isSaturday = false;
        Datetime currentDateTime = Date.today();
        if(currentDateTime.format('EEEE') == 'Saturday'){
            isSaturday = true;
        }
        if(!isSaturday){
            System.enqueueJob(new MEMOJobQueueable('RTGS'));
        }
            
    }
}