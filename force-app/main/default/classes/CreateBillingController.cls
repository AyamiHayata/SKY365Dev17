/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 請求作成コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/22          T.Matsuda        New
 * 2022/07/05          K.Kikuchi        まとめ請求不具合対応（契約開始日が1日以外の場合、まとめ請求が出来ない）
 ********************************************************************************/
public without sharing class CreateBillingController {

    // 契約
    private Contract__c contract;
    // 請求対象年月
    @TestVisible private Date billingDate;
    // 請求ヘッダ
    public BillingHeader__c sameBillingHeader { get; set; }

    /**
     * コンストラクタ
     */
    public CreateBillingController(ApexPages.StandardController stdController) {
        // 契約を取得
        this.contract = (Contract__c) stdController.getRecord();
        // 請求対象年月を設定
        setBillingDate();
    }

    /**
     * 請求対象年月を設定
     */
    private void setBillingDate() {
        Integer baseDay;
        try {
            baseDay = Integer.valueOf(System.Label.CREATE_BILLING_BASE_DAY);
        } catch (Exception e) {
            baseDay = 1;
        }
        Date today = Date.today();
        // 現在の日付が基準日より前の場合、実行年月の前月が請求対象年月
        // 現在の日付が基準日以降の場合、実行年月が請求対象年月
        // e.g.) 現在：6/15⇒5月分請求、現在：6/16⇒6月分請求
        if (today.day() <= baseDay) {
            this.billingDate = Date.newInstance(today.year(), today.month(), 1).addMonths(-1);
        } else {
            this.billingDate = Date.newInstance(today.year(), today.month(), 1);
        }
    }

    /**
     * 初期処理
     */
    public Pagereference initAction() {

        // 契約を取得
        this.contract = [
            SELECT Id
                , Name, Billing__c, BillingDepartment__c, ContractEndDate__c
                , (SELECT Id, DetailType__c, BillingStartMonth__c, Contract__r.ContractStartDate__c, SpecifiedMonth__c FROM Contract_ContractDetails__r)
            FROM Contract__c
            WHERE Id = :this.contract.Id
            LIMIT 1
        ];

        // 請求対象年月が契約終了日を超えている場合
        // e.g.) 契約終了日：7/31 請求対象年月：6月　⇒　請求対象
        // e.g.) 契約終了日：6/30 請求対象年月：6月　⇒　請求対象
        // e.g.) 契約終了日：5/31 請求対象年月：6月　⇒　請求対象外
        if (this.contract.ContractEndDate__c <> null && this.contract.ContractEndDate__c < this.billingDate) {
            String msg = '対象の契約は請求可能な期間ではありません。【契約終了日】' + this.contract.ContractEndDate__c.format() + '【請求対象年月】' + this.billingDate.format();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, msg));
            return null;
        }

        // 請求対象年月、請求先および請求先部署または契約が同一の請求ヘッダを取得
        List<BillingHeader__c> sameBillingHeaders = getSameBillingHeader();
        // 同一の請求ヘッダが既に存在する場合
        if (sameBillingHeaders.size() > 0) {
            this.sameBillingHeader = sameBillingHeaders[0];
            String msg;
            if (String.isNotBlank(this.contract.BillingDepartment__c)) {
                msg = '請求対象年月、請求先、請求先部署が同一の請求ヘッダが既に存在しています。請求作成を行いたい場合、対象の請求ヘッダを削除してください。';
            } else {
                msg = '請求対象年月、請求先、契約が同一の請求ヘッダが既に存在しています。請求作成を行いたい場合、対象の請求ヘッダを削除してください。';
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, msg));
            return null;
        }

        // 関連する契約明細に請求対象のデータがあるかをチェック
        Boolean isExistence = checkBillingTarget();
        // 作成された請求ヘッダが存在しない場合
        if (!isExistence) {
            String msg = '請求対象の契約明細が存在しませんでした。';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, msg));
            return null;
        }

        // 同一の請求先、請求先部署の契約を取得
        List<Id> targetContractIds = new List<Id>{this.contract.Id};
        if (String.isNotBlank(this.contract.BillingDepartment__c)) {
            targetContractIds.addAll(getSameBillingContractIds(this.contract.Billing__c, this.contract.BillingDepartment__c));
        }

        // 請求作成処理実行
        BillingCreator creator = new BillingCreator(targetContractIds, this.billingDate);
        List<BillingHeader__c> billingHeaders = creator.execute();

        // 作成した請求ヘッダのページに遷移
        return new PageReference('/' + billingHeaders[0].Id);
    }

    /**
     * 関連する契約明細に請求対象のデータがあるかをチェック
     * @return チェック結果 TRUE：請求対象あり FALSE：請求対象なし
     */
    private Boolean checkBillingTarget() {

        for (ContractDetail__c detail : this.contract.Contract_ContractDetails__r) {
            Boolean ret = BillingCreator.hasBillable(detail, this.billingDate);
            if (ret) return true;
        }

        return false;
    }

    /**
     * 請求対象年月、請求先および請求先部署または契約が同一の請求ヘッダを取得
     * 
     * @return 請求ヘッダリスト
     */
    private List<BillingHeader__c> getSameBillingHeader() {

        Id contractId = this.contract.Id;
        Id accId = this.contract.Billing__c;
        String billingDept = this.contract.BillingDepartment__c;
        String billingYear = String.valueOf(this.billingDate.year());
        String billingMonth = String.valueOf(this.billingDate.month());

        String soql = 'SELECT Id FROM BillingHeader__c';
        soql += ' WHERE BillingAccount__c = :accId';
        soql += ' AND BillingYear__c = :billingYear';
        soql += ' AND BillingMonth__c = :billingMonth';

        if (String.isNotBlank(billingDept)) {
            soql += ' AND BillingDepartment__c = :billingDept';
        } else {
            soql += ' AND Contract__c = :contractId';
        }

        soql += ' LIMIT 1';

        List<BillingHeader__c> billingHeaders = Database.query(soql);

        return billingHeaders;
    }

    /**
     * 請求先、請求先部署が同一の契約を取得
     * 
     * @param accId 取引先ID
     * @param billingDept 請求先部署
     * @return 請求先、請求先部署が同一の契約IDリスト
     */
    private List<Id> getSameBillingContractIds(Id accId, String billingDept) {
        // 2022/07/05 kikuchi まとめ請求不具合対応 Start
        // 末日を設定
        Date target = this.billingDate.addMonths(1).addDays(-1);
        // 2022/07/05 kikuchi まとめ請求不具合対応 end
        
        // 契約開始日がNULL以外
        // 契約開始日＜＝請求対象年月
        // 契約終了日＞＝請求対象年月　または　契約終了日がNULL
        List<Contract__c> sameBillingContracts = [
            SELECT Id FROM Contract__c
            WHERE Billing__c = :accId
            AND BillingDepartment__c = :billingDept
            AND ContractStartDate__c <> null
            AND ContractStartDate__c <= :target
            AND (ContractEndDate__c >= :target OR ContractEndDate__c = null)
        ];

        List<Id> sameBillingContractIds = new List<Id>();
        for (Contract__c contract : sameBillingContracts) {
            sameBillingContractIds.add(contract.Id);
        }

        return sameBillingContractIds;
    }

    /**
     * 請求ヘッダ画面を表示
     */
    public PageReference moveBillingHeaderAction() {
        return new Pagereference('/' + this.sameBillingHeader.Id);
    }
}