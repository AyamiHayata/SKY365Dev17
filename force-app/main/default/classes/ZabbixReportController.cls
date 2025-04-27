/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * パートナーサイト Zabbixレポート
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/04     新規作成
 ********************************************************************************/
public without sharing class ZabbixReportController extends CommunityCommonController {

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

    
    //AWSリソースを操作する指示内容
    public String selectedStatus {get;set;}
    //CSVダウンロード用の変数
    public String selectedItemId { get; set; } // ダウンロード用のItemId
    public String selectedItemName { get; set; } // ダウンロード用のItemName
    public String selectedGraphId { get; set; } // ダウンロード用のgraphId
    public String graphCsvContent { get; set; }
    public String attachmentFileName { get; private set; }

    /* Zabbix接続情報 */
    private Map<String,ZabbixSetting__mdt> zabbixMdtMap; //KEY:developname  VALUE:カスタムメタデータ

    //エラーメッセージ
    private static final String ERR_MS_SYSTEM = 'システムエラーが発生しました。ご連絡ください。';
    private static final String ERR_MS_NONE_KANSISYSTEM = 'こちらの機能はご利用いただけません。';
    private static final String ERR_MS_ZABBIX_RSC_FAILURE = 'リソースの登録がありません。ご連絡ください。';
    private static final String ERR_MS_ZABBIX_REGIST_FAILURE = '監視システムへの登録でエラーが発生しました。ご連絡ください。';
    private static final String ERR_MS_ZABBIX_DELETE_FAILURE = '監視システム上の削除でエラーが発生しました。ご連絡ください。';
    private static final String ERR_MS_ZABBIX_GRAPH_ZERO = '対象リソースにはグラフはありません。';
    private static final String WARNING_MS_SAME_SETTINGNAME = 'すでに同じ名前の設定名で登録があります。';

    public transient List<MonitoringReportInfo> monitorReportList{get;set;}

    // ページネーション
    private static final Integer RECORDS_PER_PAGE = 70;
    // プロパティ
    public Integer currentPage { get; set; }
    public Integer maxPage { get; private set; }

    public Datetime reportStartDatetime{get;set;}
    public Datetime reportEndDatetime{get;set;}
    public String periodkind{get;set;}

    public boolean initFlg{get; set;}

    // 最新の30日・最新の3ヶ月・最新の一年・最新の1時間・最新の3時間・最新の12時間・最新の24時間
    public List<SelectOption> getPkinds() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('最新の30日','最新の30日')); 
        options.add(new SelectOption('最新の3ヶ月','最新の3ヶ月')); 
        options.add(new SelectOption('最新の一年','最新の一年'));
        options.add(new SelectOption('最新の1時間','最新の1時間'));
        options.add(new SelectOption('最新の3時間','最新の3時間'));
        options.add(new SelectOption('最新の12時間','最新の12時間'));
        options.add(new SelectOption('最新の24時間','最新の24時間'));
        
        return options; 
    }
    
    /* 現在時刻 */
    public Datetime currentDateTime{get;set;}
    public String currentDateTimeString{get;set;}

    public ZabbixReportController() {
        try{
            system.debug('**==**== graphCsvContent =>' + graphCsvContent);
            if(String.isBlank(graphCsvContent)){
                super();
                System.debug('**==**== ZabbixReportController Constructor ==**==**');
                zid = ApexPages.CurrentPage().getParameters().get('zid');
                constitutionid = ApexPages.CurrentPage().getParameters().get('constitutionid');
                code = ApexPages.CurrentPage().getParameters().get('code');

                initFlg = true;
                // 初期表示時ホストを選択済みにする
                selectedStatus = '追加';
                candidateAwsResources = new List<String>();
                periodkind = 'last24hours';
                currentPage = 1;  // ページング対応
                maxPage = 0;      // ページング対応

                currentDateTime = Datetime.now();
                currentDateTimeString = currentDateTime.format('yyyy-MM-dd HH:mm:ss', 'JST');
                selectAwsResourcesMap = new Map<String,String>();
                candidateAwsResourcesMap = new Map<String,String>();
                // Zabbixアカウント情報を取得
                zabbixMdtMap = new Map<String,ZabbixSetting__mdt>();
                for(ZabbixSetting__mdt zmdt:[SELECT DeveloperName,ID__c, password__c, EndPoint__c FROM ZabbixSetting__mdt]){
                    zabbixMdtMap.put(zmdt.DeveloperName,zmdt);
                }
                System.debug('**==**== zabbixMdtMap =>' + zabbixMdtMap);
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
                    Integer hostCount = 1;
                    for (ZabbixAWSResource resource : tmpZawsResorces) {
                        tmpZawsResorceMap.put(resource.hostid, resource.host);
                        candidateAwsResources.add(resource.hostid);
                        hostCount++;
                    }
                    reportEndDatetime = Datetime.now().addHours(9);
                    reportStartDatetime = reportEndDatetime.addHours(-24);

                }
            }
        }catch (ZabbixAPIException ze) {
            System.debug('**==**== ze.getMessage() => ' + ze.getLineNumber() +' '+ ze.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ze.getMessage() + ze.getLineNumber() +' '+ ze.getMessage()));
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_SYSTEM + e.getLineNumber() +' '+e.getMessage()));
        }    
    }

    public override PageReference initAction() {
        try {
            super.initAction();
            System.debug('**==**== ZabbixReportController initAction START ==**==**');
            
            // Zendeskユーザーを取得する
            List<ZendeskUser__c> zuserInfoList = [SELECT Id, Name__c, ZendeskUserId__c, SessionId__c, ZendeskOrgId__c, ConsentVersion__c, Code__c, Email__c FROM ZendeskUser__c WHERE Code__c =:code];
            name = zuserInfoList.get(0).Name__c;
            code = zuserInfoList.get(0).Code__c;
            zendeskUserId = zuserInfoList.get(0).ZendeskUserId__c;
            zid = zuserInfoList.get(0).Id;

            if(String.isBlank(kanshiSystem) || String.isBlank(groupId)){
                tmpZawsResorces = new List<ZabbixAWSResource>();
                //エラーにする
                System.debug('**==**== こちらの機能はご利用いただけません。 ==> ' + constitutionInfo.Zabbix_Datadog__c);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_NONE_KANSISYSTEM)); 
            }      
            
        }catch (ZabbixAPIException ze) {
            System.debug('**==**== ze.getMessage() => ' + ze.getLineNumber() +' '+ ze.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ze.getLineNumber() +' '+ ze.getMessage()));
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_SYSTEM + e.getLineNumber() +' '+e.getMessage()));
        }
        return null;
    }

    public PageReference describeGraph() {
        System.debug('**==**== ZabbixReportController describeGraph START ==**==**');
        try {
            initFlg = false;
            selectedStatus = '復元';
            getAwsResources();
            getcAwsResources();
            Set<String> hostIds = new Set<String>();
            if(selectAwsResourcesMap.size() > 0 ){
                for(String hostid:selectAwsResourcesMap.keySet()){
                    hostIds.add(hostid);
                }
            }
            // グラフ取得
            //範囲指定によって日付を設定する
            String fromtimestr;
            String totimestr;
  
            fromtimestr = String.valueOf(reportStartDatetime);
            totimestr = String.valueOf(reportEndDatetime);
            totimestr = totimestr.left(totimestr.length() - 2) + '59';
            // Zabbix22 不具合対応 modify by 2024/5/14
            String period = String.valueOf((reportEndDatetime.getTime() - reportStartDatetime.getTime()) / 1000);
            String stimeStr = reportStartDatetime.format('yyyyMMddHHmmss');
            // Zabbix22 不具合対応 modify by 2024/5/14
            Map<String,MonitoringReportInfo> graphMap = ZabbixAPIController.executeGetGraph(kanshiSystem, groupId,hostIds,fromtimestr,totimestr);
            // System.debug('**==**== graphMap => ' + graphMap);

            List<MonitoringReportInfo> allReport = graphMap.values();
            
            if(allReport!=null && allReport.size() > 0){
                allReport.sort();
                // ページネーション処理
                List<List<MonitoringReportInfo>> paginatedMonitorReportList = new List<List<MonitoringReportInfo>>();
                // Integer totalGraphsize = 0;   //全体のグラフ数
                Integer countnumnber = 0;     //配列のカウント
                Integer grahcountsize = allReport[countnumnber].graphList.size(); //処理したグラフ数
                Boolean nextPageFlg = false;

                List<MonitoringReportInfo> tempMonitorReportList;
                for(MonitoringReportInfo countminfo:allReport){
                    if(countnumnber == 0 || nextPageFlg) {
                        tempMonitorReportList = new List<MonitoringReportInfo>();
                        nextPageFlg = false;
                    }
                    tempMonitorReportList.add(countminfo);
                    countnumnber ++;
                    if(countnumnber < allReport.size()){
                        grahcountsize = grahcountsize + allReport[countnumnber].graphList.size();
                        if(RECORDS_PER_PAGE < grahcountsize){
                            nextPageFlg = true;
                            grahcountsize = allReport[countnumnber-1].graphList.size();
                            paginatedMonitorReportList.add(tempMonitorReportList);
                        }
                    }
                    if(countnumnber == allReport.size()){
                        paginatedMonitorReportList.add(tempMonitorReportList);
                    }
                }
                maxPage = paginatedMonitorReportList.size();
                if(currentPage > maxPage){
                    currentPage = maxPage;
                }
                List<MonitoringReportInfo> currentGaphList = ZabbixAPIController.executeGetGraphImg(kanshiSystem, groupId,fromtimestr,totimestr, paginatedMonitorReportList[currentPage - 1], stimeStr, period);
                
                monitorReportList = currentGaphList;
                monitorReportList.sort();
            }else{
                System.debug('**==**== 対象リソースにはグラフが存在しません ==**==**');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_ZABBIX_GRAPH_ZERO));
            }

        }catch (ZabbixAPIException ze) {
            System.debug('**==**== ze.getMessage() => ' + ze.getLineNumber() +' '+ ze.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ze.getLineNumber() +' '+ ze.getMessage()));
        }catch (Exception e) {
            System.debug('**==**== e.getMessage() => ' + e.getLineNumber() +' '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ERR_MS_SYSTEM + e.getLineNumber() +' '+e.getMessage()));
        }
        return null;
    }

    public PageReference previousPage() {
        currentPage = currentPage - 1;
        describeGraph();
        return null;
    }


    public PageReference nextPage() {
        currentPage = currentPage + 1;
        describeGraph();
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
    /**
     * downloadCSV
     *
     */
    public PageReference downloadCSV() {
        System.debug('**==**== downloadCSV start ==**==**');

        // ファイル名を指定します
        attachmentFileName = selectedGraphId + '_' + selectedItemName + '_' + reportStartDatetime.format('yyyyMMddHHmmss') +'.csv';
        System.debug('**==**== attachmentFileName => ' + attachmentFileName);
        
        // 応答を設定してファイルダウンロードを開始する
        PageReference downloadPage = Page.graphCSVDownloadPage;
        downloadPage.getParameters().put('selectedItemId', EncodingUtil.urlEncode(selectedItemId, 'UTF-8'));
        downloadPage.getParameters().put('reportStartDatetime', EncodingUtil.urlEncode(String.valueOf(reportStartDatetime), 'UTF-8'));
        downloadPage.getParameters().put('reportEndDatetime', EncodingUtil.urlEncode(String.valueOf(reportEndDatetime), 'UTF-8'));
        downloadPage.getParameters().put('groupId', EncodingUtil.urlEncode(groupId, 'UTF-8'));
        downloadPage.getParameters().put('kanshiSystem', EncodingUtil.urlEncode(kanshiSystem, 'UTF-8'));
        downloadPage.getParameters().put('attachfilename', EncodingUtil.urlEncode(attachmentFileName, 'UTF-8'));

        downloadPage.getHeaders().put('Content-Type', 'text/csv');
        // downloadPage.getHeaders().put('Content-Disposition', 'attachment; filename=' +  EncodingUtil.urlEncode(attachmentFileName, 'UTF-8'));
        // downloadPage.setRedirect(true);
        downloadPage.setRedirect(false);
        
        return downloadPage;
    }
    //リソースの候補リストを表示させる
    public List<SelectOption> getcAwsResources() {
        System.debug('**==**== getcAwsResources start ==**==**');
        System.debug('**==**== selectedStatus ==> ' + selectedStatus);
        system.debug('**==**== candidateAwsResourcesMap ==>' + candidateAwsResourcesMap);
        system.debug('**==**== candidateAwsResources ==>' + candidateAwsResources);
        system.debug('**==**== selectAwsResourcesMap ==>' + selectAwsResourcesMap);
        system.debug('**==**== selectAwsResources ==>' + selectAwsResources);
        system.debug('**==**== tmpZawsResorceMap ==>' + tmpZawsResorceMap);
        
        
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
        if('追加'.equals(selectedStatus) ){
            //選択済みリストに存在する値を削除する
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
        //画面遷移前の状態を復元する
        if('復元'.equals(selectedStatus) ){
            if(selectAwsResourcesMap.size() > 0 ){
                for(String selectzumiKey:selectAwsResourcesMap.keySet()){
                    candidateAwsResourcesMap.remove(selectzumiKey);
                }
            }
            options = new List<SelectOption>();
            for (String resourceKey : candidateAwsResourcesMap.keyset()) {
                options.add(new SelectOption(resourceKey, candidateAwsResourcesMap.get(resourceKey)));
            }
        }
        return options;
    }
    //リソースの選択済みリストを表示させる
    public List<SelectOption> getAwsResources() {
        system.debug('**==**== getAwsResources ==**==**');
        List<SelectOption> options = new List<SelectOption>();

        system.debug('**==**== candidateAwsResourcesMap ==>' + candidateAwsResourcesMap);
        system.debug('**==**== candidateAwsResources ==>' + candidateAwsResources);
        system.debug('**==**== selectAwsResourcesMap ==>' + selectAwsResourcesMap);
        system.debug('**==**== selectAwsResources ==>' + selectAwsResources);
        system.debug('**==**== tmpZawsResorceMap ==>' + tmpZawsResorceMap);

        if('追加'.equals(selectedStatus) ){
        // if('追加'.equals(selectedStatus)){
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
        }else if('復元'.equals(selectedStatus)){
            for(String hostid:selectAwsResourcesMap.keySet()){
                options.add(new SelectOption(hostid, selectAwsResourcesMap.get(hostid)));
            }
        }else{
            system.debug('**==**== その他 ==**==**');
        }
        
        System.debug('**==**== options => ' + options);
        return options;
    }
    public void moveAwsResources(){
        System.debug('*candidateAwsResources' + candidateAwsResources);
        selectedStatus = '追加';
        currentPage = 1;
        maxPage = 1;
    } 
    public void moveAllAwsResources(){
        System.debug('**==**== moveAllAwsResources ==**==**');
        selectedStatus = '追加';
        Integer hostCount = selectAwsResourcesMap.size();
        System.debug('**++**++ hostCount => ' + hostCount);
        for (ZabbixAWSResource resource : tmpZawsResorces) {
            tmpZawsResorceMap.put(resource.hostid, resource.host);
            // 初期表示時ホストを選択済みにする
            // if(hostCount <= 10){
            //     candidateAwsResources.add(resource.hostid);
            // }
            candidateAwsResources.add(resource.hostid);
            hostCount++;
        }
        currentPage = 1;
        maxPage = 1;
        System.debug('**++**++ candidateAwsResources => ' + candidateAwsResources);
    } 

    public void removeAwsResources(){
        System.debug('★selectAwsResources★' + selectAwsResources);
        selectedStatus = '削除';
        currentPage = 1;
        maxPage = 1;
    }
    public void removeAllAwsResources(){
        System.debug('**==**== removeAllAwsResources ==**==**');
        selectedStatus = '追加';
        candidateAwsResources = new List<String>();
        selectAwsResourcesMap = new Map<String,String>();
        candidateAwsResourcesMap = new Map<String,String>();
        currentPage = 1;
        maxPage = 1;
    }

    // ラジオボタンが変更された場合のアクション
    public PageReference periodRadioChanged() {
        system.debug('**==**== periodRadioChanged START ==**==**');
        periodkind = ApexPages.CurrentPage().getParameters().get('periodkind');
        system.debug('**==**== periodkind => ' + periodkind);
        
        return null;
    }


}