/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Zendesk連携バッチForSWXZendeskテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/08     Kikuchi     新規作成
 ********************************************************************************/
@isTest
public with sharing class ZendeskForSwxBatchTest {
    /**
     * 正常系
     * 
     */
    @isTest
    static void testCace01() {
		system.debug('■■■テスト準備■■■');
        // 案件情報
        Constitution_Common__c con = TestClassUtil.createConstitutionCommon('9000');
        // ユーザ
        User user = TestClassUtil.createUser('1','2','3');
        // 日報
        DailyReport__c dr = TestClassUtil.createDailyReport(user);
        // 日報明細
        DailyReportDetail__c rd = createDetailReport(dr, '#1234567 Testチケット');        

        //Mock
        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, createResJSON()));        
        system.debug('■■■テスト実行■■■');
        
        ZendeskForSwxBatch batch = new ZendeskForSwxBatch();
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        system.debug('■■■テスト検証■■■');
        List<DailyReportDetail__c> detailList = [SELECT client2__c, project2__c, ConstitutionCommon__c FROM DailyReportDetail__c];
        System.assertEquals(detailList.size(), 1);
        DailyReportDetail__c detail = detailList.get(0);
        System.assertEquals(detail.client2__c, '運用代行-SWX');
        //System.assertEquals(detail.project2__c, '1_各種設定変更-連絡先変更');
        System.assert(detail.ConstitutionCommon__c != null);
        
    }

    /**
     * 日報明細作成
     * @param DailyReport__c　日報
     * @return 日報明細
     */
    public Static DailyReportDetail__c createDetailReport(DailyReport__c dr, String title) {
        DailyReportDetail__c rd = new DailyReportDetail__c();
        rd.Title__c       = '#1234567 title';      // タイトル
        rd.WorkTime__c    = 8.0;         // 稼働時間
        rd.DailyReport__c = dr.id;       // 日報
        rd.code__c = '#1234567';
        insert rd;
        return rd;
    }

    private static string createResJSON() {
        return '{' +
          '"results": [' +
            '{' +
              '"id": 1234567,' +
              '"organization_id": 9000,' +
              '"tags": [' +
                '"ご連絡先についてのお問い合わせ_msp_category",' +
                '"顧客種別:運用代行-24365"' +
              ']' +  
            '}' +
          ']' +
        '}';
    }
}