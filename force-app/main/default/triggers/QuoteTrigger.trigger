/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 見積トリガ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/07          M.Kawasaki       New
 ********************************************************************************/
trigger QuoteTrigger on Quote__c (after insert, after update) {
    QuoteTriggerHandler handler = new QuoteTriggerHandler();

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.registerTodo(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.updateTodoDate(Trigger.oldMap, Trigger.new);
        }
    }
}