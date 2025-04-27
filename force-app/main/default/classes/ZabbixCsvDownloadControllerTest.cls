/********************************************************************************
 *
 * Graphを構成するデータをCSV形式でダウンロードするクラスのテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2024/03                              New
 ********************************************************************************/
@isTest
private class ZabbixCsvDownloadControllerTest {


    static testMethod void testZabbixCsvDownloadController() {
        // モックをZabbixAPIControllerに登録
        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

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

        // テスト開始
        Test.startTest();
        ApexPages.currentPage().getParameters().put('zid',zuser.Id);
        ApexPages.currentPage().getParameters().put('constitutionid',constitution.Id);
        ApexPages.currentPage().getParameters().put('code','xxxxxx');
        // テスト用のURLパラメータを作成
        Map<String, String> params = new Map<String, String>{
            'selectedItemId' => EncodingUtil.urlEncode('item123', 'UTF-8'),
            'reportStartDatetime' => EncodingUtil.urlEncode('2023-01-01 00:00:00', 'UTF-8'),
            'reportEndDatetime' => EncodingUtil.urlEncode('2023-01-02 00:00:00', 'UTF-8'),
            'groupId' => EncodingUtil.urlEncode('12345', 'UTF-8'),
            'kanshiSystem' => EncodingUtil.urlEncode('Sky_Zabbix_03', 'UTF-8'),
            'attachfilename' => 'report.csv' // EncodingUtil.urlEncode is not necessary for filenames
        };
        for (String paramName : params.keySet()) {
            ApexPages.currentPage().getParameters().put(paramName, params.get(paramName));
        }
        ZabbixCsvDownloadController ctrl = new ZabbixCsvDownloadController();
        ctrl.createCSV();

        Test.stopTest();



        // アサート: createCSVが期待通りの結果を生成しているか
        // String expectedCsvContent = 'timestamp,value\n2023-01-01T00:00:00Z,100\n2023-01-02T00:00:00Z,200';
        // System.assertEquals(expectedCsvContent, ctrl.graphCsvContent);
    }
}