/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約トリガハンドラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/22          M.Kawasaki       New
 ********************************************************************************/
public without sharing class ContractTriggerHandler {
    public ContractTriggerHandler() {

    }

    /**
     * 契約削除時に関連する案件に紐づく見積の受注済フラグをOFFにする
     */
    public void execQuoteFlgOff(Map<Id, Contract__c> oldMap) {
        List<Id> constitutionIdList = new List<Id>();
        for (Contract__c contract : oldMap.values()) {
            constitutionIdList.add(contract.Constitution_Common__c);
        }

        List<Quote__c> quoteList = [SELECT Id, IsOrder__c From Quote__c WHERE ConstitutionCommon__c IN: constitutionIdList];
        for (Quote__c quote : quoteList) {
            quote.IsOrder__c = false;
        }
        upsert quoteList;
    }
}