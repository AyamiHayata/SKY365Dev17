/********************************************************************************
 *
 * 連絡先情報トリガーテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2022/09                              New
 ********************************************************************************/
@isTest
 private class NotifyInfoTriggerHandlerTest {
    /**
     * 【対象】
     * onBeforeUpdate
     * 【条件】
     * 変更種別が正しく判定されていること
     */
    @isTest
    public static void test_onBeforeUpdate_001() {
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
        // ni.Etc3_Name__c = '';
        // メールでのご連絡先 4
        ni.Etc4_Name__c = 'テスト4';
        ni.Etc4_Company__c = 'テスト会社4';
        ni.Etc4_Mail__c = 'xxxx4@test.co.jp';
        ni.Etc4_Permission__c = '編集可';
        // メールでのご連絡先 5
        ni.Etc5_Name__c = 'テスト5';
        ni.Etc5_Company__c = 'テスト会社5';
        ni.Etc5_Mail__c = 'xxxx5@test.co.jp';
        ni.Etc5_OtherThanAlertContact__c = true;
        ni.Etc5_Permission__c = '編集可';
        // メールでのご連絡先 6
        ni.Etc6_Name__c = 'テスト6';
        ni.Etc6_Company__c = 'テスト会社6';
        ni.Etc6_Mail__c = 'xxxx6@test.co.jp';
        ni.Etc6_OtherThanAlertContact__c = true;
        ni.Etc6_Permission__c = '編集可';
        insert ni;

        // テスト開始
        Test.startTest();
        ni.Etc1_Del__c = true;
        // ni.Etc2_Mail__c = 'xxxx22@test.co.jp';
        ni.Etc3_Name__c = '新規タロウ';
        ni.Etc4_AlertContact__c = true;
        ni.Etc5_OtherThanAlertContact__c = false;
        ni.Etc6_Company__c = 'テスト会社61';
        update ni;
        Test.stopTest();

        List<NotifyInfo__c> resultninfoList = [
            SELECT
                ID
                ,Name
                ,Etc1_ChgList__c
                ,Etc2_ChgList__c
                ,Etc3_ChgList__c
                ,Etc4_ChgList__c
                ,Etc5_ChgList__c
                ,Etc6_ChgList__c
            FROM NotifyInfo__c
            Where Id = :ni.Id
            ];
        System.debug('**==**== resultninfoList => ' + resultninfoList);
    }
    /**
     * 【対象】
     * onBeforeUpdate
     * 【条件】
     * 「詰める」処理の確認
     */
    @isTest
    public static void test_onBeforeUpdate_002() {
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
        insert ni;

        NotifyInfo__c nclone = ni.clone(false,true,false,false);
        insert nclone;

        // テスト開始
        Test.startTest();
        ni.Etc1_Del__c = true;
        ni.Etc2_Mail__c = 'xxxx22@test.co.jp';
        ni.PastOne__c = nclone.Id;
        update ni;
        ni.Etc1_Del__c = false;
        ni.Etc1_ChgList__c = '詰める';
        ni.Etc2_ChgList__c = '';
        update ni;
        Test.stopTest();
    }

}