/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 契約編集コントローラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/07/20          R.Matsui          New
 ********************************************************************************/
@isTest
private class CreateBillingPDFControllerTest {
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる

    }
    
    /**
     * 【対象】
     * initAction
     * 【条件】
     * 請求なし、請求発行日なし、備考記載121文字以上
     * 【結果】
     * 処理が正常に終了すること、請求ページが1ページ(空白)であること
     */
    @isTest
    public static void test_initAction_001() {
        // データ準備
        // 取引先
        Account acc = TestUtil.createAccount();
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 見積
        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.ApprovalStatus__c = 'approved';
        insert quote;

        // 見積明細
        QuoteDetail__c quoteDetail = TestUtil.createQuoteDetail(quote);
        quoteDetail.No__c = 3;
        insert quoteDetail;
        
        // 契約
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;
        
        // 契約明細
        ContractDetail__c contractDetail = TestUtil.createContractDetail(contract);
        contractDetail.No__c = 2;
        insert contractDetail;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        String Remark1 = '単体試験備考出力確認１２３４５６７８９０１２３４５６７８９０１２３４５６７８９０１２３４５６７８９０１２３４５６７８９０';
        String Remark2 = '単体試験備考出力確認あいうえおかきくけこあいうえおかきくけこあいうえおかきくけこあいうえおかきくけこあいうえおかきくけこ';
        String Remark3 = '単体試験備考出力確認さしすせそたちつてとさしすせそたちつてとさしすせそたちつてとさしすせそたちつてとさしすせそたちつてと';
        String Remark4 = '単体試験備考出力確認なにぬねのはひふへほなにぬねのはひふへほなにぬねのはひふへほなにぬねのはひふへほなにぬねのはひふへほ';
        billH.Remarks__c = Remark1 + Remark2 + Remark3 + Remark4;
        insert billH;
        // insertだと請求発行日が自動入力されるので空に更新
        billH.InvoiceOutputDate__c = null;
        update billH;

        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(billH);
        CreateBillingPDFController ctrl = new CreateBillingPDFController(stdCtrl);

        Boolean result = true;
        try{
            ctrl.initAction();
        }catch(Exception e){
            System.debug(e);
            result = false;
        }
        Test.stopTest();

        // 検証
        System.assertEquals(result,true);
        System.assertEquals(ctrl.maxPage,1);
        System.assertEquals(ctrl.noteList.get(0), Remark1);
        System.assertEquals(ctrl.noteList.get(1), Remark2);
        System.assertEquals(ctrl.noteList.size(), 2);
        for(String s : ctrl.noteList){
            SYstem.debug(s);
        }
        System.debug('ctrl.noteList.size='+ctrl.noteList.size());

        Organization org = CommonUtil.getOrganizationInfo();
        Address add = org.Address;
        System.assertEquals(ctrl.deptPostalCode, Label.COMMON_PDF_POST_MARK + add.getPostalCode());
        System.assertEquals(ctrl.deptAddress,add.getState() + add.getCity());
        System.assertEquals(ctrl.deptAddress2,add.getStreet());
        System.assertEquals(ctrl.deptTel,Label.COMMON_PDF_TELL + org.Phone);
    }

    /**
     * 【対象】
     * initAction
     * 【条件】
     * 請求あり(14件)、請求先住所あり、請求発行日あり、備考60文字以内
     * 【結果】
     * 処理が正常に終了すること、maxPageが2であること、請求先住所が取引先から設定されること
     */
    @isTest
    public static void test_initAction_002() {
        // データ準備
        // 取引先
        Account acc = TestUtil.createAccount();
        acc.BillingPostalcode = '1234567';
        acc.BillingState = '単体試験State';
        acc.BillingStreet = '単体試験Street';
        acc.BillingCity = '単体試験City';
        insert acc;

        // 取引先責任者
        Contact ct = TestUtil.createContact(acc);
        insert ct;

        // 案件情報
        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // 見積
        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.ApprovalStatus__c = 'approved';
        insert quote;

        // 見積明細
        QuoteDetail__c quoteDetail = TestUtil.createQuoteDetail(quote);
        quoteDetail.No__c = 3;
        insert quoteDetail;
        
        // 契約
        Contract__c contract = TestUtil.createContract(acc.Id, constitution);
        insert contract;
        
        // 契約明細
        ContractDetail__c contractDetail = TestUtil.createContractDetail(contract);
        contractDetail.No__c = 2;
        insert contractDetail;

        // 請求ヘッダ
        BillingHeader__c billH = createBillingHeader(acc, ct);
        billH.BillDestination__c = '北海道札幌市北区単体試験';
        billH.Remarks__c = 'test_initAction_002';
        billH.Name = acc.Name;
        insert billH;

        // 請求(14件)
        List<Billing__c> insertBillList = new List<Billing__c>();
        for(Integer step = 0;step<13;step++){
            Billing__c billAdd = createBilling(acc, billH, constitution);
            billAdd.Name = '単体試験請求名称' + step;
            insertBillList.add(billAdd);
        }
        Billing__c billAddLongName = createBilling(acc, billH, constitution);
        billAddLongName.Name = '単体試験請求名称最大文字数超過確認試験用あああああああああああああああああああああああああ';
        billAddLongName.TaxType__c = Constants.TAX_TYPE_10;
        insertBillList.add(billAddLongName);
        
        insert insertBillList;

        // 請求明細
        List<BillingDetail__c> insertBillDtlList = new List<BillingDetail__c>();
        BillingDetail__c billDtl1 = createBillingDetail(billAddLongName);
        billDtl1.Billing__c = billAddLongName.Id;
        billDtl1.Quantity__c = 5;
        billDtl1.UnitPrice__c =10000;
        billDtl1.TaxType__c = Constants.TAX_TYPE_10;
        billDtl1.Amount__c = 50000;
        billDtl1.TaxPrice__c = 5000;
        insertBillDtlList.add(billDtl1);

        BillingDetail__c billDtl2 = createBillingDetail(billAddLongName);
        billDtl2.Billing__c = billAddLongName.Id;
        billDtl2.Quantity__c = 2;
        billDtl2.UnitPrice__c =30000;
        billDtl2.TaxType__c = Constants.TAX_TYPE_NO_TAX;
        billDtl2.Amount__c = 60000;
        insertBillDtlList.add(billDtl2);

        insert insertBillDtlList;
        
        // テスト開始
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(billH);
        CreateBillingPDFController ctrl = new CreateBillingPDFController(stdCtrl);

        Boolean result = true;
        try{
            ctrl.initAction();
        }catch(Exception e){
            System.debug(e);
            result = false;
        }
        Test.stopTest();

        // 検証
        System.assertEquals(result,true);
        System.assertEquals(ctrl.maxPage,2);
        System.assertEquals(ctrl.billPostalCode,Label.COMMON_PDF_POST_MARK + '1234567');
        System.assertEquals(ctrl.billAddress,'単体試験State'+'単体試験City');
        System.assertEquals(ctrl.billAddress2,'単体試験Street');
        System.assertEquals(ctrl.billingHeader.TotalBillingAmount__c,110000);
        System.assertEquals(ctrl.billingHeader.TotalAmountIncludingTax__c,121000);
        System.assertEquals(ctrl.billingHeader.BillDestination__c, '北海道札幌市北区単体試験');
        System.assertEquals(ctrl.billingHeader.Name,acc.Name);
    }

    /* 請求ヘッダ */
    private static BillingHeader__c createBillingHeader(Account acc, Contact ct) {
        BillingHeader__c billH = new BillingHeader__c();
        billH.SearchBillingAccount__c = acc.Id;
        billH.BillingAccount__c = acc.Id;
        billH.BillingContact__c = ct.Id;
        billH.BillingYear__c = String.valueof(Date.today().year());
        billH.BillingMonth__c = String.valueof(Date.today().month());
        return billH;
    }

    /* 請求 */
    private static Billing__c createBilling(Account acc, BillingHeader__c billH, Constitution_Common__c constitution) {
        Billing__c bill = new Billing__c();
        bill.Constitution_Common__c = constitution.Id;
        bill.BillingHeader__c = billH.Id;
        bill.Account__c = acc.Id;
        return bill;
    }

    /* 請求明細 */
    private static BillingDetail__c createBillingDetail(Billing__c bill) {
        BillingDetail__c billDtl = new BillingDetail__c();
        billDtl.Billing__c = bill.Id;
        return billDtl;
    }
}