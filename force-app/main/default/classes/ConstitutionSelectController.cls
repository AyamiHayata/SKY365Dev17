/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * パートナーサイト 案件選択
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/04     新規作成
 ********************************************************************************/
public without sharing class ConstitutionSelectController extends CommunityCommonController{

    /* ログインユーザ名 */
    public String name {get;set;}
    
    /* 案件情報 */
    public Constitution_Common__c constitutionInfo {get;set;}

    /* 連絡先情報 */
    public NotifyInfo__c notifyInfo {get; set;}

    /* 案件 */
    public String selectConstitution {get;set;}
    public List<Constitutions> contitutionList {get;set;}
    public Integer constitutionCount {get;set;}

    /* 連絡先 */
    public Integer notifyInfoCount {get;set;}

    /* 連絡先編集可能ステータス */
    public static final String EDITABLE_STATUS_SHINSEI = '申請';

    /*　ユーザー権限 */
    public String loginUserAuthority{get;set;}
    public static final String AUTH_NOT_VIEW = '参照不可';
    public static final String AUTH_VIEW_ONLY = '参照のみ';
    public static final String AUTH_EDIT_ABLE = '編集可';

    /* 遷移先 */
    public String forwardPage {get;set;}

    //エラーメッセージ
    //規約未承諾 2023.10.27 add
    public boolean approvedchk{get;set;}

    /* 利用規約 */ //2023.10.27 add
    private static final String RIYOUKIYAKU_STR = '利用規約'; 

    public ConstitutionSelectController() {
        try{
            super();
            System.debug('**==**== ConstitutionSelectController START ==**==**');
            code = ApexPages.CurrentPage().getParameters().get('code');
            forwardPage = ApexPages.CurrentPage().getParameters().get('forwardPage');
    
            // Zendeskユーザーを取得する
            // List<ZendeskUser__c> zuserInfoList = [SELECT Id, Name__c,Code__c,ZendeskOrgId2__c FROM ZendeskUser__c WHERE Code__c =:code];
            //2023.10.27 承認済みバージョン追加
            List<ZendeskUser__c> zuserInfoList = [SELECT Id, Name__c,Code__c,ZendeskOrgId2__c,ConsentVersion__c FROM ZendeskUser__c WHERE Code__c =:code];
            
            //2023.10.29 サイト利用規約取得
            List<SiteTerms__c> kiyakulist = [SELECT Id,Version__c FROM SiteTerms__c WHERE SentenceType__c=:RIYOUKIYAKU_STR ORDER BY Version__c DESC LIMIT 1];
            approvedchk = true;
            if(kiyakulist.get(0).Version__c!=zuserInfoList.get(0).ConsentVersion__c){
                approvedchk = false;
            }

            //2023.09.25 add start
            List<Constitution_Common__c> cclist = new List<Constitution_Common__c>();
            name = zuserInfoList.get(0).Name__c;  //2023.09.25 add
            code = zuserInfoList.get(0).Code__c;  //2023.09.25 add
            // if(!String.isBlank(zuserInfoList.get(0).ZendeskOrgId2__c)){
            if(approvedchk && !String.isBlank(zuserInfoList.get(0).ZendeskOrgId2__c)){ //2023.10.27 条件追加
            //2023.09.25 add end
                List<String> orgidList = zuserInfoList.get(0).ZendeskOrgId2__c.split(',');
                // name = zuserInfoList.get(0).Name__c;  //2023.09.25 comment out
                // code = zuserInfoList.get(0).Code__c;  //2023.09.25 comment out
                System.debug('**==**== orgidList =>' + orgidList);
                // List<Constitution_Common__c> cclist = [
                cclist = [
                    SELECT
                        Id
                        ,Name
                    FROM Constitution_Common__c
                    WHERE ZendeskOrganizationId__c in :orgidList or ZendeskOrganizationId2__c in :orgidList
                ];
            }//2023.09.25 add
            contitutionList = new List<Constitutions>();
            for(Constitution_Common__c cc:cclist){
                Constitutions c = new Constitutions(cc.Id,cc.Name);
                contitutionList.add(c);
            }
            constitutionCount = contitutionList.size();

        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
    }

    public Pagereference selectConstitution(){
        System.debug('**==**== selectConstitution start ==**==**==');
        PageReference newView;
        try{
            selectConstitution = ApexPages.CurrentPage().getParameters().get('selectConstitution');
            System.debug('**==**== selectConstitution =>' + selectConstitution);
            //選択された値を選択済みとする 2023.09.25 add
            sustainSelectId(selectConstitution,contitutionList);
            contitutionList.sort();
            /* 案件情報 */
            List<Constitution_Common__c> cclist = [
                                                    SELECT
                                                        ID
                                                        ,Name
                                                        ,ChargeOption__c
                                                        ,Account__r.name
                                                    FROM Constitution_Common__c
                                                    WHERE ID = :selectConstitution
            ];
            constitutionInfo = cclist.get(0);
            /* 連絡先情報 */
            List<Schema.FieldSetMember> fields = SObjectType.NotifyInfo__c.FieldSets.ChangeInputSet.getFields();
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : fields) {
                query += f.getFieldPath() + ', ';
            }
            // query += 'Name FROM NotifyInfo__c WHERE ConstitutionCommon__c=:selectConstitution ORDER BY NAME ASC';
            query += 'Name FROM NotifyInfo__c WHERE ConstitutionCommon__c=:selectConstitution ';
            query += 'AND PastOneFLG__c = false ';
            query += 'ORDER BY NAME ASC ';
            List<NotifyInfo__c> nlist = Database.query(query);
            //連絡先情報が一件もない場合
            if(nlist.size()==0){
                notifyInfoCount=0;
                return null;
            }

            notifyInfo = nlist.get(0);
    
            // List<ZendeskUser__c> zuserInfoList = [SELECT Id FROM ZendeskUser__c WHERE SessionId__c =:sessionid];
            List<ZendeskUser__c> zuserInfoList = [SELECT Id FROM ZendeskUser__c WHERE Code__c =:code];
    
            //ユーザーの権限をチェックし、参照不可・参照のみ画面はViewページを表示させる
            System.debug('**==**== userInfo => ' + userInfo);
            System.debug('**==**== constitutionInfo => ' + constitutionInfo);
            loginUserAuthority = CoodleUtil.checkAuthority(constitutionInfo.ChargeOption__c,notifyInfo,userInfo.Email__c);
            if(AUTH_NOT_VIEW.equals(loginUserAuthority) || AUTH_VIEW_ONLY.equals(loginUserAuthority)){
                System.debug('**==**== 編集権限なし ==**==**');
                // String routing = '/apex/ViewAddress?zid='+zuserInfoList.get(0).Id + '&constitutionid='+selectConstitution+ '&userauthority='+loginUserAuthority+ '&code=' + code;
                String routing = '/apex/ViewAddress?zid='+zuserInfoList.get(0).Id + '&constitutionid='+selectConstitution+ '&code=' + code;
                newView = new PageReference(routing);
                return newView;
            }
            //連絡先情報をここで取得し、申請中であればViewページを表示する
            if(!EDITABLE_STATUS_SHINSEI.equals(notifyInfo.Status__c)&&String.isNotBlank(notifyInfo.Status__c)){
                System.debug('**==**== ステータスが申請もしくは空白以外のため、参照のみ ==**==**');
                String routing = '/apex/ViewAddress?zid='+zuserInfoList.get(0).Id + '&constitutionid='+selectConstitution+ '&code=' + code;
                newView = new PageReference(routing);
                return newView;
            }
    
            String routing = '/apex/ChangeAddress?zid='+zuserInfoList.get(0).Id + '&constitutionid='+selectConstitution+ '&code=' + code;
            
            newView = new PageReference(routing);
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        return newView;
    }

    public Pagereference selectSeikan(){
        PageReference newView;
        try{
            selectConstitution = ApexPages.CurrentPage().getParameters().get('selectConstitution');
            System.debug('**==**== selectConstitution =>' + selectConstitution);
            //選択された値を選択済みとする 2023.09.25 add
            sustainSelectId(selectConstitution,contitutionList);
            contitutionList.sort();
            /* 案件情報 　2023-03-19 add*/
            List<Constitution_Common__c> cclist = [
                                                    SELECT
                                                        ID
                                                        ,Name
                                                        ,ChargeOption__c
                                                        ,Account__r.name
                                                    FROM Constitution_Common__c
                                                    WHERE ID = :selectConstitution
            ];
            constitutionInfo = cclist.get(0);
            //2023.08.25 comment out start
            // /* 連絡先情報 */
            // List<Schema.FieldSetMember> fields = SObjectType.NotifyInfo__c.FieldSets.ChangeInputSet.getFields();
            // String query = 'SELECT ';
            // for(Schema.FieldSetMember f : fields) {
            //     query += f.getFieldPath() + ', ';
            // }
            // // query += 'Name FROM NotifyInfo__c WHERE ConstitutionCommon__c=:selectConstitution ORDER BY NAME ASC';
            // query += 'Name FROM NotifyInfo__c WHERE ConstitutionCommon__c=:selectConstitution ';
            // query += 'AND PastOneFLG__c = false ';
            // query += 'ORDER BY NAME ASC ';
            // List<NotifyInfo__c> nlist = Database.query(query);
            // //連絡先情報が一件もない場合
            // if(nlist.size()==0){
            //     notifyInfoCount=0;
            //     return null;
            // }
            /* 2023-02-19 add end */
            //2023.08.25 end

            List<ZendeskUser__c> zuserInfoList = [SELECT Id FROM ZendeskUser__c WHERE Code__c =:code];
            //2023.08.25 comment out start
            /* 2023-02-20 add start */
            // notifyInfo = nlist.get(0);
            // if(!CoodleUtil.checkExistNotify(constitutionInfo.ChargeOption__c,notifyInfo,userInfo.Email__c)){
            //     notifyInfoCount=0;
            //     return null;
            // }
            /* 2023-02-20 add end */
            //2023.08.25 comment out end

            String routing = '/apex/SeikanIrai?zid='+zuserInfoList.get(0).Id + '&constitutionid='+selectConstitution+ '&code=' + code;
        
            newView = new PageReference(routing);
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+ 'システムエラーが発生しました ' + e.getLineNumber() +' '+e.getMessage()));
            return null;
        }
        
        return newView;
    }
    public Pagereference selectRReport(){
        PageReference newView;
        try{
            selectConstitution = ApexPages.CurrentPage().getParameters().get('selectConstitution');
            System.debug('**==**== selectConstitution =>' + selectConstitution);
            System.debug('**==**== selectRReport START ==**==**');
 
            
            List<Constitution_Common__c> cclist = [
                                                    SELECT
                                                        ID
                                                        ,Name
                                                        ,ChargeOption__c
                                                        ,Account__r.name
                                                    FROM Constitution_Common__c
                                                    WHERE ID = :selectConstitution
            ];
            constitutionInfo = cclist.get(0);

            List<ZendeskUser__c> zuserInfoList = [SELECT Id FROM ZendeskUser__c WHERE Code__c =:code];
            
            // notifyInfo = nlist.get(0);
            // if(!CoodleUtil.checkExistNotify(constitutionInfo.ChargeOption__c,notifyInfo,userInfo.Email__c)){
            //     notifyInfoCount=0;
            //     return null;
            // }
    

            String routing = '/apex/ZabbixReport?zid='+zuserInfoList.get(0).Id + '&constitutionid='+selectConstitution+ '&code=' + code;
        
            newView = new PageReference(routing);
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+ 'システムエラーが発生しました ' + e.getLineNumber() +' '+e.getMessage()));
            return null;
        }
        
        return newView;
    }
    public Pagereference selectSReport(){
        PageReference newView;
        try{
            selectConstitution = ApexPages.CurrentPage().getParameters().get('selectConstitution');
            System.debug('**==**== selectConstitution =>' + selectConstitution);
 
            
            List<Constitution_Common__c> cclist = [
                                                    SELECT
                                                        ID
                                                        ,Name
                                                        ,ChargeOption__c
                                                        ,Account__r.name
                                                    FROM Constitution_Common__c
                                                    WHERE ID = :selectConstitution
            ];
            constitutionInfo = cclist.get(0);

            List<ZendeskUser__c> zuserInfoList = [SELECT Id FROM ZendeskUser__c WHERE Code__c =:code];
            
            // notifyInfo = nlist.get(0);
            // if(!CoodleUtil.checkExistNotify(constitutionInfo.ChargeOption__c,notifyInfo,userInfo.Email__c)){
            //     notifyInfoCount=0;
            //     return null;
            // }
    

            String routing = '/apex/ZabbixProblemReport?zid='+zuserInfoList.get(0).Id + '&constitutionid='+selectConstitution+ '&code=' + code;
        
            newView = new PageReference(routing);
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+ 'システムエラーが発生しました ' + e.getLineNumber() +' '+e.getMessage()));
            return null;
        }
        
        return newView;
    }

    private void sustainSelectId(String selectedId,List<Constitutions> clist){
        //選択された値を選択済みとする
        for(Constitutions c:clist){
            if(c.constitutionId == selectedId){
                c.selectedchk = 1;
            }else{
                c.selectedchk = 0;
            }
        }
        return;
    }

    // public class Constitutions　{
    //2023.09.25 案件選択での表示不具合のため、Comparableを実装
    public class Constitutions implements Comparable{
        public Id constitutionId{get;set;}
        public String contitutionName{get;set;}
        public Integer selectedchk{get;set;}  //2023.09.25 add
        Constitutions(Id id,String name){
            constitutionId = id;
            contitutionName = name;
            selectedchk = 0;  //2023.09.25 add
        }
        public Integer compareTo(Object compareTo) {
            Constitutions comp = (Constitutions)compareTo;
            return comp.selectedchk - this.selectedchk;        
        }
    }

}