/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * サポートサマリページコントローラーテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/01     kikuchi     新規作成
 * 2024/12     sasaki      回答有パターンのテスト追加
 ********************************************************************************/
@isTest
public with sharing class SupportSummaryControllerTest {
    public SupportSummaryControllerTest() {

    }
    @isTest
    static void testCace01() {
        system.debug('■■■テスト準備■■■');
        // サポート対応作成
        List<TerraskySupport__c> tsList = new List<TerraskySupport__c>();
        tsList.add(createTerraskySupport('0000001', 'SkyEditor'));
        tsList.add(createTerraskySupport('0000002', 'Salesforceライセンス'));
        tsList.add(createTerraskySupport('0000003', 'mitoco'));
        tsList.add(createTerraskySupport('0000004', 'DataSpider'));
        tsList.add(createTerraskySupport('0000005', 'DCSpider'));
        tsList.add(createTerraskySupport('0000006', 'OMLINE-I'));
        tsList.add(createTerraskySupport('0000007', 'OMLINE-O'));
        tsList.add(createTerraskySupport('0000008', 'GLOVIA OM'));
        insert tsList;

        system.debug('■■■テスト実行■■■');
        Test.startTest();
            SupportSummaryController target = new SupportSummaryController();
            target.initAction();
        Test.stopTest();

        system.debug('■■■テスト検証■■■');
        System.assertEquals(target.tempList.size(), 6);
    }

    /**
     * サポート対応作成
     * @return サポート対応
     */
    private static TerraskySupport__c createTerraskySupport(String caseNo, String productTypeNm) {
        TerraskySupport__c ts = new TerraskySupport__c();
        ts.Name = caseNo + ' title';
        ts.CaseNo__c = caseNo;
        ts.Status__c = '新規';
        ts.ReceivingEmail__c = true;
        ts.ProductType__c = productTypeNm;
        ts.SupportContractFlag__c = true;
        return ts;
    }

    @isTest
    static void testCace02() {
        system.debug('■■■テスト準備■■■');
        // サポート対応作成
        List<TerraskySupport__c> tsList = new List<TerraskySupport__c>();
        tsList.add(createTerraskySupportExisting('0000001', 'SkyEditor'));
        tsList.add(createTerraskySupportExisting('0000002', 'Salesforceライセンス'));
        tsList.add(createTerraskySupportExisting('0000003', 'mitoco'));
        tsList.add(createTerraskySupportExisting('0000004', 'DataSpider'));
        tsList.add(createTerraskySupportExisting('0000005', 'DCSpider'));
        tsList.add(createTerraskySupportExisting('0000006', 'OMLINE-I'));
        tsList.add(createTerraskySupportExisting('0000007', 'OMLINE-O'));
        tsList.add(createTerraskySupportExisting('0000008', 'GLOVIA OM'));
        insert tsList;

        system.debug('■■■テスト実行■■■');
        Test.startTest();
            SupportSummaryController target = new SupportSummaryController();
            target.initAction();
        Test.stopTest();

        system.debug('■■■テスト検証■■■');
        System.assertEquals(target.tempList.size(), 6);
    }

    /**
     * 既存サポート対応作成
     * @return 既存サポート対応
     */
    private static TerraskySupport__c createTerraskySupportExisting(String caseNo, String productTypeNm) {
        TerraskySupport__c ts = new TerraskySupport__c();
        ts.Name = caseNo + ' title';
        ts.CaseNo__c = caseNo;
        ts.Status__c = 'ユーザ確認中';
        ts.ReceivingEmail__c = true;
        ts.ProductType__c = productTypeNm;
        ts.PersonName__c = 'Sky365サポート担当';

        return ts;
    }

    @isTest
    static void testCace03() {
        system.debug('■■■テスト準備■■■');
        // サポート対応作成
        List<TerraskySupport__c> tsList = new List<TerraskySupport__c>();
        tsList.add(createTerraskySupport5Day('0000001', 'SkyEditor'));
        tsList.add(createTerraskySupport5Day('0000002', 'Salesforceライセンス'));
        tsList.add(createTerraskySupport5Day('0000003', 'mitoco'));
        tsList.add(createTerraskySupport5Day('0000004', 'DataSpider'));
        tsList.add(createTerraskySupport5Day('0000005', 'DCSpider'));
        tsList.add(createTerraskySupport5Day('0000006', 'OMLINE-I'));
        tsList.add(createTerraskySupport5Day('0000007', 'OMLINE-O'));
        tsList.add(createTerraskySupport5Day('0000008', 'GLOVIA OM'));
        insert tsList;

        system.debug('■■■テスト実行■■■');
        Test.startTest();
            SupportSummaryController target = new SupportSummaryController();
            target.initAction();
        Test.stopTest();

        system.debug('■■■テスト検証■■■');
        System.assertEquals(target.tempList.size(), 6);
    }

    /**
     * 5営業日対応サポート対応作成
     * @return 5営業日対応サポート対応
     */
    private static TerraskySupport__c createTerraskySupport5Day(String caseNo, String productTypeNm) {
        TerraskySupport__c ts = new TerraskySupport__c();
        ts.Name = caseNo + ' title';
        ts.CaseNo__c = caseNo;
        ts.Status__c = 'ユーザ確認中';
        ts.ProductType__c = productTypeNm;
        ts.PersonName__c = 'Sky365サポート担当';
        ts.Day5Flg__c = true;
        return ts;
    }

}