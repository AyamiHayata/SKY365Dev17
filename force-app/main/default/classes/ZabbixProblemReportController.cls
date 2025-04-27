/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * パートナーサイト Zabbix障害レポート
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/11     新規作成     kikuchi
 ********************************************************************************/
public without sharing class ZabbixProblemReportController extends CommunityCommonController {
    /* Zendesk */
    public String zid {get;set;}
    public String zendeskUserId {get;set;}

    /* ログインユーザ名 */
    public String name {get;set;}
    
    /* 案件情報 */
    public String constitutionid {get;set;}
    public Constitution_Common__c constitutionInfo {get;set;}
    public String constitutionName {get;set;}
    public String companyName {get;set;}

    /* Zabbix 接続情報 */
    //監視システム
    private String kanshiSystem;
    //ZabbixグループID
    private String groupId;

    /* AWSリソース名 */
    private List<ZabbixAWSResource> tmpZawsResorces;
    private Map<String,String> tmpZawsResorceMap;
    //候補となるAWSリソースリスト
    public List<String> candidateAwsResources {get;set;}
    public Map<String,String> candidateAwsResourcesMap{get;set;}
    //選択されたAWSリソースリスト
    public List<String> selectAwsResources {get;set;}
    public Map<String,String> selectAwsResourcesMap{get;set;}
    //メンテナンス一覧で選択された情報のAWS一覧
    public Map<String,String> selectMaintenanceAwsResourcesMap{get;set;}
    //AWSリソースを操作する指示内容
    public String selectedStatus {get;set;}
    //障害情報リスト
    public List<ProblemReportInfo> problemReportInfoList{get; set;}


    /* Zabbix接続情報 */
    private Map<String,ZabbixSetting__mdt> zabbixMdtMap; //KEY:developname  VALUE:カスタムメタデータ

    //エラーメッセージ
    private static final String ERR_MS_SYSTEM = 'システムエラーが発生しました。ご連絡ください。';
    private static final String ERR_MS_NONE_KANSISYSTEM = 'こちらの機能はご利用いただけません。';
    private static final String ERR_MS_ZABBIX_RSC_FAILURE = 'リソースの登録がありません。ご連絡ください。';
    private static final String ERR_MS_ZABBIX_REGIST_FAILURE = '監視システムへの登録でエラーが発生しました。ご連絡ください。';
    private static final String ERR_MS_ZABBIX_DELETE_FAILURE = '監視システム上の削除でエラーが発生しました。ご連絡ください。';
    private static final String WARNING_MS_SAME_SETTINGNAME = 'すでに同じ名前の設定名で登録があります。';

    /* 現在時刻 */
    public Datetime currentDateTime{get;set;}
    public String currentDateTimeString{get;set;}
    
    /**
     * ZabbixProblemReportControllerクラスの新しいインスタンスを初期化します。
     */    
    public ZabbixProblemReportController() {
        try{
            super();
            System.debug('**==**== ZabbixProblemReportController Constructor ==**==**');
            zid = ApexPages.CurrentPage().getParameters().get('zid');
            constitutionid = ApexPages.CurrentPage().getParameters().get('constitutionid');
            code = ApexPages.CurrentPage().getParameters().get('code');
            // 初期表示時ホストを選択済みにする
            selectedStatus = '追加';
            candidateAwsResources = new List<String>();
   
            currentDateTime = Datetime.now();
            currentDateTimeString = currentDateTime.format('yyyy-MM-dd HH:mm:ss', 'JST');
            selectAwsResourcesMap = new Map<String,String>();
            candidateAwsResourcesMap = new Map<String,String>();
            // Zabbixアカウント情報を取得
            zabbixMdtMap = new Map<String,ZabbixSetting__mdt>();
            //障害情報リスト
            problemReportInfoList = new List<ProblemReportInfo>();
            for(ZabbixSetting__mdt zmdt:[SELECT DeveloperName,ID__c, password__c, EndPoint__c FROM ZabbixSetting__mdt]){
                zabbixMdtMap.put(zmdt.DeveloperName,zmdt);
            }
            /* 案件情報 */
            List<Constitution_Common__c> cclist = [
                SELECT
                    ID
                    ,Name
                    ,Zabbix_Datadog__c
                    ,ZabbixGroupId__c
                    ,ConstitutionManagementNumber__c
                    ,Account__r.name
                FROM Constitution_Common__c
                WHERE ID = :constitutionid
            ];
            constitutionInfo = cclist.get(0);
            //監視システムがZabbix接続情報に存在するかを確認する
            kanshiSystem = '';
            for(String systemName:constitutionInfo.Zabbix_Datadog__c.split(';')){
                ZabbixSetting__mdt zmdt = zabbixMdtMap.get(systemName);
                if(zmdt!=null){
                    kanshiSystem = zmdt.DeveloperName;
                    break;
                }
            }
            if(String.isBlank(kanshiSystem)){
                tmpZawsResorces = new List<ZabbixAWSResource>();
                //エラーにする
                System.debug('**==**== この監視システムはカスタムメタデータに登録はありません ==> ' + constitutionInfo.Zabbix_Datadog__c);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_NONE_KANSISYSTEM));
            }else{
                constitutionName = constitutionInfo.Name;
                companyName = cclist.get(0).Account__r.name;
                groupId = constitutionInfo.ZabbixGroupId__c;
                tmpZawsResorces = ZabbixAPIController.executeGetAWSResources(kanshiSystem, groupId);
                tmpZawsResorceMap = new Map<String,String>();
                for (ZabbixAWSResource resource : tmpZawsResorces) {
                    tmpZawsResorceMap.put(resource.hostid, resource.host);
                    // 初期表示時ホストを選択済みにする
                    candidateAwsResources.add(resource.hostid);
                }
            }
        }catch (ZabbixAPIException ze) {
            System.debug('**==**== ze.getMessage() => ' + ze.getLineNumber() +' '+ ze.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_ZABBIX_RSC_FAILURE + ze.getLineNumber() +' '+ ze.getMessage()));
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_SYSTEM + e.getLineNumber() +' '+e.getMessage()));
        }
    }


    /**
     * initAction
     *
     */    
    public override PageReference initAction() {
        try {
            super.initAction();
            System.debug('**==**== ZabbixProblemReportController initAction START ==**==**');
        
            // Zendeskユーザーを取得する
            List<ZendeskUser__c> zuserInfoList = [SELECT Id, Name__c, ZendeskUserId__c, SessionId__c, ZendeskOrgId2__c, ConsentVersion__c, Code__c, Email__c FROM ZendeskUser__c WHERE Code__c =:code];
            name = zuserInfoList.get(0).Name__c;
            code = zuserInfoList.get(0).Code__c;
            zendeskUserId = zuserInfoList.get(0).ZendeskUserId__c;



            if(String.isNotBlank(kanshiSystem) && String.isNotBlank(groupId)){
                problemSearch();
            }else{
                tmpZawsResorces = new List<ZabbixAWSResource>();
                //エラーにする
                System.debug('**==**== こちらの機能はご利用いただけません。 ==> ' + constitutionInfo.Zabbix_Datadog__c);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_NONE_KANSISYSTEM)); 
            }            
        }catch (ZabbixAPIException ze) {
            System.debug('**==**== ze.getMessage() => ' + ze.getLineNumber() +' '+ ze.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_ZABBIX_RSC_FAILURE + ze.getLineNumber() +' '+ ze.getMessage()));      
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_SYSTEM + e.getLineNumber() +' '+e.getMessage()));
        }
        return null;                               
    }

    /**
     * problemSearch
     *
     */      
    public Pagereference problemSearch() {
        System.debug('**==**== ZabbixProblemReportController problemSearch START ==**==**');
        getcAwsResources();
        // 障害情報を取得する。
        problemReportInfoList = ZabbixAPIController.executeGetProblems(kanshiSystem, selectAwsResourcesMap);
        return null;
    }

    /**
     * refresh
     *
     */
    public Pagereference refresh() {
        currentDateTime = Datetime.now();
        currentDateTimeString = currentDateTime.format('yyyy-MM-dd HH:mm:ss', 'JST');
        return null;
    }

    public void moveAwsResources(){
        System.debug('*candidateAwsResources' + candidateAwsResources);
        selectedStatus = '追加';
    } 

    public void removeAwsResources(){
        System.debug('★selectAwsResources★' + selectAwsResources);
        selectedStatus = '削除';
    }

    public List<SelectOption> getcAwsResources() {
        System.debug('**==**== getcAwsResources start ==**==**');
        System.debug('**==**== selectedStatus ==> ' + selectedStatus);
        
        //初期化：この案件が管理するAWSリソース一覧を設定する
        List<SelectOption> options = new List<SelectOption>();
        if(tmpZawsResorces==null) return options;
        for (ZabbixAWSResource resource : tmpZawsResorces) {
            options.add(new SelectOption(resource.hostid, resource.host));
            candidateAwsResourcesMap.put(resource.hostid, resource.host);
        }

        //選択を外されたサーバーを選択可能リストに戻す
        if('削除'.equals(selectedStatus)){
            if(selectAwsResourcesMap.size() > 0 ){
                for(String selectzumiKey:selectAwsResourcesMap.keySet()){
                    candidateAwsResourcesMap.remove(selectzumiKey);
                }
            }
            for(String selectAwshostid:selectAwsResources){
                candidateAwsResourcesMap.put(selectAwshostid,tmpZawsResorceMap.get(selectAwshostid));
                selectAwsResourcesMap.remove(selectAwshostid);
            }
            options = new List<SelectOption>();
            for (String resourceKey : candidateAwsResourcesMap.keyset()) {
                options.add(new SelectOption(resourceKey, candidateAwsResourcesMap.get(resourceKey)));
            }
        }
        //選択済みになったサーバーを選択可能リストから削除する
        if('追加'.equals(selectedStatus)){
            //選択済みリストに存在する値を削除する
            // System.debug('**==**== selectAwsResources => ' + selectAwsResources);
            // System.debug('**==**== selectAwsResourcesMap => ' + selectAwsResourcesMap);

            if(selectAwsResourcesMap.size() > 0 ){
                for(String selectzumiKey:selectAwsResourcesMap.keySet()){
                    candidateAwsResourcesMap.remove(selectzumiKey);
                }
            }

            for(String canhostid:candidateAwsResources){
                candidateAwsResourcesMap.remove(canhostid);
                selectAwsResourcesMap.put(canhostid,tmpZawsResorceMap.get(canhostid));
            }
            options = new List<SelectOption>();
            for (String resourceKey : candidateAwsResourcesMap.keyset()) {
                options.add(new SelectOption(resourceKey, candidateAwsResourcesMap.get(resourceKey)));
            }
        }
        return options;
    }

    public List<SelectOption> getAwsResources() {
        system.debug('**==**== getAwsResources ==**==**');
        List<SelectOption> options = new List<SelectOption>();

        system.debug('**==**== candidateAwsResourcesMap ==>' + candidateAwsResourcesMap);
        system.debug('**==**== candidateAwsResources ==>' + candidateAwsResources);
        system.debug('**==**== selectAwsResourcesMap ==>' + selectAwsResourcesMap);
        system.debug('**==**== selectAwsResources ==>' + selectAwsResources);
        system.debug('**==**== tmpZawsResorceMap ==>' + tmpZawsResorceMap);

        if('追加'.equals(selectedStatus)){
            system.debug('**==**== 追加 ==**==**');
            //すでに選択されたリストがある場合
            if(selectAwsResourcesMap.size()>0){
                for(String selectedhostid:selectAwsResourcesMap.keySet()){
                    options.add(new SelectOption(selectedhostid, selectAwsResourcesMap.get(selectedhostid)));
                    selectAwsResourcesMap.put(selectedhostid,selectAwsResourcesMap.get(selectedhostid));
                }
                for(String canhostid:candidateAwsResources){
                    boolean equalflg = false;
                    for(String selectedhostid:selectAwsResourcesMap.keySet()){
                        //候補リストで新たに選択されたものがすでに選択済みかを判定する
                        if(canhostid.equals(selectedhostid)){
                            equalflg = true;
                        }
                    }
                    if(!equalflg){
                        options.add(new SelectOption(canhostid, tmpZawsResorceMap.get(canhostid)));
                        selectAwsResourcesMap.put(canhostid,tmpZawsResorceMap.get(canhostid));
                    }
                }
            }else{
                for(String canhostid:candidateAwsResources){
                    options.add(new SelectOption(canhostid, tmpZawsResorceMap.get(canhostid)));
                    selectAwsResourcesMap.put(canhostid,tmpZawsResorceMap.get(canhostid));
                }
            }
        }else if('削除'.equals(selectedStatus)){
            system.debug('**==**== 削除 ==**==**');
            //今のリストの値をLoopで回し、選択されたhostを削除する
            for(String hostid:selectAwsResourcesMap.keySet()){
                boolean sameflg = false;
                for(String selectAwshostid:selectAwsResources){
                    if(hostid.equals(selectAwshostid)){
                        sameflg = true;
                        selectAwsResourcesMap.remove(hostid);
                        continue;
                    }
                }
                if(!sameflg){
                    options.add(new SelectOption(hostid, selectAwsResourcesMap.get(hostid)));
                }
            }
        }else{
            system.debug('**==**== その他 ==**==**');
        }
        System.debug('**==**== options => ' + options);
        return options;
    }
}