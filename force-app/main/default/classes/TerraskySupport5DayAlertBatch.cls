/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * Terraskyサポートケース５日アラート対象更新バッチ
 * 【実行例】
 *      TerraskySupport5DayAlertBatch batch = new TerraskySupport5DayAlertBatch();
 *      Database.executeBatch(batch,200);
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/06     Kikuchi     新規作成
 ********************************************************************************/
public with sharing class TerraskySupport5DayAlertBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    /**
     * コンストラクタ
     *
     */
    public TerraskySupport5DayAlertBatch() {

    }

    /**
     * 初期処理
     * 
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // ユーザ確認中のサポートケースを取得
        return Database.getQueryLocator(createQuery());     
    }

    /**
     * 実行
     *
     */
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        // トリガーを発火させるため、カラ更新
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
        // サポートケースから状況が"ユーザ確認中"のケースを取得
        return 'SELECT ID FROM TerraskySupport__c WHERE Status__c = \'ユーザ確認中\' AND Day5Flg__c = false';
    }     
}