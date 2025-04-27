/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約作成テストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/07/15          M.Miura          New
 ********************************************************************************/
@isTest
private class ContractCreatorTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
        
    }

    /**
     * 【対象】
     * execute
     *
     * 【条件】
     * 既存契約がある場合
     * 既存契約明細がない場合
     *
     * 【結果】
     * 契約明細が作成される
     *  No = 見積明細のNo
     * 見積が更新される
     *  受注フラグ = true
     * 
     */
    @isTest
    public static void execute_001() {

        // データ準備
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 見積
        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.ApprovalStatus__c = 'approved';
        quote.IsOrder__c = false;
        insert quote;
        
        // 見積明細
        QuoteDetail__c quoteDetail = TestUtil.createQuoteDetail(quote);
        quoteDetail.No__c = 3;
        insert quoteDetail;
        
        // 契約
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;

        // テスト開始
        Test.startTest();
        
        ContractCreator ctrl = new ContractCreator(quote.Id);
        ctrl.execute();
       
        Test.stopTest();

        // 検証
        ContractDetail__c[] resultCd = [SELECT Id, No__c FROM ContractDetail__c];
        Quote__c[] resultQt = [SELECT Id, IsOrder__c FROM Quote__c WHERE Id =:quote.Id];
        System.assertEquals(1,resultCd.size());
        System.assertEquals(3,resultCd[0].No__c);
        System.assertEquals(1,resultQt.size());
        System.assertEquals(true,resultQt[0].IsOrder__c);
        
    }

    /**
     * 【対象】
     * execute
     *
     * 【条件】
     * 既存契約、契約明細がある場合
     *
     * 【結果】
     * 契約明細が作成される
     *  No = 契約明細のNo＋見積明細のNo
     * 見積が更新される
     *  受注フラグ = true
     * 
     */
    @isTest
    public static void execute_002() {

        // データ準備
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

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

        // テスト開始
        Test.startTest();
        
        ContractCreator ctrl = new ContractCreator(quote.Id);
        ctrl.execute();
       
        Test.stopTest();

        // 検証
        ContractDetail__c[] resultCd = [SELECT Id, No__c FROM ContractDetail__c WHERE Id !=:contractDetail.Id];
        Quote__c[] resultQt = [SELECT Id, IsOrder__c FROM Quote__c WHERE Id =:quote.Id];
        System.assertEquals(1,resultCd.size());
        System.assertEquals(5,resultCd[0].No__c);
        System.assertEquals(1,resultQt.size());
        System.assertEquals(true,resultQt[0].IsOrder__c);
        
    }

    /**
     * 【対象】
     * execute
     *
     * 【条件】
     * 既存契約がない場合
     *
     * 【結果】
     * 新規契約、契約明細が作成される
     * 見積が更新される
     *  受注フラグ = true
     * 
     */
    @isTest
    public static void execute_003() {

        // データ準備
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

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

        // テスト開始
        Test.startTest();
        
        ContractCreator ctrl = new ContractCreator(quote.Id);
        ctrl.execute();
       
        Test.stopTest();

        // 検証
        Contract__c[] contract = [SELECT Id FROM Contract__c];
        ContractDetail__c[] contractDetail = [SELECT Id FROM ContractDetail__c];
        Quote__c[] resultQt = [SELECT Id, IsOrder__c FROM Quote__c WHERE Id =:quote.Id];
        System.assertEquals(1,contract.size());
        System.assertEquals(1,contractDetail.size());
        System.assertEquals(1,resultQt.size());
        System.assertEquals(true,resultQt[0].IsOrder__c);      
    }

}