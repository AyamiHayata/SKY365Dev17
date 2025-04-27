/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * 日報明細トリガー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/11     Kikuchi     新規作成
 ********************************************************************************/
trigger DailyReportDetailTrigger on DailyReportDetail__c (after insert, after update, after delete) {
    
    DailyReportDetailTriggerHandler handler = new DailyReportDetailTriggerHandler();
    
    if (Trigger.isInsert && Trigger.isAfter) {
        handler.afterInsert(Trigger.new);
    }
    
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.afterUpdate(Trigger.new);
    }
    
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.afterDelete(Trigger.old);
    }

}