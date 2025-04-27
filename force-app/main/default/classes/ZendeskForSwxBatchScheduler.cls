/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2020 SKY365 Inc. All Rights Reserved.
 *
 * Zendesk連携バッチForSWXZendeskスケジューラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/08     kikuchi     新規作成
 ********************************************************************************/
public class ZendeskForSwxBatchScheduler implements Schedulable {

   /**
    * 実行
    *
    */
    public void execute(SchedulableContext ctx) {
        ZendeskForSwxBatch b = new ZendeskForSwxBatch();
        Database.executeBatch(b, 200);
    }    
}