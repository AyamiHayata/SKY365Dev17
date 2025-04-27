/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Togglサービスから稼働を取得するテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/07     kikuchi     新規作成
 ********************************************************************************/
@isTest
private class TogglServiceControllerTest {

    /**
     * 正常系（初期処理）
     * 　Yammer連係
     */
    @isTest
    static void testCace01() {
		system.debug('■■■テスト準備■■■');
    // ユーザ
    User user = TestClassUtil.createUser('1','2','3');
    // 日報
    DailyReport__c dr = TestClassUtil.createDailyReport(user);
    // 日報明細
    DailyReportDetail__c rd = TestClassUtil.createDetailReport(dr);

    ApexPages.StandardController stc = new ApexPages.StandardController(dr);
    
    Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, createResJSON()));        
		system.debug('■■■テスト実行■■■');
        System.runAs(user) {
            Test.startTest();
            TogglServiceController cls = new TogglServiceController(stc);
            Pagereference actual = cls.initAction();
            Test.stopTest();
    
            system.debug('■■■テスト検証■■■');
            System.assert(actual != null);         
        }
    }   

    private static string createResJSON() {
        return '{' +
        '"data": [' +
          '{' +
            '"id": 2077278403,' +
            '"description": "00022671 test1",' +
            '"dur": 3600000,' +
            '"client": "サービスデスク-SVE",' +
            '"project": "1_問い合わせ"' +
          '},' +
          '{' +
           '"id": 2077278403,' +
            '"description": "00022672 test2",' +
            '"dur": 3600000,' +
            '"client": "サービスデスク-SVE",' +
            '"project": "1_問い合わせ"' +
          '}' +
        ']' +
      '}';
    }    
}