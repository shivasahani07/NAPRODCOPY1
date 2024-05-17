({
    doInit : function(component, event, helper) {
        debugger;
        //helper.findGeolocation(component, event, helper);
        //console.log('doInit called');
        //helper.CaptureRecordTyepList(component, event, helper);
        
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
                const url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+lat+',' +lng +'&key='+ 'AIzaSyB4SPqkO0ZQbxT-EU4l886H9Y3ipf1NMW0';
        		//helper.makeAjaxRequest(component, url);

                
            }
        } else {
            error('Geolocation is not supported');
        }
        
                
    },

    /*handleradioChange : function(component, event, helper){
        debugger;
        var changeValue = event.getParam("value");
        component.set("v.SelectedRecordTyepId",changeValue);
        var lat = component.get("v.latitude");
        var lang = component.get("v.longitude");

        var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
               "entityApiName": 'Lead',
               "recordTypeId": changeValue,
               "defaultFieldValues": {
                'Geo_Location__Latitude__s' : lat,
                'Geo_Location__Longitude__s' : lang
            }
            });
            createRecordEvent.fire();


    },
    handleOnSubmit : function(component, event, helper) {
        debugger;
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        eventFields["Description"] = 'Lead was created from Lightning RecordEditForm'; //Add Description field Value
        component.find('leadCreateForm').submit(eventFields); //Submit Form
    }*/
})