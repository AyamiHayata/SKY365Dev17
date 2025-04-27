/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約トリガ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/22          M.Kawasaki       New
 ********************************************************************************/
trigger ContractTrigger on Contract__c (before delete) {
    ContractTriggerHandler handler = new ContractTriggerHandler();

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            handler.execQuoteFlgOff(Trigger.oldMap);
        }
    }
}