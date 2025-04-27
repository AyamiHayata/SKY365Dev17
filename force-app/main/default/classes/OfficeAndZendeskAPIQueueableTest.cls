@isTest
public class OfficeAndZendeskAPIQueueableTest {
    
    @isTest static void testCace01() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(false));

        Test.startTest();

        System.enqueueJob(queueable);

        Test.stopTest();
    }

    @isTest static void testCace02() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;

        OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        System.enqueueJob(queueable);

        Test.stopTest();
    }

    @isTest static void testCace03() {

        NotifyInfo__c notifyInfo = createNotifyInfo(null);
        insert notifyInfo;

        NotifyInfo__c newNotifyInfo = createNotifyInfo('変更');
        newNotifyInfo.Etc1_Company__c = '更新テスト';
        newNotifyInfo.Etc1_Mail__c = 'upd-test@sky365.co.jp.ut';
        newNotifyInfo.PastOne__c = notifyInfo.Id;
        insert newNotifyInfo;

        OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(newNotifyInfo.Id, 1);

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        System.enqueueJob(queueable);

        Test.stopTest();
    }

    // @isTest static void testCace04() {

    //     NotifyInfo__c notifyInfo = createNotifyInfo('追加');
    //     notifyInfo.Etc1_AlertContact__c = true;
    //     insert notifyInfo;

    //     OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);

    //     Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(9, 0, 0, 0, 0));

    //     Test.startTest();

    //     System.enqueueJob(queueable);

    //     Test.stopTest();
    // }

    // @isTest static void testCace05() {

    //     NotifyInfo__c notifyInfo = createNotifyInfo('追加');
    //     notifyInfo.Etc1_OtherThanAlertContact__c = true;
    //     insert notifyInfo;

    //     OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);

    //     Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(9, 0, 0, 0, 0));

    //     Test.startTest();

    //     System.enqueueJob(queueable);

    //     Test.stopTest();
    // }

    // @isTest static void testCace06() {

    //     NotifyInfo__c notifyInfo = createNotifyInfo('削除');
    //     notifyInfo.Etc1_AlertContact__c = true;
    //     insert notifyInfo;

    //     OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);

    //     Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(9, 0, 0, 0, 0));

    //     Test.startTest();

    //     System.enqueueJob(queueable);

    //     Test.stopTest();
    // }

    // @isTest static void testCace07() {

    //     NotifyInfo__c notifyInfo = createNotifyInfo('削除');
    //     notifyInfo.Etc1_OtherThanAlertContact__c = true;
    //     insert notifyInfo;

    //     OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);

    //     Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(9, 0, 0, 0, 0));

    //     Test.startTest();

    //     System.enqueueJob(queueable);

    //     Test.stopTest();
    // }

    // @isTest static void testCace08() {

    //     NotifyInfo__c notifyInfo = createNotifyInfo('変更');
    //     notifyInfo.Etc1_AlertContact__c = true;
    //     insert notifyInfo;

    //     OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);

    //     Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(9, 0, 0, 0, 0));

    //     Test.startTest();

    //     System.enqueueJob(queueable);

    //     Test.stopTest();
    // }
        
    // @isTest static void testCace09() {

    //     NotifyInfo__c notifyInfo = createNotifyInfo('変更');
    //     notifyInfo.Etc1_OtherThanAlertContact__c = true;
    //     insert notifyInfo;

    //     OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);

    //     Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(9, 0, 0, 0, 0));

    //     Test.startTest();

    //     System.enqueueJob(queueable);

    //     Test.stopTest();
    // }
    
    static NotifyInfo__c createNotifyInfo(String processName) {

        NotifyInfo__c notifyInfo = new NotifyInfo__c(
            Etc1_ChgList__c = processName,
            Etc1_Name__c = 'テスト',
            Etc1_Company__c = 'テスト会社',
            Etc1_Mail__c = 'test@sky365.co.jp.ut',
            SendListAlert__c = 'test_haifu1@srv02.sky365.co.jp',
            SendListAlertExpet__c = 'test_haifu2@srv02.sky365.co.jp'
        );

        return notifyInfo;
    }
}