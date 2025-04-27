/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * SaveQuotePDFControllerテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/07/28          R.Matsui          New
 ********************************************************************************/
@isTest
private class SaveQuotePDFControllerTest {
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
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quote);
        SaveQuotePDFController ctrl = new SaveQuotePDFController(stdCtrl);
        ctrl.initAction();

        Test.stopTest();

        // 検証
        Quote__c checkQuote = [SELECT QuoteNumber__c, ConstitutionCommon__r.Name FROM Quote__c];
        ContentVersion cv =  [SELECT Id, ContentDocumentId, Title FROM ContentVersion];
        String checkTitle = checkQuote.ConstitutionCommon__r.Name + '_' + checkQuote.QuoteNumber__c+'.*';
        System.assert(Pattern.matches(checkTitle,cv.Title));
    }
}