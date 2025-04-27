/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * パートナーサイト 連絡先変更
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/08     新規作成
 ********************************************************************************/
public without sharing class SeikanIraiController extends CommunityCommonController {

    /* 静観依頼登録時のIDの付番時のプレフィックス */
    private static final String SEIKANID_PREFIX = '05_';

    /* メンテナンス情報の状況表示 */    
    public static String SEIKAN_MITATSU = System.Label.PS_SEIKANMACHI;
    public static String SEIKAN_CHU = System.Label.PS_SEIKANCHU;
    public static String SEIKAN_END = System.Label.PS_SEIKANEND;
    
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

    /* メンテナンス情報一覧 */
    public List<seikanIraiZabixInfo> dispMaintenanceList{get;set;}

    /* 現在時刻 */
    public Datetime currentDateTime{get;set;}
    public String currentDateTimeString{get;set;}

    /* Zabbix接続情報 */
    private Map<String,ZabbixSetting__mdt> zabbixMdtMap; //KEY:developname  VALUE:カスタムメタデータ

    public String seikanId{get;set;}
    public String seikanDispId{get;set;}
    public String seikanType{get;set;}
    public Datetime seikanStartDatetime{get;set;}
    public Datetime seikanEndDatetime{get;set;}
    public String maintenanceId{get;set;}

    //エラーメッセージ
    private static final String ERR_MS_SYSTEM = 'システムエラーが発生しました。ご連絡ください。';
    // private static final String ERR_MS_NONE_KANSISYSTEM = '監視システムの登録がありません。ご連絡ください。';
    private static final String ERR_MS_NONE_KANSISYSTEM = 'こちらの機能はご利用いただけません。';
    private static final String ERR_MS_ZABBIX_RSC_FAILURE = 'リソースの登録がありません。ご連絡ください。';
    private static final String ERR_MS_ZABBIX_REGIST_FAILURE = '監視システムへの登録でエラーが発生しました。ご連絡ください。';
    private static final String ERR_MS_ZABBIX_DELETE_FAILURE = '監視システム上の削除でエラーが発生しました。ご連絡ください。';
    private static final String WARNING_MS_SAME_SETTINGNAME = 'すでに同じ名前の設定名で登録があります。';

    public SeikanIraiController(){
        try{
            super();
            System.debug('**==**== SeikanIraiController Constructor ==**==**');
            zid = ApexPages.CurrentPage().getParameters().get('zid');
            constitutionid = ApexPages.CurrentPage().getParameters().get('constitutionid');
            code = ApexPages.CurrentPage().getParameters().get('code');
            seikanType = '一度限り';
            selectedStatus = '';
            currentDateTime = Datetime.now();
            currentDateTimeString = currentDateTime.format('yyyy-MM-dd HH:mm:ss', 'JST');
            selectAwsResourcesMap = new Map<String,String>();
            candidateAwsResourcesMap = new Map<String,String>();
            // Zabbixアカウント情報を取得
            zabbixMdtMap = new Map<String,ZabbixSetting__mdt>();
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
            constitutionName = constitutionInfo.Name; //2023.08.28 add 
            //監視システムがZabbix接続情報に存在するかを確認する
            kanshiSystem = '';
            //2023.05.09 add 案件情報の監視システムに値が入っていない場合はエラーにする
            //2023.09.19　ZabbixグループIDのチェックも追加
            // if(String.isBlank(constitutionInfo.Zabbix_Datadog__c)){
            if(String.isBlank(constitutionInfo.Zabbix_Datadog__c) || String.isBlank(constitutionInfo.ZabbixGroupId__c)){
                System.debug('**==**== こちらの機能はご利用いただけません。 ==> ' + constitutionInfo.Zabbix_Datadog__c);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_NONE_KANSISYSTEM)); 

            }else{
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
                    System.debug('**==**== こちらの機能はご利用いただけません。 ==> ' + constitutionInfo.Zabbix_Datadog__c);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_NONE_KANSISYSTEM));
                }else{
                    // constitutionName = constitutionInfo.Name;
                    companyName = cclist.get(0).Account__r.name;
                    groupId = constitutionInfo.ZabbixGroupId__c;
                    tmpZawsResorces = ZabbixAPIController.executeGetAWSResources(kanshiSystem, groupId);
                    tmpZawsResorceMap = new Map<String,String>();
                    for (ZabbixAWSResource resource : tmpZawsResorces) {
                        tmpZawsResorceMap.put(resource.hostid, resource.host);
                    }
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
    public override PageReference initAction() {
        try {
            super.initAction();
            System.debug('**==**== SeikanIraiController initAction START ==**==**');
            // Zendeskユーザーを取得する
            List<ZendeskUser__c> zuserInfoList = [SELECT Id, Name__c, ZendeskUserId__c, SessionId__c, ZendeskOrgId2__c, ConsentVersion__c, Code__c, Email__c FROM ZendeskUser__c WHERE Code__c =:code];
            name = zuserInfoList.get(0).Name__c;
            code = zuserInfoList.get(0).Code__c;
            zendeskUserId = zuserInfoList.get(0).ZendeskUserId__c;
            //2023.05.08 add kanshisystemが取得できている場合にのみデータを取りに行く
    System.debug('**==kanshiSystem =>' + kanshiSystem);
            // if(String.isNotBlank(kanshiSystem)){
            //2023.09.19 ZabbixグループIDが空のときもエラーにする
            if(String.isNotBlank(kanshiSystem) && String.isNotBlank(groupId)){
                createData();
            }else{  //2023.09.01 refreshメソッドでinitAction呼ばれた際の対応を追加
                tmpZawsResorces = new List<ZabbixAWSResource>();
                //エラーにする
                System.debug('**==**== こちらのサービスの機能はご提供しておりません。 ==> ' + constitutionInfo.Zabbix_Datadog__c);
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
    public Pagereference save(){
        system.debug('**==**== save ==**==**');
        try{
            if(!checkInputMentenanceName(dispMaintenanceList,seikanDispId)){
                String registId = SEIKANID_PREFIX + constitutionInfo.ConstitutionManagementNumber__c + '-' + seikanDispId;
                String maintenanceId = ZabbixAPIController.executeCreateMaintenances(kanshiSystem, registId, new List<String>(selectAwsResourcesMap.keySet()), seikanStartDatetime.addHours(-9), seikanEndDatetime.addHours(-9));
                String conid = constitutionid;
                String coname = constitutionName;
                String startdt = seikanStartDatetime.format();
                String enddt = seikanEndDatetime.format();
                String dispid = seikanDispId;
                List<String> targetAwsList = new List<String>(selectAwsResourcesMap.values());
                initDisplay();
                initAction();
                //案件を更新する
                setFeedContents(MaintenanceInfo.TYPE_NEW,conid,coname,name,startdt,enddt,dispid,targetAwsList,kanshiSystem,maintenanceId);
                
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + WARNING_MS_SAME_SETTINGNAME));
            }
        }catch (ZabbixAPIException ze) {
            System.debug('**==**== ze.getMessage() => ' + ze.getLineNumber() +' '+ ze.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_ZABBIX_REGIST_FAILURE + ze.getLineNumber() +' '+ ze.getMessage()));
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_SYSTEM + e.getLineNumber() +' '+e.getMessage()));
        }  
        return null;
    }
    public Pagereference updateMaintenanceInfo(){
        system.debug('**==**== updateMaintenanceInfo ==**==**');
        try{
            system.debug('**==**== kanshiSystem => '+kanshiSystem);
            system.debug('**==**== maintenanceId => '+maintenanceId);
            system.debug('**==**== seikanId => '+seikanId);
            system.debug('**==**== selectAwsResources => '+selectMaintenanceAwsResourcesMap.keySet());
            system.debug('**==**== seikanStartDatetime => '+seikanStartDatetime);
            system.debug('**==**== seikanEndDatetime => '+seikanEndDatetime);
            // ZabbixAPIController.executeUpdateMaintenances(kanshiSystem, maintenanceId,seikanId, new List<String>(selectAwsResourcesMap.keySet()),seikanStartDatetime.addHours(-9), seikanEndDatetime.addHours(-9));
            ZabbixAPIController.executeUpdateMaintenances(kanshiSystem, maintenanceId,seikanId, new List<String>(selectMaintenanceAwsResourcesMap.keySet()),seikanStartDatetime.addHours(-9), seikanEndDatetime.addHours(-9));
            String conid = constitutionid;
            String coname = constitutionName;
            String startdt = seikanStartDatetime.format();
            String enddt = seikanEndDatetime.format();
            String dispid = seikanDispId;
            List<String> targetAwsList = new List<String>(selectMaintenanceAwsResourcesMap.values());
            initDisplay();
            initAction();
            //案件を更新する
            setFeedContents(MaintenanceInfo.TYPE_UPDATE,conid,coname,name,startdt,enddt,dispid,targetAwsList,kanshiSystem,maintenanceId);
        }catch (ZabbixAPIException ze) {
            System.debug('**==**== ze.getMessage() => ' + ze.getLineNumber() +' '+ ze.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_ZABBIX_REGIST_FAILURE + ze.getLineNumber() +' '+ ze.getMessage()));
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_SYSTEM + e.getLineNumber() +' '+e.getMessage()));
        }
        return null;
    }

    public Pagereference deleteMaintenanceInfo(){
        system.debug('**==**== deleteMaintenanceInfo ==**==**');
        try{
            String conid = constitutionid;
            String coname = constitutionName;
            String startdt = seikanStartDatetime.format();
            String enddt = seikanEndDatetime.format();
            String dispid = seikanDispId;
            List<String> targetAwsList = new List<String>(selectMaintenanceAwsResourcesMap.values()); 
            // System.debug('**==**== selectMaintenanceAwsResourcesMap => ' + selectMaintenanceAwsResourcesMap);
            ZabbixAPIController.executeDeleteMaintenances(kanshiSystem, maintenanceId);
            initDisplay();
            initAction();
            //案件を更新する
            setFeedContents(MaintenanceInfo.TYPE_DELETE,conid,coname,name,startdt,enddt,dispid,targetAwsList,kanshiSystem,maintenanceId);
        }catch (ZabbixAPIException ze) {
            System.debug('**==**== ze.getMessage() => ' + ze.getLineNumber() +' '+ ze.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_ZABBIX_DELETE_FAILURE + ze.getLineNumber() +' '+ ze.getMessage()));
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_SYSTEM + e.getLineNumber() +' '+e.getMessage()));
        }
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

    public void setAndReleaseMaintenanceInfo(){
        System.debug('**==**== setAndReleaseMaintenanceInfo ==**==**');
        //明細を取得する
        Integer checkcount = 0;
        ZabbixMaintenance targetinfo;
        String dispIdName;
        for(seikanIraiZabixInfo zi:dispMaintenanceList){
            if(zi.targetCheck){
                checkcount++;
                targetinfo = zi.maintenanceInfo;
                dispIdName = zi.dispId;
            }
        }
        //選択されたデータを画面に表示する
        if(checkcount > 0){
            //チェックがある場合
            //対象AWSリソース
            selectMaintenanceAwsResourcesMap = new Map<String,String>();
            for(ZabbixAWSResource zaresource:targetinfo.hosts){
                selectMaintenanceAwsResourcesMap.put(zaresource.hostid,zaresource.host);
            }    
            selectedStatus = '選択';
            //ID
            seikanId = targetinfo.name;
            seikanDispId = dispIdName;
            //有効期間開始日時
            // seikanStartDatetime = targetinfo.dt_active_since;
            seikanStartDatetime = targetinfo.dt_active_since.addHours(9);
            //有効期間終了日時
            // seikanEndDatetime = targetinfo.dt_active_till;
            seikanEndDatetime = targetinfo.dt_active_till.addHours(9);
            //メンテナンスID
            maintenanceId = targetinfo.maintenanceid;
            //チェックが入っていないチェックボックスを不活性化する
            for(seikanIraiZabixInfo zi:dispMaintenanceList){
                if(!zi.targetCheck){
                    zi.targetCheckDisabled = true;
                }
            }

        }else{
            //チェックがない場合
            initDisplay();
            //チェックボックスをすべて活性化する
            for(seikanIraiZabixInfo zi:dispMaintenanceList){
                zi.targetCheckDisabled = false;
            }
        }
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
        //一覧の中のデータを選択した場合
        if('選択'.equals(selectedStatus)){
            for(String hostid:selectMaintenanceAwsResourcesMap.keySet()){
                candidateAwsResourcesMap.remove(hostid);
            }
            options = new List<SelectOption>();
            for (String resourceKey : candidateAwsResourcesMap.keyset()) {
                options.add(new SelectOption(resourceKey, candidateAwsResourcesMap.get(resourceKey)));
            }
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
        }else if('選択'.equals(selectedStatus)){
            for(String hostid:selectMaintenanceAwsResourcesMap.keySet()){
                options.add(new SelectOption(hostid, selectMaintenanceAwsResourcesMap.get(hostid)));
            }
        }else{
            system.debug('**==**== その他 ==**==**');
        }
        System.debug('**==**== options => ' + options);
        return options;
    }

    private void createData(){
        //メンテナンス一覧用
        List<ZabbixMaintenance> tmplist = ZabbixAPIController.executeGetMaintenances(kanshiSystem, groupId);
        List<ZabbixMaintenance> startList = new List<ZabbixMaintenance>();
        for(ZabbixMaintenance zm:tmplist){
            if(zm.name.startsWith('05_')) startList.add(zm);
        }
        dispMaintenanceList = new List<seikanIraiZabixInfo>();
        
        for(ZabbixMaintenance zm:startList){
            seikanIraiZabixInfo zi = new seikanIraiZabixInfo(true,zm,currentDateTime);
            dispMaintenanceList.add(zi);
        }
        dispMaintenanceList.sort();

    }
    private void initDisplay(){

        //対象AWSリソース
        selectedStatus = '';
        //ID
        seikanId = '';
        seikanDispId = '';
        //有効期間開始日時
        seikanStartDatetime = null;
        //有効期間終了日時
        seikanEndDatetime = null;
        //選択可能リストの初期化
        getcAwsResources();

    }
    private void setFeedContents(String type,String conId,String ankenname,String accountname,String startdttime,String enddttime,String registname,List<String> awsresources, String kanshiSystem, String maintenanceId){
        MaintenanceInfo info = new MaintenanceInfo();
        info.type = type;
        info.ankenName = ankenname;
        info.updateUser = accountname;
        info.registName = registname;
        info.startDT = startdttime;
        info.endDT = enddttime;
        info.resourceNames = awsresources;
        info.commentRegist(conId);
        // kikuchi 修正 2023/3/23 start
        info.ankenId = conId;
        info.zabbixVersion = kanshiSystem;
        info.maintenanceId = maintenanceId;
        info.dataUpd(conId);
        // kikuchi 修正 2023/3/23 end
    }

    private boolean checkInputMentenanceName(List<seikanIraiZabixInfo> targetmentList,String settingName){
        boolean chkFlg = false;
        for(seikanIraiZabixInfo sinfo:targetmentList){
            if(settingName.equals(sinfo.dispId)){
                chkFlg = true;
                break;
            }
        }
        return chkFlg;
    }
    // SF_CORE_DEV-206対応 2023/6/7 kikuchi
    public Pagereference refresh() {
        currentDateTime = Datetime.now();
        currentDateTimeString = currentDateTime.format('yyyy-MM-dd HH:mm:ss', 'JST');
        initAction();
        return null;
    }

    public class seikanIraiZabixInfo implements Comparable{
        public boolean targetCheck{get;set;}
        public boolean targetCheckShow{get;set;}
        public boolean targetCheckDisabled{get;set;}
        public String seikanjokyo{get;set;}
        public String seikanjokyoCss{get;set;}
        public String dispId{get;set;}
        public Datetime seikanstartDtime{get;set;}
        public ZabbixMaintenance maintenanceInfo {get;set;}
        private Datetime currentDt;

        public seikanIraiZabixInfo(boolean targetCheckShowflg,ZabbixMaintenance za,Datetime ctime){
            targetCheck = false;
            targetCheckDisabled = false;
            targetCheckShow = targetCheckShowflg;
            maintenanceInfo = za;
            currentDt = ctime;
            seikanjokyo = getSeikanJokyo();
            seikanjokyoCss = getSeikanjokyoCss();
            dispId = getDispId();
            seikanstartDtime = getSeikanstartDtime();
        }
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            seikanIraiZabixInfo compareToZinfo = (seikanIraiZabixInfo)compareTo;
            if (seikanstartDtime == compareToZinfo.seikanstartDtime) return 0;
            if (seikanstartDtime > compareToZinfo.seikanstartDtime) return 1;
            return -1;        
        }
        private String getSeikanJokyo(){
            string jokyo = SEIKAN_CHU;
            if(currentDt < maintenanceInfo.dt_active_since ){
                jokyo = SEIKAN_MITATSU;
            }else{
                if(maintenanceInfo.dt_active_till < currentDt){
                    jokyo = SEIKAN_END;
                }
            }
            return jokyo;
        }
        private String getDispId(){
            String dspid = maintenanceInfo.name;
            
            String matchpattern = '05_C\\d{1,}-';
            Pattern searchPattern = Pattern.compile(matchpattern);
            Matcher match = searchPattern.matcher(maintenanceInfo.name);
            String matchStr ='';

            while (match.find()) {
                System.debug('マッチング文字列：' + match.group());
                matchStr = match.group();
            }
            if(String.isNotBlank(matchStr)){
                dspid = dspid.replace(matchStr, '');
            }
            return dspid;
        }
        private Datetime getSeikanstartDtime(){
            return maintenanceInfo.dt_active_since;
        }
        private String getSeikanjokyoCss(){
            String jokyo='';
            if(SEIKAN_CHU.equals(seikanjokyo)){
                jokyo = 'seikanchu';
            }
            return jokyo;
        }
    }
}