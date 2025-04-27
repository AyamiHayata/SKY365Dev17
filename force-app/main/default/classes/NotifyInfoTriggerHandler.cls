/********************************************************************************
 *
 * 連絡先情報トリガハンドラ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2022/08                               New
 ********************************************************************************
 * 2022/07/13 監査履歴（メールでのご連絡先）対応  
 ********************************************************************************/
public with sharing class NotifyInfoTriggerHandler{
    /**
     * 処理実行メソッド
     */
    public void run(){
        // if(Trigger.isBefore && Trigger.isInsert) {
        //    this.onBeforeInsert((SObject[])Trigger.New);
        // }else 
        if(Trigger.isBefore && Trigger.isUpdate){
           this.onBeforeUpdate((SObject[])Trigger.New, (SObject[])Trigger.Old, (Map<Id, SObject>)Trigger.newMap,(Map<Id, SObject>)Trigger.oldMap);
        //}else if(Trigger.isBefore && Trigger.isDelete){
        //    this.onBeforeDelete((SObject[])Trigger.Old, (Map<Id, SObject>)Trigger.oldMap);
        // if(Trigger.isAfter && Trigger.isInsert){
        //     this.onAfterInsert((SObject[])Trigger.New,(Map<Id, SObject>)Trigger.newMap);
        // }else if(Trigger.isAfter && Trigger.isUpdate){
        //     this.onAfterUpdate((SObject[])Trigger.New, (SObject[])Trigger.Old,(Map<Id, SObject>)Trigger.newMap, (Map<Id, SObject>)Trigger.oldMap);
        //}else if(Trigger.isAfter && Trigger.isDelete){
        //    this.onAfterDelete((SObject[])Trigger.Old, (Map<Id, SObject>)Trigger.oldMap);
        }
    }
    // public void onBeforeInsert(SObject[] triggerNews){}
    public void onBeforeUpdate(SObject[] triggerNews, SObject[] triggerOlds, Map<Id, SObject> triggerNewMap, Map<Id, SObject> triggerOldMap){
        
        Set<Id> deleteTargetIdSet = new Set<Id>();
        for(NotifyInfo__c ni:(List<NotifyInfo__c>) triggerNews){
            NotifyInfo__c oldni = (NotifyInfo__c) triggerOldMap.get(ni.Id);
            // Boolean apiFlg = CoodleUtil.chkDiffMailRenrakusaki(ni,oldni);
            Boolean apiFlg = false;
            //ヘッダーフラグを更新する
            Boolean tsumeruFlg = false;
            Boolean notTsumeruFlg = false;
            Boolean notBlankFlg = false;
            for(Integer reroopnum=1;reroopnum<21;reroopnum++){
                if(String.isNotBlank((String)ni.get('Etc'+ reroopnum + '_ChgList__c'))){
                    notBlankFlg = true;
                    apiFlg = true;
                    if('詰める'.equals((String)ni.get('Etc'+ reroopnum + '_ChgList__c'))){
                        tsumeruFlg = true;
                        apiFlg = true;
                    }else{
                        notTsumeruFlg = true;
                    }
                }
            }

            if(apiFlg && notBlankFlg && notTsumeruFlg){
                ni.HeaderFlg__c = '受付';
            }else{
                if(!ni.ProcessingFlg__c){
                    // if(!notBlankFlg || tsumeruFlg) ni.HeaderFlg__c = 'API処理済';
                    if(!notBlankFlg || (tsumeruFlg && !notTsumeruFlg)) ni.HeaderFlg__c = 'API処理済';
                }
            }

// System.debug('**==**== apiFlg =>' + apiFlg);
// System.debug('**==**== notBlankFlg =>' + notBlankFlg);
// System.debug('**==**== tsumeruFlg =>' + tsumeruFlg);
// System.debug('**==**== ni.ProcessingFlg__c =>' + ni.ProcessingFlg__c);

            //API処理済みになったら
            if('API処理済'.equals(ni.HeaderFlg__c) && !'API処理済'.equals(oldni.HeaderFlg__c)){
                //詰める処理を実施する
                moveupSonotaRenrakusaki(ni);
                //履歴レコード消すためのSetに入れる
                if(ni.PastOne__c!=null) deleteTargetIdSet.add(ni.PastOne__c);
                //ヘッダフラグとステータスを初期化する
                ni.HeaderFlg__c = '';
                ni.Status__c = '';
                ni.PastOne__c = null;
            }
        }
        // System.debug('**==**== deleteTargetIdSet =>' + deleteTargetIdSet);
        //履歴レコードを削除する場合は削除する  //2023.07.13 comment out 履歴を監査用に残すため
        // if(deleteTargetIdSet.size() > 0) {
        //     List<NotifyInfo__c> deletelist = [SELECT Id FROM NotifyInfo__c WHERE ID in :deleteTargetIdSet];
        //     if(deletelist.size() > 0) delete deletelist;
        // }
    } 
    private void moveupSonotaRenrakusaki(NotifyInfo__c notifyInfo){

        Integer maxnum = 21;
        Boolean tsumeruFlg = true;
        do {
            Integer tsumelCount = 0;
            for(Integer loopnum=1;loopnum<maxnum;loopnum++){
                if('詰める'.equals((String)notifyInfo.get('Etc'+ loopnum + '_ChgList__c'))){
                    tsumelCount++;
                    notifyInfo = clearEtcAddress(notifyInfo,loopnum);

                    //それ以下の連絡先をすべて一つ繰り上げる
                    for(Integer targetLoopnum=loopnum;targetLoopnum<maxnum-1;targetLoopnum++){
                        Integer nextIndex = targetLoopnum + 1;
                        notifyInfo.put('Etc'+ targetLoopnum +'_Del__c',(Boolean)notifyInfo.get('Etc'+ nextIndex +'_Del__c'));
                        notifyInfo.put('Etc'+ targetLoopnum +'_Name__c',(String)notifyInfo.get('Etc'+ nextIndex +'_Name__c'));
                        notifyInfo.put('Etc'+ targetLoopnum +'_Company__c',(String)notifyInfo.get('Etc'+ nextIndex +'_Company__c'));
                        notifyInfo.put('Etc'+ targetLoopnum +'_Mail__c',(String)notifyInfo.get('Etc'+ nextIndex +'_Mail__c'));
                        notifyInfo.put('Etc'+ targetLoopnum +'_AlertContact__c',(Boolean)notifyInfo.get('Etc'+ nextIndex +'_AlertContact__c'));
                        notifyInfo.put('Etc'+ targetLoopnum +'_OtherThanAlertContact__c',(Boolean)notifyInfo.get('Etc'+ nextIndex +'_OtherThanAlertContact__c'));
                        notifyInfo.put('Etc'+ targetLoopnum +'_MonthlyReportSender__c',(Boolean)notifyInfo.get('Etc'+ nextIndex +'_MonthlyReportSender__c'));
                        notifyInfo.put('Etc'+ targetLoopnum +'_Permission__c',(String)notifyInfo.get('Etc'+ nextIndex +'_Permission__c'));
                        notifyInfo.put('Etc'+ targetLoopnum +'_ChgList__c',(String)notifyInfo.get('Etc'+ nextIndex +'_ChgList__c'));
    
                        notifyInfo = clearEtcAddress(notifyInfo,nextIndex);
                    }
                }
            }
            if(tsumelCount==0) tsumeruFlg = false;
        } while (tsumeruFlg);
    
    }

    private NotifyInfo__c clearEtcAddress(NotifyInfo__c notifyInfo,Integer loopnum){
        notifyInfo.put('Etc'+ loopnum +'_Del__c',false);
        notifyInfo.put('Etc'+ loopnum +'_Name__c','');
        notifyInfo.put('Etc'+ loopnum +'_Company__c','');
        notifyInfo.put('Etc'+ loopnum +'_Mail__c','');
        notifyInfo.put('Etc'+ loopnum +'_AlertContact__c',false);
        notifyInfo.put('Etc'+ loopnum +'_OtherThanAlertContact__c',false);
        notifyInfo.put('Etc'+ loopnum +'_MonthlyReportSender__c',false);
        notifyInfo.put('Etc'+ loopnum +'_Permission__c','');
        notifyInfo.put('Etc'+ loopnum +'_ChgList__c','');

        return notifyInfo;
    }
    // public void onAfterInsert(SObject[] triggerNews, Map<Id, SObject> triggerNewMap){}
    // public void onAfterUpdate(SObject[] triggerNews, SObject[] triggerOlds, Map<Id, SObject> triggerNewMap, Map<Id, SObject> triggerOldMap){
    // }
    // public void onBeforeDelete(SObject[] triggerOlds, Map<Id, SObject> triggerOldMap){}
    // public void onAfterDelete(SObject[] triggerOlds, Map<Id, SObject> triggerOldMap){}
    // public void onUndelete(SObject[] triggerNews, Map<Id, SObject> triggerNewMap){}


}