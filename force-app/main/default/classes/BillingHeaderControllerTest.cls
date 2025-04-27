/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 請求ヘッダコントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/09/01          M.Kawasaki          New
 ********************************************************************************/
@isTest
private class BillingHeaderControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる

    }

    /**
     * 【対象】
     * 
     * 【結果】
     * 
     */
    @isTest
    public static void test_billingCheckUpdate() {
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

        // 契約
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;

        // 契約明細
        ContractDetail__c contractDetail = TestUtil.createContractDetail(contract);
        contractDetail.No__c = 2;
        insert contractDetail;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        billH.IsInvoiceSending__c = false;
        billH.IsDeposited__c = false;
        insert billH;

        // テスト開始
        Test.startTest();
        billH.IsDeposited__c = true;
        billH.IsInvoiceSending__c = true;
        BillingHeaderController.billingCheckUpdate(billH);
        Test.stopTest();

        Id targetId = billH.Id;
        BillingHeader__c resltHeader = [SELECT IsDeposited__c, IsInvoiceSending__c FROM BillingHeader__c WHERE ID=:targetId LIMIT 1 ];

        // 検証
        System.assert(resltHeader.IsDeposited__c);
        System.assert(resltHeader.IsInvoiceSending__c);
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