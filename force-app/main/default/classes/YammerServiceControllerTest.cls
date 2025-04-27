/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Yammerサービスに日報を投稿するテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/07     kikuchi     新規作成
 ********************************************************************************/
@isTest
 private class YammerServiceControllerTest {
    /**
     * 正常系（初期処理）
     * 　Yammer連係済
     */
    @isTest
    static void testCace01() {
		system.debug('■■■テスト準備■■■');
        // ユーザ
        User user = TestClassUtil.createUser('1','2','3');
        // 日報
        DailyReport__c dr = TestClassUtil.createDailyReport(user);
        // 日報明細１
        DailyReportDetail__c rd1 = TestClassUtil.createDetailReport(dr, '運用代行-BeeX');
        // 日報明細２
        DailyReportDetail__c rd2 = TestClassUtil.createDetailReport(dr);


        ApexPages.StandardController stc = new ApexPages.StandardController(dr);
		
        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200));        
		system.debug('■■■テスト実行■■■');
        System.runAs(user) {
            Test.startTest();
                YammerServiceController cls = new YammerServiceController(stc);
                Pagereference actual = cls.initAction();
            Test.stopTest();
    
            system.debug('■■■テスト検証■■■');
            System.assert(actual != null);         
        }
    }

    /**
     * 正常系（初期処理）
     * 　Yammer未連携
     */
    @isTest
    static void testCace02() {
		system.debug('■■■テスト準備■■■');
        // ユーザ
        User user = TestClassUtil.createUser('1','2',null);
        // 日報
        DailyReport__c dr = TestClassUtil.createDailyReport(user);
        // 日報明細
        DailyReportDetail__c rd = TestClassUtil.createDetailReport(dr);

        ApexPages.StandardController stc = new ApexPages.StandardController(dr);
		
        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200));        
		system.debug('■■■テスト実行■■■');
        System.runAs(user) {
            Test.startTest();
                YammerServiceController cls = new YammerServiceController(stc);
                Pagereference actual = cls.initAction();
            Test.stopTest();
    
            system.debug('■■■テスト検証■■■');
            System.assert(actual != null);         
        }
    }

}