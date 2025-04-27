@isTest
public class ZendeskAPIControllerTest {
    
    @isTest static void testCase_executeCreateUser01() {
        //Zendeskユーザが存在しないかつ、APIエラー時
        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(false, true));

        Test.startTest();

        ZendeskAPIController.executeCreateUser(notifyInfo, 1, '12345', notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Company__c, notifyInfo.Etc1_Mail__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c, ProcessingFlg__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];

        System.assertEquals('追加', retNotifyInfo.ETC1_ChgList__c);
        System.assert(String.isNotBlank(retNotifyInfo.ETC1_ErrorLog__c));
        System.assertEquals(false, retNotifyInfo.ProcessingFlg__c);
    }
    @isTest static void testCase_executeCreateUser02() {
        //Zendeskユーザが存在しないかつ、APIエラーがない時
        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(false));

        Test.startTest();

        ZendeskAPIController.executeCreateUser(notifyInfo, 1, '12345', notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Company__c, notifyInfo.Etc1_Mail__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c, ProcessingFlg__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];

        System.assertEquals(null, retNotifyInfo.ETC1_ChgList__c);
        System.assert(String.isBlank(retNotifyInfo.ETC1_ErrorLog__c));
        System.assertEquals(false, retNotifyInfo.ProcessingFlg__c);
    }

    @isTest static void testCase_executeCreateUser03() {
        //Zendeskユーザーが存在する場合
        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        ZendeskAPIController.executeCreateUser(notifyInfo, 1, '12345', notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Company__c, notifyInfo.Etc1_Mail__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c, ProcessingFlg__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];

        System.assertEquals(null, retNotifyInfo.ETC1_ChgList__c);
        System.assertEquals(null, retNotifyInfo.ETC1_ErrorLog__c);
        System.assertEquals(false, retNotifyInfo.ProcessingFlg__c);
    }

    @isTest static void testCase_executeCreateUser04() {
        //Zendeskユーザーが存在してかつ、APIエラーの場合
        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true,true));

        Test.startTest();

        ZendeskAPIController.executeCreateUser(notifyInfo, 1, '12345', notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Company__c, notifyInfo.Etc1_Mail__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c, ProcessingFlg__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
    }

    @isTest static void testCase_executeCreateUser05() {
        //Zendeskユーザーが存在してかつ、APIエラーがある場合
        System.debug('**==**== executeCreateUser04 start ==**==**');
        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        //エラーになるように
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        ct.Department = 'テスト部2';
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;
        constitution.Commercial_flow__c = 'SWX';
        constitution.ZendeskOrganizationId__c = '1';
        update constitution;

        System.debug('**==**== constitution =>' + constitution);
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        ZendeskAPIController.executeCreateUser(notifyInfo, 1, '12345', notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Company__c, notifyInfo.Etc1_Mail__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c, ProcessingFlg__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];

        System.assertEquals('追加', retNotifyInfo.ETC1_ChgList__c);
        System.assert(null <> retNotifyInfo.ETC1_ErrorLog__c);

    }

    @isTest static void testCase_executeDeleteMembership01() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        ZendeskAPIController.executeDeleteMembership(notifyInfo, 1, '12345', notifyInfo.Etc1_Mail__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c, ProcessingFlg__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];

        System.assertEquals(null, retNotifyInfo.ETC1_ChgList__c); // triggerでNULLに更新される
        System.assertEquals(null, retNotifyInfo.ETC1_ErrorLog__c);
        System.assertEquals(false, retNotifyInfo.ProcessingFlg__c);
    }

    @isTest static void testCase_executeDeleteMembership02() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true,true));

        Test.startTest();

        ZendeskAPIController.executeDeleteMembership(notifyInfo, 1, '12345', notifyInfo.Etc1_Mail__c);

        Test.stopTest();

    }


    @isTest static void testCase_executeUpdateUser01() {
        //Zendeskユーザーが存在してかつ、APIエラーがない場合
        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        insert notifyInfo;
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        ZendeskAPIController.executeUpdateUser(notifyInfo, 1, '12345', 'test@sky365.co.jp.ut', '更新テスト', '更新テスト会社', 'upd-test@sky365.co.jp.ut');
        // ZendeskAPIController.executeUpdateUser(notifyInfo, 1, '12345', 'test@sky365.co.jp.ut', '更新テスト', 'テスト会社', 'upd-test@sky365.co.jp.ut');

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c, ProcessingFlg__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];

        System.assertEquals(null, retNotifyInfo.ETC1_ChgList__c);
        System.assertEquals(null, retNotifyInfo.ETC1_ErrorLog__c);
        System.assertEquals(false, retNotifyInfo.ProcessingFlg__c);
    }

    @isTest static void testCase_executeUpdateUser02() {
        //Zendeskユーザーが存在してかつ、APIエラーがある場合
        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        insert notifyInfo;
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true,true));

        Test.startTest();

        ZendeskAPIController.executeUpdateUser(notifyInfo, 1, '12345', 'test@sky365.co.jp.ut', '更新テスト', '更新テスト会社', 'upd-test@sky365.co.jp.ut');

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c, ProcessingFlg__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];

        // System.assertEquals(null, retNotifyInfo.ETC1_ChgList__c);
        System.assert(null <> retNotifyInfo.ETC1_ErrorLog__c);
        // System.assertEquals(false, retNotifyInfo.ProcessingFlg__c);
    }
    @isTest static void testCase_executeUpdateUser03() {
        //Zendeskユーザーが存在してかつ、APIエラーがある場合
        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        insert notifyInfo;
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true,true));

        Test.startTest();

        ZendeskAPIController.executeUpdateUser(notifyInfo, 1, '12345', 'test@sky365.co.jp.ut', '更新テスト', '更新テスト会社', 'upd-test@sky365.co.jp.ut');

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c, ProcessingFlg__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];

        // System.assertEquals(null, retNotifyInfo.ETC1_ChgList__c);
        System.assert(null <> retNotifyInfo.ETC1_ErrorLog__c);
        // System.assertEquals(false, retNotifyInfo.ProcessingFlg__c);
    }

    @isTest static void testCase_executeDeleteOrganizations01() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Map<String, Object> jobStatusMap = new Map<String, Object>{
            'id' => 1
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'job_status' => jobStatusMap
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(200, JSON.serialize(bodyMap)));

        Test.startTest();

        Boolean ret = ZendeskAPIController.executeDeleteOrganizations(new List<String>{'12345'});

        Test.stopTest();

        System.assert(ret);
    }

    @isTest static void testCase_executeDeleteOrganizations02() {

        ZendeskAPIRequester target = new ZendeskAPIRequester();

        Map<String, Object> jobStatusMap = new Map<String, Object>{
            'id' => 1
        };

        Map<String, Object> bodyMap = new Map<String, Object>{
            'job_status' => jobStatusMap
        };

        Test.setMock(HttpCalloutMock.class, new HTTPRequestMock(201, JSON.serialize(bodyMap)));

        Test.startTest();

        Boolean ret = ZendeskAPIController.executeDeleteOrganizations(new List<String>{'12345'});

        Test.stopTest();

    }

    @isTest static void testCase_updateNotifyInfoErrorLog01() {

        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        insert notifyInfo;

        Test.startTest();

        ZendeskAPIController.updateNotifyInfoErrorLog(notifyInfo, 1, 'test@sky365.co.jp.ut', 'upd-test@sky365.co.jp.ut', 'プロセス', 422, 'error', null);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];

        System.assert(null <> retNotifyInfo.ETC1_ErrorLog__c);
    }

    @isTest static void testCase_executeLogout01() {
        //正常終了
        System.debug('**==**== testCase12 start ==**==**');
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        ZendeskAPIController.executeLogout('12345');

        Test.stopTest();
    }
    @isTest static void testCase_executeLogout02() {
        //異常終了
        System.debug('**==**== testCase13 start ==**==**');
        
        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(false));

        Test.startTest();

        ZendeskAPIController.executeLogout('12345');

        Test.stopTest();
    }

    static NotifyInfo__c createNotifyInfo(String processName) {
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
        constitution.Commercial_flow__c = 'SKY365';
        update constitution;

        //連絡先情報
        NotifyInfo__c notifyInfo = new NotifyInfo__c(
            ConstitutionCommon__c = constitution.Id,
            Etc1_ChgList__c = processName,
            Etc1_Name__c = 'テスト',
            Etc1_Company__c = 'テスト会社',
            Etc1_Mail__c = 'test@sky365.co.jp.ut'
        );

        return notifyInfo;
    }
}