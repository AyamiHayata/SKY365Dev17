/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約更新コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/08          M.Kawasaki       New
 ********************************************************************************/
public with sharing class ContractRenewalController {

    private Contract__c contract; 

    public ContractRenewalController(ApexPages.StandardController stdController) {
        getContract((Contract__c)stdController.getRecord());
    }

    public PageReference initAction() {
        if (this.contract.UpdateCycle__c == Constants.UPDATE_CYCLE_AUTO) {
            String msg = '自動更新のため契約更新ボタンは押下できません。';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, msg));
            return null;
        }
        if (!this.contract.IsContractUpdateMonth__c) {
            String msg = '更新月ではないため契約更新ボタンは押下できません。';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, msg));
            return null;
        }
        renewalContractEndTerm();
        return new PageReference('/' + this.contract.Id);
    }

    @TestVisible
    private void renewalContractEndTerm() {
        Date newEndTermDate = contract.ContractEndDate__c != null ? contract.ContractEndDate__c : Date.today();
        String updateCycle = contract.UpdateCycle__c;
        if (updateCycle == Constants.UPDATE_CYCLE_3_MONTHS) {
            newEndTermDate = Date.newInstance(newEndTermDate.year(), newEndTermDate.month() + 4, 0);
        } else if (updateCycle == Constants.UPDATE_CYCLE_6_MONTHS) {
            newEndTermDate = Date.newInstance(newEndTermDate.year(), newEndTermDate.month() + 7, 0);
        } else if (updateCycle == Constants.UPDATE_CYCLE_12_MONTHS) {
            newEndTermDate = Date.newInstance(newEndTermDate.year(), newEndTermDate.month() + 13, 0);
        }
        contract.ContractEndDate__c = newEndTermDate;

        update contract;
    }

    /**
     * 契約取得
     */
    private void getContract(Contract__c sorceContract) {

        List<String> selectFields = new List<String>(
            Contract__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id cId = sorceContract.Id;

        this.contract = Database.query(
            String.format(
                'SELECT {0} FROM Contract__c WHERE Id = :cId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

    }
}