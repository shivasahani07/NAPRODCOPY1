Global without sharing class GoogleMapCallOutController {
    
    @auraEnabled(continuation=true)
    Public static String GoogleMapReverseGeocodeCallout(String lat, String lng){
        system.debug('lat =====> ' + lat);
        system.debug('lng =====> ' + lng);
        String CompleteAddress = '';
        try{
            //String key='AIzaSyB4SPqkO0ZQbxT-EU4l886H9Y3ipf1NMW0';
            string key = System.Label.GoogleMapReverseGeocodingAPIKey;
            Http httpProtocol = new Http();
            // Create HTTP request to send.
            HttpRequest request = new HttpRequest();
            // Set the endpoint URL.
            String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+lat+',' +lng +'&key='+ key;
            request.setEndPoint(endpoint);
            // Set the HTTP verb to GET.
            request.setMethod('GET');
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            HttpResponse response = httpProtocol.send(request);
            System.debug('####Body : '+response.getBody());
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                Map<String, object> GooglemapResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                
                List<Object> Addresslist = (List<Object>)GooglemapResponseMap.get('results');
                integer j=0;
                for(integer i=0; i<Addresslist.size(); i++){
                    //for(Object obj : Addresslist){
                    System.debug('Addresslist[i] =====>> '+Addresslist[i]);
                    if(i==0){
                        Map<String, Object> addressmap = (map<String, Object>)Addresslist[i];
                        System.debug('addressmap =====>> '+addressmap);
                        CompleteAddress = String.valueof(addressmap.get('formatted_address'));
                    }
                }
            }
            
        }
        catch(Exception e){
            
        }
        
        
        System.debug('CompleteAddress =====>> '+CompleteAddress); 
        return CompleteAddress;
    }
    
    @future(callout=true)
    public static void parseJSONResponse(String lat, string lng) {    
        String CompleteAddress = '';
        //String address='18.5538+73.9477';
        //string lat = '12.8957036';
        //string lng = '77.596188';
        String key='AIzaSyC5Z3twwN_hX_uP1JrDnY_726nH26Zb058';
        Http httpProtocol = new Http();
        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();
        // Set the endpoint URL.
        String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+lat+',' +lng +'&key='+ 'AIzaSyB4SPqkO0ZQbxT-EU4l886H9Y3ipf1NMW0';
        request.setEndPoint(endpoint);
        // Set the HTTP verb to GET.
        request.setMethod('GET');
        // Send the HTTP request and get the response.
        // The response is in JSON format.
        HttpResponse response = httpProtocol.send(request);
        System.debug('####Body : '+response.getBody());
        
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
            Map<String, object> GooglemapResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            List<Object> Addresslist = (List<Object>)GooglemapResponseMap.get('results');
            integer i=0;
            for(Object obj : Addresslist){
                if(i==0){
                    Map<String, Object> addressmap = (map<String, Object>)obj;
                    CompleteAddress = String.valueof(addressmap.get('formatted_address'));
                }
            } 
        }
        System.debug('CompleteAddress : '+CompleteAddress);
        
    }
    
}