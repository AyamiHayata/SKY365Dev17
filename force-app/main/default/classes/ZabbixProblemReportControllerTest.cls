/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * パートナーサイト Zabbix障害レポートテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2024/1      新規作成     kikuchi
 ********************************************************************************/
@isTest
 public with sharing class ZabbixProblemReportControllerTest {

    /**
     * 正常系
     * 
     */
    @isTest static void test01() {
		system.debug('■■■テスト準備■■■');
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
        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForProblemRep());

        system.debug('■■■テスト実行■■■');
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixProblemReportController ctrl = new ZabbixProblemReportController();
        ctrl.initAction();
        ctrl.refresh();
        Test.stopTest();
        system.debug('■■■テスト検証■■■');
    }

    /**
     * 正常系(リソース追加と削除)
     * 
     */
    @isTest static void test02() {
		system.debug('■■■テスト準備■■■');
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
        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForProblemRep());

        system.debug('■■■テスト実行■■■');
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        ZabbixProblemReportController ctrl = new ZabbixProblemReportController();
        ctrl.initAction();
        // リソース削除
        ctrl.selectAwsResources = new List<String>();
        ctrl.selectAwsResources.add('1');
        ctrl.removeAwsResources();
        ctrl.getcAwsResources();
        ctrl.getAwsResources();

        // リソース追加
        ctrl.candidateAwsResources.add('1');
        ctrl.moveAwsResources();
        ctrl.getcAwsResources();
        ctrl.getAwsResources();

        Test.stopTest();
        system.debug('■■■テスト検証■■■');
    }
}