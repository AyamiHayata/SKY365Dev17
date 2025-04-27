/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約作成
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/07          T.Matsuda        New
 ********************************************************************************/
public without sharing class ContractCreator {

    // 見積
    private Quote__c quote;
    // 見積明細
    private List<QuoteDetail__c> quoteDetails;

    /**
     * コンストラクタ
     * 
     * @param quoteId 見積ID
     */
    public ContractCreator(Id quoteId) {
        getQuote(quoteId);
        getQuoteDetails(quoteId);
    }

    /**
     * 見積取得
     * 
     * @param quoteId 見積ID
     */
    private void getQuote(Id quoteId) {

        List<Quote__c> quotes = [
            SELECT Id, Name
                , BillAccount__c, BillingContact__c
                , EndUser__c, ConstitutionCommon__c, PaymentCondition__c, IsOrder__c, ConstitutionCommon__r.Name
            FROM Quote__c
            WHERE Id = :quoteId
            LIMIT 1
        ];

        if (quotes.size() > 0) this.quote = quotes[0];
    }

    /**
     * 見積明細取得
     * 
     * @param quoteId 見積ID
     */
    private void getQuoteDetails(Id quoteId) {
        this.quoteDetails = [
            SELECT Id
                , No__c, LargeType__c, ProductName__c, ProductNameText__c, DetailType__c, UnitPrice__c, Quantity__c
                , Unit__c, Amount__c, TaxType__c, TaxPrice__c
            FROM QuoteDetail__c
            WHERE Quote__c = :quoteId
            ORDER BY No__c ASC
        ];
    }

    /**
     * 契約作成処理実行
     */
    public Contract__c execute() {

        SavePoint sp = Database.setSavepoint();

        // 契約
        Contract__c contract;

        try {
            // 対象案件の既存契約を取得
            List<Contract__c> contracts = getContract(this.quote.ConstitutionCommon__c);
            Decimal existingDetailCount = 0;
            // 既存契約がある場合
            if (contracts.size() > 0) {
                contract = contracts[0];
                List<ContractDetail__c> contractDetails = getContractDetails(contract.Id);
                if (contractDetails.size() > 0) {
                    existingDetailCount = contractDetails[0].No__c;
                }
            }
            // 既存契約がない場合
            else {
                // 新規契約作成
                contract = createContract();
                insert contract;
            }
            // 契約明細作成
            List<ContractDetail__c> contractDetails = createContractDetails(contract.Id, existingDetailCount);
            insert contractDetails;
            // 見積の受注フラグ更新
            updateQuote();
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getStackTraceString());
            throw(e);
        }

        return contract;
    }

    /**
     * 対象案件の既存契約を取得
     * 
     * @param 案件情報ID
     */
    private List<Contract__c> getContract(Id constitutionId) {

        List<Contract__c> contracts = [
            SELECT ID FROM Contract__c
            WHERE Constitution_Common__c = :constitutionId
            LIMIT 1
        ];

        return contracts;
    }

    /**
     * 既存契約の契約明細を取得
     * 
     * @param 契約ID
     */
    private List<ContractDetail__c> getContractDetails(Id contractId) {

        List<ContractDetail__c> contractDetails = [
            SELECT Id, No__c FROM ContractDetail__c
            WHERE Contract__c = :contractId
            ORDER BY No__c DESC
            LIMIT 1
        ];

        return contractDetails;
    }

    /**
     * 契約作成
     * 
     * @return 契約
     */
    private Contract__c createContract() {

        Contract__c contract = new Contract__c();
        contract.Name = this.quote.ConstitutionCommon__r.Name;                   // 案件名
        contract.Billing__c = this.quote.BillAccount__c;                         // 請求先（商流）
        contract.BillingPerson__c = this.quote.BillingContact__c;                // 請求先担当者
        contract.Account__c = this.quote.EndUser__c;                             // 取引先
        contract.Constitution_Common__c = this.quote.ConstitutionCommon__c;      // 案件情報
        contract.PaymentCondition__c = this.quote.PaymentCondition__c;           // お支払条件
        contract.IsInitCreate__c = True;                                         // 初回作成フラグON

        return contract;
    }

    /**
     * 契約明細作成
     * 
     * @param contractId 契約ID
     * @return 契約明細リスト
     */
    private List<ContractDetail__c> createContractDetails(Id contractId, Decimal existingDetailCount) {
        
        List<ContractDetail__c> contractDetails = new List<ContractDetail__c>();

        for (QuoteDetail__c quoteDetail : this.quoteDetails) {
            ContractDetail__c contractDetail = new ContractDetail__c();
            contractDetail.Contract__c = contractId;                            // 契約
            contractDetail.No__c = quoteDetail.No__c + existingDetailCount;     // No
            contractDetail.LargeType__c = quoteDetail.LargeType__c;             // 区分
            contractDetail.ProductName__c = quoteDetail.ProductName__c;         // 品名
            contractDetail.ProductNameText__c = quoteDetail.ProductNameText__c; // 品名(テキスト)
            contractDetail.DetailType__c = quoteDetail.DetailType__c;           // 詳細
            contractDetail.UnitPrice__c = quoteDetail.UnitPrice__c;             // 単価
            contractDetail.Quantity__c = quoteDetail.Quantity__c;               // 数量
            contractDetail.Unit__c = quoteDetail.Unit__c;                       // 単位
            contractDetail.Amount__c = quoteDetail.Amount__c;                   // 金額
            contractDetail.TaxType__c = quoteDetail.TaxType__c;                 // 課税区分
            contractDetail.TaxPrice__c = quoteDetail.TaxPrice__c;               // 消費税額
            contractDetails.add(contractDetail);
        }

        return contractDetails;
    }

    /**
     * 見積の受注フラグ更新
     */
    private void updateQuote() {
        this.quote.IsOrder__c = true;
        update this.quote;
    }
}