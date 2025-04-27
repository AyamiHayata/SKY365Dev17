/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2020 SKY365 Inc. All Rights Reserved.
 *
 * Zendesk連携バッチForSKYZendeskスケジューラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/08     kikuchi     新規作成
 ********************************************************************************/
public class ZendeskForSkyBatchScheduler implements Schedulable {

   /**
    * 実行
    *
    */
    public void execute(SchedulableContext ctx) {
        ZendeskForSkyBatch b = new ZendeskForSkyBatch();
        Database.executeBatch(b, 200);
    }    
}