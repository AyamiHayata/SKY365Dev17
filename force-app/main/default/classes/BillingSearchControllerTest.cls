/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約検索コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/07/15          M.Miura          New
 ********************************************************************************/
@isTest
private class BillingSearchControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる

    }

    /**
     * 【対象】
     * getYearOptions
     * 【結果】
     * 年のリストが、空＋翌年から１０年前の１３個取得できていること
     */
    @isTest
    public static void test_getYearOptions() {

        // テスト開始
        Test.startTest();
        BillingSearchController ctrl = new BillingSearchController();
        List<SelectOption> yearList = ctrl.getYearOptions();
        Test.stopTest();

        // 検証
        System.assertEquals(yearList.size(),13);
    }

    /**
     * 【対象】
     * getMonthOptions
     * 【結果】
     * 月のリストが、空＋１月～１２月の１３個取得できていること
     */
    @isTest
    public static void test_getMonthOptions() {

        // テスト開始
        Test.startTest();
        BillingSearchController ctrl = new BillingSearchController();
        List<SelectOption> monthList = ctrl.getMonthOptions();
        Test.stopTest();

        // 検証
        System.assertEquals(monthList.size(),13);
    }

    /**
     * 【対象】
     * getInvoiceSendingOptions
     * 【結果】
     * 3件のオプションが取得できること
     */
    @isTest
    public static void test_getInvoiceSendingOptions() {

        // テスト開始
        Test.startTest();
        BillingSearchController ctrl = new BillingSearchController();
        List<SelectOption> invoiceSendingOptions = ctrl.getInvoiceSendingOptions();
        Test.stopTest();

        // 検証
        System.assertEquals(invoiceSendingOptions.size(),3);
    }

    /**
     * 【対象】
     * getDepositedOptions
     * 【結果】
     * 3件のオプションが取得できること
     */
    @isTest
    public static void test_getDepositedOptions() {

        // テスト開始
        Test.startTest();
        BillingSearchController ctrl = new BillingSearchController();
        List<SelectOption> depositedOptions = ctrl.getDepositedOptions();
        Test.stopTest();

        // 検証
        System.assertEquals(depositedOptions.size(),3);
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 検索結果が1000以下
     * 【結果】
     * 正常に処理されること
     */
    @isTest
    public static void test_initAction001() {

        // データ準備

        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 見積
        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.ApprovalStatus__c = 'approved';
        insert quote;

        // 見積明細
        QuoteDetail__c quoteDetail = TestUtil.createQuoteDetail(quote);
        quoteDetail.No__c = 3;
        insert quoteDetail;

        // 契約
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;

        // 契約明細
        ContractDetail__c contractDetail = TestUtil.createContractDetail(contract);
        contractDetail.No__c = 2;
        insert contractDetail;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;

        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(bill);
        insert billDtl;

        // テスト開始
        Test.startTest();

        Boolean result = true;

        try{
            BillingSearchController ctrl = new BillingSearchController();
            ctrl.searchCondBillingHeader.SearchBillingAccount__c = acc.Id;
            ctrl.searchBillingDepartment = '請求先部署';
            ctrl.searchCondBillingHeader.ApprovalStatus__c = 'approved';
            ctrl.searchCondBilling.Contract__c = contract.Id;
            ctrl.searchCondBilling.Account__c = acc.Id;
            ctrl.searchAccount = acc.Id;
            ctrl.searchCondInvoiceSending = 'true';
            ctrl.searchCondDeposited = 'true';
            ctrl.initAction();
        } catch(Exception e) {
            result = false;
        }

        Test.stopTest();

        // 検証
        System.assertEquals(true, result);
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 検索結果が1000より多い
     * 【結果】
     * エラーメッセージが表示されること
     */
    @isTest
    public static void test_initAction002() {

        // データ準備

        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 見積
        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.ApprovalStatus__c = 'approved';
        insert quote;

        // 見積明細
        QuoteDetail__c quoteDetail = TestUtil.createQuoteDetail(quote);
        quoteDetail.No__c = 3;
        insert quoteDetail;

        // 契約
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;

        // 契約明細
        ContractDetail__c contractDetail = TestUtil.createContractDetail(contract);
        contractDetail.No__c = 2;
        insert contractDetail;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        Date today = Date.today();
        billH.BillingYear__c = String.valueOf(today.year());
        billH.BillingMonth__c = String.valueOf(today.month());
        insert billH;

        // 請求
        Billing__c[] billList = new List<Billing__c>();
        for(integer cnt = 0; cnt <= 1000; cnt++){
            Billing__c bill = createBilling(acc, billH, constitution);
            billList.add(bill);
        }
        insert billList;

        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(billList[0]);
        insert billDtl;

        // テスト開始
        Test.startTest();

        Boolean result = true;

        try{
            BillingSearchController ctrl = new BillingSearchController();
            ctrl.initAction();
        } catch(Exception e) {
            result = false;
        }

        Test.stopTest();

        // 検証
        System.assertEquals(true, result);
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals('検索結果が1000件を超えるためすべてのレコードを表示できません。検索条件を入力し、結果を絞ってください。', messages[0].getDetail());
    }

    /**
     * 【対象】
     * searchActionPortal
     * 【条件】
     * ポータル画面から検索
     * 検索結果が1000以下
     * 【結果】
     * 正常に処理されること
     */
    @isTest
    public static void test_searchActionPortal001() {

        // データ準備

        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 見積
        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.ApprovalStatus__c = 'approved';
        insert quote;

        // 見積明細
        QuoteDetail__c quoteDetail = TestUtil.createQuoteDetail(quote);
        quoteDetail.No__c = 3;
        insert quoteDetail;

        // 契約
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;

        // 契約明細
        ContractDetail__c contractDetail = TestUtil.createContractDetail(contract);
        contractDetail.No__c = 2;
        insert contractDetail;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;

        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(bill);
        insert billDtl;

        // テスト開始
        Test.startTest();

        Boolean result = true;

        try{
            BillingSearchController ctrl = new BillingSearchController();
            Date today = Date.today();
            ctrl.searchCondYear= String.valueOf(today.year());
            ctrl.searchCondMonth= String.valueOf(today.month());
            ctrl.searchBillingDepartment= '請求先部署';
            ctrl.portalUserDepartment = 'テスト';
            ctrl.searchActionPortal();
        } catch(Exception e) {
            result = false;
        }

        Test.stopTest();

        // 検証
        System.assertEquals(true, result);
    }

    /**
     * 【対象】
     * searchActionPortal
     * 【条件】
     * ポータル画面から検索
     * 検索結果が1000より多い
     * 【結果】
     * エラーメッセージが表示されること
     */
    @isTest
    public static void test_searchActionPortal002() {

        // データ準備

        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 見積
        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.ApprovalStatus__c = 'approved';
        insert quote;

        // 見積明細
        QuoteDetail__c quoteDetail = TestUtil.createQuoteDetail(quote);
        quoteDetail.No__c = 3;
        insert quoteDetail;

        // 契約
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;

        // 契約明細
        ContractDetail__c contractDetail = TestUtil.createContractDetail(contract);
        contractDetail.No__c = 2;
        insert contractDetail;

        // 請求ヘッダ
        BillingHeader__c[] billHList = new List<BillingHeader__c>();
        for(integer cnt = 0; cnt <= 1000; cnt++){
            BillingHeader__c billH = createBillingHeader(acc, ct);
            billH.BillingDepartment__c = '請求先部署_' + cnt;
            billH.ApprovalStatus__c = 'approved';
            billHList.add(billH);
        }
        insert billHList;

        // 請求
        Billing__c bill = createBilling(acc, billHList[0], constitution);
        insert bill;

        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(bill);
        insert billDtl;

        // テスト開始
        Test.startTest();

        Boolean result = true;

        try{
            BillingSearchController ctrl = new BillingSearchController();
            ctrl.searchBillingDepartment= '請求先部署';
            ctrl.searchActionPortal();
        } catch(Exception e) {
            result = false;
        }

        Test.stopTest();

        // 検証
        System.assertEquals(true, result);
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals('検索結果が1000件を超えるためすべてのレコードを表示できません。検索条件を入力し、結果を絞ってください。', messages[0].getDetail());
    }

    /* 請求ヘッダ */
    private static BillingHeader__c createBillingHeader(Account acc, Contact ct) {
        BillingHeader__c billH = new BillingHeader__c();
        billH.SearchBillingAccount__c = acc.Id;
        billH.BillingAccount__c = acc.Id;
        billH.BillingContact__c = ct.Id;
        billH.BillingYear__c = String.valueof(Date.today().year());
        billH.BillingMonth__c = String.valueof(Date.today().month());
        return billH;
    }

    /* 請求 */
    private static Billing__c createBilling(Account acc, BillingHeader__c billH, Constitution_Common__c constitution) {
        Billing__c bill = new Billing__c();
        bill.Constitution_Common__c = constitution.Id;
        bill.BillingHeader__c = billH.Id;
        bill.Account__c = acc.Id;
        return bill;
    }

    /* 請求明細 */
    private static BillingDetail__c createBillingDetail(Billing__c bill) {
        BillingDetail__c billDtl = new BillingDetail__c();
        billDtl.Billing__c = bill.Id;
        return billDtl;
    }

}