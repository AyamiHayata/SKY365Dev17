@isTest
public class ZabbixAPIRequesterTest {
    
    @isTest static void testCace01() {

        ZabbixAPIRequester target = new ZabbixAPIRequester('Sky_Zabbix_01');

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        HttpResponse res = target.getToken();

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace02() {

        ZabbixAPIRequester target = new ZabbixAPIRequester('Sky_Zabbix_01');

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        HttpResponse res = target.getHosts('1', 'testtoken');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace03() {

        ZabbixAPIRequester target = new ZabbixAPIRequester('Sky_Zabbix_01');

        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        HttpResponse res = target.getMaintenances('1', 'testtoken');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace04() {

        ZabbixAPIRequester target = new ZabbixAPIRequester('Sky_Zabbix_01');
        
        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        HttpResponse res = target.createMaintenances('test-maintenance', new List<String>{ '10001', '10002' }
            , Datetime.now().getTime() / 1000, Datetime.now().addHours(3).getTime() / 1000, 'testtoken');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace05() {

        ZabbixAPIRequester target = new ZabbixAPIRequester('Sky_Zabbix_01');
        
        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        HttpResponse res = target.updateMaintenances('1', 'test-maintenance', new List<String>{ '10001', '10002' }
            , Datetime.now().getTime() / 1000, Datetime.now().addHours(3).getTime() / 1000, 'testtoken');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace06() {

        ZabbixAPIRequester target = new ZabbixAPIRequester('Sky_Zabbix_01');
        
        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMock());

        Test.startTest();

        HttpResponse res = target.deleteMaintenances(new List<String>{'1'}, 'testtoken');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }
    //Weblogin
    @isTest static void testCace07() {

        ZabbixAPIRequester target = new ZabbixAPIRequester('BeeX_Common_Zabbix2');
        
        Test.setMock(HttpCalloutMock.class, new ZabbixMultiHttpCalloutMockForResourceRep());

        Test.startTest();

        HttpResponse res = target.weblogin();

        Test.stopTest();

    }
}