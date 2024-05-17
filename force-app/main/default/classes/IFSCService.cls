public class IFSCService {
    @AuraEnabled
    public static IFSCDetailsWrapper getIFSCDetails(String ifscCode) {
        String endpoint = 'https://ifsc.razorpay.com/' + ifscCode;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        IFSCDetailsWrapper ifscDetails = new IFSCDetailsWrapper();
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            system.debug('IFSCDetailsWrapper---'+(IFSCDetailsWrapper) JSON.deserialize(response.getBody(), IFSCDetailsWrapper.class));
            return (IFSCDetailsWrapper) JSON.deserialize(response.getBody(), IFSCDetailsWrapper.class);
        } else {
            // Handle error response
            System.debug('HTTP request failed with status code: ' + response.getStatusCode());
            // Set default values for all properties
            ifscDetails.BRANCH = '';
            ifscDetails.BANK = '';
            ifscDetails.NEFT = false;
            ifscDetails.STATE = 'Not found';
            ifscDetails.CENTRE = 'Not found';
            ifscDetails.CONTACT = 'Not found';
            ifscDetails.CITY = 'Not found';
            ifscDetails.DISTRICT = 'Not found';
            ifscDetails.SWIFT = 'Not found';
            ifscDetails.ISO3166 = 'Not found';
            ifscDetails.RTGS = false;
            ifscDetails.IMPS = false;
            ifscDetails.UPI = false;
            ifscDetails.MICR = 'Not found';
            ifscDetails.ADDRESS = 'Not found';
            ifscDetails.BANKCODE = 'Not found';
            ifscDetails.IFSC = 'Not found';
        }
        return ifscDetails;
    }
    
    
    
    public class IFSCDetailsWrapper {
        @AuraEnabled
        public Boolean NEFT{get;set;}
        @AuraEnabled
        public String STATE{get;set;}
        @AuraEnabled
        public String CENTRE{get;set;}
        @AuraEnabled
        public String CONTACT{get;set;}
        @AuraEnabled
        public String BRANCH{get;set;}
        @AuraEnabled
        public String CITY{get;set;}
        @AuraEnabled
        public String DISTRICT{get;set;}
        @AuraEnabled
        public String SWIFT{get;set;}
        @AuraEnabled
        public String ISO3166{get;set;}
        @AuraEnabled
        public Boolean RTGS{get;set;}
        @AuraEnabled
        public Boolean IMPS{get;set;}
        @AuraEnabled
        public Boolean UPI{get;set;}
        @AuraEnabled
        public String MICR{get;set;}
        @AuraEnabled
        public String ADDRESS{get;set;}
        @AuraEnabled
        public String BANK{get;set;}
        @AuraEnabled
        public String BANKCODE{get;set;}
        @AuraEnabled
        public String IFSC{get;set;}
        
    }
    
}