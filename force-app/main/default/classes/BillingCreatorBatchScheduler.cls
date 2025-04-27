/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 請求作成バッチスケジューラ
 * 毎月1日の1時に実行
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/24          T.Matsuda        New
 ********************************************************************************/
global class BillingCreatorBatchScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
       Database.executebatch(new BillingCreatorBatch(), 100);
    }
 }