/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 請求書帳票コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/17          T.Hase           New
 ********************************************************************************/
public with sharing class CreateBillingPDFController {

    public BillingHeader__c billingHeader {get; set;}
    public List<Billing__c> billing {get; set;}
    public List<List<Billing__c>> billingPage {get; set;}
    public Integer maxPage {get; set;}
    public String billPostalCode {get; set;}
    public String billAddress {get; set;}
    public String billAddress2 {get; set;}
    public String deptPostalCode {get; set;}
    public String deptAddress {get; set;}
    public String deptAddress2 {get; set;}
    public String deptTel {get; set;}
    public String outputDate {get; set;}
    public String paymentCondition {get; set;}
    public Banking_Info__mdt bankingInfo { get; set; }

    public List<String> noteList {get; set;}

    public CreateBillingPDFController(ApexPages.StandardController stdController) {
        billingHeader = (BillingHeader__c)stdController.getRecord();
        billingPage = new List<List<Billing__c>>();
        maxPage = 0;
        billPostalCode = '';
        billAddress = '';
        billAddress2 = '';
        deptPostalCode = '';
        deptAddress = '';
        deptAddress2 = '';
        deptTel = '';
        outputDate = '';
        paymentCondition = '';
        noteList = new List<String>();
        bankingInfo = new Banking_Info__mdt();
    }

    // 最大明細行
    //private static final Integer DETAIL_MAX_ROW = 25;
    private static final Integer DETAIL_MAX_ROW = 13;
    // 備考最大行数
    private static final Integer REMARKS_MAX_ROWS_NUM = 2;
    // 明細品名最大文字数
    private static final Integer BILL_NAME_MAX_LENGTH = 21;
    // 表示文字数/1行
    private static final Decimal SPLIT_MAX_LEN = 60;

    // 件名の出力文字数
    private static final Integer BILLING_NAME_MAX_LEN = 25;

    public PageReference initAction() {

        // 請求ヘッダ取得
        getBillingHeader();

        // 請求取得
        getBilling();

        // 請求改ページ用分割処理
        detailSpilitPage();

        // ページ数設定
        maxPage = billingPage.size();

        // 請求先住所
        if(billingHeader.BillingAccount__r.BillingAddress <> null){
            Address add = billingHeader.BillingAccount__r.BillingAddress;
            billPostalCode = Label.COMMON_PDF_POST_MARK + add.getPostalCode();
            billAddress = add.getState() + add.getCity();
            billAddress2 = add.getStreet();
        }

        // Sky365様会社情報
        Organization org = CommonUtil.getOrganizationInfo();
        if(org.Address <> null){
            Address add = org.Address;
            deptPostalCode = Label.COMMON_PDF_POST_MARK + add.getPostalCode();
            deptAddress = add.getState() + add.getCity();
            deptAddress2 = add.getStreet();
            deptTel = Label.COMMON_PDF_TELL + org.Phone;
        }
        
        // 口座情報を取得
        bankingInfo = CommonUtil.getBankingInfo();

        // お支払い条件は請求の１件目から取得
        if (this.billing.size() > 0) {
            paymentCondition = this.billing[0].Contract__r.PaymentCondition__c;
        }

        return null;
    }

    /*
     * 請求ヘッダ取得
     *
     * @return 請求ヘッダ(全項目)
     */
    private void getBillingHeader() {

        List<String> selectFields = new List<String>(
            BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id bId = billingHeader.Id;

        billingHeader = Database.query(
            String.format(
                'SELECT {0} ,BillingAccount__r.Name ,BillingAccount__r.BillingAddress, BillingContact__r.Name FROM BillingHeader__c WHERE Id = :bId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        // 請求発行日が空なら本日日付を設定
        if (billingHeader.InvoiceOutputDate__c == null) {
            billingHeader.InvoiceOutputDate__c = date.today();
        }

        // 備考や想定作業内容は改行含む
        noteList = CommonUtil.setSplit(billingHeader.Remarks__c, REMARKS_MAX_ROWS_NUM, SPLIT_MAX_LEN);
    }

    /*
     * 請求取得
     *
     * @return 請求(全項目)
     */
    private void getBilling() {
        List<String> selectFields = new List<String>(
            Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id bId = billingHeader.Id;

        billing = Database.query(
            String.format(
                'SELECT {0},Contract__r.PaymentCondition__c, Account__r.Name, Contract__r.Name FROM Billing__c WHERE BillingHeader__c = :bId ORDER BY id '
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );
    }

    /*
     * 請求改ページ用分割処理
     *
     */
    @TestVisible
    private void detailSpilitPage() {
        // 請求改ページ用分割処理
        List<Billing__c> detailEditList = new List<Billing__c>();
        Billing__c emptyDetail= new Billing__c();

        if(billing.size() <> 0){
            for(Billing__c edit : billing){

                // 直商流以外（商流が「未設定」もしくは「Sky365」以外）の場合、請求件名に取引先を入れる
                if (!edit.IsDirectCommercialFlow__c && String.isNotBlank(edit.Account__c)) {
                    // 保守No.14 取引先名を先頭にする
                    // edit.Name += '_' + edit.Account__r.Name;
                    edit.Name = edit.Account__r.Name + '_' + edit.Name;
                }
                // 内容の改行を行う
                if (String.isNotBlank(edit.Name) && edit.Name.length() > BILL_NAME_MAX_LENGTH * 2) {
                    edit.Name = edit.Name.left(BILL_NAME_MAX_LENGTH * 3);
                }
                // if (String.isNotBlank(edit.Name) && edit.Name.length() > BILL_NAME_MAX_LENGTH) {
                //     edit.Name = edit.Name.left(BILL_NAME_MAX_LENGTH) + '<br/>' + edit.Name.substring(BILL_NAME_MAX_LENGTH);
                // }
                if (String.isNotBlank(edit.Name)) {
                    edit.Name = edit.Name.replaceAll('.', '$0<wbr>').replaceAll('\r\n', '<br/>');
                }
                // 備考を自動改行
                if (String.isNotBlank(edit.Remarks__c)) {
                    edit.Remarks__c = edit.Remarks__c.replaceAll('.', '$0<wbr>').replaceAll('\r\n', '<br/>');
                }
                detailEditList.add(edit);
                if(detailEditList.size() == DETAIL_MAX_ROW){
                    billingPage.add(detailEditList);
                    detailEditList = new List<Billing__c>();
                }
            }
            Integer setCnt = detailEditList.size();
            if(detailEditList.size() <> 0){
                for(Integer cnt=setCnt; cnt <= DETAIL_MAX_ROW-1; cnt++){
                    detailEditList.add(emptyDetail);
                }
                billingPage.add(detailEditList);
            }
        } else {
            // 請求がない場合、最大行数分空白を設定する
            for(Integer cnt=0; cnt <= DETAIL_MAX_ROW-1; cnt++){
                detailEditList.add(emptyDetail);
            }
            billingPage.add(detailEditList);
        }
    }
}