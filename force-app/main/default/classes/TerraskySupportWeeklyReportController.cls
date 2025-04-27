/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Terraskyサポート週次レポートコントローラークラス
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/11     Kikuchi     新規作成
 * 2022/12     Kikuchi     GOMサポート対応
 ********************************************************************************/
public with sharing class TerraskySupportWeeklyReportController {
    /** ケースリスト */
    public List<TerraskySupport__c> caseList{get;set;}
    public Integer monthTotal {get; set;}
    /** SVE */
    public List<TerraskySupport__c> sveList{get;set;}
    public Integer sveMonthTotal {get; set;}
    /** OMLINE */
    public List<TerraskySupport__c> omlineList{get;set;}
    public Integer omlineMonthTotal {get; set;}
    /** SFDC */
    public List<TerraskySupport__c> sfdcList{get;set;}
    public Integer sfdcMonthTotal {get; set;}
    /** mitoco */
    public List<TerraskySupport__c> mitocoList{get;set;}
    public Integer mitocoMonthTotal {get; set;}
    /** 連携製品 */
    public List<TerraskySupport__c> dcsList{get;set;}
    public Integer dcsMonthTotal {get; set;}
    /** GOM */
    public List<TerraskySupport__c> gomList{get;set;}
    public Integer gomMonthTotal {get; set;}
    /** 血液製剤 */
    public List<TerraskySupport__c> jbpoList{get;set;}

    /** 先週From */
    public Date weekStart {get;set;}
    /** 先週To */
    public Date weekEnd {get;set;}
    /**
     * コンストラクタ
     */
    public TerraskySupportWeeklyReportController() {
        sveList    = new List<TerraskySupport__c>();
        omlineList = new List<TerraskySupport__c>();
        sfdcList   = new List<TerraskySupport__c>();
        mitocoList = new List<TerraskySupport__c>();
        dcsList    = new List<TerraskySupport__c>();
        jbpoList   = new List<TerraskySupport__c>();
        gomList    = new List<TerraskySupport__c>();
        
        TerraskySupport__c temp = new TerraskySupport__c();
        jbpoList.add(temp);
        jbpoList.add(temp);
        jbpoList.add(temp);

        monthTotal       = 0;
        sveMonthTotal    = 0;
        omlineMonthTotal = 0;
        sfdcMonthTotal   = 0;
        mitocoMonthTotal = 0;
        dcsMonthTotal    = 0;
        gomMonthTotal    = 0;        
    }

    /**
     * 実行
     */
    public void execute() {
        Date toDay = Date.today();
        weekStart = toDay.toStartofWeek().addDays(-7);
        weekEnd = toDay.toStartofWeek().addDays(-1);
        // サポート対応取得（週次 新規）
        caseList = [SELECT id, WorkTime__c, CaseCreateDate__c, CaseNo__c, Solution__c, SolutionCreateDate__c, Name, Cause__c, AccountName__c, ContactName__c, ProductType__c, PersonName__c, Status__c, SolutionType__c, InquiryID__c, InquiryType__c, ProductEdition__c FROM TerraskySupport__c WHERE CaseCreateDate__c = LAST_WEEK AND PersonName__c ='SKY365サポート担当' ORDER BY CaseNo__c];

        for (TerraskySupport__c c : caseList) {
            if (c.ProductType__c == 'SkyEditor') {
                sveList.add(c);
            } else if (c.ProductType__c == 'Salesforceライセンス') {
                sfdcList.add(c);
            } else if (c.ProductType__c == 'mitoco') {
                mitocoList.add(c);
            } else if (c.ProductType__c == 'DataSpider' || c.ProductType__c == 'DCSpider') {
                dcsList.add(c);
            } else if (c.ProductType__c == 'OMLINE-I' || c.ProductType__c == 'OMLINE-O') {
                omlineList.add(c);
            } else if (c.ProductType__c == 'GLOVIA OM') {
                gomList.add(c);
            }
        }

        // サポート対応取得（当月 累計）
        Date monthStart = weekStart.toStartOfMonth();
        List<TerraskySupport__c> monthCaseList = [SELECT id, WorkTime__c, CaseCreateDate__c, CaseNo__c, Solution__c, SolutionCreateDate__c, Name, Cause__c, AccountName__c, ContactName__c, ProductType__c, PersonName__c, Status__c, SolutionType__c, InquiryID__c, InquiryType__c, ProductEdition__c FROM TerraskySupport__c WHERE CaseCreateDate__c >=: monthStart AND CaseCreateDate__c <=: weekEnd AND PersonName__c ='SKY365サポート担当' ORDER BY CaseNo__c];
        for (TerraskySupport__c c : monthCaseList) {
            if (c.ProductType__c == 'SkyEditor') {
                sveMonthTotal++;
            } else if (c.ProductType__c == 'Salesforceライセンス') {
                sfdcMonthTotal++;
            } else if (c.ProductType__c == 'mitoco') {
                mitocoMonthTotal++;
            } else if (c.ProductType__c == 'DataSpider' || c.ProductType__c == 'DCSpider') {
                dcsMonthTotal++;
            } else if (c.ProductType__c == 'OMLINE-I' || c.ProductType__c == 'OMLINE-O') {
                omlineMonthTotal++;
            } else if (c.ProductType__c == 'GLOVIA OM') {
                gomMonthTotal++;
            }
        }
    }

}