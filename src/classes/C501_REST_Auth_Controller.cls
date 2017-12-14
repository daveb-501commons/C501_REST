global with sharing class C501_REST_Auth_Controller {

    global static String strAccessToken {get; private set;}
   
	private C501_SharedCode c501_SharedCode;
    
    global C501_REST_Auth_Controller() {
        c501_SharedCode = new C501_SharedCode();
    }
    
    global static PageReference GetAccessCode() {
        
        C501_REST_Settings__c standardRESTSetting = C501_REST_Settings__c.getInstance('Sandbox');

        // Check valid user address
/*
        String strUserAddress = c501_SharedCode.GetUserIPAddress();
        String strValidClientAddresses = standardRESTSetting.valid_client_addresses__c;
        if (!strValidClientAddresses.contains('*') && !strValidClientAddresses.contains(strUserAddress))
        {
            strAccessToken = 'Permission Denied - Invalid Client Address';
            return null;
        }
*/
        
        String payLoad = 'grant_type=refresh_token' +
            '&client_id=' +
            standardRESTSetting.client_id__c +
            '&client_secret=' +
            standardRESTSetting.client_secret__c +
            '&refresh_token=' +
            standardRESTSetting.refresh_token__c;
        
        Http httpMessage = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('https://srportal--bspwebsync.cs14.my.salesforce.com/services/oauth2/token');
        httpRequest.setMethod('POST');
        httpRequest.setBody(payLoad);
        HttpResponse httpResponse = httpMessage.send(httpRequest);

        // Parse JSON response
        JSONParser parser = JSON.createParser(httpResponse.getBody());
        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.FIELD_NAME &&
                parser.getText() == 'access_token') {
                    
                    parser.nextToken();
                    strAccessToken = parser.getText();
                    
                    return null;
            }
        }
        
        return null;
    }
}