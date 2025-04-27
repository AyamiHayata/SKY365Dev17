/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * Terraskyサポートケース５日アラート対象更新バッチテストクラス
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/06     Kikuchi     新規作成
 ********************************************************************************/
@isTest
 public with sharing class TerraskySupport5DayAlertBatchTest {
    public TerraskySupport5DayAlertBatchTest() {

    }
    @isTest
    static void testCace01() {
		system.debug('■■■テスト準備■■■');

        // サポート対応
        TerraskySupport__c ts = createTerraskySupport();

        system.debug('■■■テスト実行■■■');       

        TerraskySupport5DayAlertBatch batch = new TerraskySupport5DayAlertBatch();
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        system.debug('■■■テスト検証■■■');

        List<TerraskySupport__c> expected = [SELECT id FROM TerraskySupport__c WHERE Day5Flg__c = true];
        System.assertEquals(expected.size(), 1);
    }

    /**
     * サポート対応作成
     * @return サポート対応
     */
    private static TerraskySupport__c createTerraskySupport() {
        TerraskySupport__c ts = new TerraskySupport__c();
        ts.Name = '1234567 title';
        ts.CaseNo__c = '1234567';
        ts.ProductType__c = 'skyEditor';
        ts.Status__c = 'ユーザ確認中';
        ts.MailUpdateDate__c = Datetime.newInstance(2022, 1, 1);
        insert ts;
        return ts;
    }
}