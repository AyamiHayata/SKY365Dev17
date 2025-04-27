/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Zendesk連携バッチForSWXZendesk
 * 【実行例】
 *      ZendeskForSwxBatch batch = new ZendeskForSwxBatch();
 *      Database.executeBatch(batch,200);
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/08     Kikuchi     新規作成
 * 2021/09     Kikuchi     Zendesk抽出条件変更
 *                           ・tags "スカイ３６５対応チケット:awsサポート"を追加
 *                           ・created 5日前 ⇒ updated 5日前
 *
 * 2022/03     Kikuchi     Zendesk抽出条件変更
 *              　　　　　　　・tags "スカイ３６５対応チケット" ⇒ "incident-level:high"に変更
 *                           ・updated 5日前 ⇒ 2日前
 ********************************************************************************/
public without sharing class ZendeskForSwxBatch extends Zendesk2SalesforceBatchMain {

   /**
    * コンストラクタ
    *
    */
    public ZendeskForSwxBatch() {
        // endPoint
        Date searchDate = Date.today().addDays(-2);
        endPoint = 'https://serverworks-msp.zendesk.com/api/v2/search.json?query=type:ticket';
        endPoint = endPoint + '%20updated>=' + String.valueOf(searchDate);
        endPoint = endPoint + '%20tags:"incident-level:high"%20tags:"スカイ３６５対応チケット:awsサポート"';
    }

    /**
     * Zendeskチケット取得
     * @param String endPoint
     *
     */  
    public override void getTickets(String endPoint) {
        HttpResponse res = new HttpResponse();
        res = super.restApiHttpRequest(endPoint);
        Map<String, Object> resultJSON = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
        List<Object> results = (List<Object>) resultJSON.get('results');
        for (Object element : results) {
            Ticket ticket = new Ticket();
            Map<String, Object> eMap = (Map<String, Object>)element;
            ticket.id = '#' + String.valueOf(eMap.get('id'));
            ticket.organization_id = String.valueOf(eMap.get('organization_id'));
            List<Object> tagList = (List<Object>)eMap.get('tags');
            for (Object o :tagList) {
                ticket.tags.add((String)o);
            }
            super.tickets.put(ticket.id, ticket);
        }
        // 次ページ
        String nextPage = (String) resultJSON.get('next_page');
        if (!String.isEmpty(nextPage)) {
            getTickets(nextPage);
        }        
    } 

    /**
     * Zendesk接続情報取得
     *
     */  
    public override void getZendeskAccount() {
        ZendeskAccount__mdt mdt = [SELECT loginid__c, password__c FROM ZendeskAccount__mdt WHERE DeveloperName = 'SWXZendesk'];
        super.loginid = mdt.loginid__c;
        super.password = mdt.password__c;
    }
    /**
     * 変換マッピング情報取得
     *
     */  
    public override void readMappingInfo() {
        super.shubetsuMapping = super.castListToMap([SELECT MasterLabel, TogglProjectName__c FROM SWX_ShubetsuMapping__mdt]);
        super.shoryuMapping = super.castListToMap([SELECT MasterLabel, TogglClientName__c FROM SWX_ShoryuMapping__mdt]);
    }

    /**
     * 実行2
     *
     */ 
    public override void execute2(Database.BatchableContext BC, List<sObject> scope) {
        for(sObject target : scope) {
            DailyReportDetail__c dailyReportDetail = (DailyReportDetail__c)target;
            Ticket targetTicket = null;
            // 案件の紐付け
            if (dailyReportDetail.ConstitutionCommon__c == null && dailyReportDetail.Code__c != null) {
                if (tickets.containsKey(dailyReportDetail.Code__c)) {
                    targetTicket = tickets.get(dailyReportDetail.Code__c);
                    if (super.constitutionCommon.containsKey(targetTicket.organization_id)) {
                        dailyReportDetail.ConstitutionCommon__c = super.constitutionCommon.get(targetTicket.organization_id);
                        dailyReportDetail.Log__c = '';
                    } else {
                        dailyReportDetail.Log__c = '案件情報に対象組織がない。' + targetTicket.organization_id;
                    }
                } else {
                    dailyReportDetail.Log__c = 'チケットに指定タグが無い可能性。';
                }
            }
            // Clientの紐付け
            if (dailyReportDetail.Client2__c == null && tickets.containsKey(dailyReportDetail.Code__c)) {
                targetTicket = tickets.get(dailyReportDetail.Code__c);
                if (getClientName(targetTicket) != null) {
                    dailyReportDetail.Client2__c = getClientName(targetTicket);
                }
            }
            // Projectの紐付け
            if (dailyReportDetail.Project2__c == null && tickets.containsKey(dailyReportDetail.Code__c)) {
                targetTicket = tickets.get(dailyReportDetail.Code__c);
                if (getClientName(targetTicket) != null) {
                    dailyReportDetail.Project2__c = getProjectName(targetTicket);
                }
            }

        }
        update scope;
    }

    /**
     * タグに登録されている商流からクライアントを特定する。
     * @param Ticket targetTicket
     * @return クライアント名
     */ 
    private String getClientName(Ticket targetTicket) {
        for (String key : super.shoryuMapping.keyset()) {
            if (targetTicket.tags.contains(key)) {
                SWX_ShoryuMapping__mdt mdt = (SWX_ShoryuMapping__mdt)super.shoryuMapping.get(key);
                return mdt.TogglClientName__c;
            }
        } 
        return null;
    }

    /**
     * タグに登録されている種別からプロジェクトを特定する。
     * @param Ticket targetTicket
     * @return プロジェクト名
     */ 
    private String getProjectName(Ticket targetTicket) {
        for (String key : super.shubetsuMapping.keyset()) {
            if (targetTicket.tags.contains(key)) {
                SWX_ShubetsuMapping__mdt mdt = (SWX_ShubetsuMapping__mdt)super.shubetsuMapping.get(key);
                return mdt.TogglProjectName__c;
            }
        } 
        return null;
    }
}