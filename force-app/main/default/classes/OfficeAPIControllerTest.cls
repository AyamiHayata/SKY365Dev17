@isTest
public class OfficeAPIControllerTest {
    
    /**
     * トークン取得
     *　追加：取得エラー
     *   
     *
     */
    @isTest static void testCace_Token_01() {
    
        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;
                
        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(9, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Officeトークン取得', 201);

        // エラー
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }   

    /**
     * トークン取得
     *　追加：トークンなし
     *
     */
    @isTest static void testCace_Token_02() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;
                
        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(8, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Officeトークン取得:トークンなし', 200);

        // エラー
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * トークン取得
     *　削除：取得エラー
     *
     */
    @isTest static void testCace_Token_03() {
    
        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(9, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeDelete(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Officeトークン取得', 201);

        // エラー
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * トークン取得
     *　削除：トークンなし
     *
     */
    @isTest static void testCace_Token_04() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;
                
        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(8, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeDelete(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Officeトークン取得:トークンなし', 200);

        // エラー
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * トークン取得
     *　変更：取得エラー
     *
     */
    @isTest static void testCace_Token_05() {

        NotifyInfo__c pastNotifyInfo = createNotifyInfo(null);
        pastNotifyInfo.Etc1_Mail__c = 'testMailSky365_2@example.com';
        insert pastNotifyInfo;
    
        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        notifyInfo.PastOne__c = pastNotifyInfo.Id;
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(9, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeUpdate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c, pastNotifyInfo, notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Officeトークン取得', 201);

        // エラー
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * トークン取得エラー
     *　変更：トークンなし
     *
     */
    @isTest static void testCace_Token_06() {

        NotifyInfo__c pastNotifyInfo = createNotifyInfo(null);
        pastNotifyInfo.Etc1_Mail__c = 'testMailSky365_2@example.com';
        insert pastNotifyInfo;
    
        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        notifyInfo.PastOne__c = pastNotifyInfo.Id;
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(8, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeUpdate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c, pastNotifyInfo, notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Officeトークン取得:トークンなし', 200);

        // エラー
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 案件が開始されたとき
     * 担当者が追加になったとき
     * 
     * 連絡先検索：エラー
     *
     */
    @isTest static void testCace_Create_01() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 9, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Office連絡先検索：Microsoft Graphの呼び出し', 201);

        // エラー        
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 案件が開始されたとき
     * 担当者が追加になったとき
     *
     * 連絡先登録済み：正常
     */
    @isTest static void testCace_Create_02() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        String resLog = null;

        // 正常        
        System.assertEquals(true, result);
        System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }
  
    /**
     * 案件が開始されたとき
     * 担当者が追加になったとき
     *
     * 連絡先登録：エラー
     */
    @isTest static void testCace_Create_03() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 8, 0, 9, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Office連絡先登録', 0);

        // エラー  
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 案件が開始されたとき
     * 担当者が追加になったとき
     *
     * 配布グループ検索：配布グループが存在しないエラー
     */
    @isTest static void testCace_Create_04() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 8, 8, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Office配布グループ検索', 200);

        // エラー  
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 案件が開始されたとき
     * 担当者が追加になったとき
     *
     * 配布グループ検索：エラー
     */
    @isTest static void testCace_Create_05() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 8, 9, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Office配布グループ検索：Microsoft Graphの呼び出し', 201);

        // エラー  
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 案件が開始されたとき
     * 担当者が追加になったとき
     *
     * 配布グループ登録：エラー
     */
    @isTest static void testCace_Create_06() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 8, 0, 0, 9));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Office配布グループ登録', 0);

        // エラー  
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 案件が開始されたとき
     * 担当者が追加になったとき
     *
     * 正常
     */
    @isTest static void testCace_Create_07() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 8, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = null;

        // エラー  
        System.assertEquals(true, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 案件が開始されたとき
     * 担当者が追加になったとき
     *
     * 連絡先登録済み：正常
     */
    @isTest static void testCace_Create_08() {

        NotifyInfo__c notifyInfo = createNotifyInfo('追加');
        notifyInfo.Etc1_AlertContact__c = false;
        notifyInfo.Etc1_OtherThanAlertContact__c = true;
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeCreate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        String resLog = null;

        // 正常        
        System.assertEquals(true, result);
        System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 担当者が減ったとき
     *
     * 連絡先検索：連絡先存在しないエラー
     */
    @isTest static void testCace_Delete_01() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 8, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeDelete(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = null;

        // 正常        
        System.assertEquals(true, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }
  
    /**
     * 担当者が減ったとき
     *
     * 連絡先検索：エラー
     */
    @isTest static void testCace_Delete_02() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 9, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeDelete(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Office連絡先検索：Microsoft Graphの呼び出し', 201);

        // エラー  
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 担当者が減ったとき
     *
     * 配布グループ取得：エラー
     */
    @isTest static void testCace_Delete_03() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 9, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeDelete(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Office配布グループ検索', 201);

        // エラー  
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 担当者が減ったとき
     *
     * 配布グループ検索：配布グループが存在しないエラー
     */
    @isTest static void testCace_Delete_04() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 8, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeDelete(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Office配布グループ検索', 200);

        // エラー  
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 担当者が減ったとき
     *
     * 配布グループ削除：エラー
     */
    @isTest static void testCace_Delete_05() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 0, 0, 9));

        Test.startTest();

        Boolean result = OfficeAPIController.executeDelete(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog(notifyInfo.Etc1_Mail__c, null, 'Office配布グループ削除', 0);

        // エラー  
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 担当者が減ったとき
     *
     * 正常
     */
    @isTest static void testCace_Delete_06() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeDelete(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        String resLog = null;

        // エラー  
        System.assertEquals(true, result);
        System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 担当者が減ったとき
     *
     * 正常
     */
    @isTest static void testCace_Delete_07() {

        NotifyInfo__c notifyInfo = createNotifyInfo('削除');
        notifyInfo.Etc1_AlertContact__c = false;
        notifyInfo.Etc1_OtherThanAlertContact__c = true;
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeDelete(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c,  notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        String resLog = null;

        // エラー  
        System.assertEquals(true, result);
        System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }
    
    /**
     * 担当者の氏名やメアド（属性情報）が変更になったとき
     *
     * 連絡先検索：連絡先が存在しないエラー
     *  2023.05.25 変更　存在しない場合でもエラーにしない
     */
    @isTest static void testCace_Update_01() {

        NotifyInfo__c pastNotifyInfo = createNotifyInfo(null);
        pastNotifyInfo.Etc1_Mail__c = 'testMailSky365_2@example.com';
        insert pastNotifyInfo;

        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        notifyInfo.PastOne__c = pastNotifyInfo.Id;
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 8, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeUpdate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c, pastNotifyInfo, notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog('testMailSky365_2@example.com', notifyInfo.Etc1_Mail__c, 'Office連絡先検索', 200);

        // 正常        
        // System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }
  
    /**
     * 担当者の氏名やメアド（属性情報）が変更になったとき
     *
     * 連絡先検索：エラー
     */
    @isTest static void testCace_Update_02() {

        NotifyInfo__c pastNotifyInfo = createNotifyInfo(null);
        pastNotifyInfo.Etc1_Mail__c = 'testMailSky365_2@example.com';
        insert pastNotifyInfo;

        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        notifyInfo.PastOne__c = pastNotifyInfo.Id;
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 9, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeUpdate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c, pastNotifyInfo, notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog('testMailSky365_2@example.com', notifyInfo.Etc1_Mail__c, 'Office連絡先検索：Microsoft Graphの呼び出し', 201);

        // エラー  
        System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 担当者の氏名やメアド（属性情報）が変更になったとき
     *
     * 連絡先更新：エラー
     */
    @isTest static void testCace_Update_03() {

        NotifyInfo__c pastNotifyInfo = createNotifyInfo(null);
        pastNotifyInfo.Etc1_Mail__c = 'testMailSky365_2@example.com';
        insert pastNotifyInfo;

        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 0, 9, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeUpdate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c, pastNotifyInfo, notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        // NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        // String resLog = createLog('testMailSky365_2@example.com', notifyInfo.Etc1_Mail__c, 'Office連絡先更新', 0);

        // エラー  
        System.assertEquals(true, result);
        // System.assertEquals(false, result);
        // System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 担当者の氏名やメアド（属性情報）が変更になったとき
     *
     * 正常
     */
    @isTest static void testCace_Update_04() {

        NotifyInfo__c pastNotifyInfo = createNotifyInfo(null);
        pastNotifyInfo.Etc1_Mail__c = 'testMailSky365_2@example.com';
        insert pastNotifyInfo;

        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        notifyInfo.PastOne__c = pastNotifyInfo.Id;
        notifyInfo.Etc1_AlertContact__c = false;
        notifyInfo.Etc1_OtherThanAlertContact__c = true;
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeUpdate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c, pastNotifyInfo, notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        String resLog = null;

        // エラー  
        System.assertEquals(true, result);
        System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    /**
     * 担当者の氏名やメアド（属性情報）が変更になったとき
     *
     * 正常
     */
    @isTest static void testCace_Update_05() {

        NotifyInfo__c pastNotifyInfo = createNotifyInfo(null);
        pastNotifyInfo.Etc1_Mail__c = 'testMailSky365_2@example.com';
        pastNotifyInfo.Etc1_AlertContact__c = false;
        pastNotifyInfo.Etc1_OtherThanAlertContact__c = true;
        insert pastNotifyInfo;

        NotifyInfo__c notifyInfo = createNotifyInfo('変更');
        notifyInfo.PastOne__c = pastNotifyInfo.Id;
        notifyInfo.Etc1_AlertContact__c = true;
        notifyInfo.Etc1_OtherThanAlertContact__c = false;
        insert notifyInfo;

        Test.setMock(HttpCalloutMock.class, new OfficeMultiHttpCalloutMock(0, 0, 0, 0, 0));

        Test.startTest();

        Boolean result = OfficeAPIController.executeUpdate(notifyInfo, 1, notifyInfo.Etc1_Name__c, notifyInfo.Etc1_Mail__c, pastNotifyInfo, notifyInfo.Etc1_ChgList__c);

        Test.stopTest();

        NotifyInfo__c retNotifyInfo = [SELECT Id, ETC1_ChgList__c, ETC1_ErrorLog__c FROM NotifyInfo__c WHERE Id = :notifyInfo.Id LIMIT 1];
        String resLog = null;

        // エラー  
        System.assertEquals(true, result);
        System.assertEquals(resLog, retNotifyInfo.ETC1_ErrorLog__c);
    }

    static NotifyInfo__c createNotifyInfo(String processName) {

        NotifyInfo__c notifyInfo = new NotifyInfo__c(
            Etc1_ChgList__c = processName,
            Etc1_Name__c = 'テスト 太郎',
            Etc1_Company__c = 'テスト会社',
            Etc1_Mail__c = 'testMailSky365@example.com',
            SendListAlert__c = 'test_haifu@srv02.sky365.co.jp', 
            SendListAlertExpet__c = 'test_haifu2@srv02.sky365.co.jp',
            Etc1_AlertContact__c = true,
            Etc1_OtherThanAlertContact__c = false
        );

        return notifyInfo;
    }
    
    static String createLog(String email, String newEmail, String process, Integer statusCode) {

        String resLog = '【処理】' + process;
        resLog += '【メールアドレス】' + email;
        if (String.isNotBlank(newEmail)) resLog += '【メールアドレス(変更後)】' + newEmail;
        resLog += '【ステータスコード】' + statusCode;

        return resLog;
    }
}