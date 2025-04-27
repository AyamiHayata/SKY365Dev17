public virtual class CommunityCommonController {
    /* クライアント許可コード */
    public String code {get;set;}

    /* ログインユーザ名 */
    public String name {get;set;}

    /* クライアントToken */
    public String cleantToken = null;

    /* クライアントユーザID */
    // public String userId;
    
    /* ログインユーザ情報 */
    public ZendeskUser__c userInfo {get; set;}

    /* 認証情報 */
    private String authorizationHeader = null;

    /* ブラウザセッションID */
    public String sessionid {get; set;}
    
    /* Zendesk URI */ 
    public static final String ZENDESK_API_BASE_URI = System.Label.PS_ZENDESK_URL;

    /* Zendesk 認証URI */    
    public Static String CERT_URI = System.Label.PS_CERT_URI;

    /* Zendesk クライアント情報取得URI */    
    public Static String USER_URI = System.Label.PS_USER_URI;

    /* Zendesk 秘密鍵 */    
    public Static String PRIVATE_KEY = System.Label.PS_PRIVATE_KEY;

    /* Zendesk ClientID */    
    public Static String CLIENT_ID = System.Label.PS_CLIENT_ID;

    /* Salesforce RedirectURI */    
    public Static String REDIRECT_URI = System.Label.PS_REDIRECT_URI;

    /* ZendeskLogout URL */    
    public Static String LOGOUT_URL = System.Label.PS_LOGOUT_URL;

    /* 管理者Token */
    public Static String ADMIN_TOKEN = System.Label.PS_ADMIN_TOKEN;

    /* TimeOut 分 */
    public Static Integer TIMEOUT_MIN = 60;

    /* セッションチェック */
    public Static final Integer SESSION_ERROR = -1;
    public Static final Integer SESSION_FALSE = 0;
    public Static final Integer SESSION_OK = 1;

    /* ログアウトページ */
    public static final PageReference LOGOUT_PAGE = new PageReference(LOGOUT_URL);

    /* Debug用 */
    public String debugString {get;set;}

    /* 利用規約 */
    private static final String RIYOUKIYAKU_STR = '利用規約'; 
    private static final String OSHIRASE_STR = 'お知らせ'; 
    
    public Decimal kiyakuversion {get;set;}
    public SiteTerms__c riyoukiyaku {get;set;}
    public SiteTerms__c oshirasekiyaku {get;set;}
    public String approvedcollapse {get;set;}
    public boolean approvedchk {get;set;}


    public String kiyaku {get;set;}
    public String info {get;set;}

    /* ZendeskUserId */
    public String zendeskUserId {get; set;}
    
    public CommunityCommonController() {
        userInfo = new ZendeskUser__c();
    }

    /**
     * サイトログイン時の初期処理
     *
     */
    public virtual PageReference initLoginAction() { 
        try {

            // PageReference loginPage = new PageReference(LOGOUT_URL);
            Map<String, Object> userMap = new Map<String, Object>();
            Boolean sessionFlg = false;

            // セッション有効チェック
            Integer sessionChkResult = sessionCheck();
            if(sessionChkResult==SESSION_ERROR){
                return LOGOUT_PAGE;
            }else if(sessionChkResult==SESSION_OK){
                sessionFlg = true;
            }

            if (!sessionFlg) {
                // クライアント oAuth認証
                String json = createJsonMessage();
                HttpResponse res = new HttpResponse();
                res = restApiHttpRequest(CERT_URI, json, null);
                System.debug('**==**== res => ' + res);
                Map<String, Object> resultJson = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                debugString += 'resultJson:' + res.getBody() + '\r\n';
                System.debug('**==**== debugString => ' + debugString);
                // oAuth認証チェック        
                if (resultJson.containsKey('error')) {
                    // URL 改ざん
                    return LOGOUT_PAGE;
                } else {
                    String access_token = (String)resultJson.get('access_token');
                    cleantToken = 'Bearer ' + access_token;
                }

                // クライアントユーザID取得
                res = restApiHttpRequest(USER_URI, null, cleantToken);
                resultJson = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                userMap = (Map<String, Object>) resultJson.get('user');     
                userInfo.zendeskUserId__c = String.valueOf(userMap.get('id'));
            }

            // 組織情報取得
            String endPoint = ZENDESK_API_BASE_URI + '/api/v2/users/' + userInfo.zendeskUserId__c + '/organizations.json';
            getOrganizations(userInfo, endPoint);
            /*
            HttpResponse res = restApiOrganizations(userInfo.zendeskUserId__c);      
            Map<String, Object> result = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            List<Object> organizations = (List<Object>) result.get('organizations');
            for (Object element : organizations) {
                Map<String, Object> eMap = (Map<String, Object>)element;
                if(String.isNotBlank(userInfo.ZendeskOrgId2__c)){
                    userInfo.ZendeskOrgId2__c = userInfo.ZendeskOrgId2__c + ',' + String.valueOf(eMap.get('id'));
                }else{
                    userInfo.ZendeskOrgId2__c = String.valueOf(eMap.get('id'));
                }
                debugString += 'organization:' + eMap.get('id') + '\r\n';
            }
            */
            
            if (!sessionFlg) {
                userInfo.Email__c = String.valueOf(userMap.get('email'));   // メール
                userInfo.Name__c = String.valueOf(userMap.get('name'));     // 氏名
                userInfo.Code__c = code;                                    // 認可コード
            }
            // サイト利用規約取得
            List<SiteTerms__c> kiyakulist = [SELECT Id,Version__c,Sentence__c FROM SiteTerms__c WHERE SentenceType__c=:RIYOUKIYAKU_STR ORDER BY Version__c DESC LIMIT 1];
            List<SiteTerms__c> oshiraselist = [SELECT Id,Version__c,Sentence__c FROM SiteTerms__c WHERE SentenceType__c=:OSHIRASE_STR ORDER BY Version__c DESC LIMIT 1];
            riyoukiyaku = kiyakulist.get(0);
            oshirasekiyaku = oshiraselist.get(0);
            kiyakuversion = riyoukiyaku.Version__c;
            kiyaku = kiyakulist.get(0).Sentence__c;

            userInfo.LastLoginDateTime__c = Datetime.now();                 // 最終ログイン日時
            userInfo.SessionId__c = sessionid;                              // セッションID
            Schema.SObjectField f = ZendeskUser__c.Fields.ZendeskUserId__c;
            Database.upsert(userInfo,f,false);

            name = userInfo.Name__c; 

        } catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() + ' ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getLineNumber() +' '+e.getMessage()));
        }
        return null;
    }

    /**
     * ログインユーザに紐づくZendeskの組織情報を取得
     * @param ZendeskUser__c userInfo
     * @param Srting endpoint
     *
     */    
    private void getOrganizations(ZendeskUser__c userInfo, String endPoint) {
        HttpResponse res = restApiOrganizations(endPoint);      
        Map<String, Object> result = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
        List<Object> organizations = (List<Object>) result.get('organizations');
        for (Object element : organizations) {
            Map<String, Object> eMap = (Map<String, Object>)element;
            if(String.isNotBlank(userInfo.ZendeskOrgId2__c)){
                userInfo.ZendeskOrgId2__c = userInfo.ZendeskOrgId2__c + ',' + String.valueOf(eMap.get('id'));
            }else{
                userInfo.ZendeskOrgId2__c = String.valueOf(eMap.get('id'));
            }
        }
        // 次ページ
        String nextPage = (String) result.get('next_page');
        if (!String.isEmpty(nextPage)) {
            getOrganizations(userInfo, nextPage);
        }
    }

    /**
     * サイトログイン時の初期処理
     *
     */
    public virtual PageReference initAction() { 
        try {
            // セッション有効チェック
            Integer sessionChkResult = sessionCheck();
            if(sessionChkResult==SESSION_ERROR){
                return LOGOUT_PAGE;
            }
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() + ' ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getLineNumber() +' '+e.getMessage()));
        }
        return null;
    }
    /**
     * セッションチェック
     *
     */
    private Integer sessionCheck() { 
        Integer returncode = SESSION_FALSE;
        // セッション有効チェック
        List<ZendeskUser__c> loginInfo = [SELECT Id, ZendeskUserId__c, ZendeskOrgId2__c, Email__c, name__c, LastLoginDateTime__c, code__c, SessionId__c,ConsentVersion__c FROM ZendeskUser__c WHERE code__c =: code];
System.debug('**==**== loginInfo => ' + loginInfo);

        if (loginInfo.size() > 0) {
            System.debug('**==**== SessionId__c => ' + loginInfo[0].SessionId__c);
            System.debug('**==**== sessionid => ' + sessionid);
            // タイムアウトまたは、セッションIDが異なる

//            if (loginInfo[0].LastLoginDateTime__c.addMinutes(TIMEOUT_MIN) < Datetime.now() ||
//                loginInfo[0].SessionId__c != sessionid) {
    
            if (loginInfo[0].SessionId__c != sessionid) {
                returncode = SESSION_ERROR;
            } else if (loginInfo[0].LastLoginDateTime__c.addMinutes(TIMEOUT_MIN) < Datetime.now()) {
                returncode = SESSION_ERROR;
            } else {
                userInfo.zendeskUserId__c = loginInfo[0].ZendeskUserId__c;
                userInfo.ZendeskOrgId2__c = loginInfo[0].ZendeskOrgId2__c;
                userInfo.name__c = loginInfo[0].name__c;
                userInfo.SessionId__c = loginInfo[0].SessionId__c;
                userInfo.ConsentVersion__c = loginInfo[0].ConsentVersion__c;
                userInfo.Email__c = loginInfo[0].Email__c;
                returncode = SESSION_OK;
            }
        }
        return returncode;
    }
    /**
     * createJsonMessage
     * @return String JSON
     */ 
    private String createJsonMessage() {
        return '{"grant_type": "authorization_code", ' +
        '"code": "' + code + '", ' +
        '"client_id": "'+ CLIENT_ID +'", ' +
        '"client_secret": "'+ PRIVATE_KEY +'", ' +
        '"redirect_uri": "'+ REDIRECT_URI +'", ' +
        '"scope": "users:read organizations:read"}';
   }

    /**
     * HttpRequest(JSON)
     * @param String 送信パラメータ
     */
    private HttpResponse restApiHttpRequest(String endPoint, String body, String token) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        if (!String.isEmpty(token)) {
            request.setHeader('Authorization', token);
        }
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        if (!String.isEmpty(body)) {
            request.setBody(body);
        }
        Http http = new Http();
        return http.send(request);
        
    }
    
    /**
     * 組織情報を取得
     * @param String Endpoint
     */
    private HttpResponse restApiOrganizations(String endPoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', ADMIN_TOKEN);
        // request.setEndpoint('https://serverworks1563533001.zendesk.com/api/v2/users/' + userId + '/organizations.json');
        //request.setEndpoint(ZENDESK_API_BASE_URI + '/api/v2/users/' + userId + '/organizations.json');
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        System.debug('**==**== request =>' + request);
        Http http = new Http();
        return  http.send(request);
    }
}