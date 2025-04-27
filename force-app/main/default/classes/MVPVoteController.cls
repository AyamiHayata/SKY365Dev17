/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * MVP投票コントローラクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/01     Kikuchi     新規作成
 ********************************************************************************/
public with sharing class MVPVoteController {
    // 設定情報
    public Map<String, Decimal> masterMap = new Map<String, Decimal>();
   
    // 現在の期
    public String fy;

    // 現在の半期
    public String half;

    // 投票期間中
    public Boolean isVodePeriod;

    // 投票時期
    public String halfPeriodStr {get; set;}
    // 被投票者
    public List<Vote__c> votes {get; set;}
     
    /**
     * プロファイル拡張情報クラス
     *
     */
    public Class VoteExtProfileInfo {
        public Decimal point;
        public Boolean isNoneVoteProfile;
    }

    /**
     * コンストラクタ
     *
     */
    public MVPVoteController() {
        votes = new List<Vote__c>();
        // 設定情報を取得
        List<VoteMaster__mdt> masters = [SELECT DeveloperName, Value__c FROM VoteMaster__mdt];
        for (VoteMaster__mdt m : masters) {
            masterMap.put(m.DeveloperName, m.Value__c);
        }
        // 現在の期、半期を取得
        fyChk();
    }

    /**
     * 初期処理
     *
     */
    public Pagereference init () {
        halfPeriodStr = 'FY' + fy + '-' + half;
        if (isVodePeriod) {
            // 投票取得
            votes = [SELECT Name, VoteUser__c, Cause__c, HalfPeriod__c, OwnerId FROM Vote__c WHERE CreatedById =: UserInfo.getUserId() AND HalfPeriod__c = : halfPeriodStr];
            
            if (votes.size() < 3) {
                for (Integer i = votes.size(); i < 3; i++) {
                    votes.add(new Vote__c());
                }
            }
            // 投票期間中のページを表示
            return null;
        } else {
            // 投票期間外のページを表示
            return new PageReference( '/apex/MVPVoteOutside');
        }

    }

    /**
     * 期チェック
     *
     */
    private void fyChk() {
        Integer y;
        Integer m;
        If(Test.isRunningTest()){
            Date tempDate = Date.newInstance(2023, 3, 09);
            y = tempDate.year();
            m = tempDate.month();
        } else {
            y = system.Date.today().year();
            m = system.Date.today().month();
        }
        if (m > 3) {
            y = y + 1;
        }
        fy = String.valueOf(y);

        half = '2H';
        if (m > (Integer)masterMap.get('SecondHalf') && m <= (Integer)masterMap.get('FirstHalf')) {
            half = '1H';
        }

        isVodePeriod = m == (Integer)masterMap.get('FirstHalf')  ? true :
                       m == (Integer)masterMap.get('SecondHalf') ? true : false;     

    }

    /**
     * 保存処理（投票）
     *
     */
    public void save() {

        Decimal myPoint = getExtProfile(UserInfo.getUserId()).point;
        for (Vote__c v : votes) {
            /* 登録前チェック */

            // 自分自身への投票は不可
            if(v.VoteUser__c == UserInfo.getUserId()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '自身への投稿はできません。')); 
                return;               
            }
            // SV以上への投票は不可
            if(v.VoteUser__c != null && getExtProfile(v.VoteUser__c).isNoneVoteProfile) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '部長以上への投票はできません。'));
                return;              
            }
            v.Point__c = myPoint;
            if (String.isEmpty(v.HalfPeriod__c)) {
                v.HalfPeriod__c = halfPeriodStr;
            }
        }
        upsert votes;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ありがとうございます。投票しました。'));                

    }

    /**
     * プロファイル情報取得
     *
     */
    private VoteExtProfileInfo getExtProfile(Id id) {
        User u = [SELECT id, Profile.name FROM User Where id =: id];
        VoteExtProfileInfo result = new VoteExtProfileInfo();
        if(u.Profile.name == 'MSP_OP' || u.Profile.name == 'Application_TT_Member' || u.Profile.name == '管理部_一般') {
            result.point = masterMap.get('OPPoint');
            result.isNoneVoteProfile = false;
        } else if(u.Profile.name == 'MSP_ASV' || u.Profile.name == 'Application_TT_Leader') {
            result.point = masterMap.get('ASVPoint'); 
            result.isNoneVoteProfile = false;
        } else if(u.Profile.name == 'MSP_SV') {
            result.point = masterMap.get('SVPoint');
            result.isNoneVoteProfile = false; 
        } else if(u.Profile.name == 'Application_Group' || u.Profile.name == 'MSP_LSV') {
            result.point = masterMap.get('ManagerPoint'); 
            result.isNoneVoteProfile = true;
        } else if(u.Profile.name == '役員') {
            result.point = masterMap.get('CEOPoint'); 
            result.isNoneVoteProfile = true;
        } else {
            result.point = 1;
            result.isNoneVoteProfile = false;
        }
        return result;
    }
}