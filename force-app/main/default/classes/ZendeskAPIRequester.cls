public class ZendeskAPIRequester {

    /* endPoint */
    // public static final String ZENDESK_API_BASE_URI = 'https://serverworks1563533001.zendesk.com';
    public static final String ZENDESK_API_BASE_URI = System.Label.PS_ZENDESK_URL;

    /* loginid */
    private String loginid;
    /* password */
    private String password;
    /* authorizationHeader */
    private String authorizationHeader;

    /**
     * コンストラクタ
     */
    public ZendeskAPIRequester() {
        getZendeskAccount();
    }

    /**
     * Zendesk接続情報取得
     *
     */  
    public void getZendeskAccount() {
        ZendeskAccount__mdt mdt = [SELECT loginid__c, password__c FROM ZendeskAccount__mdt WHERE DeveloperName = 'Zendesk_Portal'];
        this.loginid = mdt.loginid__c;
        this.password = mdt.password__c;

        Blob headerValue = Blob.valueOf(loginid + '/token:' + password);
        this.authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
    }

    /**
     * HttpRequest(JSON)
     *
     * @param method メソッド
     * @param endpoint エンドポイント
     * @param body ボディ
     * @return HTTPレスポンス
     */
    private HttpResponse restApiHttpRequest(String method, String endpoint, String body) {

        System.debug('★endpoint★' + endpoint);

        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod(method);
        if (String.isNotBlank(body)) request.setBody(body);
        System.debug('★body★' + body);

        HttpResponse response = new Http().send(request);
        System.debug('★response★' + response);
        System.debug('★response.getBody★' + response.getBody());

        return response;
    }

    /**
     * Zendeskユーザ検索
     * https://developer.zendesk.com/api-reference/ticketing/users/users/#search-users
     * 
     * @param email メールアドレス
     * @return HttpResponse
     */
    public HttpResponse getZendeskUser(String email) {

        System.debug('★ユーザ検索★');

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/users/search';
        endpoint += '?query=email:"' + EncodingUtil.urlEncode(email, 'UTF-8') + '"';

        HttpResponse res = restApiHttpRequest('GET', endpoint, null);

        return res;
    }

    /**
     * Zendesk組織取得
     * @param userid ユーザーID
     * @return HttpResponse
     */
    public HttpResponse getZendeskOrganizations(String userid) {

        System.debug('★組織検索★');

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/users/' + userid + '/organizations.json';
        

        HttpResponse res = restApiHttpRequest('GET', endpoint, null);

        return res;
    }

    /**
     * Zendeskチケット取得
     * @param userid ユーザーID
     * @param organizationsrid zendesk組織ID
     * @return HttpResponse
     */
    public HttpResponse getZendeskTickets(String userid,String organization) {

        System.debug('★チケット検索★');

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/search.json?query=type:ticket';
        endPoint = endPoint + '%20status<closed'; 
        endPoint = endPoint + '%20requester:' + userid; 
        endPoint = endPoint + '%20organization:' + organization;

        HttpResponse res = restApiHttpRequest('GET', endpoint, null);

        return res;
    }

    /**
     * Zendeskユーザ作成
     * https://developer.zendesk.com/api-reference/ticketing/users/users/#create-user
     * 
     * @param organization_id Zendesk組織ID
     * @param name 氏名
     * @param company 会社名
     * @param email メール
     * @return HttpResponse
     */
    public HttpResponse createZendeskUser(String organization_id, String name, String company, String email) {

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/users';

        Map<String, String> zendeskUser = new Map<String, String>{
            'organization_id' => organization_id,
            // 'name' => name,
            'name' => company + '　' + name + ' 様',
            'email' => email,
            // 'details' => company,
            'role' => 'end-user',
            'ticket_restriction' => 'organization'
        };
        Map<String, Object> reqMap = new Map<String, Object>{'user' => zendeskUser};
        String body = system.JSON.serialize(reqMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }

    /**
     * Zendeskメンバーシップ作成
     * https://developer.zendesk.com/api-reference/ticketing/organizations/organization_memberships/#create-membership
     * 
     * @param orgid Zendesk組織ID
     * @param userid ZendeskユーザID
     * @return HttpResponse
     */
    public HttpResponse createZendeskMembership(String orgid, String userid) {

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/organization_memberships';

        Map<String, String> zendesOrgMembership = new Map<String, String>{
            'user_id' => userid,
            'organization_id' => orgid
        };
        Map<String, Object> reqMap = new Map<String, Object>{'organization_membership' => zendesOrgMembership};
        String body = system.JSON.serialize(reqMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }

    /**
     * Zendeskメンバーシップ検索
     * https://developer.zendesk.com/api-reference/ticketing/organizations/organization_memberships/#list-memberships
     * 
     * @param orgid Zendesk組織ID
     * @param userid ZendeskユーザID
     * @return HttpResponse
     */
    public HttpResponse searchZendeskMembership(String orgid, String userid) {

        System.debug('★メンバーシップ検索★');

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/users/' + userid + '/organization_memberships.json';

        HttpResponse res = restApiHttpRequest('GET', endpoint, null);

        return res;
    }

    /**
     * Zendeskメンバーシップ削除
     * https://developer.zendesk.com/api-reference/ticketing/organizations/organization_memberships/#delete-membership
     * 
     * @param orgid Zendesk組織ID
     * @param userid ZendeskユーザID
     * @return Zendesk organization_membership ID
     */
    public HttpResponse deleteZendeskMembership(String membershipid) {

        System.debug('★メンバーシップ削除★');

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/organization_memberships/' + membershipid;

        HttpResponse res = restApiHttpRequest('DELETE', endpoint, null);

        return res;
    }

    /**
     * Zendeskユーザ更新(メールアドレス以外)
     * https://developer.zendesk.com/api-reference/ticketing/users/users/#update-user
     * 
     * @param userid ZendeskユーザID
     * @param name 氏名
     * @param company 会社名
     * @return HttpResponse
     */
    public HttpResponse updateZendeskUser(String userid, String name, String company) {

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/users/' + userid;

        Map<String, String> zendeskUser = new Map<String, String>{
            // 'name' => name,
            'name' => company + '　' + name + ' 様',
            // 'details' => company,
            'ticket_restriction' => 'organization'
        };
        Map<String, Object> reqMap = new Map<String, Object>{'user' => zendeskUser};
        String body = system.JSON.serialize(reqMap);

        HttpResponse res = restApiHttpRequest('PUT', endpoint, body);

        return res;
    }

    /**
     * ZendeskユーザIdentity検索
     * https://developer.zendesk.com/api-reference/ticketing/users/user_identities/#list-identities
     * 
     * @param userid ZendeskユーザID
     * @return HttpResponse
     */
    public HttpResponse searchZendeskIdentity(String userid) {

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/users/' + userid + '/identities';

        HttpResponse res = restApiHttpRequest('GET', endpoint, null);

        return res;
    }

    /**
     * ZendeskユーザーID(アイデンティティ)更新
     * https://developer.zendesk.com/api-reference/ticketing/users/user_identities/#update-identity
     * 
     * @param userid ZendeskユーザID
     * @param identityid Zendesk Identity ID
     * @param email メールアドレス
     * @return HttpResponse
     */
    public HttpResponse updateZendeskIdentity(String userid, String identityid, String email) {

        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/users/' + userid + '/identities/' + identityid;

        Map<String, String> zendeskIdentity = new Map<String, String>{
            'value' => email
        };
        Map<String, Object> reqMap = new Map<String, Object>{'identity' => zendeskIdentity};
        String body = system.JSON.serialize(reqMap);

        HttpResponse res = restApiHttpRequest('PUT', endpoint, body);

        return res;
    }

    /**
     * Zendesk組織削除
     * https://developer.zendesk.com/api-reference/ticketing/organizations/organizations/#bulk-delete-organizations
     * 
     * @param orgids Zendesk組織IDのリスト
     * @return HttpResponse
     */
    public HttpResponse deleteZendeskOrganizations(List<String> orgids) {

        String endpoint = ZENDESK_API_BASE_URI
            + '/api/v2/organizations/destroy_many?ids=' + String.join(orgids, ',');

        HttpResponse res = restApiHttpRequest('DELETE', endpoint, null);

        return res;
    }

    /**
     * Zendesk oAuth ログアウト処理
     * https://developer.zendesk.com/api-reference/ticketing/account-configuration/sessions/#delete-session
     * 
     * @param orgid Zendesk組織ID
     * @param userid ZendeskユーザID
     * @return HttpResponse
     */
    public HttpResponse deleteZendeskSession(String userid) {

        System.debug('★ログアウト処理★');
        String endpoint = ZENDESK_API_BASE_URI + '/api/v2/users/' + userid + '/sessions';

        HttpResponse res = restApiHttpRequest('DELETE', endpoint, null);

        return res;
    }
}