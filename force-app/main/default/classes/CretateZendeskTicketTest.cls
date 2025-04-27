/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2023 SKY365 Inc. All Rights Reserved.
 *
 * Zendeskにチケットを作成
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/03     kikuchi     新規作成
 ********************************************************************************/
@isTest
 private class CretateZendeskTicketTest {
    /**
     * 正常系
     * 
     */
    @isTest
    static void testCace01() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 連絡先情報
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = constitution.Id;
        ni.Week__c = '月;火;水;木;金;土;日;祝;';
        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        // メールでのご連絡先 2
        ni.Etc2_Name__c = 'テスト氏名2';
        ni.Etc2_Company__c = 'テスト会社2';
        ni.Etc2_Mail__c = 'xxxx2@test.co.jp';
        ni.Etc2_OtherThanAlertContact__c = true;
        ni.Etc2_Permission__c = '編集可';
        // メールでのご連絡先 3
        ni.Etc3_Name__c = '';
        // メールでのご連絡先 4
        ni.Etc4_Name__c = 'テスト4';
        ni.Etc4_Company__c = 'テスト会社4';
        ni.Etc4_Mail__c = 'xxxx4@test.co.jp';
        // メールでのご連絡先 5
        ni.Etc5_Name__c = 'テスト5';
        ni.Etc5_Company__c = 'テスト会社5';
        ni.Etc5_Mail__c = 'xxxx5@test.co.jp';
        ni.Etc5_OtherThanAlertContact__c = true;
        // メールでのご連絡先 6
        ni.Etc6_Name__c = 'テスト6';
        ni.Etc6_Company__c = 'テスト会社6';
        ni.Etc6_Mail__c = 'xxxx6@test.co.jp';
        ni.Etc6_OtherThanAlertContact__c = true;
        ni.Etc6_ErrorLog__c = 'Error';
        ni.Etc6_ChgList__c = '変更';
        insert ni;

        system.debug('■■■テスト準備■■■');
        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, null));        
        system.debug('■■■テスト実行■■■');
        Test.startTest();
        // CretateZendeskTicket target = new CretateZendeskTicket(ni.Id);
        // HttpResponse actual = target.createMessage('a2V1m000000Byd8EAC');
        Database.executebatch(new CretateZendeskTicket(ni.Id), 100);
        Test.stopTest();              
        system.debug('■■■テスト検証■■■');
        // System.assertEquals(200, actual.getStatusCode());    
    }
}