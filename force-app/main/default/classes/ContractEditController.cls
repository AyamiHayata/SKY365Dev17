/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約編集画面コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/05/12          T.Matsuda        New
 ********************************************************************************/
public without sharing class ContractEditController {

    // 明細登録最大件数
    private static final Integer DETAIL_MAX_COUNT = 1000;

    // 契約
    public Contract__c contract { get; set; }
    // 契約明細
    public List<ContractDetailInner> details { get; set; }
    
    // 合計金額（税抜）
    public Decimal totalContractAmount { get; set; }
    // 消費税額（10%）
    public Decimal totalTaxAmount { get; set; }
    // 見積金額（税込）
    public Decimal totalAmountIncludingTax { get; set; }

    // コピーフラグ
    private Boolean isClone;
    // 契約ID
    private Id contractId;
    // 削除対象契約明細
    private List<Id> delDetailIds;

    // 商品マスタをセットされた明細行
    public Integer targetIndex { get; set; }

    // 登録対象見積明細リスト
    @TestVisible private List<ContractDetail__c> upsertDetails;

    /**
     * コンストラクタ
     */
    public ContractEditController(ApexPages.StandardController stdController) {
        this.contract = (Contract__c) stdController.getRecord();
        this.details = new List<ContractDetailInner>();
        this.totalContractAmount = 0;
        this.totalTaxAmount = 0;
        this.totalAmountIncludingTax = 0;
        this.isClone = false;
        this.delDetailIds = new List<Id>();
        this.targetIndex = 0;
    }

    /**
     * 初期処理
     */
    public void initAction() {

        // 新規の場合
        if (this.contract.Id == null) {
            // 新規の場合の明細
            addDetail();
        }
        // 編集、コピーの場合
        else {
            // パラメータを取得
            this.isClone = ApexPages.currentPage().getParameters().get('clone') == '1';
            // 取得対象の契約ID
            this.contractId = this.contract.Id;
            // 契約を取得
            getContract();
            // 契約明細を取得
            getContractDetails();
            // 合計金額計算
            calcTotalAmount();
        }
    }

    /**
     * 契約取得
     */
    private void getContract() {

        List<String> selectFields = new List<String>(
            Contract__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id contractId = this.contractId;

        this.contract = Database.query(
            String.format(
                'SELECT {0} FROM Contract__c WHERE Id = :contractId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        // コピーの場合
        if (this.isClone) {
            this.contract = this.contract.clone(false, false);
            // 所有者を初期化
            this.contract.OwnerId = UserInfo.getUserId();
            // 最新請求ヘッダを初期化
            this.contract.LatestBillingHeader__c = null;
        }
    }

    /**
     * 契約明細取得
     */
    private void getContractDetails() {

        List<String> selectFields = new List<String>(
            ContractDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id conId = this.contractId;

        List<ContractDetail__c> contractDetails = Database.query(
            String.format(
                'SELECT {0} FROM ContractDetail__c WHERE Contract__c = :conId ORDER BY No__c ASC NULLS LAST LIMIT ' + DETAIL_MAX_COUNT
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        for (ContractDetail__c detail : contractDetails) {
            // コピーの場合
            if (this.isClone) {
                detail = detail.clone(false, false);
                detail.Contract__c = null;
            }
            this.details.add(new ContractDetailInner(detail));
        }
    }

    /**
     * 明細行追加
     */
    public void addDetail() {
        if (this.details.size() < DETAIL_MAX_COUNT) {
            Integer no = this.details.size() + 1;
            this.details.add(new ContractDetailInner(new ContractDetail__c(No__c = no, TaxType__c = 'tax10')));
        }
    }

    /**
     * 明細行削除
     */
    public void delDetail() {

        for (Integer i = this.details.size() - 1 ; i >= 0; i--) {

            ContractDetailInner detailInner = this.details[i];

            if(detailInner.isSelected) {
                // 既に登録されているレコードの場合は削除用リストに追加
                if (detailInner.detail.Id <> null) {
                    this.delDetailIds.add(detailInner.detail.Id);
                }
                this.details.remove(i);
            }
        }

        // 合計金額計算
        calcTotalAmount();
    }

    /**
     * 商品選択
     */
    public void changeProduct() {

        // 明細行に単位や単価を設定
        ContractDetailInner detailInner = this.details[this.targetIndex];
        ContractDetail__c detail = detailInner.detail;
        String targetProductId = detail.ProductName__c;

        if (String.isNotBlank(targetProductId)) {
            Product__c product = [SELECT Id, Name, toLabel(Unit__c), UnitPrice__c, TaxType__c, AssumedWorkContent__c, LargeType__c, DetailType__c From Product__c WHERE Id =: targetProductId][0];
            detail.LargeType__c = product.LargeType__c;
            detail.DetailType__c = product.DetailType__c;
            detail.Unit__c = product.Unit__c;
            detail.UnitPrice__c = product.UnitPrice__c;
            detail.TaxType__c = product.TaxType__c;
            detail.Quantity__c = 1; // デフォルトで「1」をセット
            detail.ProductNameText__c = product.Name;
        }

        // 金額変更されたら計算しなおす
        changePrice();
    }

    /**
     * 金額変更
     */
    public void changePrice() {

        // 明細行にセットされた単価や数量から金額を計算して設定
        ContractDetailInner detailInner = this.details[this.targetIndex];
        ContractDetail__c detail = detailInner.detail;
        detail.Amount__c = (CommonUtil.convertNullToZero(detail.UnitPrice__c) * CommonUtil.convertNullToZero(detail.Quantity__c)).round(System.RoundingMode.HALF_UP);
        // 消費税額の計算
        if (detail.TaxType__c == Constants.TAX_TYPE_10) {
            detail.TaxPrice__c = (detail.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        } else {
            detail.TaxPrice__c = 0;
        }

        // 合計金額計算
        calcTotalAmount();
    }

    /**
     * 合計金額計算
     */
    public void calcTotalAmount() {

        // 合計金額初期化
        this.totalContractAmount = 0;
        this.totalTaxAmount = 0;
        this.totalAmountIncludingTax = 0;

        for (ContractDetailInner detailInner : this.details) {
            this.totalContractAmount += CommonUtil.convertNullToZero(detailInner.detail.Amount__c);
            this.totalTaxAmount += CommonUtil.convertNullToZero(detailInner.detail.TaxPrice__c);
        }

        this.totalAmountIncludingTax = this.totalContractAmount + this.totalTaxAmount;
    }

    /**
     * 再計算
     */
    public void reCalcAction() {
        // 明細の再計算
        for (ContractDetailInner detailInner : this.details) {
            ContractDetail__c detail = detailInner.detail;
            // 明細行にセットされた単価や数量から金額を計算して設定
            detail.Amount__c = (CommonUtil.convertNullToZero(detail.UnitPrice__c) * CommonUtil.convertNullToZero(detail.Quantity__c)).round(System.RoundingMode.HALF_UP);
            // 消費税額の計算
            if (detail.TaxType__c == Constants.TAX_TYPE_10) {
                detail.TaxPrice__c = (detail.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
            } else {
                detail.TaxPrice__c = 0;
            }
        }
        // 合計の再計算
        calcTotalAmount();
    }

    /**
     * 保存
     */
    public PageReference saveAction() {

        this.upsertDetails = new List<ContractDetail__c>();
        for (ContractDetailInner detailInner : this.details) {
            // 登録対象のレコードを抽出
            if (getSaveCheckResult(detailInner.detail)) {
                // 登録用のリストに追加
                upsertDetails.add(detailInner.detail);
            }
        }

        // すべての明細の金額を再計算
        calcAmountAll();

        // チェック処理
        validate();

        Savepoint sp = Database.setSavepoint();

        if (!ApexPages.hasMessages()) { // エラーがなければ
            try {
                if (this.contract.IsInitCreate__c) {
                    // 初回編集の場合は、更新種別に基づいて契約終了日を自動設定し、初回作成フラグを落とす
                    setContractEndDate();
                    this.contract.IsInitCreate__c = false;
                }
                // 契約を保存
                upsert this.contract;

                for (ContractDetail__c detail : this.upsertDetails) {
                    // 親レコードが未設定の場合（明細新規作成の場合）
                    if (detail.Contract__c == null) detail.Contract__c = this.contract.Id;
                }

                // 契約明細を保存
                upsert upsertDetails;

                // 契約明細削除
                if (this.delDetailIds.size() > 0) delete [SELECT Id FROM ContractDetail__c WHERE Id IN :this.delDetailIds];

            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getStackTraceString());
                //2021.11.15 2lines comment out
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR
                //    , '予期せぬ例外が発生しました。システム管理者へお問い合わせください。'));
                ApexPages.addMessages(e);  //2021.11.15 add
                return null; //2021.11.15 add
            }
        } else {
            return null;
        }
        return new Pagereference('/' + this.contract.Id);
    }

    /**
     * 入力チェック
     */
    @TestVisible
    private void validate() {
        //契約種別で分岐
        if (this.contract.UpdateCycle__c != Constants.UPDATE_CYCLE_AUTO) {
            // 自動更新以外の場合

            // 契約開始日、契約終了日の両方に入力がある場合
            if (this.contract.ContractStartDate__c <> null && this.contract.ContractEndDate__c <> null) {
                // 契約開始日 > 契約終了日となっている場合
                if (this.contract.ContractStartDate__c > this.contract.ContractEndDate__c) {
                    this.contract.ContractEndDate__c.addError('日付を正しく入力してください。');
                }
            }
        }
        
        if (this.contract.IsAttachment__c && String.isBlank(this.contract.AttachmentInfo__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '添付物を入力してください。'));
        }

        for (ContractDetail__c detail : this.upsertDetails) {

            // 詳細が空の場合
            if (String.isBlank(detail.DetailType__c)) {
                detail.DetailType__c.addError('値を入力してください。');
            }

            // 税区分が空の場合
            if (String.isBlank(detail.TaxType__c)) {
                detail.TaxType__c.addError('値を入力してください。');
            }

            // 年払い or スポットの場合
            if (detail.DetailType__c == Constants.DETAIL_TYPE_ANNUAL || detail.DetailType__c == Constants.DETAIL_TYPE_SPOT) {
                // 請求開始月が指定月以外の場合
                if (detail.BillingStartMonth__c <> Constants.BILLING_START_SPECIFIED_MONTH) {
                    detail.BillingStartMonth__c.addError('指定月を選択してください。');
                }
            }

            // 請求開始月が指定月の場合
            if (detail.BillingStartMonth__c == Constants.BILLING_START_SPECIFIED_MONTH) {
                // 指定月が未設定の場合
                if (detail.SpecifiedMonth__c == null) {
                    detail.SpecifiedMonth__c.addError('日付を入力してください。');
                }
            }
          
        }
    }

    /**
     * 登録対象の契約明細かをチェックする
     * 　画面上の入力項目がすべて未入力の場合は登録対象としない
     * 
     * @param detail 契約明細
     * @return 登録対象：TRUE　登録対象外：FALSE
     */
    @TestVisible
    private Boolean getSaveCheckResult(ContractDetail__c detail) {

        if (String.isBlank(detail.LargeType__c)
            && detail.ProductName__c == null
            && String.isBlank(detail.DetailType__c)
            && detail.UnitPrice__c == null
            && detail.Quantity__c == null
            && String.isBlank(detail.Unit__c)
            && String.isBlank(detail.TaxType__c)
        ) {
            return false;
        }

        return true;
    }

    /**
     * すべての明細の金額を再計算
     */
    @TestVisible
    private void calcAmountAll() {
        for (ContractDetail__c detail : this.upsertDetails) {
            // 明細行にセットされた単価や数量から金額を計算して設定
            detail.Amount__c = (CommonUtil.convertNullToZero(detail.UnitPrice__c) * CommonUtil.convertNullToZero(detail.Quantity__c)).round(System.RoundingMode.HALF_UP);
            // 消費税額の計算
            if (detail.TaxType__c == Constants.TAX_TYPE_10) {
                detail.TaxPrice__c = (detail.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
            } else {
                detail.TaxPrice__c = 0;
            }
        }
    }

    /**
     * 初回編集時のみ、契約終了日の自動セットを行う
     */
    @TestVisible
    private void setContractEndDate() {
        if (contract.ContractStartDate__c != null && contract.ContractEndDate__c == null) {
            if (contract.UpdateCycle__c == Constants.UPDATE_CYCLE_3_MONTHS) {
                contract.ContractEndDate__c = Date.newInstance(contract.ContractStartDate__c.year(), contract.ContractStartDate__c.month() + 3, 0);
            } else if (contract.UpdateCycle__c == Constants.UPDATE_CYCLE_6_MONTHS) {
                contract.ContractEndDate__c = Date.newInstance(contract.ContractStartDate__c.year(), contract.ContractStartDate__c.month() + 6, 0);
            } else if (contract.UpdateCycle__c == Constants.UPDATE_CYCLE_12_MONTHS) {
                contract.ContractEndDate__c = Date.newInstance(contract.ContractStartDate__c.year(), contract.ContractStartDate__c.month() + 12, 0);
            } 
        }
    }

    /**
     * 契約明細内部クラス
     */
    public class ContractDetailInner {
        public Boolean isSelected { get; set; }
        public ContractDetail__c detail { get; set; }
        public Date specifiedMonth { get; set; }
        public ContractDetailInner(ContractDetail__c detail) {
            this.isSelected = false;
            this.detail = detail;
        }
    }
}