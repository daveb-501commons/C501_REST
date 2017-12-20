@RestResource(urlMapping='/C501_REST_Auth')
global class C501_REST_Auth {
    @HttpGet
    global static String doGet() {
        
        C501_REST_Settings__c standardRESTSetting = C501_REST_Settings__c.getInstance('Sandbox');

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
                    return parser.getText();
            }
        }
        
        return null;
    }
}