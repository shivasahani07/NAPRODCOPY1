public class MEMOJobQueueable implements Queueable, Database.AllowsCallouts{
    private String mode;
    
    public MEMOJobQueueable(String mode) {
        this.mode = mode;
    }
    
    public void execute(QueueableContext context) {
        // Fetch the list of accounts to be processed
        //List<Account> accounts = [SELECT Id, Name FROM Account];
        
        // Call the handler class method with the accounts and mode
        SystemSchedualMEMOGeneration handler = new SystemSchedualMEMOGeneration();
        handler.CreateSystemGeneratedTask(null, mode);
    }
}