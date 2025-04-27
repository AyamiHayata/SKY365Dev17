/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * SalesforceとToggl連携のための認証フロー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/07     kikuchi     新規作成
 * 2024/07     kikuchi     Toggl api v8 廃止に伴う修正
 ********************************************************************************/
public with sharing class SalesforceToTogglController {
    public String loginid {get;set;}
    public String password {get;set;}
    public User user;
    public String code;

    public SalesforceToTogglController() {
        user = new user();
    }

     /**
     * コンストラクタ
     *
     */
    public void initAction() {
        // ユーザ取得
        user = [SELECT id, Username, Email FROM USER WHERE id =:UserInfo.getUserId()];
        loginid = user.Email;
    }

    /**
     * 登録処理
     * @return Pagereference
     *
     */
    public Pagereference regist() {
        HttpResponse res = new HttpResponse();
        res = RestApiHttpRequest();
        Map<String, Object> resultJSON = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
        //Map<String, Object> data = (Map<String, Object>) resultJSON.get('data');
        user.togglAPI_Token__c = (String)resultJSON.get('api_token');
        user.togglAPI_Workspace__c = String.valueOf(resultJSON.get('default_workspace_id'));
        update user;

        String initialsettingURL = '/apex/initialsetting';
        PageReference pageRef = new PageReference(initialsettingURL);
        return pageRef;
    }
     
    /**
     * HttpRequest(JSON)
     *
     * @param String エンドポイント
     * @return HTTPレスポンス
     */
    private HttpResponse RestApiHttpRequest() {
        Blob headerValue = Blob.valueOf(loginid + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        //request.setEndpoint('https://api.track.toggl.com/api/v8/me');
        request.setEndpoint('https://api.track.toggl.com/api/v9/me');
        request.setMethod('GET');

        Http http = new Http();
        return  http.send(request);
    }
}