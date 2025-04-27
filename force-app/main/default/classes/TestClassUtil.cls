/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * TestClassUtil
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/07     kikuchi     新規作成
 ********************************************************************************/
@isTest
public class TestClassUtil {
	public static final String TESTDOMAIN = '@sky365.jp.invalid';
    public static final String TEST_PROLILE = 'システム管理者_カスタム';

    /**
     * ユーザ作成
     * @ String togglAPI_Token__c
     * @ String togglAPI_Workspace__c
     * @ String YammerToken__c
     * @ return User
     */
    Public Static User createUser(String tt, String tw, String yt) {


        // プロファイル
        Profile prof = [select id from profile where name =:TEST_PROLILE];
		User u = new User(
			alias = 'EMP',
			email = 'standarduser' + TESTDOMAIN,
			emailencodingkey = 'UTF-8',
			lastname = 'Test',
			languagelocalekey= 'ja',
			localesidkey = 'ja_JP',
			profileid = prof.Id,
			timezonesidkey = 'Asia/Tokyo',
			isActive = true,
            togglAPI_Token__c = tt,
            togglAPI_Workspace__c = tw,
            YammerToken__c = yt,
			username = 'standarduser' + TESTDOMAIN
		);
        insert u;
        return u;
    }

    /**
     * 日報作成
     * @param User ユーザ
     * @return 日報
     */
    public Static DailyReport__c createDailyReport(User u) {
        DailyReport__c dr = new DailyReport__c();
        dr.Name = 'TestUser'; // 日報名
        dr.User__c = u.id; // ユーザ
        dr.Shift__c = '常';
        dr.RegistDate__c = Date.today();
        insert dr;
        return dr;
    }

    /**
     * 日報明細作成
     * @param DailyReport__c　日報
     * @return 日報明細
     */
    public Static DailyReportDetail__c createDetailReport(DailyReport__c dr, string clientName) {
        DailyReportDetail__c rd = new DailyReportDetail__c();
        rd.Title__c       = 'TestWork' + clientName; // タイトル
        rd.WorkTime__c    = 8.0;             // 稼働時間
        rd.Client2__c     = (String.isEmpty(clientName) ? '全般-商流なし': clientName);      // クライアント
        rd.Project2__c    = 'TestProject';   // プロジェクト
        rd.DailyReport__c = dr.id;           // 日報
        insert rd;
        return rd;
    }
    
    /**
     * 日報明細作成
     * @param DailyReport__c　日報
     * @return 日報明細
     */
    public Static DailyReportDetail__c createDetailReport(DailyReport__c dr) {
        return createDetailReport(dr, '');
    }

    /**
     * 案件情報作成
     * @return 案件情報
     */
    public Static Constitution_Common__c createConstitutionCommon(String OrganizationId) {
        Constitution_Common__c con = new Constitution_Common__c();
        con.Name = 'Test案件名:' + OrganizationId;      // 案件名
        con.ZendeskOrganizationId__c = OrganizationId;  // Zendesk組織ID
        insert con;
        return con;
    }        
}