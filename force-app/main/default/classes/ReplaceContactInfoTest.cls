/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * ご連絡先名・アドレス置換テストクラス
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/02     Kikuchi     新規作成
 ********************************************************************************/
@isTest
 public with sharing class ReplaceContactInfoTest {
    public ReplaceContactInfoTest() {

    }
    /**
     * 正常系
     * お名前のみ変更
     * 
     */
    @isTest
    static void testCace01() {
		system.debug('■■■テスト準備■■■');
        //置換元案件
        Constitution_Common__c orgCon = TestClassUtil.createConstitutionCommon('9000');
        NotifyInfo__c ni = createNotifyInfo(orgCon.id);
        system.debug('■■■テスト実行■■■');
        Test.startTest();
            ReplaceContactInfo rep = new ReplaceContactInfo('xxxx6@test.co.jp', 'テスト９９', 'xxxx6@test.co.jp');
            rep.replace();
        Test.stopTest();
        system.debug('■■■テスト検証■■■');
        NotifyInfo__c actual = [SELECT Etc6_Name__c, Etc6_Mail__c FROM NotifyInfo__c WHERE id =:ni.id];
        System.assertEquals(actual.Etc6_Name__c, 'テスト９９');
        System.assertEquals(actual.Etc6_Mail__c, 'xxxx6@test.co.jp');           
    }

    /**
     * 正常系
     * メールアドレスのみ変更
     * 
     */
    @isTest
    static void testCace02() {
		system.debug('■■■テスト準備■■■');
        //置換元案件
        Constitution_Common__c orgCon = TestClassUtil.createConstitutionCommon('9000');
        NotifyInfo__c ni = createNotifyInfo(orgCon.id);
        system.debug('■■■テスト実行■■■');
        Test.startTest();
            ReplaceContactInfo rep = new ReplaceContactInfo('xxxx6@test.co.jp', 'テスト6', 'xxxx99@test.co.jp');
            rep.replace();
        Test.stopTest();
        system.debug('■■■テスト検証■■■');
        NotifyInfo__c actual = [SELECT Etc6_Name__c, Etc6_Mail__c FROM NotifyInfo__c WHERE id =:ni.id];
        System.assertEquals(actual.Etc6_Name__c, 'テスト6');
        System.assertEquals(actual.Etc6_Mail__c, 'xxxx99@test.co.jp');           
    }

    /**
     * 正常系
     * お名前・メールアドレス変更
     * 
     */
    @isTest
    static void testCace03() {
		system.debug('■■■テスト準備■■■');
        //置換元案件
        Constitution_Common__c orgCon = TestClassUtil.createConstitutionCommon('9000');
        NotifyInfo__c ni = createNotifyInfo(orgCon.id);
        system.debug('■■■テスト実行■■■');
        Test.startTest();
            ReplaceContactInfo rep = new ReplaceContactInfo('xxxx6@test.co.jp', 'テスト９９', 'xxxx99@test.co.jp');
            rep.replace();
        Test.stopTest();
        system.debug('■■■テスト検証■■■');
        NotifyInfo__c actual = [SELECT Etc6_Name__c, Etc6_Mail__c FROM NotifyInfo__c WHERE id =:ni.id];
        System.assertEquals(actual.Etc6_Name__c, 'テスト９９');
        System.assertEquals(actual.Etc6_Mail__c, 'xxxx99@test.co.jp');           
    }

    /**
     * 正常系
     * お名前・メールアドレス変更・会社名変更
     * 
     */
    @isTest
    static void testCace04() {
		system.debug('■■■テスト準備■■■');
        //置換元案件
        Constitution_Common__c orgCon = TestClassUtil.createConstitutionCommon('9000');
        NotifyInfo__c ni = createNotifyInfo(orgCon.id);
        system.debug('■■■テスト実行■■■');
        Test.startTest();
            ReplaceContactInfo rep = new ReplaceContactInfo('xxxx6@test.co.jp', 'テスト９９', 'xxxx99@test.co.jp', 'テスト会社９９');
            rep.replace();
        Test.stopTest();
        system.debug('■■■テスト検証■■■');
        NotifyInfo__c actual = [SELECT Etc6_Name__c, Etc6_Mail__c,Etc6_Company__c FROM NotifyInfo__c WHERE id =:ni.id];
        System.assertEquals(actual.Etc6_Name__c, 'テスト９９');
        System.assertEquals(actual.Etc6_Mail__c, 'xxxx99@test.co.jp');
        System.assertEquals(actual.Etc6_Company__c, 'テスト会社９９');             
    }
    private static NotifyInfo__c createNotifyInfo(Id id) {
        // 連絡先情報
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = Id;
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
        insert ni;
        return ni;      
    }
}