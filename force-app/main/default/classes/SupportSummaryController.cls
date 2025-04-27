/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * サポートサマリページコントローラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/01     kikuchi     新規作成
 * 2022/12     kikuchi     GOMサポート対応
 * 2024/12     sasaki      5営業日対応の件数カウント追加
 ********************************************************************************/
public with sharing class SupportSummaryController {

    /* 受け渡し用 */
    public List<Residual> tempList {get;set;}

    /* 製品問い合わせ情報クラス */
    public class Residual {
        public String name {get; set;}
        public Integer newCnt {get; set;}
        public String newBkColor {get; set;}
        public Integer continuationCnt {get; set;}
        public String continuationBkColor {get; set;}
        public Integer day5AlertCnt {get; set;}
        public String day5AlertBkColor {get; set;}

        public Residual (String arg, Integer val1, Integer val2, Integer val3) {
            name = arg;
            newCnt = val1;
            newBkColor = '';
            continuationCnt = val2;
            continuationBkColor = '';
            day5AlertCnt = val3;
            day5AlertBkColor = '';
        }
    }

     /* 製品問い合わせ情報リストクラス 初期化 */   
    public List<Residual> residualList = new List<Residual>{
        new Residual('SVE'   , 0, 0, 0),
        new Residual('SFDC'  , 0, 0, 0),
        new Residual('DCS'   , 0, 0, 0),
        new Residual('mitoco', 0, 0, 0),
        new Residual('OMLINE', 0, 0, 0),
        new Residual('GOM'   , 0, 0, 0)
    };

    /**
     * コンストラクタ
     */    
    public SupportSummaryController() {

    }

    /**
     * 初期処理
     */
    public void initAction() {
        // 新規ケースサマリ
        List<AggregateResult> resultList = [select count(id) cnt , ProductType__c from TerraskySupport__c where Status__c = '新規' AND LastModifiedDate = LAST_N_DAYS:30 AND SupportContractFlag__c = true group by ProductType__c order by ProductType__c];
        for (AggregateResult result : resultList) {
            if ((String)result.get('ProductType__c') == 'SkyEditor') {
                addNewCount('SVE', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'Salesforceライセンス') {
                addNewCount('SFDC', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'mitoco') {
                addNewCount('mitoco', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'GLOVIA OM') {
                addNewCount('GOM', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'DataSpider' ||
                       (String)result.get('ProductType__c') == 'DCSpider') {
                addNewCount('DCS', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'OMLINE-I' ||
                       (String)result.get('ProductType__c') == 'OMLINE-O') {
                addNewCount('OMLINE', (Integer)result.get('cnt'));
            }
        }

        // 既存ケース回答有サマリ
        resultList = [select count(id) cnt, ProductType__c from TerraskySupport__c where ReceivingEmail__c = true AND PersonName__c = 'Sky365サポート担当' AND LastModifiedDate = LAST_N_DAYS:30 group by ProductType__c];
        for (AggregateResult result : resultList) {
            if ((String)result.get('ProductType__c') == 'SkyEditor') {
                addContinuationCount('SVE', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'Salesforceライセンス') {
                addContinuationCount('SFDC', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'mitoco') {
                addContinuationCount('mitoco', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'GLOVIA OM') {
                addContinuationCount('GOM', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'DataSpider' ||
                       (String)result.get('ProductType__c') == 'DCSpider') {
                addContinuationCount('DCS', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'OMLINE-I' ||
                       (String)result.get('ProductType__c') == 'OMLINE-O') {
                addContinuationCount('OMLINE', (Integer)result.get('cnt'));
            }
        }

        // 5営業日対応サマリ
        resultList = [select count(id) cnt, ProductType__c from TerraskySupport__c where Status__c = 'ユーザ確認中' AND Day5Flg__c = true group by ProductType__c];
        for (AggregateResult result : resultList) {
            if ((String)result.get('ProductType__c') == 'SkyEditor') {
                add5DayAlertCount('SVE', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'Salesforceライセンス') {
                add5DayAlertCount('SFDC', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'mitoco') {
                add5DayAlertCount('mitoco', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'GLOVIA OM') {
                add5DayAlertCount('GOM', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'DataSpider' ||
                       (String)result.get('ProductType__c') == 'DCSpider') {
                add5DayAlertCount('DCS', (Integer)result.get('cnt'));
            } else if ((String)result.get('ProductType__c') == 'OMLINE-I' ||
                       (String)result.get('ProductType__c') == 'OMLINE-O') {
                add5DayAlertCount('OMLINE', (Integer)result.get('cnt'));
            }
        }
        tempList = residualList;
    }

    /**
     * 新規件数カウント
     */
    private void addNewCount(String ProductName, Integer val) {
        for (Residual element: residualList) {
            if (element.name == ProductName) {
                element.newCnt += val;
                element.newBkColor = getBkColor(element.newCnt);
            } 
        }
    }

    /**
     * 回答件数カウント
     */   
    private void addContinuationCount(String ProductName, Integer val) {
        for (Residual element: residualList) {
            if (element.name == ProductName) {
                element.continuationCnt += val;
                element.continuationBkColor = getBkColor(element.continuationCnt);
            } 
        }        
    }

    /*
     * 5営業日件数カウント
     */
    private void add5DayAlertCount(String ProductName, Integer val) {
        for (Residual element: residualList) {
            if (element.name == ProductName) {
                element.day5AlertCnt += val;
                element.day5AlertBkColor = getBkColor(element.day5AlertCnt);
            } 
        }        
    } 

    /**
     * 件数別色分け
     */   
    private String getBkColor(Integer val) {
        if (val >= 3) {
            return '#FF0000';
        } else if (val >= 1) {
            return '#FFCC00';
        }
        return '#FFFFFF';
    }    
}