/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * シーザー暗号化クラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/08     Kikuchi     新規作成
 ********************************************************************************/
public with sharing class Caesar {
    private static final String ALPHABETS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
   
    /**
    * コンストラクタ
    *
    */
    public Caesar() {

    }

   /**
    * 暗号化
    *
    * @param json JSON文字列
    * @param Integer シフト数
    * @return String 暗号化後文字列
    */
    public String encrypt(String json, Integer shift) {
        String encoded = EncodingUtil.base64Encode(Blob.valueOf(json));

        // シーザー暗号化マップを作成
        Map<String, String> chgMap = new Map<String, String>();
        List<String> alphbetList = ALPHABETS.split('');
        for (Integer i = 0; alphbetList.size() - 1 >= i; i++) {
            Integer idx = i + Shift >= alphbetList.size() ? i + shift - alphbetList.size() : i + Shift;
            chgMap.put(alphbetList.get(i), alphbetList.get(idx));
        }
        // 暗号化マップを元に平文を変換
        List<String> argList = encoded.split('');
        String result = '';
        for (String a : argList) {
            //system.debug('■ before:' +  a + '  after:' +  chgMap.get(a));

            if (chgMap.containsKey(a)) {
                result += chgMap.get(a);
            } else {
                result += a; 
            }
        }
        return result;
    }
}