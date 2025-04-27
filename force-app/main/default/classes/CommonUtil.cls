/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 共通関数クラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/05/17          M.Kawasaki       New
 ********************************************************************************/
public with sharing class CommonUtil {
    
    private static List<event> eventList;
    /**
     * 組織情報を取得する
     */
    public static Organization getOrganizationInfo() {
        return [SELECT Name, Address, Phone From Organization LIMIT 1][0];
    }

    /**
     * 口座情報を取得する
     */
    public static Banking_Info__mdt getBankingInfo() {
        return [SELECT BankName__c, toLabel(AccountType__c), AccountNumber__c, AccountHolder__c, BranchName__c FROM Banking_Info__mdt LIMIT 1][0];
    }

    /**
     * NULLを0に変換する
     */
    public static Decimal convertNullToZero(Decimal val) {
        if (val == null) return 0;
        return val;
    }

    /**
     * NULLを空文字に変換する
     */
    public static String convertNullToEmptyString(String val) {
        if (val == null) return '';
        return val;
    }

    /**
     * 改行編集処理
     * 
     * @param String 編集対象データ
     * @param Integer 表示最大行数
     * @param Decimal 改行文字数
     * @return List<String> 改行後文言リスト
     */
    public static List<String> setSplit(String data, Integer maxRowNum, Decimal maxLen) {
        List<String> resultList = new List<String>();
        List<String> editList = new List<String>();
        String[] splitList = null;
        Integer targetCnt = 0;
        // 空行用
        String emptyItem = '　';

        if(String.isNotBlank(data)){
            // 改行で分割
            splitList = data.split('\r\n');

            // 一行の文字数が60文字以上の場合改行する
            for(String item : splitList){
                if(item.length() <= maxLen.intValue()){
                    // 60文字未満はそのまま挿入
                    editList.add(item);
                } else {
                    // 60文字以上は分割
                    Decimal len = Math.ceil(item.length() / maxLen);
                    for(Integer lenCnt = 1; lenCnt <= len; lenCnt++){
                        if(lenCnt == 1){
                            // 分割初回
                            editList.add(item.substring((lenCnt - 1) , maxLen.intValue()));
                        } else {
                            // 分割二回目以降
                            Integer startLen = (lenCnt - 1) * maxLen.intValue();
                            if(lenCnt == len){
                                // 最終分割
                                editList.add(item.substring(startLen));
                            } else {
                                Integer endLen = startLen + maxLen.intValue();
                                editList.add(item.substring(startLen , endLen));
                            }
                        }
                    }
                }
            }            
            targetCnt = editList.size();
        }

        for(Integer cnt=0; cnt < maxRowNum; cnt++){
            if(cnt < targetCnt){
                resultList.add(String.isBlank(editList[cnt]) ? emptyItem : editList[cnt]);
            } else {
                resultList.add(emptyItem);
            }
        }
        return resultList;
    }

    /**
     * 土日祝カウント
     * 
     * @param Date 開始日
     * @param Date 終了日
     * @return 土日祝日数
     */
    public static Integer holidayCount(Date fromDate, Date toDate) {
        Set<Date> eventSet = new Set<Date>();
        if (eventList == null) {
            eventList = [select subject, ActivityDate from event where OwnerId = '0230K000005MO2cQAG'];
        }
        for (Event e : eventList) {
            eventSet.add(e.ActivityDate);
        }

        Integer between = fromDate.daysBetween(toDate);
        Set<Date> holidaySet = new Set<Date>();
        for (Integer i = 0; between >= i; i++) {
            Date targetDate = fromDate.addDays(i);
            DateTime targetDateTime = DateTime.newInstance(targetDate, Time.newInstance(0, 0, 0, 0));
            // 土日
            if (targetDateTime.format('E') == 'Sat' || 
                targetDateTime.format('E') == 'Sun') {
                holidaySet.add(targetDate);
            }
            // 祝日
            if (eventSet.contains(targetDate)) {
                holidaySet.add(targetDate); 
            }
        } 
        return holidaySet.size();
    }
}