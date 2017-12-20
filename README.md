C501 REST
====================

REST for Salesforce integration from external website (e.g., JavaScript)

## Getting Started

 * **Install Package**
 
    add URL 
 
 * **Setup Connected App**
 
    ```
    In Salesforce:
      - Create Connected App: https://developer.salesforce.com/page/Connected_Apps
      - Selected OAuth Scope include Access and manage yor data (api), Perform requests on your behalf at any time (refresh_token, offline_access), Provide access toyour data via the Web (web).
      - Callbackup Url set to Sandbox: https://test.salesforce.com/services/oauth2/callback, Prod: https://login.salesforce.com/services/oauth2/callback.
          NOTE: You can also use the instance name instead of test. or login.
    ```

 * **Generate Access Token**
 
     	https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/quickstart_oauth.htm
        
        curl https://<instanceUrl>.salesforce.com/services/oauth2/token -d "grant_type=password" -d "client_id=<client_id>" -d "client_secret=<client_secret>" -d "username=<username>" -d "password=<password><security_token>"

        The response will include the access_token which is used in the get or post calls as the sessionid

        Error Responses
          ○ {"error":"invalid_client_id","error_description":"client identifier invalid"} 
          If you get the following response - is probably because you just created the connected app and Salesforce hasn't completed the setup
          ○ {"error":"invalid_grant","error_description":"authentication failure"}IF you get this error probably means you need to include the security token after the password.  Change "password=<password>" to "password=<password><security_token>"

* **Test Access Token**
 
     	https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_code_sample_basic.htm

      Get:

        Get Call: curl -H "Authorization: Bearer <sessionId>" "https://instance.salesforce.com/services/apexrest/C501_REST/<campaignMemberId>"
        
        Use the access_token from the token call response as the sessionid
        
        curl -H "Authorization: Bearer " "https://srportal--bspwebsync.cs14.my.salesforce.com/services/apexrest/Account/001c000001K5Rci"

      Post:

        Response Code
        •	201 – OK “Created” success code, for POST request.
        •	400 – Invalid parameter (response will include more details)
        •	500 – general exception
        
        Post parameters
        •	campaignId (required)
        •	email (required)
        •	name
        •	newsletter (true or false)
        •	message
      
        1) Create post.txt
        2) curl -H "Authorization: Bearer <sessionId>" -H "Content-Type: application/json" -d @post.txt "https://<login or test instance>.salesforce.com/services/apexrest/C501_REST/

* **Refresh Access Token**
 
     	https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_refresh_token_oauth.htm 
  
## Implementation Notes

* sample folder includes Ajax sample code for getting a token via a get and using the token with a put.  

There are 2 REST Services

C501_REST_Auth – is a public REST service (no authentication required) with a single get to retrieve the Token.  Access is still restricted based on the CORS safe list
https://bspwebsync-bff-sandboxbspwebsync.cs14.force.com/services/apexrest/C501_REST_Auth

Required Step: You need to add the C501_REST_Auth class to the Public Sites via the Sites -> Public Access Settings -> Enabled Apex Class Access.

C501_REST – requires authentication token which is provided by C501_REST_Auth and has a single Post method.  Access is also restricted based on the CORS safe list
https://bspwebsync-bff-sandboxbspwebsync.cs14.force.com/services/apexrest/C501_REST/

Request an access_token

Public REST: https://bspwebsync-bff-sandboxbspwebsync.cs14.force.com/services/apexrest/C501_REST_Auth

Response:

00Dc0000003vyvV!AR0AQOtBC_WXZCJ_erB69qjZbnmEnXYUTXq8LAmsiMj._to5tz1ZPrl0GKaRyrp18l3.mLcOey5uWfn2zuLjFDDHqOmwc5.k

The response is the Token/SessionID you can use in the POST call

Send Post

1)      Create a post.txt file (campaignid, source, and email are required fields)

Example post.txt contents

{

  "campaignid" : "701c0000000XzpH"

  ,"source" : "Text field so track where the request comes from on the site"

  ,"email" : "daveb@501commons.org"

  ,"name" : "dave"

  ,"newsletter" : "true"

  ,"message" : "my messageII"

}

2)      curl -H "Authorization: Bearer 00Dc0000003vyvV!AR0AQDr3IFbDPTfjYs6Im12SsZ2XrjCeeNlHC1ix6CT1k3Iq8R7qF5I1jiWkBKRZ.f4l7.6N50oF3.HQkkDM0OYbW8PFAgWk " -H "Content-Type: application/json" -d @post.txt "https://bspwebsync-bff-sandboxbspwebsync.cs14.force.com/services/apexrest/C501_REST/"

Response:
{"attributes":{"type":"CampaignMember","url":"/services/data/v41.0/sobjects/CampaignMember/00vc00000069YECAA2"},"Id":"00vc00000069YECAA2","C501_REST_Message__c":"my messageII","C501_REST_Newsletter__c":true}

 

Response Code

201 – OK “Created” success code, for POST request.
400 – Invalid parameter (response will include more details)
500 – general exception




