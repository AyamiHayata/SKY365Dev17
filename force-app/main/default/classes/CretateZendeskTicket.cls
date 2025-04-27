/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * Zendeskにチケットを作成
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/03     kikuchi     新規作成
 ********************************************************************************/
public without sharing class CretateZendeskTicket implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    /* Zendesk UserID */
    public String userId {get;set;}
    
    /* Zendesk Token */
    public String token {get;set;}

    /* 連絡先情報ID */
    public String notifyId {get;set;}

    /* Zendesk URI */ 
    public static final String ZENDESK_API_BASE_URI = System.Label.PS_ZENDESK_URL;

    /* Zendesk REQUESTER */ 
    public static final String ZENDESK_REQUESTER = System.Label.PS_REQUESTER;


    /**
     * コンストラクタ
     *
     */
    public CretateZendeskTicket(String nid) {
        this.notifyId = nid;
        ZendeskAccount__mdt mdt = [SELECT loginid__c, password__c FROM ZendeskAccount__mdt WHERE DeveloperName = 'Zendesk_Portal'];
        this.userId = mdt.loginid__c;
        this.token = mdt.password__c;
    }
    /**
     * start
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String soql = 'SELECT ID,IsError__c FROM NotifyInfo__c WHERE ID = :notifyId';
        return Database.getQueryLocator(soql);
    }

    /**
     * execute
     */
    public void execute(Database.BatchableContext bc, List<NotifyInfo__c> notifyinfos) {
        if(notifyinfos.get(0).IsError__c){
            createMessage(notifyId);
        }
    }
    /**
     * finish
     */
    public void finish(Database.BatchableContext bc) {
        
    }
    /**
     * メイン処理
     *
     *  @param String notifyInfoId
     * 例: a2V1m000000Byd8EAC
     */
    public HttpResponse createMessage(String notifyInfoId) {
        HttpResponse res = null;
        Blob headerValue = Blob.valueOf(userId + '/token:' + token);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        String json = createJsonMessage(notifyInfoId);
        res = new HttpResponse();
        res = RestApiHttpRequest(json, ZENDESK_API_BASE_URI + '/api/v2/tickets.json', authorizationHeader);
        return res;
        
    }

    /**
     * Zendesk処理中断チケット起票
     *
     * @param String notifyInfoId
     */    
    private String createJsonMessage(String notifyInfoId) {
        String subject = 'SkyCoodleオーダーマネジメントAPI処理中断';
        String body = '連絡先変更自動処理において処理が中断しています。\\n';
               body += 'エラー内容を確認し復旧をお願いします。\\n\\n';
               body += '発生日時：' + DAteTime.now().addHours(9) + '\\n';
               body += URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/NotifyInfo__c/' + notifyInfoId + '/view';

        return '{"ticket": {"comment": {"body": "'+ body +'"},"priority": "urgent","subject": "'+ subject +'","requester": {"email": "'+ ZENDESK_REQUESTER +'"}}}';

    }

    /**
     * HttpRequest(JSON)
     * @param String 送信パラメータ
     */
    private HttpResponse RestApiHttpRequest(String prams, String endPoint, String authorizationHeader) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setBody(prams);

        Http http = new Http();
        return  http.send(request);
    } 

}