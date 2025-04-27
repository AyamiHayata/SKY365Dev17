/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * ご連絡先名・アドレス置換クラス
 * 
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/02     Kikuchi     新規作成
 ********************************************************************************/
public without sharing class ReplaceContactInfo {

        /* 変更前メールアドレス（検索キーに使用） */
        private String beforeMail;
        /* 置換後 お名前 */
        private String afterName;
        /* 置換後 会社名 */
        private String afterCompany;
        /*  置換後 メールアドレス  */       
        private String afterMail;

    public ReplaceContactInfo(String lBeforeMail, String lAfterName, String lAfterMail) {
        beforeMail = lBeforeMail;
        afterName = lAfterName;
        afterMail = lAfterMail;
        afterCompany = '';
    }

    public ReplaceContactInfo(String lBeforeMail, String lAfterName, String lAfterMail, String lAfterCompany) {
        beforeMail = lBeforeMail;
        afterName = lAfterName;
        afterMail = lAfterMail;
        afterCompany = lAfterCompany;
    }

    public void replace() {
        // 連絡先情報取得
        List<NotifyInfo__c> notifyInfoList = [SELECT Id, Etc1_Mail__c, Etc1_Name__c, Etc1_Company__c, Etc2_Mail__c, Etc2_Name__c, Etc2_Company__c, Etc3_Mail__c, Etc3_Name__c, Etc3_Company__c, Etc4_Mail__c, Etc4_Name__c, Etc4_Company__c, Etc5_Mail__c, Etc5_Name__c, Etc5_Company__c, Etc6_Mail__c, Etc6_Name__c, Etc6_Company__c, Etc7_Mail__c, Etc7_Name__c, Etc7_Company__c, Etc8_Mail__c, Etc8_Name__c, Etc8_Company__c, Etc9_Mail__c, Etc9_Name__c, Etc9_Company__c, Etc10_Mail__c, Etc10_Name__c, Etc10_Company__c, Etc11_Mail__c, Etc11_Name__c, Etc11_Company__c, Etc12_Mail__c, Etc12_Name__c, Etc12_Company__c, Etc13_Mail__c, Etc13_Name__c, Etc13_Company__c, Etc14_Mail__c, Etc14_Name__c, Etc14_Company__c, Etc15_Mail__c, Etc15_Name__c, Etc15_Company__c, Etc16_Mail__c, Etc16_Name__c, Etc16_Company__c, Etc17_Mail__c, Etc17_Name__c, Etc17_Company__c, Etc18_Mail__c, Etc18_Name__c, Etc18_Company__c, Etc19_Mail__c, Etc19_Name__c, Etc19_Company__c, Etc20_Mail__c, Etc20_Name__c, Etc20_Company__c FROM NotifyInfo__c WHERE PastOneFLG__c = false AND (Etc1_Mail__c = :beforeMail or Etc2_Mail__c = :beforeMail or Etc3_Mail__c = :beforeMail or Etc4_Mail__c = :beforeMail or Etc5_Mail__c = :beforeMail or Etc6_Mail__c = :beforeMail or Etc7_Mail__c = :beforeMail or Etc8_Mail__c = :beforeMail or Etc9_Mail__c = :beforeMail or Etc10_Mail__c = :beforeMail or Etc11_Mail__c = :beforeMail or Etc12_Mail__c = :beforeMail or Etc13_Mail__c = :beforeMail or Etc14_Mail__c = :beforeMail or Etc15_Mail__c = :beforeMail or Etc16_Mail__c = :beforeMail or Etc17_Mail__c = :beforeMail or Etc18_Mail__c = :beforeMail or Etc19_Mail__c = :beforeMail or Etc20_Mail__c = :beforeMail)];
        for (NotifyInfo__c element :notifyInfoList ) {
            Integer limitnum = 20;
            for(Integer loopnum = 1;loopnum <= limitnum; loopnum++){
                String otherName = (String) element.get('Etc'+loopnum+'_Name__c');
                String otherMail = (String) element.get('Etc'+loopnum+'_Mail__c');
                String otherCompany = (String) element.get('Etc'+loopnum+'_Company__c');

                if (otherMail == beforeMail) {
                    // お名前変更
                    if (otherName != afterName) {
                        element.put('Etc'+ loopnum +'_Name__c',afterName);
                    }

                    // メールアドレス変更
                    if (otherMail != afterMail) {
                        element.put('Etc'+ loopnum +'_Mail__c',afterMail);
                    }
                
                    // 会社名変更
                    if (afterCompany != '' && otherCompany != afterCompany) {
                        element.put('Etc'+ loopnum +'_Company__c',afterCompany);
                    }                    
                    
                }
            }
            update notifyInfoList;
        }

    }


}