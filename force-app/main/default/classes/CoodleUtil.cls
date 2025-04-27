public with sharing class CoodleUtil {


    /* 連絡先編集可能ステータス */
    public static final String EDITABLE_STATUS_SHINSEI = '申請';
    /*　ユーザー権限 */
    public static final String AUTH_NOT_VIEW = '参照不可';
    public static final String AUTH_VIEW_ONLY = '参照のみ';
    public static final String AUTH_EDIT_ABLE = '編集可';

    //エラーメッセージ
    //営業曜日
    public static final String ERR_MS1 = '営業曜日が選択されていません。';
    //営業時間
    public static final String ERR_MS2 = '営業時間は0:00から23:59の範囲で設定してください。';																				
    public static final String ERR_MS3 = '営業終了時間が営業開始時間より前に設定されています。';																				
    public static final String ERR_MS4 = '営業時間中の連絡先が設定されていません。';																				
    public static final String ERR_MS5 = '営業時間中の連絡先は、お名前、ふりがな、会社名、電話番号を設定してください。';																				
    public static final String ERR_MS6 = '営業時間外の連絡先が設定されていません。';																				
    public static final String ERR_MS7 = '営業時間外の連絡先は、お名前、ふりがな、会社名、電話番号を設定してください。';	
    
    //連絡先
    public static final String ERR_MS8 = '連絡先を2巡してもどなたにもつながらない場合の設定がありません。';

    //連絡先メール
    public static final String ERR_MS9 = 'メールでのご連絡先が一件も設定されていません。';
    public static final String ERR_MS10 = 'メールでのご連絡先は、お名前、会社名、メールアドレス、権限を設定してください。';
    public static final String ERR_MS11 = 'メールでのご連絡先で同じメールアドレスは登録できません。';

    //アラート
    public static final String ERR_MS12 = 'アラートのご連絡先が一件も設定されていません。';
    public static final String ERR_MS13 = 'アラート以外のご連絡先が一件も設定されていません。';

    //月次レポート
    public static final String ERR_MS14 = '月次レポートの送付先が一件も設定されていません。';

    //編集権限ユーザーチェック
    public static final String ERR_MS15 = '編集権限があるユーザーが少なくとも1名は必要です。';

    //編集権限ユーザーチェック
    public static final String ERR_MS16 = '現在、ログインしているユーザーの削除はできません。';

    //変更と削除チェック
    public static final String ERR_MS17 = 'メールでのご連絡先の変更と削除の申請は同時に受け付けることは出来ません。';


    /* ログインユーザーの連絡先情報での登録権限を返す */
    public static String checkAuthority(Boolean optionFlg,NotifyInfo__c ninfo,String loginuserEmail){

        String authorityStr=AUTH_NOT_VIEW;
        Integer limitnum = 10;
        if(optionFlg) limitnum = 20;

        for(Integer loopnum = 0;loopnum < limitnum;loopnum++){
            Integer namenum = loopnum + 1;
            String otheremail = (String) ninfo.get('Etc'+namenum+'_Mail__c');
            if(loginuserEmail.equals(otheremail)){
                //権限
                authorityStr = (String) ninfo.get('Etc'+namenum+'_Permission__c');
            }
        }
        return authorityStr;
    }

    /* ログインユーザーの連絡先情報での存在を確認する */
    //2023.08.28 comment out
    // public static Boolean checkExistNotify(Boolean optionFlg,NotifyInfo__c ninfo,String loginuserEmail){

    //     Boolean authorityFlg = false;
    //     Integer limitnum = 10;
    //     if(optionFlg) limitnum = 20;

    //     for(Integer loopnum = 0;loopnum < limitnum;loopnum++){
    //         Integer namenum = loopnum + 1;
    //         String otheremail = (String) ninfo.get('Etc'+namenum+'_Mail__c');
    //         if(loginuserEmail.equals(otheremail)){
    //             authorityFlg = true;
    //         }
    //     }
    //     return authorityFlg;
    // }

    public static boolean chkDiffMailRenrakusaki(NotifyInfo__c ni,NotifyInfo__c oldni){
        Boolean apiFlg = false;
        for(Integer roopnum=1;roopnum<21;roopnum++){

            //古いオブジェクトと比較して変更があれば、追加・変更を定義する
            String currentChgList = (String)ni.get('Etc'+ roopnum + '_ChgList__c');
            String oldChgList = (String)oldni.get('Etc'+ roopnum + '_ChgList__c');
            //変更前の変更種別が「追加」かつ変更後の変更種別が「追加」の場合は変更種別は「追加」のままにする 2023.04.17
            if('追加'.equals(oldChgList) && '追加'.equals(currentChgList)){
                apiFlg = true;
                continue;
            }

            if(String.isNotBlank((String)ni.get('Etc'+  roopnum + '_Name__c'))){
                if(!((String)ni.get('Etc'+  roopnum + '_Name__c')).equals((String)oldni.get('Etc'+  roopnum + '_Name__c'))){
                    if(String.isBlank((String)oldni.get('Etc'+  roopnum + '_Name__c'))){
                        ni.put('Etc'+ roopnum + '_ChgList__c','追加');
                        apiFlg = true;
                        continue;
                    }else{ //2023.02.28 分岐追加　
                        ni.put('Etc'+ roopnum + '_ChgList__c','変更');
                        apiFlg = true;
                        continue;
                    }
                }else if(String.isNotBlank((String)ni.get('Etc'+  roopnum + '_Mail__c')) && !((String)ni.get('Etc'+  roopnum + '_Mail__c')).equals((String)oldni.get('Etc'+  roopnum + '_Mail__c'))){
                    ni.put('Etc'+ roopnum + '_ChgList__c','変更');
                    apiFlg = true;
                    continue;
                }else if(((boolean)ni.get('Etc'+  roopnum + '_AlertContact__c') && !(boolean)oldni.get('Etc'+  roopnum + '_AlertContact__c'))
                || (!(boolean)ni.get('Etc'+  roopnum + '_AlertContact__c') && (boolean)oldni.get('Etc'+  roopnum + '_AlertContact__c'))){
                    ni.put('Etc'+ roopnum + '_ChgList__c','変更');
                    apiFlg = true;
                    continue;
                }else if(((boolean)ni.get('Etc'+  roopnum + '_OtherThanAlertContact__c') && !(boolean)oldni.get('Etc'+  roopnum + '_OtherThanAlertContact__c'))
                || (!(boolean)ni.get('Etc'+  roopnum + '_OtherThanAlertContact__c') && (boolean)oldni.get('Etc'+  roopnum + '_OtherThanAlertContact__c'))){
                    ni.put('Etc'+ roopnum + '_ChgList__c','変更');
                    apiFlg = true;
                    continue;
                }else if(String.isNotBlank((String)ni.get('Etc'+  roopnum + '_Company__c')) && !((String)ni.get('Etc'+  roopnum + '_Company__c')).equals((String)oldni.get('Etc'+  roopnum + '_Company__c'))){
                    //2023.03.06 add
                    ni.put('Etc'+ roopnum + '_ChgList__c','変更');
                    apiFlg = true;
                    continue;
                }

                if(String.isBlank((String)ni.get('Etc'+ roopnum + '_ChgList__c'))){
                    if((Boolean)ni.get('Etc'+ roopnum + '_Del__c')){
                        ni.put('Etc'+ roopnum + '_ChgList__c','削除');
                        apiFlg = true;
                    }
                    currentChgList = (String)ni.get('Etc'+ roopnum + '_ChgList__c');
                    //String oldChgList = (String)oldni.get('Etc'+ roopnum + '_ChgList__c');
                    if('削除'.equals(currentChgList) && !currentChgList.equals(oldChgList)){
                        apiFlg = true;
                    }
                }
            }
        }
        return apiFlg;
    }

    public static NotifyInfo__c jikangaiReinput(String on_display_order1,String on_display_order2,String on_display_order3,String off_display_order1,String off_display_order2,String off_display_order3,NotifyInfo__c notifyinfo){

        Boolean diffFlg = false;

        NotifyInfo__c tempNotifyInfo = notifyInfo.clone(false,true,false,false);
        
        //営業時間内
        if('2'.equals(on_display_order1)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'1','2','In');
            diffFlg = true;
        }else if('3'.equals(on_display_order1)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'1','3','In');
            diffFlg = true;
        }
        if('1'.equals(on_display_order2)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'2','1','In');
            diffFlg = true;
        }else if('3'.equals(on_display_order2)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'2','3','In');
            diffFlg = true;
        }
        if('1'.equals(on_display_order3)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'3','1','In');
            diffFlg = true;
        }else if('2'.equals(on_display_order3)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'3','2','In');
            diffFlg = true;
        }

        //営業時間外
        if('2'.equals(off_display_order1)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'1','2','Out');
            diffFlg = true;
        }else if('3'.equals(off_display_order1)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'1','3','Out');
            diffFlg = true;
        }
        if('1'.equals(off_display_order2)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'2','1','Out');
            diffFlg = true;
        }else if('3'.equals(off_display_order2)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'2','3','Out');
            diffFlg = true;
        }
        if('1'.equals(off_display_order3)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'3','1','Out');
            diffFlg = true;
        }else if('2'.equals(off_display_order3)){
            tempNotifyInfo = setTelRenrakusaki(tempNotifyInfo,notifyinfo,'3','2','Out');
            diffFlg = true;
        }

        if(diffFlg){
            for(Integer loopnum = 1;loopnum < 4;loopnum++){
                notifyInfo.put('In'+loopnum+'_Del__c',tempNotifyInfo.get('In'+loopnum+'_Del__c'));
                notifyInfo.put('In'+loopnum+'_Name__c',tempNotifyInfo.get('In'+loopnum+'_Name__c'));
                notifyInfo.put('In'+loopnum+'_Kana__c',tempNotifyInfo.get('In'+loopnum+'_Kana__c'));
                notifyInfo.put('In'+loopnum+'_Company__c',tempNotifyInfo.get('In'+loopnum+'_Company__c'));
                notifyInfo.put('In'+loopnum+'_Tel__c',tempNotifyInfo.get('In'+loopnum+'_Tel__c'));
                
                notifyInfo.put('Out'+loopnum+'_Del__c',tempNotifyInfo.get('Out'+loopnum+'_Del__c'));
                notifyInfo.put('Out'+loopnum+'_Name__c',tempNotifyInfo.get('Out'+loopnum+'_Name__c'));
                notifyInfo.put('Out'+loopnum+'_Kana__c',tempNotifyInfo.get('Out'+loopnum+'_Kana__c'));
                notifyInfo.put('Out'+loopnum+'_Company__c',tempNotifyInfo.get('Out'+loopnum+'_Company__c'));
                notifyInfo.put('Out'+loopnum+'_Tel__c',tempNotifyInfo.get('Out'+loopnum+'_Tel__c'));
            }
        }
        return notifyInfo;
    }

    private static NotifyInfo__c setTelRenrakusaki(NotifyInfo__c tempNotifyinfo,NotifyInfo__c notifyInfo,String orgNumber,String destNumeber,String type){
        tempNotifyinfo.put(type + destNumeber + '_Del__c',notifyInfo.get(type + orgNumber + '_Del__c'));
        tempNotifyinfo.put(type + destNumeber + '_Name__c',notifyInfo.get(type + orgNumber + '_Name__c'));
        tempNotifyinfo.put(type + destNumeber + '_Kana__c',notifyInfo.get(type + orgNumber + '_Kana__c'));
        tempNotifyinfo.put(type + destNumeber + '_Company__c',notifyInfo.get(type + orgNumber + '_Company__c'));
        tempNotifyinfo.put(type + destNumeber + '_Tel__c',notifyInfo.get(type + orgNumber + '_Tel__c'));
        return tempNotifyinfo;
    }

    public static NotifyInfo__c deleteTelRenrakusaki(NotifyInfo__c notifyInfo){
        for(Integer loopnum = 1;loopnum < 4;loopnum++){
            if((Boolean)notifyInfo.get('In'+loopnum+'_Del__c')){
                notifyInfo.put('In'+loopnum+'_Del__c',false);
                notifyInfo.put('In'+loopnum+'_Name__c','');
                notifyInfo.put('In'+loopnum+'_Kana__c','');
                notifyInfo.put('In'+loopnum+'_Company__c','');
                notifyInfo.put('In'+loopnum+'_Tel__c','');
            }
            if((Boolean)notifyInfo.get('Out'+loopnum+'_Del__c')){
                notifyInfo.put('Out'+loopnum+'_Del__c',false);
                notifyInfo.put('Out'+loopnum+'_Name__c','');
                notifyInfo.put('Out'+loopnum+'_Kana__c','');
                notifyInfo.put('Out'+loopnum+'_Company__c','');
                notifyInfo.put('Out'+loopnum+'_Tel__c','');
            }
        }
        return notifyInfo;
    }

    public static boolean checkInputContents(Boolean operater,Boolean optionFlg,NotifyInfo__c notifyInfo,String useremail){
        boolean chkflg = false;
        Integer limitnum = 10;
        if(optionFlg) limitnum = 20;
        //営業曜日チェック
        if(String.isBlank(notifyInfo.Week__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS1));
            chkflg = true;
        }
        
        //営業時間チェック1
        //0:00 ～23:59 スタート
        //0:00 ～23:59 end
        Boolean timeChkFlg = false;

         //営業時間チェック
        if(notifyInfo.BusinessHoursSt__c > notifyInfo.BusinessHoursEd__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS3));
            timeChkFlg = true;
            chkflg = true;
        }
        
        //連絡先チェック(営業時間中)
        // Boolean intimeNoRegistFlg = false;
        // Boolean intimeRegistErrorFlg = false;
        // for(Integer loopnum = 1;loopnum < 4;loopnum++){
        //     String name = (String) notifyInfo.get('In'+loopnum+'_Name__c');
        //     String kana = (String) notifyInfo.get('In'+loopnum+'_Kana__c');
        //     String company = (String) notifyInfo.get('In'+loopnum+'_Company__c');
        //     String tel = (String) notifyInfo.get('In'+loopnum+'_Tel__c');
        //     if(String.isNotBlank(name)){
        //         intimeNoRegistFlg = true;
        //     }
        //     List<String> joinStrings = new List<String>();
        //     joinStrings.add(name);
        //     joinStrings.add(kana);
        //     joinStrings.add(company);
        //     joinStrings.add(tel);
        //     String joinStr = String.join(joinStrings,'');
        //     if(String.isNotBlank(joinStr)){
        //         if(String.isBlank(name) || String.isBlank(kana) || String.isBlank(company) || String.isBlank(tel)){
        //             intimeRegistErrorFlg = true;
        //         }
        //     }
        // }
        // if(!intimeNoRegistFlg){
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS4));
        //     chkflg = true;
        // }
        // if(intimeRegistErrorFlg){
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS5));
        //     chkflg = true;
        // }
        
        //連絡先チェック(営業時間外)
        // Boolean outtimeNoRegistFlg = false;
        // Boolean outtimeRegistErrorFlg = false;
        // for(Integer loopnum = 1;loopnum < 4;loopnum++){
        //     String name = (String) notifyInfo.get('Out'+loopnum+'_Name__c');
        //     String kana = (String) notifyInfo.get('Out'+loopnum+'_Kana__c');
        //     String company = (String) notifyInfo.get('Out'+loopnum+'_Company__c');
        //     String tel = (String) notifyInfo.get('Out'+loopnum+'_Tel__c');
        //     if(String.isNotBlank(name)){
        //         outtimeNoRegistFlg = true;
        //     }
        //     List<String> joinStrings = new List<String>();
        //     joinStrings.add(name);
        //     joinStrings.add(kana);
        //     joinStrings.add(company);
        //     joinStrings.add(tel);
        //     String joinStr = String.join(joinStrings,'');
        //     if(String.isNotBlank(joinStr)){
        //         if(String.isBlank(name) || String.isBlank(kana) || String.isBlank(company) || String.isBlank(tel)){
        //             outtimeRegistErrorFlg = true;
        //         }
        //     }

        // }
        // if(!outtimeNoRegistFlg){
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS6));
        //     chkflg = true;
        // }
        // if(outtimeRegistErrorFlg){
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS7));
        //     chkflg = true;
        // }

        //2巡してもつながらない場合の連絡先
        if(String.isBlank(notifyInfo.Exception__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS8));
            chkflg = true;
        }

        //メールでのご連絡先チェック
        Boolean noMailFlg = true;               //メールアドレスの登録が一件もない
        Boolean mailRegistFlg = true;           //名前・会社名・Email・権限設定の設定がされていない
        Boolean alertNoFlg = true;              //アラートの連絡先設定なし
        Boolean alertExceptNoFlg = true;        //アラート以外の連絡先設定なし
        // Boolean monthlySendNoFlg = false;       //月次レポート送付の設定なし　//2023.07.10 comment out
        Boolean mailChofukuFlg = false;         //メールアドレスの重複あり
        Boolean editorFlg = false;              //編集権限設定なし
        Boolean loguinUserDeleteFlg = false;    //ログインユーザー削除不可

        for(Integer loopnum = 1;loopnum < limitnum+1 ;loopnum++){
            
            String mail = (String) notifyInfo.get('Etc'+loopnum+'_Mail__c');
            String name = (String) notifyInfo.get('Etc'+loopnum+'_Name__c');
            String company = (String) notifyInfo.get('Etc'+loopnum+'_Company__c');
            String permission = (String) notifyInfo.get('Etc'+loopnum+'_Permission__c');
            Boolean alertchk = (Boolean) notifyInfo.get('Etc'+loopnum+'_AlertContact__c');
            Boolean alertExcptchk = (Boolean) notifyInfo.get('Etc'+loopnum+'_OtherThanAlertContact__c');
            Boolean monthlySendchk = (Boolean) notifyInfo.get('Etc'+loopnum+'_MonthlyReportSender__c');
            Boolean deletechk = (Boolean) notifyInfo.get('Etc'+loopnum+'_Del__c');
            // System.debug('**==**== mail' + loopnum + ' ==>' + mail);
            // System.debug('**==**== name' + loopnum + ' ==>' + name);
            // System.debug('**==**== company' + loopnum + ' ==>' + company);
            // System.debug('**==**== permission' + loopnum + ' ==>' + permission);
            // System.debug('**==**== alertchk' + loopnum + ' ==>' + alertchk);
            // System.debug('**==**== monthlySendchk' + loopnum + ' ==>' + monthlySendchk);

            List<String> joinStrings = new List<String>();
            joinStrings.add(name);
            joinStrings.add(mail);
            joinStrings.add(company);
            joinStrings.add(permission);
            String joinStr = String.join(joinStrings,'');
            if(String.isNotBlank(joinStr)){
                if(String.isBlank(name) || String.isBlank(mail) || String.isBlank(company) || String.isBlank(permission)){
                    mailRegistFlg = false;
                }
            }
            if(String.isNotBlank(mail)){
                noMailFlg = false;
            }
            //アラートのご連絡先
            if(alertchk){
                alertNoFlg = false;
            }
            //アラート以外のご連絡先
            if(alertExcptchk){
                alertExceptNoFlg = false;
            }
            //月次レポートの送付先  //2023.07.10 comment out
            // if(monthlySendchk){
            //     monthlySendNoFlg = true;
            // }
            //編集可ユーザーの場合
            if('編集可'.equals(permission)){
                editorFlg = true;
            }
            //ログインユーザーで削除チェックが入っている場合
            if(String.isNotBlank(useremail) && useremail.equals(mail) && deletechk){
                loguinUserDeleteFlg = true;
            }

            for(Integer loopnum2 = loopnum + 1 ;loopnum2 < limitnum+1 ;loopnum2++){
                String hikakuEmail = (String) notifyInfo.get('Etc'+ loopnum2 +'_Mail__c');
                if(String.isNotBlank(hikakuEmail) && hikakuEmail.equals(mail)){
                    mailChofukuFlg = true;
                }
            }
        }
        //メールアドレスの登録なし
        if(!operater && noMailFlg){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS9));
            chkflg = true;
        }
        //名前・会社名・メールアドレス・権限設定が揃ってない
        if(!mailRegistFlg){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS10));
            chkflg = true;
        }
        //アラートのご連絡先
        if(!operater && alertNoFlg){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS12));
            chkflg = true;
        }
        //アラート以外のご連絡先
        if(!operater && alertExceptNoFlg){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS13));
            chkflg = true;
        }
        //月次レポートの送付先 //2023.07.10 comment out
        // if(!operater && !monthlySendNoFlg){
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS14));
        //     chkflg = true;
        // }
        //同一メールの連絡先チェック
        if(mailChofukuFlg){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS11));
            chkflg = true;
        }
        //編集権限ゼロの場合
        if(!operater && !editorFlg){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS15));
            chkflg = true;
        }
        //ログインユーザーで削除チェックが入っている場合
        if(loguinUserDeleteFlg){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS16));
            chkflg = true;
        }
        return chkflg;
    }
    public static boolean checkDeleteChg(Boolean optionFlg,NotifyInfo__c notifyInfo){
        boolean chkflg = false;
        Integer limitnum = 10;
        if(optionFlg) limitnum = 20;

        //メールでのご連絡先チェック
        Boolean deleteAndChgFlg = false;        //削除と変更が同時になされていないか

        for(Integer loopnum = 1;loopnum < limitnum+1 ;loopnum++){
            
            String chgshubetsu = (String) notifyInfo.get('Etc'+loopnum+'_ChgList__c');
            Boolean deletechk = (Boolean) notifyInfo.get('Etc'+loopnum+'_Del__c');

            //変更と削除が同時にされている場合
            if(deletechk && '変更'.equals(chgshubetsu)){
                deleteAndChgFlg = true;
                notifyInfo.put('Etc'+ loopnum + '_ChgList__c','');
            }
            //登録がない行の削除がチェックされていればクリアする
            if(deletechk && String.isBlank((String)notifyInfo.get('Etc'+loopnum+'_Name__c'))){
                notifyInfo.put('Etc'+loopnum+'_Del__c',false);
            }
        }

        //変更と削除が同時にされている場合
        if(deleteAndChgFlg){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MS17));
            chkflg = true;
        }
        return chkflg;
    }

    public static NotifyInfo__c moveUpTelRenrakusaki(NotifyInfo__c notifyInfo){
        notifyInfo = moveUpTelRenrakusaki(notifyInfo,'In');
        notifyInfo = moveUpTelRenrakusaki(notifyInfo,'Out');
        return notifyInfo;
    }

    private static NotifyInfo__c moveUpTelRenrakusaki(NotifyInfo__c notifyInfo,String type){
        Integer maxnum = 4;
        //2023.04.27 add start
        Boolean tsumeruFlg = true;
        do {
            Integer tsumelCount = 0;
            for(Integer loopnum=1;loopnum<maxnum-1;loopnum++){
                List<String> joinStrings = new List<String>();
                joinStrings.add((String) notifyInfo.get(type + loopnum + '_Name__c'));
                joinStrings.add((String) notifyInfo.get(type + loopnum + '_Kana__c'));
                joinStrings.add((String) notifyInfo.get(type + loopnum + '_Company__c'));
                joinStrings.add((String) notifyInfo.get(type + loopnum + '_Tel__c'));
                String tmpName = String.join(joinStrings,'');
                if(String.isBlank(tmpName)){
                    Integer nextIndex = loopnum + 1;
                    notifyInfo = clearTelAddress(notifyInfo,loopnum,type);

                    List<String> nextjoinStrings = new List<String>();
                    nextjoinStrings.add((String) notifyInfo.get(type + nextIndex + '_Name__c'));
                    nextjoinStrings.add((String) notifyInfo.get(type + nextIndex + '_Kana__c'));
                    nextjoinStrings.add((String) notifyInfo.get(type + nextIndex + '_Company__c'));
                    nextjoinStrings.add((String) notifyInfo.get(type + nextIndex + '_Tel__c'));
                    String tmpNextName = String.join(nextjoinStrings,'');
                    if(String.isNotBlank(tmpNextName)){
                        notifyInfo.put(type + loopnum + '_Del__c',notifyInfo.get(type + nextIndex + '_Del__c'));
                        notifyInfo.put(type + loopnum + '_Name__c',notifyInfo.get(type + nextIndex + '_Name__c'));
                        notifyInfo.put(type + loopnum + '_Kana__c',notifyInfo.get(type + nextIndex + '_Kana__c'));
                        notifyInfo.put(type + loopnum + '_Company__c',notifyInfo.get(type + nextIndex + '_Company__c'));
                        notifyInfo.put(type + loopnum + '_Tel__c',notifyInfo.get(type + nextIndex + '_Tel__c'));
                    
                        notifyInfo = clearTelAddress(notifyInfo,nextIndex,type);
                        tsumelCount++;
                    }
                }
            }
            if(tsumelCount==0) tsumeruFlg = false;
        } while (tsumeruFlg);
        //2023.04.27 add end

        //2023.04.27 comment out
        // for(Integer loopnum=1;loopnum<maxnum-1;loopnum++){
        //     // String tmpName = (String) notifyInfo.get(type + loopnum + '_Name__c');
        //     List<String> joinStrings = new List<String>();
        //     joinStrings.add((String) notifyInfo.get(type + loopnum + '_Name__c'));
        //     joinStrings.add((String) notifyInfo.get(type + loopnum + '_Kana__c'));
        //     joinStrings.add((String) notifyInfo.get(type + loopnum + '_Company__c'));
        //     joinStrings.add((String) notifyInfo.get(type + loopnum + '_Tel__c'));
        //     String tmpName = String.join(joinStrings,'');
        //     if(String.isBlank(tmpName)){
        //         Integer nextIndex = loopnum + 1;
        //         notifyInfo = clearTelAddress(notifyInfo,loopnum,type);

        //         notifyInfo.put(type + loopnum + '_Del__c',notifyInfo.get(type + nextIndex + '_Del__c'));
        //         notifyInfo.put(type + loopnum + '_Name__c',notifyInfo.get(type + nextIndex + '_Name__c'));
        //         notifyInfo.put(type + loopnum + '_Kana__c',notifyInfo.get(type + nextIndex + '_Kana__c'));
        //         notifyInfo.put(type + loopnum + '_Company__c',notifyInfo.get(type + nextIndex + '_Company__c'));
        //         notifyInfo.put(type + loopnum + '_Tel__c',notifyInfo.get(type + nextIndex + '_Tel__c'));
                
        //         notifyInfo = clearTelAddress(notifyInfo,nextIndex,type);
        //     }
        // }

        return notifyInfo;
    }

    private static NotifyInfo__c clearTelAddress(NotifyInfo__c notifyInfo,Integer loopnum,String type){
        notifyInfo.put(type + loopnum +'_Del__c',false);
        notifyInfo.put(type + loopnum +'_Name__c','');
        notifyInfo.put(type + loopnum +'_Kana__c','');
        notifyInfo.put(type + loopnum +'_Company__c','');
        notifyInfo.put(type + loopnum +'_Tel__c','');

        return notifyInfo;
    }
}