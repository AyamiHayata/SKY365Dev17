/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2020 SKY365 Inc. All Rights Reserved.
 *
 * Terraskyサポートケース日報紐付けバッチスケジューラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/11     kikuchi     新規作成
 ********************************************************************************/
public class TerraskySupportBatchScheduler implements Schedulable {
   /**
    * 実行
    *
    */
    public void execute(SchedulableContext ctx) {
        TerraskySupportBatch b = new TerraskySupportBatch();
        Database.executeBatch(b, 200);
    }  
}