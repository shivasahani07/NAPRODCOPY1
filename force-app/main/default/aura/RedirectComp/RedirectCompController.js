({
	doInit: function (component, event, helper) {
		debugger;
		var caseId = component.get("v.recordId");
		var action = component.get("c.reedirecttosite");
		action.setParams({
			"recId": caseId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state == 'SUCCESS') {
				var result = response.getReturnValue();
				component.set("v.CaseRec", result.CaseRecdetail);
				component.set("v.AccRec", result.AccRecDetail);

				if ((result.CaseRecdetail.Financial_Account__c == null || result.CaseRecdetail.Financial_Account__c == undefined) && (result.AccRecDetail == null || result.AccRecDetail == undefined)) {
					component.set("v.ShowMessage", true);
				}
				else {
					if (result.CaseRecdetail.Financial_Account__c != null && result.CaseRecdetail.Financial_Account__c != undefined) {
						if ((result.CaseRecdetail.Financial_Account__r.Originating_System__c != null && result.CaseRecdetail.Financial_Account__r.Originating_System__c != undefined) &&
							(result.CaseRecdetail.Financial_Account__r.Originating_System_URL_ID__c != null && result.CaseRecdetail.Financial_Account__r.Originating_System_URL_ID__c != undefined)) {

							component.set("v.ShowLoanDetailButton", true);
							component.set("v.disableLoanDetailButton", false);
							component.set("v.LoanBtnMessage", 'View Loan Details');
							//component.set("v.ShowMessage", false);
						}
						else if ((result.CaseRecdetail.Financial_Account__r.Originating_System__c == null || result.CaseRecdetail.Financial_Account__r.Originating_System__c == undefined) &&
							(result.CaseRecdetail.Financial_Account__r.Originating_System_URL_ID__c == null || result.CaseRecdetail.Financial_Account__r.Originating_System_URL_ID__c == undefined)) {

							//component.set("v.ShowMessage", true);
							component.set("v.ShowLoanDetailButton", true);
							component.set("v.disableLoanDetailButton", true);

							component.set("v.LoanBtnMessage", 'Contact With Admin');
						}

					}
					else if (result.CaseRecdetail.Financial_Account__c == null || result.CaseRecdetail.Financial_Account__c == undefined) {
						//if ((result.CaseRecdetail.Financial_Account__r.Originating_System__c == null || result.CaseRecdetail.Financial_Account__r.Originating_System__c == undefined) &&
							//(result.CaseRecdetail.Financial_Account__r.Originating_System_URL_ID__c == null || result.CaseRecdetail.Financial_Account__r.Originating_System_URL_ID__c == undefined)) {

							//component.set("v.ShowMessage", true);
							component.set("v.ShowLoanDetailButton", true);
							component.set("v.disableLoanDetailButton", true);

							component.set("v.LoanBtnMessage", 'Contact With Admin');
						//}

					}
					if (result.AccRecDetail != null && result.AccRecDetail != undefined) {
						if ((result.AccRecDetail.Originating_System__c != null && result.AccRecDetail.Originating_System__c != undefined) &&
							(result.AccRecDetail.Originating_System_URL_ID__c != null && result.AccRecDetail.Originating_System_URL_ID__c != undefined)) {


							component.set("v.ShowCustDetailButton", true);
							component.set("v.disableCustDetailButton", false);
							component.set("v.CustBtnMessage", 'View Customer details');

							//component.set("v.ShowMessage", false);
						}
						else if ((result.AccRecDetail.Originating_System__c == null || result.AccRecDetail.Originating_System__c == undefined) &&
							(result.AccRecDetail.Originating_System_URL_ID__c == null || result.AccRecDetail.Originating_System_URL_ID__c == undefined)) {


							component.set("v.ShowCustDetailButton", true);
							component.set("v.disableCustDetailButton", true);
							component.set("v.CustBtnMessage", 'Contact With Admin');
							//component.set("v.ShowMessage", true);
						}

					} else if (result.AccRecDetail == null || result.AccRecDetail == undefined) {
						// if((result.AccRecDetail.Originating_System__c == null || result.AccRecDetail.Originating_System__c == undefined) &&
						//    (result.AccRecDetail.Originating_System_URL_ID__c == null || result.AccRecDetail.Originating_System_URL_ID__c == undefined)){


						component.set("v.ShowCustDetailButton", true);
						component.set("v.disableCustDetailButton", true);
						component.set("v.CustBtnMessage", 'Contact With Admin');
						//component.set("v.ShowMessage", true);
						//}

					}

				}

			} else {
				component.set("v.ShowMessage", true);
			}
		});
		$A.enqueueAction(action);
	},

	ViewLoanLMSsystem: function (component, event, helper) {
		debugger;

		var caseRecDetail = component.get("v.CaseRec");
		var relocateString;
		if (caseRecDetail.Financial_Account__r.Originating_System__c == 'Perdix') {
			var PerdixBaseUrl = $A.get("$Label.c.PerdixBaseUrl");
			relocateString = PerdixBaseUrl + caseRecDetail.Financial_Account__r.Originating_System_URL_ID__c;

		}
		else if (caseRecDetail.Financial_Account__r.Originating_System__c == 'Nimbus') {
			var NimbusBaseUrl = $A.get("$Label.c.NimbusBaseUrl");
			relocateString = NimbusBaseUrl + caseRecDetail.Financial_Account__r.Originating_System_URL_ID__c;

		}
        window.open(relocateString,'_blank' );
        //window.location.href = relocateString;
		//window.location.replace(relocateString);
	},

	ViewCustLMSsystem: function (component, event, helper) {
		debugger;

		var AccRecDetail = component.get("v.AccRec");
		var relocateString;
		if (AccRecDetail.Originating_System__c == 'Perdix') {
			var PerdixCustBaseUrl = $A.get("$Label.c.PerdixCustomerBaseUrl");
			relocateString = PerdixCustBaseUrl + AccRecDetail.Originating_System_URL_ID__c;

		}
		else if (AccRecDetail.Originating_System__c == 'Nimbus') {
			var NimbusCustBaseUrl = $A.get("$Label.c.NimbusCustomerBaseUrl");
			relocateString = NimbusCustBaseUrl + AccRecDetail.Originating_System_URL_ID__c;

		}
        window.open(relocateString,'_blank' );
        //window.location.href = relocateString;
		//window.location.replace(relocateString);
	}
})