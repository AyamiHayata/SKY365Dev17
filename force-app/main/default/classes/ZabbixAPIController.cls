public class ZabbixAPIController {

    /* status code 200 */
    public static final Integer STATUS_CODE_200 = 200;
    
    /**
     * HOSTグループIDをキーに対象AWSリソース情報一覧を取得
     * 
     * @param datadogDevName Zabbixアカウント情報.カスタムメタデータレコード名
     * @param groupid ZabbixグループID
     * @return AWSリソース情報一覧
     */
    public static List<ZabbixAWSResource> executeGetAWSResources(String datadogDevName, String groupid) {

        ZabbixAPIRequester requester = new ZabbixAPIRequester(datadogDevName);

        HttpResponse res = requester.getToken();
        Map<String, Object> resMap;
        String token;
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            token = (String) resMap.get('result');
            if (String.isBlank(token)) throw new ZabbixAPIException('トークンの取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('トークンの取得に失敗しました。');
        }

        res = requester.getHosts(groupid, token);
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
            if (errorMap <> null) throw new ZabbixAPIException('AWSリソース情報一覧の取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('AWSリソース情報一覧の取得に失敗しました。');
        }

        List<ZabbixAWSResource> zabbixAWSResources = convertAWSResourceResponseToList(resMap);

        executeLogout(requester, token);

        return zabbixAWSResources;
    }

    /**
     * HOSTグループIDをキーにメンテナンス一覧を取得
     * 
     * @param datadogDevName 監視システムAPI参照名
     * @param groupid ZabbixグループID
     * @return メンテナンス一覧
     */
    public static List<ZabbixMaintenance> executeGetMaintenances(String datadogDevName, String groupid) {

        ZabbixAPIRequester requester = new ZabbixAPIRequester(datadogDevName);

        HttpResponse res = requester.getToken();
        Map<String, Object> resMap;
        String token;
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            token = (String) resMap.get('result');
            if (String.isBlank(token)) throw new ZabbixAPIException('トークンの取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('トークンの取得に失敗しました。');
        }

        res = requester.getMaintenances(groupid, token);
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
            if (errorMap <> null) throw new ZabbixAPIException('メンテナンス一覧の取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('メンテナンス一覧の取得に失敗しました。');
        }

        List<ZabbixMaintenance> zabbixMaintenances = convertMaintenanceResponseToList(resMap);

        executeLogout(requester, token);

        return zabbixMaintenances;
    }

    /**
     * メンテナンス設定を登録する
     * 
     * @param datadogDevName 監視システムAPI参照名
     * @param name 名前
     * @param hostids 対象AWSリソースのリスト
     * @param active_since 開始日時
     * @param active_till 終了日時
     */
    public static String executeCreateMaintenances(String datadogDevName, String name, List<String> hostids, Datetime active_since, Datetime active_till) {

        ZabbixAPIRequester requester = new ZabbixAPIRequester(datadogDevName);

        HttpResponse res = requester.getToken();
        Map<String, Object> resMap;
        String token;
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            token = (String) resMap.get('result');
            if (String.isBlank(token)) throw new ZabbixAPIException('トークンの取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('トークンの取得に失敗しました。');
        }

        res = requester.createMaintenances(name, hostids, active_since.getTime() / 1000, active_till.getTime() / 1000, token);
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
            if (errorMap <> null) throw new ZabbixAPIException('メンテナンス設定の登録に失敗しました。');
        } else {
            throw new ZabbixAPIException('メンテナンス設定の登録に失敗しました。');
        }

        executeLogout(requester, token);
        // 3/23 kikuchi 追加 start 
        String result = '';
        Map<String, Object> resultMap = (Map<String, Object>) resMap.get('result');
        List<Object> maintenanceids = (List<Object>) resultMap.get('maintenanceids');
        if(maintenanceids.size() > 0) {
            result = (String)maintenanceids.get(0);
        } else {
            throw new ZabbixAPIException('メンテナンス設定の登録に失敗しました。'); 
        }
        return result;
        // 3/23 kikuchi 追加 end 
    }

    /**
     * メンテナンスIDをキーにメンテナンス設定を更新する
     * 
     * @param datadogDevName 監視システムAPI参照名
     * @param maintenanceid メンテナンスID
     * @param name 名前
     * @param active_since 開始日時
     * @param active_till 終了日時
     */
    public static void executeUpdateMaintenances(String datadogDevName, String maintenanceid, String name, List<String> hostids, Datetime active_since, Datetime active_till) {

        ZabbixAPIRequester requester = new ZabbixAPIRequester(datadogDevName);

        HttpResponse res = requester.getToken();
        Map<String, Object> resMap;
        String token;
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            token = (String) resMap.get('result');
            if (String.isBlank(token)) throw new ZabbixAPIException('トークンの取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('トークンの取得に失敗しました。');
        }

        res = requester.updateMaintenances(maintenanceid, name, hostids, active_since.getTime() / 1000, active_till.getTime() / 1000, token);
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
            if (errorMap <> null) throw new ZabbixAPIException('メンテナンス設定の更新に失敗しました。');
        } else {
            throw new ZabbixAPIException('メンテナンス設定の更新に失敗しました。');
        }

        executeLogout(requester, token);
    }

    /**
     * メンテナンスIDをキーにメンテナンス設定を削除する
     * 
     * @param datadogDevName 監視システムAPI参照名
     * @param maintenanceid メンテナンスID
     */
    public static void executeDeleteMaintenances(String datadogDevName, String maintenanceid) {

        ZabbixAPIRequester requester = new ZabbixAPIRequester(datadogDevName);

        HttpResponse res = requester.getToken();
        Map<String, Object> resMap;
        String token;
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            token = (String) resMap.get('result');
            if (String.isBlank(token)) throw new ZabbixAPIException('トークンの取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('トークンの取得に失敗しました。');
        }

        res = requester.deleteMaintenances(new List<String>{ maintenanceid }, token);
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
            if (errorMap <> null) throw new ZabbixAPIException('メンテナンス設定の削除に失敗しました。');
        } else {
            throw new ZabbixAPIException('メンテナンス設定の削除に失敗しました。');
        }

        executeLogout(requester, token);
    }
    /**
     * リソースグラフ情報を取得する
     * 
     * @param datadogDevName Zabbixアカウント情報.カスタムメタデータレコード名
     * @param groupid ZabbixグループID
     * @return AWSリソース情報一覧
     */
    public static Map<String,MonitoringReportInfo> executeGetGraph(String datadogDevName, String groupid,Set<String> paraHostids,String active_since, String active_till) {
        System.debug('**== executeGetGrapth start ==**');
        ZabbixAPIRequester requester = new ZabbixAPIRequester(datadogDevName);

        HttpResponse res = requester.getToken();
        Map<String, Object> resMap;
        String token;
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            token = (String) resMap.get('result');
            if (String.isBlank(token)) throw new ZabbixAPIException('トークンの取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('トークンの取得に失敗しました。');
        }
        List<MonitoringReportInfo> monitoringReportInfoList = new List<MonitoringReportInfo>();

        // ① ホストグループIDからホストID（複数）を取得する
        Set<String> hostIds = new Set<String>();
        if(paraHostids == null || paraHostids.size() == 0){
            res = requester.getHosts(groupid, token);
            if (res.getStatusCode() == STATUS_CODE_200) {
                resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
                if (errorMap <> null) throw new ZabbixAPIException('AWSリソース情報一覧の取得に失敗しました。');
            } else {
                throw new ZabbixAPIException('AWSリソース情報一覧の取得に失敗しました。');
            }
            List<Object> hosts = (List<Object>) resMap.get('result');

            hostIds = new Set<String>();
            for (Object hostElement : hosts) {
                Map<String, Object> hostMap = (Map<String, Object>)hostElement;
                hostIds.add((String) hostMap.get('hostid'));
            }
        }else{
            hostIds.addAll(paraHostids);
        }
        
        System.debug('**== hostIds => ' +hostIds);
        System.debug('**== hostIds.size => ' +hostIds.size());
        // ② ホストID（複数）からグラフID（複数）を取得する
        // res = requester.getGraphid('10558', token);
        res = requester.getGraphid(hostIds, token);
        system.debug('**== グラフIDを取得する ==**');
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
            if (errorMap <> null) throw new ZabbixAPIException('グラフID一覧の取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('グラフID一覧の取得に失敗しました。');
        }
        Map<String,MonitoringReportInfo> hostGraphMap = convertGraphResponseToMap(resMap);
        Integer graphIdAllCount = allGraphListSize(hostGraphMap);
        system.debug('**==graphIdAllCount => ' + graphIdAllCount);
        // Integer countupgraphId = 0;
        //③ グラフIDからグラフイメージを取得する 2024.03 ページネーション対応で別メソッドに移動
        // system.debug('**== グラフイメージを取得する ==**');//TODO　この部分を切り出して別関数にする
        // for(String hostid:hostGraphMap.keySet()){
        //     MonitoringReportInfo minfo = hostGraphMap.get(hostid);
        //     countupgraphId += minfo.graphList.size();
        //     // if(countupgraphId <= 10){
        //         for(MonitoringReportInfo.Graph g: minfo.graphList){
        //             // HttpResponse resGraph = requester.getGraphImg(g.graphid, token,active_since.getTime() / 1000, active_till.getTime() / 1000);
        //             HttpResponse resGraph = requester.getGraphImg(g.graphid, token, active_since, active_till);
        //             g.graphImage = resGraph.getBodyAsBlob();
        //             g.graphImageEncode = EncodingUtil.base64Encode(g.graphImage);
        //         }
        // }
        
        // ④ ログアウト
        executeLogout(requester, token);
        // return graphImages;
        return hostGraphMap;

    }
    /**
     * リソースグラフ情報を取得する
     * 
     *
     * @return リソースグラフ一覧
     */

    public static List<MonitoringReportInfo> executeGetGraphImg(String datadogDevName, String groupid,String active_since, String active_till,List<MonitoringReportInfo> targetGraphList, String stimeStr, String period) {
        System.debug('**== executeGetGraphImg start ==**');
        ZabbixAPIRequester requester = new ZabbixAPIRequester(datadogDevName);

        HttpResponse res = requester.getToken();
        Map<String, Object> resMap;
        String token;
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            token = (String) resMap.get('result');
            if (String.isBlank(token)) throw new ZabbixAPIException('トークンの取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('トークンの取得に失敗しました。');
        }
        //グラフIDからグラフイメージを取得する
        system.debug('**== グラフイメージを取得する ==**');
        String zbxSessionValue = null;  // ZABBIX=60の場合のみ使用
        if(requester.zabbixVersion == 'Zabbix60'){
            HttpResponse webloginres = requester.webLogin();
             // クッキー情報を取り出す（レスポンスヘッダから）
             List<String> responseHeaderKeys = webloginres.getHeaderKeys();
             
             // レスポンスヘッダーのキーをループ処理
             for (String headerKey : responseHeaderKeys) {
                if (headerKey.equalsIgnoreCase('Set-Cookie')) {
                    // Set-Cookieヘッダーの値を取得
                    String cookieHeader = webloginres.getHeader(headerKey);
                    // セミコロンで分割して複数のクッキーを取得
                    String[] cookies = cookieHeader.split(';');
                    // zbx_sessionの値を探す
                    for (String cookie : cookies) {
                        if (cookie.trim().toLowerCase().startsWith('zbx_session=')) {
                            zbxSessionValue = cookie.trim().substring('zbx_session='.length());
                            break;
                        }
                    }
                    if (zbxSessionValue != null) {
                        // 必要なクッキーが見つかった場合、ループを抜ける
                        break;
                    }
                }
            }
        }

        for(MonitoringReportInfo targerGaphInfo:targetGraphList){
            for(MonitoringReportInfo.Graph g: targerGaphInfo.graphList){
                // TODO Zabbix22 不具合対応 modify by 2024/5/14
                HttpResponse resGraph = new HttpResponse();
                // if (requester.zabbixVersion != 'Zabbix22') {
                if (requester.zabbixVersion == 'Zabbix22') {
                    resGraph = requester.getGraphImg2(g.graphid, token, stimeStr, period);
                    // resGraph = requester.getGraphImg(g.graphid, token, active_since, active_till);
                }else if(requester.zabbixVersion == 'Zabbix60'){
                    // クッキー値を確認
                    if (zbxSessionValue != null) {
                        System.debug('zbx_session value: ' + zbxSessionValue);
                        resGraph = requester.getGraphImgAtWeblogin(g.graphid, zbxSessionValue, active_since, active_till);
                    } else {
                        System.debug('zbx_session cookie not found in the response headers.');
                    }

                } else {
                    // resGraph = requester.getGraphImg2(g.graphid, token, stimeStr, period);
                    resGraph = requester.getGraphImg(g.graphid, token, active_since, active_till);
                }
                g.graphImage = resGraph.getBodyAsBlob();
                g.graphImageEncode = EncodingUtil.base64Encode(g.graphImage);
            }
        }
        // ログアウト
        executeLogout(requester, token);
        
        return targetGraphList;

    }
    /**
     * リソースCSVを取得する
     * 
     * @param datadogDevName Zabbixアカウント情報.カスタムメタデータレコード名
     * @param groupid ZabbixグループID
     * @return AWSリソース情報一覧
     */
    public static String executeGetHistory(String datadogDevName, String groupid,Set<String> paraItemids,Datetime active_since, Datetime active_till) {
        System.debug('**== executeGetHistory start ==**');
        ZabbixAPIRequester requester = new ZabbixAPIRequester(datadogDevName);
        HttpResponse res = requester.getToken();
        Map<String, Object> resMap;
        String token;
        String resutlCSV = '';
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            token = (String) resMap.get('result');
            if (String.isBlank(token)) throw new ZabbixAPIException('トークンの取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('トークンの取得に失敗しました。');
        }
        List<MonitoringReportInfo> monitoringReportInfoList = new List<MonitoringReportInfo>();
        
        Set<Integer> history = new Set<Integer>{0,3,1,2,4};
        for (Integer his:history){
            // ItemIdと期間指定でHistoryを取得する
            res = requester.getHistory(paraItemids, token, active_since.getTime() / 1000, active_till.getTime() / 1000, his);
            system.debug('**== historyを取得する ==**');
            if (res.getStatusCode() == STATUS_CODE_200) {
                resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
                if (errorMap <> null) throw new ZabbixAPIException('CSV情報の取得に失敗しました。');
            } else {
                throw new ZabbixAPIException('CSV情報の取得に失敗しました。');
            }
            System.debug('**== resMap => ' + resMap);
            System.debug('**== resMap.get(result) => ' + resMap.get('result'));
            List<Object> resultList = (List<Object>) resMap.get('result');
            if (!resultList.isEmpty()) {break;}
        }
        resutlCSV = JsonToCsvConverter.convertJsonToCsv(resMap);
        
        // ログアウト
        executeLogout(requester, token);

        return resutlCSV;

    }

    /**
     * ホストIDをキーに障害情報を取得する
     * 
     * @param datadogDevName Zabbixアカウント情報.カスタムメタデータレコード名
     * @param selectAwsResourcesMap 選択したAWSリソース情報一覧
     * @return 障害情報一覧
     */
    public static List<ProblemReportInfo> executeGetProblems(String datadogDevName, Map<String, String> selectAwsResourcesMap) {
        // トークンを取得
        ZabbixAPIRequester requester = new ZabbixAPIRequester(datadogDevName);
        HttpResponse res = requester.getToken();
        Map<String, Object> resMap;
        String token;
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            token = (String) resMap.get('result');
            if (String.isBlank(token)) throw new ZabbixAPIException('トークンの取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('トークンの取得に失敗しました。');
        }

        Set<String> hostIds = new Set<String>();
        if(selectAwsResourcesMap.size() > 0 ){
            for(String hostid:selectAwsResourcesMap.keySet()){
                hostIds.add(hostid);
            }
        }

        // ② ホストID（複数）からイベントID、障害情報（複数）を取得する
        res = requester.getProblem(hostIds, token);
        if (res.getStatusCode() == STATUS_CODE_200) {
            resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
            if (errorMap <> null) throw new ZabbixAPIException('AWSリソース情報一覧の取得に失敗しました。');
        } else {
            throw new ZabbixAPIException('AWSリソース情報一覧の取得に失敗しました。');
        }
        //障害情報リスト
        List<ProblemReportInfo> problemReportInfoList = new List<ProblemReportInfo>();
        List<Object> problems = (List<Object>) resMap.get('result');  
        for (Object problemElement : problems) {
            Map<String, Object> resultMap = (Map<String, Object>)problemElement;
            
            ProblemReportInfo problemReportInfo = new ProblemReportInfo();          
            problemReportInfo.triggerId = (String) resultMap.get('triggerid');
            problemReportInfo.description = (String) resultMap.get('description');
            problemReportInfo.priority = (String) resultMap.get('priority');
            problemReportInfo.lastchange = Long.valueOf((String)resultMap.get('lastchange'));
            
            List<Object> hostList = (List<Object>) resultMap.get('hosts');

            Map<String, Object> hostsMap = (Map<String, Object>)hostList[0];
            problemReportInfo.host = (String) hostsMap.get('name');
            problemReportInfo.hostId = (String) hostsMap.get('hostid');
            problemReportInfo.maintenance_status = (String) hostsMap.get('maintenance_status');
            problemReportInfoList.add(problemReportInfo);
        }
        // problemReportInfoListを降順でソート
        ProblemReportInfo.sortList(problemReportInfoList, 'desc');
        return problemReportInfoList;
    }

    /**
     * AWSリソース情報一覧のレスポンスを表示用のリストに変換する
     * 
     * @param resultJson AWSリソース情報一覧のレスポンス
     * @return AWSリソース情報一覧
     */
    private static List<ZabbixAWSResource> convertAWSResourceResponseToList(Map<String, Object> resultJson) {

        List<ZabbixAWSResource> zabbixAWSResources = new List<ZabbixAWSResource>();

        List<Object> resAWSResources = (List<Object>) resultJson.get('result');

        for (Object resAWSResource : resAWSResources) {
            Map<String, Object> tmp = (Map<String, Object>) resAWSResource;
// ホスト表示名を優先表示する 2023/7/27 kikuchi
            String hostName = (String)tmp.get('name') == '' ? (String)tmp.get('host') : (String)tmp.get('name');
            // ZabbixAWSResource zAWSResource = new ZabbixAWSResource((String) tmp.get('hostid'), (String) tmp.get('host'));
            ZabbixAWSResource zAWSResource = new ZabbixAWSResource((String) tmp.get('hostid'), hostName);
// ホスト表示名を優先表示する 2023/7/27 kikuchi
        zabbixAWSResources.add(zAWSResource);
        }
        return zabbixAWSResources;
    }

    /**
     * メンテナンス一覧のレスポンスを表示用のリストに変換する
     * 
     * @param resultJson AWSリソース情報一覧のレスポンス
     * @return メンテナンス一覧
     */
    private static List<ZabbixMaintenance> convertMaintenanceResponseToList(Map<String, Object> resultJson) {

        List<ZabbixMaintenance> zabbixMaintenances = new List<ZabbixMaintenance>();

        List<Object> resMaintenances = (List<Object>) resultJson.get('result');

        for (Object resMaintenance : resMaintenances) {
            
            Map<String, Object> tmpMaintenanceMap = (Map<String, Object>) resMaintenance;

            List<Object> hosts = (List<Object>) tmpMaintenanceMap.get('hosts');
            List<ZabbixAWSResource> zabbixAWSResources = new List<ZabbixAWSResource>();
            for (Object host : hosts) {
                Map<String, Object> tmpHostMap = (Map<String, Object>) host;
// ホスト表示名を優先表示する 2023/7/27 kikuchi
                String hostName = (String)tmpHostMap.get('name') == '' ? (String)tmpHostMap.get('host') : (String)tmpHostMap.get('name');
                // ZabbixAWSResource zAWSResource = new ZabbixAWSResource((String) tmpHostMap.get('hostid'), (String) tmpHostMap.get('host'));
                ZabbixAWSResource zAWSResource = new ZabbixAWSResource((String) tmpHostMap.get('hostid'), hostName);
// ホスト表示名を優先表示する 2023/7/27 kikuchi         
                zabbixAWSResources.add(zAWSResource);
            }

            List<Object> resTimeperiods = (List<Object>) tmpMaintenanceMap.get('timeperiods');

            if (resTimeperiods.size() > 0) {

                Map<String, Object> tmpTimeperiodMap = (Map<String, Object>) resTimeperiods[0];

                ZabbixMaintenance zMaintenance = new ZabbixMaintenance(
                    (String) tmpMaintenanceMap.get('maintenanceid'),
                    (String) tmpMaintenanceMap.get('name'),
                    zabbixAWSResources,
                    (String) tmpTimeperiodMap.get('timeperiod_type'),
                    Long.valueOf((String) tmpMaintenanceMap.get('active_since')),
                    Long.valueOf((String) tmpMaintenanceMap.get('active_till')),
                    Long.valueOf((String) tmpTimeperiodMap.get('start_time')),
                    Long.valueOf((String) tmpTimeperiodMap.get('period'))
                );
                zabbixMaintenances.add(zMaintenance);
            }
        }

        return zabbixMaintenances;
    }
    /**
     * ホストごとのグラフ情報を表示用のリストに変換し、Mapに格納して返す
     * 
     * @param resultJson ホストごとのグラフ情報のレスポンス
     * @return 表示用のリストをhostidをキーにし、グラフ情報をvalueとしたMap
     */
    private static Map<String,MonitoringReportInfo> convertGraphResponseToMap(Map<String, Object> resultJson) {

        System.debug('**== convertGraphResponseToMap start ==**');
        List<Object> resGraphResources = (List<Object>) resultJson.get('result');
        String hostid = '';
        Map<String,MonitoringReportInfo> hostMonitorinReportMap = new Map<String,MonitoringReportInfo>();

        for (Object resGraphResource : resGraphResources) {
            Map<String, Object> resultMap = (Map<String, Object>) resGraphResource;
            //ホスト情報の取得
            List<Object> hostList = (List<Object>) resultMap.get('hosts');
            Map<String, Object> hostsMap = (Map<String, Object>)hostList[0];
            if(String.isBlank(hostid) ||!hostid.equals( (String)hostsMap.get('hostid'))) {
                hostid = (String) hostsMap.get('hostid');
            }
            // System.debug('**==**== hostsMap =>' +hostsMap);
            //Mapにすでにこのホスト情報があるかどうか
            MonitoringReportInfo minfo = hostMonitorinReportMap.get(hostid);
            if(minfo==null){
                // minfo = new MonitoringReportInfo((String) hostsMap.get('host'), hostid);
                minfo = new MonitoringReportInfo((String) hostsMap.get('name'), hostid);
            }

            MonitoringReportInfo.Graph tempGraph = new MonitoringReportInfo.Graph();
            tempGraph.graphid =  (String) resultMap.get('graphid');
            tempGraph.graphName =  (String) resultMap.get('name');
            //item情報を取得する
            List<Object> itemList = (List<Object>) resultMap.get('items');
            for( Object tempitemMap:itemList){
                Map<String, Object> itemMap = (Map<String, Object>) tempitemMap;
                MonitoringReportInfo.Item tempItem = new MonitoringReportInfo.Item();
                tempItem.itemid= (String) itemMap.get('itemid');
                tempItem.itemname= (String) itemMap.get('name');
                tempItem.key= (String) itemMap.get('key_');                
                tempGraph.itemList.add(tempItem);
            }

            System.debug('**== tempGraph.itemList => ' + tempGraph.itemList);
            minfo.graphList.add(tempGraph);

            hostMonitorinReportMap.put(hostid,minfo);
        }
        for(MonitoringReportInfo monitorRInfo:hostMonitorinReportMap.values()){
            for(MonitoringReportInfo.Graph tempGraph:monitorRInfo.graphList){
                tempGraph.itemIds = '';
                tempGraph.itemNames = '';
                for(MonitoringReportInfo.Item tempItem: tempGraph.itemList){
                    if(String.isBlank(tempGraph.itemIds))tempGraph.itemIds = tempItem.itemid;
                    else tempGraph.itemIds += ',' + tempItem.itemid;
                    if(String.isBlank(tempGraph.itemNames))tempGraph.itemNames = tempItem.getItemNameCnv();
                    else tempGraph.itemNames += ',' + tempItem.getItemNameCnv();
                }
            }
        }
        System.debug('**== hostMonitorinReportMap => ' +hostMonitorinReportMap);
        return hostMonitorinReportMap;
    }

    public  static Integer allGraphListSize(Map<String,MonitoringReportInfo> hmmap){
        System.debug('**== convertGraphResponseToMap start ==**');
        Integer countgrapidsize = 0;
        for(String hostid:hmmap.keySet()){
            MonitoringReportInfo minfo = hmmap.get(hostid);
            countgrapidsize += minfo.graphList.size();
        }
        return countgrapidsize;
    }

    /**
     * ログアウト
     * 
     * @param requester リクエストクラス
     * @param token 認証トークン
     */
    private static void executeLogout(ZabbixAPIRequester requester, String token) {
        HttpResponse res = requester.logout(token);
        if (res.getStatusCode() == STATUS_CODE_200) {
            Map<String, Object> resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
            Map<String, Object> errorMap = (Map<String, Object>) resMap.get('error');
            if (errorMap <> null) throw new ZabbixAPIException('ログアウトに失敗しました。');
        } else {
            throw new ZabbixAPIException('ログアウトに失敗しました。');
        }
    }
}