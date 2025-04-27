/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2020 SKY365 Inc. All Rights Reserved.
 *
 * 対応一覧コントローラテスト
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2020/10     Kikuchi    新規作成
 * 2020/12     ssasaki    修正        テスト内容、コードを整理
 ********************************************************************************/
@isTest(SeeAllData=false)
public class OperationListDatatableControllerVFTest {
    /*
     * 正常系テスト
     * OPが作成、別のOPが取得/編集/削除するケース
     *
     * 終了処理済みフラグがFalseのみ取得
     * @param profileName テスト対象のプロファイル名
     * @param email テスト対象のプロファイルのメールアドレス(仮設定)
     */
    @isTest
    static void Success_OP() {
        // テストデータを作成するOP権限ユーザーを作成
        User op1 = setupOpProfile('MSP_OP', 'MS1MEM', 'OP1');
        User op2 = setupOpProfile('MSP_OP', 'MS1MEM', 'OP2');
        User asv = setupOpProfile('MSP_ASV', 'MS1', 'ASV');

        System.Test.startTest();
        SuccessTest(op1, op2, asv);
        System.Test.stopTest();
    } 

    /*
     * 正常系テスト
     * LSV：作成/削除
     * OP：取得/編集/削除(対応一覧のみ)
     * ASV：削除(案件情報のみ)
     *
     * 終了処理済みフラグがFalseのみ取得
     * @param profileName テスト対象のプロファイル名
     * @param email テスト対象のプロファイルのメールアドレス(仮設定)
     */
    @isTest
    static void Success_LSV() {
        User lsv = setupOpProfile('MSP_LSV', 'MSP', 'LSV');
        User op = setupOpProfile('MSP_OP', 'MS1MEM', 'OP');
        User asv = setupOpProfile('MSP_ASV', 'MS1', 'ASV');

        System.Test.startTest();
        SuccessTest(lsv, op, asv);
        System.Test.stopTest();
    }

    /*
	 * 正常系テストのメイン処理
	 * @u テストデータを作成するユーザー
     * @op テストデータを取得/編集/削除するユーザー
     * @asv 案件情報を削除するユーザー
     */
    private static void SuccessTest(User u, User op, User asv) {
        // テスト用案件情報/対応一覧の定義
        Constitution_Common__c con = new Constitution_Common__c();
        OperationList__c opeTrue = new OperationList__c();
        OperationList__c opeFalse = new OperationList__c();
        List<OperationList__c> fetchOperationLists = new List<OperationList__c>();

        try {
            System.runAs(u) {
                System.debug('◆◆◆Test実行◆◆◆');

                // 作成のテスト
                con = constitutionIns();                    // 案件情報作成
                System.debug('SUCCESS: Constitution has been created by ' + u.LastName + '.');

                opeTrue = operationListIns(con, true);      // 対応一覧作成(終了処理済みフラグ = True)
                opeFalse = operationListIns(con, false);    // 対応一覧作成(終了処理済みフラグ = False)
                System.debug('SUCCESS: OperationList has been created by ' + u.LastName + '.');

            }
            System.runAs(op) {
                ApexPages.StandardController sc = new ApexPages.StandardController(con);
                OperationListDatatableControllerVF c = new OperationListDatatableControllerVF(sc);

                // 取得のテスト
                fetchOperationLists = c.getOperationList();
                System.assertEquals(1, fetchOperationLists.size()); // 終了処理済みフラグがFalseのものだけ拾えていればsize=1になる
                System.debug('SUCCESS: OperationLists has been fetched by ' + op.LastName + '.');

                // 編集のテスト
                opeTrue.CompletedFlag__c = false;
                update opeTrue;
                fetchOperationLists = c.getOperationList();
                System.assertEquals(2, fetchOperationLists.size()); // 編集が行えていればsize=2になる
                System.debug('SUCCESS: OperationLists has been updated by ' + op.LastName + '.');

                // 削除のテスト
                delete opeTrue;
                delete opeFalse;
                fetchOperationLists = c.getOperationList();
                System.assertEquals(0, fetchOperationLists.size()); // 削除が行えていればsize=0になる
                System.debug('SUCCESS: OperationLists has been deleted by ' + op.LastName + '.');
            }

        } catch(Exception e) {
            System.debug('ERROR: The following exception has occurred: ' + e.getMessage());
        }

        // 案件情報の削除テスト
        // - OPは(所有者以外)削除できない、ASV以上が削除することになっている
        // - OP以外が案件情報を作成していた場合、所有者をOPに変更する
        try {
            System.runAs(op) {
                
                delete con;
                System.debug('ERROR: Constitution has been deleted by ' + op.LastName + '.');

            } 
        // OPでは削除できずにDmlException発生が正
        } catch(DmlException e) {
            System.debug('SUCCESS: Constitution owned by ' + u.LastName + ' has \"not\" been deleted by ' + op.LastName + '.');

        } catch(Exception e) {
            System.debug('ERROR: The following exception has occurred: ' + e.getMessage());
        }

        try {
            // 案件情報の所有者をOPに変更
            System.runAs(u) {
                con.OwnerId = op.Id;
                update con;
                System.debug('SUCCESS: An owner of Constitution has been changed to ' + op.LastName + '.');

            }
            System.runAs(asv) {
                delete con;
                System.debug('SUCCESS: Constitution owned by ' + op.LastName + ' has been deleted by ' + asv.LastName + '.');

                System.debug('◆◆◆Test終了◆◆◆');

            }
        // 先にOPが削除できてしまった場合は削除対象がないためDmlExceptionが発生
        } catch(DmlException e) {
            System.debug('ERROR: The following exception has occurred: ' + e.getMessage());

        } catch(Exception e) {
            System.debug('ERROR: The following exception has occurred: ' + e.getMessage());
        }
    }

    /*
	 * プロファイル取得
	 * @ return プロファイル
     */    
    private static Profile getProfile(String name) {
        List<Profile> p = [SELECT Id, Name From Profile Where Name =:name];
        return p.get(0);
    }

    /*
	 * ロール取得
	 * @ return ロール
     */    
    private static UserRole getRole(String name) {
        List<UserRole> r = [SELECT Id, Name From UserRole Where DeveloperName =:name];
        return r.get(0);
    }

    /*
	 * テスト用ユーザ作成
     * @param profileName テストするプロファイル名
     * @param roleName テストするロール名
     * @param userName 任意のユーザー名
	 * @ return ユーザ
     */
    private static User setupOpProfile(String profileName, String roleName, String userName) {
        Profile opProfile = getProfile(profileName);
        UserRole opRole = getRole(roleName);
        User u = createUserIns(userName, userName + '@sky468.co.jp', opProfile.id, opRole.id);
        return u;

    }
    /*
	 * ユーザ作成
	 * @ return ユーザ
     */
    private static User createUserIns(String userName, String email, Id profileId, Id roleId) {
        USer u = new User();        
        u.Username = email;
        u.LastName = userName;
        u.Email = email;
        u.Alias = userName;
        u.TimeZoneSidKey = 'Asia/Tokyo';
        u.LocaleSidKey = 'ja_JP';
        u.EmailEncodingKey = 'ISO-2022-JP';
        u.ProfileId = profileId;
        u.LanguageLocaleKey = 'ja';
        u.UserRoleId = roleId;
        insert u;
        return u;
    }

    /*
	 * 案件情報作成
	 * @ return 案件情報
     */    
    private static Constitution_Common__c constitutionIns() {
        Constitution_Common__c projectInformation = new Constitution_Common__c(Name = 'Lightning Data Table Apex Test');
        insert projectInformation;
        return projectInformation;
    }
    
    /*
	 * 対応一覧作成
	 * @param Constitution_Common__c 案件情報
	 * @param Boolean 終了処理済みフラグ
	 * @return OperationList__c 案件一覧
     */    
    private static OperationList__c operationListIns(Constitution_Common__c con, Boolean CompletedFlag) {
        OperationList__c operationlist = new OperationList__c(Name = 'Apex Test Phase', 
                                                              Requester__c = 'https://www.google.co.jp',
                                                              Alert__c = 'Test Alert',
                                                              Host__c = 'Host01',
                                                              GroupWatcher__c = '済',
                                                              StartDate__c = Datetime.newInstance(2000, 1, 1),
                                                              EndDate__c = Datetime.newInstance(2000, 12, 31),
                                                              ProjectInformation__c = con.Id,
                                                              CompletedFlag__c = CompletedFlag
                                                             );
        insert operationlist;
    	return operationlist;
    }
}