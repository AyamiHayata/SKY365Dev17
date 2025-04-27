@isTest
public class ZendeskAPIRequesterTest {
    
    @isTest static void testCace01() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(false));

        Test.startTest();

        HttpResponse res = target.getZendeskUser('test@sky365.co.jp.ut');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace02() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(false));

        Test.startTest();

        HttpResponse res = target.createZendeskUser('12345', '名前', '会社名', 'test@sky365.co.jp.ut');

        Test.stopTest();

        System.assertEquals(201, res.getStatusCode());
    }

    @isTest static void testCace03() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        HttpResponse res = target.createZendeskMembership('12345', '1');

        Test.stopTest();

        System.assertEquals(201, res.getStatusCode());
    }

    @isTest static void testCace04() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        HttpResponse res = target.searchZendeskMembership('12345', '1');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace05() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        HttpResponse res = target.deleteZendeskMembership('1');

        Test.stopTest();

        System.assertEquals(204, res.getStatusCode());
    }

    @isTest static void testCace06() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        HttpResponse res = target.updateZendeskUser('1', '名前', '会社名');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace07() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        HttpResponse res = target.searchZendeskIdentity('1');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace08() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        HttpResponse res = target.updateZendeskIdentity('1', '2', 'upd-test@sky365.co.jp.ut');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    @isTest static void testCace09() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Map<String, Object> jobStatusMap = new Map<String, Object>{
            'id' => 1
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'job_status' => jobStatusMap
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        HttpResponse res = target.deleteZendeskOrganizations(new List<String>{'12345'});

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }
}