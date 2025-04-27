/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約編集コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/07/19          R.Matsui          New
 ********************************************************************************/
@isTest
 private class BillingEditControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる

    }
    /**
     * 【対象】
     * initAction、getBilling、getBillingDetails
     * 【条件】
     * 編集の場合
     * 【結果】
     * 登録済みの請求明細が表示されていること
     * Noの並び順で一覧が表示されること
     */
    @isTest
    public static void test_initAction_001(){

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

        // 商品マスタ
        Product__c product = TestUtil.createProducts(Constants.TAX_TYPE_NO_TAX,10000);
        product.LargeType__c = 'operation';
        product.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        product.Unit__c = 'shiki';
        insert product;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        // 確認用の値を設定
        bill.Contract__c = contract.Id;
        bill.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        bill.Name = 'UT試験請求名称';
        // bill.Remarks__c = 'UT請求備考入力値';
        bill.DetailType__c = 'initialCost';
        insert bill;

        // 請求明細
        List<BillingDetail__c> insertBillDt= new List<BillingDetail__c>();
        BillingDetail__c billDtl = createBillingDetail(bill);
        // 確認用の値を設定
        billDtl.ProductName__c = product.Id;
        billDtl.No__c = 1;
        billDtl.Remarks__c = 'UT請求明細備考入力値1';
        billDtl.LargeType__c = 'outsourcing';
        billDtl.Unit__c ='台';
        billDtl.UnitPrice__c =5000;
        billDtl.ProductNameText__c = 'テスト商品';
        billDtl.Quantity__c = 2;
        billDtl.TaxPrice__c = 0;
        billDtl.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        billDtl.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDtl.Amount__c = 10000;

        BillingDetail__c billDt2 = createBillingDetail(bill);
        // 確認用の値を設定
        billDt2.ProductName__c = product.Id;
        billDt2.No__c = 2;
        billDt2.Remarks__c = 'UT請求明細備考入力値2';
        billDt2.LargeType__c = 'operation';
        billDt2.Unit__c ='台';
        billDt2.UnitPrice__c =5000;
        billDt2.ProductNameText__c = 'テスト商品';
        billDt2.Quantity__c = 3;
        billDt2.TaxPrice__c = 0;
        billDt2.DetailType__c = 'initialCost';
        billDt2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDt2.Amount__c = 15000;

        BillingDetail__c billDt3 = createBillingDetail(bill);
        // 確認用の値を設定
        billDt3.ProductName__c = product.Id;
        billDt3.No__c = 4;
        billDt3.Remarks__c = 'UT請求明細備考入力値4';
        billDt3.LargeType__c = 'operation';
        billDt3.Unit__c ='台';
        billDt3.UnitPrice__c =5000;
        billDt3.ProductNameText__c = 'テスト商品';
        billDt3.Quantity__c = 3;
        billDt3.TaxPrice__c = 0;
        billDt3.DetailType__c = 'initialCost';
        billDt3.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDt3.Amount__c = 15000;

        BillingDetail__c billDt4 = createBillingDetail(bill);
        // 確認用の値を設定
        billDt4.ProductName__c = product.Id;
        billDt4.No__c = 3;
        billDt4.Remarks__c = 'UT請求明細備考入力値3';
        billDt4.LargeType__c = 'operation';
        billDt4.Unit__c ='台';
        billDt4.UnitPrice__c =5000;
        billDt4.ProductNameText__c = 'テスト商品';
        billDt4.Quantity__c = 3;
        billDt4.TaxPrice__c = 0;
        billDt4.DetailType__c = 'initialCost';
        billDt4.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDt4.Amount__c = 15000;

        insertBillDt.add(billDtl);
        insertBillDt.add(billDt2);
        insertBillDt.add(billDt3);
        insertBillDt.add(billDt4);

        insert insertBillDt;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.initAction();
        
        Test.stopTest();

        // 請求
        ID bId = bill.Id;
        List<String> selectFields = new List<String>(
            Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        Billing__c checkBill = Database.query(
            String.format(
                'SELECT {0} FROM Billing__c WHERE Id = :bId LIMIT 1'
                , new List<String>{ String.join(selectFields,', ')}
            )
        );

        // 請求明細
        ID bdId = checkBill.Id;
        List<String> selectDetailFields = new List<String>(
            BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        List<BillingDetail__c> checkBillDetailList = Database.query(
            String.format(
                'SELECT {0} FROM BillingDetail__c WHERE Billing__c = :bdId ORDER BY No__c ASC NULLS LAST '
                , new List<String>{ String.join(selectDetailFields,', ')}
            )
        );

        // 検証
        // 請求
        system.assertEquals(bill.Contract__c,checkBill.Contract__c);
        system.assertEquals(bill.TaxType__c,checkBill.TaxType__c);
        system.assertEquals(bill.Name,checkBill.Name);
        // system.assertEquals(bill.Remarks__c,checkBill.Remarks__c);
        system.assertEquals(bill.DetailType__c,checkBill.DetailType__c);

        // 請求明細
        System.assertEquals(ctrl.details[0].detail.ProductName__c,billDtl.ProductName__c);
        System.assertEquals(ctrl.details[0].detail.No__c,billDtl.No__c);
        System.assertEquals(ctrl.details[0].detail.Remarks__c,billDtl.Remarks__c);
        System.assertEquals(ctrl.details[0].detail.LargeType__c,billDtl.LargeType__c);
        System.assertEquals(ctrl.details[0].detail.Unit__c,billDtl.Unit__c);
        System.assertEquals(ctrl.details[0].detail.UnitPrice__c,billDtl.UnitPrice__c);
        System.assertEquals(ctrl.details[0].detail.ProductName__c,billDtl.ProductName__c);
        System.assertEquals(ctrl.details[0].detail.ProductNameText__c,billDtl.ProductNameText__c);
        System.assertEquals(ctrl.details[0].detail.Quantity__c,billDtl.Quantity__c);
        System.assertEquals(ctrl.details[0].detail.TaxPrice__c,billDtl.TaxPrice__c);
        System.assertEquals(ctrl.details[0].detail.DetailType__c,billDtl.DetailType__c);
        System.assertEquals(ctrl.details[0].detail.TaxType__c,billDtl.TaxType__c);
        System.assertEquals(ctrl.details[0].detail.Amount__c,billDtl.Amount__c);
        System.assertEquals(ctrl.details[1].detail.ProductName__c,billDt2.ProductName__c);
        System.assertEquals(ctrl.details[1].detail.No__c,billDt2.No__c);
        System.assertEquals(ctrl.details[1].detail.Remarks__c,billDt2.Remarks__c);
        System.assertEquals(ctrl.details[1].detail.LargeType__c,billDt2.LargeType__c);
        System.assertEquals(ctrl.details[1].detail.Unit__c,billDt2.Unit__c);
        System.assertEquals(ctrl.details[1].detail.UnitPrice__c,billDt2.UnitPrice__c);
        System.assertEquals(ctrl.details[1].detail.ProductName__c,billDt2.ProductName__c);
        System.assertEquals(ctrl.details[1].detail.ProductNameText__c,billDt2.ProductNameText__c);
        System.assertEquals(ctrl.details[1].detail.Quantity__c,billDt2.Quantity__c);
        System.assertEquals(ctrl.details[1].detail.TaxPrice__c,billDt2.TaxPrice__c);
        System.assertEquals(ctrl.details[1].detail.DetailType__c,billDt2.DetailType__c);
        System.assertEquals(ctrl.details[1].detail.TaxType__c,billDt2.TaxType__c);
        System.assertEquals(ctrl.details[1].detail.Amount__c,billDt2.Amount__c);

        // 検証(Noの並び順で一覧が表示されること)
        System.assertEquals(ctrl.details[2].detail.ProductName__c,billDt4.ProductName__c);
        System.assertEquals(ctrl.details[2].detail.No__c,billDt4.No__c);
        System.assertEquals(ctrl.details[2].detail.Remarks__c,billDt4.Remarks__c);
        System.assertEquals(ctrl.details[2].detail.LargeType__c,billDt4.LargeType__c);
        System.assertEquals(ctrl.details[2].detail.Unit__c,billDt4.Unit__c);
        System.assertEquals(ctrl.details[2].detail.UnitPrice__c,billDt4.UnitPrice__c);
        System.assertEquals(ctrl.details[2].detail.ProductName__c,billDt4.ProductName__c);
        System.assertEquals(ctrl.details[2].detail.ProductNameText__c,billDt4.ProductNameText__c);
        System.assertEquals(ctrl.details[2].detail.Quantity__c,billDt4.Quantity__c);
        System.assertEquals(ctrl.details[2].detail.TaxPrice__c,billDt4.TaxPrice__c);
        System.assertEquals(ctrl.details[2].detail.DetailType__c,billDt4.DetailType__c);
        System.assertEquals(ctrl.details[2].detail.TaxType__c,billDt4.TaxType__c);
        System.assertEquals(ctrl.details[2].detail.Amount__c,billDt4.Amount__c);
        System.assertEquals(ctrl.details[3].detail.ProductName__c,billDt3.ProductName__c);
        System.assertEquals(ctrl.details[3].detail.No__c,billDt3.No__c);
        System.assertEquals(ctrl.details[3].detail.Remarks__c,billDt3.Remarks__c);
        System.assertEquals(ctrl.details[3].detail.LargeType__c,billDt3.LargeType__c);
        System.assertEquals(ctrl.details[3].detail.Unit__c,billDt3.Unit__c);
        System.assertEquals(ctrl.details[3].detail.UnitPrice__c,billDt3.UnitPrice__c);
        System.assertEquals(ctrl.details[3].detail.ProductName__c,billDt3.ProductName__c);
        System.assertEquals(ctrl.details[3].detail.ProductNameText__c,billDt3.ProductNameText__c);
        System.assertEquals(ctrl.details[3].detail.Quantity__c,billDt3.Quantity__c);
        System.assertEquals(ctrl.details[3].detail.TaxPrice__c,billDt3.TaxPrice__c);
        System.assertEquals(ctrl.details[3].detail.DetailType__c,billDt3.DetailType__c);
        System.assertEquals(ctrl.details[3].detail.TaxType__c,billDt2.TaxType__c);
        System.assertEquals(ctrl.details[3].detail.Amount__c,billDt3.Amount__c);
    }

    /**
     * 【対象】
     * initAction、getBilling、getBillingDetails
     * 【条件】
     * コピーの場合
     * 【結果】
     * 請求、請求明細が複製されること
     */
    @isTest
    public static void test_initAction_002(){
        
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

        // 商品マスタ
        Product__c product = TestUtil.createProducts(Constants.TAX_TYPE_NO_TAX,10000);
        product.LargeType__c = 'operation';
        product.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        product.Unit__c = 'shiki';
        insert product;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        // 確認用の値を設定
        bill.Contract__c = contract.Id;
        bill.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        bill.Name = 'UT試験請求名称';
        // bill.Remarks__c = 'UT請求備考入力値';
        bill.DetailType__c = 'initialCost';
        insert bill;
        
        // 請求明細
        List<BillingDetail__c> insertBillDt= new List<BillingDetail__c>();
        BillingDetail__c billDtl = createBillingDetail(bill);
        // 確認用の値を設定
        billDtl.ProductName__c = product.Id;
        billDtl.No__c = 1;
        billDtl.Remarks__c = 'UT請求明細備考入力値1';
        billDtl.LargeType__c = 'outsourcing';
        billDtl.Unit__c ='台';
        billDtl.UnitPrice__c =5000;
        billDtl.ProductNameText__c = 'テスト商品';
        billDtl.Quantity__c = 2;
        billDtl.TaxPrice__c = 0;
        billDtl.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        billDtl.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDtl.Amount__c = 10000;

        BillingDetail__c billDt2 = createBillingDetail(bill);
        // 確認用の値を設定
        billDt2.ProductName__c = product.Id;
        billDt2.No__c = 2;
        billDt2.Remarks__c = 'UT請求明細備考入力値2';
        billDt2.LargeType__c = 'operation';
        billDt2.Unit__c ='台';
        billDt2.UnitPrice__c =5000;
        billDt2.ProductNameText__c = 'テスト商品';
        billDt2.Quantity__c = 3;
        billDt2.TaxPrice__c = 0;
        billDt2.DetailType__c = 'initialCost';
        billDt2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDt2.Amount__c = 15000;

        insertBillDt.add(billDtl);
        insertBillDt.add(billDt2);

        insert insertBillDt;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        // コピーパラメータ設定
        ApexPages.currentPage().getParameters().put('clone','1');

        ctrl.initAction();
        
        Test.stopTest();

        // 請求
        ID bId = bill.Id;
        List<String> selectFields = new List<String>(
            Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        Billing__c checkBill = Database.query(
            String.format(
                'SELECT {0} FROM Billing__c WHERE Id = :bId LIMIT 1'
                , new List<String>{ String.join(selectFields,', ')}
            )
        );

        // 請求明細
        ID bdId = checkBill.Id;
        List<String> selectDetailFields = new List<String>(
            BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        List<BillingDetail__c> checkBillDetailList = Database.query(
            String.format(
                'SELECT {0} FROM BillingDetail__c WHERE Billing__c = :bdId ORDER BY No__c ASC NULLS LAST '
                , new List<String>{ String.join(selectDetailFields,', ')}
            )
        );

        // 検証
        // 請求
        system.assertEquals(bill.Contract__c,checkBill.Contract__c);
        system.assertEquals(bill.TaxType__c,checkBill.TaxType__c);
        system.assertEquals(bill.Name,checkBill.Name);
        // system.assertEquals(bill.Remarks__c,checkBill.Remarks__c);
        system.assertEquals(bill.DetailType__c,checkBill.DetailType__c);

        // 請求明細
        System.assertEquals(ctrl.details[0].detail.ProductName__c,billDtl.ProductName__c);
        System.assertEquals(ctrl.details[0].detail.No__c,billDtl.No__c);
        System.assertEquals(ctrl.details[0].detail.Remarks__c,billDtl.Remarks__c);
        System.assertEquals(ctrl.details[0].detail.LargeType__c,billDtl.LargeType__c);
        System.assertEquals(ctrl.details[0].detail.Unit__c,billDtl.Unit__c);
        System.assertEquals(ctrl.details[0].detail.UnitPrice__c,billDtl.UnitPrice__c);
        System.assertEquals(ctrl.details[0].detail.ProductName__c,billDtl.ProductName__c);
        System.assertEquals(ctrl.details[0].detail.ProductNameText__c,billDtl.ProductNameText__c);
        System.assertEquals(ctrl.details[0].detail.Quantity__c,billDtl.Quantity__c);
        System.assertEquals(ctrl.details[0].detail.TaxPrice__c,billDtl.TaxPrice__c);
        System.assertEquals(ctrl.details[0].detail.DetailType__c,billDtl.DetailType__c);
        System.assertEquals(ctrl.details[0].detail.TaxType__c,billDtl.TaxType__c);
        System.assertEquals(ctrl.details[0].detail.Amount__c,billDtl.Amount__c);
        System.assertEquals(ctrl.details[1].detail.ProductName__c,billDt2.ProductName__c);
        System.assertEquals(ctrl.details[1].detail.No__c,billDt2.No__c);
        System.assertEquals(ctrl.details[1].detail.Remarks__c,billDt2.Remarks__c);
        System.assertEquals(ctrl.details[1].detail.LargeType__c,billDt2.LargeType__c);
        System.assertEquals(ctrl.details[1].detail.Unit__c,billDt2.Unit__c);
        System.assertEquals(ctrl.details[1].detail.UnitPrice__c,billDt2.UnitPrice__c);
        System.assertEquals(ctrl.details[1].detail.ProductName__c,billDt2.ProductName__c);
        System.assertEquals(ctrl.details[1].detail.ProductNameText__c,billDt2.ProductNameText__c);
        System.assertEquals(ctrl.details[1].detail.Quantity__c,billDt2.Quantity__c);
        System.assertEquals(ctrl.details[1].detail.TaxPrice__c,billDt2.TaxPrice__c);
        System.assertEquals(ctrl.details[1].detail.DetailType__c,billDt2.DetailType__c);
        System.assertEquals(ctrl.details[1].detail.TaxType__c,billDt2.TaxType__c);
        System.assertEquals(ctrl.details[1].detail.Amount__c,billDt2.Amount__c);

        // 請求明細がコピーであることを確認
        System.assertEquals((ctrl.details[0].detail.Billing__c == null)
                            &&(ctrl.details[1].detail.Billing__c == null), true);
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 新規の場合
     * 【結果】
     * 請求明細が1件追加された状態であること
     */
    @isTest
    public static void test_initAction_003(){
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
        Billing__c bill = createNewBilling();

        // テスト開始
        Test.startTest();

        Boolean result = true;
        
        try{
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
            BillingEditController ctrl = new BillingEditController(stdCtrl);
            ctrl.initAction();
        } catch(Exception e) {
            System.debug(e);
            result = false;
        }    
        
        Test.stopTest();

        // 検証
        System.assertEquals(true, result);
    }

     /**
     * 【対象】
     * addDetail
     * 【結果】
     * 明細に行が追加されること
     */
    @isTest
    public static void test_addDetail(){
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

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.addDetail();

        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.details.size(),1);        
    }

     /**
     * 【対象】
     * delDetail
     * 【条件】
     * 登録済みレコードではないこと
     * 【結果】
     * 明細の行が削除されること
     * 削除用リストに追加がされないこと ※確認不可
     */
    @isTest
    public static void test_delDetail_001(){
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

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.addDetail();
        ctrl.addDetail();
        ctrl.addDetail();

        // 削除対象確認用に配列各要素のBillingDetail__c.No__cに番号を設定
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
        /*
         * 削除用レコードに追加されないこと(privateでgetterなしのため確認不可)
         *System.assertEquals(ctrl.delDetailIds.size(), 0);
         */
    }

    /**
     * 【対象】
     * delDetail
     * 【条件】
     * 登録済みレコードであること
     * 【結果】
     * 明細の行が削除されること
     * 削除用リストに追加されること ※確認不可
     */
    @isTest
    public static void test_delDetail_002(){
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

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.initAction();
        ctrl.addDetail();
        ctrl.addDetail();

        // 削除対象確認用に配列各要素のBillingDetail__c.No__cに番号を設定
        ctrl.details[1].detail.No__c = 2;
        ctrl.details[2].detail.No__c = 3;

        // １行目と２行目の明細を削除する
        ctrl.details[0].isSelected = true;
        ctrl.details[2].isSelected = true;
        ctrl.delDetail();

        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.details.size(),1);
        System.assertEquals(ctrl.details[0].detail.No__c,2);
        /**
         * 削除用レコードに追加されていること(privateでgetterなしのため確認不可)
         *System.assertEquals(ctrl.delDetailIds.size(), 1);
         */
    }

     /**
     * 【対象】
     * changeProduct、changePrice
     * 【条件】
     * 税率が「非課税」、変更した商品の情報が存在する
     * 【結果】
     * 消費税額が0であること
     * 明細に商品の情報が設定されていること
     */
    @isTest
    public static void test_changeProduct_001(){
        // データ用意

        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 商品マスタ
        Product__c product = TestUtil.createProducts(Constants.TAX_TYPE_NO_TAX,10000);
        product.LargeType__c = 'operation';
        product.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        product.Unit__c = 'shiki';
        insert product;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(bill);
        billDtl.ProductName__c = product.Id;
        insert billDtl;

        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.addDetail();

        // 明細の商品の値を設定する
        ctrl.details[0].detail.ProductName__c = product.Id;
        ctrl.targetIndex = 0;

        ctrl.changeProduct();

        Test.stopTest();

        // 明細行に単位や単価を設定
        Product__c checkProduct = [SELECT Id, Name, toLabel(Unit__c), UnitPrice__c, TaxType__c, AssumedWorkContent__c, LargeType__c, DetailType__c From Product__c WHERE Id = :product.Id];

        // 検証
        System.assertEquals(ctrl.details[0].detail.LargeType__c,checkProduct.LargeType__c);
        System.assertEquals(ctrl.details[0].detail.DetailType__c,checkProduct.DetailType__c);
        System.assertEquals(ctrl.details[0].detail.Unit__c,checkProduct.Unit__c);
        System.assertEquals(ctrl.details[0].detail.UnitPrice__c,checkProduct.UnitPrice__c);
        System.assertEquals(ctrl.details[0].detail.TaxType__c,checkProduct.TaxType__c);
        System.assertEquals(ctrl.details[0].detail.ProductNameText__c,'テスト商品');
        System.assertEquals(ctrl.details[0].detail.Amount__c,10000);
        System.assertEquals(ctrl.details[0].detail.TaxPrice__c,0);
    }


     /**
     * 【対象】
     * changeProduct、changePrice
     * 【条件】
     * 税率が「課税10%」、変更した商品の情報が存在する
     * 【結果】
     * 消費税額が10%で計算されること
     * 明細に商品の情報が設定されていること
     */
    @isTest
    public static void test_changeProduct_002(){
        // データ用意

        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 商品マスタ
        Product__c product = TestUtil.createProducts(Constants.TAX_TYPE_10,20000);
        product.LargeType__c = 'operation';
        product.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        product.Unit__c = 'shiki';
        insert product;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(bill);
        billDtl.ProductName__c = product.Id;
        insert billDtl;

        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.addDetail();

        // 明細の商品の値を設定する
        ctrl.details[0].detail.ProductName__c = product.Id;
        ctrl.targetIndex = 0;

        ctrl.changeProduct();

        Test.stopTest();

        // 明細行に単位や単価を設定
        Product__c checkProduct = [SELECT Id, Name, toLabel(Unit__c), UnitPrice__c, TaxType__c, AssumedWorkContent__c, LargeType__c, DetailType__c From Product__c WHERE Id = :product.Id];

        // 検証
        System.assertEquals(ctrl.details[0].detail.LargeType__c,checkProduct.LargeType__c);
        System.assertEquals(ctrl.details[0].detail.DetailType__c,checkProduct.DetailType__c);
        System.assertEquals(ctrl.details[0].detail.Unit__c,checkProduct.Unit__c);
        System.assertEquals(ctrl.details[0].detail.UnitPrice__c,checkProduct.UnitPrice__c);
        System.assertEquals(ctrl.details[0].detail.TaxType__c,checkProduct.TaxType__c);
        System.assertEquals(ctrl.details[0].detail.ProductNameText__c,'テスト商品');
        System.assertEquals(ctrl.details[0].detail.Amount__c,20000);
        System.assertEquals(ctrl.details[0].detail.TaxPrice__c,2000);
    }

    /**
     * 【対象】
     * changePrice
     * 【条件】
     * 税率が「課税10%」、複数行存在する
     * 【結果】
     * 変更した請求明細の消費税、金額が再計算されること
     */
    @isTest
    public static void test_changePrice(){
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

        // 商品マスタ
        Product__c product = TestUtil.createProducts(Constants.TAX_TYPE_NO_TAX,10000);
        product.LargeType__c = 'operation';
        product.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        product.Unit__c = 'shiki';
        insert product;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
    
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        // 確認用の値を設定
        bill.Contract__c = contract.Id;
        bill.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        bill.Name = 'UT試験請求名称';
        // bill.Remarks__c = 'UT請求備考入力値';
        bill.DetailType__c = 'initialCost';
        insert bill;
        
        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(bill);
        // 確認用の値を設定
        billDtl.ProductName__c = product.Id;
        billDtl.No__c = 1;
        billDtl.Remarks__c = 'UT請求明細備考入力値1';
        billDtl.LargeType__c = 'outsourcing';
        billDtl.Unit__c ='台';
        billDtl.UnitPrice__c =5000;
        billDtl.ProductNameText__c = 'テスト商品';
        billDtl.Quantity__c = 2;
        billDtl.TaxPrice__c = 0;
        billDtl.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        billDtl.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDtl.Amount__c = 10000;

        BillingDetail__c billDt2 = createBillingDetail(bill);
        // 確認用の値を設定
        billDt2.ProductName__c = product.Id;
        billDt2.No__c = 2;
        billDt2.Remarks__c = 'UT請求明細備考入力値2';
        billDt2.LargeType__c = 'operation';
        billDt2.Unit__c ='台';
        billDt2.UnitPrice__c =5000;
        billDt2.ProductNameText__c = 'テスト商品';
        billDt2.Quantity__c = 3;
        billDt2.TaxPrice__c = 0;
        billDt2.DetailType__c = 'initialCost';
        billDt2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDt2.Amount__c = 15000;
        
        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.addDetail();
        ctrl.addDetail();

        ctrl.details[0].detail = billDtl;
        ctrl.details[1].detail = billDt2;
        ctrl.targetIndex = 0;
        // 数量、金額、税率を変更
        ctrl.details[0].detail.UnitPrice__c = 3000;
        ctrl.details[0].detail.Quantity__c = 5;
        ctrl.details[0].detail.TaxType__c = Constants.TAX_TYPE_10;

        ctrl.changePrice();
        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.details[0].detail.Amount__c, 3000*5);
        System.assertEquals(ctrl.details[0].detail.TaxPrice__c, 3000*5*0.1);
        System.assertEquals(ctrl.details[0].detail.Amount__c, 15000);
    }

    /**
     * 【対象】
     * saveAction、getSaveCheckResult、calcAmountAll、validate
     * 【結果】
     * 入力した内容で請求明細が登録されること
     */ 
    @isTest
    public static void test_saveAction_001(){
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

        // 商品マスタ
        Product__c product = TestUtil.createProducts(Constants.TAX_TYPE_NO_TAX,10000);
        product.LargeType__c = 'operation';
        product.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        product.Unit__c = 'shiki';
        insert product;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(bill);
        billDtl.ProductName__c = product.Id;
        billDtl.No__c = 1;
        billDtl.Remarks__c = '単体テスト';
        billDtl.LargeType__c = 'operation';
        billDtl.Unit__c ='台';
        billDtl.UnitPrice__c =5000;
        billDtl.ProductNameText__c = 'テスト商品';
        billDtl.Quantity__c = 2;
        billDtl.TaxPrice__c = 0;
        billDtl.DetailType__c = 'initialCost';
        billDtl.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDtl.Amount__c = 10000;

        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.initAction();

        // 登録用データを入力内容に設定
        ctrl.addDetail();
        ctrl.details[0].detail.No__c = billDtl.No__c;
        ctrl.details[0].detail.LargeType__c = billDtl.LargeType__c;
        ctrl.details[0].detail.ProductName__c = billDtl.ProductName__c;
        ctrl.details[0].detail.ProductNameText__c = billDtl.ProductNameText__c;
        ctrl.details[0].detail.DetailType__c = billDtl.DetailType__c;
        ctrl.details[0].detail.UnitPrice__c = billDtl.UnitPrice__c;
        ctrl.details[0].detail.Quantity__c = billDtl.Quantity__c;
        ctrl.details[0].detail.Unit__c = billDtl.Unit__c;
        ctrl.details[0].detail.Amount__c = billDtl.Amount__c;
        ctrl.details[0].detail.TaxType__c = billDtl.TaxType__c;
        ctrl.details[0].detail.TaxPrice__c = billDtl.TaxPrice__c;
        ctrl.details[0].detail.Remarks__c = billDtl.Remarks__c;

        // 保存処理実行
        ctrl.saveAction();

        Test.stopTest();

        // 検証用請求明細データ取得
        List<String> selectDetailFields = new List<String>(
            BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        ID bId = bill.Id;
        List<BillingDetail__c> checkBillDtList = Database.Query(
            String.format(
                'SELECT {0} FROM BillingDetail__c WHERE Billing__c = :bId',
                new List<String>{String.join(selectDetailFields,', ')}
            )
        );
        // 検証
        // 請求明細
        System.assertEquals(checkBillDtList.get(0).No__c,billDtl.No__c);
        System.assertEquals(checkBillDtList.get(0).LargeType__c,billDtl.LargeType__c);
        System.assertEquals(checkBillDtList.get(0).ProductName__c,billDtl.ProductName__c);
        System.assertEquals(checkBillDtList.get(0).ProductNameText__c,billDtl.ProductNameText__c);
        System.assertEquals(checkBillDtList.get(0).DetailType__c,billDtl.DetailType__c);
        System.assertEquals(checkBillDtList.get(0).UnitPrice__c,billDtl.UnitPrice__c);
        System.assertEquals(checkBillDtList.get(0).Quantity__c,billDtl.Quantity__c);
        System.assertEquals(checkBillDtList.get(0).Unit__c,billDtl.Unit__c);
        System.assertEquals(checkBillDtList.get(0).Amount__c,billDtl.Amount__c);
        System.assertEquals(checkBillDtList.get(0).TaxType__c,billDtl.TaxType__c);
        System.assertEquals(checkBillDtList.get(0).TaxPrice__c,billDtl.TaxPrice__c);
        System.assertEquals(checkBillDtList.get(0).Remarks__c,billDtl.Remarks__c);
    }

    /**
     * 【対象】
     * saveAction、getSaveCheckResult、calcAmountAll、validate
     * 【条件】
     * 複数行明細があり、入力項目が満たされていない行がある
     * 【結果】
     * 入力した内容で請求明細が登録されること
     */ 
    @isTest
    public static void test_saveAction_002(){
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

        // 商品マスタ
        Product__c product = TestUtil.createProducts(Constants.TAX_TYPE_NO_TAX,10000);
        product.LargeType__c = 'operation';
        product.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        product.Unit__c = 'shiki';
        insert product;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(bill);
        billDtl.ProductName__c = product.Id;
        billDtl.No__c = 1;
        billDtl.Remarks__c = '単体テスト';
        billDtl.LargeType__c = 'operation';
        billDtl.Unit__c ='台';
        billDtl.UnitPrice__c =5000;
        billDtl.ProductNameText__c = 'テスト商品税抜';
        billDtl.Quantity__c = 2;
        billDtl.TaxPrice__c = 0;
        billDtl.DetailType__c = 'initialCost';
        billDtl.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDtl.Amount__c = 10000;

        BillingDetail__c billDt2 = createBillingDetail(bill);
        billDt2.ProductName__c = product.Id;
        billDt2.No__c = 2;
        billDt2.Remarks__c = '単体テスト';
        billDt2.LargeType__c = 'operation';
        billDt2.Unit__c ='台';
        billDt2.UnitPrice__c =5000;
        billDt2.ProductNameText__c = 'テスト商品税込';
        billDt2.Quantity__c = 3;
        billDt2.TaxPrice__c = 1500;
        billDt2.DetailType__c = 'initialCost';
        billDt2.TaxType__c = Constants.TAX_TYPE_10;
        billDt2.Amount__c = 15000;

        BillingDetail__c billDt3 = createBillingDetail(bill);
        billDt3.ProductName__c = null;
        billDt3.No__c = 3;
        billDt3.Remarks__c = '単体テスト';
        billDt3.LargeType__c = '';
        billDt3.Unit__c ='';
        billDt3.UnitPrice__c = null;
        billDt3.ProductNameText__c = 'テスト商品';
        billDt3.Quantity__c = null;
        billDt3.DetailType__c = '';

        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.initAction();

        // 登録用データを入力内容に設定
        ctrl.addDetail();
        ctrl.details[0].detail.No__c = billDtl.No__c;
        ctrl.details[0].detail.LargeType__c = billDtl.LargeType__c;
        ctrl.details[0].detail.ProductName__c = billDtl.ProductName__c;
        ctrl.details[0].detail.ProductNameText__c = billDtl.ProductNameText__c;
        ctrl.details[0].detail.DetailType__c = billDtl.DetailType__c;
        ctrl.details[0].detail.UnitPrice__c = billDtl.UnitPrice__c;
        ctrl.details[0].detail.Quantity__c = billDtl.Quantity__c;
        ctrl.details[0].detail.Unit__c = billDtl.Unit__c;
        ctrl.details[0].detail.Amount__c = billDtl.Amount__c;
        ctrl.details[0].detail.TaxType__c = billDtl.TaxType__c;
        ctrl.details[0].detail.TaxPrice__c = billDtl.TaxPrice__c;
        ctrl.details[0].detail.Remarks__c = billDtl.Remarks__c;

        ctrl.addDetail();
        ctrl.details[1].detail.No__c = billDt2.No__c;
        ctrl.details[1].detail.LargeType__c = billDt2.LargeType__c;
        ctrl.details[1].detail.ProductName__c = billDt2.ProductName__c;
        ctrl.details[1].detail.ProductNameText__c = billDt2.ProductNameText__c;
        ctrl.details[1].detail.DetailType__c = billDt2.DetailType__c;
        ctrl.details[1].detail.UnitPrice__c = billDt2.UnitPrice__c;
        ctrl.details[1].detail.Quantity__c = billDt2.Quantity__c;
        ctrl.details[1].detail.Unit__c = billDt2.Unit__c;
        ctrl.details[1].detail.Amount__c = billDt2.Amount__c;
        ctrl.details[1].detail.TaxType__c = billDt2.TaxType__c;
        ctrl.details[1].detail.TaxPrice__c = billDt2.TaxPrice__c;
        ctrl.details[1].detail.Remarks__c = billDt2.Remarks__c;

        ctrl.addDetail();
        ctrl.details[2].detail.No__c = billDt3.No__c;
        ctrl.details[2].detail.LargeType__c = billDt3.LargeType__c;
        ctrl.details[2].detail.ProductName__c = billDt3.ProductName__c;
        ctrl.details[2].detail.ProductNameText__c = billDt3.ProductNameText__c;
        ctrl.details[2].detail.DetailType__c = billDt3.DetailType__c;
        ctrl.details[2].detail.UnitPrice__c = billDt3.UnitPrice__c;
        ctrl.details[2].detail.Quantity__c = billDt3.Quantity__c;
        ctrl.details[2].detail.Unit__c = billDt3.Unit__c;
        ctrl.details[2].detail.Amount__c = billDt3.Amount__c;
        ctrl.details[2].detail.TaxType__c = billDt3.TaxType__c;
        ctrl.details[2].detail.TaxPrice__c = billDt3.TaxPrice__c;
        ctrl.details[2].detail.Remarks__c = billDt3.Remarks__c;

        // 保存処理実行
        ctrl.saveAction();

        Test.stopTest();

        // 検証用請求明細データ取得
        List<String> selectDetailFields = new List<String>(
            BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        ID bId = bill.Id;
        List<BillingDetail__c> checkBillDtList = Database.Query(
            String.format(
                'SELECT {0} FROM BillingDetail__c WHERE Billing__c = :bId',
                new List<String>{String.join(selectDetailFields,', ')}
            )
        );
        // 検証
        // 請求明細
        System.assertEquals(checkBillDtList.get(0).No__c,billDtl.No__c);
        System.assertEquals(checkBillDtList.get(0).LargeType__c,billDtl.LargeType__c);
        System.assertEquals(checkBillDtList.get(0).ProductName__c,billDtl.ProductName__c);
        System.assertEquals(checkBillDtList.get(0).ProductNameText__c,billDtl.ProductNameText__c);
        System.assertEquals(checkBillDtList.get(0).DetailType__c,billDtl.DetailType__c);
        System.assertEquals(checkBillDtList.get(0).UnitPrice__c,billDtl.UnitPrice__c);
        System.assertEquals(checkBillDtList.get(0).Quantity__c,billDtl.Quantity__c);
        System.assertEquals(checkBillDtList.get(0).Unit__c,billDtl.Unit__c);
        System.assertEquals(checkBillDtList.get(0).Amount__c,billDtl.Amount__c);
        System.assertEquals(checkBillDtList.get(0).TaxType__c,billDtl.TaxType__c);
        System.assertEquals(checkBillDtList.get(0).TaxPrice__c,billDtl.TaxPrice__c);
        System.assertEquals(checkBillDtList.get(0).Remarks__c,billDtl.Remarks__c);

        System.assertEquals(checkBillDtList.get(1).No__c,billDt2.No__c);
        System.assertEquals(checkBillDtList.get(1).LargeType__c,billDt2.LargeType__c);
        System.assertEquals(checkBillDtList.get(1).ProductName__c,billDt2.ProductName__c);
        System.assertEquals(checkBillDtList.get(1).ProductNameText__c,billDt2.ProductNameText__c);
        System.assertEquals(checkBillDtList.get(1).DetailType__c,billDt2.DetailType__c);
        System.assertEquals(checkBillDtList.get(1).UnitPrice__c,billDt2.UnitPrice__c);
        System.assertEquals(checkBillDtList.get(1).Quantity__c,billDt2.Quantity__c);
        System.assertEquals(checkBillDtList.get(1).Unit__c,billDt2.Unit__c);
        System.assertEquals(checkBillDtList.get(1).Amount__c,billDt2.Amount__c);
        System.assertEquals(checkBillDtList.get(1).TaxType__c,billDt2.TaxType__c);
        System.assertEquals(checkBillDtList.get(1).TaxPrice__c,billDt2.TaxPrice__c);
        System.assertEquals(checkBillDtList.get(1).Remarks__c,billDt2.Remarks__c);

        // 入力不備があるものは登録されていないこと(3明細中2明細が登録されている)
        System.assertEquals(checkBillDtList.size(), 2);
    }

    /**
     * 【対象】
     * delDetail、saveAction
     * 【条件】
     * 登録済み明細を削除後、保存処理を実行
     * 【結果】
     * 登録済み明細が削除されること
     */ 
    @isTest
    public static void test_saveAction_003(){
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

        // 商品マスタ
        Product__c product = TestUtil.createProducts(Constants.TAX_TYPE_NO_TAX,10000);
        product.LargeType__c = 'operation';
        product.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        product.Unit__c = 'shiki';
        insert product;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // 請求明細
        List<BillingDetail__c> insertBillDt= new List<BillingDetail__c>();
        BillingDetail__c billDtl = createBillingDetail(bill);
        billDtl.ProductName__c = product.Id;
        billDtl.No__c = 1;
        billDtl.Remarks__c = '単体テスト';
        billDtl.LargeType__c = 'operation';
        billDtl.Unit__c ='台';
        billDtl.UnitPrice__c =5000;
        billDtl.ProductNameText__c = 'テスト商品税抜';
        billDtl.Quantity__c = 2;
        billDtl.TaxPrice__c = 0;
        billDtl.DetailType__c = 'initialCost';
        billDtl.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDtl.Amount__c = 10000;

        BillingDetail__c billDt2 = createBillingDetail(bill);
        billDt2.ProductName__c = product.Id;
        billDt2.No__c = 2;
        billDt2.Remarks__c = '単体テスト';
        billDt2.LargeType__c = 'operation';
        billDt2.Unit__c ='台';
        billDt2.UnitPrice__c =5000;
        billDt2.ProductNameText__c = 'テスト商品税込';
        billDt2.Quantity__c = 3;
        billDt2.TaxPrice__c = 1500;
        billDt2.DetailType__c = 'initialCost';
        billDt2.TaxType__c = Constants.TAX_TYPE_10;
        billDt2.Amount__c = 15000;

        insertBillDt.add(billDtl);
        insertBillDt.add(billDt2);

        insert insertBillDt;

        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.initAction();

        // billDt2を削除
        ctrl.details[1].isSelected = true;
        ctrl.delDetail();

        // billDtlを画面から編集
        ctrl.details[0].detail.Remarks__c = '単体テスト編集後保存確認';

        // 保存実行
        ctrl.saveAction();
        Test.stopTest();

        List<String> selectDetailFields = new List<String>(
            BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        ID bId = bill.Id;
        List<BillingDetail__c> checkBillDtList = Database.Query(
            String.format(
                'SELECT {0} FROM BillingDetail__c WHERE Billing__c = :bId',
                new List<String>{String.join(selectDetailFields,', ')}
            )
        );

        // 検証
        System.assertEquals(checkBillDtList.size(), 1);
        System.assertEquals(checkBillDtList.get(0).Remarks__c, '単体テスト編集後保存確認');
    }

    @isTest
    public static void test_validate_001(){

        BillingEditController target = new BillingEditController(new ApexPages.StandardController(new Billing__c()));
        target.initAction();
        target.upsertDetails = new List<BillingDetail__c>{target.details[0].detail};

        Test.startTest();

        target.validate();

        Test.stopTest();
    }
    
    @isTest
    public static void test_reCalcAction_001(){
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

        // 商品マスタ
        Product__c product = TestUtil.createProducts(Constants.TAX_TYPE_NO_TAX,10000);
        product.LargeType__c = 'operation';
        product.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        product.Unit__c = 'shiki';
        insert product;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        insert billH;  
        
        // 請求
        Billing__c bill = createBilling(acc, billH, constitution);
        insert bill;

        // 請求明細
        BillingDetail__c billDtl = createBillingDetail(bill);
        billDtl.ProductName__c = product.Id;
        billDtl.No__c = 1;
        billDtl.Remarks__c = '単体テスト';
        billDtl.LargeType__c = 'operation';
        billDtl.Unit__c ='台';
        billDtl.UnitPrice__c =5000;
        billDtl.ProductNameText__c = 'テスト商品';
        billDtl.Quantity__c = 2;
        billDtl.TaxPrice__c = 0;
        billDtl.DetailType__c = 'initialCost';
        billDtl.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDtl.Amount__c = 10000;

        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bill);
        BillingEditController ctrl = new BillingEditController(stdCtrl);
        ctrl.initAction();

        // 登録用データを入力内容に設定
        ctrl.addDetail();
        ctrl.details[0].detail.No__c = billDtl.No__c;
        ctrl.details[0].detail.LargeType__c = billDtl.LargeType__c;
        ctrl.details[0].detail.ProductName__c = billDtl.ProductName__c;
        ctrl.details[0].detail.ProductNameText__c = billDtl.ProductNameText__c;
        ctrl.details[0].detail.DetailType__c = billDtl.DetailType__c;
        ctrl.details[0].detail.UnitPrice__c = billDtl.UnitPrice__c;
        ctrl.details[0].detail.Quantity__c = billDtl.Quantity__c;
        ctrl.details[0].detail.Unit__c = billDtl.Unit__c;
        ctrl.details[0].detail.Amount__c = billDtl.Amount__c;
        ctrl.details[0].detail.TaxType__c = billDtl.TaxType__c;
        ctrl.details[0].detail.TaxPrice__c = billDtl.TaxPrice__c;
        ctrl.details[0].detail.Remarks__c = billDtl.Remarks__c;

        // 保存処理実行
        ctrl.reCalcAction();

        Test.stopTest();
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
    /* 請求(新規) */
    private static Billing__c createNewBilling() {
        Billing__c bill = new Billing__c();
        return bill;
    }    
    
    /* 請求明細 */
    private static BillingDetail__c createBillingDetail(Billing__c bill) {
        BillingDetail__c billDtl = new BillingDetail__c();
        billDtl.Billing__c = bill.Id;
        return billDtl;
    }
}