/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約作成コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/07          T.Matsuda        New
 ********************************************************************************/
public without sharing class CreateContractController {

    // 見積
    private Quote__c quote;
    // 契約
    public Contract__c contract { get; set; }

    /**
     * コンストラクタ
     */
    public CreateContractController(ApexPages.StandardController stdController) {
        // 見積を取得
        this.quote = (Quote__c) stdController.getRecord();
    }

    /**
     * 初期処理
     */
    public Pagereference initAction() {
        // 見積を取得
        this.quote = [SELECT Id, IsOrder__c, ApprovalStatus__c, ConstitutionCommon__c FROM Quote__c WHERE Id = :this.quote.Id LIMIT 1];

        // 未承認の場合
        if (this.quote.ApprovalStatus__c != 'approved') {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, '未承認のため契約を作成できません。'));
                return null;
        }
        // 既に受注フラグが立っている場合
        if (this.quote.IsOrder__c) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, '既に当見積から契約が作成されています。'));
            // 見積.案件情報に関連する契約を取得
            List<Contract__c> contracts = getContract(this.quote.ConstitutionCommon__c);
            if (contracts.size() > 0) this.contract = contracts[0];
            return null;
        }
        
        try {
            // 契約作成処理実行
            this.contract = new ContractCreator(this.quote.Id).execute();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }

        // 作成した契約の詳細画面に遷移する
        return new Pagereference('/' + contract.Id);
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
     * 契約画面を表示
     */
    public PageReference moveContractAction() {
        return new Pagereference('/' + this.contract.Id);
    }
}