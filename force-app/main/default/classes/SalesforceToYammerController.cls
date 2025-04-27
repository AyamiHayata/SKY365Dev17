/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * SalesforceとYammer連携のための認証フロー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/06     kikuchi     新規作成
 ********************************************************************************/
public with sharing class SalesforceToYammerController {
    /* 許可コード */
    public String code;

    /* 認証URL */    
    public Static String URL = 'https://www.yammer.com/oauth2/access_token.json?client_id=HnJKXRc1V2GDOTrzmyLHpg&client_secret=XbV6g9y8aQL1b2jPXQD7PwPAEK2M7YZuwu2ITmaj3k&code=';
 
    /**
     * コンストラクタ
     *
     */
    public SalesforceToYammerController() {
        code = ApexPages.CurrentPage().getParameters().get('code');
    }

    /**
     * 初期処理
     *
     */
    public void initAction() {
        HttpResponse res = new HttpResponse();
        res = RestApiHttpRequest(URL + code);
        
        Map<String, Object> resultJSON = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
        Map<String, Object> accessToken = (Map<String, Object>) resultJSON.get('access_token');
        String token = (String)accessToken.get('token');
        
        // トークンを更新
        User u = [SELECT id, YammerToken__c FROM USER WHERE id =:UserInfo.getUserId()];
        u.YammerToken__c = token;
        update u;
    }
    
    /**
     * 戻る
     *
     */
    public Pagereference back() {
        String initialsettingURL = '/apex/initialsetting';
        PageReference pageRef = new PageReference(initialsettingURL);
        return pageRef;
    }

    /**
     * HttpRequest(JSON)
     * @param String 送信パラメータ
     * @return レスポンス
     */
    private HttpResponse RestApiHttpRequest(String endPoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setMethod('GET');

        Http http = new Http();
        return  http.send(request);
    }    
}