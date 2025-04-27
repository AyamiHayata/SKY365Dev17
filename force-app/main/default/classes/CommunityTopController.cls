/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * パートナーサイトトップページコントローラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/12     kikuchi     新規作成
 ********************************************************************************/
public without sharing class CommunityTopController extends CommunityCommonController{


    /* 利用規約 */
    private static final String RIYOUKIYAKU_STR = '利用規約'; 


    /**
     * コンストラクタ
     *
     */
    public CommunityTopController() {
        // userInfo = new ZendeskUser__c();
        super();
        code = ApexPages.CurrentPage().getParameters().get('code');
        debugString = '';
        approvedcollapse = 'cmnTbl accordion-collapse';
        approvedchk = false;
    }

    /**
     * 組織取得
     *
     */
    public override PageReference initLoginAction() {   
        try {
            System.debug('**==**== initLoginAction start ==**==**');
            // kikuchi URL改ざんチェック
            // super.initLoginAction();
            PageReference p = super.initLoginAction();
            if(p != null) {
                return p;
            }
            // kikuchi URL改ざんチェック
            
            // 最新の規約を承認済みかを確認する
            //2023.10.03 codeでZenUserを取得するように変更
            // List<ZendeskUser__c> zuserInfoList = [SELECT Id, ConsentVersion__c FROM ZendeskUser__c WHERE SessionId__c =:sessionid];
            System.debug('**==**== code => ' + code);
            List<ZendeskUser__c> zuserInfoList = [SELECT Id, ConsentVersion__c FROM ZendeskUser__c WHERE code__c =:code];
            Decimal approvedVersion = userInfo.ConsentVersion__c;
            if(approvedVersion==null){
                approvedVersion = zuserInfoList.get(0).ConsentVersion__c;
            }
            // サイト利用規約取得
            List<SiteTerms__c> kiyakulist = [SELECT Id,Version__c,Sentence__c FROM SiteTerms__c WHERE SentenceType__c=:RIYOUKIYAKU_STR ORDER BY Version__c DESC LIMIT 1];
            System.debug('**==**== kiyaku version => ' + kiyakulist.get(0).Version__c);
            System.debug('**==**== approvedVersion => ' + approvedVersion);
            if(kiyakulist.get(0).Version__c==approvedVersion){
                approvedcollapse = approvedcollapse + ' collapse';
                approvedchk = true;
            }

        } catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }

    public PageReference approvedAgreement() {
        System.debug('**==**== approvedAgreement start ==**==**');
        PageReference newView;
        try {
            // 規約を承認したことをzendeskユーザーに記録する
            //2023.10.03 codeでZenUserを取得するように変更
            // List<ZendeskUser__c> zuserInfoList = [SELECT Id, SessionId__c FROM ZendeskUser__c WHERE SessionId__c =:sessionid];
            List<ZendeskUser__c> zuserInfoList = [SELECT Id, SessionId__c FROM ZendeskUser__c WHERE code__c =:code];
            zuserInfoList.get(0).ConsentVersion__c = kiyakuversion;
            zuserInfoList.get(0).ConsentDateTime__c = Datetime.now();
            system.debug('**==**== zuserInfoList.get(0) => ' + zuserInfoList.get(0));
            update zuserInfoList.get(0);
            
            // String routing = '/apex/ConstitutionSelect?zid='+ zuserInfoList.get(0).Id +'&approved=true';
            String routing = '/oms?code='+ code;
            newView = new PageReference(routing);
        } catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return newView;
    }

    public void communitysiteLogout(){
        System.debug('**==**== communitysiteLogout start ==**==**');
        try {
            //ZendeskUserの情報を取得
            List<ZendeskUser__c> zuserInfoList = [SELECT Id,ZendeskUserId__c FROM ZendeskUser__c WHERE code__c =:code];
            //Zendeskログアウト
            ZendeskAPIController.executeLogout(zuserInfoList.get(0).ZendeskUserId__c);

        } catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

}