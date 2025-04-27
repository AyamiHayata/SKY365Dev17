/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * MVP投票コントローラテストクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/01     Kikuchi     新規作成
 ********************************************************************************/
@isTest
public with sharing class MVPVoteControllerTest {
    /**
     * 正常系
     * 
     */
    @isTest
    static void testCace01() {
        system.debug('■■■テスト準備■■■');
        User op = createUser('MSP_OP');
        User asv = createUser('MSP_ASV');
        User sv = createUser('MSP_SV');

        system.debug('■■■テスト実行■■■');
        Test.startTest();
        MVPVoteController target = new MVPVoteController();
        target.init();
        
        // OP1
        Vote__c op1 = new Vote__c();
        op1.VoteUser__c = op.id;
        op1.Cause__c = 'op';
        target.votes[0] = op1; // 投票１

        // OP2
        Vote__c op2 = new Vote__c();
        op2.VoteUser__c = op.id;
        op2.Cause__c = 'op';
        target.votes[1] = op2; // 投票２

        // ASV
        Vote__c asvv = new Vote__c();
        asvv.VoteUser__c = asv.id;
        asvv.Cause__c = 'asv';
        target.votes[2] =asvv; // 投票３

        target.save();
        
        Test.stopTest();
        system.debug('■■■テスト検証■■■');
        List<Vote__c> actual = [SELECT id FROM Vote__c];
        System.assertEquals(actual.size(), 3);  
    }

    /**
     * ユーザ
     *
     * @param profileName プロファイル名
     * @return ユーザ
     */
    private static User createUser(String profileName) {
        List<Profile> targetProfileList = [SELECT Id FROM Profile WHERE Name = :profileName ORDER BY CreatedDate LIMIT 1];
        User u = new User();
        u.LastName = 'テスト';
        u.FirstName = 'ユーザ_' + profileName;
        u.Username = profileName + '@test.co.test';
        u.Email = profileName + '@test.co.test';
        u.Alias = profileName;
        u.CommunityNickname = 'test担当者_' + profileName;
        u.TimeZoneSidKey = 'Asia/Tokyo';
        u.LocaleSidKey = 'ja_JP';
        u.EmailEncodingKey = 'ISO-2022-JP';
        u.ProfileId = targetProfileList[0].Id;
        u.LanguageLocaleKey = 'ja';
        insert u;
        return u;
    }    
}