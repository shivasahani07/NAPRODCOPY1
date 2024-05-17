public with sharing class Constants {
    
    // ========================================================= Sobject name Constanst =================================================
    public static final string SOBJECT_LEAD = 'Lead';



    // =================================================== case Status Picklist Constant =================================================

    public static final string CASE_STATUS_AWAITING_PARTNER_REPLY = 'Awaiting partner reply'; 
    public static final string CASE_STATUS_PARTNER_REPLIED_BACK = 'Partner Replied Back';
    public static final string CASE_STATUS_REOPENED = ' ReOpened';

    // ================================================== Lead Status Picklist Constant ==================================================

    public static final string LEAD_STATUS_NEW = 'New'; 
    
    // ======================================================= API Constants =============================================================

    public static final string API_EDUCATION_LOAN_APPLICATION = 'Education Loan Application';
    public static final string API_SUCCESS = 'CUSTOMER CREATED SUCCESSFULLY';
    public static final string API_ACTIVITY_SUCCESS = 'ACTIVITY CREATED SUCCESSFULLY';
    public static final string API_UPDATE_ACTIVITY_SUCCESS = 'ACTIVITY UPDATED SUCCESSFULLY';
    public static final string API_UPDATED_SUCCESS = 'CUSTOMER DETAILS UPDATED SUCCESSFULLY';
    public static final string API_SUCCESS_APPLICATION = 'APPLICATION CREATED SUCCESSFULLY';
    public static final string API_UPDATED_SUCCESS_APPLICATION = 'APPLICATION DETAILS UPDATED SUCCESSFULLY';
    public static final string API_UPDATED_FAILLED_APPLICATION = 'APPLICATION FAILLED TO CREATED DUE TO SOME ERROR. PLEASE CHECK!!';
    public static final string API_FAILURE = 'FAILURE'; 
    public static final string API_REQUEST_BODY_IS_NULL = 'REQUEST BODY IS NULL';
    public static final string API_NOERROR = 'NOERROR';
    public static final string API_OPP_EXTERNALID_ISSUE = 'NO EXTERNAL ID FOUND';
    public static final string API_OPP_JOURNEYID_FOUND = 'NO JOURNEY ID FOUND'; 
    public static final string API_CASE_SUCCESS = 'CASE CREATED SUCCESSFULLY';
    public static final string API_UPDATE_CASE_SUCCESS = 'CASE UPDATED SUCCESSFULLY';   


    // ======================================================= Opportunity StageName Constants =============================================================

    public static final string OPP_STAGENAME_CLOSED_WON = 'Closed Won';
    public static final string OPP_STAGENAME_CLOSED_LOST = 'Closed Lost';
    public static final string OPP_CUSTOMERTYPE_INDIVIDUAL = 'Individual';

    // ======================================================= Task Status Constants =============================================================

    public static final String TASK_STATUS_COMPLETED = 'Completed';
    public static final String TASK_STATUS_SYSTEM_CLOSED = 'System Closed';
    public static final String TASK_STATUS_SUBMITED_FOR_REVIEW = 'Submited For Review';
    public static final String DOC_HANDLER_SUBMITTED_FOR_EXECUTION = 'Submitted For Execution';
    public static final String PAYABLE_STATUS_MEMO_CREATED = 'Memo Created';
    public static final String DOC_HANDLER_MEMO_EXECUTED = 'MEMO EXECUTED';
    public static final String OTC_DOCUMENT_COLLECTION = 'OTC Document Collection';
    public Static final String PDD_DOCUMENT_COLLECTION = 'PDD Document Collection';
    public Static final String OTC_DOC_TYPE = 'OTC';
    public Static final String PDD_DOC_TYPE = 'PDD';
    public Static final String DOC_HANDLER_DRAFT = 'Draft';
    
    //========================Do Onboarding Process Stages ==============================
    
    Public Static Final String TERM_SHEET_FINALIZATION 			= 	'Term Sheet Finalization';
    Public Static Final String INTERNAL_STACK_HOLDER_SIGN_OFF 	= 	'Internal Stack Holder Signoff';
    Public Static Final String TECH_INTEGRATION					=	'Tech Integration';
    Public Static Final String CC_APPROVALS						=	'CC Approvals';
    Public Static Final String SLA_DRAFTING						= 	'SLA Drafting';
    Public Static Final String COMPLETED						= 	'Completed';
    Public Static Final String INPROGRESS						= 	'In Progress';
    
    
    //----------------------Email Services ----------------------------//
    Public static Final String SALESFORCE = 'Salesforce';
    Public static Final String NIMBUS = 'Nimbus';

    
}