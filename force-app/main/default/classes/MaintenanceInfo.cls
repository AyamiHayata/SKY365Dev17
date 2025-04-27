/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * 静観情報投稿クラス
 * 【実行例】
 * MaintenanceInfo info = new MaintenanceInfo();
 * info.type = MaintenanceInfo.TYPE_NEW;
 * info.ankenName = 'ERP運用代行';
 * info.updateUser = 'テスト 太郎';
 * info.registName = 'Ver1.3 アップデート作業';
 * info.startDT = '2022/12/15 00:00';
 * info.endDT = '2022/12/15 06:00';
 * info.resourceNames = new List<String>{'server1','server2','server3'};
 * info.commentRegist(案件ID);
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/12     Kikuchi     新規作成
 ********************************************************************************/
public without sharing class MaintenanceInfo {

    public Static final String TYPE_NEW    = '登録';
    public Static final String TYPE_UPDATE = '変更';
    public Static final String TYPE_DELETE = '削除';

    public String type {set; get;}
    public String ankenName {set; get;}
    public String updateUser {set; get;}
    public String registName {set; get;}
    public String startDT {set; get;}

    public String endDT {set; get;}
    public List<String> resourceNames {get; set;}
    public String zabbixVersion {get; set;}
    public String ankenId {get; set;}
    public String maintenanceId {get; set;}

    public Static Final String  WEB_HOOK_URI = System.Label.PS_SLACK_WEBHOOK;
    
    /**
     * コンストラクタ
     *
     */
    public MaintenanceInfo() {
        type = '';
        ankenName = '';
        updateUser = '';
        registName = '';
        startDT = '';
        endDT = '';
        resourceNames = null;
        zabbixVersion = '';
        ankenId = '';
        maintenanceId = '';
     }

    /**
     * 登録する。
     * 
     * @param Id 案件情報ID
     *
     */
    public void commentRegist(Id ankenId) {
        System.debug('**==**== ankenId => ' + ankenId);
        Constitution_Common__c con = [SELECT id, MaintenanceComment__c, IsMaintenanceComment__c FROM Constitution_Common__c WHERE id =:ankenId];
        if (con != null) {
            String arg  = '<p><b>【'+ type +'】&nbsp;'+ Datetime.now().format('yyyy/MM/dd HH:mm', 'JST') +'</b> 静観設定がされました。</p>';
            arg += '<p>----------設定情報----------</p>';
            arg += '<p>案件名  ：<b>'+ ankenName +'</b></p>';
            arg += '<p>更新者  ：<b>'+ updateUser +'</b></p>';
            arg += '<p>設定名  ：<b>'+ registName +'</b></p>';
            arg += '<p>静観日時：<b>'+ startDT +' ～ '+ endDT +'</b></p>';
            arg += '<p>------対象AWSリソース-------</p>';
            for (String resourceName : resourceNames) {
                arg += '<p>・'+ resourceName +'</p>';
            }
            arg += '<p>===============================================</p>';
            arg += '<p>&nbsp;</p>';
            slackSendMessage(con.id);
            if(String.isBlank(con.MaintenanceComment__c))con.MaintenanceComment__c = arg;
            else con.MaintenanceComment__c = arg + con.MaintenanceComment__c;
            con.IsMaintenanceComment__c = true;
            update con;
        }
    }

    /**
     * 対応一覧更新
     *
     */
    public void dataUpd(Id ankenId) {
        OperationList__c ol = new OperationList__c();
        ol.maintenanceId__c         = maintenanceId + '_' + zabbixVersion;                       // ZabbixメンテナンスID
        ol.ProjectInformation__c    = ankenId;                                                   // 案件情報     
        ol.StartDate__c             = Datetime.parse(startDT).addHours(-9);                      // 開始日時
        ol.EndDate__c               = Datetime.parse(endDT).addHours(-9);                        // 終了日時
        ol.Host__c                  = aWSResourceList2String(resourceNames);                     // 対象ホスト
        ol.name                     = '静観対応(SkyCoodle)';                                      // 対応名
        ol.GroupWatcher__c          = '出来ない';                                                 // GroupWatcher 登録
        ol.Requester__c             = 'Skycoodleオーダーマネジメントから依頼 設定名：' + registName;// 依頼ソース
        ol.Wchecker__c              = System.Label.PS_GESTID;                                    // サイトゲストユーザID
        ol.Description_unmonitor__c = 'この静観は、終了日時を過ぎると自動で"終了済み"となります。';   // 備考
        ol.Alert__c                 = '全アラート';                                               // 対象アラート
        ol.CompletedFlag__c         = false;
        if (type == TYPE_DELETE) {
            ol.EndDate__c           = Datetime.now();
            ol.CompletedFlag__c     = true;
        }
        Schema.SObjectField f = OperationList__c.Fields.maintenanceId__c;
        Database.upsert(ol,f,false);
    }

    private String aWSResourceList2String(List<String> resources) {
        String result = '';
        for(String resource : resources) {
            result = result + resource + '\n';
        }
        return result;
    }

    /**
     * 静観時刻が終了したものは、終了済みへ更新
     *
     */
    public void dataDel() {
        List<OperationList__c> opeList = [SELECT ID, CompletedFlag__c FROM OperationList__c WHERE maintenanceId__c != null AND CompletedFlag__c = false AND EndDate__c <=: DateTime.now()];
        for (OperationList__c ope : opeList) {
            ope.CompletedFlag__c = true;
        }
        update opeList;
    }

    /**
     * Slackにメッセージを送信する
     *
     */
    private void slackSendMessage(String id) {
        HttpResponse res = new HttpResponse();
        res = RestApiHttpRequest('{"username":"オーダーマネジメントシステム","icon_emoji":":skyc:","text": "```' + createSendMessage(id) + '```"}', WEB_HOOK_URI);
    }
    

    /**
     * Slack送信用メッセージを生成する
     * @return String
     */
     public String createSendMessage(String id) {
        String arg  = '【'+ type +'】 '+ Datetime.now().format('yyyy/MM/dd HH:mm', 'JST') +' 静観設定がされました。\\n';
        arg += '----------設定情報----------\\n';
        arg += '案件名  ：'+ ankenName +'\\n';
        arg += '更新者  ：'+ updateUser +'\\n';
        arg += '設定名  ：'+ registName +'\\n';
        arg += '静観日時：'+ startDT +' ～ '+ endDT +'\\n';
        arg += '------対象AWSリソース-------\\n';
        for (String resourceName : resourceNames) {
            arg += '・'+ resourceName +'\\n';
        }
        arg += '------Salesforce案件情報-------\\n';
        arg += URL.getOrgDomainUrl().toExternalForm() + '/' + id;
        arg = arg.replace('\r\n', '\\n');
        return arg.replace('"', '\\"');
    }    

    /**
     * HttpRequest(JSON)
     * @param String 送信パラメータ
     */
    private HttpResponse RestApiHttpRequest(String prams, String endPoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setBody(prams);

        Http http = new Http();
        return  http.send(request);
    }
    /**
     * null2Val
     */
    private String null2Val (String arg) {
        return String.isEmpty(arg) ? '' : arg;
    }    
}