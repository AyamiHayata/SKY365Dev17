/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * Office365連携APIリクエスト
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/08     Miura     新規作成
 ********************************************************************************/
public class OfficeAPIRequester {


    // クライアントID
    public String clientId;
    // クライアントシークレット
    public String clientSecret;
    // テナントID
    public String tenantId;

    // メールアドレス
    private String paramMail;
    // メールアドレス（旧）
    private String paramMailBefor;
    // 配布グループ
    private String paramGroup;
    // 名
    private String paramName;
    // 処理タイプ
    private String paramType;

    // アクセストークン
    private String accessToken;
    // トークンタイプ
    private String tokenType;
    // HTTPステータスコード
    private Integer HTTP_STATUS_CODE_200 = 200;
    
    private String contactId;

    private Integer haihuListOnCount = 0;     //2023.06.15 add
    private boolean contactExistFlg = false;     //2023.06.15 add
    
    // （トークン取得用）スコープ
    private static String TOKEN_SCOPE = 'https%3A%2F%2Fgraph.microsoft.com%2F.default';
    private static String TOKEN_GRANT_TYPE = 'client_credentials';

    // API連携URL
    // private static String URL_NEW = 'http://35.76.212.2/o365-tools/sandbox/new_mail_contact.php';    // 連絡先：新規登録
    private static String URL_NEW = System.Label.PS_OFFICEAPI_URI + '/new_mail_contact.php';    // 連絡先：新規登録
    // private static String URL_EDIT = 'http://35.76.212.2/o365-tools/sandbox/update_mail_contact.php';    // 連絡先：変更
    private static String URL_EDIT = System.Label.PS_OFFICEAPI_URI + '/update_mail_contact.php';    // 連絡先：変更
    // private static String URL_DEL = 'http://35.76.212.2/o365-tools/sandbox/delete_mail_contact.php';    // 連絡先：削除
    private static String URL_DEL = System.Label.PS_OFFICEAPI_URI + '/delete_mail_contact.php';    // 連絡先：削除
    // private static String URL_ML_ADD = 'http://35.76.212.2/o365-tools/sandbox/add_ml_member.php';    //  メーリングリスト：追加
    private static String URL_ML_ADD = System.Label.PS_OFFICEAPI_URI + '/add_ml_member.php';    //  メーリングリスト：追加
    // private static String URL_ML_DEL = 'http://35.76.212.2/o365-tools/sandbox/del_ml_member.php';    //  メーリングリスト：削除
    private static String URL_ML_DEL = System.Label.PS_OFFICEAPI_URI + '/del_ml_member.php';    //  メーリングリスト：削除
    // private static String URL_GP_DEL = 'http://35.76.212.2/o365-tools/sandbox/del_ml.php';    //  配布グループ：削除
    private static String URL_GP_DEL = System.Label.PS_OFFICEAPI_URI + '/del_ml.php';    //  配布グループ：削除
    private static String AUTH_ID = System.Label.PS_OFFICEAPI_AUTH_ID;          // OfficeAPI Basic認証ID
    private static String AUTH_PASS = System.Label.PS_OFFICEAPI_AUTH_PASS;      // OfficeAPI Basic認証パスワード
    
    // APIパラメータ値
    private static String API_PARAM_VERSION = '1.0.0';
    private static String API_PARAM_COPYRIGHT = 'Sky365.Co,.Ltd';
    private static String API_PARAM_DATE = String.valueOfGmt(Datetime.now());
    // 実行モード
    // 　DryRun：実際に更新は実施されないが、一連の処理の流れを処理した想定の結果を返却
    // 　Prod：実際に更新処理が実施される
    private static String API_PARAM_MODE = 'Prod';

    public class Certification {
        public String Domain;
    }

    // 新規連絡先追加 パラメータ
    public class newParameters {
        public String DisplayName;
        public String FirstName;
        public String LastName;
        public String MailAddress;
        public String Mode = API_PARAM_MODE;
    }

    // 連絡先変更 パラメータ
    public class editParameters {
        public String Identity;
        public String DisplayName;
        public String FirstName;
        public String LastName;
        public String MailAddress;
        public String Mode = API_PARAM_MODE;
    }

    // 連絡先削除 パラメータ
    public class delParameters {
        public String Identity;
        public String Mode = API_PARAM_MODE;
    }

    // メーリングリスト パラメータ
    public class MLParameters {
        public String Identity;
        public List<String> MemberEmailList;
        public String Mode = API_PARAM_MODE;
    }

    // 新規連絡先追加API
    public class newContactApi {
        public String Version = API_PARAM_VERSION;
        public String Copyright = API_PARAM_COPYRIGHT;
        public String RequestDate = API_PARAM_DATE;
        public String RequestMode = 'Insert';
        Certification Certification = new Certification();
        newParameters Parameters = new newParameters();
    }

    // 連絡先の変更API
    public class editContactApi {
        public String Version = API_PARAM_VERSION;
        public String Copyright = API_PARAM_COPYRIGHT;
        public String RequestDate = API_PARAM_DATE;
        public String RequestMode = 'Update';
        Certification Certification = new Certification();
        editParameters Parameters = new editParameters();
    }

    // 連絡先の削除API
    public class removeApi {
        public String Version = API_PARAM_VERSION;
        public String Copyright = API_PARAM_COPYRIGHT;
        public String RequestDate = API_PARAM_DATE;
        public String RequestMode = 'ML_Del';
        Certification Certification = new Certification();
        delParameters Parameters = new delParameters();
    }

    // メーリングリストへのメンバー追加／削除API
    public class groupMemberApi {
        public String Version = API_PARAM_VERSION;
        public String Copyright = API_PARAM_COPYRIGHT;
        public String RequestDate = String.valueOfGmt(Datetime.now());
        public String RequestMode = 'ML_Del';
        Certification Certification = new Certification();
        MLParameters Parameters = new MLParameters();
    }

    /**
     * コンストラクタ
     *
     */
    public OfficeAPIRequester(String sMail, String sMailBefor, String sGroup, String sName, String sType) {

        paramMail = sMail;
        paramMailBefor = sMailbefor;
        paramGroup = sGroup;
        paramName = sName;
        paramType = sType;

        // Office365接続情報取得
        getOfficeAccount();
    }

    /**
     * Office365接続情報取得
     *
     */  
    public void getOfficeAccount() {
        String domain = paramGroup.substringAfter('@');
        if (String.isNotBlank(domain)) {
            List<Microsoft365Account__mdt> mdt = [SELECT DeveloperName, clientId__c, clientSecret__c, tenantId__c FROM Microsoft365Account__mdt WHERE Label = :domain];
            if (mdt.size() == 1) {
                this.clientId = mdt[0].clientId__c;
                this.clientSecret = mdt[0].clientSecret__c;
                this.tenantId = mdt[0].tenantId__c;
            }
        }
    }

    /**
     * 連絡先の検索
     *
     * @param  処理種別（contacts：連絡先の検索、groups：配布グループの検索）
     * @return 連絡先Id
     */
    public HttpResponse searchData(String pType, String groupAddress) {

        String resId = null;
        HttpResponse res = new HttpResponse();

        if (!String.isBlank(this.accessToken) && !String.isBlank(this.tokenType) ) {
            // Microsoft Graph取得
            res = restMicrosoftGraph(this.accessToken, pType, groupAddress);
        }

        return res;
    }
    
    /**
     * トークン取得
     *  HttpRequest(JSON)
     */
    public HTTPResponse requestToken() {

        String url = 'https://login.microsoftonline.com/' + this.tenantId + '/oauth2/v2.0/token';
        String requestBody = 'client_id=' + this.clientId +
                      '&scope=' + TOKEN_SCOPE +
                      '&client_secret=' + this.clientSecret +
                      '&grant_type=' + TOKEN_GRANT_TYPE;

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/x-www-form-urlencoded');
        request.setHeader('Host', 'login.microsoftonline.com');
        request.setEndPoint(url);
        request.setBody(requestBody);

        HTTPResponse response = new Http().send(request);

        if (response.getStatusCode() == HTTP_STATUS_CODE_200) {
            Map<String, Object> resTokenMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if(!resTokenMap.isEmpty()){
                this.accessToken = (String) resTokenMap.get('access_token');
                this.tokenType = (String) resTokenMap.get('token_type');
            }
        }
        return response;
    }

    /**
     * Microsoft Graph取得
     * 2023.06.26 処理種別　updateContacts　を追加
     * 
     * @param  アクセストークン
     * @param  処理種別（contacts：連絡先の検索、groups：配布グループの検索、updateContacts:変更後の連絡先の検索）
     * @param  配布リストのアドレス
     */
    public HTTPResponse restMicrosoftGraph(String sToken, String sType, String groupAddress) {
        
        // String sAddress = (sType == 'contacts') ? paramMailBefor : groupAddress; //2023.06.26 comment out
        //2023.06.26 add start
        String sAddress = null; 
        if(sType == 'contacts'){
            sAddress = paramMailBefor;
        }else if(sType == 'updateContacts'){
            sAddress = paramMail;
            sType = 'contacts';
        }else{
            sAddress = groupAddress;
        }
        //2023.06.26 add end
        // String url = 'https://graph.microsoft.com/v1.0/' + sType + '?$filter=startswith(mail,\'' + EncodingUtil.urlEncode(sAddress, 'UTF-8') + '\')';
        String url = 'https://graph.microsoft.com/v1.0/' + sType + '?$filter=mail%20eq%20\'' + EncodingUtil.urlEncode(sAddress, 'UTF-8') + '\'';
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + sToken);
        request.setHeader('Accept', 'application/json');
        request.setEndpoint(url);

        HTTPResponse response = new Http().send(request);

        return response;
    }

    /**
     * 連絡先の追加
     *
     * @return HTTPレスポンス
     */
    public HttpResponse newContact() {
        
        System.debug('[DEBUG]連絡先の追加 処理開始');

        HTTPResponse response = null;  //2023.06.21 add
        if(!contactExistFlg){  //2023.06.21 add
            newContactApi createApi = new newContactApi();
            createApi.Parameters.DisplayName = paramMailBefor;
            String[] splitName = paramName.replaceAll('　', ' ').split(' ');
            createApi.Parameters.LastName = splitName[0];
            if(splitName.size() >= 2){
                createApi.Parameters.FirstName = splitName[1];
            }
            createApi.Parameters.MailAddress = paramMailBefor;
            // createApi.Certification.Domain = paramMailBefor.substringAfter('@');
            createApi.Certification.Domain = paramGroup.substringAfter('@');

            JSONGenerator g = JSON.createGenerator(false);
            g.writeObject(createApi);

            // WEBAPI連携
            // HTTPResponse response = sendWebApi(g.getAsString(), URL_NEW);
            response = sendWebApi(g.getAsString(), URL_NEW);
            
            contactExistFlg = true;

            System.debug('[DEBUG]response：' + response); 
            System.debug('[DEBUG]getBody()：' + response.getBody());       
            System.debug('[DEBUG]連絡先の追加 処理終了');
        }
        
        return response;
    }

    /**
     * 連絡先の追加（Salesforceの連絡先変更でOfficeに連絡先を追加する必要がでてきた場合）
     * ・配布リストがすべてOFFの状態からONになった場合等、Officeに連絡先がない場合
     *  2023.06.22 add 
     * @return HTTPレスポンス
     */
    public HttpResponse newContactForUpdate() {
        
        System.debug('[DEBUG]連絡先の追加 処理開始');

        HTTPResponse response = null;  
        if(!contactExistFlg){
            newContactApi createApi = new newContactApi();
            createApi.Parameters.DisplayName = paramMail;  //newContactと違う部分
            String[] splitName = paramName.replaceAll('　', ' ').split(' ');
            createApi.Parameters.LastName = splitName[0];
            if(splitName.size() >= 2){
                createApi.Parameters.FirstName = splitName[1];
            }
            createApi.Parameters.MailAddress = paramMail;  //newContactと違う部分
            createApi.Certification.Domain = paramGroup.substringAfter('@');

            JSONGenerator g = JSON.createGenerator(false);
            g.writeObject(createApi);

            // WEBAPI連携
            response = sendWebApi(g.getAsString(), URL_NEW);
            
            contactExistFlg = true;

            System.debug('[DEBUG]response：' + response); 
            System.debug('[DEBUG]getBody()：' + response.getBody());       
            System.debug('[DEBUG]連絡先の追加 処理終了');
        }
        
        return response;
    }


    /**
     * 連絡先の変更
     *
     * @return HTTPレスポンス
     */
    public HttpResponse setMailContact() {
    
        System.debug('[DEBUG]連絡先の変更 処理開始');

        editContactApi createApi = new editContactApi();
        createApi.Parameters.Identity = paramMailbefor;
        createApi.Parameters.DisplayName = paramMail;
        String[] splitName = paramName.replaceAll('　', ' ').split(' ');
        createApi.Parameters.LastName = splitName[0];
        if(splitName.size() >= 2){
            createApi.Parameters.FirstName = splitName[1];
        }
        createApi.Parameters.MailAddress = paramMail;
        // createApi.Certification.Domain = paramMail.substringAfter('@');
        createApi.Certification.Domain = paramGroup.substringAfter('@');

        JSONGenerator g = JSON.createGenerator(false);
        g.writeObject(createApi);

        // WEBAPI連携
        HTTPResponse response = sendWebApi(g.getAsString(), URL_EDIT);

        System.debug('[DEBUG]response：' + response); 
        System.debug('[DEBUG]getBody()：' + response.getBody());       
        System.debug('[DEBUG]連絡先の変更 処理終了');

        return response;
    }

    /**
     * 連絡先の削除
     *
     * @return HTTPレスポンス
     */
    public HttpResponse removeContact() {
    
        System.debug('[DEBUG]連絡先の削除 処理開始');
    
        removeApi createApi = new removeApi();
        createApi.Parameters.Identity = paramMailBefor;
        // createApi.Certification.Domain = paramMailBefor.substringAfter('@');
        createApi.Certification.Domain = paramGroup.substringAfter('@');
        
        JSONGenerator g = JSON.createGenerator(false);
        g.writeObject(createApi);

        // WEBAPI連携
        HTTPResponse response = sendWebApi(g.getAsString(), URL_DEL);
        
        System.debug('[DEBUG]response：' + response); 
        System.debug('[DEBUG]getBody()：' + response.getBody());       
        System.debug('[DEBUG]連絡先の削除 処理終了');

        return response;
    }

    /**
     * メーリングリストへのメンバー追加
     *
     * @return HTTPレスポンス
     */
    public HttpResponse addGroupMember(String groupAddress, String mail) {
    
        System.debug('[DEBUG]メーリングリストへのメンバー追加 処理開始');
    
        groupMemberApi createApi = new groupMemberApi();
        createApi.RequestMode= 'Insert';
        // createApi.Parameters.Identity = paramGroup;
        createApi.Parameters.Identity = groupAddress;
        List<String> ml = new List<String>();
        // ml.add(paramMailBefor);
        ml.add(mail);
        createApi.Parameters.MemberEmailList = ml;
        // createApi.Certification.Domain = paramMailBefor.substringAfter('@');
        createApi.Certification.Domain = paramGroup.substringAfter('@');
        
        JSONGenerator g = JSON.createGenerator(false);
        g.writeObject(createApi);

        // WEBAPI連携
        HTTPResponse response = sendWebApi(g.getAsString(), URL_ML_ADD);

        System.debug('[DEBUG]response：' + response); 
        System.debug('[DEBUG]getBody()：' + response.getBody());       
        System.debug('[DEBUG]メーリングリストへのメンバー追加 処理終了');

        return response;
    }

    /**
     * メーリングリストへのメンバー削除
     *
     * @return HTTPレスポンス
     */
    public HttpResponse removeGroupMember(String groupAddress, String mail) {
    
        System.debug('[DEBUG]メーリングリストへのメンバー削除 処理開始');
    
        groupMemberApi createApi = new groupMemberApi();
        createApi.RequestMode= 'Insert';
        // createApi.Parameters.Identity = paramGroup;
        createApi.Parameters.Identity = groupAddress;
        List<String> ml = new List<String>();
        // ml.add(paramMailBefor);
        ml.add(mail);
        createApi.Parameters.MemberEmailList = ml;
        // createApi.Certification.Domain = paramMailBefor.substringAfter('@');
        createApi.Certification.Domain = paramGroup.substringAfter('@');

        JSONGenerator g = JSON.createGenerator(false);
        g.writeObject(createApi);

        // WEBAPI連携
        HTTPResponse response = sendWebApi(g.getAsString(), URL_ML_DEL);
        
        System.debug('[DEBUG]response：' + response); 
        System.debug('[DEBUG]getBody()：' + response.getBody());       
        System.debug('[DEBUG]メーリングリストへのメンバー削除 処理終了');

        return response;
    }

    /**
     * 配布グループの削除
     *
     * @return HTTPレスポンス
     */
    public HttpResponse removeGroup() {
    
        System.debug('[DEBUG]配布グループの削除 処理開始');
    
        removeApi createApi = new removeApi();
        createApi.RequestMode= 'ML_Del';
        createApi.Parameters.Identity = paramMailBefor;
        // createApi.Certification.Domain = paramMailBefor.substringAfter('@');
        createApi.Certification.Domain = paramGroup.substringAfter('@');

        JSONGenerator g = JSON.createGenerator(false);
        g.writeObject(createApi);

        // WEBAPI連携
        HTTPResponse response = sendWebApi(g.getAsString(), URL_GP_DEL);

        System.debug('[DEBUG]response：' + response); 
        System.debug('[DEBUG]getBody()：' + response.getBody());       
        System.debug('[DEBUG]配布グループの削除 処理終了');

        return response;
    }

    /**
     * WEBAPI連携
     *
     * @param sJson JSON文字列
     * @param sUrl API
     * @return response
     *
     *  ※requestbodyに[crypto=false]を付与するとJSON平文での処理となる
     *
     */
    public HttpResponse sendWebApi(String sJson, String sUrl) {
System.debug('★sJson★' + sJson);
    
        // Caesar文字列
        Caesar c = new Caesar();
        String sData = c.encrypt(sJson, 3);
        
        String requestBody = 'data=' + EncodingUtil.urlEncode(sData, 'UTF-8');

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(sUrl);
        request.setHeader('Authorization', getBasicAuthorization());
        request.setHeader('content-type','application/x-www-form-urlencoded');
        request.setBody(requestBody);
        request.setTimeout(120000);

        HTTPResponse response = new Http().send(request);
        return response;
    }

    // public void countupHaifuListOnCount(){
    //     this.haihuListOnCount ++;
    // }
    // public Integer getHaifuListCount(){
    //     return this.haihuListOnCount;
    // }
    // public void setContactExistFlg(){
    //     this.contactExistFlg = true;
    // }
    // public boolean getContactExistFlg(){
    //     return this.contactExistFlg;
    // }
    private String getBasicAuthorization() {
        Blob headerValue = Blob.valueOf(AUTH_ID + ':' + AUTH_PASS);
        return 'BASIC ' + EncodingUtil.base64Encode(headerValue);
    } 
}