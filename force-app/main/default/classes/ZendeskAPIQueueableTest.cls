@isTest
public class ZendeskAPIQueueableTest {
    @isTest static void testCace01() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        ZendeskAPIQueueable queueable = new ZendeskAPIQueueable(notifyInfo.Id, 1);

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(false));

        Test.startTest();

        System.enqueueJob(queueable);

        Test.stopTest();
    }

    @isTest static void testCace02() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;

        ZendeskAPIQueueable queueable = new ZendeskAPIQueueable(notifyInfo.Id, 1);

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

        ZendeskAPIQueueable queueable = new ZendeskAPIQueueable(newNotifyInfo.Id, 1);

        Test.setMock(HttpCalloutMock.class, new ZendeskMultiHttpCalloutMock(true));

        Test.startTest();

        System.enqueueJob(queueable);

        Test.stopTest();
    }

    static NotifyInfo__c createNotifyInfo(String processName) {

        NotifyInfo__c notifyInfo = new NotifyInfo__c(
            Etc1_ChgList__c = processName,
            Etc1_Name__c = 'テスト',
            Etc1_Company__c = 'テスト会社',
            Etc1_Mail__c = 'test@sky365.co.jp.ut'
        );

        return notifyInfo;
    }
}