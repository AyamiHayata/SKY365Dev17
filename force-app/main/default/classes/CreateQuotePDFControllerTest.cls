/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 見積書作成コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/16          XXXXXXX          New
 ********************************************************************************/
@isTest
private class CreateQuotePDFControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
        
        // データ準備
        Account acc = TestUtil.createAccount();
        acc.BillingPostalCode = '111-2222';
        acc.BillingCountry = 'Japan';
        acc.BillingStreet = '12345';
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

    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * なし
     * 【結果】
     * 見積、見積明細データが取得できること・請求先住所、Sky365様会社情報が取得できること
     */
    @isTest
    public static void test_initAction_001() {

        Quote__c quoteData = [SELECT Id, ApprovalStatus__c, BillAccount__r.BillingAddress FROM Quote__c LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateQuotePDFController target = new CreateQuotePDFController(stdCtrl);

        quoteData.ApprovalStatus__c = 'Approved';
        update quoteData;

        // テスト開始
        Test.startTest();

        target.initAction();

        Test.stopTest();

        // 検証

        // 見積、見積明細
        System.assertEquals(quoteData.Id, target.quote.Id);
        System.assertEquals(2, target.quoteDetail.size());

        // 請求先住所
        Address addBillAccount = quoteData.BillAccount__r.BillingAddress;
        System.assertEquals(Label.COMMON_PDF_POST_MARK + addBillAccount.getPostalCode(), target.billPostalCode);
        System.assertEquals(addBillAccount.getState() + addBillAccount.getCity(), target.billAddress);
        System.assertEquals(addBillAccount.getStreet(), target.billAddress2);
        
        // Sky365様会社情報
        Organization org = CommonUtil.getOrganizationInfo();
        Address addOrganization = org.Address;
        System.assertEquals(Label.COMMON_PDF_POST_MARK + addOrganization.getPostalCode(), target.deptPostalCode);
        System.assertEquals(addOrganization.getState() + addOrganization.getCity(), target.deptAddress);
        System.assertEquals(addOrganization.getStreet(), target.deptAddress2);
        System.assertEquals(Label.COMMON_PDF_TELL + org.Phone, target.deptTel);
    
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 見積発行日が未設定
     * 【結果】
     * 見積発行日が当日に設定されること
     */
    @isTest
    public static void test_initAction_002() {

        Quote__c quoteData = [SELECT Id, EstimateOutputDate__c, ApprovalStatus__c FROM Quote__c LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateQuotePDFController target = new CreateQuotePDFController(stdCtrl);

        quoteData.EstimateOutputDate__c = null;
        quoteData.ApprovalStatus__c = 'Approved';
        update quoteData;

        // テスト開始
        Test.startTest();

        target.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(date.today(), target.quote.EstimateOutputDate__c);
    
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 備考、想定作業内容、納品物に改行が含まれている・1行の文字数が１１８文字を超えている・未設定
     * 【結果】
     * 改行で分割され、Listとして取得できること・項目の改行の数がそれぞれの最大数で設定されていること・最大数を超えた場合、切り捨てられること。
     */
    @isTest
    public static void test_initAction_003() {

        Quote__c quoteData = [SELECT Id, Note__c, AssumedWorkContent__c, Deliverables__c, ApprovalStatus__c FROM Quote__c LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateQuotePDFController target = new CreateQuotePDFController(stdCtrl);

        quoteData.Note__c = 'あいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ';
        quoteData.AssumedWorkContent__c = 'あいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ';
        quoteData.Deliverables__c = 'あいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ';
        quoteData.ApprovalStatus__c = 'Approved';
        update quoteData;

        // テスト開始
        Test.startTest();

        target.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(5, target.noteList.size());
        System.assertEquals(32, target.assumedWorkContentList.size());
        System.assertEquals(3, target.deliverablesList.size());
    
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 明細の行数が改ページ行数-1の数
     * 【結果】
     * 明細が改ページされずに１ページ目に収まっている
     */
    @isTest
    public static void test_initAction_004() {

        Quote__c quoteData = [SELECT Id, ApprovalStatus__c FROM Quote__c LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateQuotePDFController target = new CreateQuotePDFController(stdCtrl);

        quoteData.ApprovalStatus__c = 'Approved';
        update quoteData;

        makeDetailTestData(quoteData, false);

        // テスト開始
        Test.startTest();

        target.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(1, target.quoteDetailPage.size());

    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 明細の行数が改ページ行数の数
     * 【結果】
     * 明細が改ページされて２ページ目に出力されている
     */
    @isTest
    public static void test_initAction_005() {

        Quote__c quoteData = [SELECT Id, ApprovalStatus__c FROM Quote__c LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateQuotePDFController target = new CreateQuotePDFController(stdCtrl);

        quoteData.ApprovalStatus__c = 'Approved';
        update quoteData;

        makeDetailTestData(quoteData, true);

        // テスト開始
        Test.startTest();

        target.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(2, target.quoteDetailPage.size());

    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 明細がない場合
     * 【結果】
     * 明細がなくても明細ページは設定されること
     */
    @isTest
    public static void test_initAction_006() {

        Quote__c quoteData = [SELECT Id, ApprovalStatus__c FROM Quote__c LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateQuotePDFController target = new CreateQuotePDFController(stdCtrl);

        quoteData.ApprovalStatus__c = 'Approved';
        update quoteData;

        List<QuoteDetail__c> qdetailList = [SELECT Id FROM QuoteDetail__c WHERE Quote__c =: quoteData.Id];
        delete qdetailList;

        // テスト開始
        Test.startTest();

        target.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(1, target.quoteDetailPage.size());

    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 備考、想定作業内容、想定作業内容追記、納品物に改行が含まれている・1行の文字数が１１８文字を超えている・未設定
     * 【結果】
     * 改行で分割され、Listとして取得できること・項目の改行の数がそれぞれの最大数で設定されていること・最大数を超えた場合、切り捨てられること。
     */
    @isTest
    public static void test_initAction_007() {

        Quote__c quoteData = [SELECT Id, Note__c, AssumedWorkContent__c, Deliverables__c, ApprovalStatus__c FROM Quote__c LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateQuotePDFController target = new CreateQuotePDFController(stdCtrl);

        quoteData.Note__c = 'あいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ';
        quoteData.AssumedWorkContent__c = 'あいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ';
        quoteData.AssumedWorkContentAdd__c = 'あいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ';
        quoteData.Deliverables__c = 'あいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ\r\nあいうえおかきくけこ';
        quoteData.ApprovalStatus__c = 'Approved';
        update quoteData;

        // テスト開始
        Test.startTest();

        target.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(5, target.noteList.size());
        System.assertEquals(32, target.assumedWorkContentList.size());
        System.assertEquals(3, target.deliverablesList.size());
    
    }



    /**
     * 【対象】
     * getStampFilePath
     * 【条件】
     * 60文字以上の場合
     * 【結果】
     * 改行されること
     */
    @isTest
    public static void test_getStampFilePath() {

        User user = [SELECT Id, StampFilePath__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        user.StampFilePath__c = 'test.txt';
        update user;

        Quote__c quoteData = [SELECT Id, ApprovalStatus__c FROM Quote__c LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateQuotePDFController target = new CreateQuotePDFController(stdCtrl);

        // テスト開始
        Test.startTest();

        String  stampFilePath = target.getStampFilePath(user.Id);

        Test.stopTest();

        // 検証
        System.assertEquals(user.StampFilePath__c, stampFilePath);
    }

    public static void makeDetailTestData(Quote__c quote, Boolean isOver){

        List<Product__c> lPdct = new List<Product__c>();
        List<QuoteDetail__c> lDetail = new List<QuoteDetail__c>();

        Integer count =10;
        if (isOver)
        {
            count++;
        }

        for(Integer idx = 0; idx <= count; idx++){
            Product__c pdct = TestUtil.createProducts('noTax', 1000);
            pdct.Name = '改ページテスト商品_' + (idx+1);
            lPdct.add(pdct);
        }
        insert lPdct;

        for(Integer idx = 0; idx <= count; idx++){
            QuoteDetail__c detail = TestUtil.createQuoteDetail(quote);
            detail.No__c = (idx+1);
            detail.Remarks__C = '備考' + (idx+1);
            detail.LargeType__c = 'operation';
            detail.Unit__c = 'テスト';
            detail.UnitPrice__c = 2000;
            detail.ProductName__c = lPdct[idx].Id;
            detail.Quantity__c =20;
            detail.Amount__c = detail.UnitPrice__c * detail.Quantity__c;
            detail.TaxPrice__c = (detail.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
            detail.Quote__c = quote.Id;
            detail.DetailType__c = 'initialCost';
            detail.TaxType__c = 'tax10';
            lDetail.add(detail);
        }
        insert lDetail;

    }

}