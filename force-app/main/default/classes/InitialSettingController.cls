/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * 日報初期設定画面コントローラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/06     kikuchi     新規作成
 ********************************************************************************/
public with sharing class InitialSettingController {
    
    public Boolean isYRegistred {get; set;}
    public Boolean isTRegistred {get; set;}

    /**
     * コンストラクタ
     *
     */
    public InitialSettingController() {
        isYRegistred = false;
        isTRegistred = false;
    }

    /**
     * 初期処理
     *
     */
    public void initAction() {
        // ユーザ取得
        User u = [SELECT id, YammerToken__c, togglAPI_Workspace__c, togglAPI_Token__c FROM USER WHERE id =:UserInfo.getUserId()];
        isYRegistred = String.isEmpty(u.YammerToken__c) ? false : true; 
        isTRegistred = String.isEmpty(u.togglAPI_Workspace__c) || String.isEmpty(u.togglAPI_Token__c) ? false : true; 
    }

    /**
     * Toggl認証ページ
     *
     */
    public Pagereference togglLink() {
        String togglSettingURL = '/apex/salesforcetotoggl';
        PageReference pageRef = new PageReference(togglSettingURL);
        return pageRef;

    }

    /**
     * Yammer認証ページ
     *
     */
    public Pagereference yammerLink() {
        String oAuthYammerURL = 'https://www.yammer.com/dialog/oauth?client_id=HnJKXRc1V2GDOTrzmyLHpg&redirect_uri=https://sky365.lightning.force.com/apex/salesforcetoyammer';
        PageReference pageRef = new PageReference(oAuthYammerURL);
        return pageRef;
    }

    /**
     * 戻る（日報）
     *
     */
    public Pagereference back() {
        PageReference pageRef = new PageReference('/lightning/o/DailyReport__c/list');
        return pageRef;
    }

}