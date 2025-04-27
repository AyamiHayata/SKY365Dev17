/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2020 SKY365 Inc. All Rights Reserved.
 *
 * 対応一覧コントローラテスト
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/08     Kikuchi    新規作成
 ********************************************************************************/
@isTest(SeeAllData=false)
public class ConstitutionListDatatableControllerTest {

    /**
     * 正常系
     * 
     */
    @isTest
    static void testCace01() {
        system.debug('■■■テスト準備■■■');
        // 取引先
        Account acc = createAccount();
        // 案件情報
        createConstitutionCommon();
        createConstitutionCommon(acc.id);
        ApexPages.StandardController sCon = new ApexPages.StandardController(acc);
        system.debug('■■■テスト実行■■■');
        System.Test.startTest();
        ConstitutionListDatatableControllerVF target = new ConstitutionListDatatableControllerVF(sCon);
        List<Constitution_Common__c> actual = target.getConstitutionList();
        System.Test.stopTest();
        system.debug('■■■テスト検証■■■');
        System.assertEquals(actual.size(), 2);
    }

    /**
     * 取引先作成
     * @return 取引先
     */    
    private Static Account createAccount() {
        Account acc = new Account();
        acc.name = 'testAccount';
        acc.Commercial_flow__c = 'SWX';
        insert acc;
        return acc;
    }

    
    /**
     * 案件情報作成（SWX商流）
     * @return 案件情報
     */
    private Static Constitution_Common__c createConstitutionCommon() {
        Constitution_Common__c con = new Constitution_Common__c();
        con.Name = 'Test案件 SWX'; // 案件名
        con.Commercial_flow__c = 'SWX';
        insert con;
        return con;
    }          

    /**
     * 案件情報作成（商流 直流）
     * @return 案件情報
     */
    private Static Constitution_Common__c createConstitutionCommon(Id accid) {
        Constitution_Common__c con = new Constitution_Common__c();
        con.Name = 'Test案件 直流'; // 案件名
        con.Commercial_flow__c = 'SKY365';
        con.account__c = accid;
        insert con;
        return con;
    }          
    
    
    
}