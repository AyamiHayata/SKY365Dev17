/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * 連絡先情報トリガー案件情報更新ハンドラー
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/09/13  Kikuchi     新規作成
 ********************************************************************************/
public with sharing class NotifyInfoTriggerCCommonUpdHandler {

    /**
     * コンストラクタ
     */
    public NotifyInfoTriggerCCommonUpdHandler() {

    }

    /**
     * 案件情報.連絡先有をTrueに更新
     */    

     public void RenrakusakiUpdTrue(List<NotifyInfo__c> triggerList) {
        RenrakusakiUpd(triggerList, true); 
    }

    /**
     * 案件情報.連絡先有をFalseに更新
     */    
    public void RenrakusakiUpdFalse(List<NotifyInfo__c> triggerList) {
        RenrakusakiUpd(triggerList, false); 
    }

    /**
     * 案件情報.連絡先有を更新
     */    
    private void RenrakusakiUpd(List<NotifyInfo__c> triggerList, Boolean updFlg) {
        Set<Id> idSet = new Set<Id>();
        for (NotifyInfo__c target : triggerList) {
            if (target.ConstitutionCommon__c != null) {
                idSet.add((Id)target.ConstitutionCommon__c);
                system.debug('kik_step1:' + (Id)target.ConstitutionCommon__c);
            }
        }
        if (idSet.size() > 0) {
            // 連絡先情報を取得
            List<AggregateResult> resultList = [select ConstitutionCommon__c, COUNT(id) Cnt FROM NotifyInfo__c where ConstitutionCommon__c IN :idSet AND PastOneFLG__c = false Group by ConstitutionCommon__c];
            
            if (updFlg) {
                idSet = new Set<Id>();
                for (AggregateResult result : resultList) {
                    idSet.add((Id)result.get('ConstitutionCommon__c'));
                    system.debug('kik_step2:' + (Id)result.get('ConstitutionCommon__c'));
                }

            } else {
                for (AggregateResult result : resultList) {
                    idSet.remove((Id)result.get('ConstitutionCommon__c'));
                    system.debug('kik_step3:' + (Id)result.get('ConstitutionCommon__c'));
                }
            }
            // 更新する案件情報を取得
            List<Constitution_Common__c> updateList = [SELECT Id, IsRenrakusaki__c FROM Constitution_Common__c WHERE Id IN:idSet];
            for (Constitution_Common__c target : updateList) {
                target.IsRenrakusaki__c = updFlg;
                system.debug('kik_step4:' + target.id);

            }
            
            // 更新
            if (updateList.size() > 0) {
                system.debug('kik_step5:' + updateList.size());
                update updateList;
            }

        }        
    }
}