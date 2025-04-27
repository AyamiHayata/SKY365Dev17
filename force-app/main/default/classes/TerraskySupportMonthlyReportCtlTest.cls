/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Terraskyサポート月次レポートコントローラーテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/11     Kikuchi     新規作成
 ********************************************************************************/
@isTest
public with sharing class TerraskySupportMonthlyReportCtlTest {
    public TerraskySupportMonthlyReportCtlTest() {

    }

    @isTest
    static void testCace01() {
        system.debug('■■■テスト準備■■■');
        // サポート対応作成
        List<TerraskySupport__c> supportList = new List<TerraskySupport__c>(); 
        supportList.add(createTerraskySupport('0000001', null, 'SVE: [低]標準機能について', null, 'SkyEditor', date.newInstance(2021, 9, 1), date.newInstance(2021, 10, 1))); 
        supportList.add(createTerraskySupport('0000002', null, 'SVE: [低]標準機能について', null, 'SkyEditor', date.newInstance(2021, 10, 1), date.newInstance(2021, 9, 1))); 
        supportList.add(createTerraskySupport('0000003', '0001', null, '掲示板', 'mitoco', date.newInstance(2021, 10, 1), date.newInstance(2021, 10, 1))); 
        supportList.add(createTerraskySupport('0000004', null, null, '掲示板', 'mitoco', date.newInstance(2021, 10, 1), date.newInstance(2021, 9, 1))); 
        insert supportList;
 
        // ユーザ作成
        User user = TestClassUtil.createUser('1','2','3');
        // 日報作成
        DailyReport__c dr1 = createDailyReport(user, date.newInstance(2021, 10, 1));
        DailyReport__c dr2 = createDailyReport(user, date.newInstance(2021, 10, 2));
        // 日報明細作成
        List<DailyReportDetail__c> drDetailList = new List<DailyReportDetail__c>();
        drDetailList.add(createDetailReport(dr1, '0000001', 4, 'サービスデスク-SVE', '1_問い合わせ', supportList.get(0)));
        drDetailList.add(createDetailReport(dr1, '0000001', 3, 'サービスデスク-SVE', '1_問い合わせ', supportList.get(0)));
        drDetailList.add(createDetailReport(dr1, null, 5.5, 'サービスデスク-SVE', '2_その他対応', null));
        drDetailList.add(createDetailReport(dr1, null, 0.5, 'サービスデスク-SVE', '2_その他対応', null));
        drDetailList.add(createDetailReport(dr2, '0000002', 10, 'サービスデスク-SVE', '1_問い合わせ', supportList.get(1)));
        drDetailList.add(createDetailReport(dr1, '0000003', 4, 'サービスデスク-SFDC', '1_問い合わせ', supportList.get(2)));
        drDetailList.add(createDetailReport(dr1, '0000003', 1, 'サービスデスク-SFDC', '1_問い合わせ', supportList.get(2)));
        drDetailList.add(createDetailReport(dr1, null, 1, 'サービスデスク-SFDC', '2_その他対応', null));
        drDetailList.add(createDetailReport(dr1, null, 1, 'サービスデスク-SFDC', '2_その他対応', null));
        drDetailList.add(createDetailReport(dr2, '0000004', 1, 'サービスデスク-SFDC', '1_問い合わせ', supportList.get(3)));
        insert drDetailList;
 
 
        
        system.debug('■■■テスト実行■■■');
        Test.startTest();
        TerraskySupportMonthlyReportController target = new TerraskySupportMonthlyReportController();
        target.createYear = '2021';
        target.createMonth = '10';
        target.productType = 'サービスデスク-SVE';
        target.execute();
        Test.stopTest();

        system.debug('■■■テスト検証■■■');
        System.assertEquals(target.getProductLine1().name, 'SVE: [低]標準機能について');
        System.assertEquals(target.getProductLine1().value, 1);
        System.assertEquals(target.totalWorkTimeThisMonth, 7);
        System.assertEquals(target.workTimeLastMonth, 10);
        System.assertEquals(target.workTimeEtc, 6);
        System.assertEquals(target.totalSumworkTime, 23);
    }

    @isTest
    static void testCace02() {
        system.debug('■■■テスト準備■■■');
        // サポート対応作成
        List<TerraskySupport__c> supportList = new List<TerraskySupport__c>(); 
        supportList.add(createTerraskySupport('0000001', null, 'SVE: [低]標準機能について', null, 'SkyEditor', date.newInstance(2021, 9, 1), date.newInstance(2021, 10, 1))); 
        supportList.add(createTerraskySupport('0000002', null, 'SVE: [低]標準機能について', null, 'SkyEditor', date.newInstance(2021, 10, 1), date.newInstance(2021, 9, 1))); 
        supportList.add(createTerraskySupport('0000003', '0001', null, '掲示板', 'mitoco', date.newInstance(2021, 10, 1), date.newInstance(2021, 10, 1))); 
        supportList.add(createTerraskySupport('0000004', null, null, '掲示板', 'mitoco', date.newInstance(2021, 10, 1), date.newInstance(2021, 9, 1))); 
        insert supportList;
 
        // ユーザ作成
        User user = TestClassUtil.createUser('1','2','3');
        // 日報作成
        DailyReport__c dr1 = createDailyReport(user, date.newInstance(2021, 10, 1));
        DailyReport__c dr2 = createDailyReport(user, date.newInstance(2021, 10, 2));
        // 日報明細作成
        List<DailyReportDetail__c> drDetailList = new List<DailyReportDetail__c>();
        drDetailList.add(createDetailReport(dr1, '0000001', 4, 'サービスデスク-SVE', '1_問い合わせ', supportList.get(0)));
        drDetailList.add(createDetailReport(dr1, '0000001', 3, 'サービスデスク-SVE', '1_問い合わせ', supportList.get(0)));
        drDetailList.add(createDetailReport(dr1, null, 5.5, 'サービスデスク-SVE', '2_その他対応', null));
        drDetailList.add(createDetailReport(dr1, null, 0.5, 'サービスデスク-SVE', '2_その他対応', null));
        drDetailList.add(createDetailReport(dr2, '0000002', 10, 'サービスデスク-SVE', '1_問い合わせ', supportList.get(1)));
        drDetailList.add(createDetailReport(dr1, '0000003', 4, 'サービスデスク-mitoco', '1_問い合わせ', supportList.get(2)));
        drDetailList.add(createDetailReport(dr1, '0000003', 1, 'サービスデスク-mitoco', '1_問い合わせ', supportList.get(2)));
        drDetailList.add(createDetailReport(dr1, null, 1, 'サービスデスク-mitoco', '2_その他対応', null));
        drDetailList.add(createDetailReport(dr1, null, 1, 'サービスデスク-mitoco', '2_その他対応', null));
        drDetailList.add(createDetailReport(dr2, '0000004', 2, 'サービスデスク-mitoco', '1_問い合わせ', supportList.get(3)));
        insert drDetailList;
 
 
        
        system.debug('■■■テスト実行■■■');
        Test.startTest();
        TerraskySupportMonthlyReportController target = new TerraskySupportMonthlyReportController();
        target.createYear = '2021';
        target.createMonth = '10';
        target.productType = 'サービスデスク-mitoco';
        target.execute();
        Test.stopTest();

        system.debug('■■■テスト検証■■■');
        System.assertEquals(target.getProductLine1().name, '掲示板');
        System.assertEquals(target.getProductLine1().value, 1);
        System.assertEquals(target.totalWorkTimeThisMonth, 5);
        System.assertEquals(target.workTimeLastMonth, 2);
        System.assertEquals(target.workTimeEtc, 2);
        System.assertEquals(target.totalSumworkTime, 9);
    }
    
    /**
     * サポート対応作成
     * @return サポート対応
     */
    private static TerraskySupport__c createTerraskySupport(
        String caseNo,
        String inquiryID,
        String inquiryType,
        String productEdition,
        String productType,
        Date solutionCreateDate,
        Date caseCreateDate ) {

        TerraskySupport__c ts = new TerraskySupport__c();
        ts.Name = '1234567 title';                     // タイトル
        ts.PersonName__c = 'SKY365サポート担当';        // 担当者
        ts.CaseCreateDate__c = caseCreateDate;         // 作成日（引数）
        ts.CaseNo__c = caseNo;                         // ケース番号（引数）
        ts.InquiryID__c = inquiryID;                   // 製品問い合わせID（引数）
        ts.InquiryType__c = inquiryType;               // 製品問い合わせ種別（引数）
        ts.ProductEdition__c = productEdition;         // 製品エディション（引数）
        ts.ProductType__c = productType;               // 対象製品（引数）
        ts.SolutionCreateDate__c = solutionCreateDate; // ソリューション作成日（引数）
        return ts;
    }

    /**
     * 日報作成
     * @param User ユーザ
     * @return 日報
     */
    private Static DailyReport__c createDailyReport(User u, Date registDate) {
        DailyReport__c dr = new DailyReport__c();
        dr.Name = 'TestUser' + String.valueOf(registDate); // 日報名
        dr.RegistDate__c = registDate;                     // 登録日
        dr.User__c = u.id;                                 // ユーザ
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
    public Static DailyReportDetail__c createDetailReport(
        DailyReport__c dr,
        String code,
        Decimal workTime,
        String client2,
        String project2,
        TerraskySupport__c support) {
        DailyReportDetail__c rd = new DailyReportDetail__c();
        rd.Title__c = 'dailyDetail';    // タイトル
        rd.WorkTime__c = workTime;      // 稼働時間（引数）
        rd.DailyReport__c = dr.id;      // 日報(引数)
        rd.code__c = code;              // ケース番号（引数）
        rd.Project2__c = project2;      // プロジェクト（引数）
        rd.Client2__c = client2;        // クライアント（引数）
        if (support != null) {
            rd.TerraskySupport__c = support.id;// サポート対応（引数）
        }
        return rd;
    }

    private static void wait(Integer millisec) {

        if(millisec == null || millisec < 0) {
            millisec = 0;
        }
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < millisec) {
            //sleep for parameter x millisecs
            finishTime = DateTime.now().getTime();
        }
        // System.debug('>>> Done from ' + startTime + ' to ' + finishTime);
    }    
}