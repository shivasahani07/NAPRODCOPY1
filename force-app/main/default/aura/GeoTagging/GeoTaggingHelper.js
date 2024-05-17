({
    
    makeAjaxRequest : function(component, url) {
        debugger;
        var component = component.find('component');
        
        //Make Ajax request by calling method from component
        component.callAjax("POST", url, true,
                           function(xmlhttp){
                               console.log('xmlhttp:', xmlhttp);
                               
                               
                               //Show response text if successful
                               //Display error message otherwise
                               if (xmlhttp.status == 200) {
                let userObj = JSON.parse(xmlhttp.responseText);

				console.log(userObj);
                var completeaddressstring = '';
                if(userObj.results[0].address_components.find(component => component.types.includes('sublocality_level_1'))){
                     completeaddressstring = completeaddressstring + ', '+ userObj.results[0].address_components.find(component => component.types.includes('sublocality_level_1')).long_name;
                }
                if(userObj.results[0].address_components.find(component => component.types.includes('sublocality_level_2'))){
                    completeaddressstring = completeaddressstring + ', ' + userObj.results[0].address_components.find(component => component.types.includes('sublocality_level_1')).long_name;
                }
                if(userObj.results[0].address_components.find(component => component.types.includes('locality'))){
                    completeaddressstring = userObj.results[0].address_components.find(component => component.types.includes('locality')).long_name;
                }
                if( userObj.results[0].address_components.find(component => component.types.includes('administrative_area_level_1'))){
                    completeaddressstring = completeaddressstring + ', ' + userObj.results[0].address_components.find(component => component.types.includes('administrative_area_level_1')).long_name;
                }
                if(userObj.results[0].address_components.find(component => component.types.includes('country'))){
                    completeaddressstring = completeaddressstring + ', ' + userObj.results[0].address_components.find(component => component.types.includes('country')).long_name;
                }
                if(userObj.results[0].address_components.find(component => component.types.includes('postal_code'))){
                    completeaddressstring = completeaddressstring + ', ' +userObj.results[0].address_components.find(component => component.types.includes('postal_code')).long_name;
                }
                //component.set('v.CompleteAddress',Completeaddress);
                component.set('v.CompleteAddressstring',completeaddressstring);
            }
            else if (xmlhttp.status == 400) {
                window.alert('There was an error 400');
            }
            else {
                window.alert('Something else other than 200 was returned', city);
                }
                           }
                          );
    },
    
    GetAddressFromApex : function(component, event, latit, lang){
        debugger;
        //var latit = component.get('latitude');
        //var longit = component.get('longitude');
        var latit = latit.toString();
        var lang = lang.toString();
        var action = component.get("c.GoogleMapReverseGeocodeCallout");
        action.setParams({ "lat": latit,"lng": lang });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var Completeaddress = response.getReturnValue();
                if(Completeaddress != null && Completeaddress != undefined){
                    component.set("v.CompleteAddressstring", Completeaddress);
                }
            }
        });
         $A.enqueueAction(action);
    }
    
})