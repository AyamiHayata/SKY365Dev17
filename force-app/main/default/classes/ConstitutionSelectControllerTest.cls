/********************************************************************************
 *
 * Coodle案件選択画面コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2022/09                              New
 ********************************************************************************/
@isTest
private class ConstitutionSelectControllerTest {
    /**
     * 【対象】
     * selectConstitution
     * 【条件】
     * 連絡先情報が存在する場合
     * ユーザーの権限が編集可の場合
     */
    @isTest
    public static void test_selectConstitution_001() {

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

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'test@sky365.co.jp.ut';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.ZendeskOrganizationId__c = 'XXXXXXXX';
        constitution.name = 'テスト案件';
        insert constitution;

        // 連絡先情報
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = constitution.Id;
        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'test@sky365.co.jp.ut';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        insert ni;

        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ApexPages.currentPage().getParameters().put('selectConstitution',constitution.Id);
        ConstitutionSelectController ctrl = new ConstitutionSelectController();
        ctrl.initAction();
        ctrl.selectConstitution();
        Test.stopTest();
    }
    /**
     * 【対象】
     * selectConstitution
     * 【条件】
     * 連絡先情報が存在する場合
     * ユーザーの権限が参照のみの場合
     */
    @isTest
    public static void test_selectConstitution_002() {
        
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

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'test@sky365.co.jp.ut';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.ZendeskOrganizationId__c = 'XXXXXXXX';
        constitution.name = 'テスト案件';
        insert constitution;

        // 連絡先情報
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = constitution.Id;
        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'test@sky365.co.jp.ut';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '参照のみ';
        insert ni;

        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ApexPages.currentPage().getParameters().put('selectConstitution',constitution.Id);
        ConstitutionSelectController ctrl = new ConstitutionSelectController();
        ctrl.initAction();
        ctrl.selectConstitution();
        Test.stopTest();
    }
    /**
     * 【対象】
     * selectConstitution
     * 【条件】
     * 連絡先情報が存在する場合
     * ユーザーの権限が編集可
     * 申請中の場合
     */
    @isTest
    public static void test_selectConstitution_003() {
        //サイト規約情報
        List<SiteTerms__c> stlist = new List<SiteTerms__c>();
        SiteTerms__c st = new SiteTerms__c();
        st.Version__c = 1.1;
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
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.0;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'test@sky365.co.jp.ut';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.ZendeskOrganizationId__c = 'XXXXXXXX';
        constitution.name = 'テスト案件';
        insert constitution;

        // 連絡先情報
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = constitution.Id;
        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'test@sky365.co.jp.ut';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_ChgList__c='追加';
        ni.Status__c='受付';
        insert ni;


        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ApexPages.currentPage().getParameters().put('selectConstitution',constitution.Id);
        ConstitutionSelectController ctrl = new ConstitutionSelectController();
        ctrl.initAction();
        ctrl.selectConstitution();
        Test.stopTest();
    }
    /**
     * 【対象】
     * selectConstitution
     * 【条件】
     * 連絡先情報が存在しない場合
     */
    @isTest
    public static void test_selectConstitution_error001() {
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
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'test@sky365.co.jp.ut';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.ZendeskOrganizationId__c = 'XXXXXXXX';
        constitution.name = 'テスト案件';
        insert constitution;

        // 連絡先情報
        // NotifyInfo__c ni = new NotifyInfo__c();
        // ni.ConstitutionCommon__c = constitution.Id;
        // // メールでのご連絡先 1
        // ni.Etc1_Name__c = 'テスト氏名';
        // ni.Etc1_Company__c = 'テスト会社';
        // ni.Etc1_Mail__c = 'test@sky365.co.jp.ut';
        // ni.Etc1_AlertContact__c = true;
        // ni.Etc1_Permission__c = '編集可';
        // ni.Etc1_ChgList__c='追加';
        // ni.Status__c='受付';
        // insert ni;


        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ApexPages.currentPage().getParameters().put('selectConstitution',constitution.Id);
        ConstitutionSelectController ctrl = new ConstitutionSelectController();
        ctrl.initAction();
        ctrl.selectConstitution();
        Test.stopTest();
    }
    /**
     * 【対象】
     * selectSeikan
     * 【条件】
     * 連絡先情報が存在する場合
     * ユーザーが連絡先情報にない場合
     */
    @isTest
    public static void test_selectSeikan_001() {
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
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'test@sky365.co.jp.ut';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.ZendeskOrganizationId__c = 'XXXXXXXX';
        insert constitution;

        // 連絡先情報
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = constitution.Id;
        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'test2@sky365.co.jp.ut';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_ChgList__c='追加';
        ni.Status__c='受付';
        insert ni;

        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ApexPages.currentPage().getParameters().put('selectConstitution',constitution.Id);
        ConstitutionSelectController ctrl = new ConstitutionSelectController();
        ctrl.initAction();
        ctrl.selectSeikan();
        Test.stopTest();
    }
    /**
     * 【対象】
     * selectSeikan
     * 【条件】
     * 連絡先情報が存在する場合
     * ユーザーが連絡先情報にある場合
     */
    @isTest
    public static void test_selectSeikan_002() {
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
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'test@sky365.co.jp.ut';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.ZendeskOrganizationId__c = 'XXXXXXXX';
        insert constitution;

        // 連絡先情報
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = constitution.Id;
        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'test@sky365.co.jp.ut';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_ChgList__c='追加';
        ni.Status__c='受付';
        insert ni;

        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ApexPages.currentPage().getParameters().put('selectConstitution',constitution.Id);
        ConstitutionSelectController ctrl = new ConstitutionSelectController();
        ctrl.initAction();
        ctrl.selectSeikan();
        Test.stopTest();
    }
    /**
     * 【対象】
     * selectRReport
     * 【条件】
     * 連絡先情報が存在する場合
     * ユーザーが連絡先情報にない場合
     */
    @isTest
    public static void test_selectRReport_001() {
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
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'test@sky365.co.jp.ut';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.ZendeskOrganizationId__c = 'XXXXXXXX';
        insert constitution;

        // 連絡先情報
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = constitution.Id;
        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'test2@sky365.co.jp.ut';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_ChgList__c='追加';
        ni.Status__c='受付';
        insert ni;

        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ApexPages.currentPage().getParameters().put('selectConstitution',constitution.Id);
        ConstitutionSelectController ctrl = new ConstitutionSelectController();
        ctrl.initAction();
        ctrl.selectRReport();
        Test.stopTest();
    }

    /**
     * 【対象】
     * selectSReport
     * 【条件】
     * 連絡先情報が存在する場合
     * ユーザーが連絡先情報にない場合
     */
    @isTest
    public static void test_selectSReport_001() {
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
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'test@sky365.co.jp.ut';
        zuser.LastLoginDateTime__c = Datetime.now();
        zuser.zendeskUserId__c = '1';
        insert zuser;
        
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.ZendeskOrganizationId__c = 'XXXXXXXX';
        insert constitution;

        // 連絡先情報
        NotifyInfo__c ni = new NotifyInfo__c();
        ni.ConstitutionCommon__c = constitution.Id;
        // メールでのご連絡先 1
        ni.Etc1_Name__c = 'テスト氏名';
        ni.Etc1_Company__c = 'テスト会社';
        ni.Etc1_Mail__c = 'test2@sky365.co.jp.ut';
        ni.Etc1_AlertContact__c = true;
        ni.Etc1_Permission__c = '編集可';
        ni.Etc1_ChgList__c='追加';
        ni.Status__c='受付';
        insert ni;

        Test.setMock(HttpCalloutMock.class, new ZendeskAuthHttpCalloutMock(true));
        Test.startTest();
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ApexPages.currentPage().getParameters().put('selectConstitution',constitution.Id);
        ConstitutionSelectController ctrl = new ConstitutionSelectController();
        ctrl.initAction();
        ctrl.selectSReport();
        Test.stopTest();
    }
}