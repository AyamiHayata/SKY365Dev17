/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * SalesforceとYammer連携のための認証フローテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/07     kikuchi     新規作成
 ********************************************************************************/
@isTest
private class SalesforceToYammerControllerTest {
    /**
     * 正常系（初期処理）
     * 　Yammer連係
     */
    @isTest
    static void testCace01() {
		system.debug('■■■テスト準備■■■');
        // ユーザ
        User user = TestClassUtil.createUser('1','2','3');

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, createResJSON()));        
		system.debug('■■■テスト実行■■■');
        System.runAs(user) {
            Test.startTest();
            SalesforceToYammerController cls = new SalesforceToYammerController();
            cls.initAction();
            Pagereference actual = cls.back();
            Test.stopTest();
    
            system.debug('■■■テスト検証■■■');
            System.assert(actual != null);         
        }
    }    

    private static string createResJSON() {
        return '{' +
        '"access_token": {' +
            '"token": "6087841"' +
            '}' +
        '}';
    }
    
}