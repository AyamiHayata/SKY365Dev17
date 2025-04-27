/********************************************************************************
 *
 * リソースレポートコントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2024/01                              New
 ********************************************************************************/
@isTest
private class ZabbixReportControllerTest {
    @testSetup static void setUpTestData() {
        // カスタムメタデータのテストデータを作成する
        // insert new ZabbixSetting__mdt(
        //     DeveloperName = 'Test Site Name'
        //     , ID__c = 'http://www.example.com'
        //     , password__c = 'http://www.example.com'
        //     , EndPoint__c = 'http://www.example.com'
        //     );
    }
    /**
     * 【対象】
     * initAction
     * 【条件】
     * エラーがない場合
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
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;
        
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.LastLoginDateTime__c = Datetime.now();
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.getPkinds(); 
        ctrl.initAction(); 

        Test.stopTest();
    }
    /**
     * 【対象】
     * refresh
     * 【条件】
     * エラーがない場合
     */
    @isTest
    public static void test_refresh_002() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;
        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;
        
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.LastLoginDateTime__c = Datetime.now();
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.getPkinds(); 
        ctrl.initAction(); 
        
        ctrl.refresh(); 

        Test.stopTest();
    }
    /**
     * 【対象】
     * describeGraph
     * 【条件】
     * エラーがない場合
     */
    @isTest
    public static void test_describeGraph_003() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;
        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;
        
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.LastLoginDateTime__c = Datetime.now();
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.getPkinds(); 
        ctrl.initAction(); 
        ctrl.periodkind = '最新の30日';
        ctrl.describeGraph(); 
        ctrl.periodkind = '最新の3ヶ月';
        ctrl.describeGraph(); 
        ctrl.periodkind = '最新の一年';
        ctrl.describeGraph(); 
        ctrl.periodkind = '最新の1時間';
        ctrl.describeGraph(); 
        ctrl.periodkind = '最新の3時間';
        ctrl.describeGraph(); 
        ctrl.periodkind = '最新の12時間';
        ctrl.describeGraph(); 
        ctrl.periodkind = '最新の24時間';
        ctrl.describeGraph(); 

        Test.stopTest();
    }
    /**
     * 【対象】
     * describeGraph
     * 【条件】
     * エラーがない場合
     */
    @isTest
    public static void test_describeGraph_003_2() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;
        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'BeeX_Common_Zabbix2';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;
        
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.LastLoginDateTime__c = Datetime.now();
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.getPkinds(); 
        ctrl.initAction(); 
        ctrl.periodkind = '最新の30日';
        ctrl.describeGraph(); 

        Test.stopTest();
    }
        /**
     * 【対象】
     * describeGraph
     * 【条件】
     * エラーがない場合
     */
    @isTest
    public static void test_downloadCSV_004() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;
        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;
        
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.LastLoginDateTime__c = Datetime.now();
        insert zuser;
        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.getPkinds(); 
        ctrl.initAction();
        ctrl.selectedItemId = '12345';
        ctrl.selectedItemName = 'testItemName';
        ctrl.reportStartDatetime = Datetime.now();
        ctrl.downloadCSV();
        Test.stopTest();
    }
        /**
     * 【対象】
     * getcAwsResources
     * 【条件】
     * 
     */
    @isTest
    public static void test_getcAwsResources_005() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.initAction(); 
        ctrl.getcAwsResources();
        ctrl.selectedStatus = '追加';
        
        Test.stopTest();
    }
    /**
     * 【対象】
     * test_moveAndRemove_001
     * 【条件】
     * 
     */
    @isTest
    public static void test_moveAndRemove_006() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.initAction(); 
        ctrl.candidateAwsResources = new List<String>{'1','2'};
        ctrl.moveAwsResources(); 
        ctrl.getcAwsResources();
        ctrl.getAwsResources();
        //同じものを選択した場合
        ctrl.candidateAwsResources = new List<String>{'1'};
        ctrl.moveAwsResources(); 
        ctrl.getcAwsResources();
        ctrl.getAwsResources();

        ctrl.selectAwsResources = new List<String>{'2'};
        ctrl.removeAwsResources();
        ctrl.getcAwsResources();
        ctrl.getAwsResources();

        Test.stopTest();
    }
    /**
     * 【対象】
     * test_previousPage_008
     * 【条件】
     * 
     */
    @isTest
    public static void test_previousPage_008() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());
        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.initAction(); 
        ctrl.previousPage();

        Test.stopTest();
    }
    /**
     * 【対象】
     * test_nextPage_009
     * 【条件】
     * 
     */
    @isTest
    public static void test_nextPage_009() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());
        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.initAction(); 
        ctrl.nextPage();

        Test.stopTest();
    }
    /**
     * 【対象】
     * test_moveAllAwsResources_010
     * 【条件】
     * 
     */
    @isTest
    public static void test_moveAllAwsResources_010() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());
        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.initAction(); 
        ctrl.moveAllAwsResources();

        Test.stopTest();
    }
    /**
     * 【対象】
     * test_removeAllAwsResources_011
     * 【条件】
     * 
     */
    @isTest
    public static void test_removeAllAwsResources_011() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());
        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.initAction(); 
        ctrl.removeAllAwsResources();

        Test.stopTest();
    }

    /**
     * 【対象】
     * test_periodRadioChanged_001
     * 【条件】
     * 
     */
    @isTest
    public static void test_periodRadioChanged_007() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = 'Sky_Zabbix_03';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;

        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForSeikanIrai());
        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();
        ctrl.initAction(); 
        ctrl.periodRadioChanged(); 

        Test.stopTest();
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * エラーがない場合
     */
    @isTest
    public static void test_Error_001() {
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;
        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        constitution.Zabbix_Datadog__c = '';
        constitution.ZabbixGroupId__c = '12345';
        insert constitution;
        
        //Zendeskユーザー
        ZendeskUser__c zuser = new ZendeskUser__c();
        zuser.Name__c = 'テストユーザー';
        zuser.ZendeskOrgId2__c = 'XXXXXXXX';
        zuser.ConsentVersion__c = 1.1;
        zuser.Code__c = 'xxxxxx';
        zuser.Email__c = 'xxxx5@test.co.jp';
        zuser.LastLoginDateTime__c = Datetime.now();
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixReportController ctrl = new ZabbixReportController();

        Test.stopTest();
    }
}