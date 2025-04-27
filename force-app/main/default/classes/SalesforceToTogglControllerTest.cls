/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * SalesforceとToggl連携のための認証フローテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/07     kikuchi     新規作成
 ********************************************************************************/
@isTest
private class SalesforceToTogglControllerTest {

    /**
     * 正常系（初期処理）
     * 　Toggl連係
     */
    @isTest
    static void testCace01() {
		system.debug('■■■テスト準備■■■');
        // ユーザ
        User user = TestClassUtil.createUser('1','2','3');
/*
        // 日報
        DailyReport__c dr = TestClassUtil.createDailyReport(user);
        // 日報明細１
        DailyReportDetail__c rd1 = TestClassUtil.createDetailReport(dr, '運用代行-BeeX');
        // 日報明細２
        DailyReportDetail__c rd2 = TestClassUtil.createDetailReport(dr);
*/	
        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, createResJSON()));        
		system.debug('■■■テスト実行■■■');
        System.runAs(user) {
            Test.startTest();
            SalesforceToTogglController cls = new SalesforceToTogglController();
            cls.initAction();
            Pagereference actual = cls.regist();
            Test.stopTest();
    
            system.debug('■■■テスト検証■■■');
            System.assert(actual != null);         
        }
    }    

    private static string createResJSON() {
        return '{' +
        '"since": 1625315761,' +
        '"data": {' +
            '"id": 6087841,' +
            '"api_token": "999576329b04c44bcc43c5a37a16aa65",' +
            '"default_wid": 4627926' +
            '}' +
        '}';
    }
}