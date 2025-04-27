/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約トリガハンドラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/10          M.Kawasaki       New
 ********************************************************************************/
@isTest
private class ContractTriggerHandlerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
        
    }

    /**
     * 【対象】
     * beforeDelete
     * 【条件】
     * 正常系：見積に対する契約が作成されている状態で契約を削除する
     * 【結果】
     * 見積の受注済フラグがOFFになること
     */
    @isTest
    public static void test_beforeDelete_001() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.IsOrder__c = true;
        insert quote;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;

        // テスト開始
        Test.startTest();
        delete contract;
        Test.stopTest();
        List<Quote__c> quoteList = [SELECT Id, IsOrder__c From Quote__c WHERE ConstitutionCommon__c =: constitution.Id];

        // 検証
        System.assertEquals(quoteList.size(), 1);
        System.assertEquals(quoteList[0].IsOrder__c, false);
    }

}