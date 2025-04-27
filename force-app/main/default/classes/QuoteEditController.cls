/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 見積編集画面コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/04/12          T.Matsuda        New
 ********************************************************************************/
public without sharing class QuoteEditController {

    // 明細登録最大件数
    private static final Integer DETAIL_MAX_COUNT = 1000;
    // 見積.承認状況(未申請)
    private static final String APPROVAL_STATUS_UNAPPLIED = 'unapplied';

    // 見積
    public Quote__c quote { get; set; }
    // 見積明細
    public List<QuoteDetailInner> details { get; set; }
    // 合計金額（税抜）
    public Decimal totalQuoteAmount { get; set; }
    // 消費税額（10%）
    public Decimal totalTaxAmount { get; set; }
    // 見積金額（税込）
    public Decimal totalAmountIncludingTax { get; set; }
    
    // コピーフラグ
    private Boolean isClone;
    // 見積ID
    private Id quoteId;
    // 削除対象見積明細
    private List<Id> delDetailIds;

    // 商品マスタをセットされた明細行
    public Integer targetIndex { get; set; }

    // 登録対象見積明細リスト
    private List<QuoteDetail__c> upsertDetails;

    /**
     * コンストラクタ
     */
    public QuoteEditController(ApexPages.StandardController stdController) {
        this.quote = (Quote__c) stdController.getRecord();
        this.details = new List<QuoteDetailInner>();
        this.totalQuoteAmount = 0;
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
        if (this.quote.Id == null) {
            // 見積作成ボタン(案件情報の詳細ボタン)から実行した場合はパラメータから案件情報を取得
            // 関連リストからの新規の場合、既に案件情報が設定されている
            if (this.quote.ConstitutionCommon__c == null) {
                // パラメータから案件情報のIDを取得
                String prm = ApexPages.currentPage().getParameters().get('cId');
                this.quote.ConstitutionCommon__c = prm;
            }
            // 案件情報変更時処理を実行
            changeConstitution();
            // 新規デフォルト表示設定
            setDefallt();
            // 新規の場合の明細
            addDetail();
        }
        // 編集、コピーの場合
        else {
            // パラメータを取得
            this.isClone = ApexPages.currentPage().getParameters().get('clone') == '1';
            // 取得対象の見積ID
            this.quoteId = this.quote.Id;
            // 見積を取得
            getQuote();
            // 見積明細を取得
            getQuoteDetails();
            // 合計金額計算
            calcTotalAmount();
        }
    }

    /**
     * 案件情報変更時
     */
    public void changeConstitution() {

        // 請求先（商流）の設定
        if (this.quote.ConstitutionCommon__c <> null) {
            List<Constitution_Common__c> constitutions = [
                SELECT Id, Name, Account__c, QuoteBillAccount__c
                FROM Constitution_Common__c
                WHERE Id = :this.quote.ConstitutionCommon__c
                LIMIT 1
            ];
            if (constitutions.size() > 0) {
                Constitution_Common__c constitution = constitutions[0];
                // 案件名
                this.quote.Name = constitution.Name;
                // 取引先
                this.quote.EndUser__c = constitution.Account__c;
                // 商流
                this.quote.BillAccount__c = constitution.QuoteBillAccount__c;
            }
        }
    }

    /**
     * 新規デフォルト表示設定
     */
    @TestVisible
    private void setDefallt() {
        // 見積
        this.quote.QuoteUser__c = UserInfo.getUserId();
        // その他
        this.quote.other__c = Label.QUOTE_OTHER_INITIAL;
        // 備考
        this.quote.Note__c = Label.QUOTE_NOTE_INITIAL;
        // 納品物
        this.quote.Deliverables__c = Label.QUOTE_DELIVERABLES_INITIAL;
    }

    /**
     * 見積取得
     */
    private void getQuote() {

        List<String> selectFields = new List<String>(
            Quote__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id qId = this.quoteId;

        this.quote = Database.query(
            String.format(
                'SELECT {0} FROM Quote__c WHERE Id = :qId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        // コピーの場合
        if (this.isClone) {
            this.quote = this.quote.clone(false, false);
            // コピー時の承認状況は「未申請」
            this.quote.ApprovalStatus__c = APPROVAL_STATUS_UNAPPLIED;
            // コピー時の一次承認で完了はfalse 2021.10.25
            this.quote.FirstApprvEndChk__c = false;
            // コピー時に受注受注済は「false」
            this.quote.IsOrder__c = false;
            // 案件情報、取引先を初期化
            this.quote.ConstitutionCommon__c = null;
            this.quote.EndUser__c = null;
            // 見積担当者にはログインユーザをセット
            this.quote.QuoteUser__c = UserInfo.getUserId();
            // 所有者を初期化
            this.quote.OwnerId = UserInfo.getUserId();
        }
    }

    /**
     * 見積明細取得
     */
    private void getQuoteDetails() {

        List<String> selectFields = new List<String>(
            QuoteDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id qId = this.quoteId;

        List<QuoteDetail__c> quoteDetails = Database.query(
            String.format(
                'SELECT {0} FROM QuoteDetail__c WHERE Quote__c = :qId ORDER BY No__c ASC NULLS LAST LIMIT ' + DETAIL_MAX_COUNT
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        for (QuoteDetail__c detail : quoteDetails) {
            // コピーの場合
            if (this.isClone) {
                detail = detail.clone(false, false);
                detail.Quote__c = null;
            }
            this.details.add(new QuoteDetailInner(detail));
        }
    }

    /**
     * 明細行追加
     */
    public void addDetail() {
        if (this.details.size() < DETAIL_MAX_COUNT) {
            Integer no = this.details.size() + 1;
            this.details.add(new QuoteDetailInner(new QuoteDetail__c(No__c = no, TaxType__c = 'tax10')));
        }
    }

    /**
     * 明細行削除
     */
    public void delDetail() {

        for (Integer i = this.details.size() - 1 ; i >= 0; i--) {

            QuoteDetailInner qdInner = this.details[i];

            if(qdInner.isSelected) {
                // 既に登録されているレコードの場合は削除用リストに追加
                if (qdInner.detail.Id <> null) {
                    this.delDetailIds.add(qdInner.detail.Id);
                }
                this.details.remove(i);
            }
        }

        // 合計金額計算
        calcTotalAmount();
    }

    /**
     * 商品選択時
     */
    public void changeProduct() {

        // 処理対象の見積明細を取得
        QuoteDetailInner detailInner = this.details[this.targetIndex];
        QuoteDetail__c detail = detailInner.detail;

        if (String.isNotBlank(detail.ProductName__c)) {
            // 明細行に単位や単価を設定
            Product__c product = [SELECT Id, Name, toLabel(Unit__c), UnitPrice__c, TaxType__c, AssumedWorkContent__c, LargeType__c, DetailType__c From Product__c WHERE Id = :detail.ProductName__c][0];
            detail.LargeType__c = product.LargeType__c;
            detail.DetailType__c = product.DetailType__c;
            detail.Unit__c = product.Unit__c;
            detail.UnitPrice__c = product.UnitPrice__c;
            detail.TaxType__c = product.TaxType__c;
            detail.Quantity__c = 1; // デフォルトで「1」をセット
            detail.ProductNameText__c = product.Name;

            // 商品マスタ.想定作業内容が空ではない場合
            if (String.isNotBlank(product.AssumedWorkContent__c)) {
                // 想定作業内容をAdd
                if (String.isNotBlank(this.quote.AssumedWorkContent__c)) {
                    this.quote.AssumedWorkContent__c += '\r\n';
                } else {
                    this.quote.AssumedWorkContent__c = '';
                }
                this.quote.AssumedWorkContent__c += '【No.' + detail.No__c + '】\r\n' + product.AssumedWorkContent__c;
            }
        }

        // 金額変更時の処理を実行
        changePrice();
    }

    /**
     * 金額変更時
     */
    public void changePrice() {

        // 処理対象の見積明細を取得
        QuoteDetailInner detailInner = this.details[this.targetIndex];
        QuoteDetail__c detail = detailInner.detail;

        // 金額の計算
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
        this.totalQuoteAmount = 0;
        this.totalTaxAmount = 0;
        this.totalAmountIncludingTax = 0;

        for (QuoteDetailInner detailInner : this.details) {
            this.totalQuoteAmount += CommonUtil.convertNullToZero(detailInner.detail.Amount__c);
            this.totalTaxAmount += CommonUtil.convertNullToZero(detailInner.detail.TaxPrice__c);
        }

        this.totalAmountIncludingTax = this.totalQuoteAmount + this.totalTaxAmount;
    }

    /**
     * 再計算
     */
    public void reCalcAction() {
        // 明細の再計算
        for (QuoteDetailInner detailInner : this.details) {
            QuoteDetail__c detail = detailInner.detail;
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

        this.upsertDetails = new List<QuoteDetail__c>();
        for (QuoteDetailInner detailInner : this.details) {
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
                // 更新の場合、承認状況を取得し申請中・承認済であればロック状態なのでエラーとする
                // ただし、システム管理者は除外とする
                Id profileId=userinfo.getProfileId();
                String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
                Set<String> excludeProfileNames = new Set<String>(System.Label.SYSTEM_ADMIN_PROFILE_NAMES.split(','));

                if (this.quote.Id != null && !excludeProfileNames.contains(profileName)) {
                    Quote__c nowQuote = [SELECT ApprovalStatus__c FROM Quote__c WHERE Id =: this.quote.Id LIMIT 1];
                    if (nowQuote.ApprovalStatus__c == 'applying' || nowQuote.ApprovalStatus__c == 'approved') {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR
                            , System.Label.MESSAGE_RECORD_LOCK_ERROR));
                        return null;
                    }
                }
                
                // 見積を保存
                upsert this.quote;

                for (QuoteDetail__c detail : this.upsertDetails) {
                    // 親レコードが未設定の場合（明細新規作成の場合）
                    if (detail.Quote__c == null) detail.Quote__c = this.quote.Id;
                }

                // 見積明細を保存
                upsert upsertDetails;

                // 見積明細削除
                if (this.delDetailIds.size() > 0) delete [SELECT Id FROM QuoteDetail__c WHERE Id IN :this.delDetailIds];

            } catch (Exception e) {
                Database.rollback(sp);
                System.debug('★' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR
                    , '予期せぬ例外が発生しました。システム管理者へお問い合わせください。'));
                return null;
            }
        } else {
            return null;
        }

        return new Pagereference('/' + this.quote.Id);
    }

    /**
     * 入力チェック
     */
    @TestVisible
    private void validate() {
        for (QuoteDetail__c detail : this.upsertDetails) {
            if (String.isBlank(detail.DetailType__c)) {
                detail.DetailType__c.addError('値を入力してください');
            }
            if (String.isBlank(detail.TaxType__c)) {
                detail.TaxType__c.addError('値を入力してください');
            }
        }
    }

    /**
     * 登録対象の見積明細かをチェックする
     * 　画面上の入力項目がすべて未入力の場合は登録対象としない
     * 
     * @param detail 見積明細
     * @return 登録対象：TRUE　登録対象外：FALSE
     */
    @TestVisible
    private Boolean getSaveCheckResult(QuoteDetail__c detail) {

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
        for (QuoteDetail__c detail : this.upsertDetails) {
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
     * 見積明細内部クラス
     */
    public class QuoteDetailInner {
        public Boolean isSelected { get; set; }
        public QuoteDetail__c detail { get; set; }
        public QuoteDetailInner(QuoteDetail__c detail) {
            this.isSelected = false;
            this.detail = detail;
        }
    }
}