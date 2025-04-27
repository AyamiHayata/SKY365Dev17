/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * Terraskyサポートケース５日アラート対象更新バッチスケジューラー
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/06     Kikuchi     新規作成
 ********************************************************************************/
public with sharing class TerraskySupport5DayAlertBatchScheduler implements Schedulable {
   /**
    * 実行
    *
    */
    public void execute(SchedulableContext ctx) {
        TerraskySupport5DayAlertBatch b = new TerraskySupport5DayAlertBatch();
        Database.executeBatch(b, 200);
    }  
}