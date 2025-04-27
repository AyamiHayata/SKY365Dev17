/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約更新コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/09          XXXXXXX          New
 ********************************************************************************/
@isTest
private class QuoteEditControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
        
    }

    /**
     * 【対象】
     * changeConstitution
     * 【結果】
     * 見積の件名、取引先、請求先には、それぞれ案件情報の件名、取引先、見積用請求先が指定されること、
     */
    @isTest
    public static void test_changeConstitution() {

        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Name = '案件変更メソッドテスト_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        constitution.Commercial_flow__c = 'TerraSky';
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.changeConstitution();

        Test.stopTest();

        Constitution_Common__c  checkConstitution = [SELECT Id, Name, Account__c, QuoteBillAccount__c FROM Constitution_Common__c LIMIT 1];

        // 検証
        System.assertEquals(ctrl.quote.Name, checkConstitution.Name);
        System.assertEquals(ctrl.quote.EndUser__c, checkConstitution.Account__c);
        System.assertEquals(ctrl.quote.BillAccount__c, checkConstitution.QuoteBillAccount__c);
    }

    /**
     * 【対象】
     * setDefallt
     * 【結果】
     * 見積の見積担当者、その他、備考、納品物には、それぞれログインユーザー、カスタム表示ラベルのその他、備考、納品物が指定されること、
     */
    @isTest
    public static void test_setDefallt() {

        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.setDefallt();

        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.quote.QuoteUser__c, UserInfo.getUserId());
        System.assertEquals(ctrl.quote.other__c, Label.QUOTE_OTHER_INITIAL);
        System.assertEquals(ctrl.quote.Note__c, Label.QUOTE_NOTE_INITIAL);
        System.assertEquals(ctrl.quote.Deliverables__c, Label.QUOTE_DELIVERABLES_INITIAL);
    }

    /**
     * 【対象】
     * addDetail
     * 【結果】
     * 明細に行が追加されること
     */
    @isTest
    public static void test_addDetail() {

        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.addDetail();

        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.details.size(),1);
    }

    /**
     * 【対象】
     * delDetail
     * 【結果】
     * 明細の行が削除されること
     */
    @isTest
    public static void test_delDetail() {

        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.addDetail();
        ctrl.addDetail();
        ctrl.addDetail();
        ctrl.details[0].detail.No__c = 1;
        ctrl.details[1].detail.No__c = 2;
        ctrl.details[2].detail.No__c = 3;

        // １行目と２行目の明細を削除する
        ctrl.details[0].isSelected = true;
        ctrl.details[1].isSelected = true;
        ctrl.delDetail();

        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.details.size(),1);
        System.assertEquals(ctrl.details[0].detail.No__c,3);
    }

    /**
     * 【対象】
     * changePrice
     * 【結果】
     * 税率が設定されている場合で、明細行の金額、税額が計算されること・合計金額の計算処理が実行されること
     */
    @isTest
    public static void test_changePrice_001() {

        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.addDetail();
        ctrl.addDetail();

        // １行目と２行目の明細の値を設定する
        ctrl.details[0].detail.UnitPrice__c = 1000;
        ctrl.details[0].detail.Quantity__c =10;
        ctrl.details[0].detail.Amount__c = 1000*10;
        ctrl.details[0].detail.TaxPrice__c = (ctrl.details[0].detail.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        ctrl.details[0].detail.TaxType__c = 'tax10';
        ctrl.details[1].detail.UnitPrice__c = 2000;
        ctrl.details[1].detail.Quantity__c =20;
        ctrl.details[1].detail.TaxType__c = 'tax10';
        ctrl.targetIndex = 1;
        ctrl.changePrice();

        Test.stopTest();

        // 合計金額の取得
        // 合計金額（税抜）
        Decimal totalQuoteAmount = ctrl.details[0].detail.Amount__c + ctrl.details[1].detail.Amount__c;
        // 消費税額（10%）
        Decimal totalTaxAmount = ctrl.details[0].detail.TaxPrice__c + ctrl.details[1].detail.TaxPrice__c;
        // 見積金額（税込）
        Decimal totalAmountIncludingTax = totalQuoteAmount + totalTaxAmount;

        // 検証
        System.assertEquals(ctrl.details[1].detail.Amount__c, 2000*20);
        System.assertEquals(ctrl.details[1].detail.TaxPrice__c, (ctrl.details[1].detail.Amount__c * 0.1).round(System.RoundingMode.HALF_UP));
        // 合計金額
        System.assertEquals(ctrl.totalAmountIncludingTax, totalAmountIncludingTax);
        System.assertEquals(ctrl.totalQuoteAmount, totalQuoteAmount);
        System.assertEquals(ctrl.totalTaxAmount, totalTaxAmount);

    }

    /**
     * 【対象】
     * changePrice
     * 【結果】
     * 税率が設定されていない場合で、明細行の金額、税額が計算されること・合計金額の計算処理が実行されること
     */
    @isTest
    public static void test_changePrice_002() {

        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.addDetail();
        ctrl.addDetail();

        // １行目と２行目の明細の値を設定する
        ctrl.details[0].detail.UnitPrice__c = 1000;
        ctrl.details[0].detail.Quantity__c =10;
        ctrl.details[0].detail.Amount__c = 1000*10;
        ctrl.details[0].detail.TaxPrice__c = 0;
        ctrl.details[0].detail.TaxType__c = 'noTax';
        ctrl.details[1].detail.UnitPrice__c = 2000;
        ctrl.details[1].detail.Quantity__c =20;
        ctrl.details[1].detail.TaxType__c = 'noTax';
        ctrl.targetIndex = 1;
        ctrl.changePrice();

        Test.stopTest();

        // 合計金額の取得
        // 合計金額（税抜）
        Decimal totalQuoteAmount = ctrl.details[0].detail.Amount__c + ctrl.details[1].detail.Amount__c;
        // 消費税額（10%）
        Decimal totalTaxAmount = ctrl.details[0].detail.TaxPrice__c + ctrl.details[1].detail.TaxPrice__c;
        // 見積金額（税込）
        Decimal totalAmountIncludingTax = totalQuoteAmount + totalTaxAmount;

        // 検証
        System.assertEquals(ctrl.details[1].detail.Amount__c, 2000*20);
        System.assertEquals(ctrl.details[1].detail.TaxPrice__c, 0);
        // 合計金額
        System.assertEquals(ctrl.totalAmountIncludingTax, totalAmountIncludingTax);
        System.assertEquals(ctrl.totalQuoteAmount, totalQuoteAmount);
        System.assertEquals(ctrl.totalTaxAmount, totalTaxAmount);

    }

    /**
     * 【対象】
     * changeProduct
     * 【結果】
     * 変更した商品の情報が存在している場合、明細に商品の情報が設定されていること
     */
    @isTest
    public static void test_changeProduct_001() {

        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        Product__c pdct1 = TestUtil.createProducts('tax10', 1000);
        pdct1.LargeType__c = 'operation';
        pdct1.DetailType__c = 'annual';
        pdct1.Unit__c = 'shiki';
        pdct1.AssumedWorkContent__c = 'test';
        insert pdct1;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.addDetail();

        // 明細の商品の値を設定する
        ctrl.details[0].detail.ProductName__c = pdct1.Id;
        ctrl.targetIndex = 0;
        ctrl.changeProduct();

        Test.stopTest();

        // 明細行に単位や単価を設定
        Product__c product = [SELECT Id, Name, toLabel(Unit__c), UnitPrice__c, TaxType__c, AssumedWorkContent__c, LargeType__c, DetailType__c From Product__c WHERE Id = :pdct1.Id];

        // 検証
        System.assertEquals(ctrl.details[0].detail.LargeType__c, product.LargeType__c);
        System.assertEquals(ctrl.details[0].detail.DetailType__c, product.DetailType__c);
        System.assertEquals(ctrl.details[0].detail.Unit__c, product.Unit__c);
        System.assertEquals(ctrl.details[0].detail.UnitPrice__c, product.UnitPrice__c);
        System.assertEquals(ctrl.details[0].detail.TaxType__c, product.TaxType__c);
        System.assertEquals(ctrl.details[0].detail.Quantity__c, 1);

    }

    /**
     * 【対象】
     * changeProduct
     * 【結果】
     * 変更した商品の情報が存在していない場合、明細に商品の情報が設定されていないこと
     */
    @isTest
    public static void test_changeProduct_002() {

        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.addDetail();

        // 明細の商品の値を設定せずにメソッドの呼び出しを行う
        ctrl.targetIndex = 0;
        ctrl.changeProduct();

        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.details[0].detail.LargeType__c, null);
        System.assertEquals(ctrl.details[0].detail.DetailType__c, null);
        System.assertEquals(ctrl.details[0].detail.Unit__c, null);
        System.assertEquals(ctrl.details[0].detail.UnitPrice__c, null);
        System.assertEquals(ctrl.details[0].detail.TaxType__c, 'tax10');
        System.assertEquals(ctrl.details[0].detail.Quantity__c, null);

    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 新規の場合・パラメータでIDを渡された案件情報の商流がSky365の場合（商流が直流）
     * 【結果】
     * 変数にデフォルト値が設定されていること・見積の請求先には案件の取引先が指定されること・見積明細が1件追加された状態であること
     */
    @isTest
    public static void test_initAction_001() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Commercial_flow__c = 'SKY365';
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ApexPages.currentPage().getParameters().put('cId', constitution.Id);
        ctrl.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.quote.other__c, Label.QUOTE_OTHER_INITIAL);
        System.assertEquals(ctrl.quote.Note__c, Label.QUOTE_NOTE_INITIAL);
        System.assertEquals(ctrl.quote.Deliverables__c, Label.QUOTE_DELIVERABLES_INITIAL);
        System.assertEquals(ctrl.quote.BillAccount__c, constitution.Account__c);
        System.assertEquals(ctrl.quote.EndUser__c, constitution.Account__c);
        System.assertEquals(ctrl.details.size(),1);
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 新規の場合・パラメータでIDを渡された案件情報の商流がSky365以外の場合
     * 【結果】
     * 変数にデフォルト値が設定されていること・見積の請求先には案件の商流に応じた取引先が指定されること・見積明細が1件追加された状態であること
     */
    @isTest
    public static void test_initAction_002() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Commercial_flow__c = 'TerraSky';
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ApexPages.currentPage().getParameters().put('cId', constitution.Id);
        ctrl.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.quote.other__c, Label.QUOTE_OTHER_INITIAL);
        System.assertEquals(ctrl.quote.Note__c, Label.QUOTE_NOTE_INITIAL);
        System.assertEquals(ctrl.quote.Deliverables__c, Label.QUOTE_DELIVERABLES_INITIAL);
        // 本来は見積の請求先にTerraSkyの取引先が設定されていることのテストが必要となるが、
        // 案件情報の商流からは設定されるべき取引先の情報を取得できず、IDで直接指定することになるため、コメントアウト
        // ※環境によってIDが異なり、テストでエラーとなることを避けるため
        //System.assertEquals(ctrl.quote.BillAccount__c, '0010T00000GC3HUQA1');
        System.assertEquals(ctrl.quote.EndUser__c, constitution.Account__c);
        System.assertEquals(ctrl.details.size(),1);
    }

    /**
     * 【対象】
     * initAction、getQuote、getQuoteDetails、calcTotalAmount
     * 【条件】
     * 更新・コピーの場合・パラメータでIDを渡された案件情報の商流がSky365以外の場合
     * 【結果】
     * テスト用に登録した見積の情報が設定されていること・見積明細が２件追加され登録した明細の情報が設定されていること・明細の金額の合計が計算されていること
     */
    @isTest
    public static void test_initAction_003() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Contact con = TestUtil.createContact(acc);
        insert con;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c ctrct = TestUtil.createContract(acc.Id, constitution);
        insert ctrct;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        // 確認用の値を設定
        quote.Name = '見積取得メソッドテスト_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApplyerRole__c = '申請者ロール_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApprovalStatus__c = 'applying';
        quote.AssumedWorkContent__c = '想定作業内容_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.BillAccount__c = acc.Id;
        quote.BillingContact__c = con.Id;
        quote.ClosingMonth__c = 'twoMonthsLater';
        quote.ConstitutionCommon__c = constitution.Id;
        quote.Contract__c = ctrct.Id;
        quote.Deliverables__c = '納品物_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.EndUser__c = acc.Id;
        quote.EstimateOutputDate__c = date.today();
        quote.ExpirationDate__c = '有効期限_';
        quote.IsOrder__c = true;
        quote.Note__c = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.Other__c = 'その他_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.OwnerId = UserInfo.getUserId();
        quote.QuoteTerm__c = '期間_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.QuoteTodo__c = '見積書発行ToDo_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.QuoteUser__c = UserInfo.getUserId();
        insert quote;

        Product__c pdct2 = TestUtil.createProducts('tax10', 2000);
        pdct2.Name = 'テスト商品２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct2;
        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;

        QuoteDetail__c detail2 = TestUtil.createQuoteDetail(quote);
        // Noの昇順になっているかの検証のため、先に２で登録
        detail2.No__c = 2;
        detail2.Remarks__C = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail2.LargeType__c = 'operation';
        detail2.Unit__c = 'テスト';
        detail2.UnitPrice__c = 2000;
        detail2.ProductName__c = pdct2.Id;
        detail2.Quantity__c =20;
        detail2.Amount__c = detail2.UnitPrice__c * detail2.Quantity__c;
        detail2.TaxPrice__c = (detail2.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail2.Quote__c = quote.Id;
        detail2.DetailType__c = 'initialCost';
        detail2.TaxType__c = 'tax10';
        insert detail2;
        QuoteDetail__c detail1 = TestUtil.createQuoteDetail(quote);
        // Noの昇順になっているかの検証のため、先に２で登録
        detail1.No__c = 1;
        detail1.Remarks__C = '備考1_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail1.LargeType__c = '';
        detail1.Unit__c = 'テスト1';
        detail1.UnitPrice__c = 1000;
        detail1.ProductName__c = pdct1.Id;
        detail1.Quantity__c =10;
        detail1.Amount__c = detail1.UnitPrice__c * detail1.Quantity__c;
        detail1.TaxPrice__c = (detail1.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail1.Quote__c = quote.Id;
        detail1.DetailType__c = 'monthlyCost';
        detail1.TaxType__c = 'noTax';
        insert detail1;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.initAction();
        
        Test.stopTest();

        // 検証用見積データ取得
        Id qId =quote.Id;
        List<String> selectFields = new List<String>(
            Quote__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        Quote__c checkQuote = Database.query(
            String.format(
                'SELECT {0} FROM Quote__c WHERE Id = :qId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );
        List<String> selectDetailFields = new List<String>(
            QuoteDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        List<QuoteDetail__c> checkQuoteDetails = Database.query(
            String.format(
                'SELECT {0} FROM QuoteDetail__c WHERE Quote__c = :qId ORDER BY No__c ASC NULLS LAST '
                , new List<String>{ String.join(selectDetailFields, ', ') }
            )
        );

        // 合計金額の取得
        // 合計金額（税抜）
        Decimal totalQuoteAmount = ctrl.details[0].detail.Amount__c + ctrl.details[1].detail.Amount__c;
        // 消費税額（10%）
        Decimal totalTaxAmount = ctrl.details[0].detail.TaxPrice__c + ctrl.details[1].detail.TaxPrice__c;
        // 見積金額（税込）
        Decimal totalAmountIncludingTax = totalQuoteAmount + totalTaxAmount;

        // 検証
        // 見積
        System.assertEquals(ctrl.quote.Id, checkQuote.Id);
        System.assertEquals(ctrl.quote.Name, checkQuote.Name);
        System.assertEquals(ctrl.quote.ConstitutionCommon__c, checkQuote.ConstitutionCommon__c);
        System.assertEquals(ctrl.quote.Contract__c, checkQuote.Contract__c);
        System.assertEquals(ctrl.quote.CreatedById, checkQuote.CreatedById);
        System.assertEquals(ctrl.quote.Deliverables__c, checkQuote.Deliverables__c);
        System.assertEquals(ctrl.quote.EndUser__c, checkQuote.EndUser__c);
        System.assertEquals(ctrl.quote.EstimateOutputDate__c, checkQuote.EstimateOutputDate__c);
        System.assertEquals(ctrl.quote.ExpirationDate__c, checkQuote.ExpirationDate__c);
        System.assertEquals(ctrl.quote.IsOrder__c, checkQuote.IsOrder__c);
        System.assertEquals(ctrl.quote.LastModifiedById, checkQuote.LastModifiedById);
        System.assertEquals(ctrl.quote.Note__c, checkQuote.Note__c);
        System.assertEquals(ctrl.quote.Other__c, checkQuote.Other__c);
        System.assertEquals(ctrl.quote.OwnerId, checkQuote.OwnerId);
        System.assertEquals(ctrl.quote.PaymentCondition__c, checkQuote.PaymentCondition__c);
        System.assertEquals(ctrl.quote.QuoteNumber__c, checkQuote.QuoteNumber__c);
        System.assertEquals(ctrl.quote.QuoteTerm__c, checkQuote.QuoteTerm__c);
        System.assertEquals(ctrl.quote.QuoteTodo__c, checkQuote.QuoteTodo__c);
        System.assertEquals(ctrl.quote.QuoteUser__c, checkQuote.QuoteUser__c);
        System.assertEquals(ctrl.quote.TotalAmountIncludingTax__c, checkQuote.TotalAmountIncludingTax__c);
        System.assertEquals(ctrl.quote.TotalQuoteAmount__c, checkQuote.TotalQuoteAmount__c);
        System.assertEquals(ctrl.quote.TotalTaxAmount__c, checkQuote.TotalTaxAmount__c);
        
        // 見積明細
        System.assertEquals(ctrl.details.size(),2);
        System.assertEquals(ctrl.details[0].detail.No__c, checkQuoteDetails[0].No__c);
        System.assertEquals(ctrl.details[0].detail.CreatedById, checkQuoteDetails[0].CreatedById);
        System.assertEquals(ctrl.details[0].detail.Remarks__c, checkQuoteDetails[0].Remarks__c);
        System.assertEquals(ctrl.details[0].detail.LargeType__c, checkQuoteDetails[0].LargeType__c);
        System.assertEquals(ctrl.details[0].detail.Unit__c, checkQuoteDetails[0].Unit__c);
        System.assertEquals(ctrl.details[0].detail.UnitPrice__c, checkQuoteDetails[0].UnitPrice__c);
        System.assertEquals(ctrl.details[0].detail.ProductName__c, checkQuoteDetails[0].ProductName__c);
        System.assertEquals(ctrl.details[0].detail.Quantity__c, checkQuoteDetails[0].Quantity__c);
        System.assertEquals(ctrl.details[0].detail.LastModifiedById, checkQuoteDetails[0].LastModifiedById);
        System.assertEquals(ctrl.details[0].detail.TaxPrice__c, checkQuoteDetails[0].TaxPrice__c);
        System.assertEquals(ctrl.details[0].detail.Quote__c, checkQuoteDetails[0].Quote__c);
        System.assertEquals(ctrl.details[0].detail.Name, checkQuoteDetails[0].Name);
        System.assertEquals(ctrl.details[0].detail.DetailType__c, checkQuoteDetails[0].DetailType__c);
        System.assertEquals(ctrl.details[0].detail.TaxType__c, checkQuoteDetails[0].TaxType__c);
        System.assertEquals(ctrl.details[0].detail.Amount__c, checkQuoteDetails[0].Amount__c);
        System.assertEquals(ctrl.details[1].detail.No__c, checkQuoteDetails[1].No__c);
        System.assertEquals(ctrl.details[1].detail.CreatedById, checkQuoteDetails[1].CreatedById);
        System.assertEquals(ctrl.details[1].detail.Remarks__c, checkQuoteDetails[1].Remarks__c);
        System.assertEquals(ctrl.details[1].detail.LargeType__c, checkQuoteDetails[1].LargeType__c);
        System.assertEquals(ctrl.details[1].detail.Unit__c, checkQuoteDetails[1].Unit__c);
        System.assertEquals(ctrl.details[1].detail.UnitPrice__c, checkQuoteDetails[1].UnitPrice__c);
        System.assertEquals(ctrl.details[1].detail.ProductName__c, checkQuoteDetails[1].ProductName__c);
        System.assertEquals(ctrl.details[1].detail.Quantity__c, checkQuoteDetails[1].Quantity__c);
        System.assertEquals(ctrl.details[1].detail.LastModifiedById, checkQuoteDetails[1].LastModifiedById);
        System.assertEquals(ctrl.details[1].detail.TaxPrice__c, checkQuoteDetails[1].TaxPrice__c);
        System.assertEquals(ctrl.details[1].detail.Quote__c, checkQuoteDetails[1].Quote__c);
        System.assertEquals(ctrl.details[1].detail.Name, checkQuoteDetails[1].Name);
        System.assertEquals(ctrl.details[1].detail.DetailType__c, checkQuoteDetails[1].DetailType__c);
        System.assertEquals(ctrl.details[1].detail.TaxType__c, checkQuoteDetails[1].TaxType__c);
        System.assertEquals(ctrl.details[1].detail.Amount__c, checkQuoteDetails[1].Amount__c);
        // 合計金額
        System.assertEquals(ctrl.totalAmountIncludingTax, totalAmountIncludingTax);
        System.assertEquals(ctrl.totalQuoteAmount, totalQuoteAmount);
        System.assertEquals(ctrl.totalTaxAmount, totalTaxAmount);

    }

    /**
     * 【対象】
     * saveAction
     * 【条件】
     *　コピーを押した時のデータ取得
     * 【結果】
     * 
     */
    @isTest
    public static void test_initAction_004() {

        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Contact con = TestUtil.createContact(acc);
        insert con;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c ctrct = TestUtil.createContract(acc.Id, constitution);
        insert ctrct;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        // 確認用の値を設定
        quote.Name = '見積取得メソッドテスト_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApplyerRole__c = '申請者ロール_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApprovalStatus__c = 'unapplied';
        quote.AssumedWorkContent__c = '想定作業内容_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.BillAccount__c = acc.Id;
        quote.BillingContact__c = con.Id;
        quote.ClosingMonth__c = 'twoMonthsLater';
        quote.ConstitutionCommon__c = constitution.Id;
        quote.Contract__c = ctrct.Id;
        quote.Deliverables__c = '納品物_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.EndUser__c = acc.Id;
        quote.EstimateOutputDate__c = date.today();
        quote.ExpirationDate__c = '有効期限_';
        quote.IsOrder__c = true;
        quote.Note__c = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.Other__c = 'その他_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.OwnerId = UserInfo.getUserId();
        quote.QuoteTerm__c = '期間_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.QuoteTodo__c = '見積書発行ToDo_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.QuoteUser__c = UserInfo.getUserId();
        insert quote;

        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;
        Product__c pdct2 = TestUtil.createProducts('tax10', 2000);
        pdct2.Name = 'テスト商品２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct2;
        
        QuoteDetail__c detail1 = TestUtil.createQuoteDetail(quote);
        detail1.No__c = 1;
        detail1.Remarks__C = '備考1_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail1.LargeType__c = '';
        detail1.Unit__c = 'テスト1';
        detail1.UnitPrice__c = 1000;
        detail1.ProductName__c = pdct1.Id;
        detail1.Quantity__c =10;
        detail1.Amount__c = detail1.UnitPrice__c * detail1.Quantity__c;
        detail1.TaxPrice__c = (detail1.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail1.Quote__c = quote.Id;
        detail1.DetailType__c = 'monthlyCost';
        detail1.TaxType__c = 'noTax';
        insert detail1;
        QuoteDetail__c detail2 = TestUtil.createQuoteDetail(quote);
        detail2.No__c = 2;
        detail2.Remarks__C = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail2.LargeType__c = 'operation';
        detail2.Unit__c = 'テスト';
        detail2.UnitPrice__c = 2000;
        detail2.ProductName__c = pdct2.Id;
        detail2.Quantity__c =20;
        detail2.Amount__c = detail2.UnitPrice__c * detail2.Quantity__c;
        detail2.TaxPrice__c = (detail2.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail2.Quote__c = quote.Id;
        detail2.DetailType__c = 'initialCost';
        detail2.TaxType__c = 'tax10';
        insert detail2;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ApexPages.currentPage().getParameters().put('clone', '1');
        ctrl.initAction();

        Test.stopTest();

        // 検証
        // 見積
        System.assertEquals('unapplied',ctrl.quote.ApprovalStatus__c);
        System.assertEquals(false,ctrl.quote.FirstApprvEndChk__c);
        System.assertEquals(false,ctrl.quote.IsOrder__c);
        System.assertEquals(null,ctrl.quote.ConstitutionCommon__c);
        System.assertEquals(null,ctrl.quote.EndUser__c);
        

    }

    /**
     * 【対象】
     * getSaveCheckResult
     * 【条件】
     * 保存対象の見積明細ではない場合
     * 【結果】
     * Falseが返ってくること
     */
    @isTest
    public static void test_getSaveCheckResult_001() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        insert quote;

        QuoteDetail__c qd = new QuoteDetail__c();

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        Boolean saveChkResult = ctrl.getSaveCheckResult(qd);

        Test.stopTest();

        // 検証
        System.assertEquals(saveChkResult, False);
    }

    /**
     * 【対象】
     * getSaveCheckResult
     * 【条件】
     * 保存対象の見積明細の場合
     * 【結果】
     * Trueが返ってくること
     */
    @isTest
    public static void test_getSaveCheckResult_002() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        insert quote;

        Product__c pdct = TestUtil.createProducts('noTax', 1000);
        insert pdct;

        QuoteDetail__c qd1 = new QuoteDetail__c();
        qd1.LargeType__c = 'operation';
        QuoteDetail__c qd2 = new QuoteDetail__c();
        qd2.ProductName__c = pdct.Id;
        QuoteDetail__c qd3 = new QuoteDetail__c();
        qd3.DetailType__c = 'monthlyCost';
        QuoteDetail__c qd4 = new QuoteDetail__c();
        qd4.UnitPrice__c = 100;
        QuoteDetail__c qd5 = new QuoteDetail__c();
        qd5.Quantity__c = 100;
        QuoteDetail__c qd6 = new QuoteDetail__c();
        qd6.Unit__c = '台';
        QuoteDetail__c qd7 = new QuoteDetail__c();
        qd7.TaxType__c = 'noTax';

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        Boolean saveChkResult1 = ctrl.getSaveCheckResult(qd1);
        Boolean saveChkResult2 = ctrl.getSaveCheckResult(qd2);
        Boolean saveChkResult3 = ctrl.getSaveCheckResult(qd3);
        Boolean saveChkResult4 = ctrl.getSaveCheckResult(qd4);
        Boolean saveChkResult5 = ctrl.getSaveCheckResult(qd5);
        Boolean saveChkResult6 = ctrl.getSaveCheckResult(qd6);
        Boolean saveChkResult7 = ctrl.getSaveCheckResult(qd7);

        Test.stopTest();

        // 検証
        System.assertEquals(saveChkResult1, True);
        System.assertEquals(saveChkResult2, True);
        System.assertEquals(saveChkResult3, True);
        System.assertEquals(saveChkResult4, True);
        System.assertEquals(saveChkResult5, True);
        System.assertEquals(saveChkResult6, True);
        System.assertEquals(saveChkResult7, True);
    }

    /**
     * 【対象】
     * saveAction
     * 【条件】
     *　入力内容にエラーがある場合
     * 【結果】
     * エラーメッセージが表示され、保存処理が行われていないこと
     */
    @isTest
    public static void test_saveAction_001() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.Name = '見積保存メソッドテスト１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        // 明細を追加する
        ctrl.addDetail();
        ctrl.details[0].detail.ProductName__c = pdct1.Id;
        ctrl.details[0].detail.DetailType__c = null;

        // エラーがある状態で保存処理実行
        ctrl.saveAction();
        
        Test.stopTest();

        // 検証用見積データ件数取得
        String qName = quote.Name;
        Integer count = Database.countQuery('SELECT COUNT() FROM Quote__c WHERE Name = :qName ');

        // 検証
        System.assertEquals(count, 0);
        
    }

    /**
     * 【対象】
     * saveAction
     * 【条件】
     *　入力内容にエラーがない場合で新規登録
     * 【結果】
     * 入力した内容で見積が新規登録されていること
     */
    @isTest
    public static void test_saveAction_002() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Contact con = TestUtil.createContact(acc);
        insert con;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c ctrct = TestUtil.createContract(acc.Id, constitution);
        insert ctrct;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        // 確認用の値を設定
        quote.Name = '見積保存メソッドテスト２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApplyerRole__c = '申請者ロール_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApprovalStatus__c = 'applying';
        quote.AssumedWorkContent__c = '想定作業内容_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ClosingMonth__c = 'twoMonthsLater';
        quote.ConstitutionCommon__c = constitution.Id;
        quote.Contract__c = ctrct.Id;
        quote.Deliverables__c = '納品物_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.EndUser__c = acc.Id;
        quote.EstimateOutputDate__c = date.today();
        quote.ExpirationDate__c = '有効期限_';
        quote.IsOrder__c = true;
        quote.Note__c = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.Other__c = 'その他_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.OwnerId = UserInfo.getUserId();

        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;
        Product__c pdct2 = TestUtil.createProducts('tax10', 2000);
        pdct2.Name = 'テスト商品２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct2;

        QuoteDetail__c detail1 = TestUtil.createQuoteDetail(quote);
        detail1.No__c = 1;
        detail1.Remarks__C = '備考1_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail1.LargeType__c = '';
        detail1.Unit__c = 'テスト1';
        detail1.UnitPrice__c = 1000;
        detail1.ProductName__c = pdct1.Id;
        detail1.Quantity__c =10;
        detail1.Amount__c = detail1.UnitPrice__c * detail1.Quantity__c;
        detail1.TaxPrice__c = 0;
        detail1.DetailType__c = 'monthlyCost';
        detail1.TaxType__c = 'noTax';
        QuoteDetail__c detail2 = TestUtil.createQuoteDetail(quote);
        detail2.No__c = 2;
        detail2.Remarks__C = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail2.LargeType__c = 'operation';
        detail2.Unit__c = 'テスト２';
        detail2.UnitPrice__c = 2000;
        detail2.ProductName__c = pdct2.Id;
        detail2.Quantity__c =20;
        detail2.Amount__c = detail2.UnitPrice__c * detail2.Quantity__c;
        detail2.TaxPrice__c = (detail2.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail2.DetailType__c = 'initialCost';
        detail2.TaxType__c = 'tax10';

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ApexPages.currentPage().getParameters().put('cId', constitution.Id);
        ctrl.initAction();
        ctrl.quote.BillAccount__c = acc.Id;

        // 明細追加
        ctrl.addDetail();
        ctrl.details[0].detail.No__c = detail1.No__c ;
        ctrl.details[0].detail.Remarks__C = detail1.Remarks__C;
        ctrl.details[0].detail.LargeType__c = detail1.LargeType__c;
        ctrl.details[0].detail.Unit__c = detail1.Unit__c;
        ctrl.details[0].detail.UnitPrice__c = detail1.UnitPrice__c;
        ctrl.details[0].detail.ProductName__c = detail1.ProductName__c;
        ctrl.details[0].detail.Quantity__c = detail1.Quantity__c;
        ctrl.details[0].detail.Amount__c = detail1.Amount__c;
        ctrl.details[0].detail.TaxPrice__c = detail1.TaxPrice__c;
        ctrl.details[0].detail.DetailType__c = detail1.DetailType__c;
        ctrl.details[0].detail.TaxType__c = detail1.TaxType__c;
        ctrl.details[1].detail.No__c = detail2.No__c ;
        ctrl.details[1].detail.Remarks__C = detail2.Remarks__C;
        ctrl.details[1].detail.LargeType__c = detail2.LargeType__c;
        ctrl.details[1].detail.Unit__c = detail2.Unit__c;
        ctrl.details[1].detail.UnitPrice__c = detail2.UnitPrice__c;
        ctrl.details[1].detail.ProductName__c = detail2.ProductName__c;
        ctrl.details[1].detail.Quantity__c = detail2.Quantity__c;
        ctrl.details[1].detail.Amount__c = detail2.Amount__c;
        ctrl.details[1].detail.TaxPrice__c = detail2.TaxPrice__c;
        ctrl.details[1].detail.DetailType__c = detail2.DetailType__c;
        ctrl.details[1].detail.TaxType__c = detail2.TaxType__c;

        // 保存処理実行
        ctrl.saveAction();
        
        Test.stopTest();

        // 検証用見積データ件数取得
        String qName = quote.Name;
        Integer count = Database.countQuery('SELECT COUNT() FROM Quote__c WHERE Name = :qName ');
        // 検証
        System.assertEquals(count, 1);

        // 検証用見積データ取得
        List<String> selectFields = new List<String>(
            Quote__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        Quote__c checkQuote = Database.query(
            String.format(
                'SELECT {0} FROM Quote__c WHERE Name = :qName LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        // 検証用見積明細データ件数取得
        Id qId = checkQuote.Id;
        Integer countDetail = Database.countQuery('SELECT COUNT() FROM QuoteDetail__c WHERE Quote__c = :qId ');
        // 検証
        System.assertEquals(countDetail, 2);

        // 検証用見積明細データ取得
        List<String> selectDetailFields = new List<String>(
            QuoteDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        List<QuoteDetail__c> checkQuoteDetails = Database.query(
            String.format(
                'SELECT {0} FROM QuoteDetail__c WHERE Quote__c = :qId ORDER BY No__c ASC NULLS LAST '
                , new List<String>{ String.join(selectDetailFields, ', ') }
            )
        );

        // 検証
        // 見積
        System.assertEquals(quote.Name, checkQuote.Name);
        System.assertEquals(quote.ConstitutionCommon__c, checkQuote.ConstitutionCommon__c);
        System.assertEquals(quote.Contract__c, checkQuote.Contract__c);
        System.assertEquals(quote.Deliverables__c, checkQuote.Deliverables__c);
        System.assertEquals(quote.EndUser__c, checkQuote.EndUser__c);
        System.assertEquals(quote.EstimateOutputDate__c, checkQuote.EstimateOutputDate__c);
        System.assertEquals(quote.ExpirationDate__c, checkQuote.ExpirationDate__c);
        System.assertEquals(quote.IsOrder__c, checkQuote.IsOrder__c);
        System.assertEquals(quote.Note__c, checkQuote.Note__c);
        System.assertEquals(quote.Other__c, checkQuote.Other__c);
        System.assertEquals(quote.OwnerId, checkQuote.OwnerId);
        // 見積明細
        System.assertEquals(detail1.No__c, checkQuoteDetails[0].No__c);
        System.assertEquals(detail1.Remarks__c, checkQuoteDetails[0].Remarks__c);
        //System.assertEquals(detail1.LargeType__c, checkQuoteDetails[0].LargeType__c);
        System.assertEquals(detail1.Unit__c, checkQuoteDetails[0].Unit__c);
        System.assertEquals(detail1.UnitPrice__c, checkQuoteDetails[0].UnitPrice__c);
        System.assertEquals(detail1.ProductName__c, checkQuoteDetails[0].ProductName__c);
        System.assertEquals(detail1.Quantity__c, checkQuoteDetails[0].Quantity__c);
        System.assertEquals(detail1.TaxPrice__c, checkQuoteDetails[0].TaxPrice__c);
        System.assertEquals(checkQuote.Id, checkQuoteDetails[0].Quote__c);
        System.assertEquals(detail1.DetailType__c, checkQuoteDetails[0].DetailType__c);
        System.assertEquals(detail1.TaxType__c, checkQuoteDetails[0].TaxType__c);
        System.assertEquals(detail1.Amount__c, checkQuoteDetails[0].Amount__c);
        System.assertEquals(detail2.No__c, checkQuoteDetails[1].No__c);
        System.assertEquals(detail2.Remarks__c, checkQuoteDetails[1].Remarks__c);
        //System.assertEquals(detail2.LargeType__c, checkQuoteDetails[1].LargeType__c);
        System.assertEquals(detail2.Unit__c, checkQuoteDetails[1].Unit__c);
        System.assertEquals(detail2.UnitPrice__c, checkQuoteDetails[1].UnitPrice__c);
        System.assertEquals(detail2.ProductName__c, checkQuoteDetails[1].ProductName__c);
        System.assertEquals(detail2.Quantity__c, checkQuoteDetails[1].Quantity__c);
        System.assertEquals(detail2.TaxPrice__c, checkQuoteDetails[1].TaxPrice__c);
        System.assertEquals(checkQuote.Id, checkQuoteDetails[1].Quote__c);
        System.assertEquals(detail2.DetailType__c, checkQuoteDetails[1].DetailType__c);
        System.assertEquals(detail2.TaxType__c, checkQuoteDetails[1].TaxType__c);
        System.assertEquals(detail2.Amount__c, checkQuoteDetails[1].Amount__c);
    }

    /**
     * 【対象】
     * saveAction
     * 【条件】
     *　入力内容にエラーがない場合で更新、削除
     * 【結果】
     * 入力した内容で見積が更新、削除されていること
     */
    @isTest
    public static void test_saveAction_003() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Contact con = TestUtil.createContact(acc);
        insert con;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c ctrct = TestUtil.createContract(acc.Id, constitution);
        insert ctrct;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        // 確認用の値を設定
        quote.Name = '見積取得メソッドテスト_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApplyerRole__c = '申請者ロール_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApprovalStatus__c = 'unapplied';
        quote.AssumedWorkContent__c = '想定作業内容_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.BillAccount__c = acc.Id;
        quote.BillingContact__c = con.Id;
        quote.ClosingMonth__c = 'twoMonthsLater';
        quote.ConstitutionCommon__c = constitution.Id;
        quote.Contract__c = ctrct.Id;
        quote.Deliverables__c = '納品物_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.EndUser__c = acc.Id;
        quote.EstimateOutputDate__c = date.today();
        quote.ExpirationDate__c = '有効期限_';
        quote.IsOrder__c = true;
        quote.Note__c = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.Other__c = 'その他_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.OwnerId = UserInfo.getUserId();
        quote.QuoteTerm__c = '期間_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.QuoteTodo__c = '見積書発行ToDo_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.QuoteUser__c = UserInfo.getUserId();
        insert quote;

        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;
        Product__c pdct2 = TestUtil.createProducts('tax10', 2000);
        pdct2.Name = 'テスト商品２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct2;
        
        QuoteDetail__c detail1 = TestUtil.createQuoteDetail(quote);
        detail1.No__c = 1;
        detail1.Remarks__C = '備考1_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail1.LargeType__c = '';
        detail1.Unit__c = 'テスト1';
        detail1.UnitPrice__c = 1000;
        detail1.ProductName__c = pdct1.Id;
        detail1.Quantity__c =10;
        detail1.Amount__c = detail1.UnitPrice__c * detail1.Quantity__c;
        detail1.TaxPrice__c = (detail1.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail1.Quote__c = quote.Id;
        detail1.DetailType__c = 'monthlyCost';
        detail1.TaxType__c = 'noTax';
        insert detail1;
        QuoteDetail__c detail2 = TestUtil.createQuoteDetail(quote);
        detail2.No__c = 2;
        detail2.Remarks__C = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail2.LargeType__c = 'operation';
        detail2.Unit__c = 'テスト';
        detail2.UnitPrice__c = 2000;
        detail2.ProductName__c = pdct2.Id;
        detail2.Quantity__c =20;
        detail2.Amount__c = detail2.UnitPrice__c * detail2.Quantity__c;
        detail2.TaxPrice__c = (detail2.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail2.Quote__c = quote.Id;
        detail2.DetailType__c = 'initialCost';
        detail2.TaxType__c = 'tax10';
        insert detail2;
        
        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ctrl.initAction();

        // 見積の名称の先頭に’更新’の文字列を追加
        String afterName = '更新' + ctrl.quote.Name;
        ctrl.quote.Name = afterName;
        
        // 見積明細の備考の戦闘に’更新’の文字列を追加（Noが2のデータを対象）
        String afterRemarks = '更新' + ctrl.details[1].detail.Remarks__C;
        ctrl.details[1].detail.Remarks__C = afterRemarks;

        // 明細削除（Noが１のデータ削除）
        Id delId = ctrl.details[0].detail.Id;
        ctrl.details[0].isSelected = true;
        ctrl.delDetail();

        // 保存処理実行
        ctrl.saveAction();
        
        Test.stopTest();

        // 検証用見積データ取得
        Id qId = quote.Id;
        List<String> selectFields = new List<String>(
            Quote__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        Quote__c checkQuote = Database.query(
            String.format(
                'SELECT {0} FROM Quote__c WHERE Id = :qId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        // 検証用見積明細データ取得
        List<String> selectDetailFields = new List<String>(
            QuoteDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        List<QuoteDetail__c> checkQuoteDetails = Database.query(
            String.format(
                'SELECT {0} FROM QuoteDetail__c WHERE Quote__c = :qId ORDER BY No__c ASC NULLS LAST '
                , new List<String>{ String.join(selectDetailFields, ', ') }
            )
        );

        // 検証用見積明細データ件数取得
        Integer countDelDetail = Database.countQuery('SELECT COUNT() FROM QuoteDetail__c WHERE Id = :delId ');
        // 検証
        

        // 検証
        // 見積
        System.assertEquals(afterName, checkQuote.Name);

        // 見積明細
        System.assertEquals(countDelDetail, 0);
        System.assertEquals(afterRemarks, checkQuoteDetails[0].Remarks__c);

    }





    @isTest
    public static void test_reCalcAction_001() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Contact con = TestUtil.createContact(acc);
        insert con;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c ctrct = TestUtil.createContract(acc.Id, constitution);
        insert ctrct;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        // 確認用の値を設定
        quote.Name = '見積保存メソッドテスト２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApplyerRole__c = '申請者ロール_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ApprovalStatus__c = 'applying';
        quote.AssumedWorkContent__c = '想定作業内容_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.ClosingMonth__c = 'twoMonthsLater';
        quote.ConstitutionCommon__c = constitution.Id;
        quote.Contract__c = ctrct.Id;
        quote.Deliverables__c = '納品物_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.EndUser__c = acc.Id;
        quote.EstimateOutputDate__c = date.today();
        quote.ExpirationDate__c = '有効期限_';
        quote.IsOrder__c = true;
        quote.Note__c = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.Other__c = 'その他_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        quote.OwnerId = UserInfo.getUserId();

        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;
        Product__c pdct2 = TestUtil.createProducts('tax10', 2000);
        pdct2.Name = 'テスト商品２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct2;

        QuoteDetail__c detail1 = TestUtil.createQuoteDetail(quote);
        detail1.No__c = 1;
        detail1.Remarks__C = '備考1_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail1.LargeType__c = '';
        detail1.Unit__c = 'テスト1';
        detail1.UnitPrice__c = 1000;
        detail1.ProductName__c = pdct1.Id;
        detail1.Quantity__c =10;
        detail1.Amount__c = detail1.UnitPrice__c * detail1.Quantity__c;
        detail1.TaxPrice__c = 0;
        detail1.DetailType__c = 'monthlyCost';
        detail1.TaxType__c = 'noTax';
        QuoteDetail__c detail2 = TestUtil.createQuoteDetail(quote);
        detail2.No__c = 2;
        detail2.Remarks__C = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail2.LargeType__c = 'operation';
        detail2.Unit__c = 'テスト２';
        detail2.UnitPrice__c = 2000;
        detail2.ProductName__c = pdct2.Id;
        detail2.Quantity__c =20;
        detail2.Amount__c = detail2.UnitPrice__c * detail2.Quantity__c;
        detail2.TaxPrice__c = (detail2.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail2.DetailType__c = 'initialCost';
        detail2.TaxType__c = 'tax10';

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        QuoteEditController ctrl = new QuoteEditController(stdCtrl);
        ApexPages.currentPage().getParameters().put('cId', constitution.Id);
        ctrl.initAction();
        ctrl.quote.BillAccount__c = acc.Id;

        // 明細追加
        ctrl.addDetail();
        ctrl.details[0].detail.No__c = detail1.No__c ;
        ctrl.details[0].detail.Remarks__C = detail1.Remarks__C;
        ctrl.details[0].detail.LargeType__c = detail1.LargeType__c;
        ctrl.details[0].detail.Unit__c = detail1.Unit__c;
        ctrl.details[0].detail.UnitPrice__c = detail1.UnitPrice__c;
        ctrl.details[0].detail.ProductName__c = detail1.ProductName__c;
        ctrl.details[0].detail.Quantity__c = detail1.Quantity__c;
        ctrl.details[0].detail.Amount__c = detail1.Amount__c;
        ctrl.details[0].detail.TaxPrice__c = detail1.TaxPrice__c;
        ctrl.details[0].detail.DetailType__c = detail1.DetailType__c;
        ctrl.details[0].detail.TaxType__c = detail1.TaxType__c;
        ctrl.details[1].detail.No__c = detail2.No__c ;
        ctrl.details[1].detail.Remarks__C = detail2.Remarks__C;
        ctrl.details[1].detail.LargeType__c = detail2.LargeType__c;
        ctrl.details[1].detail.Unit__c = detail2.Unit__c;
        ctrl.details[1].detail.UnitPrice__c = detail2.UnitPrice__c;
        ctrl.details[1].detail.ProductName__c = detail2.ProductName__c;
        ctrl.details[1].detail.Quantity__c = detail2.Quantity__c;
        ctrl.details[1].detail.Amount__c = detail2.Amount__c;
        ctrl.details[1].detail.TaxPrice__c = detail2.TaxPrice__c;
        ctrl.details[1].detail.DetailType__c = detail2.DetailType__c;
        ctrl.details[1].detail.TaxType__c = detail2.TaxType__c;

        // 再計算処理実行
        ctrl.reCalcAction();
        
        Test.stopTest();
    }

}