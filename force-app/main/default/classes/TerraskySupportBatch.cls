/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Terraskyサポートケース日報紐付けバッチ
 * 【実行例】
 *      TerraskySupportBatch batch = new TerraskySupportBatch();
 *      Database.executeBatch(batch,200);
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/10     Kikuchi     新規作成
 ********************************************************************************/
public with sharing class TerraskySupportBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    /* Case */  
    public Map<String, TerraskySupport__c> cases;

    /**
     * コンストラクタ
     *
     */
    public TerraskySupportBatch() {
        cases = new Map<String, TerraskySupport__c>();
    }

    /**
     * 初期処理
     * 
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // TerraskySupportCase取得
        getSupportCase();

        // 紐付け対象の日報明細取得
        return Database.getQueryLocator(createQuery());        
    }

    /**
     * 実行
     *
     */
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        for(sObject target : scope) {
            DailyReportDetail__c dailyReportDetail = (DailyReportDetail__c)target;  
            TerraskySupport__c targetCase = null;
            if (cases.containsKey(dailyReportDetail.Code__c)) {
                targetCase = cases.get(dailyReportDetail.Code__c);
                dailyReportDetail.TerraskySupport__c = targetCase.Id;
            }
        }
        update scope;
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
        // 日報明細からクライアントが(mitoco,dsc,omline,sve,sfdc)かつ、サポート対応が未登録のデータを取得
        return 'SELECT ID, Tid__c, Client2__c, Code__c, Title__c, Project2__c, TerraskySupport__c, DailyReport__r.RegistDate__c FROM DailyReportDetail__c WHERE TerraskySupport__c = null AND Client2__c IN (\'サービスデスク-SVE\', \'サービスデスク-SFDC\', \'サービスデスク-mitoco\', \'サービスデスク-OMLINE\', \'サービスデスク-DCS\',\'サービスデスク-GOM\') AND Code__c != null';
    }

    /**
     * TerraskySupportCase取得
     *
     */  
    public virtual void getSupportCase() {
        // override
        List<TerraskySupport__c> resluts = [SELECT Id, CaseNo__c FROM TerraskySupport__c];
        for (TerraskySupport__c element : resluts) {
            cases.put(element.CaseNo__c, element);
        }
    }     
}