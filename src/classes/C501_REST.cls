@RestResource(urlMapping='/C501_REST/*')
global with sharing class C501_REST {

    public class InvalidParameterValueException extends Exception {}
    public class NoDataFoundException extends Exception {}

	private C501_SharedCode c501_SharedCode;
    
    global C501_REST() {
        c501_SharedCode = new C501_SharedCode();
    }
    
    @HttpGet
    global static void doGetCampaignMember() {

        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        try {
            
            res.responseBody = Blob.valueOf(JSON.serialize(get()));
            res.statusCode = 200;
        }
        catch (InvalidParameterValueException e) {
            
            res.responseBody = Blob.valueOf(
                String.valueOf(e) + '\n\n' + e.getStackTraceString()
            );
            res.statusCode = 400;
        }
        catch (NoDataFoundException e) {
            
            res.responseBody = Blob.valueOf(
                String.valueOf(e) + '\n\n' + e.getStackTraceString()
            );
            res.statusCode = 400;
        }
        catch (Exception e) {
            res.responseBody = Blob.valueOf(
                'General Exception: ' + String.valueOf(e) + '\n\n' + e.getStackTraceString()
            );
            res.statusCode = 500;
        }
    }
    
  @HttpPost
    global static void doPostCampaignMember(String campaignid, String source, String email, String name, Boolean newsletter, String message) {
        
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        try {
            
            res.responseBody = Blob.valueOf(JSON.serialize(post(campaignId, source, email, name, newsletter, message)));
            res.statusCode = 201;
        }
        catch (InvalidParameterValueException e) {
            
            res.responseBody = Blob.valueOf(
                String.valueOf(e) + '\n\n' + e.getStackTraceString()
            );
            res.statusCode = 400;
        }
        catch (NoDataFoundException e) {
            
            res.responseBody = Blob.valueOf(
                String.valueOf(e) + '\n\n' + e.getStackTraceString()
            );
            res.statusCode = 400;
        }
        catch (Exception e) {
            res.responseBody = Blob.valueOf(
                'General Exception: ' + String.valueOf(e) + '\n\n' + e.getStackTraceString()
            );
            res.statusCode = 500;
        }
    }
    
	private static CampaignMember get() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String campaignMemberId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        // Check Id
        if (string.isBlank(campaignMemberId) || campaignMemberId.length() != 15) {
	        throw new InvalidParameterValueException('Error: Invalid campaignMemberId (expecting 15 character string): ' + campaignMemberId);
        }
            
        List<CampaignMember> existingCampaignMemberQuery = [SELECT Id
                                       FROM CampaignMember
                                       WHERE Id=:campaignMemberId
                                       LIMIT 1];
        if (existingCampaignMemberQuery.isEmpty()) {
			throw new NoDataFoundException('No Data found for campaignMemberId: ' + campaignMemberId);
        }
        
        return existingCampaignMemberQuery[0];
    }
    
    private static CampaignMember post(String campaignid, String source, String email, String name, Boolean newsletter, String message) {
        
        // Check Required Url Parameters - campaignId, email
        if (string.isBlank(campaignId) || campaignId.length() != 15) {
   	        throw new InvalidParameterValueException('Error: Required campaignId is invalid (expecting 15 character string): ' + campaignId);
        }
        
        if (String.isBlank(source)) {
   	        throw new InvalidParameterValueException('Error: Required source field is blank.');
        }

        if (String.isBlank(email) || email.length() < 4 || !c501_SharedCode.ValidateEmail(email)) {
  	        throw new InvalidParameterValueException('Error: Required email address is invalid: ' + email);
        }
 
        // Check if name blank then set to front part of email address since last name required for a Salesforce contact
        if (string.isBlank(name)) {
            List<String> nameTokens = email.split('@');
            name = nameTokens[0];
        }
        
	    if (newsletter == null) {
            newsletter = false;
        }

	    if (message == null) {
            message = '';
        }
        
        Contact contact = new Contact();
        contact.C501_REST_Managed__c = true;
        contact.email = email;
        contact.LastName = name;
        if (contact.LastName.contains(' ')) {
            List<String> nameTokens = contact.LastName.split(' ');
            contact.FirstName = nameTokens[0];
            contact.LastName = contact.LastName.substring(nameTokens[0].length());
        }

        Account account = new Account();
        account.name = contact.LastName;

        // Check for existing contact
        List<Contact> existingContactQuery = [SELECT Id
                                       FROM Contact
                                       WHERE Email=:contact.Email AND LastName=:contact.LastName AND C501_REST_Managed__c=TRUE
                                       LIMIT 1];
        if (!existingContactQuery.isEmpty()) {
            
            contact.Id = existingContactQuery[0].Id;
        }
        else {
            insert account;
            
            contact.AccountId = account.Id;
            insert contact;
        }

        CampaignMember campaignMember = new CampaignMember();
        campaignMember.CampaignId = campaignId;
        campaignMember.ContactId = contact.Id;
            
        // Check for existing Campaign Member
        List<CampaignMember> existingCampaignMemberQuery = [SELECT Id
                                       FROM CampaignMember
                                       WHERE ContactId=:contact.Id AND CampaignId=:campaignId
                                       LIMIT 1];
        if (!existingCampaignMemberQuery.isEmpty()) {
            
            existingCampaignMemberQuery[0].C501_REST_Message__c = message;
            existingCampaignMemberQuery[0].C501_REST_Newsletter__c = newsletter;
                
            update existingCampaignMemberQuery[0];
            
            return existingCampaignMemberQuery[0];
        }
        else {
            campaignMember.C501_REST_Message__c = message;
          	campaignMember.C501_REST_Newsletter__c = Boolean.valueOf(newsletter);
        
        	insert campaignMember;
        }
            
        return campaignMember;
    }
}