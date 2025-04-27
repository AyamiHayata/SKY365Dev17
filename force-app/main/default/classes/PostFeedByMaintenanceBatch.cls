/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * 静観情報フィード投稿クラスバッチ
 * 【実行例】
 * PostFeedByMaintenanceBatch batch = new PostFeedByMaintenanceBatch();
 * Database.executeBatch(batch,1);
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/12     Kikuchi     新規作成
 ********************************************************************************/
public without sharing class PostFeedByMaintenanceBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    /**
     * コンストラクタ
     *
     */
    public PostFeedByMaintenanceBatch() {

    }

    /**
     * 初期処理
     * 
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // 案件情報を取得
        return Database.getQueryLocator(createQuery()); 
    }

    /**
     * 実行
     *
     */
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        system.debug('scopeSize:' + scope.size());    
        List<FeedItem> feedItems = new List<FeedItem>();
        for (sObject target : scope) {
            Constitution_Common__c constitutionCommon = (Constitution_Common__c)target;
            FeedItem item = new FeedItem();
            item.IsRichText = true;
            item.Body = constitutionCommon.MaintenanceComment__c;
            item.ParentId =  constitutionCommon.id;
            feedItems.add(item);

            constitutionCommon.MaintenanceComment__c = '';
            constitutionCommon.IsMaintenanceComment__c = false;
        }
        insert feedItems;
        update scope;
    }

    /**
     * 終了処理
     *
     */
    public void finish(Database.BatchableContext BC) {
        MaintenanceInfo t = new MaintenanceInfo();
        t.dataDel();
    }
    
   /**
    * データ取得クエリ
    *
    * @return クエリ
    */
    private String createQuery() {
        // 案件情報からフィードコメント待ちのレコードを取得
        return 'SELECT ID, MaintenanceComment__c, IsMaintenanceComment__c FROM Constitution_Common__c WHERE IsMaintenanceComment__c = true';
    }
}