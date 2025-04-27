@isTest
public with sharing class ZendeskAuthHttpCalloutMock implements HttpCalloutMock{
    public Boolean isExistenceUser { get; set; }
    // public static final String ZENDESK_API_BASE_URI = 'https://serverworks1563533001.zendesk.com';
    public static final String ZENDESK_API_BASE_URI = System.Label.PS_ZENDESK_URL;

    public ZendeskAuthHttpCalloutMock(Boolean isExistenceUser) {
        this.isExistenceUser = isExistenceUser;
    }
    /**
     * レスポンス
     */    
    public HTTPResponse respond(HTTPRequest req) {
        
        String body;
        Integer statusCode;

        // if (req.getEndpoint().contains(ZENDESK_API_BASE_URI + '/oauth/tokens')) {
        if (req.getEndpoint().contains(System.Label.PS_CERT_URI)) {
            Map<String, Object> bodyMap;
            if (isExistenceUser) {
                bodyMap = new Map<String, Object>{
                    'access_token' => 'new List<Object>{userMap},'
                };
            } else {
                bodyMap = new Map<String, Object>{
                    'error' => 'error'
                };
            }
            body = JSON.serialize(bodyMap);
            statusCode = 200;
        // } else if (req.getEndpoint().contains(ZENDESK_API_BASE_URI + '/api/v2/users/me')) {
        } else if (req.getEndpoint().contains(System.Label.PS_USER_URI)) {
            Map<String, Object> bodyMap;
            if (isExistenceUser) {
                Map<String, Object> userMap = new Map<String, Object>{
                    'id' => 1,
                    'name' => 'テスト',
                    'email' => 'test@sky365.co.jp.ut',
                    'details' => 'テスト会社'
                };
                bodyMap = new Map<String, Object>{
                    'user' => userMap
                };
            } else {
                bodyMap = new Map<String, Object>{
                    'error' => 'error'
                };
            }
            
            body = JSON.serialize(bodyMap);
            statusCode = 200;
        } else if (req.getEndpoint().contains(ZENDESK_API_BASE_URI + '/api/v2/users/1/organizations')) {
            Map<String, Object> organization = new Map<String, Object>{
                'id' => 1,
                'organization_id' => 3
            };
            List<Map<String,Object>> organizationList = new List<Map<String,Object>>();
            organizationList.add(organization);
            Map<String, Object> bodyMap = new Map<String, Object>{
                'organizations' => organizationList
            };
            body = JSON.serialize(bodyMap);
            statusCode = 200;
        }

        HttpResponse res = new HttpResponse();
        if (String.isNotBlank(body)) res.setBody(body);
        res.setStatusCode(statusCode);

        return res;
    }
}