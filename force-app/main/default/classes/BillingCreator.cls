/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 請求作成
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/16          T.Matsuda        New
 ********************************************************************************/
public without sharing class BillingCreator {

    // 締め月
    private static final String NEXT_MONTH = '翌月';

    // 請求対象年月
    private Date billingDate;
    // 契約Map
    private Map<Id, Contract__c> contractMap;
    // 契約明細リスト
    private List<ContractDetail__c> contractDetails;
    // 作成済みの請求ヘッダMap key:請求先ID＋請求先部署
    private Map<String, BillingHeader__c> existingBillingHeaderMap;

    /**
     * コンストラクタ
     * 
     * @param contractIds 契約IDリスト
     * @param billingDate 請求対象年月（1日）
     */
    public BillingCreator(List<Id> contractIds, Date billingDate) {
        this(contractIds, billingDate, new List<BillingHeader__c>());
    }

    /**
     * コンストラクタ
     * 
     * @param contractIds 契約IDリスト
     * @param billingDate 請求対象年月（1日）
     * @param createdBillingHeaders バッチで作成した請求ヘッダリスト
     */
    public BillingCreator(List<Id> contractIds, Date billingDate, List<BillingHeader__c> createdBillingHeaders) {
        this.billingDate = billingDate;
        // 契約取得
        getContracts(contractIds);
        // 契約明細取得
        getContractDetails(contractIds);
        // 作成済みの請求ヘッダMapを取得
        getExistingBillingHeaderMap(createdBillingHeaders);
    }

    /**
     * 契約取得
     * 
     * @param contractIds 契約ID
     */
    private void getContracts(List<Id> contractIds) {

        this.contractMap = new Map<Id, Contract__c>([
            SELECT Id
                , Name, Constitution_Common__c, Constitution_Common__r.Name, Account__c
                , Billing__c, Billing__r.Name, BillingPerson__c, BillingDepartment__c
                , PaymentCondition__c, Remarks__c, LatestBillingHeader__c
            FROM Contract__c
            WHERE Id IN :contractIds
            ORDER BY Id ASC
        ]);
    }

    /**
     * 契約明細取得
     * 
     * @param contractIds 契約IDリスト
     */
    private void getContractDetails(List<Id> contractIds) {

        this.contractDetails = [
            SELECT Id, Contract__c, Contract__r.ContractStartDate__c, Contract__r.ContractEndDate__c
                , No__c, LargeType__c, ProductName__c, ProductNameText__c, DetailType__c
                , UnitPrice__c, Quantity__c, Unit__c, Amount__c, TaxType__c, TaxPrice__c, Remarks__c
                , BillingStartMonth__c, SpecifiedMonth__c
            FROM
                ContractDetail__c
            WHERE
                Contract__c IN :contractIds
            ORDER BY Contract__c ASC, No__c ASC
        ];
    }

    /**
     * 作成済みの請求ヘッダMapを取得
     * 
     * @param createdBillingHeaders 作成済みの請求ヘッダリスト
     */
    private void getExistingBillingHeaderMap(List<BillingHeader__c> createdBillingHeaders) {

        this.existingBillingHeaderMap = new Map<String, BillingHeader__c>();

        for (BillingHeader__c header : createdBillingHeaders) {
            String key;
            if (String.isNotBlank(header.BillingDepartment__c)) {
                // key:請求先ID＋請求先部署＋請求年＋請求月
                key = header.BillingAccount__c + header.BillingDepartment__c;
            } else {
                // key:請求先ID＋契約ID＋請求年＋請求月
                key = header.BillingAccount__c + String.valueOf(header.Contract__c);
            }
            this.existingBillingHeaderMap.put(key, header);
        }
    }

    /**
     * 請求作成処理実行
     * 
     * @return 作成した請求ヘッダリスト
     */
    public List<BillingHeader__c> execute() {

        // 契約ID別に詳細＋課税区分でまとめた請求明細Mapを作成
        Map<Id, Map<String, List<BillingDetail__c>>> contactBillingDetailMap = createContactBillingDetailMap();

        // 請求先＋請求先部署または請求先＋契約IDでまとめた請求Mapを作成
        Map<String, List<Billing__c>> billingMap = createBillingMap(contactBillingDetailMap);

        // 請求ヘッダMapを作成
        Map<String, BillingHeader__c> billingHeaderMap = createBillingHeaderMap(billingMap);

        // 請求ヘッダ登録
        insert billingHeaderMap.values();

        // バッチで作成した請求ヘッダMapにPUT
        this.existingBillingHeaderMap.putAll(billingHeaderMap);

        // 請求ヘッダと請求の紐付け
        List<Billing__c> insertbillings = new List<Billing__c>();
        for (String key : billingMap.keySet()) {
            List<Billing__c> billings = billingMap.get(key);
            for (Billing__c billing : billings) {
                billing.BillingHeader__c = this.existingBillingHeaderMap.get(key).Id;
                insertbillings.add(billing);
            }
        }

        // 請求登録
        insert insertbillings;

        // 登録した請求を契約ID＋詳細＋課税区分でまとめた請求Mapを作成
        Map<String, Billing__c> insertBillingMap = new Map<String, Billing__c>();
        for (Billing__c billing : insertbillings) {
            String key = billing.Contract__c + billing.DetailType__c + billing.TaxType__c;
            insertBillingMap.put(key, billing);
            // 請求に関連する契約を取得し、最新請求ヘッダを設定 
            Contract__c contract = contractMap.get(billing.Contract__c);
            contract.LatestBillingHeader__c = billing.BillingHeader__c;
        }

        // 請求と請求明細の紐付け
        List<BillingDetail__c> insertBillingDetails = new List<BillingDetail__c>();
        for (Id contractId : contactBillingDetailMap.keySet()) {
            // 
            Map<String, List<BillingDetail__c>> billingDetailMap = contactBillingDetailMap.get(contractId);
            for (List<BillingDetail__c> details : billingDetailMap.values()) {
                String key = contractId + details[0].DetailType__c + details[0].TaxType__c;
                Billing__c billing = insertBillingMap.get(key);
                for (BillingDetail__c detail : details) {
                    detail.Billing__c = billing.Id;
                    insertBillingDetails.add(detail);
                }
            }
        }

        // 請求明細の登録
        insert insertBillingDetails;

        // 契約.最新請求ヘッダを更新
        update this.contractMap.values();

        // 登録した請求ヘッダを返却
        return billingHeaderMap.values();
    }

    /**
     * 請求明細作成
     * 
     * @return key:契約ID value:詳細＋課税区分をkeyにした請求明細Map
     */
    private Map<Id, Map<String, List<BillingDetail__c>>> createContactBillingDetailMap() {

        // key:契約ID value:詳細＋課税区分をkeyにした請求明細Map
        Map<Id, Map<String, List<BillingDetail__c>>> billingDetailMap = new Map<Id, Map<String, List<BillingDetail__c>>>();

        for (ContractDetail__c contractDetail : this.contractDetails) {
            // 契約明細が請求対象年月かどうかを判定する
            Boolean isBillable = hasBillable(contractDetail, this.billingDate);
            // 請求対象の契約明細の場合
            if (isBillable) {
                BillingDetail__c billingDetail = new BillingDetail__c();
                billingDetail.No__c = contractDetail.No__c;                           // No
                billingDetail.LargeType__c = contractDetail.LargeType__c;             // 区分
                billingDetail.ProductName__c = contractDetail.ProductName__c;         // 品名
                billingDetail.ProductNameText__c = contractDetail.ProductNameText__c; // 品名(テキスト)
                billingDetail.DetailType__c = contractDetail.DetailType__c;           // 詳細
                billingDetail.UnitPrice__c = contractDetail.UnitPrice__c;             // 単価
                billingDetail.Quantity__c = contractDetail.Quantity__c;               // 数量
                billingDetail.Unit__c = contractDetail.Unit__c;                       // 単位
                billingDetail.Amount__c = contractDetail.Amount__c;                   // 金額
                billingDetail.TaxType__c = contractDetail.TaxType__c;                 // 課税区分
                billingDetail.TaxPrice__c = contractDetail.TaxPrice__c;               // 消費税額
                billingDetail.Remarks__c = contractDetail.Remarks__c;                 // 【内部】備考

                // 契約ID
                Id key1 = contractDetail.Contract__c;
                // 詳細＋課税区分
                String key2 = contractDetail.DetailType__c + contractDetail.TaxType__c;
                
                if (billingDetailMap.containskey(key1)) {
                    Map<String, List<BillingDetail__c>> tmpMap1 = billingDetailMap.get(key1);
                    if (tmpMap1.containsKey(key2)) {
                        tmpMap1.get(key2).add(billingDetail);
                    } else {
                        tmpMap1.put(key2, new List<BillingDetail__c>{billingDetail});
                    }
                } else {
                    billingDetailMap.put(key1, new Map<String, List<BillingDetail__c>>{
                        key2 => new List<BillingDetail__c>{billingDetail}
                    });
                }
            }
        }

        return billingDetailMap;
    }

    /**
     * 請求作成
     * 
     * @param contactBillingDetailMap key:契約ID value:詳細＋課税区分をkeyにした請求明細Map
     * @return 請求先＋請求先部署でまとめた請求Map
     */
    private Map<String, List<Billing__c>> createBillingMap(Map<Id, Map<String, List<BillingDetail__c>>> contactBillingDetailMap) {

        Map<String, List<Billing__c>> billingMap = new Map<String, List<Billing__c>>();

        for (Id contractId : contactBillingDetailMap.keySet()) {
            Map<String, List<BillingDetail__c>> tmpMap = contactBillingDetailMap.get(contractId);
            Contract__c contract = this.contractMap.get(contractId);
            String billingMapKey;
            if (String.isNotBlank(contract.BillingDepartment__c)) {
                // key:請求先ID＋請求先部署
                billingMapKey = contract.Billing__c + contract.BillingDepartment__c;
            } else {
                // key:請求先ID＋契約ID
                billingMapKey = contract.Billing__c + String.valueOf(contract.Id);
            }
            // 契約別で詳細＋課税区分ごとに請求を作成
            for (String key : tmpMap.keySet()) {
                List<BillingDetail__c> billingDetails = tmpMap.get(key);
                String detailTypeLabel = getDetailTypeLabel(billingDetails[0].DetailType__c);
                String taxTypeLabel = getTaxTypeLabel(billingDetails[0].TaxType__c);
                // 請求作成
                Billing__c billing = new Billing__c();
                // 保守 No16 請求件名を契約名にする 
                //billing.Name = contract.Constitution_Common__r.Name + ' ' + detailTypeLabel + ' ' + taxTypeLabel; 
                billing.Name = contract.Name + ' ' + detailTypeLabel + ' ' + taxTypeLabel; 
                billing.Contract__c = contract.Id;
                billing.Account__c = contract.Account__c;
                billing.Constitution_Common__c = contract.Constitution_Common__c;
                billing.DetailType__c = billingDetails[0].DetailType__c;
                billing.TaxType__c = billingDetails[0].TaxType__c;
                billing.Remarks__c = contract.Remarks__c;
                // 請求先＋請求先部署でまとめた請求Mapへ追加
                if (billingMap.containsKey(billingMapKey)) {
                    billingMap.get(billingMapKey).add(billing);
                } else {
                    billingMap.put(billingMapKey, new List<Billing__c>{billing});
                }
            }
        }

        return billingMap;
    }

    /**
     * 請求ヘッダ作成
     * 
     * @param billingMap 請求先＋請求先部署でまとめた請求Map
     * @return 請求先＋請求先部署でまとめた請求ヘッダMap
     */
    private Map<String, BillingHeader__c> createBillingHeaderMap(Map<String, List<Billing__c>> billingMap) {

        Map<String, BillingHeader__c> billingHeaderMap = new Map<String, BillingHeader__c>();

        for (String key : billingMap.keySet()) {

            List<Billing__c> billings = billingMap.get(key);

            // 対象の請求ヘッダが作成されていない場合
            if (!this.existingBillingHeaderMap.containsKey(key)) {

                Contract__c contract = contractMap.get(billings[0].Contract__c);

                BillingHeader__c header = new BillingHeader__c();
                if (String.isNotBlank(contract.BillingDepartment__c)) {
                    header.Name = contract.Billing__r.Name;
                    header.Name += '（' + contract.BillingDepartment__c + '）';
                    header.Name += ' 様 ' + this.billingDate.year() + '年' + this.billingDate.month() + '月分ご請求';
                } else {
                    header.Name = contract.Name + ' ' + this.billingDate.year() + '年' + this.billingDate.month() + '月分ご請求';
                    header.Contract__c = contract.Id;
                }
                header.BillingAccount__c = contract.Billing__c;
                header.BillingContact__c = contract.BillingPerson__c;
                header.BillingDepartment__c = contract.BillingDepartment__c;
                header.BillingYear__c = String.valueOf(this.billingDate.year());
                header.BillingMonth__c = String.valueOf(this.billingDate.month());
                // 入金予定日
                if (String.isNotBlank(contract.PaymentCondition__c)) {
                    // 翌月
                    if (contract.PaymentCondition__c.contains(NEXT_MONTH)) {
                        header.PlannedDepositDate__c = this.billingDate.addMonths(2).addDays(-1);
                    }
                    // 翌々月 
                    else {
                        header.PlannedDepositDate__c = this.billingDate.addMonths(3).addDays(-1);
                    }
                }
                header.Remarks__c = System.Label.BILLING_CREATE_DEFAULT_REMARKS; // 固定値
                billingHeaderMap.put(key, header);
            }
        }

        return billingHeaderMap;
    }

    /**
     * 契約明細が請求対象年月かどうかを判定する
     * 
     * @param detail 契約明細
     * @param targetBillingDate 請求対象年月
     * @return 判定結果 TRUE:請求対象 FALSE:請求対象外
     */
    public static Boolean hasBillable(ContractDetail__c detail, Date targetBillingDate) {

        Boolean isBillable = false;

        // 請求対象年
        Integer targetBillingYear = targetBillingDate.year();
        // 請求対象月
        Integer targetBillingMonth = targetBillingDate.Month();

        // 契約終了日＞＝[請求対象年月]　OR　契約終了日＝NULL
        // 上記は呼び出し元で契約取得時の条件としている

        // 詳細＝初期費用
        if (detail.DetailType__c == Constants.DETAIL_TYPE_INICIAL_COST) {
            // 請求開始月＝契約開始月
            if (detail.BillingStartMonth__c == Constants.BILLING_START_MONTH) {
                // 契約.契約開始日の年＝[請求対象年月の年]　AND　契約.契約開始日の月＝[請求対象年月の月]
                Date contractStartMonth = detail.Contract__r.ContractStartDate__c;
                if (contractStartMonth <> null) {
                    if (contractStartMonth.year() == targetBillingYear && contractStartMonth.month() == targetBillingMonth) {
                        isBillable = true;
                    }
                }
            }
            // 請求開始月＝契約開始翌月
            else if (detail.BillingStartMonth__c == Constants.BILLING_START_NEXT_MONTH) {
                // 契約.契約開始日の翌月の年＝[請求対象年月の年]　AND　契約.契約開始日の翌月の月＝[請求対象年月の月]
                if (detail.Contract__r.ContractStartDate__c <> null) {
                    Date contractStartNextMonth = detail.Contract__r.ContractStartDate__c.addMonths(1);
                    if (contractStartNextMonth.year() == targetBillingYear && contractStartNextMonth.month() == targetBillingMonth) {
                        isBillable = true;
                    }
                }
            }
            // 請求開始月＝指定月
            else if (detail.BillingStartMonth__c == Constants.BILLING_START_SPECIFIED_MONTH) {
                // 契約明細.指定月の年＝[請求対象年月の年]　AND　契約明細.指定月の月＝[請求対象年月の月]
                Date specifiedMonth = detail.SpecifiedMonth__c;
                if (specifiedMonth <> null) {
                    if (specifiedMonth.year() == targetBillingYear && specifiedMonth.month() == targetBillingMonth) {
                        isBillable = true;
                    }
                }
            }
        }
        // 詳細＝月額費用
        else if (detail.DetailType__c == Constants.DETAIL_TYPE_MONTHLY_COST) {
            // 請求開始月＝契約開始月
            if (detail.BillingStartMonth__c == Constants.BILLING_START_MONTH) {
                if (detail.Contract__r.ContractStartDate__c <> null) {
                    // 契約.契約開始日の1日　＜＝　[請求対象年月]
                    Date contractStartDate = Date.newInstance(detail.Contract__r.ContractStartDate__c.year(), detail.Contract__r.ContractStartDate__c.month(), 1);
                    if (contractStartDate <= targetBillingDate) {
                        isBillable = true;
                    }
                }
            }
            // 請求開始月＝契約開始翌月
            else if (detail.BillingStartMonth__c == Constants.BILLING_START_NEXT_MONTH) {
                if (detail.Contract__r.ContractStartDate__c <> null) {
                    // 契約.契約開始日翌月の1日　＜＝　[請求対象年月]
                    Date contractStartDate = Date.newInstance(detail.Contract__r.ContractStartDate__c.year(), detail.Contract__r.ContractStartDate__c.month(), 1).addMonths(1);
                    if (contractStartDate <= targetBillingDate) {
                        isBillable = true;
                    }
                }
            }
            // 請求開始月＝指定月
            else if (detail.BillingStartMonth__c == Constants.BILLING_START_SPECIFIED_MONTH) {
                // 契約明細.指定月の1日　＜＝　[請求対象年月]
                Date specifiedMonth = detail.SpecifiedMonth__c;
                if (specifiedMonth <> null) {
                    Date specifiedDate = Date.newInstance(specifiedMonth.year(), specifiedMonth.month(), 1);
                    if (specifiedDate <= targetBillingDate) {
                        isBillable = true;
                    }
                }
            }
        }
        // 詳細＝年払い または スポット
        else if (detail.DetailType__c == Constants.DETAIL_TYPE_ANNUAL || detail.DetailType__c == Constants.DETAIL_TYPE_SPOT) {
            if (detail.BillingStartMonth__c == Constants.BILLING_START_SPECIFIED_MONTH) {
                // 契約明細.指定月の年＝[請求対象年月の年]　AND　契約明細.指定月の月＝[請求対象年月の月]
                Date specifiedMonth = detail.SpecifiedMonth__c;
                if (specifiedMonth <> null) {
                    if (specifiedMonth.year() == targetBillingYear && specifiedMonth.month() == targetBillingMonth) {
                        isBillable = true;
                    }
                }
            }
        }

        return isBillable;
    }

    /**
     * 詳細選択リスト項目のラベルを取得する
     * 
     * @param taxType 詳細選択リスト値(API名)
     * @return 詳細選択リスト値(ラベル名)
     */
    private String getDetailTypeLabel(String detailType) {

        String detailTypeLabel = '';

        if (detailType == Constants.DETAIL_TYPE_INICIAL_COST) {
            detailTypeLabel = '初期費用';
        } else if (detailType == Constants.DETAIL_TYPE_MONTHLY_COST) {
            detailTypeLabel = '月額費用';
        } else if (detailType == Constants.DETAIL_TYPE_ANNUAL) {
            detailTypeLabel = '年払い';
        } else if (detailType == Constants.DETAIL_TYPE_SPOT) {
            detailTypeLabel = 'スポット';
        }

        return detailTypeLabel;
    }

    /**
     * 課税区分選択リスト項目のラベルを取得する
     * 課税10%の場合は、件名に付与する文言がないため空となる
     * 
     * @param taxType 課税区分選択リスト値(API名)
     * @return 課税区分選択リスト値(ラベル名)
     */
    private String getTaxTypeLabel(String taxType) {

        String taxTypeLabel = '';

        if (taxType == Constants.TAX_TYPE_NO_TAX) {
            taxTypeLabel = '（非課税）';
        }

        return taxTypeLabel;
    }
}