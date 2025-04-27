/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約作成コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/18          M.Miura          New
 ********************************************************************************/
@isTest
private class CreateContractControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
        
    }

    /**
     * 【対象】
     * initAction
     *
     * 【条件】
     * 見積が未承認の場合
     *
     * 【結果】
     * エラーとなり、エラーメッセージが「未承認のため契約を作成できません。」であること
     * 
     */
    @isTest
    public static void initAction_001() {

        // データ準備
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 見積
        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.ApprovalStatus__c = 'applying';
        insert quote;
        
        // 契約作成
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;

        // テスト開始
        Test.startTest();
        
        Quote__c quoteData = [SELECT Id, IsOrder__c, ApprovalStatus__c, ConstitutionCommon__c FROM Quote__c LIMIT 1];
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateContractController ctrl = new CreateContractController(stdCtrl);
        ctrl.initAction();
       
        Test.stopTest();

        // 検証
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals('未承認のため契約を作成できません。', messages[0].getDetail());
    }

    /**
     * 【対象】
     * initAction
     *
     * 【条件】
     * 既に見積から契約が作成されている場合
     *
     * 【結果】
     * エラーとなり、エラーメッセージが「既に当見積から契約が作成されています。」であること
     * 
     */
    @isTest
    public static void initAction_002() {

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
        quote.IsOrder__c = true;
        insert quote;
        
        // 契約作成
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;

        // テスト開始
        Test.startTest();
        
        Quote__c quoteData = [SELECT Id, IsOrder__c, ApprovalStatus__c, ConstitutionCommon__c FROM Quote__c LIMIT 1];
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateContractController ctrl = new CreateContractController(stdCtrl);
        ctrl.initAction();
       
        Test.stopTest();

        // 検証
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals('既に当見積から契約が作成されています。', messages[0].getDetail());
    }

    /**
     * 【対象】
     * initAction
     *
     * 【条件】
     * 契約が作成されていない場合
     *
     * 【結果】
     * 契約が作成されること
     * 
     */
    @isTest
    public static void initAction_003() {

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
        
        // テスト開始
        Test.startTest();
        
        // 実行前の契約のレコード件数
        List<Contract__c> contactDataBefor = [SELECT Id, Name FROM Contract__c];
        
        Quote__c quoteData = [SELECT Id, IsOrder__c, ApprovalStatus__c, ConstitutionCommon__c FROM Quote__c LIMIT 1];
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
        CreateContractController ctrl = new CreateContractController(stdCtrl);
        ctrl.initAction();
       
        Test.stopTest();

        // 検証
        List<Contract__c> contactData = [SELECT Id, Name FROM Contract__c];
        System.assertEquals(0, contactDataBefor.size());
        System.assertEquals(1, contactData.size());
    }
    
    /**
     * 【対象】
     * moveContractAction
     *
     * 【結果】
     * エラーとならないこと
     * 
     */
    @isTest
    public static void moveContractAction_001() {

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
        
        // テスト開始
        Test.startTest();
        
        Boolean result = true;
        
        try{
            Quote__c quoteData = [SELECT Id, IsOrder__c, ApprovalStatus__c, ConstitutionCommon__c FROM Quote__c LIMIT 1];
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(quoteData);
            CreateContractController ctrl = new CreateContractController(stdCtrl);
            ctrl.initAction();
            ctrl.moveContractAction();
        } catch(Exception e) {
            result = false;
        }    
       
        Test.stopTest();

        // 検証
        System.assertEquals(true, result);
    }
    
}