public with sharing class LogPush {

    /* Push logs to POW*/
    public static void userInteractionLogPush(Boolean isSynchronous, String eventType, String eventDetail, String additionalDetail){
        String orgId = UserInfo.getOrganizationId();
        String companyName = UserInfo.getOrganizationName();
        String firstName = UserInfo.getFirstName();
        String lastName = UserInfo.getLastName();
        String email = UserInfo.getUserEmail();
        String orgType = isSandbox ? 'sandbox':'production';
        if(!Test.isRunningTest()) {
            if(isSynchronous) {
                push(orgId, companyName, eventType, eventDetail, firstName, lastName, email, additionalDetail, orgType);
            } else {
                asynchronousLogPush(orgId, companyName, eventType, eventDetail, firstName, lastName, email, additionalDetail, orgType);
            }
        }
    }

    @future(callout = true)
    public static void asynchronousLogPush(String orgId, String companyName, String eventType, String eventDetail, String firstName, String lastName, String email, String additionalDetail, String orgType){
        push(orgId, companyName, eventType, eventDetail, firstName, lastName, email, additionalDetail, orgType);
    }

    @TestVisible
    private static void push(String orgId, String companyName, String eventType, String eventDetail, String firstName, String lastName, String email, String additionalDetail, String orgType){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String endPointBaseURL = BreadwinnerUtil.getSupportEndpointBaseURL();
            String packageVersion = BreadwinnerUtil.getBW_PackageVersion();//BreadwinnerUtil.getBW_PackageVersion();
            String body = '';

            body = '{"org_id":"' + orgId + '",';
            body += '"company_name":"' + companyName + '",';
            body += '"event_type":"' + eventType + '",';
            body += '"event_detail":"' + eventDetail + '",';
            body += '"first_name":"' + firstName + '",';
            body += '"last_name":"' + lastName + '",';
            body += '"email":"' + email + '",';
            body += '"additional_detail":"' + additionalDetail.replaceAll('"','&quot').replaceAll('\n',' &nl ') + '",';
            body += '"org_type":"' + orgType + '",';
            body += '"package_version":"' + packageVersion + '",';
            body += '"app" : "Payments"}';

            request.setEndpoint(endPointBaseURL+'/api/v2/user_interaction_log');
            //request.setEndpoint('https://support-staging.breadwinnerhq.com/api/v2/user_interaction_log');
            request.setMethod('POST');
            request.setBody(body);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            authorize(request);
            System.debug('Request Body : ' + request.getBody());
            HttpResponse response = http.send(request);
            System.debug('response body '+response);
        }
        catch(exception e){
            System.debug('Exception e : ' + e.getMessage());
        }
    }
    public static void authorize(HttpRequest req){
        Breadwinner_Payments_Metadata__mdt auth = [SELECT MasterLabel, Key__c,DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName = 'Breadwinner_Token' LIMIT 1];
        Blob b = EncodingUtil.base64Decode(EncodingUtil.base64Decode(auth.Key__c).toString());
        req.setHeader('Auth-Token', '' + EncodingUtil.convertFromHex(b.toString()).toString());
    }

    // This needs to be it's own private method because this class shouldn't call other classes
    private static Boolean isSandbox{
        get {
            if (isSandbox == null){
                isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        set;
    }

}