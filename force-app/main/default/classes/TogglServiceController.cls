/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2020 SKY365 Inc. All Rights Reserved.
 *
 * Togglサービスから日報に紐づく稼働を取得する。
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/06     kikuchi     新規作成
 ********************************************************************************/
public class TogglServiceController {

    private DailyReport__c dailyReport;
    private String authorizationHeader = null;
    
    /**
     * コンストラクタ
     *
     * @param StandardController コントローラー
     */
    public TogglServiceController(ApexPages.StandardController stdController) {
        this.dailyReport = (DailyReport__c)stdController.getRecord();
        system.debug('kik_id' + this.dailyReport.id);
    }

    /**
     * コンストラクタ
     *
     */
    public TogglServiceController() {
    }

    /**
     * ワーククラス
     *
     */
    public class Work {
        public String tid;
        public String project;
        public String client;
        public String title;
        public Integer workTime;

        /**
         * コンストラクタ
         *
         */
        public Work() {
            tid = '';
            project = '';
            client = '';
            title = '';
            workTime = 0;
        }
    }

    /**
     * 初期処理
     *
     */
    public PageReference initAction() {
        // Toggl連携済チェック
        User u = [SELECT id, YammerToken__c, togglAPI_Workspace__c, togglAPI_Token__c FROM USER WHERE id =:UserInfo.getUserId()];
        if (String.isEmpty(u.togglAPI_Workspace__c) || String.isEmpty(u.togglAPI_Token__c)) {
            PageReference initPage = new PageReference( '/apex/InitialSetting');
            return initPage;
        }

        // 日報情報取得
        DailyReport__c daily = retrieveDailyReport();
        // トークン、ワークスペースが取得できない場合はエラー画面へ

        // togglAPI呼び出し
        List<Work> workList = getWorkTimes(daily);

        // 明細書き込み
        if (workList.size() > 0) {
            detailReportIns(this.dailyReport.id, workList);
        }
        // 再描画 /lightning/r/DailyReport__c/a2D0l000000Mho4EAC/view
        PageReference page = new PageReference( '/lightning/r/DailyReport__c/' + this.dailyReport.id + '/view');
        update daily;
        return page;
    }

    /**
     * 日報情報取得
     * 
     * @return 日報情報
     *
     */
    private DailyReport__c retrieveDailyReport() {
        return [SELECT Id, User__r.togglAPI_Token__c, User__r.togglAPI_Workspace__c, 
                       User__r.Email, RegistDate__c, shift__c FROM DailyReport__c 
                       WHERE id =:this.dailyReport.id];
    } 

    /**
     * Togglから稼働を取得
     * 
     * @param DailyReport__c 日報情報
     * @return  稼働リスト
     */
    public List<Work> getWorkTimes(DailyReport__c daily) {
        // シフトが"遅,夜"は日跨ぎのため２日分を取得する。
        Date fromDate = (daily.shift__c == '遅' || daily.shift__c == '夜'? daily.RegistDate__c.adddays(-1) : daily.RegistDate__c);
        Date toDate = daily.RegistDate__c;
     
        Blob headerValue = Blob.valueOf(daily.User__r.togglAPI_Token__c + ':api_token');
        authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        HttpResponse res = new HttpResponse();
        // 2021/11/09 togglドメイン名変更対応 
        //res = RestApiHttpRequest2('https://toggl.com/reports/api/v2/details?workspace_id=' + daily.User__r.togglAPI_Workspace__c + 
        res = RestApiHttpRequest2('https://api.track.toggl.com/reports/api/v2/details?workspace_id=' + daily.User__r.togglAPI_Workspace__c + 
                                    '&since=' + String.valueOf(fromDate) + 
                                    '&until=' + String.valueOf(toDate) + 
                                    '&user_agent=' + daily.User__r.Email); 
        Map<String, Object> resultJSON = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
        List<Object> data = (List<Object>) resultJSON.get('data');
        List<Work> works = new List<Work>();
        for (Object element : data) {
            Work work = new Work();
            Map<String, Object> eMap = (Map<String, Object>)element;
            // idを取得
            work.tid = String.valueOf(eMap.get('id'));
            // プロジェクト
            work.project = (String)eMap.get('project');
            // クライアント
            work.client = (String)eMap.get('client');
            // タイトルを取得
            work.title = (String)eMap.get('description');
            // ワークタイム
            work.workTime = (Integer)eMap.get('dur');
            works.add(work);
        }
        return works;
    }

    /**
     * 日報明細作成
     * 
     * @param Id 日報ID
     * @param List<Work> 稼働リスト
     */
    public void detailReportIns(Id reportId, List<Work> wList) {
        // 登録済のものは除外
        SET<String> togglIdSET = new SET<String>();
        for (Work w :wlist) {
            togglIdSET.add(w.tid);
        }
        List<DailyReportDetail__c> chkDetailList =[SELECT id, Tid__c FROM DailyReportDetail__c WHERE Tid__c =: togglIdSET];
        SET<String> togglIdNoneInsSet = new SET<String>();
        for (DailyReportDetail__c d : chkDetailList) {
            togglIdNoneInsSet.add(d.Tid__c);
            system.debug('kik_noneIns:' + d.Tid__c);
        }
        // 日報明細Upsert
        List<DailyReportDetail__c> detailList = new List<DailyReportDetail__c>();
        for (Work w :wlist) {
            //if (!togglIdNoneInsSet.contains(w.tid)) {
                DailyReportDetail__c detail = new DailyReportDetail__c();
                detail.Tid__c      = w.tid;
                detail.Title__c    = w.title;
                detail.Client2__c   = w.client;
                detail.Project2__c  = w.project;
                Decimal wTimed = Decimal.valueOf(w.workTime);
                detail.WorkTime__c = wTimed / 3600000;
                detail.DailyReport__c = reportId;
                detail.Code__c = getWorkCode(w.title);
                detailList.add(detail);
            //}
        }
        Schema.SObjectField f = DailyReportDetail__c.Fields.Tid__c;
        Database.upsert(detailList,f,false);
    }

    /**
     * コード取得
     *
     * @param String タイトル
     * @return コード
     */
    private String getWorkCode(String arg) {
        // Zendeckコード取得
        Pattern zendeskCode = Pattern.compile('^#\\d{1,7}');        
        Matcher zendeskCodeMatch = zendeskCode.matcher(arg);
        if (zendeskCodeMatch.find()){
            return zendeskCodeMatch.group().trim();
        }
        // サポートデスクコード取得
        Pattern supportCode = Pattern.compile('^[0-9]*');
        Matcher supportCodeMatch = supportCode.matcher(arg);
        if (supportCodeMatch.find()){
            return supportCodeMatch.group().trim();
        }
        return '';
    }

    /**
     * HttpRequest(JSON)
     *
     * @param String エンドポイント
     * @return HTTPレスポンス
     */
    private HttpResponse RestApiHttpRequest2(String endPoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setMethod('GET');

        Http http = new Http();
        return  http.send(request);
    }
}