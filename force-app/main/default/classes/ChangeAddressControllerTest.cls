/********************************************************************************
 *
 * 連絡先編集コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2022/09                              New
 ********************************************************************************/
@isTest
private class ChangeAddressControllerTest {
    /**
     * 【対象】
     * initAction
     * 【条件】
     * 
     */
    @isTest
    public static void test_initAction_001() {
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
        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ChangeAddressController ctrl = new ChangeAddressController();
        ctrl.initAction(); 

        Test.stopTest();

    }
    /**
     * 【対象】
     * view
     * 【条件】
     * 
     */
    @isTest
    public static void test_view_001() {
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

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ChangeAddressController ctrl = new ChangeAddressController();
        ctrl.view(); 

        Test.stopTest();

    }

    /**
     * 【対象】
     * save
     * 【条件】
     * ErrorなしでAPI起動する場合
     */
    @isTest
    public static void test_save_001() {
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
        ni.In1_Name__c = '営業時間内１名前';
        ni.In1_Kana__c = 'エイギョウジカンナイ１';
        ni.In1_Company__c = '時間内会社１';
        ni.In1_Tel__c = '011-222-1111';
        ni.In2_Name__c = '営業時間内２名前';
        ni.In2_Kana__c = 'エイギョウジカンナイ１';
        ni.In2_Company__c = '時間内会社２';
        ni.In2_Tel__c = '011-222-2222';
        ni.In3_Name__c = '営業時間内名前３';
        ni.In3_Kana__c = 'エイギョウジカンナイ３';
        ni.In3_Company__c = '時間内会社３';
        ni.In3_Tel__c = '011-222-3333';

        ni.Out1_Name__c = '営業時間外１名前';
        ni.Out1_Kana__c = 'エイギョウジカンガイ１';
        ni.Out1_Company__c = '時間外会社１';
        ni.Out1_Tel__c = '090-1111-1111';
        ni.Out2_Name__c = '営業時間外名前２';
        ni.Out2_Kana__c = 'エイギョウジカンガイ２';
        ni.Out2_Company__c = '時間外会社２';
        ni.Out2_Tel__c = '090-2222-2222';
        ni.Out3_Name__c = '営業時間外名前３';
        ni.Out3_Kana__c = 'エイギョウジカンガイ３';
        ni.Out3_Company__c = '時間外会社３';
        ni.Out3_Tel__c = '090-3333-3333';

        ni.Exception__c = 'test2222';

        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_MonthlyReportSender__c = true;
        // メールでのご連絡先 2
        ni.Etc2_Name__c = 'テスト氏名2';
        ni.Etc2_Company__c = 'テスト会社2';
        ni.Etc2_Mail__c = 'xxxx2@test.co.jp';
        ni.Etc2_OtherThanAlertContact__c = true;
        ni.Etc2_Permission__c = '編集可';
        // メールでのご連絡先 3
        //ni.Etc3_Name__c = '';
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

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        
        ChangeAddressController ctrl = new ChangeAddressController();
        ctrl.initAction();
        ApexPages.currentPage().getParameters().put('on_display_order1','2');
        ApexPages.currentPage().getParameters().put('on_display_order2','1');
        ApexPages.currentPage().getParameters().put('on_display_order3','3');
        ApexPages.currentPage().getParameters().put('off_display_order1','1');
        ApexPages.currentPage().getParameters().put('off_display_order2','3');
        ApexPages.currentPage().getParameters().put('off_display_order3','2');

        //連絡先情報の変更
        // ctrl.notifyinfo.Etc1_Mail__c = 'xxxx11@test.co.jp';
        ctrl.notifyinfo.Etc2_AlertContact__c = true;
        ctrl.notifyinfo.In3_Del__c = true;
        ctrl.notifyinfo.Out3_Del__c = true;
        ctrl.save();

        Test.stopTest();

    }

    /**
     * 【対象】
     * save
     * 【条件】
     * Errorありの場合
     *  ・時間内の連絡先なし
     *  ・時間外の連絡先なし
     *  ・2巡してもつながらない場合の連絡先なし
     *   
     */
    @isTest
    public static void test_save_error001() {
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
        // ni.In1_Name__c = '営業時間内１名前';
        // ni.In1_Kana__c = 'エイギョウジカンナイ１';
        // ni.In1_Company__c = '時間内会社１';
        // ni.In1_Tel__c = '011-222-3333';
        // ni.In2_Name__c = '営業時間内１名前';
        // ni.In2_Kana__c = 'エイギョウジカンナイ１';
        // ni.In2_Company__c = '時間内会社１';
        // ni.In2_Tel__c = '011-222-3333';

        // ni.Out1_Name__c = '営業時間内１名前';
        // ni.Out1_Kana__c = 'エイギョウジカンナイ１';
        // ni.Out1_Company__c = '時間内会社１';
        // ni.Out1_Tel__c = '011-222-3333';
        // ni.Out2_Name__c = '営業時間内１名前';
        // ni.Out2_Kana__c = 'エイギョウジカンナイ１';
        // ni.Out2_Company__c = '時間内会社１';
        // ni.Out2_Tel__c = '011-222-3333';

        // ni.Exception__c = 'test2222';

        // メールでのご連絡先 1
        // ni.Etc1_Name__c = 'テスト氏名';
        // ni.Etc1_Company__c = 'テスト会社';
        // ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        // ni.Etc1_AlertContact__c = true;
        // ni.Etc1_Permission__c = '編集可';
        // ni.Etc1_MonthlyReportSender__c = true;
        // メールでのご連絡先 2
        ni.Etc2_Name__c = 'テスト氏名2';
        ni.Etc2_Company__c = 'テスト会社2';
        // ni.Etc2_Mail__c = 'xxxx2@test.co.jp';
        // ni.Etc2_OtherThanAlertContact__c = true;
        ni.Etc2_Permission__c = '参照のみ';
        
        // メールでのご連絡先 4
        ni.Etc4_Name__c = 'テスト4';
        // ni.Etc4_Company__c = 'テスト会社4';
        // ni.Etc4_Mail__c = 'xxxx4@test.co.jp';
        // メールでのご連絡先 5
        // ni.Etc5_Name__c = 'テスト5';
        // ni.Etc5_Company__c = 'テスト会社5';
        // ni.Etc5_Mail__c = 'xxxx5@test.co.jp';
        // ni.Etc5_OtherThanAlertContact__c = true;
        // メールでのご連絡先 6
        // ni.Etc6_Name__c = 'テスト6';
        // ni.Etc6_Company__c = 'テスト会社6';
        // ni.Etc6_Mail__c = 'xxxx6@test.co.jp';
        // ni.Etc6_OtherThanAlertContact__c = true;
        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ChangeAddressController ctrl = new ChangeAddressController();
        ctrl.initAction();

        //連絡先情報の変更
        ctrl.save();

        Test.stopTest();
    }
    /**
     * 【対象】
     * save
     * 【条件】
     * Errorありの場合
     *  ・時間内の連絡先の入力にミスあり
     *  ・時間外の連絡先の入力にミスあり
     *  ・メールアドレスの重複あり
     *   
     */
    @isTest
    public static void test_save_error002() {
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
        ni.In1_Name__c = '営業時間内１名前';
        ni.In1_Kana__c = 'エイギョウジカンナイ１';
        ni.In1_Company__c = '時間内会社１';

        ni.Out1_Name__c = '営業時間内１名前';
        ni.Out1_Kana__c = 'エイギョウジカンナイ１';
        ni.Out1_Company__c = '時間内会社１';
        ni.Out1_Tel__c = '011-222-3333';
        ni.Out2_Name__c = '営業時間内１名前';
        ni.Out2_Kana__c = 'エイギョウジカンナイ１';
        ni.Out2_Company__c = '時間内会社１';
        // ni.Out2_Tel__c = '011-222-3333';

        ni.Exception__c = 'test2222';

        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'xxxx@test.co.jp';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_MonthlyReportSender__c = true;
        // メールでのご連絡先 2
        ni.Etc2_Name__c = 'テスト氏名2';
        ni.Etc2_Company__c = 'テスト会社2';
        ni.Etc2_Mail__c = 'xxxx@test.co.jp';
        ni.Etc2_OtherThanAlertContact__c = true;
        ni.Etc2_Permission__c = '参照のみ';

        insert ni;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ChangeAddressController ctrl = new ChangeAddressController();
        ctrl.initAction();

        //連絡先情報の変更
        ctrl.save();

        Test.stopTest();
    }
}