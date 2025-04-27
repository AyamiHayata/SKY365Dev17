/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2020 SKY365 Inc. All Rights Reserved.
 *
 * 対応一覧コントローラ
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2020/10     Kikuchi     新規作成
 ********************************************************************************/
public class OperationListDatatableControllerVF {
    
    private final Constitution_Common__c common;
    
    /*
     * コンストラクタ
     */    
    public OperationListDatatableControllerVF(ApexPages.StandardController stdController) {
        this.common = (Constitution_Common__c)stdController.getRecord();
    }
    
    /*
     * 対応一覧を取得
     * @return 対応一覧リスト
     */    
    public List<OperationList__c> getOperationList() {
        return [SELECT Id, Name, BeforeFlag__c, InProgressFlag__c, CompletedFlag__c, EndedFlag__c,
                        RepetitionDate__c, Host__c, Alert__c, ProjectInformation__c, AllHostFlag__c FROM OperationList__c  
                 WHERE CompletedFlag__c = false AND ProjectInformation__c = :common.id ];
    }
    
    
}