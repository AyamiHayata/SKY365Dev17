/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 請求作成テストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/07/20          R.Matsui          New
 ********************************************************************************/
@isTest
private class BillingCreatorTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
    }

    /**
     * 【対象】
     * execute
     * 【条件】
     * 請求ヘッダがすでに存在している
     * 【結果】
     * 請求ヘッダが新規作成されないこと、請求が既存の請求ヘッダに紐づいて作成されること
     */
    @isTest
    public static void test_execute_001(){
        // データ準備
        
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

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc,ct);
        billH.BillingDepartment__c = 'テスト部';
        insert billH;

        // 請求対象年月（1日）
        Date bDate = Date.newInstance(2021, 6, 1);
        List<Id> cList = new List<Id>();
        cList.add(contract.Id);
        List<BillingHeader__c> bHList = new List<BillingHeader__c>();
        bHList.add(billH);

        // テスト開始
        Test.startTest();
        BillingCreator ctrl = new BillingCreator(cList,bDate,bHList);
        ctrl.execute();

        Test.stopTest();

        // 検証

        List<String> selectDtlFields = new List<String>(	
        	BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingDetail__c> checkBillDtlList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingDetail__c'
	        	, new List<String>{ String.join(selectDtlFields,', ')}
	        )
        );
        Map<Decimal,BillingDetail__c> checkBillDtlMap = new Map<Decimal,BillingDetail__c>();
        for(BillingDetail__c bD : checkBillDtlList){
            checkBillDtlMap.put(bD.No__c,bD);
        }

        List<String> selectFields = new List<String>(	
        	Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<Billing__c> checkBillList = Database.query(
        	String.format(
        		'SELECT {0} FROM Billing__c'
	        	, new List<String>{ String.join(selectFields,', ')}
	        )
        );
        Map<String,Billing__c> checkBillMap = new Map<String,Billing__c>();
        for(Billing__c b : checkBillList){
            checkBillMap.put(b.Name,b);
            System.debug(b.Name);
        }

        List<String> selectHeaderFields = new List<String>(	
        	BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingHeader__c> checkBillHeaderList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingHeader__c'
	        	, new List<String>{ String.join(selectHeaderFields,', ')}
	        )
        );

        ID bHId = checkBillHeaderList.get(0).Id;

        // 請求ヘッダ検証：作成済の請求ヘッダに請求が紐づくこと=新規で請求ヘッダが作成されないこと
        System.assertEquals(checkBillHeaderList.size(),1);
        System.assertEquals([SELECT COUNT() FROM Billing__c WHERE BillingHeader__c =:bHId],2);

        // 請求検証：請求名が案件名と契約詳細と課税区分からできていること、作成された請求が契約と契約明細に基づいて作成されていること
        // 保守 No16 請求件名を契約名にする 
        //String checkCName1 = constitution.Name + ' ' + '初期費用' + ' ' + '（非課税）';
        //String checkCName2 = constitution.Name + ' ' + '初期費用';
        String checkCName1 = contract.Name + ' ' + '初期費用' + ' ' + '（非課税）';
        String checkCName2 = contract.Name + ' ' + '初期費用';
        System.assertEquals(checkBillMap.get(checkCName1).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName1).DetailType__c, Constants.DETAIL_TYPE_INICIAL_COST);
        System.assertEquals(checkBillMap.get(checkCName1).TaxType__c, Constants.TAX_TYPE_NO_TAX);
        System.assertEquals(checkBillMap.get(checkCName2).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName2).DetailType__c, Constants.DETAIL_TYPE_INICIAL_COST);
        System.assertEquals(checkBillMap.get(checkCName2).TaxType__c, Constants.TAX_TYPE_10);

        // 請求明細検証：請求明細と契約明細が1:1対応していること
        System.assertEquals(checkBillDtlMap.get(1).ProductNameText__c,contractDetail1.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(1).UnitPrice__c,contractDetail1.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Quantity__c,contractDetail1.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(1).Amount__c,contractDetail1.Amount__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxPrice__c,contractDetail1.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Remarks__c,contractDetail1.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxType__c,contractDetail1.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(2).ProductNameText__c,contractDetail2.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(2).UnitPrice__c,contractDetail2.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Quantity__c,contractDetail2.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(2).Amount__c,contractDetail2.Amount__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxPrice__c,contractDetail2.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Remarks__c,contractDetail2.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxType__c,contractDetail2.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(3).ProductNameText__c,contractDetail3.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(3).UnitPrice__c,contractDetail3.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Quantity__c,contractDetail3.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(3).Amount__c,contractDetail3.Amount__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxPrice__c,contractDetail3.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Remarks__c,contractDetail3.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxType__c,contractDetail3.TaxType__c);
    }

    /**
     * 【対象】
     * execute
     * 【条件】
     * 契約明細：初期費用、請求開始月=契約開始月
     * 【結果】
     * 請求ヘッダ、請求、請求明細がテストデータに基づいて作成されること
     */
    @isTest
    public static void test_execute_002(){
        
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

        // 請求対象年月（1日）
        Date bDate = Date.newInstance(2021, 6, 1);
        List<Id> cList = new List<Id>();
        cList.add(contract.Id);

        // テスト開始
        Test.startTest();
        BillingCreator ctrl = new BillingCreator(cList,bDate);
        ctrl.execute();

        Test.stopTest();

        // 検証
        // 検証内容1:それぞれの契約に対応する請求明細が存在していること->3件 ※ただし請求明細と契約は直接紐づいてない
        // 検証内容2:請求明細に対応した請求が登録されていること->2件 ※契約明細の詳細＋課税区分が2パターンある
        // 検証内容3:請求に対応した請求ヘッダが登録されていること->1件 ※↑に応じた請求ヘッダが作成される

        List<String> selectDtlFields = new List<String>(	
        	BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingDetail__c> checkBillDtlList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingDetail__c'
	        	, new List<String>{ String.join(selectDtlFields,', ')}
	        )
        );
        Map<Decimal,BillingDetail__c> checkBillDtlMap = new Map<Decimal,BillingDetail__c>();
        for(BillingDetail__c bD : checkBillDtlList){
            checkBillDtlMap.put(bD.No__c,bD);
        }

        List<String> selectFields = new List<String>(	
        	Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<Billing__c> checkBillList = Database.query(
        	String.format(
        		'SELECT {0} FROM Billing__c'
	        	, new List<String>{ String.join(selectFields,', ')}
	        )
        );
        Map<String,Billing__c> checkBillMap = new Map<String,Billing__c>();
        for(Billing__c b : checkBillList){
            checkBillMap.put(b.Name,b);
            System.debug(b.Name);
        }

        List<String> selectHeaderFields = new List<String>(	
        	BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingHeader__c> checkBillHeaderList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingHeader__c'
	        	, new List<String>{ String.join(selectHeaderFields,', ')}
	        )
        );
        // 請求ヘッダ検証：請求先取引先がテストで用意した取引先であること
        System.assertEquals(checkBillHeaderList.get(0).BillingAccount__c, acc.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingContact__c, ct.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingYear__c, String.valueOf(bDate.year()));
        System.assertEquals(checkBillHeaderList.get(0).BillingMonth__c, String.valueOf(bDate.month()));

        // 請求検証：請求名が案件名と契約詳細と課税区分からできていること、作成された請求が契約と契約明細に基づいて作成されていること
        // 保守 No16 請求件名を契約名にする 
        //String checkCName1 = constitution.Name + ' ' + '初期費用' + ' ' + '（非課税）';
        //String checkCName2 = constitution.Name + ' ' + '初期費用';
        String checkCName1 = contract.Name + ' ' + '初期費用' + ' ' + '（非課税）';
        String checkCName2 = contract.Name + ' ' + '初期費用';
        System.assertEquals(checkBillMap.get(checkCName1).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName1).DetailType__c, Constants.DETAIL_TYPE_INICIAL_COST);
        System.assertEquals(checkBillMap.get(checkCName1).TaxType__c, Constants.TAX_TYPE_NO_TAX);
        System.assertEquals(checkBillMap.get(checkCName2).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName2).DetailType__c, Constants.DETAIL_TYPE_INICIAL_COST);
        System.assertEquals(checkBillMap.get(checkCName2).TaxType__c, Constants.TAX_TYPE_10);

        // 請求明細検証：請求明細と契約明細が1:1対応していること
        System.assertEquals(checkBillDtlMap.get(1).ProductNameText__c,contractDetail1.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(1).UnitPrice__c,contractDetail1.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Quantity__c,contractDetail1.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(1).Amount__c,contractDetail1.Amount__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxPrice__c,contractDetail1.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Remarks__c,contractDetail1.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxType__c,contractDetail1.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(2).ProductNameText__c,contractDetail2.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(2).UnitPrice__c,contractDetail2.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Quantity__c,contractDetail2.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(2).Amount__c,contractDetail2.Amount__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxPrice__c,contractDetail2.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Remarks__c,contractDetail2.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxType__c,contractDetail2.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(3).ProductNameText__c,contractDetail3.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(3).UnitPrice__c,contractDetail3.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Quantity__c,contractDetail3.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(3).Amount__c,contractDetail3.Amount__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxPrice__c,contractDetail3.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Remarks__c,contractDetail3.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxType__c,contractDetail3.TaxType__c);
    }

    /**
     * 【対象】
     * execute
     * 【条件】
     * 契約明細：初期費用、請求開始月=契約開始翌月
     * 【結果】
     * 請求ヘッダ、請求、請求明細がテストデータに基づいて作成されること
     */
    @isTest
    public static void test_execute_003(){
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
        // contractDetail1.BillingStartMonth__c = Constants.BILLING_START_NEXT_MONTH;
        contractDetail1.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail1.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
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
        // contractDetail2.BillingStartMonth__c = Constants.BILLING_START_NEXT_MONTH;
        contractDetail2.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail2.SpecifiedMonth__c =  Date.newInstance(2021, 7, 1);
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
        // contractDetail3.BillingStartMonth__c = Constants.BILLING_START_NEXT_MONTH;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail3.SpecifiedMonth__c =  Date.newInstance(2021, 7, 1);
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        insertCDList.add(contractDetail3);

        insert insertCDList;

        // 請求対象年月（1日）
        Date bDate = Date.newInstance(2021, 7, 1);
        List<Id> cList = new List<Id>();
        cList.add(contract.Id);

        // テスト開始
        Test.startTest();
        BillingCreator ctrl = new BillingCreator(cList,bDate);
        ctrl.execute();

        Test.stopTest();

        // 検証
        // 検証内容1:それぞれの契約に対応する請求明細が存在していること->3件 ※ただし請求明細と契約は直接紐づいてない
        // 検証内容2:請求明細に対応した請求が登録されていること->2件 ※契約明細の詳細＋課税区分が2パターンある
        // 検証内容3:請求に対応した請求ヘッダが登録されていること->1件 ※↑に応じた請求ヘッダが作成される

        List<String> selectDtlFields = new List<String>(	
        	BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingDetail__c> checkBillDtlList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingDetail__c'
	        	, new List<String>{ String.join(selectDtlFields,', ')}
	        )
        );
        Map<Decimal,BillingDetail__c> checkBillDtlMap = new Map<Decimal,BillingDetail__c>();
        for(BillingDetail__c bD : checkBillDtlList){
            checkBillDtlMap.put(bD.No__c,bD);
        }

        List<String> selectFields = new List<String>(	
        	Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<Billing__c> checkBillList = Database.query(
        	String.format(
        		'SELECT {0} FROM Billing__c'
	        	, new List<String>{ String.join(selectFields,', ')}
	        )
        );
        Map<String,Billing__c> checkBillMap = new Map<String,Billing__c>();
        for(Billing__c b : checkBillList){
            checkBillMap.put(b.Name,b);
            System.debug(b.Name);
        }

        List<String> selectHeaderFields = new List<String>(	
        	BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingHeader__c> checkBillHeaderList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingHeader__c'
	        	, new List<String>{ String.join(selectHeaderFields,', ')}
	        )
        );
        // 請求ヘッダ検証：請求先取引先がテストで用意した取引先であること
        System.assertEquals(checkBillHeaderList.get(0).BillingAccount__c, acc.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingContact__c, ct.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingYear__c, String.valueOf(bDate.year()));
        System.assertEquals(checkBillHeaderList.get(0).BillingMonth__c, String.valueOf(bDate.month()));

        // 請求検証：請求名が案件名と契約詳細と課税区分からできていること、作成された請求が契約と契約明細に基づいて作成されていること
        // 保守 No16 請求件名を契約名にする         
        //String checkCName1 = constitution.Name + ' ' + '初期費用' + ' ' + '（非課税）';
        //String checkCName2 = constitution.Name + ' ' + '初期費用';
        String checkCName1 = contract.Name + ' ' + '初期費用' + ' ' + '（非課税）';
        String checkCName2 = contract.Name + ' ' + '初期費用';
        System.assertEquals(checkBillMap.get(checkCName1).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName1).DetailType__c, Constants.DETAIL_TYPE_INICIAL_COST);
        System.assertEquals(checkBillMap.get(checkCName1).TaxType__c, Constants.TAX_TYPE_NO_TAX);
        System.assertEquals(checkBillMap.get(checkCName2).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName2).DetailType__c, Constants.DETAIL_TYPE_INICIAL_COST);
        System.assertEquals(checkBillMap.get(checkCName2).TaxType__c, Constants.TAX_TYPE_10);

        // 請求明細検証：請求明細と契約明細が1:1対応していること
        System.assertEquals(checkBillDtlMap.get(1).ProductNameText__c,contractDetail1.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(1).UnitPrice__c,contractDetail1.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Quantity__c,contractDetail1.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(1).Amount__c,contractDetail1.Amount__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxPrice__c,contractDetail1.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Remarks__c,contractDetail1.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxType__c,contractDetail1.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(2).ProductNameText__c,contractDetail2.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(2).UnitPrice__c,contractDetail2.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Quantity__c,contractDetail2.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(2).Amount__c,contractDetail2.Amount__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxPrice__c,contractDetail2.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Remarks__c,contractDetail2.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxType__c,contractDetail2.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(3).ProductNameText__c,contractDetail3.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(3).UnitPrice__c,contractDetail3.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Quantity__c,contractDetail3.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(3).Amount__c,contractDetail3.Amount__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxPrice__c,contractDetail3.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Remarks__c,contractDetail3.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxType__c,contractDetail3.TaxType__c);
    }

    /**
     * 【対象】
     * execute
     * 【条件】
     * 契約明細：初期費用、請求開始月=指定月
     * 【結果】
     * 請求ヘッダ、請求、請求明細がテストデータに基づいて作成されること
     */
    @isTest
    public static void test_execute_004(){
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
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
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
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        contractDetail3.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail3);

        insert insertCDList;

        // 請求対象年月（1日）
        Date bDate = Date.newInstance(2021, 7, 1);
        List<Id> cList = new List<Id>();
        cList.add(contract.Id);

        // テスト開始
        Test.startTest();
        BillingCreator ctrl = new BillingCreator(cList,bDate);
        ctrl.execute();

        Test.stopTest();

        // 検証
        // 検証内容1:それぞれの契約に対応する請求明細が存在していること->3件 ※ただし請求明細と契約は直接紐づいてない
        // 検証内容2:請求明細に対応した請求が登録されていること->2件 ※契約明細の詳細＋課税区分が2パターンある
        // 検証内容3:請求に対応した請求ヘッダが登録されていること->1件 ※↑に応じた請求ヘッダが作成される

        List<String> selectDtlFields = new List<String>(	
        	BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingDetail__c> checkBillDtlList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingDetail__c'
	        	, new List<String>{ String.join(selectDtlFields,', ')}
	        )
        );
        Map<Decimal,BillingDetail__c> checkBillDtlMap = new Map<Decimal,BillingDetail__c>();
        for(BillingDetail__c bD : checkBillDtlList){
            checkBillDtlMap.put(bD.No__c,bD);
        }

        List<String> selectFields = new List<String>(	
        	Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<Billing__c> checkBillList = Database.query(
        	String.format(
        		'SELECT {0} FROM Billing__c'
	        	, new List<String>{ String.join(selectFields,', ')}
	        )
        );
        Map<String,Billing__c> checkBillMap = new Map<String,Billing__c>();
        for(Billing__c b : checkBillList){
            checkBillMap.put(b.Name,b);
            System.debug(b.Name);
        }

        List<String> selectHeaderFields = new List<String>(	
        	BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingHeader__c> checkBillHeaderList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingHeader__c'
	        	, new List<String>{ String.join(selectHeaderFields,', ')}
	        )
        );
        // 請求ヘッダ検証：請求先取引先がテストで用意した取引先であること
        System.assertEquals(checkBillHeaderList.get(0).BillingAccount__c, acc.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingContact__c, ct.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingYear__c, String.valueOf(bDate.year()));
        System.assertEquals(checkBillHeaderList.get(0).BillingMonth__c, String.valueOf(bDate.month()));

        // 請求検証：請求名が案件名と契約詳細と課税区分からできていること、作成された請求が契約と契約明細に基づいて作成されていること
        // 保守 No16 請求件名を契約名にする 
        //String checkCName1 = constitution.Name + ' ' + '初期費用' + ' ' + '（非課税）';
        //String checkCName2 = constitution.Name + ' ' + '初期費用';
        String checkCName1 = contract.Name + ' ' + '初期費用' + ' ' + '（非課税）';
        String checkCName2 = contract.Name + ' ' + '初期費用';
        System.assertEquals(checkBillMap.get(checkCName1).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName1).DetailType__c, Constants.DETAIL_TYPE_INICIAL_COST);
        System.assertEquals(checkBillMap.get(checkCName1).TaxType__c, Constants.TAX_TYPE_NO_TAX);
        System.assertEquals(checkBillMap.get(checkCName2).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName2).DetailType__c, Constants.DETAIL_TYPE_INICIAL_COST);
        System.assertEquals(checkBillMap.get(checkCName2).TaxType__c, Constants.TAX_TYPE_10);

        // 請求明細検証：請求明細と契約明細が1:1対応していること
        System.assertEquals(checkBillDtlMap.get(1).ProductNameText__c,contractDetail1.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(1).UnitPrice__c,contractDetail1.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Quantity__c,contractDetail1.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(1).Amount__c,contractDetail1.Amount__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxPrice__c,contractDetail1.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Remarks__c,contractDetail1.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxType__c,contractDetail1.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(2).ProductNameText__c,contractDetail2.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(2).UnitPrice__c,contractDetail2.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Quantity__c,contractDetail2.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(2).Amount__c,contractDetail2.Amount__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxPrice__c,contractDetail2.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Remarks__c,contractDetail2.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxType__c,contractDetail2.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(3).ProductNameText__c,contractDetail3.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(3).UnitPrice__c,contractDetail3.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Quantity__c,contractDetail3.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(3).Amount__c,contractDetail3.Amount__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxPrice__c,contractDetail3.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Remarks__c,contractDetail3.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxType__c,contractDetail3.TaxType__c);
    }

    /**
     * 【対象】
     * execute
     * 【条件】
     * 契約明細：月額費用、請求開始月＝契約開始月
     * 【結果】
     * 請求ヘッダ、請求、請求明細がテストデータに基づいて作成されること
     */
    @isTest
    public static void test_execute_005(){
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
        contractDetail1.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
        contractDetail1.BillingStartMonth__c = Constants.BILLING_START_MONTH;
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
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
        contractDetail2.BillingStartMonth__c = Constants.BILLING_START_MONTH;
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
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_MONTH;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        insertCDList.add(contractDetail3);

        insert insertCDList;

        // 請求対象年月（1日）
        Date bDate = Date.newInstance(2021, 6, 1);
        List<Id> cList = new List<Id>();
        cList.add(contract.Id);

        // テスト開始
        Test.startTest();
        BillingCreator ctrl = new BillingCreator(cList,bDate);
        ctrl.execute();

        Test.stopTest();

        // 検証
        // 検証内容1:それぞれの契約に対応する請求明細が存在していること->3件 ※ただし請求明細と契約は直接紐づいてない
        // 検証内容2:請求明細に対応した請求が登録されていること->2件 ※契約明細の詳細＋課税区分が2パターンある
        // 検証内容3:請求に対応した請求ヘッダが登録されていること->1件 ※↑に応じた請求ヘッダが作成される

        List<String> selectDtlFields = new List<String>(	
        	BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingDetail__c> checkBillDtlList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingDetail__c'
	        	, new List<String>{ String.join(selectDtlFields,', ')}
	        )
        );
        Map<Decimal,BillingDetail__c> checkBillDtlMap = new Map<Decimal,BillingDetail__c>();
        for(BillingDetail__c bD : checkBillDtlList){
            checkBillDtlMap.put(bD.No__c,bD);
        }

        List<String> selectFields = new List<String>(	
        	Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<Billing__c> checkBillList = Database.query(
        	String.format(
        		'SELECT {0} FROM Billing__c'
	        	, new List<String>{ String.join(selectFields,', ')}
	        )
        );
        Map<String,Billing__c> checkBillMap = new Map<String,Billing__c>();
        for(Billing__c b : checkBillList){
            checkBillMap.put(b.Name,b);
            System.debug(b.Name);
        }

        List<String> selectHeaderFields = new List<String>(	
        	BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingHeader__c> checkBillHeaderList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingHeader__c'
	        	, new List<String>{ String.join(selectHeaderFields,', ')}
	        )
        );
        // 請求ヘッダ検証：請求先取引先がテストで用意した取引先であること
        System.assertEquals(checkBillHeaderList.get(0).BillingAccount__c, acc.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingContact__c, ct.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingYear__c, String.valueOf(bDate.year()));
        System.assertEquals(checkBillHeaderList.get(0).BillingMonth__c, String.valueOf(bDate.month()));

        // 請求検証：請求名が案件名と契約詳細と課税区分からできていること、作成された請求が契約と契約明細に基づいて作成されていること
        // 保守 No16 請求件名を契約名にする 
        //String checkCName1 = constitution.Name + ' ' + '月額費用' + ' ' + '（非課税）';
        //String checkCName2 = constitution.Name + ' ' + '月額費用';
        String checkCName1 = contract.Name + ' ' + '月額費用' + ' ' + '（非課税）';
        String checkCName2 = contract.Name + ' ' + '月額費用';
        System.assertEquals(checkBillMap.get(checkCName1).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName1).DetailType__c, Constants.DETAIL_TYPE_MONTHLY_COST);
        System.assertEquals(checkBillMap.get(checkCName1).TaxType__c, Constants.TAX_TYPE_NO_TAX);
        System.assertEquals(checkBillMap.get(checkCName2).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName2).DetailType__c, Constants.DETAIL_TYPE_MONTHLY_COST);
        System.assertEquals(checkBillMap.get(checkCName2).TaxType__c, Constants.TAX_TYPE_10);

        // 請求明細検証：請求明細と契約明細が1:1対応していること
        System.assertEquals(checkBillDtlMap.get(1).ProductNameText__c,contractDetail1.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(1).UnitPrice__c,contractDetail1.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Quantity__c,contractDetail1.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(1).Amount__c,contractDetail1.Amount__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxPrice__c,contractDetail1.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Remarks__c,contractDetail1.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxType__c,contractDetail1.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(2).ProductNameText__c,contractDetail2.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(2).UnitPrice__c,contractDetail2.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Quantity__c,contractDetail2.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(2).Amount__c,contractDetail2.Amount__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxPrice__c,contractDetail2.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Remarks__c,contractDetail2.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxType__c,contractDetail2.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(3).ProductNameText__c,contractDetail3.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(3).UnitPrice__c,contractDetail3.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Quantity__c,contractDetail3.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(3).Amount__c,contractDetail3.Amount__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxPrice__c,contractDetail3.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Remarks__c,contractDetail3.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxType__c,contractDetail3.TaxType__c);
    }

    /**
     * 【対象】
     * execute
     * 【条件】
     * 契約明細：月額費用、請求開始月＝契約開始翌月
     * 【結果】
     *  請求ヘッダ、請求、請求明細がテストデータに基づいて作成されること
     */
    @isTest
    public static void test_execute_006(){
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
        contractDetail1.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
        contractDetail1.BillingStartMonth__c = Constants.BILLING_START_NEXT_MONTH;
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
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
        contractDetail2.BillingStartMonth__c = Constants.BILLING_START_NEXT_MONTH;
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
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_NEXT_MONTH;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        insertCDList.add(contractDetail3);

        insert insertCDList;

        // 請求対象年月（1日）
        Date bDate = Date.newInstance(2021, 7, 1);
        List<Id> cList = new List<Id>();
        cList.add(contract.Id);

        // テスト開始
        Test.startTest();
        BillingCreator ctrl = new BillingCreator(cList,bDate);
        ctrl.execute();

        Test.stopTest();

        // 検証
        // 検証内容1:それぞれの契約に対応する請求明細が存在していること->3件 ※ただし請求明細と契約は直接紐づいてない
        // 検証内容2:請求明細に対応した請求が登録されていること->2件 ※契約明細の詳細＋課税区分が2パターンある
        // 検証内容3:請求に対応した請求ヘッダが登録されていること->1件 ※↑に応じた請求ヘッダが作成される

        List<String> selectDtlFields = new List<String>(	
        	BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingDetail__c> checkBillDtlList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingDetail__c'
	        	, new List<String>{ String.join(selectDtlFields,', ')}
	        )
        );
        Map<Decimal,BillingDetail__c> checkBillDtlMap = new Map<Decimal,BillingDetail__c>();
        for(BillingDetail__c bD : checkBillDtlList){
            checkBillDtlMap.put(bD.No__c,bD);
        }

        List<String> selectFields = new List<String>(	
        	Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<Billing__c> checkBillList = Database.query(
        	String.format(
        		'SELECT {0} FROM Billing__c'
	        	, new List<String>{ String.join(selectFields,', ')}
	        )
        );
        Map<String,Billing__c> checkBillMap = new Map<String,Billing__c>();
        for(Billing__c b : checkBillList){
            checkBillMap.put(b.Name,b);
            System.debug(b.Name);
        }

        List<String> selectHeaderFields = new List<String>(	
        	BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingHeader__c> checkBillHeaderList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingHeader__c'
	        	, new List<String>{ String.join(selectHeaderFields,', ')}
	        )
        );
        // 請求ヘッダ検証：請求先取引先がテストで用意した取引先であること
        System.assertEquals(checkBillHeaderList.get(0).BillingAccount__c, acc.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingContact__c, ct.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingYear__c, String.valueOf(bDate.year()));
        System.assertEquals(checkBillHeaderList.get(0).BillingMonth__c, String.valueOf(bDate.month()));

        // 請求検証：請求名が案件名と契約詳細と課税区分からできていること、作成された請求が契約と契約明細に基づいて作成されていること
        // 保守 No16 請求件名を契約名にする 
        //String checkCName1 = constitution.Name + ' ' + '月額費用' + ' ' + '（非課税）';
        //String checkCName2 = constitution.Name + ' ' + '月額費用';
        String checkCName1 = contract.Name + ' ' + '月額費用' + ' ' + '（非課税）';
        String checkCName2 = contract.Name + ' ' + '月額費用';        
        System.assertEquals(checkBillMap.get(checkCName1).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName1).DetailType__c, Constants.DETAIL_TYPE_MONTHLY_COST);
        System.assertEquals(checkBillMap.get(checkCName1).TaxType__c, Constants.TAX_TYPE_NO_TAX);
        System.assertEquals(checkBillMap.get(checkCName2).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName2).DetailType__c, Constants.DETAIL_TYPE_MONTHLY_COST);
        System.assertEquals(checkBillMap.get(checkCName2).TaxType__c, Constants.TAX_TYPE_10);

        // 請求明細検証：請求明細と契約明細が1:1対応していること
        System.assertEquals(checkBillDtlMap.get(1).ProductNameText__c,contractDetail1.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(1).UnitPrice__c,contractDetail1.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Quantity__c,contractDetail1.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(1).Amount__c,contractDetail1.Amount__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxPrice__c,contractDetail1.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Remarks__c,contractDetail1.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxType__c,contractDetail1.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(2).ProductNameText__c,contractDetail2.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(2).UnitPrice__c,contractDetail2.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Quantity__c,contractDetail2.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(2).Amount__c,contractDetail2.Amount__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxPrice__c,contractDetail2.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Remarks__c,contractDetail2.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxType__c,contractDetail2.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(3).ProductNameText__c,contractDetail3.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(3).UnitPrice__c,contractDetail3.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Quantity__c,contractDetail3.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(3).Amount__c,contractDetail3.Amount__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxPrice__c,contractDetail3.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Remarks__c,contractDetail3.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxType__c,contractDetail3.TaxType__c);
    }

    /**
     * 【対象】
     * execute
     * 【条件】
     * 契約明細：月額費用、請求開始月＝指定月
     * 【結果】
     *  請求ヘッダ、請求、請求明細がテストデータに基づいて作成されること
     */
    @isTest
    public static void test_execute_007(){
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
        contractDetail1.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
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
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
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
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        contractDetail3.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail3);

        insert insertCDList;

        // 請求対象年月（1日）
        Date bDate = Date.newInstance(2021, 7, 1);
        List<Id> cList = new List<Id>();
        cList.add(contract.Id);

        // テスト開始
        Test.startTest();
        BillingCreator ctrl = new BillingCreator(cList,bDate);
        ctrl.execute();

        Test.stopTest();

        // 検証
        // 検証内容1:それぞれの契約に対応する請求明細が存在していること->3件 ※ただし請求明細と契約は直接紐づいてない
        // 検証内容2:請求明細に対応した請求が登録されていること->2件 ※契約明細の詳細＋課税区分が2パターンある
        // 検証内容3:請求に対応した請求ヘッダが登録されていること->1件 ※↑に応じた請求ヘッダが作成される

        List<String> selectDtlFields = new List<String>(	
        	BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingDetail__c> checkBillDtlList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingDetail__c'
	        	, new List<String>{ String.join(selectDtlFields,', ')}
	        )
        );
        Map<Decimal,BillingDetail__c> checkBillDtlMap = new Map<Decimal,BillingDetail__c>();
        for(BillingDetail__c bD : checkBillDtlList){
            checkBillDtlMap.put(bD.No__c,bD);
        }

        List<String> selectFields = new List<String>(	
        	Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<Billing__c> checkBillList = Database.query(
        	String.format(
        		'SELECT {0} FROM Billing__c'
	        	, new List<String>{ String.join(selectFields,', ')}
	        )
        );
        Map<String,Billing__c> checkBillMap = new Map<String,Billing__c>();
        for(Billing__c b : checkBillList){
            checkBillMap.put(b.Name,b);
            System.debug(b.Name);
        }

        List<String> selectHeaderFields = new List<String>(	
        	BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingHeader__c> checkBillHeaderList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingHeader__c'
	        	, new List<String>{ String.join(selectHeaderFields,', ')}
	        )
        );
        // 請求ヘッダ検証：請求先取引先がテストで用意した取引先であること
        System.assertEquals(checkBillHeaderList.get(0).BillingAccount__c, acc.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingContact__c, ct.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingYear__c, String.valueOf(bDate.year()));
        System.assertEquals(checkBillHeaderList.get(0).BillingMonth__c, String.valueOf(bDate.month()));

        // 請求検証：請求名が案件名と契約詳細と課税区分からできていること、作成された請求が契約と契約明細に基づいて作成されていること
        // 保守 No16 請求件名を契約名にする
        //String checkCName1 = constitution.Name + ' ' + '月額費用' + ' ' + '（非課税）';
        //String checkCName2 = constitution.Name + ' ' + '月額費用';
        String checkCName1 = contract.Name + ' ' + '月額費用' + ' ' + '（非課税）';
        String checkCName2 = contract.Name + ' ' + '月額費用';
        System.assertEquals(checkBillMap.get(checkCName1).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName1).DetailType__c, Constants.DETAIL_TYPE_MONTHLY_COST);
        System.assertEquals(checkBillMap.get(checkCName1).TaxType__c, Constants.TAX_TYPE_NO_TAX);
        System.assertEquals(checkBillMap.get(checkCName2).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName2).DetailType__c, Constants.DETAIL_TYPE_MONTHLY_COST);
        System.assertEquals(checkBillMap.get(checkCName2).TaxType__c, Constants.TAX_TYPE_10);

        // 請求明細検証：請求明細と契約明細が1:1対応していること
        System.assertEquals(checkBillDtlMap.get(1).ProductNameText__c,contractDetail1.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(1).UnitPrice__c,contractDetail1.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Quantity__c,contractDetail1.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(1).Amount__c,contractDetail1.Amount__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxPrice__c,contractDetail1.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Remarks__c,contractDetail1.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxType__c,contractDetail1.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(2).ProductNameText__c,contractDetail2.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(2).UnitPrice__c,contractDetail2.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Quantity__c,contractDetail2.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(2).Amount__c,contractDetail2.Amount__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxPrice__c,contractDetail2.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Remarks__c,contractDetail2.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxType__c,contractDetail2.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(3).ProductNameText__c,contractDetail3.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(3).UnitPrice__c,contractDetail3.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Quantity__c,contractDetail3.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(3).Amount__c,contractDetail3.Amount__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxPrice__c,contractDetail3.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Remarks__c,contractDetail3.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxType__c,contractDetail3.TaxType__c);
    }

    /**
     * 【対象】
     * execute
     * 【条件】
     * 契約明細：年払い
     * 【結果】
     *  請求ヘッダ、請求、請求明細がテストデータに基づいて作成されること
     */
    @isTest
    public static void test_execute_008(){
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

        // 請求対象年月（1日）
        Date bDate = Date.newInstance(2021, 7, 1);
        List<Id> cList = new List<Id>();
        cList.add(contract.Id);

        // テスト開始
        Test.startTest();
        BillingCreator ctrl = new BillingCreator(cList,bDate);
        ctrl.execute();

        Test.stopTest();

        // 検証
        // 検証内容1:それぞれの契約に対応する請求明細が存在していること->3件 ※ただし請求明細と契約は直接紐づいてない
        // 検証内容2:請求明細に対応した請求が登録されていること->2件 ※契約明細の詳細＋課税区分が2パターンある
        // 検証内容3:請求に対応した請求ヘッダが登録されていること->1件 ※↑に応じた請求ヘッダが作成される

        List<String> selectDtlFields = new List<String>(	
        	BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingDetail__c> checkBillDtlList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingDetail__c'
	        	, new List<String>{ String.join(selectDtlFields,', ')}
	        )
        );
        Map<Decimal,BillingDetail__c> checkBillDtlMap = new Map<Decimal,BillingDetail__c>();
        for(BillingDetail__c bD : checkBillDtlList){
            checkBillDtlMap.put(bD.No__c,bD);
        }

        List<String> selectFields = new List<String>(	
        	Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<Billing__c> checkBillList = Database.query(
        	String.format(
        		'SELECT {0} FROM Billing__c'
	        	, new List<String>{ String.join(selectFields,', ')}
	        )
        );
        Map<String,Billing__c> checkBillMap = new Map<String,Billing__c>();
        for(Billing__c b : checkBillList){
            checkBillMap.put(b.Name,b);
            System.debug(b.Name);
        }

        List<String> selectHeaderFields = new List<String>(	
        	BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingHeader__c> checkBillHeaderList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingHeader__c'
	        	, new List<String>{ String.join(selectHeaderFields,', ')}
	        )
        );
        // 請求ヘッダ検証：請求先取引先がテストで用意した取引先であること
        System.assertEquals(checkBillHeaderList.get(0).BillingAccount__c, acc.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingContact__c, ct.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingYear__c, String.valueOf(bDate.year()));
        System.assertEquals(checkBillHeaderList.get(0).BillingMonth__c, String.valueOf(bDate.month()));

        // 請求検証：請求名が案件名と契約詳細と課税区分からできていること、作成された請求が契約と契約明細に基づいて作成されていること
        // 保守 No16 請求件名を契約名にする
        //String checkCName1 = constitution.Name + ' ' + '年払い' + ' ' + '（非課税）';
        //String checkCName2 = constitution.Name + ' ' + '年払い';
        String checkCName1 = contract.Name + ' ' + '年払い' + ' ' + '（非課税）';
        String checkCName2 = contract.Name + ' ' + '年払い';
        System.assertEquals(checkBillMap.get(checkCName1).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName1).DetailType__c, Constants.DETAIL_TYPE_ANNUAL);
        System.assertEquals(checkBillMap.get(checkCName1).TaxType__c, Constants.TAX_TYPE_NO_TAX);
        System.assertEquals(checkBillMap.get(checkCName2).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName2).DetailType__c, Constants.DETAIL_TYPE_ANNUAL);
        System.assertEquals(checkBillMap.get(checkCName2).TaxType__c, Constants.TAX_TYPE_10);

        // 請求明細検証：請求明細と契約明細が1:1対応していること
        System.assertEquals(checkBillDtlMap.get(1).ProductNameText__c,contractDetail1.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(1).UnitPrice__c,contractDetail1.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Quantity__c,contractDetail1.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(1).Amount__c,contractDetail1.Amount__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxPrice__c,contractDetail1.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Remarks__c,contractDetail1.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxType__c,contractDetail1.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(2).ProductNameText__c,contractDetail2.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(2).UnitPrice__c,contractDetail2.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Quantity__c,contractDetail2.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(2).Amount__c,contractDetail2.Amount__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxPrice__c,contractDetail2.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Remarks__c,contractDetail2.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxType__c,contractDetail2.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(3).ProductNameText__c,contractDetail3.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(3).UnitPrice__c,contractDetail3.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Quantity__c,contractDetail3.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(3).Amount__c,contractDetail3.Amount__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxPrice__c,contractDetail3.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Remarks__c,contractDetail3.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxType__c,contractDetail3.TaxType__c);
    }

    /**
     * 【対象】
     * execute
     * 【条件】
     * 契約明細：スポット
     * 【結果】
     *  請求ヘッダ、請求、請求明細がテストデータに基づいて作成されること
     */
    @isTest
    public static void test_execute_009(){
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
        contract.BillingPerson__c = ct.Id;
        contract.PaymentCondition__c = '月末締め翌々月末日';
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
        contractDetail1.DetailType__c = Constants.DETAIL_TYPE_SPOT;
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
        contractDetail2.DetailType__c = Constants.DETAIL_TYPE_SPOT;
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
        contractDetail3.DetailType__c = Constants.DETAIL_TYPE_SPOT;
        contractDetail3.BillingStartMonth__c = Constants.BILLING_START_SPECIFIED_MONTH;
        contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
        contractDetail3.Remarks__c = '単体試験確認用備考3';
        contractDetail3.SpecifiedMonth__c = Date.newInstance(2021, 7, 1);
        insertCDList.add(contractDetail3);

        insert insertCDList;

        // 請求対象年月（1日）
        Date bDate = Date.newInstance(2021, 7, 1);
        List<Id> cList = new List<Id>();
        cList.add(contract.Id);

        // テスト開始
        Test.startTest();
        BillingCreator ctrl = new BillingCreator(cList,bDate);
        ctrl.execute();

        Test.stopTest();

        // 検証
        // 検証内容1:それぞれの契約に対応する請求明細が存在していること->3件 ※ただし請求明細と契約は直接紐づいてない
        // 検証内容2:請求明細に対応した請求が登録されていること->2件 ※契約明細の詳細＋課税区分が2パターンある
        // 検証内容3:請求に対応した請求ヘッダが登録されていること->1件 ※↑に応じた請求ヘッダが作成される

        List<String> selectDtlFields = new List<String>(	
        	BillingDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingDetail__c> checkBillDtlList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingDetail__c'
	        	, new List<String>{ String.join(selectDtlFields,', ')}
	        )
        );
        Map<Decimal,BillingDetail__c> checkBillDtlMap = new Map<Decimal,BillingDetail__c>();
        for(BillingDetail__c bD : checkBillDtlList){
            checkBillDtlMap.put(bD.No__c,bD);
        }

        List<String> selectFields = new List<String>(	
        	Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<Billing__c> checkBillList = Database.query(
        	String.format(
        		'SELECT {0} FROM Billing__c'
	        	, new List<String>{ String.join(selectFields,', ')}
	        )
        );
        Map<String,Billing__c> checkBillMap = new Map<String,Billing__c>();
        for(Billing__c b : checkBillList){
            checkBillMap.put(b.Name,b);
            System.debug(b.Name);
        }

        List<String> selectHeaderFields = new List<String>(	
        	BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );	
        List<BillingHeader__c> checkBillHeaderList = Database.query(
        	String.format(
        		'SELECT {0} FROM BillingHeader__c'
	        	, new List<String>{ String.join(selectHeaderFields,', ')}
	        )
        );
        // 請求ヘッダ検証：請求先取引先がテストで用意した取引先であること
        System.assertEquals(checkBillHeaderList.get(0).BillingAccount__c, acc.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingContact__c, ct.Id);
        System.assertEquals(checkBillHeaderList.get(0).BillingYear__c, String.valueOf(bDate.year()));
        System.assertEquals(checkBillHeaderList.get(0).BillingMonth__c, String.valueOf(bDate.month()));

        // 請求検証：請求名が案件名と契約詳細と課税区分からできていること、作成された請求が契約と契約明細に基づいて作成されていること
        // 保守 No16 請求件名を契約名にする 
        //String checkCName1 = constitution.Name + ' ' + 'スポット' + ' ' + '（非課税）';
        //String checkCName2 = constitution.Name + ' ' + 'スポット';
        String checkCName1 = contract.Name + ' ' + 'スポット' + ' ' + '（非課税）';
        String checkCName2 = contract.Name + ' ' + 'スポット';
        System.assertEquals(checkBillMap.get(checkCName1).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName1).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName1).DetailType__c, Constants.DETAIL_TYPE_SPOT);
        System.assertEquals(checkBillMap.get(checkCName1).TaxType__c, Constants.TAX_TYPE_NO_TAX);
        System.assertEquals(checkBillMap.get(checkCName2).Contract__c, contract.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Account__c, acc.Id);
        System.assertEquals(checkBillMap.get(checkCName2).Constitution_Common__c, constitution.Id);
        System.assertEquals(checkBillMap.get(checkCName2).DetailType__c, Constants.DETAIL_TYPE_SPOT);
        System.assertEquals(checkBillMap.get(checkCName2).TaxType__c, Constants.TAX_TYPE_10);

        // 請求明細検証：請求明細と契約明細が1:1対応していること
        System.assertEquals(checkBillDtlMap.get(1).ProductNameText__c,contractDetail1.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(1).UnitPrice__c,contractDetail1.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Quantity__c,contractDetail1.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(1).Amount__c,contractDetail1.Amount__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxPrice__c,contractDetail1.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(1).Remarks__c,contractDetail1.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(1).TaxType__c,contractDetail1.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(2).ProductNameText__c,contractDetail2.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(2).UnitPrice__c,contractDetail2.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Quantity__c,contractDetail2.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(2).Amount__c,contractDetail2.Amount__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxPrice__c,contractDetail2.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(2).Remarks__c,contractDetail2.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(2).TaxType__c,contractDetail2.TaxType__c);
        System.assertEquals(checkBillDtlMap.get(3).ProductNameText__c,contractDetail3.ProductNameText__c);
        System.assertEquals(checkBillDtlMap.get(3).UnitPrice__c,contractDetail3.UnitPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Quantity__c,contractDetail3.Quantity__c);
        System.assertEquals(checkBillDtlMap.get(3).Amount__c,contractDetail3.Amount__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxPrice__c,contractDetail3.TaxPrice__c);
        System.assertEquals(checkBillDtlMap.get(3).Remarks__c,contractDetail3.Remarks__c);
        System.assertEquals(checkBillDtlMap.get(3).TaxType__c,contractDetail3.TaxType__c);
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
}