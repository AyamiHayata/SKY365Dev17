/********************************************************************************
 *
 * Coodleログイン後トップ画面コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2022/09                              New
 ********************************************************************************/
@isTest
private class CommunityTopControllerTest {
    /**
     * 【対象】
     * initAction
     * 【条件】
     * 利用規約が承認済みの場合
     */
    @isTest
    public static void test_initLoginAction_001() {
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.0;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;

        //サイト規約情報
        List<SiteTerms__c> stlist = new List<SiteTerms__c>();
        SiteTerms__c st = new SiteTerms__c();
        st.Version__c = 1.0;
        st.Sentence__c = '2022年9月１日 サイトメンテナンスのお知らせ';
        st.SentenceType__c = 'お知らせ';
        st.SiteTermsDateTime__c = Datetime.now();
        stlist.add(st);
        SiteTerms__c st2 = new SiteTerms__c();
        st2.Version__c = 1.0;
        st2.Sentence__c = '第１条　ご利用にあたって';
        st2.SentenceType__c = '利用規約';
        st2.SiteTermsDateTime__c = Datetime.now();
        stlist.add(st2);
        insert stlist;
        
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

        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        CommunityTopController ctrl = new CommunityTopController();
        ctrl.initLoginAction();
        Test.stopTest();
    }
    /**
     * 【対象】
     * initAction
     * 【条件】
     * 利用規約が承認済みではない場合
     */
    @isTest
    public static void test_initLoginAction_002() {
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.0;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;

        //サイト規約情報
        List<SiteTerms__c> stlist = new List<SiteTerms__c>();
        SiteTerms__c st = new SiteTerms__c();
        st.Version__c = 1.0;
        st.Sentence__c = '2022年9月１日 サイトメンテナンスのお知らせ';
        st.SentenceType__c = 'お知らせ';
        st.SiteTermsDateTime__c = Datetime.now();
        stlist.add(st);
        SiteTerms__c st2 = new SiteTerms__c();
        st2.Version__c = 1.1;
        st2.Sentence__c = '第１条　ご利用にあたって';
        st2.SentenceType__c = '利用規約';
        st2.SiteTermsDateTime__c = Datetime.now();
        stlist.add(st2);
        insert stlist;
        
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

        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        CommunityTopController ctrl = new CommunityTopController();
        ctrl.initLoginAction();
        Test.stopTest();
    }
    /**
     * 【対象】
     * approvedAgreement
     * 【条件】
     * 
     */
    @isTest
    public static void test_approvedAgreement_001() {
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.0;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.zendeskUserId__c = '1';
        insert zuser;

        //サイト規約情報
        List<SiteTerms__c> stlist = new List<SiteTerms__c>();
        SiteTerms__c st = new SiteTerms__c();
        st.Version__c = 1.0;
        st.Sentence__c = '2022年9月１日 サイトメンテナンスのお知らせ';
        st.SentenceType__c = 'お知らせ';
        st.SiteTermsDateTime__c = Datetime.now();
        stlist.add(st);
        SiteTerms__c st2 = new SiteTerms__c();
        st2.Version__c = 1.1;
        st2.Sentence__c = '第１条　ご利用にあたって';
        st2.SentenceType__c = '利用規約';
        st2.SiteTermsDateTime__c = Datetime.now();
        stlist.add(st2);
        insert stlist;
        
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

        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','1234');
        CommunityTopController ctrl = new CommunityTopController();
        ctrl.initLoginAction();
        ctrl.approvedAgreement();
        Test.stopTest();
    }
    /**
     * 【対象】
     * Logout
     * 【条件】
     * 正常終了
     */
    @isTest
    public static void test_communitysiteLogout_001() {
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.0;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.zendeskUserId__c = '12345';
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        CommunityTopController ctrl = new CommunityTopController();
        ctrl.communitysiteLogout();
        Test.stopTest();
    }
    /**
     * 【対象】
     * Logout
     * 【条件】
     * 異常終了
     */
    @isTest
    public static void test_communitysiteLogout_Error001() {
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.0;
        zuser.Code__c = 'XAXA';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.zendeskUserId__c = '12345';
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        CommunityTopController ctrl = new CommunityTopController();
        ctrl.communitysiteLogout();
        Test.stopTest();
    }


}