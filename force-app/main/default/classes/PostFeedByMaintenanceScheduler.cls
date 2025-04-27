/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * 静観情報フィード投稿クラススケジューラー
 * 【実行例】
 * 10分間隔で実行
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/12     Kikuchi     新規作成
 ********************************************************************************/
public with sharing class PostFeedByMaintenanceScheduler implements Schedulable {

    /**
     * コンストラクタ
     *
     */
    public PostFeedByMaintenanceScheduler() {
    }

	public void execute(SchedulableContext ctx) {
        PostFeedByMaintenanceBatch batch = new PostFeedByMaintenanceBatch();
        Database.executeBatch(batch, 1);
    }    
}