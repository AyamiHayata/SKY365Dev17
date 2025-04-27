/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 請求編集画面コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/05/20          T.Matsuda        New
 ********************************************************************************/
public without sharing class BillingEditController {

    // 明細デフォルト表示件数
    private static final Integer DETAIL_DEFAULT_COUNT = 5;
    // 明細登録最大件数
    // private static final Integer DETAIL_MAX_COUNT = 20;
    private static final Integer DETAIL_MAX_COUNT = 1000;
    // 請求.承認状況(未申請)
    private static final String APPROVAL_STATUS_UNAPPLIED = 'unapplied';

    // 合計金額（税抜）
    public Decimal totalContractAmount { get; set; }
    // 消費税額（10%）
    public Decimal totalTaxAmount { get; set; }
    // 見積金額（税込）
    public Decimal totalAmountIncludingTax { get; set; }

    // 請求
    public Billing__c billing { get; set; }
    // 請求明細
    public List<BillingDetailInner> details { get; set; }
    
    // コピーフラグ
    private Boolean isClone;
    // 請求ID
    private Id billingId;
    // 削除対象請求明細
    private List<Id> delDetailIds;

    // 商品マスタをセットされた明細行
    public Integer targetIndex { get; set; }

    // 登録対象請求明細リスト
    @TestVisible private List<BillingDetail__c> upsertDetails;

    /**
     * コンストラクタ
     */
    public billingEditController(ApexPages.StandardController stdController) {
        this.billing = (Billing__c) stdController.getRecord();
        this.details = new List<BillingDetailInner>();
        this.isClone = false;
        this.delDetailIds = new List<Id>();
        this.targetIndex = 0;
    }

    /**
     * 初期処理
     */
    public void initAction() {

        // 新規の場合
        if (this.billing.Id == null) {
            // 新規の場合の明細
            addDetail();
        }
        // 編集、コピーの場合
        else {
            // パラメータを取得
            this.isClone = ApexPages.currentPage().getParameters().get('clone') == '1';
            // 取得対象の請求ID
            this.billingId = this.billing.Id;
            // 請求を取得
            getBilling();
            // 請求明細を取得
            getBillingDetails();
            // 合計金額計算
            calcTotalAmount();
        }
    }

    /**
     * 請求取得
     */
    private void getBilling() {

        List<String> selectFields = new List<String>(
            Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id qId = this.billingId;

        this.billing = Database.query(
            String.format(
                'SELECT {0} FROM Billing__c WHERE Id = :qId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        // コピーの場合
        if (this.isClone) {
            this.billing = this.billing.clone(false, false);
            this.billing.BillingHeader__c = null;
        }
    }

    /**
     * 請求明細取得
     */
    private void getBillingDetails() {

        List<String> selectFields = new List<String>(
            BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id bId = this.billingId;

        List<BillingDetail__c> billingDetails = Database.query(
            String.format(
                'SELECT {0} FROM BillingDetail__c WHERE Billing__c = :bId ORDER BY No__c ASC LIMIT ' + DETAIL_MAX_COUNT
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        for (BillingDetail__c detail : billingDetails) {
            // コピーの場合
            if (this.isClone) {
                detail = detail.clone(false, false);
                detail.Billing__c = null;
            }
            this.details.add(new BillingDetailInner(detail));
        }
    }

    /**
     * 明細行追加
     */
    public void addDetail() {
        if (this.details.size() < DETAIL_MAX_COUNT) {
            Integer no = this.details.size() + 1;
            this.details.add(new BillingDetailInner(new BillingDetail__c(No__c = no, TaxType__c = 'tax10')));
        }
    }

    /**
     * 明細行削除
     */
    public void delDetail() {

        for (Integer i = this.details.size() - 1 ; i >= 0; i--) {

            BillingDetailInner bdInner = this.details[i];

            if(bdInner.isSelected) {
                // 既に登録されているレコードの場合は削除用リストに追加
                if (bdInner.detail.Id <> null) {
                    this.delDetailIds.add(bdInner.detail.Id);
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
        BillingDetailInner detailInner = this.details[this.targetIndex];
        BillingDetail__c detail = detailInner.detail;
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
        BillingDetailInner detailInner = this.details[this.targetIndex];
        BillingDetail__c detail = detailInner.detail;
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

        for (BillingDetailInner detailInner : this.details) {
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
        for (BillingDetailInner detailInner : this.details) {
            BillingDetail__c detail = detailInner.detail;
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

        this.upsertDetails = new List<BillingDetail__c>();
        for (BillingDetailInner detailInner : this.details) {
            // 登録対象のレコードを抽出
            if (getSaveCheckResult(detailInner.detail)) {
                // 登録用のリストに追加
                this.upsertDetails.add(detailInner.detail);
            }
        }

        // すべての明細の金額を再計算
        calcAmountAll();

        // チェック処理
        validate();

        Savepoint sp = Database.setSavepoint();

        if (!ApexPages.hasMessages()) { // エラーがなければ
            
            try {
                // 更新の場合、承認状況を取得し申請中・承認済であればロック状態なのでエラーとする
                // ただし、システム管理者は除外とする
                Id profileId=userinfo.getProfileId();
                String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
                Set<String> excludeProfileNames = new Set<String>(System.Label.SYSTEM_ADMIN_PROFILE_NAMES.split(','));

                if (this.billing.Id != null && !excludeProfileNames.contains(profileName)) {
                    BillingHeader__c nowBilling = [SELECT ApprovalStatus__c FROM BillingHeader__c WHERE Id =: this.billing.BillingHeader__c LIMIT 1];
                    if (nowBilling.ApprovalStatus__c == 'applying' || nowBilling.ApprovalStatus__c == 'approved') {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR
                            , System.Label.MESSAGE_RECORD_LOCK_ERROR));
                        return null;
                    }
                }

                // 請求を保存
                upsert this.billing;

                for (BillingDetail__c detail : this.upsertDetails) {
                    // 親レコードが未設定の場合（明細新規作成の場合）
                    if (detail.Billing__c == null) detail.Billing__c = this.billing.Id;
                }

                // 請求明細を保存
                upsert upsertDetails;

                // 請求明細削除
                if (this.delDetailIds.size() > 0) delete [SELECT Id FROM BillingDetail__c WHERE Id IN :this.delDetailIds];

            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR
                    , '予期せぬ例外が発生しました。システム管理者へお問い合わせください。'));
            }
        } else {
            return null;
        }

        return new Pagereference('/' + this.billing.Id);
    }

    /**
     * 入力チェック
     */
    @TestVisible
    private void validate() {

        if (String.isBlank(this.billing.Name)) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '値を入力してください。'));
            this.billing.Name.addError('値を入力してください。');
        }

        for (BillingDetail__c detail : this.upsertDetails) {

            // 詳細が空の場合
            if (String.isBlank(detail.DetailType__c)) {
                detail.DetailType__c.addError('値を入力してください。');
            }

            // 税区分が空の場合
            if (String.isBlank(detail.TaxType__c)) {
                detail.TaxType__c.addError('値を入力してください。');
            }
          
        }

    }

    /**
     * 登録対象の請求明細かをチェックする
     * 　画面上の入力項目がすべて未入力の場合は登録対象としない
     * 
     * @param detail 請求明細
     * @return 登録対象：TRUE　登録対象外：FALSE
     */
    @TestVisible
    private Boolean getSaveCheckResult(BillingDetail__c detail) {

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
        for (BillingDetail__c detail : this.upsertDetails) {
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
     * 請求明細内部クラス
     */
    public class BillingDetailInner {
        public Boolean isSelected { get; set; }
        public BillingDetail__c detail { get; set; }
        public BillingDetailInner(BillingDetail__c detail) {
            this.isSelected = false;
            this.detail = detail;
        }
    }
}