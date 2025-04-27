/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2020 SKY365 Inc. All Rights Reserved.
 *
 * Yammerサービスに日報を投稿するコントローラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/06     kikuchi     新規作成
 * 2025/04     souma       改行コードが含まれる場合の投稿不具合修正
 ********************************************************************************/
public class YammerServiceController {

    private DailyReport__c dailyReport;
    private String authorizationHeader = null;    
    private String api_token = null;
    public Static String MESSAGE = 'https://www.yammer.com/api/v1/messages.json';

    /**
     * コンストラクタ
     *
     */
    public YammerServiceController(ApexPages.StandardController stdController) {
        this.dailyReport = (DailyReport__c)stdController.getRecord();
    }

    
    /**
     * 初期処理
     *
     */
    public PageReference initAction() {
        // Yammer連携済チェック
        User u = [SELECT id, YammerToken__c, togglAPI_Workspace__c, togglAPI_Token__c FROM USER WHERE id =:UserInfo.getUserId()];
        api_token = u.YammerToken__c;
        if (String.isEmpty(api_token)) {
            PageReference initPage = new PageReference( '/apex/InitialSetting');
            return initPage;
        }

        // 日報取得
        DailyReport__c daily = selectDailyReport();
        //if (!daily.isRegist__c) {
            execute();
            daily.isRegist__c = true;
            update daily;
        //}
        PageReference thisPage = new ApexPages.StandardController(dailyReport).view();
        thisPage.setRedirect(true);
        return thisPage;
    }
    
    /**
     * メイン処理
     *
     */
    private void execute() {
        // Yammer 認証文字列を生成
        authorizationHeader = 'Bearer ' + api_token;
        
        String json = createJsonMessage();
        HttpResponse res = new HttpResponse();
        res = RestApiHttpRequest(json, MESSAGE);
    }
 
    private String createJsonMessage() {
        return '{"body": "' + createDailyReportLength2() + '","group_id": 12159717}'; // 本番
        //return '{"body": "' + createDailyReportLength() + '","group_id": 9975727}'; // 検証
    }

    /**
     * 送信用JSON文字列生成２
     * @return JSON文字列
     */
    public String createDailyReportLength2() {
        // 日報取得
        DailyReport__c daily = selectDailyReport();
        // 日報明細取得
        List<DailyReportDetail__c> detailList = selectDailyDetailList();
        // mitocoの予定を取得
        List<Event> eventList = selectEventList(daily.user__c);

        Map<String, Set<String>> tasks = new Map<String, Set<String>>();
        for (DailyReportDetail__c detail : detailList) {
            if (tasks.containsKey(detail.Client2__c)) {
                tasks.get(detail.Client2__c).add(null2Val(detail.Project2__c) + ' ' + null2Val(detail.Title__c));
            } else {
                Set<String> titleSet = new Set<String>();
                titleSet.add(null2Val(detail.Project2__c) + ' ' + null2Val(detail.Title__c));
                tasks.put(detail.Client2__c, titleSet);
            }
        }
        
        // セクション１（ヘッダ） 
        String sec1Str = '日報 シフト:(' + daily.Shift__c + ') ' + daily.name;
        
        sec1Str = sec1Str + '\\n'; // １行空け
        // セクション２（日次業務）
        String sec2Str = '\\n■ 本日の作業内容\\n';
        String sec2_1Str = '';
        for (String key : tasks.keySet()) {
            sec2_1Str = sec2_1Str + null2Val(key) + '\\n';
            Set<String> titleSet = tasks.get(key);
            for (String title : titleSet) {
                sec2_1Str = sec2_1Str + '・' + title + '\\n';
            }
            sec2_1Str = sec2_1Str + '\\n'; // １行空け
        }
        sec2Str = sec2Str + (String.isEmpty(sec2_1Str) ? 'ありません。\\n\\n' : sec2_1Str);

        // セクション４（翌日の作業予定）
        String sec4Str = '■ 翌日の作業予定\\n';
        sec4Str = sec4Str + (String.isEmpty(daily.TomorrowWorkschedule__c) ? '記載なし。' : daily.TomorrowWorkschedule__c.replace('\\', '\\\\').replace('\r\n', '\\n'));
        sec4Str = sec4Str + '\\n'; // １行空け        
        sec4Str = sec4Str + '\\n■ mitocoの予定\\n';
        sec4Str = sec4Str + (eventList.size() == 0 ? 'ありません。': '');
        for (Event event : eventList) {
            sec4Str = sec4Str + event.SUBJECT + '\\n';
        }

        sec4Str = sec4Str + '\\n'; // １行空け
        // セクション５（日報情報）
        String sec5Str = '\\n■ 困っていること\\n';
        sec5Str = sec5Str + (String.isEmpty(daily.Introuble__c)? 'ありません。': daily.Introuble__c.replace('\\', '\\\\').replace('\r\n', '\\n'));
        sec5Str = sec5Str + '\\n'; // １行空け
        sec5Str = sec5Str + '\\n■ 所感\\n';
        sec5Str = sec5Str + (String.isEmpty(daily.Impressions__c)? 'ありません。': daily.Impressions__c.replace('\\', '\\\\').replace('\r\n', '\\n'));
        String arg = sec1Str + sec2Str + sec4Str + sec5Str;
        return arg.replace('"', '\\"');
    }

    /**
     * 日報を取得
     * @return DailyReport__c 日報
     */
    private DailyReport__c selectDailyReport() {
        DailyReport__c daily = [SELECT id, Introuble__c, Impressions__c, TomorrowWorkschedule__c, user__c, 
        User__r.name, Condition__c, Name, Shift__c, isRegist__c FROM DailyReport__c WHERE id =:this.dailyReport.id];
        return daily;
    }

    /**
     * 日報明細を取得
     * @return List<DailyReportDetail__c> 日報明細
     */
    private List<DailyReportDetail__c> selectDailyDetailList() {
        List<DailyReportDetail__c> details = [SELECT id, Tid__c, Client2__c, Title__c, Project2__c,
        DailyReport__c, Name FROM DailyReportDetail__c WHERE DailyReport__c =:this.dailyReport.id Order BY Client2__c];
        return details;
    }

    /**
     * mitocoの予定を取得
     * @return List<Event> 日報明細
     */
    private List<Event> selectEventList(Id ownerId) {
        List<Event> events = [SELECT SUBJECT, OWNER.LASTNAME, OWNER.FIRSTNAME, 
        STARTDATETIME, ENDDATETIME, LOCATION FROM EVENT WHERE ACTIVITYDATE IN(TODAY, TOMORROW) AND STARTDATETIME >:Datetime.now()
        AND OWNERID =:ownerId ORDER BY STARTDATETIME];
        return events;
    }



    /**
     * HttpRequest(JSON)
     * @param String 送信パラメータ
     */
    private HttpResponse RestApiHttpRequest(String prams, String endPoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);        
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setBody(prams);

        Http http = new Http();
        return  http.send(request);
    }
    /**
     * null2Val
     */
    private String null2Val (String arg) {
        return String.isEmpty(arg) ? '' : arg;
    }
}