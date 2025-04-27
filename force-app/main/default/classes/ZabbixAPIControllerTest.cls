@isTest
public class ZabbixAPIControllerTest {
    
    @isTest static void testCace01() {

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        ZabbixAPIController.executeGetAWSResources('Sky_Zabbix_03', '12345');

        Test.stopTest();
    }

    @isTest static void testCace02() {

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        List<ZabbixMaintenance> ret = ZabbixAPIController.executeGetMaintenances('Sky_Zabbix_03', '12345');

        Test.stopTest();

        System.assert(ret[0].disp_timeperiod_type <> null);
        System.assert(ret[0].dt_active_since <> null);
        System.assert(ret[0].disp_active_since <> null);
        System.assert(ret[0].dt_active_till <> null);
        System.assert(ret[0].disp_active_till <> null);
        System.assert(ret[0].disp_start_time <> null);
        System.assert(ret[0].disp_end_time <> null);
    }

    @isTest static void testCace03() {

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        ZabbixAPIController.executeCreateMaintenances('Sky_Zabbix_03'
            , 'テストメンテナンス', new List<String>{'10001','10002'}, Datetime.now(), Datetime.now().addHours(3));

        Test.stopTest();
    }

    @isTest static void testCace04() {

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        ZabbixAPIController.executeUpdateMaintenances('Sky_Zabbix_03', '1'
            , 'テストメンテナンス', new List<String>{ '10001', '10002' }, Datetime.now(), Datetime.now().addHours(3));

        Test.stopTest();
    }

    @isTest static void testCace05() {

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        ZabbixAPIController.executeDeleteMaintenances('Sky_Zabbix_03', '1');

        Test.stopTest();
    }
}