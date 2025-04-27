/********************************************************************************
 *
 * 静観依頼コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2022/12                              New
 ********************************************************************************/
@isTest
private class SeikanIraiControllerTest {
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
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForSeikanIrai());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        SeikanIraiController ctrl = new SeikanIraiController();
        ctrl.initAction(); 

        Test.stopTest();
    }
    /**
     * 【対象】
     * initAction
     * 【条件】
     * エラーがある場合
     */
    @isTest
    public static void test_initAction_002() {
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
        insert zuser;

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForSeikanIrai());

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        SeikanIraiController ctrl = new SeikanIraiController();
        ctrl.initAction(); 

        Test.stopTest();
    }
    /**
     * 【対象】
     * setAndReleaseMaintenanceInfo
     * 【条件】
     * 
     */
    @isTest
    public static void test_setAndReleaseMaintenanceInfo_001() {
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
        SeikanIraiController ctrl = new SeikanIraiController();
        ctrl.initAction(); 
        ctrl.dispMaintenanceList.get(0).targetCheck=true;
        ctrl.setAndReleaseMaintenanceInfo();
        ctrl.getcAwsResources();
        ctrl.getAwsResources();
        ctrl.dispMaintenanceList.get(0).targetCheck=false;
        ctrl.setAndReleaseMaintenanceInfo();
        ctrl.getcAwsResources();
        ctrl.getAwsResources();

        Test.stopTest();
    }
    /**
     * 【対象】
     * getcAwsResources
     * 【条件】
     * 
     */
    @isTest
    public static void test_getcAwsResources_001() {
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
        SeikanIraiController ctrl = new SeikanIraiController();
        ctrl.initAction(); 
        ctrl.getcAwsResources(); 
        
        Test.stopTest();
    }

    /**
     * 【対象】
     * save
     * 【条件】
     * 
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
        SeikanIraiController ctrl = new SeikanIraiController();
        ctrl.initAction(); 
        ctrl.dispMaintenanceList.get(0).targetCheck=true;
        ctrl.setAndReleaseMaintenanceInfo();
        List<String> selectlist = new List<String>();
        selectlist.add('1');
        ctrl.selectAwsResources = selectlist;
        ctrl.seikanDispId = 'testtesttest';
        ctrl.seikanStartDatetime = Datetime.newInstance(2023, 2, 1, 10, 0, 0);
        ctrl.seikanEndDatetime = Datetime.newInstance(2023, 2, 3, 9, 59, 0);
        ctrl.save();
        Test.stopTest();
    }
    /**
     * 【対象】
     * updateMaintenanceInfo
     * 【条件】
     * 
     */
    @isTest
    public static void test_updateMaintenanceInfo_001() {
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
        SeikanIraiController ctrl = new SeikanIraiController();
        ctrl.initAction(); 
        ctrl.dispMaintenanceList.get(0).targetCheck=true;
        ctrl.setAndReleaseMaintenanceInfo();
        ctrl.updateMaintenanceInfo();
        Test.stopTest();
    }
    /**
     * 【対象】
     * deleteMaintenanceInfo
     * 【条件】
     * 
     */
    @isTest
    public static void test_deleteMaintenanceInfo_001() {
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
        SeikanIraiController ctrl = new SeikanIraiController();
        ctrl.initAction(); 
        ctrl.dispMaintenanceList.get(0).targetCheck=true;
        ctrl.setAndReleaseMaintenanceInfo();
        ctrl.deleteMaintenanceInfo();
        Test.stopTest();
    }
    /**
     * 【対象】
     * test_moveAndRemove_001
     * 【条件】
     * 
     */
    @isTest
    public static void test_moveAndRemove_001() {
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
        SeikanIraiController ctrl = new SeikanIraiController();
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
     * setAndReleaseMaintenanceInfo
     * 【条件】
     * 
     */
    @isTest
    public static void test_seikanIraiZabixInfo_001() {

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

        // ZabbixMaintenance za1 = new ZabbixMaintenance();
        // za1.maintenanceid = '1';
        // za1.name = 'test';
        // za1.seikanstartDtime = datetime.now();
        // seikanIraiZabixInfo sinfo = new seikanIraiZabixInfo(true,za1,datetime.now());

        // ZabbixMaintenance za2 = new ZabbixMaintenance();
        // za2.maintenanceid = '2';
        // za2.name = 'test2';
        // za2.seikanstartDtime = datetime.now();
        // seikanIraiZabixInfo sinfo2 = new seikanIraiZabixInfo(true,za2,datetime.now());
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        SeikanIraiController ctrl = new SeikanIraiController();
        ctrl.initAction(); 
        ctrl.dispMaintenanceList.get(0).compareTo(ctrl.dispMaintenanceList.get(1)); 
        
        Test.stopTest();
    }
}