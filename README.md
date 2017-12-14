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

* **JavaScript**

If interfacing w/ REST using JavaScript then here are a couple helpful links.
https://github.com/developerforce/Force.com-JavaScript-REST-Toolkit
https://javascriptobfuscator.com

Use the JavaScript REST Toolkit for building the solution and obfuscator for hiding all the post calls.  Want to make sure to hide the post calls so hacker can not get the token.




