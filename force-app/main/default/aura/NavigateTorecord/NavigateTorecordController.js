({
    invoke: function (component, event, helper) {
        // Get the record ID attribute
        debugger;
        var record = component.get("v.recordId");
        // window.open('/' + record); 

        // Get the Lightning event that opens a record in a new tab
        var redirect = $A.get("e.force:navigateToSObject");

        // Pass the record ID to the event
        var defurl = 'lightning/r/Lead/' + record+ '/view';
        redirect.setParams({
            // "url": defurl
           "recordId": record,
           "slideDevName": "detail",
           "isredirect": "true"
        });

        // Open the record
        redirect.fire();


        // var navService = component.find("navService");
        // // Sets the route to /lightning/o/Account/home
        // var pageReference = {
        //     "type": "standard__recordPage",
        //     "attributes": {
        //         "recordId": record,
        //         "objectApiName": "Lead",
        //         "actionName": "view"
        //     }
        // };
        // component.set("v.pageReference", pageReference);
        // // Set the URL on the link or use the default if there's an error
        // var defaultUrl = "#";
        // navService.generateUrl(pageReference)
        //     .then($A.getCallback(function (url) {
        //         component.set("v.url", url ? url : defaultUrl);
        //     }), $A.getCallback(function (error) {
        //         component.set("v.url", defaultUrl);
        //     }));
        //     //event.preventDefault();
        //     navService.navigate(pageReference);

    },
    navigateToRecord : function(component , event, helper){
        var record = component.get("v.recordId");
        window.open('/' + record);  
    },

})