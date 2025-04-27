/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 請求作成バッチ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/18          T.Matsuda        New
 * 2022/07/05          K.Kikuchi        まとめ請求不具合対応（契約開始日が1日以外の場合、まとめ請求が出来ない）
 ********************************************************************************/
public class BillingCreatorBatch implements Database.Batchable<sObject>, Database.Stateful {

    // 請求対象年月
    private Date billingDate;
    // バッチで作成された請求ヘッダ
    private List<BillingHeader__c> createdBillingHeaders;

    /**
     * コンストラクタ
     */
    public BillingCreatorBatch() {
        Date today = Date.today();
        // 請求対象年月＝実行年月の前月
        this.billingDate = Date.newInstance(today.year(), today.month(), 1).addMonths(-1);
        this.createdBillingHeaders = new List<BillingHeader__c>();
    }

    /**
     * start
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        // 2022/07/05 kikuchi まとめ請求不具合対応 Start
        // 末日を設定
        // Date target = this.billingDate;
        Date target = this.billingDate.addMonths(1).addDays(-1);
        // 2022/07/05 kikuchi まとめ請求不具合対応 end

        // 契約開始日がNULL以外
        // 契約開始日＜＝請求対象年月
        // 契約終了日＞＝請求対象年月　または　契約終了日がNULL
        String soql = 'SELECT Id, Name, Billing__c, BillingDepartment__c FROM Contract__c';
        soql += ' WHERE ContractStartDate__c <> null AND ContractStartDate__c <= :target';
        soql += ' AND (ContractEndDate__c >= :target OR ContractEndDate__c = null)';
        return Database.getQueryLocator(soql);
    }

    /**
     * execute
     */
    public void execute(Database.BatchableContext bc, List<Contract__c> contracts) {
        
        // 請求作成対象の契約を取得
        List<Contract__c> targetContracts = getTargetContracts(contracts);
        List<Id> targetContractIds = new List<Id>();
        for (Contract__c contract : targetContracts) {
            targetContractIds.add(contract.Id);
        }

        // 請求作成処理実行
        BillingCreator creator = new BillingCreator(targetContractIds, this.billingDate, this.createdBillingHeaders);
        this.createdBillingHeaders.addAll(creator.execute());
    }

    /**
     * 請求作成対象の契約を取得
     * 
     * @param contracts 契約リスト
     * @return 請求対象契約リスト
     */
    private List<Contract__c> getTargetContracts(List<Contract__c> contracts) {

        List<Id> billings = new List<Id>();
        List<String> billingDepts = new List<String>();

        // 請求先、請求先部署を取得
        for (Contract__c contract : contracts) {
            billings.add(contract.Billing__c);
            billingDepts.add(contract.BillingDepartment__c);
        }

        // 既存の請求ヘッダを取得
        Map<String, BillingHeader__c> existingBillingHeaderMap = getExistingBillingHeaderMap(billings, billingDepts);

        // 処理対象の抽出
        List<Contract__c> targetContracts = new List<Contract__c>();
        for (Contract__c contract : contracts) {
            String key;
            if (String.isNotBlank(contract.BillingDepartment__c)) {
                // key:請求先ID＋請求先部署＋請求年＋請求月
                key = contract.Billing__c + contract.BillingDepartment__c + this.billingDate.year() + this.billingDate.month();
            } else {
                // key:請求先ID＋契約ID＋請求年＋請求月
                key = contract.Billing__c + String.valueOf(contract.Id) + this.billingDate.year() + this.billingDate.month();
            }
            // 既存の請求ヘッダが存在しない場合
            if (!existingBillingHeaderMap.containsKey(key)) {
                targetContracts.add(contract);
            }
        }

        return targetContracts;
    }

    /**
     * 既存の請求ヘッダを取得する
     */
    private Map<String, BillingHeader__c> getExistingBillingHeaderMap(List<Id> billings, List<String> billingDepts) {

        // 既存の請求ヘッダを取得
        List<BillingHeader__c> existingBillingHeaders = [
            SELECT Id, BillingAccount__c, BillingDepartment__c, Contract__c, BillingYear__c, BillingMonth__c
            FROM BillingHeader__c
            WHERE BillingAccount__c IN :billings
            AND BillingDepartment__c IN :billingDepts
            AND BillingYear__c = :String.valueOf(this.billingDate.year())
            AND BillingMonth__c = :String.valueOf(this.billingDate.month())
            AND ID NOT IN :this.createdBillingHeaders // 当バッチで作成された請求ヘッダ以外
        ];

        Map<String, BillingHeader__c> existingBillingHeaderMap = new Map<String, BillingHeader__c>();

        for (BillingHeader__c header : existingBillingHeaders) {
            String key;
            if (String.isNotBlank(header.BillingDepartment__c)) {
                // key:請求先ID＋請求先部署＋請求年＋請求月
                key = header.BillingAccount__c + header.BillingDepartment__c + header.BillingYear__c + header.BillingMonth__c;
            } else {
                // key:請求先ID＋契約ID＋請求年＋請求月
                key = header.BillingAccount__c + String.valueOf(header.Contract__c) + header.BillingYear__c + header.BillingMonth__c;
            }
            existingBillingHeaderMap.put(key, header);
        }

        return existingBillingHeaderMap;
    }

    /**
     * finish
     */
    public void finish(Database.BatchableContext bc) {
        
    }
}