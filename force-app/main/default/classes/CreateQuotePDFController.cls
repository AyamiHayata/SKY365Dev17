/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 見積書帳票コントローラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/04/12          M.Kawasaki       New
 ********************************************************************************/
public with sharing class CreateQuotePDFController {

    private static final String PRIMARY_APPROVAL = '一次承認';
    private static final String SECONDARY_APPROVAL = '二次承認';
    private static final String APPROVAL_APPLICANT = '申請者';
    private static final String PRIMARY_APPROVER = '一次承認者';
    private static final String SECONDARY_APPROVER = '二次承認者';
    
    public Quote__c quote {get; set;}
    public List<QuoteDetail__c> quoteDetail {get; set;}
    public List<List<QuoteDetail__c>> quoteDetailPage {get; set;}
    public Integer maxPage {get; set;}
    public Integer detailPage {get; set;} //2021.10.28 add
    public String billPostalCode {get; set;}
    public String billAddress {get; set;}
    public String billAddress2 {get; set;}
    public String deptPostalCode {get; set;}
    public String deptAddress {get; set;}
    public String deptAddress2 {get; set;}
    public String deptTel {get; set;}
    public String outputDate {get; set;}
    public String markSalesOwner {get; set;}
    public String markManager {get; set;}
    public String markResponsible {get; set;}

    public List<String> noteList {get; set;}
    public List<String> assumedWorkContentList {get; set;}
    public List<String> assumedWorkAddContentList {get; set;} //2021.10.28 add
    public boolean assumedWorkAddContentFlg {get; set;} //2021.10.28 add
    public List<String> deliverablesList {get; set;}

    public CreateQuotePDFController(ApexPages.StandardController stdController) {
        quote = (Quote__c)stdController.getRecord();
        quoteDetailPage = new List<List<QuoteDetail__c>>();
        maxPage = 0;
        billPostalCode = '';
        billAddress = '';
        billAddress2 = '';
        deptPostalCode = '';
        deptAddress = '';
        deptAddress2 = '';
        deptTel = '';
        outputDate = '';
        markSalesOwner = '';
        markManager = '';
        markResponsible = '';
        noteList = new List<String>();
        assumedWorkContentList = new List<String>();
        assumedWorkAddContentList = new List<String>(); //2021.10.28 add
        assumedWorkAddContentFlg = false; //2021.10.28 add
        deliverablesList = new List<String>();
    }

    // 最大明細行
    //private static final Integer DETAIL_MAX_ROW = 25;
    private static final Integer DETAIL_MAX_ROW = 13;
    // 明細品名最大文字数
    private static final Integer PRODUCT_NAME_MAX_LENGTH = 21;

    // 備考最大行数
    private static final Integer NOTE_MAX_ROWS_NUM = 5;
    // 想定作業内容最大行数
    private static final Integer ASSUMED_WORK_CONTENT_MAX_ROWS_NUM = 32;
    // 想定作業内容追記最大行数
    private static final Integer ASSUMED_WORK_CONTENTADD_MAX_ROWS_NUM = 40;
    // 納品物容最大行数
    private static final Integer DELIVERABLES_MAX_ROWS_NUM = 3;

    // 表示文字数/1行
    private static final Decimal SPLIT_MAX_LEN = 59;

    public PageReference initAction() {

        // 見積取得
        getQuote();

        // 見積明細取得
        getQuoteDetail();

        // 見積明細改ページ用分割処理
        detailSpilitPage();

        // ページ数設定
        maxPage = quoteDetailPage.size();
        detailPage = quoteDetailPage.size();    //2021.10.28 add 
        if(assumedWorkAddContentFlg) maxPage++; //2021.10.28 add 


        // 請求先住所
        if(quote.BillAccount__r.BillingAddress <> null){
            Address add = quote.BillAccount__r.BillingAddress;
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

        // 承認状況取得
        Map<String, String> statusMap = getProcessInstances();
        if(!statusMap.isEmpty()){
            String primaryApprovalStatus = statusMap.get(PRIMARY_APPROVAL);
            String secondaryApprovalStatus = statusMap.get(SECONDARY_APPROVAL);
            if (quote.ApprovalStatus__c == 'Applying' || quote.ApprovalStatus__c == 'Approved') {
                markSalesOwner = getStampFilePath((Id)statusMap.get(APPROVAL_APPLICANT));
                if(primaryApprovalStatus <> null && primaryApprovalStatus == 'Approved'){
                    // 一次承認の場合
                    markManager = getStampFilePath((Id)statusMap.get(PRIMARY_APPROVER));
                }
                if(secondaryApprovalStatus <> null && secondaryApprovalStatus == 'Approved'){
                    // 二次承認の場合
                    markResponsible = getStampFilePath((Id)statusMap.get(SECONDARY_APPROVER));
                }
            }
        }

        return null;
    }

    /*
     * 担当印画像取得
     *
     * @return 担当印画像ファイルパス
     */
    @TestVisible
    private String getStampFilePath(Id id) {

        List<String> selectFields = new List<String>(
            Quote__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        User user = Database.query(
            String.format(
                'SELECT id, StampFilePath__c FROM User WHERE Id = :id LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        return user.StampFilePath__c;
    }

    /*
     * 見積取得
     *
     * @return 見積(全項目)
     */
    private void getQuote() {

        List<String> selectFields = new List<String>(
            Quote__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id qId = quote.Id;

        quote = Database.query(
            String.format(
                'SELECT {0} ,BillAccount__r.Name ,BillAccount__r.BillingAddress, BillingContact__r.Name, QuoteUser__r.Name, QuoteUser__r.Email FROM Quote__c WHERE Id = :qId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

        // 見積書に出力する件名は80文字まで
        final Integer SUBJECT_LEN = 80;
        if (quote.Name.length() > SUBJECT_LEN) quote.Name = quote.Name.subString(0, SUBJECT_LEN);

        // 見積発行日が空なら本日日付を設定
        if (quote.EstimateOutputDate__c == null) {
            quote.EstimateOutputDate__c = date.today();
        }

        // その他項目は24文字で折り返す
        final Integer OTHER_LEN = 24;
        if (String.isNotBlank(quote.Other__c) && quote.Other__c.length() > OTHER_LEN) {
            quote.Other__c = quote.Other__c.left(OTHER_LEN) + '\r\n' + quote.Other__c.substring(OTHER_LEN);
        }


        // 備考や想定作業内容は改行含む(空の場合は共通処理内で規定の枠分のスペースを作成)
        noteList = CommonUtil.setSplit(quote.Note__c, NOTE_MAX_ROWS_NUM, SPLIT_MAX_LEN);
        assumedWorkContentList = CommonUtil.setSplit(quote.AssumedWorkContent__c, ASSUMED_WORK_CONTENT_MAX_ROWS_NUM, SPLIT_MAX_LEN);
        deliverablesList = CommonUtil.setSplit(quote.Deliverables__c, DELIVERABLES_MAX_ROWS_NUM, SPLIT_MAX_LEN);
        //2021.10.21 add start
        if(String.isNotBlank(quote.AssumedWorkContentAdd__c)){
            assumedWorkAddContentFlg = true;
            assumedWorkAddContentList = CommonUtil.setSplit(quote.AssumedWorkContentAdd__c, ASSUMED_WORK_CONTENTADD_MAX_ROWS_NUM, SPLIT_MAX_LEN);
        }
        //2021.10.21 add end
        

    }

    /*
     * 見積明細取得
     *
     * @return 見積明細(全項目)
     */
    private void getQuoteDetail() {
        List<String> selectFields = new List<String>(
            QuoteDetail__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id qId = quote.Id;

        quoteDetail = Database.query(
            String.format(
                'SELECT No__c, toLabel(LargeType__c), ProductNameText__c, toLabel(DetailType__c), Quantity__c, Unit__c, UnitPrice__c, Amount__c, Remarks__c, TaxType__c FROM QuoteDetail__c WHERE Quote__c = :qId ORDER BY No__c ASC '
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );
    }

    /*
     * 承認情報取得処理
     *
     *
     * @return
     */
    private Map<String, String> getProcessInstances() {
        Map<String, String> result = new Map<String, String>();

        List<ProcessInstance> processInstanceData = [
            SELECT
                 Id
                ,CompletedDate
                ,LastActorId
                ,ProcessDefinitionId
                ,Status
                ,TargetObjectId
                ,(
                    SELECT
                        Id
                        ,ActorId
                        ,Comments
                        ,IsPending
                        ,OriginalActorId
                        ,ProcessInstanceId
                        ,ProcessNodeId
                        ,StepStatus
                        ,TargetObjectId
                        ,CreatedDate
                    FROM
                        StepsAndWorkitems
                    ORDER BY CreatedDate DESC
                 )
            FROM
                ProcessInstance
            WHERE
                TargetObjectId =: quote.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if(processInstanceData.size() == 0 ){
            return result;
        }

        // ProcessNodeId取得
        Set<String> nodeIds = new Set<String>();
        for (ProcessInstanceHistory sw : processInstanceData[0].StepsAndWorkitems) {
            nodeIds.add(sw.ProcessNodeId);
        }

        List<ProcessInstanceNode> processNodes = [
            SELECT
                Id
                , CompletedDate
                , LastActorId
                , NodeStatus
                , ProcessInstanceId
                , ProcessNodeId
                , ProcessNodeName
            FROM
                ProcessInstanceNode
            WHERE
                ProcessNodeId IN: nodeIds
        ];

        Id primaryApprovalId = null;
        Id secondaryApprovalId = null;
        for (ProcessInstanceNode node : processNodes ) {
            if(node.ProcessNodeName == PRIMARY_APPROVAL){
                primaryApprovalId = node.ProcessNodeId;
            }
            if(node.ProcessNodeName == SECONDARY_APPROVAL){
                secondaryApprovalId = node.ProcessNodeId;
            }
        }

        // 承認状況の確認
        Boolean isLatestPrimaryApproval = false;
        Boolean isLatestSecondaryApproval = false;
        for (ProcessInstanceHistory sw : processInstanceData[0].StepsAndWorkitems) {
            // 申請者
            if ('Started' == sw.StepStatus) {
                result.put(APPROVAL_APPLICANT, sw.ActorId);
            }
            // 一次承認
            if(!isLatestPrimaryApproval && sw.ProcessNodeId == primaryApprovalId){
                result.put(PRIMARY_APPROVAL, sw.StepStatus);
                result.put(PRIMARY_APPROVER, sw.ActorId);
                isLatestPrimaryApproval = true;
            }
            // 二次承認
            if(!isLatestSecondaryApproval && sw.ProcessNodeId == secondaryApprovalId){
                result.put(SECONDARY_APPROVAL, sw.StepStatus);
                result.put(SECONDARY_APPROVER, sw.ActorId);
                isLatestSecondaryApproval = true;
            }
        }
        return result;
    }

    /*
     * 見積明細改ページ用分割処理
     *
     */
    @TestVisible
    private void detailSpilitPage() {
        // 見積明細改ページ用分割処理
        List<QuoteDetail__c> detailEditList = new List<QuoteDetail__c>();
        QuoteDetail__c emptyDetail= new QuoteDetail__c();

        if(quoteDetail.size() <> 0){
            for(QuoteDetail__c edit : quoteDetail){
                // 品名の改行を行う
                if (String.isNotBlank(edit.ProductNameText__c) && edit.ProductNameText__c.length() > PRODUCT_NAME_MAX_LENGTH) {
                    edit.ProductNameText__c = edit.ProductNameText__c.left(PRODUCT_NAME_MAX_LENGTH) + '<br/>' + edit.ProductNameText__c.substring(PRODUCT_NAME_MAX_LENGTH);
                }
                detailEditList.add(edit);
                if(detailEditList.size() == DETAIL_MAX_ROW){
                   quoteDetailPage.add(detailEditList);
                   detailEditList = new List<QuoteDetail__c>();
                }
            }
            Integer setCnt = detailEditList.size();
            if(detailEditList.size() <> 0){
                for(Integer cnt=setCnt; cnt <= DETAIL_MAX_ROW-1; cnt++){
                    detailEditList.add(emptyDetail);
                }
                quoteDetailPage.add(detailEditList);
            }
        } else {
            // 見積明細がない場合、最大行数分空白を設定する
            for(Integer cnt=0; cnt <= DETAIL_MAX_ROW-1; cnt++){
                detailEditList.add(emptyDetail);
            }
            quoteDetailPage.add(detailEditList);
        }
    }
}