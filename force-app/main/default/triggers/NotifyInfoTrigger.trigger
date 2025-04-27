/********************************************************************************
 *
 * 連絡先情報トリガ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2022/08                              New
 * 2023/09/13          Kikuchi          案件情報更新
 ********************************************************************************/
trigger NotifyInfoTrigger on NotifyInfo__c (before update, after insert, after update, after delete) {
  new NotifyInfoTriggerHandler().run();
  
  // 2023/9/13 案件情報更新 add
  NotifyInfoTriggerCCommonUpdHandler handler = new NotifyInfoTriggerCCommonUpdHandler();
  if (Trigger.isInsert && Trigger.isAfter) {
    handler.RenrakusakiUpdTrue(Trigger.new);
  }

  else if(Trigger.isUpdate && Trigger.isAfter){
    handler.RenrakusakiUpdFalse(Trigger.old);
    handler.RenrakusakiUpdTrue(Trigger.new);     
  }

  else if(Trigger.isDelete && Trigger.isAfter){
    handler.RenrakusakiUpdFalse(Trigger.old);
  }
  // 2023/9/13 案件情報更新 add
}