({
    doInit: function (component, event, helper) {
        debugger;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(success);
            function success(position) {
                var lat = position.coords.latitude;
                component.set("v.latitude", lat);
                var lng = position.coords.longitude;
                component.set("v.longitude", lng);
                console.log(lat, lng)
                var inputVariables = [
                    {
                        name: 'latitude',
                        type: 'String',
                        value: lat
                    },
                    {
                        name: 'Longitude',
                        type: 'String',
                        value: lng
                    },

                ];
                component.set("v.geoLocation",inputVariables );
                const url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+lat+',' +lng +'&key='+ 'AIzaSyB4SPqkO0ZQbxT-EU4l886H9Y3ipf1NMW0';
        		//helper.makeAjaxRequest(component, url);
                    helper.GetAddressFromApex(component, event, lat, lng);
                    

            }
        } else {
            error('Geolocation is not supported');
        }
    },
})