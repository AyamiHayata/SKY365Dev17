/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * 日報明細トリガーハンドラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/11     Kikuchi     新規作成
 ********************************************************************************/
public with sharing class DailyReportDetailTriggerHandler {
    /**
     * コンストラクタ
     */
    public DailyReportDetailTriggerHandler() {

    }

    /**
     * 作成時処理
     */
    public void afterInsert(List<DailyReportDetail__c> triggerNew) {
        dailyReportWorkTimeSummaryUpd(triggerNew);
    }

    /**
     * 更新時処理
     */
    public void afterUpdate(List<DailyReportDetail__c> triggerNew) {
        dailyReportWorkTimeSummaryUpd(triggerNew);
    }

    /**
     * 削除時処理
     */
    public void afterDelete(List<DailyReportDetail__c> triggerOld) {
        dailyReportWorkTimeSummaryUpd(triggerOld);
    }

    /**
     * サポート対象更新処理
     * @param targetList 日報明細リスト
     * 
     */
    private void dailyReportWorkTimeSummaryUpd(List<DailyReportDetail__c> targetList) {
        Set<Id> idSet = new Set<Id>();
        for (DailyReportDetail__c target : targetList) {
            if (target.TerraskySupport__c != null) {
                idSet.add((Id)target.TerraskySupport__c);
            }
        }
        if (idSet.size() > 0) {
            // 稼働集計を取得
            List<AggregateResult> resultList = [select TerraskySupport__c, SUM(WorkTime__c) WorkTime FROM DailyReportDetail__c where TerraskySupport__c IN :idSet Group by TerraskySupport__c];
            Map<Id, Decimal> workTimeMap = new Map<Id, Decimal>();
            for (AggregateResult result : resultList) {
                workTimeMap.put((Id)result.get('TerraskySupport__c'), (Decimal)result.get('WorkTime'));
            }
            // 更新するサポート対象を取得
            List<TerraskySupport__c> caseList = [SELECT Id, WorkTime__c FROM TerraskySupport__c WHERE Id IN:workTimeMap.keySet()];
            for (TerraskySupport__c supportCace : caseList) {
                supportCace.WorkTime__c = workTimeMap.get(supportCace.Id);
            }
            // 稼働集計をサポート対象に更新
            if (caseList.size() > 0) {
                update caseList;
            }
        }
    }
}