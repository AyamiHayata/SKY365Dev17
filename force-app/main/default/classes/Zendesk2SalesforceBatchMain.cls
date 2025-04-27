/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Zendesk連携バッチベースクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/07     Kikuchi     新規作成
 ********************************************************************************/
public virtual class Zendesk2SalesforceBatchMain implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    /* Zendeskチケット */  
    public Map<String, Ticket> tickets;
    /* 種別（プロジェクト）マッピング */
    public Map<String, SObject> shubetsuMapping;
    /* 商流（クライアント）マッピング */
    public Map<String, SObject> shoryuMapping;
    /* 案件情報 */
    public Map<String, Id> constitutionCommon;
    
    /* endPoint */
    public String endPoint;
    /* loginid */
    public String loginid;
    /* password */
    public String password; 

    /**
     * コンストラクタ
     *
     */
    public Zendesk2SalesforceBatchMain() {
        tickets = new Map<String, Ticket>();
        shubetsuMapping = new Map<String, SObject>();
        shoryuMapping = new Map<String, SObject>();
        constitutionCommon = new Map<String, Id>();
    }

    /**
     * 初期処理
     * 
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {

        // 変換マッピング情報取得
        readMappingInfo();
        // Zendesk接続情報取得
        getZendeskAccount();
        // チケット取得
        getTickets(endPoint);
        // 案件情報取得
        readConstitutionCommon();

        // 紐付け対象の日報明細取得
        return Database.getQueryLocator(createQuery());
    }

    /**
     * チケットクラス
     *
     */
    public class Ticket {
        public String id;
        public String organization_id;
        public Set<String> tags;

        /**
         * コンストラクタ
         *
         */
        public Ticket() {
            id = '';
            organization_id = '';
            tags = new Set<String>();
        }
    }

    /**
     * 実行
     *
     */
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        execute2(BC, scope);
    }

    /**
     * 実行2
     *
     */    
    public virtual void execute2(Database.BatchableContext BC, List<sObject> scope) {
        // override
    }

    /**
     * 終了処理
     *
     */
    public void finish(Database.BatchableContext BC) {
    }

   /**
    * データ取得クエリ
    *
    * @return クエリ
    */
    private String createQuery() {
        // 日報明細から過去５日間のクライアントまたは、案件が未登録のデータを取得
        return 'SELECT ID, Tid__c, Client2__c, Code__c, Title__c, Project2__c, ConstitutionCommon__c, DailyReport__r.RegistDate__c FROM DailyReportDetail__c WHERE (Client2__c = null OR ConstitutionCommon__c = null) AND Code__c LIKE \'#%\' AND DailyReport__r.RegistDate__c = LAST_N_DAYS:5';
    }

    /**
     * HttpRequest2(JSON)
     *
     * @return HTTPレスポンス
     */
    public HttpResponse restApiHttpRequest(String lEndpoint) {
        Blob headerValue = Blob.valueOf(loginid + '/token:' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(lEndpoint);
        request.setMethod('GET');

        Http http = new Http();
        return  http.send(request);
    }

    /**
     * 変換マッピング情報取得
     *
     */    
    public virtual void readMappingInfo() {
        // override
    }

    /**
     * Zendesk接続情報取得
     *
     */  
    public virtual void getZendeskAccount() {
        // override
    }

    /**
     * Zendeskチケット取得
     * @param String endPoint
     *
     */  
    public virtual void getTickets(String endPoint) {
        // override
    } 

    /**
     * ListをMapにキャスト
     * @param List<SObject> カスタムメタリスト
     * @return カスタムメタマップ
     */    
    public virtual Map<String, SObject> castListToMap(List<SObject> mrtaList) {
        Map<String, SObject> restltMap = new Map<String, SObject>();
        for (SObject meta : mrtaList) {
            restltMap.put((String)meta.get('MasterLabel'), meta);
        }
        return restltMap;
    }

    /**
     * 案件情報取得
     *
     */        
    private void readConstitutionCommon() {
        constitutionCommon = castListToMap([SELECT Id, ZendeskOrganizationIdJoin__c FROM Constitution_Common__c WHERE TerminationFlag__c = false AND ZendeskOrganizationIdJoin__c != null]);
    }

    /**
     * ListをMapにキャスト
     * @param List<Constitution_Common__c> 案件リスト
     * @return マップ
     */    
    private Map<String, Id> castListToMap(List<Constitution_Common__c> objList) {
        Map<String, Id> restltMap = new Map<String, Id>();
        for (Constitution_Common__c element : objList) {
            List<String> organizationIdList = element.ZendeskOrganizationIdJoin__c.split(',');
            for (String organizationId : organizationIdList) {
                restltMap.put(organizationId, element.id);
            }
        }
        return restltMap;
    }

}