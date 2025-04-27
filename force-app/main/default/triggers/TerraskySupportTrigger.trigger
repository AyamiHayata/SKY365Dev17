/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * サポート対応トリガー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/12     Kikuchi     新規作成
 ********************************************************************************/
trigger TerraskySupportTrigger on TerraskySupport__c (before insert, before update) {

    TerraskySupportTriggerHandler handler = new TerraskySupportTriggerHandler();

    if (Trigger.isInsert && Trigger.isBefore) {
        handler.beforeInsert(Trigger.new);
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.beforeUpdate(Trigger.new);
    }    
}