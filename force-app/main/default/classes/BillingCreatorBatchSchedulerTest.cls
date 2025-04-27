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
private class BillingCreatorBatchSchedulerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
    }
    /**
     * 【対象】
     * execute
     * 【条件】
     * なし
     * 【結果】
     * スケジューラが実行されて請求が作成されること
     */
    @isTest
    public static void test_execute_001(){
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
        System.schedule('BillingCreatorBatchTest' , '0 0 23 * * ?', new BillingCreatorBatchScheduler());
        Test.stopTest();
    }
}