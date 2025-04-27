/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約更新コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/15          XXXXXXX          New
 ********************************************************************************/
@isTest
private class ContractEditControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
        
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

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
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

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
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

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
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
        Decimal totalContractAmount = ctrl.details[0].detail.Amount__c + ctrl.details[1].detail.Amount__c;
        // 消費税額（10%）
        Decimal totalTaxAmount = ctrl.details[0].detail.TaxPrice__c + ctrl.details[1].detail.TaxPrice__c;
        // 見積金額（税込）
        Decimal totalAmountIncludingTax = totalContractAmount + totalTaxAmount;

        // 検証
        System.assertEquals(ctrl.details[1].detail.Amount__c, 2000*20);
        System.assertEquals(ctrl.details[1].detail.TaxPrice__c, (ctrl.details[1].detail.Amount__c * 0.1).round(System.RoundingMode.HALF_UP));
        // 合計金額
        System.assertEquals(ctrl.totalAmountIncludingTax, totalAmountIncludingTax);
        System.assertEquals(ctrl.totalContractAmount, totalContractAmount);
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

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
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
        Decimal totalContractAmount = ctrl.details[0].detail.Amount__c + ctrl.details[1].detail.Amount__c;
        // 消費税額（10%）
        Decimal totalTaxAmount = ctrl.details[0].detail.TaxPrice__c + ctrl.details[1].detail.TaxPrice__c;
        // 見積金額（税込）
        Decimal totalAmountIncludingTax = totalContractAmount + totalTaxAmount;

        // 検証
        System.assertEquals(ctrl.details[1].detail.Amount__c, 2000*20);
        System.assertEquals(ctrl.details[1].detail.TaxPrice__c, 0);
        // 合計金額
        System.assertEquals(ctrl.totalAmountIncludingTax, totalAmountIncludingTax);
        System.assertEquals(ctrl.totalContractAmount, totalContractAmount);
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

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);

        Product__c pdct1 = TestUtil.createProducts('tax10', 1000);
        pdct1.LargeType__c = 'operation';
        pdct1.DetailType__c = 'annual';
        pdct1.Unit__c = 'shiki';
        insert pdct1;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
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

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
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
     * 新規の場合
     * 【結果】
     * 見積明細が1件追加された状態であること
     */
    @isTest
    public static void test_initAction_001() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(ctrl.details.size(),1);
    }

    /**
     * 【対象】
     * initAction、getQuote、getQuoteDetails、calcTotalAmount
     * 【条件】
     * 更新・コピーの場合
     * 【結果】
     * テスト用に登録した契約の情報が設定されていること・見積明細が２件追加され登録した明細の情報が設定されていること・明細の金額の合計が計算されていること
     */
    @isTest
    public static void test_initAction_002() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Contact cntct = TestUtil.createContact(acc);
        insert cntct;

        Contact con = TestUtil.createContact(acc);
        insert con;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        // 確認用の値を設定
        contract.Name = '契約Initメソッドテスト_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        contract.Account__c = acc.id;
        contract.Billing__c = acc.id;
        contract.BillingPerson__c = cntct.id;
        contract.Constitution_Common__c = constitution.id;
        contract.ContractEndDate__c = date.today().addDays(30);
        contract.ContractEndDate__c = date.today();
        contract.OwnerId = UserInfo.getUserId();
        contract.PaymentCondition__c = 'お支払い条件_' + datetime.now().format('yyyy-MM-dd');
        // contract.Remarks__c = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        contract.UpdateCycle__c = '3Months';
        insert contract;

        Product__c pdct2 = TestUtil.createProducts('tax10', 2000);
        pdct2.Name = 'テスト商品２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct2;
        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;

        ContractDetail__c detail2 = TestUtil.createContractDetail(contract);
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
        detail2.Contract__c = contract.Id;
        detail2.DetailType__c = 'initialCost';
        detail2.SpecifiedMonth__c =Date.today();
        // detail2.BillingStartMonth__c ='contractStartNextMonth';
        detail2.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        detail2.TaxType__c = 'tax10';
        insert detail2;
        ContractDetail__c detail1 = TestUtil.createContractDetail(contract);
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
        detail1.Contract__c = contract.Id;
        detail1.DetailType__c = 'monthlyCost';
        detail1.SpecifiedMonth__c =Date.today();
        // detail1.BillingStartMonth__c ='contractStartNextMonth';
        detail1.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        detail1.TaxType__c = 'noTax';
        insert detail1;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.initAction();
        
        Test.stopTest();

        // 検証用契約データ取得
        Id cId =contract.Id;
        List<String> selectFields = new List<String>(
            Contract__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        Contract__c checkContract = Database.query(
            String.format(
                'SELECT {0} FROM Contract__c WHERE Id = :cId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );
        List<String> selectDetailFields = new List<String>(
            ContractDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        List<ContractDetail__c> checkContractDetails = Database.query(
            String.format(
                'SELECT {0} FROM ContractDetail__c WHERE Contract__c = :cId ORDER BY No__c ASC NULLS LAST '
                , new List<String>{ String.join(selectDetailFields, ', ') }
            )
        );

        // 合計金額の取得
        // 合計金額（税抜）
        Decimal totalContractAmount = ctrl.details[0].detail.Amount__c + ctrl.details[1].detail.Amount__c;
        // 消費税額（10%）
        Decimal totalTaxAmount = ctrl.details[0].detail.TaxPrice__c + ctrl.details[1].detail.TaxPrice__c;
        // 見積金額（税込）
        Decimal totalAmountIncludingTax = totalContractAmount + totalTaxAmount;

        // 検証
        // 契約
        System.assertEquals(ctrl.contract.Id, checkContract.Id);
        System.assertEquals(ctrl.contract.Name, checkContract.Name);
        System.assertEquals(ctrl.contract.Account__c, checkContract.Account__c);
        System.assertEquals(ctrl.contract.Billing__c, checkContract.Billing__c);
        System.assertEquals(ctrl.contract.BillingDepartment__c, checkContract.BillingDepartment__c);
        System.assertEquals(ctrl.contract.BillingPerson__c, checkContract.BillingPerson__c);
        System.assertEquals(ctrl.contract.Constitution_Common__c, checkContract.Constitution_Common__c);
        System.assertEquals(ctrl.contract.ContractEndDate__c, checkContract.ContractEndDate__c);
        System.assertEquals(ctrl.contract.ContractStartDate__c, checkContract.ContractStartDate__c);
        System.assertEquals(ctrl.contract.CreatedById, checkContract.CreatedById);
        System.assertEquals(ctrl.contract.IsContractUpdateMonth__c, checkContract.IsContractUpdateMonth__c);
        System.assertEquals(ctrl.contract.LastModifiedById, checkContract.LastModifiedById);
        System.assertEquals(ctrl.contract.OrderNumber__c, checkContract.OrderNumber__c);
        System.assertEquals(ctrl.contract.OwnerId, checkContract.OwnerId);
        System.assertEquals(ctrl.contract.PaymentCondition__c, checkContract.PaymentCondition__c);
        // System.assertEquals(ctrl.contract.Remarks__c, checkContract.Remarks__c);
        System.assertEquals(ctrl.contract.ThisMonthTotalAmount__c, checkContract.ThisMonthTotalAmount__c);
        System.assertEquals(ctrl.contract.ThisMonthTotalAmountIncludingTax__c, checkContract.ThisMonthTotalAmountIncludingTax__c);
        System.assertEquals(ctrl.contract.ThisMonthTotalTaxAmount__c, checkContract.ThisMonthTotalTaxAmount__c);
        System.assertEquals(ctrl.contract.UpdateCycle__c, checkContract.UpdateCycle__c);
        // 契約明細
        System.assertEquals(ctrl.details.size(),2);
        System.assertEquals(ctrl.details[0].detail.No__c, checkContractDetails[0].No__c);
        System.assertEquals(ctrl.details[0].detail.CreatedById, checkContractDetails[0].CreatedById);
        System.assertEquals(ctrl.details[0].detail.Remarks__c, checkContractDetails[0].Remarks__c);
        System.assertEquals(ctrl.details[0].detail.LargeType__c, checkContractDetails[0].LargeType__c);
        System.assertEquals(ctrl.details[0].detail.Unit__c, checkContractDetails[0].Unit__c);
        System.assertEquals(ctrl.details[0].detail.UnitPrice__c, checkContractDetails[0].UnitPrice__c);
        System.assertEquals(ctrl.details[0].detail.ProductName__c, checkContractDetails[0].ProductName__c);
        System.assertEquals(ctrl.details[0].detail.Quantity__c, checkContractDetails[0].Quantity__c);
        System.assertEquals(ctrl.details[0].detail.LastModifiedById, checkContractDetails[0].LastModifiedById);
        System.assertEquals(ctrl.details[0].detail.TaxPrice__c, checkContractDetails[0].TaxPrice__c);
        System.assertEquals(ctrl.details[0].detail.Contract__c, checkContractDetails[0].Contract__c);
        System.assertEquals(ctrl.details[0].detail.Name, checkContractDetails[0].Name);
        System.assertEquals(ctrl.details[0].detail.DetailType__c, checkContractDetails[0].DetailType__c);
        System.assertEquals(ctrl.details[0].detail.SpecifiedMonth__c, checkContractDetails[0].SpecifiedMonth__c);
        System.assertEquals(ctrl.details[0].detail.BillingStartMonth__c, checkContractDetails[0].BillingStartMonth__c);
        System.assertEquals(ctrl.details[0].detail.TaxType__c, checkContractDetails[0].TaxType__c);
        System.assertEquals(ctrl.details[0].detail.Amount__c, checkContractDetails[0].Amount__c);
        System.assertEquals(ctrl.details[1].detail.No__c, checkContractDetails[1].No__c);
        System.assertEquals(ctrl.details[1].detail.CreatedById, checkContractDetails[1].CreatedById);
        System.assertEquals(ctrl.details[1].detail.Remarks__c, checkContractDetails[1].Remarks__c);
        System.assertEquals(ctrl.details[1].detail.LargeType__c, checkContractDetails[1].LargeType__c);
        System.assertEquals(ctrl.details[1].detail.Unit__c, checkContractDetails[1].Unit__c);
        System.assertEquals(ctrl.details[1].detail.UnitPrice__c, checkContractDetails[1].UnitPrice__c);
        System.assertEquals(ctrl.details[1].detail.ProductName__c, checkContractDetails[1].ProductName__c);
        System.assertEquals(ctrl.details[1].detail.Quantity__c, checkContractDetails[1].Quantity__c);
        System.assertEquals(ctrl.details[1].detail.LastModifiedById, checkContractDetails[1].LastModifiedById);
        System.assertEquals(ctrl.details[1].detail.SpecifiedMonth__c, checkContractDetails[1].SpecifiedMonth__c);
        System.assertEquals(ctrl.details[1].detail.BillingStartMonth__c, checkContractDetails[1].BillingStartMonth__c);
        System.assertEquals(ctrl.details[1].detail.TaxPrice__c, checkContractDetails[1].TaxPrice__c);
        System.assertEquals(ctrl.details[1].detail.Contract__c, checkContractDetails[1].Contract__c);
        System.assertEquals(ctrl.details[1].detail.Name, checkContractDetails[1].Name);
        System.assertEquals(ctrl.details[1].detail.DetailType__c, checkContractDetails[1].DetailType__c);
        System.assertEquals(ctrl.details[1].detail.TaxType__c, checkContractDetails[1].TaxType__c);
        System.assertEquals(ctrl.details[1].detail.Amount__c, checkContractDetails[1].Amount__c);
        // 合計金額
        System.assertEquals(ctrl.totalAmountIncludingTax, totalAmountIncludingTax);
        System.assertEquals(ctrl.totalContractAmount, totalContractAmount);
        System.assertEquals(ctrl.totalTaxAmount, totalTaxAmount);

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

        // 処理がまだ記載されておらず、必ずtrueが返却されるため、テスト処理もなし
        // チェック処理が追加された際にはテスト側も修正が必要

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

        // 処理がまだ記載されておらず、必ずtrueが返却されるため、テスト処理もなし
        // チェック処理が追加された際にはテスト側も修正が必要

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

        // 処理がまだ記載されておらず、チェックが実装されていないためテスト処理もなし
        // チェック処理が追加された際にはテスト側も修正が必要

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

        Contact cntct = TestUtil.createContact(acc);
        insert cntct;

        Contact con = TestUtil.createContact(acc);
        insert con;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        // 確認用の値を設定
        contract.Name = '契約保存メソッドテスト２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        contract.Account__c = acc.id;
        contract.Billing__c = acc.id;
        contract.BillingPerson__c = cntct.id;
        contract.Constitution_Common__c = constitution.id;
        contract.ContractEndDate__c = date.today().addDays(30);
        contract.ContractEndDate__c = date.today();
        contract.OwnerId = UserInfo.getUserId();
        contract.PaymentCondition__c = 'お支払い条件_' + datetime.now().format('yyyy-MM-dd');
        // contract.Remarks__c = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        contract.UpdateCycle__c = '3Months';

        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;
        Product__c pdct2 = TestUtil.createProducts('tax10', 2000);
        pdct2.Name = 'テスト商品２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct2;

        ContractDetail__c detail1 = TestUtil.createContractDetail(contract);
        detail1.No__c = 1;
        detail1.Remarks__C = '備考１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail1.LargeType__c = '';
        detail1.Unit__c = 'テスト1';
        detail1.UnitPrice__c = 1000;
        detail1.ProductName__c = pdct1.Id;
        detail1.Quantity__c =10;
        detail1.Amount__c = detail1.UnitPrice__c * detail1.Quantity__c;
        detail1.SpecifiedMonth__c =Date.today();
        // detail1.BillingStartMonth__c ='contractStartNextMonth';
        detail1.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        detail1.TaxPrice__c = 0;
        detail1.DetailType__c = 'monthlyCost';
        detail1.TaxType__c = 'noTax';
        ContractDetail__c detail2 = TestUtil.createContractDetail(contract);
        detail2.No__c = 2;
        detail2.Remarks__C = '備考２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail2.LargeType__c = 'operation';
        detail2.Unit__c = 'テスト２';
        detail2.UnitPrice__c = 2000;
        detail2.ProductName__c = pdct2.Id;
        detail2.Quantity__c =20;
        detail2.Amount__c = detail2.UnitPrice__c * detail2.Quantity__c;
        detail2.SpecifiedMonth__c =Date.today();
        // detail2.BillingStartMonth__c ='contractStartNextMonth';
        detail2.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        detail2.TaxPrice__c = (detail2.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail2.DetailType__c = 'initialCost';
        detail2.TaxType__c = 'tax10';

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.initAction();

        // 明細追加(※initActionにて１行追加されるため、１行分の行追加を行う)
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
        ctrl.details[0].detail.SpecifiedMonth__c = detail1.SpecifiedMonth__c;
        ctrl.details[0].detail.BillingStartMonth__c = detail1.BillingStartMonth__c;
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
        ctrl.details[1].detail.SpecifiedMonth__c = detail2.SpecifiedMonth__c;
        ctrl.details[1].detail.BillingStartMonth__c = detail2.BillingStartMonth__c;
        ctrl.details[1].detail.TaxType__c = detail2.TaxType__c;

        // 保存処理実行
        ctrl.saveAction();
        
        Test.stopTest();

        // 検証用見積データ件数取得
        String cName = contract.Name;
        Integer count = Database.countQuery('SELECT COUNT() FROM Contract__c WHERE Name = :cName ');
        // 検証
        System.assertEquals(count, 1);

        // 検証用見積データ取得
        List<String> selectFields = new List<String>(
            Contract__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        Contract__c checkContract = Database.query(
            String.format(
                'SELECT {0} FROM Contract__c WHERE Name = :cName LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        // 検証用見積明細データ件数取得
        Id cId = checkContract.Id;
        Integer countDetail = Database.countQuery('SELECT COUNT() FROM ContractDetail__c WHERE Contract__c = :cId ');
        // 検証
        System.assertEquals(countDetail, 2);

        // 検証用見積明細データ取得
        List<String> selectDetailFields = new List<String>(
            ContractDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        List<ContractDetail__c> checkContractDetails = Database.query(
            String.format(
                'SELECT {0} FROM ContractDetail__c WHERE Contract__c = :cId ORDER BY No__c ASC  '
                , new List<String>{ String.join(selectDetailFields, ', ') }
            )
        );

        // 検証
        // 契約
        System.assertEquals(contract.Name, checkContract.Name);
        System.assertEquals(contract.Account__c, checkContract.Account__c);
        System.assertEquals(contract.Billing__c, checkContract.Billing__c);
        System.assertEquals(contract.BillingDepartment__c, checkContract.BillingDepartment__c);
        System.assertEquals(contract.BillingPerson__c, checkContract.BillingPerson__c);
        System.assertEquals(contract.Constitution_Common__c, checkContract.Constitution_Common__c);
        System.assertEquals(contract.ContractStartDate__c, checkContract.ContractStartDate__c);
        System.assertEquals(contract.ContractEndDate__c, checkContract.ContractEndDate__c);
        System.assertEquals(contract.OwnerId, checkContract.OwnerId);
        System.assertEquals(contract.PaymentCondition__c, checkContract.PaymentCondition__c);
        // System.assertEquals(contract.Remarks__c, checkContract.Remarks__c);
        System.assertEquals(contract.UpdateCycle__c, checkContract.UpdateCycle__c);
        
        // 見積明細
        System.assertEquals(detail1.No__c, checkContractDetails[0].No__c);
        System.assertEquals(detail1.Remarks__c, checkContractDetails[0].Remarks__c);
        // System.assertEquals(detail1.LargeType__c, checkContractDetails[0].LargeType__c);
        System.assertEquals(detail1.Unit__c, checkContractDetails[0].Unit__c);
        System.assertEquals(detail1.UnitPrice__c, checkContractDetails[0].UnitPrice__c);
        System.assertEquals(detail1.ProductName__c, checkContractDetails[0].ProductName__c);
        System.assertEquals(detail1.Quantity__c, checkContractDetails[0].Quantity__c);
        System.assertEquals(detail1.TaxPrice__c, checkContractDetails[0].TaxPrice__c);
        System.assertEquals(checkContract.Id, checkContractDetails[0].Contract__c);
        System.assertEquals(detail1.DetailType__c, checkContractDetails[0].DetailType__c);
        System.assertEquals(detail1.SpecifiedMonth__c, checkContractDetails[0].SpecifiedMonth__c);
        System.assertEquals(detail1.BillingStartMonth__c, checkContractDetails[0].BillingStartMonth__c);
        System.assertEquals(detail1.TaxType__c, checkContractDetails[0].TaxType__c);
        System.assertEquals(detail1.Amount__c, checkContractDetails[0].Amount__c);
        System.assertEquals(detail2.No__c, checkContractDetails[1].No__c);
        System.assertEquals(detail2.Remarks__c, checkContractDetails[1].Remarks__c);
        // System.assertEquals(detail2.LargeType__c, checkContractDetails[1].LargeType__c);
        System.assertEquals(detail2.Unit__c, checkContractDetails[1].Unit__c);
        System.assertEquals(detail2.UnitPrice__c, checkContractDetails[1].UnitPrice__c);
        System.assertEquals(detail2.ProductName__c, checkContractDetails[1].ProductName__c);
        System.assertEquals(detail2.Quantity__c, checkContractDetails[1].Quantity__c);
        System.assertEquals(detail2.TaxPrice__c, checkContractDetails[1].TaxPrice__c);
        System.assertEquals(checkContract.Id, checkContractDetails[1].Contract__c);
        System.assertEquals(detail2.DetailType__c, checkContractDetails[1].DetailType__c);
        System.assertEquals(detail2.SpecifiedMonth__c, checkContractDetails[1].SpecifiedMonth__c);
        System.assertEquals(detail2.BillingStartMonth__c, checkContractDetails[1].BillingStartMonth__c);
        System.assertEquals(detail2.TaxType__c, checkContractDetails[1].TaxType__c);
        System.assertEquals(detail2.Amount__c, checkContractDetails[1].Amount__c);
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

        Contact cntct = TestUtil.createContact(acc);
        insert cntct;

        Contact con = TestUtil.createContact(acc);
        insert con;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
 
        // 確認用の値を設定
        contract.Name = '契約取得メソッドテスト_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        contract.Account__c = acc.id;
        contract.Billing__c = acc.id;
        contract.BillingPerson__c = cntct.id;
        contract.Constitution_Common__c = constitution.id;
        contract.ContractEndDate__c = date.today().addDays(30);
        contract.ContractEndDate__c = date.today();
        contract.OwnerId = UserInfo.getUserId();
        contract.PaymentCondition__c = 'お支払い条件_' + datetime.now().format('yyyy-MM-dd');
        // contract.Remarks__c = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        contract.UpdateCycle__c = '3Months';
        insert contract;

        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;
        Product__c pdct2 = TestUtil.createProducts('tax10', 2000);
        pdct2.Name = 'テスト商品２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct2;
        
        ContractDetail__c detail1 = TestUtil.createContractDetail(contract);
        detail1.No__c = 1;
        detail1.Remarks__C = '備考1_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail1.LargeType__c = '';
        detail1.Unit__c = 'テスト1';
        detail1.UnitPrice__c = 1000;
        detail1.ProductName__c = pdct1.Id;
        detail1.Quantity__c =10;
        detail1.Amount__c = detail1.UnitPrice__c * detail1.Quantity__c;
        detail1.TaxPrice__c = (detail1.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail1.Contract__c = contract.Id;
        detail1.DetailType__c = 'monthlyCost';
        detail1.SpecifiedMonth__c =Date.today();
        // detail1.BillingStartMonth__c ='contractStartNextMonth';
        detail1.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        detail1.TaxType__c = 'noTax';
        insert detail1;
        ContractDetail__c detail2 = TestUtil.createContractDetail(contract);
        detail2.No__c = 2;
        detail2.Remarks__C = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail2.LargeType__c = 'operation';
        detail2.Unit__c = 'テスト';
        detail2.UnitPrice__c = 2000;
        detail2.ProductName__c = pdct2.Id;
        detail2.Quantity__c =20;
        detail2.Amount__c = detail2.UnitPrice__c * detail2.Quantity__c;
        detail2.TaxPrice__c = (detail2.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail2.Contract__c = contract.Id;
        detail2.SpecifiedMonth__c =Date.today();
        // detail2.BillingStartMonth__c ='contractStartNextMonth';
        detail2.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        detail2.DetailType__c = 'initialCost';
        detail2.TaxType__c = 'tax10';
        insert detail2;
        
        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.initAction();

        // 見積の名称の先頭に’更新’の文字列を追加
        String afterName = '更新' + ctrl.contract.Name;
        ctrl.contract.Name = afterName;
        
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
        Id cId = contract.Id;
        List<String> selectFields = new List<String>(
            Contract__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        Contract__c checkContract = Database.query(
            String.format(
                'SELECT {0} FROM Contract__c WHERE Id = :cId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        // 検証用見積明細データ取得
        List<String> selectDetailFields = new List<String>(
            ContractDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );
        List<ContractDetail__c> checkContractDetails = Database.query(
            String.format(
                'SELECT {0} FROM ContractDetail__c WHERE Contract__c = :cId ORDER BY Id '
                , new List<String>{ String.join(selectDetailFields, ', ') }
            )
        );

        // 検証用見積明細データ件数取得
        Integer countDelDetail = Database.countQuery('SELECT COUNT() FROM ContractDetail__c WHERE Id = :delId ');

        // 検証
        // 契約
        System.assertEquals(afterName, checkContract.Name);

        // 契約明細
        System.assertEquals(countDelDetail, 0);
        System.assertEquals(afterRemarks, checkContractDetails[0].Remarks__c);

    }

    /**
     * 【対象】
     * setContractEndDate
     * 【条件】
     *　3ヶ月更新
     * 【結果】
     * 契約終了日に契約開始日の3ヶ月後が設定されること
     */
    @isTest
    public static void test_setContractEndDate_001() {

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Contract__c());
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.contract.ContractStartDate__c = Date.newInstance(2021, 7, 1);
        ctrl.contract.UpdateCycle__c = Constants.UPDATE_CYCLE_3_MONTHS;

        // テスト開始
        Test.startTest();
        
        ctrl.setContractEndDate();

        Test.stopTest();

        System.assertEquals(Date.newInstance(2021, 9, 30), ctrl.contract.ContractEndDate__c);
    }

    /**
     * 【対象】
     * setContractEndDate
     * 【条件】
     *　3ヶ月更新
     * 【結果】
     * 契約終了日に契約開始日の6ヶ月後が設定されること
     */
    @isTest
    public static void test_setContractEndDate_002() {

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Contract__c());
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.contract.ContractStartDate__c = Date.newInstance(2021, 7, 1);
        ctrl.contract.UpdateCycle__c = Constants.UPDATE_CYCLE_6_MONTHS;

        // テスト開始
        Test.startTest();
        
        ctrl.setContractEndDate();

        Test.stopTest();

        System.assertEquals(Date.newInstance(2021, 12, 31), ctrl.contract.ContractEndDate__c);
    }

    /**
     * 【対象】
     * setContractEndDate
     * 【条件】
     *　3ヶ月更新
     * 【結果】
     * 契約終了日に契約開始日の12ヶ月後が設定されること
     */
    @isTest
    public static void test_setContractEndDate_003() {

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Contract__c());
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.contract.ContractStartDate__c = Date.newInstance(2021, 7, 1);
        ctrl.contract.UpdateCycle__c = Constants.UPDATE_CYCLE_12_MONTHS;

        // テスト開始
        Test.startTest();
        
        ctrl.setContractEndDate();

        Test.stopTest();

        System.assertEquals(Date.newInstance(2022, 6, 30), ctrl.contract.ContractEndDate__c);
    }

    /**
     * 【対象】
     * validate
     * 【条件】
     * エラーあり
     * 【結果】
     * 
     */
    @isTest
    public static void test_validate_001() {

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Contract__c());
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.initAction();
        ctrl.contract.UpdateCycle__c = Constants.UPDATE_CYCLE_AUTO;
        ctrl.contract.ContractEndDate__c = Date.today();
        ctrl.contract.IsAttachment__c = true;

        ctrl.upsertDetails = new List<ContractDetail__c>{ctrl.details[0].detail};
        ctrl.upsertDetails[0].BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;

        // テスト開始
        Test.startTest();
        
        ctrl.validate();

        Test.stopTest();
    }

    /**
     * 【対象】
     * validate
     * 【条件】
     * エラーあり
     * 【結果】
     * 
     */
    @isTest
    public static void test_validate_002() {

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Contract__c());
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.initAction();
        ctrl.contract.UpdateCycle__c = Constants.UPDATE_CYCLE_3_MONTHS;
        ctrl.contract.ContractStartDate__c = Date.today() + 1;
        ctrl.contract.ContractEndDate__c = Date.today();

        ctrl.upsertDetails = new List<ContractDetail__c>{ctrl.details[0].detail};
        ctrl.upsertDetails[0].DetailType__c = Constants.DETAIL_TYPE_ANNUAL;

        // テスト開始
        Test.startTest();
        
        ctrl.validate();

        Test.stopTest();
    }

    @isTest
    public static void test_reCalcAction_001() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Contact cntct = TestUtil.createContact(acc);
        insert cntct;

        Contact con = TestUtil.createContact(acc);
        insert con;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        // 確認用の値を設定
        contract.Name = '契約保存メソッドテスト２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        contract.Account__c = acc.id;
        contract.Billing__c = acc.id;
        contract.BillingPerson__c = cntct.id;
        contract.Constitution_Common__c = constitution.id;
        contract.ContractEndDate__c = date.today().addDays(30);
        contract.ContractEndDate__c = date.today();
        contract.OwnerId = UserInfo.getUserId();
        contract.PaymentCondition__c = 'お支払い条件_' + datetime.now().format('yyyy-MM-dd');
        // contract.Remarks__c = '備考_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        contract.UpdateCycle__c = '3Months';

        Product__c pdct1 = TestUtil.createProducts('noTax', 1000);
        pdct1.Name = 'テスト商品１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct1;
        Product__c pdct2 = TestUtil.createProducts('tax10', 2000);
        pdct2.Name = 'テスト商品２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        insert pdct2;

        ContractDetail__c detail1 = TestUtil.createContractDetail(contract);
        detail1.No__c = 1;
        detail1.Remarks__C = '備考１_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail1.LargeType__c = '';
        detail1.Unit__c = 'テスト1';
        detail1.UnitPrice__c = 1000;
        detail1.ProductName__c = pdct1.Id;
        detail1.Quantity__c =10;
        detail1.Amount__c = detail1.UnitPrice__c * detail1.Quantity__c;
        detail1.SpecifiedMonth__c =Date.today();
        detail1.BillingStartMonth__c ='contractStartNextMonth';
        detail1.TaxPrice__c = 0;
        detail1.DetailType__c = 'monthlyCost';
        detail1.TaxType__c = 'noTax';
        ContractDetail__c detail2 = TestUtil.createContractDetail(contract);
        detail2.No__c = 2;
        detail2.Remarks__C = '備考２_' + datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        detail2.LargeType__c = 'operation';
        detail2.Unit__c = 'テスト２';
        detail2.UnitPrice__c = 2000;
        detail2.ProductName__c = pdct2.Id;
        detail2.Quantity__c =20;
        detail2.Amount__c = detail2.UnitPrice__c * detail2.Quantity__c;
        detail2.SpecifiedMonth__c =Date.today();
        detail2.BillingStartMonth__c ='contractStartNextMonth';
        detail2.TaxPrice__c = (detail2.Amount__c * 0.1).round(System.RoundingMode.HALF_UP);
        detail2.DetailType__c = 'initialCost';
        detail2.TaxType__c = 'tax10';

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractEditController ctrl = new ContractEditController(stdCtrl);
        ctrl.initAction();

        // 明細追加(※initActionにて１行追加されるため、１行分の行追加を行う)
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
        ctrl.details[0].detail.SpecifiedMonth__c = detail1.SpecifiedMonth__c;
        ctrl.details[0].detail.BillingStartMonth__c = detail1.BillingStartMonth__c;
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
        ctrl.details[1].detail.SpecifiedMonth__c = detail2.SpecifiedMonth__c;
        ctrl.details[1].detail.BillingStartMonth__c = detail2.BillingStartMonth__c;
        ctrl.details[1].detail.TaxType__c = detail2.TaxType__c;

        // 保存処理実行
        ctrl.reCalcAction();
        
        Test.stopTest();
    }
}