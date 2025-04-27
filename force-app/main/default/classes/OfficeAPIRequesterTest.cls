@isTest
public class OfficeAPIRequesterTest {
    
    /**
     * トークン取得
     */
    @isTest static void testCace01() {

        OfficeAPIRequester target = new OfficeAPIRequester('Sky_Office_01@exanpel.com', null, 'test_haifu@srv02.sky365.co.jp', 'テスト 太郎', '追加');

        Map<String, Object> bodyMap = new Map<String, Object>{
            'access_token' => 'eyJ0eXAiOiJKV1QiLCJub25jZSI6IkE2Z2J5eERQN2M3YUw3Nk14NzVHMDNXdkZDX01CSVpDdTdqTmJTdmQ5ZU0iLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kZjYwODdkNy04YjFkLTRhMGUtOTk2ZS01MTVjMzEyOGEyMWIvIiwiaWF0IjoxNjYxMjI4MTkwLCJuYmYiOjE2NjEyMjgxOTAsImV4cCI6MTY2MTIzMjA5MCwiYWlvIjoiRTJaZ1lEQ3RpK1p6YmZ5dElTU3hZaDNEamJQc0FBPT0iLCJhcHBfZGlzc',
            'token_type' => 'Bearer'
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        HttpResponse res = target.requestToken();

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }
    
    /**
     * Microsoft Graph取得
     */
    @isTest static void testCace02() {

        OfficeAPIRequester target = new OfficeAPIRequester(null, 'Sky_Office_01@exanpel.com', 'test_haifu@srv02.sky365.co.jp', 'テスト 太郎', '追加');

        Map<String, Object> bodyMap = new Map<String, Object>{
            '@odata.context' => 'https://graph.microsoft.com/v1.0/$metadata#groups',
            'value' => 'XXXXX'
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        HttpResponse res = target.restMicrosoftGraph('eyJ0eXAiOiJKV1QiLCJub25jZSI6IkE2Z2J5eERQN2M3YUw3Nk14NzVHMDNXdkZDX01CSVpDdTdqTmJTdmQ5ZU0iLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kZjYwODdkNy04YjFkLTRhMGUtOTk2ZS01MTVjMzEyOGEyMWIvIiwiaWF0IjoxNjYxMjI4MTkwLCJuYmYiOjE2NjEyMjgxOTAsImV4cCI6MTY2MTIzMjA5MCwiYWlvIjoiRTJaZ1lEQ3RpK1p6YmZ5dElTU3hZaDNEamJQc0FBPT0iLCJhcHBfZGlzc', 'contacts', null);

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    /**
     * 連絡先の追加
     */
    @isTest static void testCace03() {

        OfficeAPIRequester target = new OfficeAPIRequester(null, 'Sky_Office_01@exanpel.com', 'test_haifu@srv02.sky365.co.jp', 'テスト 太郎', '追加');

        Map<String, Object> bodyMap = new Map<String, Object>{
            'result' => '[SUCCESS]#New-MailContact'
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        HttpResponse res = target.newContact();

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }
    
    /**
     * 連絡先の変更
     */
    @isTest static void testCace04() {

        OfficeAPIRequester target = new OfficeAPIRequester('Sky_Office_02@exanpel.com', 'Sky_Office_01@exanpel.com', 'test_haifu@srv02.sky365.co.jp', 'テスト 太郎', '追加');

        Map<String, Object> bodyMap = new Map<String, Object>{
            'result' => '[SUCCESS]#Set-MailContact'
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        HttpResponse res = target.setMailContact();

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    /**
     * 連絡先の削除
     */
    @isTest static void testCace05() {

        OfficeAPIRequester target = new OfficeAPIRequester(null, 'Sky_Office_01@exanpel.com', 'test_haifu@srv02.sky365.co.jp', 'テスト 太郎', '追加');

        Map<String, Object> bodyMap = new Map<String, Object>{
            'result' => '[SUCCESS]#Remove-MailContact'
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        HttpResponse res = target.removeContact();

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    /**
     * メーリングリストへのメンバー追加
     */
    @isTest static void testCace06() {

        OfficeAPIRequester target = new OfficeAPIRequester(null, 'Sky_Office_01@exanpel.com', 'test_haifu@srv02.sky365.co.jp', 'テスト 太郎', '追加');

        Map<String, Object> bodyMap = new Map<String, Object>{
            'result' => '[SUCCESS]#Add-DistributionGroupMember'
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        HttpResponse res = target.addGroupMember('test_haifu@srv02.sky365.co.jp', 'Sky_Office_01@exanpel.com');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    /**
     * メーリングリストへのメンバー削除
     */
    @isTest static void testCace07() {

        OfficeAPIRequester target = new OfficeAPIRequester(null, 'Sky_Office_01@exanpel.com', 'test_haifu@srv02.sky365.co.jp', 'テスト 太郎', '追加');

        Map<String, Object> bodyMap = new Map<String, Object>{
            'result' => '[SUCCESS]#Remove-DistributionGroupMember'
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        HttpResponse res = target.removeGroupMember('test_haifu@srv02.sky365.co.jp', 'Sky_Office_01@exanpel.com');

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    /**
     * 配布グループの削除
     */
    @isTest static void testCace08() {

        OfficeAPIRequester target = new OfficeAPIRequester(null, 'Sky_Office_01@exanpel.com', 'test_haifu@srv02.sky365.co.jp', 'テスト 太郎', '追加');

        Map<String, Object> bodyMap = new Map<String, Object>{
            'result' => '[SUCCESS]#Remove-DistributionGroup'
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        HttpResponse res = target.removeGroup();

        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }
    
}