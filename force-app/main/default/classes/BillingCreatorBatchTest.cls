/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 共通関数テストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/07/28          R.Matsui          New
 ********************************************************************************/
@isTest
private class BillingCreatorBatchTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
    }
    /**
     * 【対象】
     * start,execute,finish
     * 【条件】
     * 取引先件loopNum、案件3*loopNum件(3件/1取引先)、契約3*loopNum件、契約明細9*loopNum件
     * 既存請求ヘッダexistedHederNum件
     * 【結果】
     * 下記が作成される
     * 請求明細(loopNum-existedHederNum)*9件
     * 請求(loopNum-existedHederNum)*6件
     * 請求ヘッダ loopNum-existedHederNum 件
     * ※税率の違いで1案件あたりに作成される3請求明細が2請求にぶら下がる
     * ※作成済み請求ヘッダに紐づく契約からは請求が作成されない
     */
    @isTest
    public static void test_start(){
        // データ準備
        Integer loopNum = 10;
        Integer existedHederNum = 5;
        
        // 取引先　loopNumの値分作成
        List<Account> insAccList = new List<Account>();
        for(Integer step = 0;step< loopNum;step++){
            Account addAcc = TestUtil.createAccount();
            addAcc.Name = 'テスト取引先' + step;
            insAccList.add(addAcc);
        }
        insert insAccList;

        // 取引先責任者　取引先と1:1になるように作成
        List<Contact> insCtList = new List<Contact>();
        Map<Id,Contact> accConMap = new Map<Id,Contact>();
        for(Integer step = 0;step< loopNum;step++){
            Contact addCt = TestUtil.createContact(insAccList.get(step));
            addCt.FirstName = 'テスト' + step;
            addCt.LastName = '取引先責任者' + step;
            addCt.Department = '取引先部署'+step;
            insCtList.add(addCt);
            accConMap.put(insAccList.get(step).Id,addCt);
        }
        insert insCtList;

        // 案件情報　取引先1件につき3件作成
        List<Constitution_Common__c> insConstitutionList = new List<Constitution_Common__c>();
        Map<Id,Constitution_Common__c> accConstitutionMap = new Map<Id,Constitution_Common__c>();
        for(Integer step = 0;step< loopNum;step++){
            Constitution_Common__c constitution1 = TestUtil.createConstitution(insAccList.get(step));
            constitution1.Name = 'テスト案件' + step +'-1';
            insConstitutionList.add(constitution1);
            Constitution_Common__c constitution2 = TestUtil.createConstitution(insAccList.get(step));
            constitution2.Name = 'テスト案件' + step +'-2';
            insConstitutionList.add(constitution2);
            Constitution_Common__c constitution3 = TestUtil.createConstitution(insAccList.get(step));
            constitution3.Name = 'テスト案件' + step +'-3';
            accConstitutionMap.put(insAccList.get(step).Id,constitution3);
            insConstitutionList.add(constitution3);
        }
        insert insConstitutionList;

        // 見積　案件情報と1:1で作成
        List<Quote__c> insQuoteList = new List<Quote__c>();
        for(Integer step = 0; step<insConstitutionList.size();step++){
            Constitution_Common__c cmn = insConstitutionList.get(step);
            Quote__c quote = TestUtil.createQuote(cmn.Account__c, cmn);
            quote.ApprovalStatus__c = 'approved';
            insQuoteList.add(quote);
        }
        insert insQuoteList;

        // 見積明細　見積もりと1:1で作成
        List<QuoteDetail__c> insQuoteDetailList = new List<QuoteDetail__c>();
        for(Integer step = 0; step<insQuoteList.size();step++){
            QuoteDetail__c quoteDetail = TestUtil.createQuoteDetail(insQuoteList.get(step));
            insQuoteDetailList.add(quoteDetail);
        } 
        insert insQuoteDetailList;
        
        // 契約　案件情報と1:1で作成
        List<Contract__c> insContractList = new List<Contract__c>();
        Map<Id,Contract__c> constitutionConMap = new Map<Id,Contract__c>();
        Date today = Date.today();
        Date contractStartDate = Date.newInstance(today.year(), today.Month(), 1).addMonths(-1);
        for(Integer step = 0; step < insConstitutionList.size();step++){
            Contract__c contract = TestUtil.createContract(insConstitutionList.get(step).Account__c, insConstitutionList.get(step));
            contract.ContractStartDate__c = contractStartDate;
            contract.BillingPerson__c = accConMap.get(insConstitutionList.get(step).Account__c).Id;
            constitutionConMap.put(insConstitutionList.get(step).Id,contract);
            insContractList.add(contract);
        }
        insert insContractList;
        
        // 契約明細　契約1件につき3件作成
        List<ContractDetail__c> insertCDList = new List<ContractDetail__c>();
        for(Integer step=0;step<insContractList.size();step++){
            ContractDetail__c contractDetail1 = TestUtil.createContractDetail(insContractList.get(step));
            contractDetail1.No__c = 1;
            contractDetail1.ProductNameText__c = '単体試験確認用品名1';
            contractDetail1.Quantity__c = 1;
            contractDetail1.UnitPrice__c = 1000;
            contractDetail1.TaxPrice__c = 0;
            contractDetail1.Amount__c = 1000;
            // contractDetail1.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
            contractDetail1.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
            contractDetail1.BillingStartMonth__c = Constants.BILLING_START_MONTH;
            contractDetail1.TaxType__c = Constants.TAX_TYPE_NO_TAX;
            contractDetail1.Remarks__c = '単体試験確認用備考1';
            insertCDList.add(contractDetail1);
    
            ContractDetail__c contractDetail2 = TestUtil.createContractDetail(insContractList.get(step));
            contractDetail2.No__c = 2;
            contractDetail2.ProductNameText__c = '単体試験確認用品名2';
            contractDetail2.Quantity__c = 2;
            contractDetail2.UnitPrice__c = 2000;
            contractDetail2.TaxPrice__c = 0;
            contractDetail2.Amount__c = 4000;
            // contractDetail2.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
            contractDetail2.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
            contractDetail2.BillingStartMonth__c = Constants.BILLING_START_MONTH;
            contractDetail2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
            contractDetail2.Remarks__c = '単体試験確認用備考2';
            insertCDList.add(contractDetail2);
    
            ContractDetail__c contractDetail3 = TestUtil.createContractDetail(insContractList.get(step));
            contractDetail3.No__c = 3;
            contractDetail3.ProductNameText__c = '単体試験確認用品名3';
            contractDetail3.Quantity__c = 3;
            contractDetail3.UnitPrice__c = 3000;
            contractDetail3.TaxPrice__c = 900;
            contractDetail3.Amount__c = 9000;
            // contractDetail3.DetailType__c = Constants.DETAIL_TYPE_INICIAL_COST;
            contractDetail3.DetailType__c = Constants.DETAIL_TYPE_MONTHLY_COST;
            contractDetail3.BillingStartMonth__c = Constants.BILLING_START_MONTH;
            contractDetail3.TaxType__c = Constants.TAX_TYPE_10;
            contractDetail3.Remarks__c = '単体試験確認用備考3';
            insertCDList.add(contractDetail3);
        }
        insert insertCDList;

        // 作成済み請求ヘッダ 5件分
        List<BillingHeader__c> insBillHList = new List<BillingHeader__c>();
        for(Integer step = loopNum-existedHederNum; step < insAccList.size();step ++ ){
            BillingHeader__c billH = createBillingHeader(insAccList.get(step),insCtList.get(step));
            // 契約と紐づけ
            billH.BillingDepartment__c = insCtList.get(step).Department;
            insBillHList.add(billH);
        }
        insert insBillHList;

        Integer beforeBillHeaderCount = [SELECT count() FROM BillingHeader__c];

        // テスト開始
        Test.startTest();
        BillingCreatorBatch t = new BillingCreatorBatch();
        Database.executeBatch(t,300);
        Test.stopTest();
        
        // 検証
        // 請求明細
        Integer checkBillDetailCount= [SELECT count() FROM BillingDetail__c];
        
        // 請求
        Integer checkBillCount = [SELECT count() FROM Billing__c];

        // 請求ヘッダ
        Integer checkBillHeaderCount = [SELECT count() FROM BillingHeader__c];

        // 検証 想定の件数分作成されていること 請求明細：45件、請求：30件、請求明細：5→10件
        System.assertEquals(beforeBillHeaderCount, existedHederNum);
        System.assertEquals(checkBillDetailCount, (loopNum-existedHederNum)*9);
        System.assertEquals(checkBillCount, (loopNum-existedHederNum)*6);
        System.assertEquals(checkBillHeaderCount, loopNum);
    }

    /* 請求ヘッダ */
    private static BillingHeader__c createBillingHeader(Account acc, Contact ct) {
        Date today = Date.today();
        Date contractStartDate = Date.newInstance(today.year(), today.Month(), 1).addMonths(-1);
        BillingHeader__c billH = new BillingHeader__c();
        billH.BillingAccount__c = acc.Id;
        billH.BillingContact__c = ct.Id;
        billH.BillingYear__c = String.valueOf(contractStartDate.year());
        billH.BillingMonth__c = String.valueOf(contractStartDate.month());
        return billH;
    }
}