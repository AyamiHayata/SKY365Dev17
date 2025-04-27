/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * パートナーサイト 連絡先変更
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/04     新規作成
 ********************************************************************************
 * 2022/07/13 監査履歴（メールでのご連絡先）対応  
 ********************************************************************************/
public without sharing class ChangeAddressController extends CommunityCommonController {


    /* ZendeskUserId */
    public String zid {get;set;}

    /* 案件管理のID */
    public String constitutionid {get;set;}

    /* ログインユーザ名 */
    public String name {get;set;}

    /* ログインユーザ情報 */
    public ZendeskUser__c userInfo {get;set;}

    /* 案件情報 */
    public Constitution_Common__c constitutionInfo {get;set;}
    public String constitutionName {get;set;}
    public String companyName {get;set;}
    
    /* 連絡先情報 */
    public NotifyInfo__c notifyInfo {get; set;}
    public NotifyInfo__c beforeNotifyInfo {get;set;}

    /* 曜日 */
    public Map<String,boolean> daymap{get;set;}

    /* オペレータフラグ */
    public boolean operatorFlg{get;set;}
    
    /* 連絡先編集可能ステータス */
    public static final String EDITABLE_STATUS_SHINSEI = '申請';

    /*　ユーザー権限 */
    public String loginUserAuthority{get;set;}

    /* 営業時間内の連絡先順番 */
    public String on_display_order1{get;set;}
    public String on_display_order2{get;set;}
    public String on_display_order3{get;set;}

    /* 営業時間外の連絡先順番 */
    public String off_display_order1{get;set;}
    public String off_display_order2{get;set;}
    public String off_display_order3{get;set;}

    /* 参照フラグ */
    public boolean viewFlg{get;set;}

    /* 画面表示判断用のその他連絡先の名前保存配列 */
    public List<String> originalOtherNameList{get;set;}

    /* 画面表示判断用のその他連絡先の名前保存配列 */
    public List<String> originalEmailList{get;set;}

    public ChangeAddressController() {
        super();
        System.debug('**==**== ChangeAddressController Constructor ==**==**');
        zid = ApexPages.CurrentPage().getParameters().get('zid');
        // consentApprovedstatus = ApexPages.CurrentPage().getParameters().get('approved');
        constitutionid = ApexPages.CurrentPage().getParameters().get('constitutionid');
        // loginUserAuthority = ApexPages.CurrentPage().getParameters().get('userauthority');
        code = ApexPages.CurrentPage().getParameters().get('code');
        operatorFlg = false;
        daymap = new Map<String,boolean>{
            '月' => false, 
            '火' => false, 
            '水' => false, 
            '木' => false, 
            '金' => false, 
            '土' => false, 
            '日' => false,
            '祝' => false
        };
        originalOtherNameList = new List<String>(20);
        originalEmailList = new List<String>(20);
        for(Integer loopnum=0; loopnum < 20; loopnum++){
            originalOtherNameList[loopnum] = '';
            originalEmailList[loopnum] = '';
        }

    }

    public override PageReference initAction() {
        try {
            super.initAction();
            System.debug('**==**== ChangeAddressController initAction START ==**==**');

            // Zendeskユーザーを取得する
            // List<ZendeskUser__c> zuserInfoList = [SELECT Id, Name__c, SessionId__c, ZendeskOrgId2__c, ConsentVersion__c, Code__c, Email__c FROM ZendeskUser__c WHERE id =:zid];
            List<ZendeskUser__c> zuserInfoList = [SELECT Id, Name__c, SessionId__c, ZendeskOrgId2__c, ConsentVersion__c, Code__c, Email__c FROM ZendeskUser__c WHERE Code__c =:code];
            userInfo = zuserInfoList.get(0);
            name = userInfo.Name__c;
            code = userInfo.Code__c;
    
            /* 案件情報 */
            List<Constitution_Common__c> cclist = [
                                                    SELECT
                                                        ID
                                                        ,Name
                                                        ,ChargeOption__c
                                                        ,Account__r.name
                                                    FROM Constitution_Common__c
                                                    WHERE ID = :constitutionid
            ];
            constitutionInfo = cclist.get(0);
            constitutionName = constitutionInfo.Name;
            companyName = cclist.get(0).Account__r.name;

            /* 連絡先情報 */
            List<Schema.FieldSetMember> fields = SObjectType.NotifyInfo__c.FieldSets.ChangeInputSet.getFields();
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : fields) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Name FROM NotifyInfo__c WHERE ConstitutionCommon__c=:constitutionid AND PastOneFLG__c = false ORDER BY NAME ASC';
            // query += ' AND PastOne__c=null';
            List<NotifyInfo__c> nlist = Database.query(query);
            notifyInfo = nlist.get(0);

            for(Integer loopnum=0; loopnum < 20; loopnum++){
                Integer plusOneNum = loopnum + 1;
                String orgname = (String)notifyInfo.get('Etc' + plusOneNum + '_Name__c');
                String orgemail = (String)notifyInfo.get('Etc' + plusOneNum + '_Mail__c');
                if(String.isNotBlank(orgname)) originalOtherNameList[loopnum] = orgname;
                if(String.isNotBlank(orgemail)) originalEmailList[loopnum] = orgemail;
            }

            // this.beforeNotifyInfo = notifyinfo.clone(false,true,false,false);  //2023.07.13 comment out
            this.beforeNotifyInfo = notifyinfo.clone(false,true,true,false);     //2023.07.13 add
            this.beforeNotifyInfo.HenshuUser__c = this.beforeNotifyInfo.LastModifiedById; //2023.07.13 add
            this.beforeNotifyInfo.HenshuDateTime__c = this.beforeNotifyInfo.LastModifiedDate; //2023.07.13 add
            
// System.debug('**==**== originalOtherNameList[2] ==>' + originalOtherNameList[2]);
            //曜日のチェックボックスの値を保存する変数に値をセットする
            if(String.isNotBlank(this.notifyinfo.Week__c)){
                if(this.notifyinfo.Week__c.contains('月')) daymap.put('月',true);
                if(this.notifyinfo.Week__c.contains('火')) daymap.put('火',true);
                if(this.notifyinfo.Week__c.contains('水')) daymap.put('水',true);
                if(this.notifyinfo.Week__c.contains('木')) daymap.put('木',true);
                if(this.notifyinfo.Week__c.contains('金')) daymap.put('金',true);
                if(this.notifyinfo.Week__c.contains('土')) daymap.put('土',true);
                if(this.notifyinfo.Week__c.contains('日')) daymap.put('日',true);
                if(this.notifyinfo.Week__c.contains('祝')) daymap.put('祝',true);
            }


        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'システムエラーが発生しました ' + e.getLineNumber() +' '+e.getMessage()));
        }
        return null;
    }

    public Pagereference view(){
        try {
            super.initAction();
            System.debug('**==**== ChangeAddressController initAction START ==**==**');

            // Zendeskユーザーを取得する
            List<ZendeskUser__c> zuserInfoList = [SELECT Id, Name__c, SessionId__c, ZendeskOrgId2__c, ConsentVersion__c, Code__c, Email__c FROM ZendeskUser__c WHERE id =:zid];
            userInfo = zuserInfoList.get(0);
            name = userInfo.Name__c;
            code = userInfo.Code__c;
    
            /* 案件情報 */
            List<Constitution_Common__c> cclist = [
                                                    SELECT
                                                        ID
                                                        ,Name
                                                        ,ChargeOption__c
                                                        ,Account__r.name
                                                    FROM Constitution_Common__c
                                                    WHERE ID = :constitutionid
            ];
            constitutionInfo = cclist.get(0);
            constitutionName = constitutionInfo.Name;
            companyName = cclist.get(0).Account__r.name;

            /* 連絡先情報 */
            List<Schema.FieldSetMember> fields = SObjectType.NotifyInfo__c.FieldSets.ChangeInputSet.getFields();
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : fields) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Name FROM NotifyInfo__c WHERE ConstitutionCommon__c=:constitutionid';
            query += ' AND PastOneFLG__c=false';
            List<NotifyInfo__c> nlist = Database.query(query);
            notifyInfo = nlist.get(0);
            
            //曜日のチェックボックスの値を保存する変数に値をセットする
            if(String.isNotBlank(this.notifyinfo.Week__c)){
                if(this.notifyinfo.Week__c.contains('月')) daymap.put('月',true);
                if(this.notifyinfo.Week__c.contains('火')) daymap.put('火',true);
                if(this.notifyinfo.Week__c.contains('水')) daymap.put('水',true);
                if(this.notifyinfo.Week__c.contains('木')) daymap.put('木',true);
                if(this.notifyinfo.Week__c.contains('金')) daymap.put('金',true);
                if(this.notifyinfo.Week__c.contains('土')) daymap.put('土',true);
                if(this.notifyinfo.Week__c.contains('日')) daymap.put('日',true);
                if(this.notifyinfo.Week__c.contains('祝')) daymap.put('祝',true);
            }
            //ログインユーザーの権限をここで判定する
            loginUserAuthority = CoodleUtil.checkAuthority(constitutionInfo.ChargeOption__c,notifyInfo,userInfo.Email__c);
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+ 'システムエラーが発生しました ' + e.getLineNumber() +' '+e.getMessage()));
        }
        return null;
    }
    public Pagereference save(){
        try{
            String eigyoYoubi='';

            if(daymap.get('日')) eigyoYoubi = '日';
            if(daymap.get('月')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '月';
                else eigyoYoubi = eigyoYoubi + ';' + '月';
            }
            if(daymap.get('火')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '火';
                else eigyoYoubi = eigyoYoubi + ';' + '火';
            }
            if(daymap.get('水')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '水';
                else eigyoYoubi = eigyoYoubi + ';' + '水';
            }
            if(daymap.get('木')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '木';
                else eigyoYoubi = eigyoYoubi + ';' + '木';
            }
            if(daymap.get('金')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '金';
                else eigyoYoubi = eigyoYoubi + ';' + '金';
            }
            if(daymap.get('土')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '土';
                else eigyoYoubi = eigyoYoubi + ';' + '土';
            }
            if(daymap.get('祝')){
                if(String.isBlank(eigyoYoubi)) eigyoYoubi = '祝';
                else eigyoYoubi = eigyoYoubi + ';' + '祝';
            }
            notifyinfo.Week__c = eigyoYoubi;

            //インサート前チェック
            List<Constitution_Common__c> cclist = [
                    SELECT
                        ID
                        ,Name
                        ,ChargeOption__c
                        ,Account__r.name
                    FROM Constitution_Common__c
                    WHERE ID = :notifyinfo.ConstitutionCommon__c
                ];

            if(cclist.size()>0){
                constitutionInfo = cclist.get(0);
            }

            boolean checkflg = CoodleUtil.checkInputContents(false,constitutionInfo.ChargeOption__c,notifyinfo,userInfo.Email__c);
            if(!checkflg){
                //時間内・時間外の連絡先の順番変更する
                jikangaiReinput();
                
                //時間内・時間外の削除処理を行う
                deleteTelRenrakusaki();

                //時間内・時間外の空行を詰める
                notifyinfo = CoodleUtil.moveUpTelRenrakusaki(notifyinfo);

                //追加・変更・削除の状況を確認する
                boolean diffFlg = CoodleUtil.chkDiffMailRenrakusaki(notifyinfo,beforeNotifyInfo);
                //削除と変更のチェックを行う
                boolean delchgChlFlg = CoodleUtil.checkDeleteChg(constitutionInfo.ChargeOption__c,notifyinfo);
                if(delchgChlFlg) return null;

                //履歴を残し、APIを呼び出す必要があるのかを判別する// if(CoodleUtil.chkDiffMailRenrakusaki(notifyinfo,beforeNotifyInfo)){
                if(diffFlg){
                    //古い連絡先情報があったら削除する(ステータスが申請の場合は存在する)
                    Id deleteId;
                    // if(this.notifyinfo.PastOne__c!=null){  //2023.07.13 監査履歴を残すためにcomment out
                    //     List<NotifyInfo__c> pastonedeleteList = [SELECT ID FROM NotifyInfo__c WHERE Id = :this.notifyinfo.PastOne__c];
                    //     if(pastonedeleteList.size() > 0){
                    //         delete pastonedeleteList;
                    //     }
                    // }
                    //古い連絡先情報をまずはInsertする
                    beforeNotifyInfo.PastOneFLG__c = true;
                    beforeNotifyInfo.PastOne__c = null;
                    System.debug('**==**== insert前 beforeNotifyInfo =>' + beforeNotifyInfo);
                    insert beforeNotifyInfo;

                    //現在の連絡先情報を更新する
                    notifyinfo.PastOne__c = beforeNotifyInfo.id;
                    notifyinfo.Status__c = '受付';
                    this.notifyinfo.ShagaiHenshusha__c = name;  //2023.07.13 add
                    upsert notifyinfo;

                    //APIを呼ぶ
                    if(!Test.isRunningTest()){
                        OfficeAndZendeskAPIQueueable queueable = new OfficeAndZendeskAPIQueueable(notifyInfo.Id, 1);
                        System.enqueueJob(queueable);
                    }
                }else{
                    this.notifyinfo.ShagaiHenshusha__c = name;  //2023.07.13 add
                    upsert notifyinfo;
                }
                
            }else{
                System.debug('**==**== check Error ==**==**');
                return null;
            }
        }catch(Exception e){
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() + ' ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'システムエラーが発生しました ' + e.getLineNumber() +' '+e.getMessage()));
            return null;
        }
        // String routing = '/apex/ChangeAddress?zid='+zid + '&constitutionid='+constitutionid + '&code=' + code;
        // String routing = '/apex/ViewAddress?zid='+ zid + '&constitutionid='+constitutionid+ '&code=' + code;
        String routing = '/oms?code='+ code;
        PageReference newView = new PageReference(routing);

        return newView;
    }
//     public Pagereference cancelApplication() {

//         //保存されている旧データのIDを取得する
//         List<NotifyInfo__c> currentNotifyList = [SELECT PastOne__c FROM NotifyInfo__c WHERE Id =:notifyInfo.Id];

//         Id pastoneId = currentNotifyList.get(0).Id;
//         if(pastoneId!=null){
//             //旧データをすべて取得して復元する
//             List<String> selectFields = new List<String>(	
//                 NotifyInfo__c.SObjectType.getDescribe().fields.getMap().keySet()
//             );	
//             List<NotifyInfo__c> pastOneNotifyList = Database.query(
//                 String.format(
//                     'SELECT {0} FROM NotifyInfo__c WHERE Id = :pastoneId'
//                     , new List<String>{ String.join(selectFields,', ')}
//                 )
//             );
// // System.debug('**==**== pastOneNotifyList => ');
//             if(pastOneNotifyList.size() > 0){
//                 NotifyInfo__c restoreNotify = pastOneNotifyList.get(0).clone(false,false,true,false);
//                 // restoreNotify.name = notifyInfo.name;
//                 restoreNotify.Id = notifyInfo.Id;
//                 restoreNotify.Status__c = '';

//                 update restoreNotify;
//             }

//         }
        
//         String routing = '/apex/ChangeAddress?zid=' + userInfo.Id + '&constitutionid='+constitutionid+ '&code=' + code;
//         PageReference newView = new PageReference(routing);

//         return newView;
//     }
    
    private void jikangaiReinput(){
        on_display_order1 = ApexPages.CurrentPage().getParameters().get('on_display_order1');
        on_display_order2 = ApexPages.CurrentPage().getParameters().get('on_display_order2');
        on_display_order3 = ApexPages.CurrentPage().getParameters().get('on_display_order3');

        off_display_order1 = ApexPages.CurrentPage().getParameters().get('off_display_order1');
        off_display_order2 = ApexPages.CurrentPage().getParameters().get('off_display_order2');
        off_display_order3 = ApexPages.CurrentPage().getParameters().get('off_display_order3');

        notifyinfo = CoodleUtil.jikangaiReinput(on_display_order1,on_display_order2,on_display_order3,off_display_order1,off_display_order2,off_display_order3,notifyinfo);

    }


    private void deleteTelRenrakusaki(){

        notifyInfo =  CoodleUtil.deleteTelRenrakusaki(notifyInfo);

    }

}