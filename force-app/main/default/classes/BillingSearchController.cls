/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 請求検索画面コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/05/20          T.Matsuda        New
 * 2023/11/22          K.kikuchi        電帳法対応
 ********************************************************************************/
public with sharing class BillingSearchController {

    // 検索結果表示最大件数
    private static final Integer SERACH_MAX_COUNT = 1000;

    // 年月リスト
    public List<SelectOption> yearOptions { get; set; }
    public List<SelectOption> monthOptions { get; set; }
    // 2024/11/22 電帳法対応
    public List<SelectOption> dayOptions { get; set; }

    // 検索テキスト
    public String searchBillingDepartment { get; set; }
    public String searchAccount { get; set; }
    // 2024/11/22 電帳法対応
    public Decimal searchTotalAmountIncludingTax { get; set;}

    // 検索条件
    public String searchCondYear { get; set; }
    public String searchCondMonth { get; set; }
    public String searchCondDay { get; set; }
    public BillingHeader__c searchCondBillingHeader { get; set; }
    public Billing__c searchCondBilling { get; set; }
    public String searchCondInvoiceSending { get; set; }
    public String searchCondDeposited { get; set; }

    // ユーザ
    public User loginUserDetail { get; set; }
    public String portalUserDepartment { get; set; }

    // 検索結果
    public List<Billing__c> billings { get; set; }
    public List<BillingHeader__c> billingHeaders { get; set; }
    
    // 年選択リスト
    @TestVisible
    public List<SelectOption> getYearOptions() {

        // 現在の年を取得
        Integer currentYear = Date.today().year();

        // 現在の年の±1年が選択可能
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption(String.valueOf(currentYear + 1), String.valueOf(currentYear + 1) + '年'));
        options.add(new SelectOption(String.valueOf(currentYear), String.valueOf(currentYear) + '年'));
        for (Integer i=1; i<=10; i++) {
            options.add(new SelectOption(String.valueOf(currentYear - i), String.valueOf(currentYear - i) + '年'));
        }

        return options;
    }

    // 月選択リスト
    @TestVisible
    public List<SelectOption> getMonthOptions() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));

        for (Integer i=1; i<=12; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i) + '月'));
        }

        return options;
    }

    // 日選択リスト
    @TestVisible
    public List<SelectOption> getDayOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        for (Integer i=1; i<=31; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i) + '日'));
        }
        return options;    
    }

    // 請求書送付選択リスト
    public List<SelectOption> getInvoiceSendingOptions() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--なし--'));
        options.add(new SelectOption('false', '未送付'));
        options.add(new SelectOption('true', '送付済'));

        return options;
    }

    // 請求書送付選択リスト
    public List<SelectOption> getDepositedOptions() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--なし--'));
        options.add(new SelectOption('false', '未確認'));
        options.add(new SelectOption('true', '確認済'));

        return options;
    }

    /**
     * コンストラクタ
     */
    public BillingSearchController() {
        this.searchCondBillingHeader = new BillingHeader__c();
        this.searchCondBilling = new Billing__c();
        this.yearOptions = getYearOptions();
        this.monthOptions = getMonthOptions();
        this.dayOptions = getDayOptions();
        this.searchAccount = '';
        this.searchBillingDepartment = '';
        this.loginUserDetail = new User();
        this.portalUserDepartment = '';
        this.searchCondBillingHeader.ApprovalStatus__c = '';
        this.searchCondInvoiceSending = '';
        this.searchCondDeposited = '';
        this.searchTotalAmountIncludingTax = null;
    }

    /**
     * 初期処理
     */
    public void initAction() {
        // ログインユーザがポータルユーザかどうかなど取得
        this.loginUserDetail = [SELECT AccountId, ContactId, Account.Name, Contact.Department, IsPortalEnabled From User Where Id =: UserInfo.getUserId() LIMIT 1];
        // 検索画面で入力項目に直接指定できないため、一度変数に保持
        this.portalUserDepartment = this.loginUserDetail.Contact.Department;

        // 現在日付で検索条件セット
        Date today = Date.today();
        this.searchCondYear = String.valueOf(today.year());
        this.searchCondMonth = String.valueOf(today.month());
        searchAction();
    }

    /**
     * 検索処理
     */
    public void searchAction() {
        if (this.loginUserDetail.IsPortalEnabled) {
            searchActionPortal();
            return;
        }

        String countCond = 'SELECT COUNT()';

        String selectCond = 'SELECT Id, BillingHeader__r.BillingNumber__c, BillingHeader__r.Name, Name';
        selectCond += ', BillingHeader__r.BillingYearMonth__c, BillingHeader__r.BillingAccount__c, BillingHeader__r.BillingDepartment__c';
        selectCond += ', BillingHeader__r.ApprovalStatus__c, TotalAmountIncludingTax__c, BillingHeader__r.IsInvoiceSending__c, BillingHeader__r.IsDeposited__c';
        selectCond += ', BillingHeader__c, BillingHeader__r.BillingAccount__r.Name, Account__r.Name, BillingHeader__r.InvoiceOutputDate__c';

        String fromCond = ' FROM Billing__c';

        String whereCond = ' ';
        List<String> whereCondList = new List<String>();
        // 請求年
        if (searchCondYear <> null) {
            whereCondList.add('BillingHeader__r.BillingYear__c = :searchCondYear');
        }
        // 請求月
        if (searchCondMonth <> null) {
            whereCondList.add('BillingHeader__r.BillingMonth__c = :searchCondMonth');
        }
        // 請求日
        if (searchCondDay <> null) {
            whereCondList.add('BillingHeader__r.BillingDay__c = :searchCondDay');
        }
        // 請求先
        String searchBillingAccount = searchCondBillingHeader.SearchBillingAccount__c;
        if (!String.isBlank(searchCondBillingHeader.SearchBillingAccount__c)) {
            whereCondList.add('BillingHeader__r.BillingAccount__c = :searchBillingAccount');
        }
        // 請求先部署（Like検索）
        String billingDepartment = '';
        if (String.isNotBlank(searchBillingDepartment)) {
            billingDepartment = '%' + String.escapeSingleQuotes(searchBillingDepartment) + '%';
            whereCondList.add('BillingHeader__r.BillingDepartment__c LIKE :billingDepartment ');
        }
        // 請求金額（税込）
        if (searchTotalAmountIncludingTax > 0) {
            whereCondList.add('BillingHeader__r.TotalAmountIncludingTax__c = :searchTotalAmountIncludingTax');
        }

        // 承認状況
        String aaprovalStatus = searchCondBillingHeader.ApprovalStatus__c;
        if (String.isNotBlank(searchCondBillingHeader.ApprovalStatus__c)) {
            whereCondList.add('BillingHeader__r.ApprovalStatus__c = :AaprovalStatus');
        }
        // 契約
        String contract = searchCondBilling.Contract__c;
        if (String.isNotBlank(searchCondBilling.Contract__c)) {
            whereCondList.add('Contract__c = :contract');
        }
        // 取引先
        String account = searchCondBilling.Account__c;
        if (searchCondBilling.Account__c <> null) {
            whereCondList.add('Account__c = :account');
        }
        // 請求書送付
        if (String.isNotBlank(this.searchCondInvoiceSending)) {
            Boolean isInvoiceSending = Boolean.valueOf(this.searchCondInvoiceSending);
            whereCondList.add('BillingHeader__r.IsInvoiceSending__c = :isInvoiceSending');
        }
        // 入金確認
        if (String.isNotBlank(this.searchCondDeposited)) {
            Boolean isDeposited = Boolean.valueOf(this.searchCondDeposited);
            whereCondList.add('BillingHeader__r.IsDeposited__c = :isDeposited');
        }

        if (whereCondList.size() > 0) {
            whereCond = ' WHERE ' + String.join(whereCondList, ' AND ');
        }

        String orderCond = ' ORDER BY BillingHeader__r.BillingNumber__c DESC';
        String limitCond = ' LIMIT ' + SERACH_MAX_COUNT;

        String countSoql = countCond + fromCond + whereCond;

        Integer cnt = Database.countQuery(countSoql);
        if (cnt > SERACH_MAX_COUNT) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.WARNING
                    , '検索結果が' + SERACH_MAX_COUNT
                    + '件を超えるためすべてのレコードを表示できません。検索条件を入力し、結果を絞ってください。'
                )
            );
        }

        String soql = selectCond + fromCond + whereCond + orderCond + limitCond;
        this.billings = Database.query(soql);
    }

    @TestVisible
    private void searchActionPortal() {

        String countCond = 'SELECT COUNT()';

        String selectCond = 'SELECT Id, BillingNumber__c, Name';
        selectCond += ', BillingYearMonth__c, BillingAccount__c';
        selectCond += ', BillingDepartment__c, TotalAmountIncludingTax__c';
        selectCond += ', BillingAccount__r.Name';

        String fromCond = ' FROM BillingHeader__c';

        String whereCond = ' ';
        List<String> whereCondList = new List<String>();
        // 請求年
        if (searchCondYear <> null) {
            whereCondList.add('BillingYear__c = :searchCondYear');
        }
        // 請求月
        if (searchCondMonth <> null) {
            whereCondList.add('BillingMonth__c = :searchCondMonth');
        }
        // 請求先
        String searchBillingAccount = this.loginUserDetail.AccountId;
        if (String.isNotBlank(this.loginUserDetail.AccountId)) {
            whereCondList.add('BillingAccount__c = :searchBillingAccount');
        }
        // 請求先部署（Like検索）
        String billingDepartment = '';
        if (String.isNotBlank(portalUserDepartment)) {
            billingDepartment = '%' + String.escapeSingleQuotes(portalUserDepartment) + '%';
            whereCondList.add('BillingDepartment__c LIKE :billingDepartment ');
        }
        // 承認状況…承認済のみ
        String ApprovalStatus = 'approved';
        whereCondList.add('ApprovalStatus__c = :ApprovalStatus');

        if (whereCondList.size() > 0) {
            whereCond = ' WHERE ' + String.join(whereCondList, ' AND ');
        }

        String orderCond = ' ORDER BY BillingNumber__c DESC';
        String limitCond = ' LIMIT ' + SERACH_MAX_COUNT;

        String countSoql = countCond + fromCond + whereCond;

        Integer cnt = Database.countQuery(countSoql);
        if (cnt > SERACH_MAX_COUNT) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.WARNING
                    , '検索結果が' + SERACH_MAX_COUNT
                    + '件を超えるためすべてのレコードを表示できません。検索条件を入力し、結果を絞ってください。'
                )
            );
        }

        String soql = selectCond + fromCond + whereCond + orderCond + limitCond;
        this.billingHeaders = Database.query(soql);
    }
}