/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * SaveBillingPDFControllerテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/08/11          M.Kawasaki       New
 ********************************************************************************/
@isTest
private class SaveBillingPDFControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
    }
    /**
     * 【対象】
     * initAction
     * 【条件】
     * 
     * 【結果】
     * 
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

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        billH.BillDestination__c = '北海道札幌市北区単体試験';
        billH.Remarks__c = 'test_initAction_001';
        billH.Name = acc.Name;
        insert billH;

        // 請求
        List<Billing__c> insertBillList = new List<Billing__c>();
        for(Integer step = 0;step<5;step++){
            Billing__c billAdd = createBilling(acc, billH, constitution);
            billAdd.Name = '単体試験請求名称' + step;
            insertBillList.add(billAdd);
        }
        Billing__c billName = createBilling(acc, billH, constitution);
        billName.Name = '単体試験請求名称';
        insertBillList.add(billName);
        insert insertBillList;

        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(billH);
        SaveBillingPDFController ctrl = new SaveBillingPDFController(stdCtrl);
        ctrl.initAction();

        Test.stopTest();

        // 検証
        BillingHeader__c checkBillingHeader = [SELECT BillingNumber__c, BillingAccount__r.Name FROM BillingHeader__c];
        ContentVersion cv =  [SELECT Id, ContentDocumentId, Title FROM ContentVersion];
        String checkTitle = checkBillingHeader.BillingAccount__r.Name + '様_' + checkBillingHeader.BillingNumber__c+'.*';
        System.assert(Pattern.matches(checkTitle,cv.Title));
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
}