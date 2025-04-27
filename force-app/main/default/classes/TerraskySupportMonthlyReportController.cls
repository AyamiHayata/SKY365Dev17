/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * Terraskyサポート月次レポートコントローラークラス
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/11     Kikuchi     新規作成
 * 2022/09     Kikuchi     ケース開始から解決までの時間計測処理追加
 * 2022/12     Kikuchi     GOMサポート対応
 * 2023/5      Kikuhci     長期化ケース一覧表示対応
 * 2024/5      Kikuchi     SFDCライセンスサポートエスカケース自動反映
 * 2024/11     Sasaki      mitocoの種別に「mitoco Mobile」を追加
 * 2024/11     Sasaki      GOMのエスカレーション判別処理追加
 * 2025/02     Sasaki      mitocoの種別に「mitoco 申請」を追加
 ********************************************************************************/
public with sharing class TerraskySupportMonthlyReportController {
    /** 作成年 */
    public String createYear{get;set;}

    /** 作成月 */
    public String createMonth{get;set;}

    /** 対象製品 */
    public String productType{get;set;}

    /** 対応ケース総数 */
    public Integer totalCaseCount{get;set;}

    /** ユーザ確認中 */
    public Integer userPenddingCount{get;set;}

    /** クローズ */
    public Integer closeCount{get;set;}

    /** メーカー確認中 */
    public Integer makerPenddingCount{get;set;}

    /** 営業確認中 */
    public Integer salesPenddingCount{get;set;}

    /** 製品開発問い合わせ数 */
    public Integer escalationCount{get;set;}

    /** うち妥当と考えられる問い合わせ起票数 */
    public Integer escalationValidCount{get;set;}

    /** SKY３６５自己解決数 */
    public Integer selfCloseCount{get;set;}

    /** テラスカイ対応数 */
    public Integer tettaskyTotalCaseCount{get;set;}

    /** ケース総数に対する自己解決率 */
    public Decimal selfCloseRate{get;set;}

    /** ケース総数に対する④を含めた解決率 */
    public Decimal selfCloseInValidRate{get;set;}

    /** ケース総数に対するソリューションHit率 */
    public Decimal totalCaseCoountInSolutionHitRate{get;set;}

    /** 自己解決数に対するソリューションHit率 */
    public Decimal selfCloseInSolutionHitRate{get;set;}

    /** 当月問い合わせ対応時間 */
    public Decimal totalWorkTimeThisMonth{get;set;}

    /** 継続問い合わせ対応時間 */
    public Decimal workTimeLastMonth{get;set;}

    /** 手順修正・打ち合わせ等 */
    public Decimal workTimeEtc{get;set;}

    /** 合計対応総時間 */
    public Decimal totalSumworkTime{get;set;}

    /** 初回応答率（２営業日以内） */
    public Decimal firstContactRate{get;set;}
    
    /** ケースリスト */
    public List<TerraskySupport__c> caseList{get;set;}

    /** 長期化ケースリスト */
    public List<TerraskySupport__c> longTimeCaseList{get;set;}

    /** 長期化ケース数 */
    public Decimal longTimeCaseCount{get;set;}

    /** 長期化ケース数 表示設定 */
    public Boolean isLongTimeCaseCountView{get;set;}

    /** 長期化ケースリスト 表示設定 */
    public Boolean isLongTimeCaseListView{get;set;}

    /** クライアント名から対象製品を特定 */
    private static Map<String, Set<String>> productName = new Map<String, Set<String>> {
        'サービスデスク-SVE' => new Set<String>{'SkyEditor'},
        'サービスデスク-SFDC' => new Set<String>{'Salesforceライセンス'},
        'サービスデスク-DCS' => new Set<String>{'DataSpider', 'DCSpider'},
        'サービスデスク-mitoco' => new Set<String>{'mitoco'},
        'サービスデスク-GOM' => new Set<String>{'GLOVIA OM'},
        'サービスデスク-OMLINE' => new Set<String>{'OMLINE-I', 'OMLINE-O'}     
    };

    /** 製品問い合わせ種別カウント用クラス */
    public class Product {
        public String name{get;set;}
        public Integer value{get;set;}
        public Product(String arg, Integer val) {
            this.name = arg;
            this.value = val;
        }
    }

    /** 製品問い合せ種別 */
    public List<Product> inquiryTypeList;

    /** 製品エディション */
    public List<Product> productEditionList;

    /**
     * コンストラクタ
     */
    public TerraskySupportMonthlyReportController(ApexPages.StandardController stdController) {
    
    }

    /**
     * コンストラクタ
     */
    public TerraskySupportMonthlyReportController() {
        createYear = String.valueOf(system.today().addMonths(-1).year());
        createMonth = String.valueOf(system.today().addMonths(-1).month());
        productType = 'サービスデスク-SVE';
        init();
    }

    /**
     * 初期処理
     */
    private void init() {
        totalCaseCount = 0;
        userPenddingCount = 0;
        closeCount = 0;
        makerPenddingCount = 0;
        salesPenddingCount = 0;
        escalationCount = 0;
        escalationValidCount = 0;
        selfCloseCount = 0;
        tettaskyTotalCaseCount = 0;
        selfCloseRate = 0;
        selfCloseInValidRate = 0;
        totalCaseCoountInSolutionHitRate = 0;
        selfCloseInSolutionHitRate = 0;
        totalWorkTimeThisMonth = 0;
        workTimeLastMonth = 0;
        workTimeEtc = 0;
        totalSumworkTime = 0;
        firstContactRate = 0;
        longTimeCaseCount = 0;
        isLongTimeCaseCountView = true;
        isLongTimeCaseListView = true;

        inquiryTypeList = new List<Product> {
            new Product('SVE: [低]標準機能について', 0),
            new Product('SVE: [低]料金やサービス概要について', 0),
            new Product('SVE: [中]機能追加、機能改善要望', 0),
            new Product('SVE: [中]困っている事象から、推奨機能の提案', 0),
            new Product('SVE: [中]Apex拡張、JS/CSS等の標準サポート対象外機能の問い合わせ', 0),
            new Product('SVE: [中]お客様の設定変更、ご操作による動作変更内容確認', 0),
            new Product('SVE: [中]Salesforce機能に関係した質問', 0),
            new Product('SVE: [高]お客様環境に酔要ログイン', 0),
            new Product('SVE: その他', 0),
            new Product('', null),
            new Product('', null),
            new Product('', null),
            new Product('', null)
        };

        productEditionList = new List<Product> {
            new Product('掲示板', 0),
            new Product('ToDo', 0),
            new Product('トーク', 0),
            new Product('カレンダー', 0),
            new Product('文書管理', 0),
            new Product('ワークフロー', 0),
            new Product('アドレス帳', 0),
            new Product('モバイルアプリ(iOS/Android)', 0),
            new Product('mitoco Mobile（iOS/Andorid用統合アプリ）',0),
            new Product('mitoco Work 経費', 0),
            new Product('mitoco Work 勤怠', 0),
            new Product('mitoco 申請',0),
            new Product('その他', 0)
        };       
    }
    /**
     * 戻る
     */
    public Pagereference back() {
        return new PageReference('/apex/TerraskySupportMonthlyReportCreate');
    }
    /**
     * 実行
     */
    public Pagereference execute() {
        init();
        // 日報集計情報取得
        Date startDate = Date.newInstance(Integer.valueOf(createYear), Integer.valueOf(createMonth), 1);
        Date endDate = startDate.addMonths(1);
        List<AggregateResult> resultList = [SELECT Project2__c, SUM(WorkTime__c) WorkTimeSum FROM DailyReportDetail__c WHERE Client2__c =: productType AND DailyReport__r.RegistDate__c >=: startDate AND DailyReport__r.RegistDate__c <: endDate GROUP BY Project2__c];
        Map<String, Decimal> workTimeMap = new Map<String, Decimal>();
        for (AggregateResult result : resultList) {
            workTimeMap.put((String)result.get('Project2__c'), (Decimal)result.get('WorkTimeSum'));
        }      
        // サポート対応取得
        caseList = [SELECT id, WorkTime__c, CaseCreateDate__c, CaseNo__c, Solution__c, SolutionCreateDate__c, Name, Cause__c, AccountName__c, ContactName__c, ProductType__c, PersonName__c, Status__c, SolutionType__c, InquiryID__c, InquiryType__c, ProductEdition__c, FixTime__c, SFDCCaseNumber__c, CaseOwnerName__c FROM TerraskySupport__c WHERE DAY_ONLY(convertTimezone(CaseCreateDate__c)) >=: startDate AND DAY_ONLY(convertTimezone(CaseCreateDate__c)) <: endDate AND ProductType__c IN :productName.get(productType) AND PersonName__c ='SKY365サポート担当' ORDER BY CaseNo__c];
        
        // ステータスカウント
        Map<String, Integer> countMapByStatus = new Map<String, Integer>();
        // 製品開発問い合わせ数
        Integer inquiryCount = 0;
        
        // 既存ソリューション数
        Integer solutionCount = 0;
        
        // サポート対応合計工数
        Decimal supportWorkTimeTotal = 0;

        // Sky365サポート担当ケース総数
        Integer sky365TotalCaseCount = 0;
        
        for (TerraskySupport__c result : caseList) {
            // ステータスカウント
            if (countMapByStatus.containsKey(result.Status__c)) {
                countMapByStatus.put(result.Status__c, countMapByStatus.get(result.Status__c) + 1);
            } else {
                countMapByStatus.put(result.Status__c, 1);
            }
            // ソリューション
            if (result.SolutionCreateDate__c != null) {
                result.Solution__c = result.SolutionCreateDate__c < startDate ? '既存' : '新規';
            }

            // 製品開発問い合わせ
            if (result.inquiryID__c != null) {
                result.SolutionType__c = 'エスカレーション';
                result.Solution__c = result.Solution__c == '既存' ? '' : result.Solution__c;
            } else {
                if (productType == 'サービスデスク-SFDC' && result.SFDCCaseNumber__c != null) {
                    result.SolutionType__c = 'エスカレーション';
                    result.Solution__c = result.Solution__c == '既存' ? '' : result.Solution__c;                    
                } else if (productType == 'サービスデスク-GOM' && result.CaseOwnerName__c == 'GLOVIA OMサポート'){
                    result.SolutionType__c = 'エスカレーション';
                    result.Solution__c = result.Solution__c == '既存' ? '' : result.Solution__c;
                }
            }
            if (result.SolutionType__c == 'エスカレーション') {
                inquiryCount ++;       
            }

            if (result.Solution__c == '既存' && result.SolutionType__c == null) {
                result.SolutionType__c = 'ソリューション';
            }
            if (result.SolutionType__c == 'ソリューション') {
                solutionCount ++;
            }

            // 自己解決種別
            result.SolutionType__c = result.SolutionType__c == null ? 'ドキュメント/検証' : result.SolutionType__c;
            
            // サポート対応合計工数
            supportWorkTimeTotal += null2Zero(result.WorkTime__c);
            
            // Sky365サポート担当ケース総数
            if (result.PersonName__c == 'Sky365サポート担当') {
                // Sky365サポート担当ケース総数
                sky365TotalCaseCount ++;
            } else {
                // テラスカイ対応数
                tettaskyTotalCaseCount ++;
                result.SolutionType__c = '-';
            }

            // 製品問い合せ種別カウント
            for (Product p : inquiryTypeList) {
                if (p.name == result.InquiryType__c) {
                    p.value ++;
                }
            }

            // 製品エディションカウント
            for (Product p : productEditionList) {
                if (p.name == result.ProductEdition__c) {
                    p.value ++;
                }
            }

        }
        /** ヘッダー情報作成 */ 
        
        // 対応ケース総数
        totalCaseCount = caseList.size();

        // ユーザ確認中
        userPenddingCount = null2Zero(countMapByStatus.get('ユーザ確認中'));

        // クローズ
        closeCount = null2Zero(countMapByStatus.get('クローズ'));

        // メーカー確認中
        makerPenddingCount = null2Zero(countMapByStatus.get('メーカー確認中'));

        // 営業確認中
        salesPenddingCount = null2Zero(countMapByStatus.get('営業対応中'));

        // 製品開発問い合わせ数
        escalationCount = inquiryCount;

        // うち妥当と考えられる問い合わせ起票数
        escalationValidCount = inquiryCount;

        // SKY３６５自己解決数 (Sky365サポート担当ケース総数 - 製品開発問い合わせ数)
        selfCloseCount = sky365TotalCaseCount - escalationCount;

        if (totalCaseCount > 0) {
            // ケース総数に対する自己解決率 (スカイ３６５自己解決数 / 対応ケース総数)
            selfCloseRate = Decimal.valueOf(selfCloseCount) / Decimal.valueOf(totalCaseCount) * 100;
            selfCloseRate = selfCloseRate.setScale(2, System.RoundingMode.HALF_UP);

            // ケース総数に対する④を含めた解決率 ((SKY３６５自己解決数 + うち妥当と考えられる問い合わせ起票数 + テラスカイ対応数) / 対応ケース総数)
            selfCloseInValidRate = Decimal.valueOf((selfCloseCount + escalationValidCount + tettaskyTotalCaseCount)) / Decimal.valueOf(totalCaseCount) * 100;
            selfCloseInValidRate = selfCloseInValidRate.setScale(2, System.RoundingMode.HALF_UP);

            // ケース総数に対するソリューションHit率 (既存ソリューション / 対応ケース総数)
            totalCaseCoountInSolutionHitRate = Decimal.valueOf(solutionCount) / Decimal.valueOf(totalCaseCount) * 100;
            totalCaseCoountInSolutionHitRate = totalCaseCoountInSolutionHitRate.setScale(2, System.RoundingMode.HALF_UP);
        }
        // 自己解決数に対するソリューションHit率 (既存ソリューション / SKY３６５自己解決数)
        if (selfCloseCount > 0) {
            selfCloseInSolutionHitRate =  Decimal.valueOf(solutionCount) / Decimal.valueOf(selfCloseCount) * 100;
            selfCloseInSolutionHitRate = selfCloseInSolutionHitRate.setScale(2, System.RoundingMode.HALF_UP);
        }
        
        // 当月問い合わせ対応時間
        totalWorkTimeThisMonth = supportWorkTimeTotal;
        totalWorkTimeThisMonth = totalWorkTimeThisMonth.setScale(2, System.RoundingMode.HALF_UP);

        // 継続問い合わせ対応時間 (当月日報工数 - 当月問い合わせ対応時間)
        workTimeLastMonth = null2Zero(workTimeMap.get('1_問い合わせ')) - totalWorkTimeThisMonth;
        workTimeLastMonth = workTimeLastMonth.setScale(2, System.RoundingMode.HALF_UP);

        // 手順修正・打ち合わせ等
        for (String key : workTimeMap.keySet()) {
            if (key != '1_問い合わせ') {
                workTimeEtc += workTimeMap.get(key); 
            }
        }
        // 合計対応総時間
        workTimeEtc = workTimeEtc.setScale(2, System.RoundingMode.HALF_UP);
        totalSumworkTime = totalWorkTimeThisMonth + workTimeLastMonth + workTimeEtc;
        
        // 初回応答率（２営業日以内）
        firstContactRate = 100;

        // 長期化ケース一覧 2023/5/17
        // 長期サポートケース取得
        longTimecaseList = [SELECT id, WorkTime__c, CaseCreateDate__c, CaseNo__c, Solution__c, SolutionCreateDate__c, Name, Cause__c, AccountName__c, ContactName__c, ProductType__c, PersonName__c, Status__c, SolutionType__c, InquiryID__c, InquiryType__c, ProductEdition__c, FixTime__c, CaseResponseDate__c, LongTimeReason__c, MailUpdateDate__c FROM TerraskySupport__c WHERE DAY_ONLY(convertTimezone(MailUpdateDate__c)) >=: startDate AND DAY_ONLY(convertTimezone(MailUpdateDate__c)) <: endDate AND ProductType__c IN :productName.get(productType) AND PersonName__c ='SKY365サポート担当' AND Status__c = 'クローズ' AND CaseResponseDate__c >= 11 ORDER BY CaseNo__c];
        longTimeCaseCount = longTimecaseList.size();
        isLongTimeCaseCountView = (productType == 'サービスデスク-SFDC' || productType == 'サービスデスク-GOM') ? false : true;
        isLongTimeCaseListView = (isLongTimeCaseCountView && longTimeCaseCount > 0) ? true : false;
system.debug(isLongTimeCaseCountView);
system.debug(longTimeCaseCount);
system.debug(longTimeCaseCount > 0);
system.debug(isLongTimeCaseCountView && longTimeCaseCount > 0);
system.debug(isLongTimeCaseListView);


        String reportURL = '/apex/TerraskySupportMonthlyReport';
        PageReference pageRef = new PageReference(reportURL);
        return pageRef;

    }

    /**
     * Null To Zero
     *
     * @return Decimal
     */
    private Decimal null2Zero(Decimal dec) {
        return dec == null ? 0 : dec;
    }

    /**
     * Null To Zero
     *
     * @return Integer
     */
    private Integer null2Zero(Integer i) {
        return i == null ? 0 : i;
    }

    /**
     * 対象製品option作成
     *
     * @return 対象製品optionリスト
     */
    public List<SelectOption> getProductTypes() {
        List<SelectOption> options = new List<SelectOption>();
        for (String key : productName.keySet()) {
            options.add(new SelectOption(key, key));
        }
        return options;
    }

    /**
     * 対象製品取得
     *
     * @return 対象製品
     */
    public String getProduct() {
        system.debug('kik_product:' + String.join(new List<String>(productName.get(productType)), ','));
        return String.join(new List<String>(productName.get(productType)), ',');
    }

    /**
     * 月option作成
     *
     * @return 月optionリスト
     */
    public List<SelectOption> getMonths() {
        List<SelectOption> options = new List<SelectOption>();
        for (Integer i = 1; i <= 12; i++) {
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    /**
     * 製品種別取得
     *
     * @return Product 製品情報
     */
    private Product getProductLine(Integer idx) {
        if (productType == 'サービスデスク-SVE') {
            return inquiryTypeList.get(idx);
        } else if (productType == 'サービスデスク-mitoco') {
            return productEditionList.get(idx);
        } else {
            return new Product('', null);
        }
    }

    public Product getProductLine1() { return getProductLine(0); }
    public Product getProductLine2() { return getProductLine(1); }
    public Product getProductLine3() { return getProductLine(2); }
    public Product getProductLine4() { return getProductLine(3); }
    public Product getProductLine5() { return getProductLine(4); }
    public Product getProductLine6() { return getProductLine(5); }
    public Product getProductLine7() { return getProductLine(6); }
    public Product getProductLine8() { return getProductLine(7); }
    public Product getProductLine9() { return getProductLine(8); }
    public Product getProductLine10() { return getProductLine(9); }
    public Product getProductLine11() { return getProductLine(10); }
    public Product getProductLine12() { return getProductLine(11); }
    public Product getProductLine13() { return getProductLine(12); }

    /**
     * 保存処理
     *
     */
    public PageReference save(){
        update caseList;
        update longTimecaseList;
        execute();
        return null;
    }
}