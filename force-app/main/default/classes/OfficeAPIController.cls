/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2022 SKY365 Inc. All Rights Reserved.
 *
 * Office365連携APIコントローラクラス
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2022/08     Miura     新規作成
 ********************************************************************************/
public class OfficeAPIController {

    /* status code 200 */
    public static final Integer STATUS_CODE_200 = 200;
    /* status code 201 */
    public static final Integer STATUS_CODE_201 = 201;
    /* status code 204 */
    public static final Integer STATUS_CODE_204 = 204;
    /* status code 401 */
    public static final Integer STATUS_CODE_401 = 401;  //2023.05.25 add

    public static final Integer WAIT_TIME_MS = 4000;
    public static final Integer WAIT_TIME_MS3000 = 3000;

    /**
     * 案件が開始されたとき
     * 担当者が追加になったとき
     */
    public static Boolean executeCreate(NotifyInfo__c notifyInfo
        , Integer index, String name, String email, String process) {

        // Office365接続情報取得
        OfficeAPIRequester requester = new OfficeAPIRequester(null, email, notifyInfo.SendListAlert__c, name, process);
        
        // トークン取得
        HTTPResponse resToken = requester.requestToken();      
        if (resToken.getStatusCode() == STATUS_CODE_200) {
            Map<String, Object> resTokenMap = (Map<String, Object>) JSON.deserializeUntyped(resToken.getBody());
            if(resTokenMap.isEmpty()){
                // エラー時はエラーログ更新
                String msg = '[ERR]要求したトークンが存在しませんでした。';
                System.debug(msg);
                updateNotifyInfoErrorLog(notifyInfo, index, 'Officeトークン取得:トークンなし', resToken.getStatusCode(), null, msg);
                return false;
            }
        } else {
            // エラー時はエラーログ更新
            String msg = '[ERR]トークンの取得に失敗しました。';
            System.debug(msg);
            updateNotifyInfoErrorLog(notifyInfo, index, 'Officeトークン取得', resToken.getStatusCode(), null, msg);
            return false;
        }
        
        // 連絡先の検索　2023.06.07 addGroupMemberへ移動
        // HTTPResponse resSearch = requester.searchData('contacts', null);
        // if (resSearch.getStatusCode() == STATUS_CODE_200) {
        //     Map<String, Object> resGraphMap = (Map<String, Object>) JSON.deserializeUntyped(resSearch.getBody());
        //     List<Object> dataValue = (List<Object>)resGraphMap.get('value');
        //     if(!dataValue.isEmpty()){
        //         // 処理成功時
        //         System.debug('[SUCCESS]連絡先登録済み');
        //         // return true;
        //     } else {
        //         // 連絡先の登録    
        //         HttpResponse res = requester.newContact();
        //         // if(res.getBody().contains('ERR')){ //2023.05.25 認証エラー時にスルーしてしまうため以下の修正を加える
        //         if(res.getBody().contains('ERR') || res.getStatusCode()==STATUS_CODE_401){
        //             // エラー時はエラーログ更新
        //             System.debug('[ERR]連絡先の登録に失敗しました。');
        //             updateNotifyInfoErrorLog(notifyInfo, index, 'Office連絡先登録', res.getStatusCode(), null, res.getBody());
        //             return false;
        //         }
        //     }
        //     wait(WAIT_TIME_MS);
        // } else {
        //     // エラー時はエラーログ更新
        //     String msg = '[ERR]Microsoft Graphの呼び出しに失敗しました。';
        //     System.debug(msg);
        //     updateNotifyInfoErrorLog(notifyInfo, index, 'Office連絡先検索：Microsoft Graphの呼び出し', resSearch.getStatusCode(), null, msg);
        //     return false;
        // }

        Boolean ret = true;

        String fieldApiName_AlertContact = 'Etc' + index + '_' + 'AlertContact__c';
        Boolean isAlertContact = (Boolean) notifyInfo.get(fieldApiName_AlertContact);
        // アラートのご連絡先ONの場合
        if (isAlertContact) {
            // requester.countupHaifuListOnCount(); //2023.06.15 add 2023.06.21 comment out
            ret = addGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlert__c);
        }

        if (ret == false) return ret;

        wait(WAIT_TIME_MS);
        
        String fieldApiName_OtherThanAlertContact = 'Etc' + index + '_' + 'OtherThanAlertContact__c';
        Boolean isOtherThanAlertContact = (Boolean) notifyInfo.get(fieldApiName_OtherThanAlertContact);
        // アラート以外のご連絡先ONの場合
        if (isOtherThanAlertContact) {
            // requester.countupHaifuListOnCount();//2023.06.15 add 2023.06.21 comment out
            ret = addGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlertExpet__c);
        }

        wait(WAIT_TIME_MS);
        
        return ret;
    }

    /**
     * @param SendListAlert 配布リストのメールアドレス
     * @return 処理結果
     */
    private static Boolean addGroupMember(OfficeAPIRequester requester, NotifyInfo__c notifyInfo, Integer index, String email, String SendListAlert) {

        // 配布グループの検索
        HTTPResponse resSearch2 = requester.searchData('groups', SendListAlert);
        if (resSearch2.getStatusCode() == STATUS_CODE_200) {
            Map<String, Object> resGraphMap = (Map<String, Object>) JSON.deserializeUntyped(resSearch2.getBody());
            List<Object> dataValue = (List<Object>)resGraphMap.get('value');
            if(dataValue.isEmpty()){
                // エラー時はエラーログ更新
                String msg = '[ERR]配布グループが存在しませんでした。';
                System.debug(msg);
                updateNotifyInfoErrorLog(notifyInfo, index, 'Office配布グループ検索', resSearch2.getStatusCode(), SendListAlert, msg);
                return false;
            }
            //2023.06.08 add start　配布グループがあれば、連絡先があるか確認し、なければ連絡先追加する。
            // if(requester.getHaifuListCount() < 2 || !requester.getContactExistFlg()){ //2023.06.21 comment out
                HTTPResponse resSearchContacts = requester.searchData('contacts', null);
                if (resSearchContacts.getStatusCode() == STATUS_CODE_200) { 
                    Map<String, Object> resGraphContactMap = (Map<String, Object>) JSON.deserializeUntyped(resSearchContacts.getBody());
                    List<Object> dataValueContact = (List<Object>)resGraphContactMap.get('value');
                    System.debug('**==**== dataValueContact => ' + dataValueContact);
                    if(!dataValueContact.isEmpty()){
                        // 処理成功時
                        System.debug('[SUCCESS]連絡先登録済み');
                    } else {
                        // 連絡先の登録    
                        HttpResponse res = requester.newContact();
                        // if(res.getBody().contains('ERR') || res.getStatusCode()==STATUS_CODE_401){ //2023.06.21 comment out
                        if(res!=null && (res.getBody().contains('ERR') || res.getStatusCode()==STATUS_CODE_401)){  //2021.06.21 add
                            // エラー時はエラーログ更新
                            System.debug('[ERR]連絡先の登録に失敗しました。');
                            updateNotifyInfoErrorLog(notifyInfo, index, 'Office連絡先登録', res.getStatusCode(), null, res.getBody());
                            return false;
                        }
                    }
                    wait(WAIT_TIME_MS);
                } else {
                    // エラー時はエラーログ更新
                    String msg = '[ERR]Microsoft Graphの呼び出しに失敗しました。';
                    System.debug(msg);
                    updateNotifyInfoErrorLog(notifyInfo, index, 'Office連絡先検索：Microsoft Graphの呼び出し', resSearchContacts.getStatusCode(), null, msg);
                    return false;
                }
            // } //2023.06.21 comment out
            //2023.06.08 add end

            // 配布グループの登録
            HttpResponse res2 = requester.addGroupMember(SendListAlert, email);
            if(res2.getBody().contains('ERR')){
                // エラー時はエラーログ更新
                System.debug('[ERR]配布グループの登録に失敗しました。');
                updateNotifyInfoErrorLog(notifyInfo, index, 'Office配布グループ登録', res2.getStatusCode(), SendListAlert, res2.getBody());
                return false;
            }
        } else {
            // エラー時はエラーログ更新
            String msg = '[ERR]Microsoft Graphの呼び出しに失敗しました。';
            System.debug(msg);
            updateNotifyInfoErrorLog(notifyInfo, index, 'Office配布グループ検索：Microsoft Graphの呼び出し', resSearch2.getStatusCode(), SendListAlert, msg);
            return false;
        }

        return true;
    }

    /**
     * 担当者が減ったとき
     */
    public static Boolean executeDelete(NotifyInfo__c notifyInfo
        , Integer index, String name, String email, String process) {
        
        // Office365接続情報取得
        OfficeAPIRequester requester = new OfficeAPIRequester(null, email, notifyInfo.SendListAlert__c, name, process);
        
        // トークン取得
        HTTPResponse resToken = requester.requestToken();      
        if (resToken.getStatusCode() == STATUS_CODE_200) {
            Map<String, Object> resTokenMap = (Map<String, Object>) JSON.deserializeUntyped(resToken.getBody());
            if(resTokenMap.isEmpty()){
                // エラー時はエラーログ更新
                String msg = '[ERR]要求したトークンが存在しませんでした。';
                System.debug(msg);
                updateNotifyInfoErrorLog(notifyInfo, index, 'Officeトークン取得:トークンなし', resToken.getStatusCode(), null, msg);
                return false;
            }
        } else {
            // エラー時はエラーログ更新
            String msg = '[ERR]トークンの取得に失敗しました。';
            System.debug(msg);
            updateNotifyInfoErrorLog(notifyInfo, index, 'Officeトークン取得', resToken.getStatusCode(), null, msg);
            return false;
        }

        // 連絡先の検索
        HTTPResponse resSearch = requester.searchData('contacts', null);
        if (resSearch.getStatusCode() == STATUS_CODE_200) {
            Map<String, Object> resGraphMap = (Map<String, Object>) JSON.deserializeUntyped(resSearch.getBody());
            List<Object> dataValue = (List<Object>)resGraphMap.get('value');
            if(dataValue.isEmpty()){
                // 処理成功時
                System.debug('[SUCCESS]処理済のため処理終了');
                return true;
            }        
        } else {
            // エラー時はエラーログ更新
            String msg = '[ERR]Microsoft Graphの呼び出しに失敗しました。';
            System.debug(msg);
            updateNotifyInfoErrorLog(notifyInfo, index, 'Office連絡先検索：Microsoft Graphの呼び出し', resSearch.getStatusCode(), null, msg);
            return false;
        }

        wait(WAIT_TIME_MS);

        Boolean ret = true;

        String fieldApiName_AlertContact = 'Etc' + index + '_' + 'AlertContact__c';
        Boolean isAlertContact = (Boolean) notifyInfo.get(fieldApiName_AlertContact);
        // アラートのご連絡先ONの場合
        if (isAlertContact) {
            ret = delGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlert__c);
        }

        if (ret == false) return ret;

        wait(WAIT_TIME_MS);
        
        String fieldApiName_OtherThanAlertContact = 'Etc' + index + '_' + 'OtherThanAlertContact__c';
        Boolean isOtherThanAlertContact = (Boolean) notifyInfo.get(fieldApiName_OtherThanAlertContact);
        // アラート以外のご連絡先ONの場合
        if (isOtherThanAlertContact) {
            ret = delGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlertExpet__c);
        }

        wait(WAIT_TIME_MS);
        
        return ret;
    }

    /**
     * @param SendListAlert 配布リストのメールアドレス
     * @return 処理結果
     */
    private static Boolean delGroupMember(OfficeAPIRequester requester, NotifyInfo__c notifyInfo, Integer index, String mail, String SendListAlert) {

        // 配布グループの検索
        HTTPResponse resSearch2 = requester.searchData('groups', SendListAlert);
        if (resSearch2.getStatusCode() == STATUS_CODE_200) {
            Map<String, Object> resGraphMap = (Map<String, Object>) JSON.deserializeUntyped(resSearch2.getBody());
            List<Object> dataValue = (List<Object>)resGraphMap.get('value');
            if(dataValue.isEmpty()){
                // エラー時はエラーログ更新
                String msg = '[ERR]配布グループが存在しませんでした。';
                System.debug(msg);
                updateNotifyInfoErrorLog(notifyInfo, index, 'Office配布グループ検索', resSearch2.getStatusCode(), SendListAlert, msg);
                return false;
            }

            // 配布グループの削除
            HttpResponse res2 = requester.removeGroupMember(SendListAlert, mail);
            if(res2.getBody().contains('ERR')){
                // エラー時はエラーログ更新
                updateNotifyInfoErrorLog(notifyInfo, index, 'Office配布グループ削除', res2.getStatusCode(), SendListAlert, res2.getBody());
                return false;
            }
        } else {
            // エラー時はエラーログ更新
            String msg = '[ERR]Microsoft Graphの呼び出しに失敗しました。';
            System.debug(msg);
            updateNotifyInfoErrorLog(notifyInfo, index, 'Office配布グループ検索', resSearch2.getStatusCode(), SendListAlert, msg);
            return false;
        }

        return true;
    }

    /**
     * 担当者の氏名やメアド（属性情報）が変更になったとき
     */
    public static Boolean executeUpdate(NotifyInfo__c notifyInfo
        , Integer index, String name, String email, NotifyInfo__c pastNotifyInfo, String process) {

        String fieldApiName_Mail = 'Etc' + index + '_' + 'Mail__c';
        String emailBefor = (String) pastNotifyInfo.get(fieldApiName_Mail);
        String fieldApiName_AlertContact = 'Etc' + index + '_' + 'AlertContact__c'; //2023.05.24 add
        Boolean isOldAlertContact = (Boolean) pastNotifyInfo.get(fieldApiName_AlertContact); //2023.05.24 add
        Boolean isNewAlertContact = (Boolean) notifyInfo.get(fieldApiName_AlertContact);     //2023.05.24 add
        String fieldApiName_OtherThanAlertContact = 'Etc' + index + '_' + 'OtherThanAlertContact__c';  //2023.05.24 add
        Boolean isOldOtherThanAlertContact = (Boolean) pastNotifyInfo.get(fieldApiName_OtherThanAlertContact);  //2023.05.24 add
        Boolean isNewOtherThanAlertContact = (Boolean) notifyInfo.get(fieldApiName_OtherThanAlertContact);  //2023.05.24 add


        Boolean contactExistFlg = true;   //2023.05.24 add
        Boolean mailDiffFlg = false;   //2023.05.24 add
        Boolean alertOffOnFlg = false;   //2023.05.24 add
        Boolean alertOtherOffOnFlg = false;   //2023.05.24 add
        if(!emailBefor.equals(email)){ //2023.05.24 add
            mailDiffFlg = true;
        }
                
        // Office365接続情報取得
        OfficeAPIRequester requester = new OfficeAPIRequester(email, emailBefor, notifyInfo.SendListAlert__c, name, process);
        
        if (!isOldAlertContact && isNewAlertContact) { //2023.05.24 add
            alertOffOnFlg = true;
        }
        if (!isOldOtherThanAlertContact && isNewOtherThanAlertContact) { //2023.05.24 add
            alertOtherOffOnFlg = true;
        }
        
        // トークン取得
        HTTPResponse resToken = requester.requestToken();      
        if (resToken.getStatusCode() == STATUS_CODE_200) {
            Map<String, Object> resTokenMap = (Map<String, Object>) JSON.deserializeUntyped(resToken.getBody());
            if(resTokenMap.isEmpty()){
                // エラー時はエラーログ更新
                String msg = '[ERR]要求したトークンが存在しませんでした。';
                System.debug(msg);
                updateNotifyInfoErrorLog(notifyInfo, index, 'Officeトークン取得:トークンなし', resToken.getStatusCode(), null, msg);
                return false;
            }
        } else {
            // エラー時はエラーログ更新
            String msg = '[ERR]トークンの取得に失敗しました。';
            System.debug(msg);
            updateNotifyInfoErrorLog(notifyInfo, index, 'Officeトークン取得', resToken.getStatusCode(), null, msg);
            return false;
        }

        // 連絡先の検索
        HTTPResponse resSearch = requester.searchData('contacts', null);
        if (resSearch.getStatusCode() == STATUS_CODE_200) { 
            Map<String, Object> resGraphMap = (Map<String, Object>) JSON.deserializeUntyped(resSearch.getBody());
            List<Object> dataValue = (List<Object>)resGraphMap.get('value');
            System.debug('**== dataValue =>' + dataValue);
            if(dataValue.isEmpty()){
                // エラー時はエラーログ更新
                String msg = '[ERR]連絡先がありません。';
                System.debug(msg);
                contactExistFlg = false;    //2023.05.24 add
                //以下２パターンの時、連絡先を作成する
                //1.メールアドレスの変更時　配布リストのどちらかがONであれば連絡先を作成
                //2.メールアドレスの変更がない場合は、配布リスト２種がOFFからどちらかONへ変更された場合
                if((mailDiffFlg && (isNewAlertContact || isNewOtherThanAlertContact)) || (alertOffOnFlg || alertOtherOffOnFlg)){ //2023.06.21 comment out
                    // 連絡先の登録
                    // Office365接続情報取得
                    // OfficeAPIRequester requesterNew = new OfficeAPIRequester(null, email, notifyInfo.SendListAlert__c, name, '追加'); 2023.06.22 comment out
                    // HttpRespo÷nse res = requesterNew.newContact();  2023.06.22 comment out
                    //すでに追加しようとしているメールアドレスが連絡先として登録されているかを確認する 2023.06.26 add
                    HTTPResponse newSearch = requester.searchData('updateContacts', null);
                    if (newSearch.getStatusCode() == STATUS_CODE_200) { 
                        Map<String, Object> resNewGraphMap = (Map<String, Object>) JSON.deserializeUntyped(newSearch.getBody());
                        List<Object> newDataValue = (List<Object>)resNewGraphMap.get('value');
                        System.debug('**== newDataValue =>' + newDataValue);
                        if(!newDataValue.isEmpty()){
                            // 処理成功時
                            System.debug('[SUCCESS]連絡先登録済み');
                        }else{
                            HttpResponse res = requester.newContactForUpdate();  //2023.06.22 add
                            // if(res.getBody().contains('ERR') || res.getStatusCode()==STATUS_CODE_401){ //2023.06.21 comment out
                            if(res!=null && (res.getBody().contains('ERR') || res.getStatusCode()==STATUS_CODE_401)){ //2023.06.21 add
                                // エラー時はエラーログ更新
                                System.debug('[ERR]連絡先の登録に失敗しました。');
                                updateNotifyInfoErrorLog(notifyInfo, index, 'Office連絡先登録', res.getStatusCode(), null, res.getBody());
                                return false;
                            }
                        }
                    }
                }
                else if(!alertOffOnFlg && !alertOtherOffOnFlg){
                    //配布リストのどちらもOFFの場合
                    return true;
                }
                else{
                    updateNotifyInfoErrorLog(notifyInfo, index, 'Office連絡先検索', resSearch.getStatusCode(), null, msg);
                    return false;
                }
            }
            // requester.setContactExistFlg(); //2023.06.21 comment out
            // 連絡先の更新 
            // 連絡先がない場合、新規作成するので、ここは通らない 2023.03.26 add
            if(contactExistFlg){
                //新規に登録するメールが存在するかを確認する 2023.06.26 add start
                HTTPResponse newSearch = requester.searchData('updateContacts', null);
                if (newSearch.getStatusCode() == STATUS_CODE_200) { 
                    Map<String, Object> resNewGraphMap = (Map<String, Object>) JSON.deserializeUntyped(newSearch.getBody());
                    List<Object> newDataValue = (List<Object>)resNewGraphMap.get('value');
                    System.debug('**== newDataValue =>' + newDataValue);
                    if(!newDataValue.isEmpty()){
                        // 処理成功時　すでにあるので、Office側の情報を変更しない。
                        System.debug('[SUCCESS]連絡先登録済み');
                    }else{
                        HttpResponse res = requester.setMailContact();
                        if(res.getBody().contains('ERR')){
                            // エラー時はエラーログ更新
                            System.debug('[ERR]連絡先の更新に失敗しました。');
                            updateNotifyInfoErrorLog(notifyInfo, index, 'Office連絡先更新', res.getStatusCode(), null, res.getBody());
                            return false;
                        }
                    }
                }else{
                    updateNotifyInfoErrorLog(notifyInfo, index, '連絡先変更の新メールアドレス検索失敗', newSearch.getStatusCode(), null, newSearch.getBody());
                    return false;
                }
            }

        } else {
            // エラー時はエラーログ更新
            String msg = '[ERR]Microsoft Graphの呼び出しに失敗しました。';
            System.debug(msg);
            updateNotifyInfoErrorLog(notifyInfo, index, 'Office連絡先検索：Microsoft Graphの呼び出し', resSearch.getStatusCode(), null, msg);
            return false;
        }

        wait(WAIT_TIME_MS);

        Boolean ret = true;

        // String fieldApiName_AlertContact = 'Etc' + index + '_' + 'AlertContact__c'; 2023.05.24 comment out 
        // Boolean isOldAlertContact = (Boolean) pastNotifyInfo.get(fieldApiName_AlertContact); 2023.05.25 comment out
        // Boolean isNewAlertContact = (Boolean) notifyInfo.get(fieldApiName_AlertContact);  2023.05.25 comment out
        // アラートのご連絡先ON⇒OFF
        if(!contactExistFlg && isNewAlertContact){
            // 連絡先がなくて作成した場合は、ONの場合に配布リストに追加する
            System.debug('**==**== 連絡先作成し、アラートの連絡先ON **==**==');
           ret = addGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlert__c);
           wait(WAIT_TIME_MS3000);  //2023.07.03 add
        }
        // else if (isOldAlertContact && !isNewAlertContact) {  //2023.07.03 comment out
        //     // 配布リストから連絡先を削除する
        //     ret = delGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlert__c);
        // }
        // アラートのご連絡先OFF⇒ON
        else if (!isOldAlertContact && isNewAlertContact) {
            // 配布リストへ連絡先を追加する
            ret = addGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlert__c);
            wait(WAIT_TIME_MS3000);  //2023.07.03 add
        }

        if (ret == false) return ret;
        // wait(WAIT_TIME_MS3000);  //2023.07.03 comment out

        if (isOldAlertContact && !isNewAlertContact) {  //2023.07.03 add
            if(mailDiffFlg){
                // 配布リストから古いメールアドレスを削除する
                ret = delGroupMember(requester, notifyInfo, index, emailBefor, notifyInfo.SendListAlert__c);
            }else{
                ret = delGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlert__c);
            }
            wait(WAIT_TIME_MS3000);  //2023.07.03 add
        }

        if (ret == false) return ret; //2023.07.03 add
        // wait(WAIT_TIME_MS);   //2023.07.03 comment out
        

        // String fieldApiName_OtherThanAlertContact = 'Etc' + index + '_' + 'OtherThanAlertContact__c'; 2023.05.24 comment out
        // Boolean isOldOtherThanAlertContact = (Boolean) pastNotifyInfo.get(fieldApiName_OtherThanAlertContact); 2023.05.24 comment out
        // Boolean isNewOtherThanAlertContact = (Boolean) notifyInfo.get(fieldApiName_OtherThanAlertContact); 2023.05.24 comment out
        // アラート以外のご連絡先ON⇒OFF
        if(!contactExistFlg && isNewOtherThanAlertContact){
            // 連絡先がなくて作成した場合は、ONの場合に配布リストに追加する
            System.debug('**==**== 連絡先作成し、アラート以外の連絡先ON **==**==');
            ret = addGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlertExpet__c);
            wait(WAIT_TIME_MS3000); //2023.07.03 add
        }
        // else if (isOldOtherThanAlertContact && !isNewOtherThanAlertContact) {   //2023.07.03 comment out
        //     // 配布リストから連絡先を削除する
        //     ret = delGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlertExpet__c);
        // }
        // アラート以外のご連絡先OFF⇒ON
        else if (!isOldOtherThanAlertContact && isNewOtherThanAlertContact) {
            // 配布リストへ連絡先を追加する
            ret = addGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlertExpet__c);
            wait(WAIT_TIME_MS3000); //2023.07.03 add
        }
        if (ret == false) return ret; //2023.06.16 add

        // wait(WAIT_TIME_MS);  //2023.06.23 comment out
        // wait(WAIT_TIME_MS3000); //2023.06.23 add  //2023.07.03 comment out

        if (isOldOtherThanAlertContact && !isNewOtherThanAlertContact) {  //2023.07.03 add
            if(mailDiffFlg){
                // 配布リストから古いメールアドレスを削除する
                ret = delGroupMember(requester, notifyInfo, index, emailBefor, notifyInfo.SendListAlertExpet__c);
            }else{
                ret = delGroupMember(requester, notifyInfo, index, email, notifyInfo.SendListAlertExpet__c);
            }
            wait(WAIT_TIME_MS3000); //2023.07.03 add
        }

        if (ret == false) return ret; //2023.07.03 add
        
        
        return true;
    }

    /**
     * エラー時はエラーログを更新する
     */
    private static void updateNotifyInfoErrorLog(NotifyInfo__c notifyInfo, Integer index, String process, Integer statusCode, String SendListAlert, String detail) {

        String errorLog = '【処理】' + process;
        errorLog += '【ステータスコード】' + statusCode;
        if (String.isNotBlank(SendListAlert)) errorLog += '【配布リスト】' + SendListAlert;
        errorLog += '【詳細】' + detail;
        if (errorLog.length() > 255) errorLog = errorLog.substring(0, 255);

        // エラー時はエラーログ更新
        notifyInfo.put('Etc' + index + '_ErrorLog__c', errorLog);
        update notifyInfo;
    }

    private static void wait(Integer millisecond) {
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < millisecond) {
            finishTime = DateTime.now().getTime();
        }
    }
}