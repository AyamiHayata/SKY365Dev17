/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * 日報初期設定画面コントローラーテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/07     kikuchi     新規作成
 ********************************************************************************/
@isTest
 public class InitialSettingControllerTest {

   /**
     * 条件：
     * 正常系
     */
    @isTest
    static void perfectMatchTest_001() {
        System.debug('■■■■データ作成■■■■');

        User user = TestClassUtil.createUser('1','2','3');
                
        System.runAs(user) {
            Test.startTest();
              // テスト対象クラス
              InitialSettingController actual = new InitialSettingController();
              System.debug('■■■■テスト開始■■■■');           
              // 初期処理
              actual.initAction();
              // Toggl連携ページへ
              Pagereference tpage = actual.togglLink();
              // Yammer連携ページへ
              Pagereference ypage = actual.yammerLink();
              // 日報ページへ
              Pagereference dpage = actual.back();
            Test.stopTest();
            System.debug('■■■■テスト検証■■■■');
            // Yammer連携済
            System.assertEquals(true, actual.isYRegistred);
            // Toggl連携済
            System.assertEquals(true, actual.isTRegistred);
            // Toggl連携ページへ
            System.assert(tpage != null);
            // Yammer連携ページへ
            System.assert(ypage != null);
            // 日報ページへ
            System.assert(dpage != null);
		}
    }
}