/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * サポート対応トリガーハンドラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/12     Kikuchi     新規作成
 * 2022/06     Kikuchi     ５日後対応フラグ更新、ソリューション区分更新追加
 ********************************************************************************/
public with sharing class TerraskySupportTriggerHandler {
    /**
     * コンストラクタ
     */
    public TerraskySupportTriggerHandler() {

    }

    /**
     * 作成時処理
     */
    public void beforeInsert(List<TerraskySupport__c> triggerNew) {
        holidayDeductionTimeUpd(triggerNew);
    }

    /**
     * 更新時処理
     */
    public void beforeUpdate(List<TerraskySupport__c> triggerNew) {
        holidayDeductionTimeUpd(triggerNew);
    }
    
    /**
     * 休日差引時間更新処理
     * @param targetList サポート対応リスト
     * 
     */
    private void holidayDeductionTimeUpd(List<TerraskySupport__c> targetList) {
        for (TerraskySupport__c target : targetList) {
            // 初回応答時間
            if (target.CaseCreateDate__c != null && target.FirstMailDate__c != null) {
                Integer count = CommonUtil.holidayCount(target.CaseCreateDate__c.date(), target.FirstMailDate__c.date());
                target.HolidayDeductionTime__c = count * 24;
            }
            // ５日後対応
            if (target.MailUpdateDate__c != null) {
                Integer daySpan = target.MailUpdateDate__c.date().daysBetween(system.today());
                Integer holcount = CommonUtil.holidayCount(target.MailUpdateDate__c.date(), system.today());
                target.Day5Flg__c = daySpan - holcount >= 5 ? true : false;
            }
            // ソリューション区分更新
            if (target.Solutionkbn__c == '未作成' || target.Solutionkbn__c == null) {
                if (target.SolutionCreateDate__c != null) {
                    target.Solutionkbn__C = '作成済';
                }
            }
            // クローズ済のケース
            if (target.Status__c == 'クローズ') {
                target.Day5Flg__c = false;
            }

        }    
    }
    
}