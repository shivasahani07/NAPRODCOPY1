({
    findGeolocation : function(component, event) {
        debugger;

        console
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(success);
            function success(position) {
                var lat = position.coords.latitude;
                component.set("v.latitude", lat);
                var lng = position.coords.longitude;
                component.set("v.longitude", lng);
                console.log(lat, lng)

                component.set('v.mapMarkers', [
                    {
                        location: {
                            Latitude: lat,
                            Longitude: lng
                            
                        }
                    }
                ]);
                component.set('v.zoomLevel',16);
            }
        } else {
            error('Geolocation is not supported');
        }
    },

    CaptureRecordTyepList : function(component, event){
        var LeadRecordType = [];
        var action = component.get("c.CaptureRecordTypeList");
        //action.setParams({ firstName : cmp.get("v.firstName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseValue = response.getReturnValue();
                if (responseValue.length >0) {
                    for (let i = 0; i < responseValue.length; i++) {
                        LeadRecordType.push(
                            {
                                label: responseValue[i].Name,
                                value: responseValue[i].Id
                            }
                        )
                    }
                    
                    component.set("v.LeadRecordTypeList",LeadRecordType );
                }
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);


    },
    
    makeAjaxRequest : function(component, url) {
        debugger;
        var callingchildmethod = component.find('GetCityComponent');
        
        //Make Ajax request by calling method from component
        callingchildmethod.callAjax("POST", url, true,
            function(xmlhttp){
            console.log('xmlhttp:', xmlhttp);
                

            //Show response text if successful
            //Display error message otherwise
            if (xmlhttp.status == 200) {
                let userObj = JSON.parse(xmlhttp.responseText);

				console.log(userObj);
                var completeaddressstring = '';
                
                //const Colony = userObj.results[0].address_components.find(component => component.types.includes('sublocality_level_3')).long_name;
				               
                if(userObj.results[0].address_components.find(component => component.types.includes('sublocality_level_1'))){
                    const Nagar = userObj.results[0].address_components.find(component => component.types.includes('sublocality_level_1')).long_name;
                    completeaddressstring = completeaddressstring + Nagar + ', ';
                }
                
                if(userObj.results[0].address_components.find(component => component.types.includes('sublocality_level_2'))){
                    const Phase = userObj.results[0].address_components.find(component => component.types.includes('sublocality_level_2')).long_name;
                     completeaddressstring = completeaddressstring + Phase + ', ';
				} 
                
                if(userObj.results[0].address_components.find(component => component.types.includes('locality'))){
                    const city = userObj.results[0].address_components.find(component => component.types.includes('locality')).long_name;
                    completeaddressstring = completeaddressstring + city + ', ';
                }
                
                if(userObj.results[0].address_components.find(component => component.types.includes('administrative_area_level_1'))){
                    const State = userObj.results[0].address_components.find(component => component.types.includes('administrative_area_level_1')).long_name;
                	completeaddressstring = completeaddressstring + State + ', ';
				}
                
                if(userObj.results[0].address_components.find(component => component.types.includes('country'))){
                    const Country = userObj.results[0].address_components.find(component => component.types.includes('country')).long_name;
                    completeaddressstring = completeaddressstring + Country + ', ';
                }
                
                if(userObj.results[0].address_components.find(component => component.types.includes('postal_code'))){
                    const PostalCode = userObj.results[0].address_components.find(component => component.types.includes('postal_code')).long_name;
                     completeaddressstring = completeaddressstring + PostalCode;
                }
                const Completeaddress = userObj.results[0].formatted_address;
               // component.set("v.CompleteAddress",Completeaddress);
                component.set("v.CompleteAddressstring",completeaddressstring); 
            }
            else if (xmlhttp.status == 400) {
                //window.alert('There was an error 400');
            }else {
                //window.alert('Something else other than 200 was returned', city);
                }
            }
        );
    }
})