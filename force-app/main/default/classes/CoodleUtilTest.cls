/********************************************************************************
 *
 * Coodle　ポータルサイト共通クラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2022/09                              New
 ********************************************************************************/
@isTest
private class CoodleUtilTest {
    /**
     * 【対象】
     * checkAuthority
     * 【条件】
     * 
     */
    @isTest
    public static void test_checkAuthority_001() {
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

        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        CoodleUtil.checkAuthority(false,ni,'xxxx@test.co.jp');
        Test.stopTest();
    }
    /**
     * 【対象】
     * chkDiffMailRenrakusaki
     * 【条件】
     * 
     */
    @isTest
    public static void test_chkDiffMailRenrakusaki_001() {
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

        // 連絡先情報1
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = constitution.Id;
        ni.Week__c = '月;火;水;木;金;土;日;祝;';
        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_OtherThanAlertContact__c = false;
        ni.Etc1_Permission__c = '編集可';
        // メールでのご連絡先 2
        ni.Etc2_Del__c = false;
        ni.Etc2_Name__c = 'テスト氏名2';
        ni.Etc2_Company__c = 'テスト会社2';
        ni.Etc2_Mail__c = 'xxxx2@test.co.jp';
        ni.Etc2_AlertContact__c = true;
        ni.Etc2_Permission__c = '参照のみ';
        // メールでのご連絡先 3
        ni.Etc3_Name__c = '';
        

        // 連絡先情報2
        NotifyInfo__c oldni = new NotifyInfo__c();
        oldni.ConstitutionCommon__c = constitution.Id;
        oldni.Week__c = '月;火;水;木;金;土;日;祝;';
        // メールでのご連絡先 1
        oldni.Etc1_Name__c = 'テスト氏名';
        oldni.Etc1_Company__c = 'テスト会社';
        oldni.Etc1_Mail__c = 'xxxx@test.co.jp';
        oldni.Etc1_AlertContact__c = true;
        oldni.Etc1_OtherThanAlertContact__c = true;
        oldni.Etc1_Permission__c = '編集可';
        // メールでのご連絡先 2
        oldni.Etc2_Del__c = true;
        oldni.Etc2_Name__c = 'テスト氏名2';
        oldni.Etc2_Company__c = 'テスト会社2';
        oldni.Etc2_Mail__c = 'xxxx2@test.co.jp';
        oldni.Etc2_AlertContact__c = false;
        oldni.Etc2_Permission__c = '参照のみ';
        // メールでのご連絡先 3
        oldni.Etc3_Name__c = 'テスト氏名3';
        oldni.Etc3_Company__c = 'テスト会社3';
        oldni.Etc3_Mail__c = 'xxxx3@test.co.jp';
        oldni.Etc3_AlertContact__c = false;
        oldni.Etc3_Permission__c = '参照のみ';
        

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        CoodleUtil.chkDiffMailRenrakusaki(ni,oldni);
        Test.stopTest();
    }
    /**
     * 【対象】
     * jikangaiReinput
     * 【条件】
     * 
     */
    @isTest
    public static void test_jikangaiReinput_001() {
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

        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        CoodleUtil.jikangaiReinput('2','3','1','3','1','2',ni);
        CoodleUtil.jikangaiReinput('3','1','2','2','3','1',ni);
        Test.stopTest();
    }
    /**
     * 【対象】
     * deleteTelRenrakusaki
     * 【条件】
     * 
     */
    @isTest
    public static void test_deleteTelRenrakusaki_001() {
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
        ni.In1_Del__c = true;
        ni.In1_Name__c = '営業時間内１名前';
        ni.In1_Kana__c = 'エイギョウジカンナイ１';
        ni.In1_Company__c = '時間内会社１';
        //ni.In1_Tel__c = '011-222-1111';
        ni.In2_Del__c = false;
        ni.In2_Name__c = '営業時間内２名前';
        ni.In2_Kana__c = 'エイギョウジカンナイ１';
        ni.In2_Company__c = '時間内会社２';
        //ni.In2_Tel__c = '011-222-2222';
        ni.In3_Del__c = false;
        ni.In3_Name__c = '営業時間内名前３';
        ni.In3_Kana__c = 'エイギョウジカンナイ３';
        ni.In3_Company__c = '時間内会社３';
        //ni.In3_Tel__c = '011-222-3333';

        ni.Out1_Del__c = false;
        ni.Out1_Name__c = '営業時間外１名前';
        ni.Out1_Kana__c = 'エイギョウジカンガイ１';
        ni.Out1_Company__c = '時間外会社１';
        //ni.Out1_Tel__c = '090-1111-1111';
        ni.Out2_Del__c = true;
        ni.Out2_Name__c = '営業時間外名前２';
        ni.Out2_Kana__c = 'エイギョウジカンガイ２';
        ni.Out2_Company__c = '時間外会社２';
        //ni.Out2_Tel__c = '090-2222-2222';
        ni.Out3_Del__c = true;
        ni.Out3_Name__c = '営業時間外名前３';
        ni.Out3_Kana__c = 'エイギョウジカンガイ３';
        ni.Out3_Company__c = '時間外会社３';
        //ni.Out3_Tel__c = '090-3333-3333';

        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_MonthlyReportSender__c = true;

        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        CoodleUtil.deleteTelRenrakusaki(ni);
        Test.stopTest();
    }
    /**
     * 【対象】
     * checkInputContents
     * 【条件】
     *  電話連絡先の登録が全く無い場合
     *  ログインユーザーで削除チェックが入っている場合
     */
    @isTest
    public static void test_checkInputContents_error001() {
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

        for(Integer loopnum=1; loopnum < 21; loopnum++){
            ni.put('Etc'+loopnum+'_AlertContact__c',false);
            ni.put('Etc'+loopnum+'_OtherThanAlertContact__c',false);
            ni.put('Etc'+loopnum+'_MonthlyReportSender__c',false);
            ni.put('Etc'+loopnum+'_Del__c',false);
        }

        ni.ConstitutionCommon__c = constitution.Id;
        ni.Week__c = '月;火;水;木;金;土;日;祝;';
        // メールでのご連絡先 1
        ni.Etc1_Del__c = false;
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_OtherThanAlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_MonthlyReportSender__c = true;
        // メールでのご連絡先 2
        ni.Etc2_Del__c = false;
        ni.Etc2_Name__c = 'テスト氏名2';
        ni.Etc2_Company__c = 'テスト会社2';
        ni.Etc2_Mail__c = 'xxxx2@test.co.jp';
        ni.Etc2_AlertContact__c = false;
        ni.Etc2_OtherThanAlertContact__c = true;
        ni.Etc2_Permission__c = '編集可';
        ni.Etc2_MonthlyReportSender__c = false;
        // メールでのご連絡先 3
        //ni.Etc3_Name__c = '';
        ni.Etc3_Del__c = true;
        // メールでのご連絡先 4
        ni.Etc4_Del__c = false;
        ni.Etc4_Name__c = 'テスト4';
        ni.Etc4_Company__c = 'テスト会社4';
        ni.Etc4_Mail__c = 'xxxx4@test.co.jp';
        ni.Etc4_AlertContact__c = false;
        ni.Etc4_OtherThanAlertContact__c = false;
        ni.Etc4_Permission__c = '編集可';
        ni.Etc4_MonthlyReportSender__c = false;
        // メールでのご連絡先 5
        ni.Etc5_Del__c = true;
        ni.Etc5_Name__c = 'テスト5';
        ni.Etc5_Company__c = 'テスト会社5';
        ni.Etc5_Mail__c = 'xxxx5@test.co.jp';
        ni.Etc5_AlertContact__c = false;
        ni.Etc5_OtherThanAlertContact__c = true;
        ni.Etc5_Permission__c = '編集可';
        ni.Etc5_MonthlyReportSender__c = false;
        // メールでのご連絡先 6
        ni.Etc6_Del__c = false;
        ni.Etc6_Name__c = 'テスト6';
        ni.Etc6_Company__c = 'テスト会社6';
        ni.Etc6_Mail__c = 'xxxx6@test.co.jp';
        ni.Etc6_AlertContact__c = true;
        ni.Etc6_OtherThanAlertContact__c = true;
        // ni.Etc6_Permission__c = '編集可';
        ni.Etc6_MonthlyReportSender__c = false;
        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        CoodleUtil.checkInputContents(false,false,ni,'xxxx5@test.co.jp');
        Test.stopTest();
    }
    /**
     * 【対象】
     * checkInputContents
     * 【条件】
     *  
     *  ログインユーザーで削除チェックが入っている場合
     */
    @isTest
    public static void test_checkInputContents_error002() {
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

        for(Integer loopnum=1; loopnum < 21; loopnum++){
            ni.put('Etc'+loopnum+'_AlertContact__c',false);
            ni.put('Etc'+loopnum+'_OtherThanAlertContact__c',false);
            ni.put('Etc'+loopnum+'_MonthlyReportSender__c',false);
            ni.put('Etc'+loopnum+'_Del__c',false);
        }

        ni.ConstitutionCommon__c = constitution.Id;
        ni.Week__c = '月;火;水;木;金;土;日;祝;';
        ni.In1_Del__c = true;
        ni.In1_Name__c = '営業時間内１名前';
        ni.In1_Kana__c = 'エイギョウジカンナイ１';
        ni.In1_Company__c = '時間内会社１';
        //ni.In1_Tel__c = '011-222-1111';
        ni.In2_Del__c = false;
        ni.In2_Name__c = '営業時間内２名前';
        ni.In2_Kana__c = 'エイギョウジカンナイ１';
        ni.In2_Company__c = '時間内会社２';
        //ni.In2_Tel__c = '011-222-2222';
        ni.In3_Del__c = false;
        ni.In3_Name__c = '';
        ni.In3_Kana__c = 'エイギョウジカンナイ３';
        ni.In3_Company__c = '時間内会社３';
        //ni.In3_Tel__c = '011-222-3333';

        ni.Out1_Del__c = false;
        ni.Out1_Name__c = '営業時間外１名前';
        ni.Out1_Kana__c = 'エイギョウジカンガイ１';
        ni.Out1_Company__c = '時間外会社１';
        //ni.Out1_Tel__c = '090-1111-1111';
        ni.Out2_Del__c = false;
        ni.Out2_Name__c = '';
        ni.Out2_Kana__c = 'test2';
        ni.Out2_Company__c = '';
        //ni.Out2_Tel__c = '';
        ni.Out3_Del__c = true;
        ni.Out3_Name__c = '営業時間外名前３';
        ni.Out3_Kana__c = 'エイギョウジカンガイ３';
        ni.Out3_Company__c = '時間外会社３';
        //ni.Out3_Tel__c = '090-3333-3333';

        ni.Exception__c = 'test2222';

        // メールでのご連絡先 1
        ni.Etc1_Del__c = false;
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        ni.Etc1_AlertContact__c = false;
        ni.Etc1_OtherThanAlertContact__c = false;
        ni.Etc1_Permission__c = '参照のみ';
        ni.Etc1_MonthlyReportSender__c = false;
        // メールでのご連絡先 2
        ni.Etc2_Del__c = false;
        ni.Etc2_Name__c = 'テスト氏名2';
        ni.Etc2_Company__c = 'テスト会社2';
        ni.Etc2_Mail__c = 'xxxx@test.co.jp';
        ni.Etc2_AlertContact__c = false;
        ni.Etc2_OtherThanAlertContact__c = false;
        ni.Etc2_Permission__c = '参照のみ';
        ni.Etc2_MonthlyReportSender__c = false;
        // メールでのご連絡先 3
        //ni.Etc3_Name__c = '';
        ni.Etc3_Del__c = true;
        // メールでのご連絡先 4
        ni.Etc4_Del__c = false;
        ni.Etc4_Name__c = 'テスト4';
        ni.Etc4_Company__c = 'テスト会社4';
        ni.Etc4_Mail__c = 'xxxx4@test.co.jp';
        ni.Etc4_AlertContact__c = false;
        ni.Etc4_OtherThanAlertContact__c = false;
        ni.Etc4_Permission__c = '参照のみ';
        ni.Etc4_MonthlyReportSender__c = false;
        // メールでのご連絡先 5
        ni.Etc5_Del__c = false;
        ni.Etc5_Name__c = 'テスト5';
        ni.Etc5_Company__c = 'テスト会社5';
        ni.Etc5_Mail__c = 'xxxx5@test.co.jp';
        ni.Etc5_AlertContact__c = false;
        ni.Etc5_OtherThanAlertContact__c = false;
        ni.Etc5_Permission__c = '参照のみ';
        ni.Etc5_MonthlyReportSender__c = false;
        // メールでのご連絡先 6
        ni.Etc6_Del__c = false;
        ni.Etc6_Name__c = 'テスト6';
        ni.Etc6_Company__c = 'テスト会社6';
        ni.Etc6_Mail__c = 'xxxx6@test.co.jp';
        ni.Etc6_AlertContact__c = false;
        ni.Etc6_OtherThanAlertContact__c = false;
        ni.Etc6_Permission__c = '参照のみ';
        ni.Etc6_MonthlyReportSender__c = false;
        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        CoodleUtil.checkInputContents(false,false,ni,'xxxx5@test.co.jp');
        Test.stopTest();
    }
    /**
     * 【対象】
     * checkDeleteCh
     * 【条件】
     * 
     */
    @isTest
    public static void test_checkDeleteChg_001() {
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

        for(Integer loopnum=1; loopnum < 21; loopnum++){
            ni.put('Etc'+loopnum+'_AlertContact__c',false);
            ni.put('Etc'+loopnum+'_OtherThanAlertContact__c',false);
            ni.put('Etc'+loopnum+'_MonthlyReportSender__c',false);
            ni.put('Etc'+loopnum+'_Del__c',false);
        }

        ni.ConstitutionCommon__c = constitution.Id;
        ni.Week__c = '月;火;水;木;金;土;日;祝;';
        // メールでのご連絡先 1
        ni.Etc1_Del__c = false;
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_OtherThanAlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_MonthlyReportSender__c = true;
        // メールでのご連絡先 2
        ni.Etc2_Del__c = true;
        ni.Etc2_Name__c = 'テスト氏名2';
        ni.Etc2_Company__c = 'テスト会社2';
        ni.Etc2_Mail__c = 'xxxx2@test.co.jp';
        ni.Etc2_AlertContact__c = false;
        ni.Etc2_OtherThanAlertContact__c = true;
        ni.Etc2_Permission__c = '編集可';
        ni.Etc2_MonthlyReportSender__c = false;
        ni.Etc2_ChgList__c = '変更';
        // メールでのご連絡先 3
        //ni.Etc3_Name__c = '';
        
        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        CoodleUtil.checkDeleteChg(false,ni);
        Test.stopTest();
    }
    /**
     * 【対象】
     * checkInputContents
     * 【条件】
     * 
     */
    @isTest
    public static void test_moveUpTelRenrakusaki_001() {
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

        for(Integer loopnum=1; loopnum < 21; loopnum++){
            ni.put('Etc'+loopnum+'_AlertContact__c',false);
            ni.put('Etc'+loopnum+'_OtherThanAlertContact__c',false);
            ni.put('Etc'+loopnum+'_MonthlyReportSender__c',false);
            ni.put('Etc'+loopnum+'_Del__c',false);
        }

        ni.ConstitutionCommon__c = constitution.Id;
        ni.Week__c = '月;火;水;木;金;土;日;祝;';
        ni.In1_Del__c = true;
        ni.In1_Name__c = '営業時間内１名前';
        ni.In1_Kana__c = 'エイギョウジカンナイ１';
        ni.In1_Company__c = '時間内会社１';
        //ni.In1_Tel__c = '011-222-1111';
        ni.In2_Del__c = false;
        ni.In2_Name__c = '営業時間内２名前';
        ni.In2_Kana__c = 'エイギョウジカンナイ１';
        ni.In2_Company__c = '時間内会社２';
        //ni.In2_Tel__c = '011-222-2222';
        ni.In3_Del__c = false;
        ni.In3_Name__c = '営業時間内名前３';
        ni.In3_Kana__c = 'エイギョウジカンナイ３';
        ni.In3_Company__c = '時間内会社３';
        //ni.In3_Tel__c = '011-222-3333';

        ni.Out1_Del__c = false;
        ni.Out1_Name__c = '営業時間外１名前';
        ni.Out1_Kana__c = 'エイギョウジカンガイ１';
        ni.Out1_Company__c = '時間外会社１';
        //ni.Out1_Tel__c = '090-1111-1111';
        ni.Out2_Del__c = false;
        ni.Out2_Name__c = '';
        ni.Out2_Kana__c = '';
        ni.Out2_Company__c = '';
        //ni.Out2_Tel__c = '';
        ni.Out3_Del__c = true;
        ni.Out3_Name__c = '営業時間外名前３';
        ni.Out3_Kana__c = 'エイギョウジカンガイ３';
        ni.Out3_Company__c = '時間外会社３';
        //ni.Out3_Tel__c = '090-3333-3333';
        // メールでのご連絡先 1
        ni.Etc1_Del__c = false;
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_OtherThanAlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_MonthlyReportSender__c = true;
        // メールでのご連絡先 2
        ni.Etc2_Del__c = true;
        ni.Etc2_Name__c = 'テスト氏名2';
        ni.Etc2_Company__c = 'テスト会社2';
        ni.Etc2_Mail__c = 'xxxx2@test.co.jp';
        ni.Etc2_AlertContact__c = false;
        ni.Etc2_OtherThanAlertContact__c = true;
        ni.Etc2_Permission__c = '編集可';
        ni.Etc2_MonthlyReportSender__c = false;
        ni.Etc2_ChgList__c = '変更';
        // メールでのご連絡先 3
        //ni.Etc3_Name__c = '';
        
        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        CoodleUtil.moveUpTelRenrakusaki(ni);
        Test.stopTest();
    }
}