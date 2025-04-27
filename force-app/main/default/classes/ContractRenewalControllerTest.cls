/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約更新処理テストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/11          M.Kawasaki       New
 ********************************************************************************/
@isTest
private class ContractRenewalControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
        
    }

    /**
     * 【対象】
     * renewalContractEndTerm
     * 【条件】
     * 正常系：３か月更新の場合
     * 【結果】
     * 契約期間に合わせ、3か月後の月末が契約終了日となること
     */
    @isTest
    public static void test_renewalContractEndTerm_001() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        Date myDate = Date.today();
        Date newDate = myDate.addMonths(-3);
        newDate = Date.newInstance(newDate.year(), newDate.month(), 1);
        contract.ContractStartDate__c = newDate; // 3か月前の１日
        contract.ContractEndDate__c = Date.newInstance(myDate.year(), myDate.month() + 1, 0); // 今月末
        contract.UpdateCycle__c = '3Months';
        insert contract;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractRenewalController ctrl = new ContractRenewalController(stdCtrl);
        ctrl.initAction();

        Id contractId = contract.Id;

        contract = getContract(contractId);

        Test.stopTest();

        // 検証
        System.assertEquals(contract.ContractEndDate__c, Date.newInstance(myDate.year(), myDate.month() + 4, 0));
    }

    /**
     * 【対象】
     * renewalContractEndTerm
     * 【条件】
     * 正常系：6か月更新の場合
     * 【結果】
     * 契約期間に合わせ、6か月後の月末が契約終了日となること
     */
    @isTest
    public static void test_renewalContractEndTerm_002() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        Date myDate = Date.today();
        Date newDate = myDate.addMonths(-6);
        newDate = Date.newInstance(newDate.year(), newDate.month(), 1);
        contract.ContractStartDate__c = newDate; // 6か月前の１日
        contract.ContractEndDate__c = Date.newInstance(myDate.year(), myDate.month() + 1, 0); // 今月末
        contract.UpdateCycle__c = '6Months';
        insert contract;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractRenewalController ctrl = new ContractRenewalController(stdCtrl);
        ctrl.initAction();

        Id contractId = contract.Id;

        contract = getContract(contractId);

        Test.stopTest();

        // 検証
        System.assertEquals(contract.ContractEndDate__c, Date.newInstance(myDate.year(), myDate.month() + 7, 0));
    }

    /**
     * 【対象】
     * renewalContractEndTerm
     * 【条件】
     * 正常系：12か月更新の場合
     * 【結果】
     * 契約期間に合わせ、12か月後の月末が契約終了日となること
     */
    @isTest
    public static void test_renewalContractEndTerm_003() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        Date myDate = Date.today();
        Date newDate = myDate.addMonths(-12);
        newDate = Date.newInstance(newDate.year(), newDate.month(), 1);
        contract.ContractStartDate__c = newDate; // 6か月前の１日
        contract.ContractEndDate__c = Date.newInstance(myDate.year(), myDate.month() + 1, 0); // 今月末
        contract.UpdateCycle__c = '12Months';
        insert contract;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractRenewalController ctrl = new ContractRenewalController(stdCtrl);
        ctrl.initAction();

        Id contractId = contract.Id;

        contract = getContract(contractId);

        Test.stopTest();

        // 検証
        System.assertEquals(contract.ContractEndDate__c, Date.newInstance(myDate.year(), myDate.month() + 13, 0));
    }

    /**
     * 【対象】
     * renewalContractEndTerm
     * 【条件】
     * 異常系：自動更新の場合
     * 【結果】
     * 契約更新処理を行えないこと
     */
    @isTest
    public static void test_renewalContractEndTerm_004() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        Date myDate = Date.today();
        Date newDate = myDate.addMonths(-6);
        newDate = Date.newInstance(newDate.year(), newDate.month(), 1);
        contract.ContractStartDate__c = newDate; // 6か月前の１日
        contract.ContractEndDate__c = Date.newInstance(myDate.year(), myDate.month() + 2, 0); // 来月末
        contract.UpdateCycle__c = '6Months';
        insert contract;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractRenewalController ctrl = new ContractRenewalController(stdCtrl);
        PageReference pr = ctrl.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(pr, null);
    }

    /**
     * 【対象】
     * renewalContractEndTerm
     * 【条件】
     * 異常系：更新月ではない場合
     * 【結果】
     * 契約更新処理を行えないこと
     */
    @isTest
    public static void test_renewalContractEndTerm_005() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        Date myDate = Date.today();
        Date newDate = myDate.addMonths(-6);
        newDate = Date.newInstance(newDate.year(), newDate.month(), 1);
        contract.ContractStartDate__c = newDate; // 6か月前の１日
        contract.ContractEndDate__c = Date.newInstance(myDate.year(), myDate.month() + 1, 0); // 今月末
        contract.UpdateCycle__c = 'auto';
        insert contract;

        // テスト開始
        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contract);
        ContractRenewalController ctrl = new ContractRenewalController(stdCtrl);
        PageReference pr = ctrl.initAction();

        Test.stopTest();

        // 検証
        System.assertEquals(pr, null);
    }

    private static Contract__c getContract(Id contractId) {

        List<String> selectFields = new List<String>(
            Contract__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        return Database.query(
            String.format(
                'SELECT {0} FROM Contract__c WHERE Id = :contractId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );
    }

}