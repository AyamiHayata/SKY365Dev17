/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約編集コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/07/30          L.Sato          New
 ********************************************************************************/
@isTest
private class CreateBillingControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる

    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 請求対象年月が契約終了日より前、請求対象年月、請求先、請求先部署が同一の請求ヘッダなし
     * 【結果】
     * 処理が正常に終了すること、ページメッセージがないこと、請求ヘッダが作成されていること
     */
    @isTest
    public static void test_initAction_001() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
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
        contract.ContractStartDate__c = Date.newInstance(2021, 6, 1);
        contract.ContractEndDate__c = Date.newInstance(2022, 6, 1);
        contract.Billing__c = acc.Id;
        contract.BillingPerson__c = ct.Id;
        insert contract;
        
        // 契約明細
        List<ContractDetail__c> insertCDList = new List<ContractDetail__c>();
        ContractDetail__c contractDetail1 = TestUtil.createContractDetail(contract);
        contractDetail1.No__c = 1;
        contractDetail1.ProductNameText__c = '単体試験確認用品名1';
        contractDetail1.Quantity__c = 1;
        contractDetail1.UnitPrice__c = 1000;
        contractDetail1.TaxPrice__c = 0;
        contractDetail1.Amount__c = 1000;
        contractDetail1.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        contractDetail1.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail1.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail1.Remarks__c = '単体試験確認用備考1';
        contractDetail1.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail1);

        ContractDetail__c contractDetail2 = TestUtil.createContractDetail(contract);
        contractDetail2.No__c = 2;
        contractDetail2.ProductNameText__c = '単体試験確認用品名2';
        contractDetail2.Quantity__c = 2;
        contractDetail2.UnitPrice__c = 2000;
        contractDetail2.TaxPrice__c = 0;
        contractDetail2.Amount__c = 4000;
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        contractDetail2.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail2.Remarks__c = '単体試験確認用備考2';
        contractDetail2.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail2);

        ContractDetail__c contractDetail3 = TestUtil.createContractDetail(contract);
        contractDetail3.No__c = 3;
        contractDetail3.ProductNameText__c = '単体試験確認用品名3';
        contractDetail3.Quantity__c = 3;
        contractDetail3.UnitPrice__c = 3000;
        contractDetail3.TaxPrice__c = 900;
        contractDetail3.Amount__c = 9000;
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        contractDetail3.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail3);

        insert insertCDList;
    
        Boolean result = true;
        List<ApexPages.Message> messages;

        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        CreateBillingController ctrl = new CreateBillingController(stdCtrl);
        ctrl.billingDate = Date.newInstance(2021, 7, 1);

        try{
            ctrl.initAction();
            messages = ApexPages.getMessages();
        }catch(Exception e){
            System.debug(e);
            result = false;
        }
        Test.stopTest();

        List<BillingHeader__c> billingHeaderList = [SELECT Id FROM BillingHeader__c];

        // 検証
        System.assertEquals(result,true);
 
        System.debug(messages);
        System.assertEquals(0, messages.size());
        System.assertEquals(1, billingHeaderList.size());
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 請求対象年月、請求先、請求先部署が同一の請求ヘッダが既に存在する
     * 【結果】
     * 請求対象年月、請求先、請求先部署が同一の請求ヘッダが既に存在する場合のエラーメッセージが表示されていること、請求ヘッダが作成されていないこと
     */
    @isTest
    public static void test_initAction_002() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
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
        contract.ContractStartDate__c = Date.newInstance(2021, 6, 1);
        contract.ContractEndDate__c = Date.newInstance(2022, 6, 1);
        contract.Billing__c = acc.Id;
        contract.BillingPerson__c = ct.Id;
        insert contract;
        
        // 契約明細
        List<ContractDetail__c> insertCDList = new List<ContractDetail__c>();
        ContractDetail__c contractDetail1 = TestUtil.createContractDetail(contract);
        contractDetail1.No__c = 1;
        contractDetail1.ProductNameText__c = '単体試験確認用品名1';
        contractDetail1.Quantity__c = 1;
        contractDetail1.UnitPrice__c = 1000;
        contractDetail1.TaxPrice__c = 0;
        contractDetail1.Amount__c = 1000;
        contractDetail1.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        contractDetail1.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail1.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail1.Remarks__c = '単体試験確認用備考1';
        contractDetail1.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail1);

        ContractDetail__c contractDetail2 = TestUtil.createContractDetail(contract);
        contractDetail2.No__c = 2;
        contractDetail2.ProductNameText__c = '単体試験確認用品名2';
        contractDetail2.Quantity__c = 2;
        contractDetail2.UnitPrice__c = 2000;
        contractDetail2.TaxPrice__c = 0;
        contractDetail2.Amount__c = 4000;
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        contractDetail2.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail2.Remarks__c = '単体試験確認用備考2';
        contractDetail2.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail2);

        ContractDetail__c contractDetail3 = TestUtil.createContractDetail(contract);
        contractDetail3.No__c = 3;
        contractDetail3.ProductNameText__c = '単体試験確認用品名3';
        contractDetail3.Quantity__c = 3;
        contractDetail3.UnitPrice__c = 3000;
        contractDetail3.TaxPrice__c = 900;
        contractDetail3.Amount__c = 9000;
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        contractDetail3.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail3);

        insert insertCDList;
    
        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc,ct, '2021', '7');
        billH.BillingDepartment__c = 'テスト部';
        insert billH;
        
        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        CreateBillingController ctrl = new CreateBillingController(stdCtrl);
        ctrl.billingDate = Date.newInstance(2021, 7, 1);

        Boolean result = true;
        List<ApexPages.Message> messages;

        try{
            ctrl.initAction();
            messages = ApexPages.getMessages();
        }catch(Exception e){
            System.debug(e);
            result = false;
        }
        Test.stopTest();

        // 検証
        System.assertEquals(result,true);
 
        System.assertEquals(1, messages.size());

        System.assertEquals('請求対象年月、請求先、請求先部署が同一の請求ヘッダが既に存在しています。請求作成を行いたい場合、対象の請求ヘッダを削除してください。', messages[0].getDetail());

        List<BillingHeader__c> billingHeaderList = [SELECT Id FROM BillingHeader__c WHERE Id !=:billH.Id];

        System.assertEquals(0, billingHeaderList.size());
    }

     /**
     * 【対象】
     * initAction
     * 【条件】
     * 契約明細が請求対象外
     * 【結果】
     * エラーメッセージが表示されていること、請求ヘッダが作成されていないこと
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
        contract.ContractStartDate__c = Date.newInstance(2021, 6, 1);
        contract.ContractEndDate__c = Date.newInstance(2022, 6, 1);
        contract.Billing__c = acc.Id;
        contract.BillingPerson__c = ct.Id;
        insert contract;
        
        // 契約明細
        List<ContractDetail__c> insertCDList = new List<ContractDetail__c>();
        ContractDetail__c contractDetail1 = TestUtil.createContractDetail(contract);
        contractDetail1.No__c = 1;
        contractDetail1.ProductNameText__c = '単体試験確認用品名1';
        contractDetail1.Quantity__c = 1;
        contractDetail1.UnitPrice__c = 1000;
        contractDetail1.TaxPrice__c = 0;
        contractDetail1.Amount__c = 1000;
        contractDetail1.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
        // contractDetail1.BillingStartMonth__c = Constants.BILLING_START_MONTH;
        contractDetail1.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail1.SpecifiedMonth__c = contract.ContractStartDate__c;
        contractDetail1.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail1.Remarks__c = '単体試験確認用備考1';
        insertCDList.add(contractDetail1);

        ContractDetail__c contractDetail2 = TestUtil.createContractDetail(contract);
        contractDetail2.No__c = 2;
        contractDetail2.ProductNameText__c = '単体試験確認用品名2';
        contractDetail2.Quantity__c = 2;
        contractDetail2.UnitPrice__c = 2000;
        contractDetail2.TaxPrice__c = 0;
        contractDetail2.Amount__c = 4000;
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
        // contractDetail2.BillingStartMonth__c = Constants.BILLING_START_MONTH;
        contractDetail2.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail2.SpecifiedMonth__c = contract.ContractStartDate__c;
        contractDetail2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail2.Remarks__c = '単体試験確認用備考2';
        insertCDList.add(contractDetail2);

        ContractDetail__c contractDetail3 = TestUtil.createContractDetail(contract);
        contractDetail3.No__c = 3;
        contractDetail3.ProductNameText__c = '単体試験確認用品名3';
        contractDetail3.Quantity__c = 3;
        contractDetail3.UnitPrice__c = 3000;
        contractDetail3.TaxPrice__c = 900;
        contractDetail3.Amount__c = 9000;
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
        // contractDetail3.BillingStartMonth__c = Constants.BILLING_START_MONTH;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail3.SpecifiedMonth__c = contract.ContractStartDate__c;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        insertCDList.add(contractDetail3);

        insert insertCDList;

        Boolean result = true;
        List<ApexPages.Message> messages;

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        CreateBillingController ctrl = new CreateBillingController(stdCtrl);
        ctrl.billingDate = Date.newInstance(2021, 7, 1);

        try{
            ctrl.initAction();
            messages = ApexPages.getMessages();
        }catch(Exception e){
            System.debug(e);
            result = false;
        }
        Test.stopTest();

        // 検証
        System.assertEquals(result,true);
 
        System.assertEquals(1, messages.size());

        System.assertEquals('請求対象の契約明細が存在しませんでした。', messages[0].getDetail());

        List<BillingHeader__c> billingHeaderList = [SELECT Id FROM BillingHeader__c];

        System.assertEquals(0, billingHeaderList.size());
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 請求対象年月が契約終了日を超えている
     * 【結果】
     * 請求可能な期間外エラーメッセージが表示されること、請求ヘッダが作成されていないこと
     */
    @isTest
    public static void test_initAction_004(){
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
        contract.ContractStartDate__c = Date.newInstance(2021, 6, 1);
        contract.ContractEndDate__c = Date.newInstance(2021, 1, 1);
        contract.Billing__c = acc.Id;
        contract.BillingPerson__c = ct.Id;
        insert contract;
        
        // 契約明細
        List<ContractDetail__c> insertCDList = new List<ContractDetail__c>();
        ContractDetail__c contractDetail1 = TestUtil.createContractDetail(contract);
        contractDetail1.No__c = 1;
        contractDetail1.ProductNameText__c = '単体試験確認用品名1';
        contractDetail1.Quantity__c = 1;
        contractDetail1.UnitPrice__c = 1000;
        contractDetail1.TaxPrice__c = 0;
        contractDetail1.Amount__c = 1000;
        contractDetail1.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
        // contractDetail1.BillingStartMonth__c = Constants.BILLING_START_MONTH;
        contractDetail1.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail1.SpecifiedMonth__c = contract.ContractStartDate__c;
        contractDetail1.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail1.Remarks__c = '単体試験確認用備考1';
        insertCDList.add(contractDetail1);

        ContractDetail__c contractDetail2 = TestUtil.createContractDetail(contract);
        contractDetail2.No__c = 2;
        contractDetail2.ProductNameText__c = '単体試験確認用品名2';
        contractDetail2.Quantity__c = 2;
        contractDetail2.UnitPrice__c = 2000;
        contractDetail2.TaxPrice__c = 0;
        contractDetail2.Amount__c = 4000;
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
        // contractDetail2.BillingStartMonth__c = Constants.BILLING_START_MONTH;
        contractDetail2.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail2.SpecifiedMonth__c = contract.ContractStartDate__c;
        contractDetail2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail2.Remarks__c = '単体試験確認用備考2';
        insertCDList.add(contractDetail2);

        ContractDetail__c contractDetail3 = TestUtil.createContractDetail(contract);
        contractDetail3.No__c = 3;
        contractDetail3.ProductNameText__c = '単体試験確認用品名3';
        contractDetail3.Quantity__c = 3;
        contractDetail3.UnitPrice__c = 3000;
        contractDetail3.TaxPrice__c = 900;
        contractDetail3.Amount__c = 9000;
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
        // contractDetail3.BillingStartMonth__c = Constants.BILLING_START_MONTH;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail3.SpecifiedMonth__c = contract.ContractStartDate__c;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        insertCDList.add(contractDetail3);

        insert insertCDList;

        Boolean result = true;
        List<ApexPages.Message> messages;

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        CreateBillingController ctrl = new CreateBillingController(stdCtrl);
        ctrl.billingDate = Date.newInstance(2021, 7, 1);

        try{
            ctrl.initAction();
            messages = ApexPages.getMessages();
        }catch(Exception e){
            System.debug(e);
            result = false;
        }
        Test.stopTest();

        // 検証
        System.assertEquals(result,true);
 
        System.assertEquals(1, messages.size());

        System.assertEquals('対象の契約は請求可能な期間ではありません。【契約終了日】2021/01/01【請求対象年月】' + Date.newInstance(2021, 7, 1).format(), messages[0].getDetail());

        List<BillingHeader__c> billingHeaderList = [SELECT Id FROM BillingHeader__c];

        System.assertEquals(0, billingHeaderList.size());
    }

    /**
     * 【対象】
     * moveBillingHeaderAction
     * 【条件】
     * -
     * 【結果】
     * 正常に実行されること
     */
    @isTest
    public static void test_moveBillingHeaderAction_001() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
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
        contract.ContractStartDate__c = Date.newInstance(2021, 6, 1);
        contract.ContractEndDate__c = Date.newInstance(2022, 6, 1);
        contract.Billing__c = acc.Id;
        contract.BillingPerson__c = ct.Id;
        insert contract;
        
        // 契約明細
        List<ContractDetail__c> insertCDList = new List<ContractDetail__c>();
        ContractDetail__c contractDetail1 = TestUtil.createContractDetail(contract);
        contractDetail1.No__c = 1;
        contractDetail1.ProductNameText__c = '単体試験確認用品名1';
        contractDetail1.Quantity__c = 1;
        contractDetail1.UnitPrice__c = 1000;
        contractDetail1.TaxPrice__c = 0;
        contractDetail1.Amount__c = 1000;
        contractDetail1.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        contractDetail1.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail1.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail1.Remarks__c = '単体試験確認用備考1';
        contractDetail1.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail1);

        ContractDetail__c contractDetail2 = TestUtil.createContractDetail(contract);
        contractDetail2.No__c = 2;
        contractDetail2.ProductNameText__c = '単体試験確認用品名2';
        contractDetail2.Quantity__c = 2;
        contractDetail2.UnitPrice__c = 2000;
        contractDetail2.TaxPrice__c = 0;
        contractDetail2.Amount__c = 4000;
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        contractDetail2.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        contractDetail2.Remarks__c = '単体試験確認用備考2';
        contractDetail2.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail2);

        ContractDetail__c contractDetail3 = TestUtil.createContractDetail(contract);
        contractDetail3.No__c = 3;
        contractDetail3.ProductNameText__c = '単体試験確認用品名3';
        contractDetail3.Quantity__c = 3;
        contractDetail3.UnitPrice__c = 3000;
        contractDetail3.TaxPrice__c = 900;
        contractDetail3.Amount__c = 9000;
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_ANNUAL;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        contractDetail3.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail3);

        insert insertCDList;
    
        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc,ct, '2021', '7');
        billH.BillingDepartment__c = 'テスト部';
        insert billH;
        
        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        CreateBillingController ctrl = new CreateBillingController(stdCtrl);
        ctrl.billingDate = Date.newInstance(2021, 7, 1);

        Boolean result = true;

        try{
            ctrl.initAction();
            ctrl.moveBillingHeaderAction();
        }catch(Exception e){
            System.debug(e);
            result = false;
        }
        Test.stopTest();

        // 検証
        System.assertEquals(result,true);
    }


    /* 請求ヘッダ */
    private static BillingHeader__c createBillingHeader(Account acc, Contact ct, String year, String month) {
        BillingHeader__c billH = new BillingHeader__c();
        billH.SearchBillingAccount__c = acc.Id;
        billH.BillingAccount__c = acc.Id;
        billH.BillingContact__c = ct.Id;
        billH.BillingYear__c = year;
        billH.BillingMonth__c = month;
        return billH;
    }
}