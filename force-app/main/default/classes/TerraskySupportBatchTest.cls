/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Terraskyサポートケース日報紐付けバッチテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/11     Kikuchi     新規作成
 ********************************************************************************/
@isTest
 public with sharing class TerraskySupportBatchTest {
    public TerraskySupportBatchTest() {

    }
    @isTest
    static void testCace01() {
		system.debug('■■■テスト準備■■■');
        // ユーザ
        User user = TestClassUtil.createUser('1','2','3');
        // 日報
        DailyReport__c dr = createDailyReport(user);
        // 日報明細
        DailyReportDetail__c rd = createDetailReport(dr, '1234567 SupportTestチケット');        
        // サポート対応
        TerraskySupport__c ts = createTerraskySupport();

        system.debug('■■■テスト実行■■■');
        
        TerraskySupportBatch batch = new TerraskySupportBatch();
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        system.debug('■■■テスト検証■■■');
        List<DailyReportDetail__c> detailList = [SELECT client2__c, project2__c, ConstitutionCommon__c, TerraskySupport__c FROM DailyReportDetail__c];
        System.assertEquals(detailList.size(), 1);
        DailyReportDetail__c detail = detailList.get(0);
        System.assertEquals(detail.TerraskySupport__c, ts.id);
    }

    /**
     * 日報作成
     * @param User ユーザ
     * @return 日報
     */
    public Static DailyReport__c createDailyReport(User u) {
        DailyReport__c dr = new DailyReport__c();
        dr.Name = 'TestUser 2021-07-01'; // 日報名
        dr.RegistDate__c = system.today(); 
        dr.User__c = u.id; // ユーザ
        dr.Shift__c = '常';
        insert dr;
        return dr;
    }

    /**
     * 日報明細作成
     * @param DailyReport__c　日報
     * @param String タイトル
     * @return 日報明細
     */
    public Static DailyReportDetail__c createDetailReport(DailyReport__c dr, String title) {
        DailyReportDetail__c rd = new DailyReportDetail__c();
        rd.Title__c       = title;       // タイトル
        rd.WorkTime__c    = 8.0;         // 稼働時間
        rd.DailyReport__c = dr.id;       // 日報
        rd.code__c = '1234567';
        rd.Project2__c = '1_問い合わせ';
        rd.Client2__c = 'サービスデスク-SVE';
        insert rd;
        return rd;
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
        insert ts;
        return ts;
    }

}