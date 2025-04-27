public class ZabbixAPIRequester {

    /* loginid */
    private String loginid;
    /* password */
    private String password;
    /* endpoint */
    private String endpoint;
    /* chartendpoint  2023.12.11 add*/
    private String chartendpoint;
    /* zabbixVersion 2024.05.14 add*/
    public String zabbixVersion;

    /**
     * コンストラクタ
     */
    public ZabbixAPIRequester(String datadogDevName) {
        getZabbixAccount(datadogDevName);
    }

    /**
     * Zabbix接続情報取得
     *
     * @param datadogDevName Zabbixアカウント情報.カスタムメタデータレコード名
     */  
    private void getZabbixAccount(String datadogDevName) {
        // 案件情報の監視システムを元にZabbixアカウント情報を取得
        // ZabbixSetting__mdt mdt = [SELECT ID__c, password__c, EndPoint__c FROM ZabbixSetting__mdt WHERE DeveloperName = :datadogDevName];
        //2023.12.11 ChartEndPoint__c 追加
        ZabbixSetting__mdt mdt = [SELECT ID__c, password__c, EndPoint__c,ChartEndPoint__c, ZabbixVersion__c FROM ZabbixSetting__mdt WHERE DeveloperName = :datadogDevName];
        this.loginid = mdt.ID__c;
        this.password = mdt.password__c;
        this.endpoint = mdt.EndPoint__c;
        this.chartendpoint = mdt.ChartEndPoint__c; //2023.12.11 add
        this.zabbixVersion = mdt.ZabbixVersion__c; //2024.05.14 add

        // 動作確認用
        // Zabbix - スカイ３６５ 検証Zabbix(2.2)
        // this.endpoint = 'http://zabbix99.sky365.co.jp/zabbix/api_jsonrpc.php'; 
        // Zabbix - スカイ３６５ 検証Zabbix(3.0)
        // this.endpoint = 'http://3.112.219.175/zabbix/api_jsonrpc.php';
        // Zabbix - スカイ３６５ 検証Zabbix(4.0)
        // this.endpoint = 'http://54.178.246.32/zabbix/api_jsonrpc.php';
        // Zabbix - スカイ３６５ 検証Zabbix(5.0)
        // this.endpoint = 'http://52.197.81.205/zabbix/api_jsonrpc.php';
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
        request.setHeader('Content-Type', 'application/json-rpc');
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setBody(body);
        System.debug('★body★' + body);

        HttpResponse response = new Http().send(request);
        System.debug('★response★' + response);
        System.debug('★response.getBody★' + response.getBody());

        return response;
    }

    /**
     * 認証トークン取得
     *
     * @return HTTPレスポンス
     */
    public HttpResponse getToken() {

        Map<String, Object> paramMap = new Map<String, Object>{
            'user' => this.loginid,
            'password' => this.password
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'user.login',
            'params' => paramMap,
            'id' => 1
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }

    /**
     * HOSTグループIDをキーに対象AWSリソース情報一覧を取得
     *
     * @return HTTPレスポンス
     */
    public HttpResponse getHosts(String groupid, String token) {
        Map<String, Object> statusMap = new Map<String, Object>{
            'status' => '0'
        };
        
        Map<String, Object> paramMap = new Map<String, Object>{
            'groupids' => new List<String>{ groupid },
            'output' => 'extend',
            'filter'=> statusMap
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'host.get',
            'params' => paramMap,
            'id' => 1,
            'auth' => token
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }

    /**
     * HOSTグループIDをキーにメンテナンス一覧を取得
     *
     * @return HTTPレスポンス
     */
    public HttpResponse getMaintenances(String groupid, String token) {

        Map<String, Object> paramMap = new Map<String, Object>{
            'groupids' => new List<String>{ groupid },
            'output' => 'extend',
            'selectHosts' => 'extend',
            'selectTimeperiods' => 'extend'
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'maintenance.get',
            'params' => paramMap,
            'id' => 1,
            'auth' => token
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }

    /**
     * HOSTグループIDをキーにメンテナンス設定を登録する
     *
     * @return HTTPレスポンス
     */
    public HttpResponse createMaintenances(String name, List<String> hostids
        , Long active_since, Long active_till, String token) {

        Map<String, Object> timeperiodMap = new Map<String, Object>{
            // 'timeperiod_type' => 0, デフォルト0:1度限り
            'start_date' => active_since,
            'period' => active_till - active_since
        };

        Map<String, Object> paramMap = new Map<String, Object>{
            'name' => name,
            'hostids' => hostids,
            'active_since' => active_since,
            'active_till' => active_till,
            'timeperiods' => new List<Object>{ timeperiodMap }
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'maintenance.create',
            'params' => paramMap,
            'id' => 1,
            'auth' => token
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }

    /**
     * メンテナンスIDをキーにメンテナンス設定を更新する
     * 更新時もホストIDの指定が必要
     *
     * @return HTTPレスポンス
     */
    public HttpResponse updateMaintenances(String maintenanceid, String name
        , List<String> hostids, Long active_since, Long active_till, String token) {

        Map<String, Object> timeperiodMap = new Map<String, Object>{
            'start_date' => active_since,
            'period' => active_till - active_since
        };

        Map<String, Object> paramMap = new Map<String, Object>{
            'maintenanceid' => maintenanceid,
            'name' => name,
            'hostids' => hostids,
            'active_since' => active_since,
            'active_till' => active_till,
            'timeperiods' => new List<Object>{ timeperiodMap }
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'maintenance.update',
            'params' => paramMap,
            'id' => 1,
            'auth' => token
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }

    /**
     * メンテナンスIDをキーにメンテナンス設定を削除する
     *
     * @return HTTPレスポンス
     */
    public HttpResponse deleteMaintenances(List<String> maintenanceids, String token) {

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'maintenance.delete',
            'params' => maintenanceids,
            'id' => 1,
            'auth' => token
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }

    /**
     * ログアウト
     *
     * @return HTTPレスポンス
     */
    public HttpResponse logout(String token) {

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'user.logout',
            'params' => new List<String>(),
            'id' => '1',
            'auth' => token
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }
    /**
     * ホストIDに紐づくグラフIDを取得
     *
     * @return HTTPレスポンス
     */
    // public HttpResponse getGraphid(String hostids, String token) {
    public HttpResponse getGraphid(Set<String> hostids, String token) {

        Map<String, Object> paramMap = new Map<String, Object>{
            // 'hostids' => new List<String>{ hostids },
            'hostids' => new List<String>(hostids),
            'output' => 'extend',
            'selectHosts' => 'extend',
            'selectItems' => 'extend'
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'graph.get',
            'params' => paramMap,
            'id' => 1,
            'auth' => token
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }

    /**
     * グラフIDを指定してグラフ画像を取得
     * 
     * @param graphid String
     * @param token String
     * @return HTTPレスポンス
     */
    public HttpResponse getGraphImg(String graphid, String token,String active_since, String active_till) {

        String endp = chartendpoint + '?graphid=';
        endp += graphid + '&profileIdx=web.graphs.filter&from=' + EncodingUtil.urlEncode(active_since, 'UTF-8') + '&to=' + EncodingUtil.urlEncode(active_till, 'UTF-8');
        System.debug('***getGraphImg endp***' + endp);
        HttpResponse res = restApiHttpRequestBlob('POST', endp, token,null);
        System.debug('***res***' + res);
        return res;
    }

    /**
     * グラフIDを指定してグラフ画像を取得Zabbix22用
     * 
     * @param graphid String
     * @param token String
     * @return HTTPレスポンス
     */
    public HttpResponse getGraphImg2(String graphid, String token,String stimeStr, String period) {

        String endp = chartendpoint + '?graphid=';
        endp += graphid + '&profileIdx=web.graphs.filter&stime=' + EncodingUtil.urlEncode(stimeStr, 'UTF-8') + '&period=' + EncodingUtil.urlEncode(period, 'UTF-8');
        System.debug('***getGraphImg endp***' + endp);
        HttpResponse res = restApiHttpRequestBlob('POST', endp, token,null);
        System.debug('***res***' + res);
        return res;
    }

    /**
     * グラフIDを指定してグラフ画像を取得
     * 
     * @param graphid String
     * @param token String
     * @return HTTPレスポンス
     */
    public HttpResponse getGraphImgAtWeblogin(String graphid, String sessionvalue,String active_since, String active_till) {

        String endp = chartendpoint + '?graphid=';
        endp += graphid + '&profileIdx=web.graphs.filter&from=' + EncodingUtil.urlEncode(active_since, 'UTF-8') + '&to=' + EncodingUtil.urlEncode(active_till, 'UTF-8');
        System.debug('***getGraphImgAtWeblogin endp***' + endp);
        HttpResponse res = restApiHttpRequestBlob('POST', endp, sessionvalue,'zbx_session');
        System.debug('***res***' + res);
        return res;
    }
    /**
     * itemIdに紐づくログを取得
     *
     * @return HTTPレスポンス
     */
    public HttpResponse getHistory(Set<String> itemids, String token,Long active_since, Long active_till, Integer historyType) {

        Map<String, Object> paramMap = new Map<String, Object>{
            // 'hostids' => new List<String>{ hostids },
            'itemids' => new List<String>(itemids),
            'history' => historyType,
            'output' => 'extend',
            'sortfield' => 'clock',
            'sortorder' => 'DESC',
            'time_from' => active_since,
            'time_till' => active_till,
            'limit' => 1440
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'history.get',
            'params' => paramMap,
            'id' => 1,
            'auth' => token
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }


    // private HttpResponse restApiHttpRequestBlob(String method, String chartendpoint, String token) {//Zabbix60対応
    private HttpResponse restApiHttpRequestBlob(String method, String chartendpoint, String token,String cookiename) {
        System.debug('***endpoint★' + chartendpoint);

        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'image/png');
        request.setHeader('Content-Length', '0');
        //Zabbix60対応 Start
        if(String.isBlank(cookiename)){
            request.setHeader('Cookie', 'zbx_sessionid=' + token);
            system.debug('kik_50:' + cookiename);
        }else{
            request.setHeader('Cookie', cookiename + '=' + token);
            system.debug('kik_60:' + cookiename);
        }
        //Zabbix60対応 End
        request.setEndpoint(chartendpoint);
        request.setMethod(method);
    
        HttpResponse response = new Http().send(request);
        System.debug('***response★' + response);
        System.debug('***response.getBodyAsBlob★' + response.getBodyAsBlob());

        return response;
    }
        /**
     * 指定されたホストIDに関連するZabbixの現在発生中の障害情報を取得します。
     * @param hostids 取得する障害情報に関連するホストIDのカンマ区切りの文字列
     * @param token Zabbix APIのトークン
     * @return Zabbixの障害情報を含むHTTPレスポンス
     */
    public HttpResponse getProblem(Set<String> hostids, String token) {

        Map<String, Object> filterMap = new Map<String, Object>{   
            'value' => 1
        };

        Map<String, Object> paramMap = new Map<String, Object>{
            'output' => 'extend',
            'selectHosts' => 'extend',
            'selectRelatedObject' => new List<String>{ 'description' },
            'hostids' => new List<String>(hostids),
            'only_true' => 1,
            'filter' => filterMap
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method' => 'trigger.get',
            'params' => paramMap,
            'id' => 1,
            'auth' => token
        };

        String body = JSON.serialize(bodyMap);

        HttpResponse res = restApiHttpRequest('POST', endpoint, body);

        return res;
    }
    /**
     * Webログイン
     *
     * @return HTTPレスポンス
     */
    public HttpResponse weblogin() {
        System.debug('***weblogin***');
        String webloginurl = endPoint.replace('api_jsonrpc.php', 'index.php') ;
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        request.setEndpoint(webloginurl);
        request.setMethod('POST');
        String name = EncodingUtil.urlEncode(this.loginid, 'UTF-8');
        String password = EncodingUtil.urlEncode(this.password, 'UTF-8');
        String enter = EncodingUtil.urlEncode('サインイン', 'UTF-8');

        String requestBody = 'name=' + name + '&password=' + password+ '&autologin=1' + '&enter=' + enter;
        request.setBody(requestBody);

        Http http = new Http();
        return http.send(request);
    }
}