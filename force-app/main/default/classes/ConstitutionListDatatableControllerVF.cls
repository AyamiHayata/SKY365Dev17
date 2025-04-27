/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * 案件情報一覧コントローラ
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2021/08     Kikuchi     新規作成
 ********************************************************************************/
public class ConstitutionListDatatableControllerVF {
    
    private final Account acc;
    
    /*
     * コンストラクタ
     */    
    public ConstitutionListDatatableControllerVF(ApexPages.StandardController stdController) {
        this.acc = (Account)stdController.getRecord();
    }
    
    /*
     * 案件情報を取得
     * @return 案件情報リスト
     */    
    public List<Constitution_Common__c> getConstitutionList() {
        Account lAcc = [SELECT id, Commercial_flow__c FROM Account WHERE id =:acc.id];
        return [select id, name, Account__r.name, Commercial_flow__c, TerminationFlag__c, 
                OperationStartDate__c,TerminationDate__c from Constitution_Common__c 
                where Commercial_flow__c != null AND TerminationFlag__c = false AND (Commercial_flow__c= :lAcc.Commercial_flow__c or Account__c=:lAcc.id) order by CreatedDate desc LIMIT 1000];
    }
}