public class ZendeskAPIController {

    /* status code 200 */
    public static final Integer STATUS_CODE_200 = 200;
    /* status code 201 */
    public static final Integer STATUS_CODE_201 = 201;
    /* status code 204 */
    public static final Integer STATUS_CODE_204 = 204;

    /**
     * 案件が開始されたとき、担当者が追加になったとき
     * Zendeskのユーザを作成する
     * 既にユーザが存在する場合は対象組織へのメンバーシップ登録のみを行う
     * API呼出最大2回
     * 
     * @param notifyInfo 連絡先情報
     * @param index 処理対象インデックス
     * @param orgid Zendesk組織ID
     * @param name 氏名
     * @param company 会社名
     * @param email メールアドレス
     */
    public static void executeCreateUser(NotifyInfo__c notifyInfo, Integer index
        , String orgid, String name, String company, String email) {

        ZendeskAPIRequester requester = new ZendeskAPIRequester();

        // Zendeskユーザ検索
        HttpResponse res = requester.getZendeskUser(email);
        String userid;
        Map<String, Object> resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
        if (res.getStatusCode() == STATUS_CODE_200) {
            userid = getZendeskUserid(email, resMap);
        } else {
            // エラー時はエラーログ更新
            updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskユーザ検索', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
            return;
        }

        // ユーザが存在しない場合
        if (String.isBlank(userid)) {
            // Zendeskユーザ作成
            res = requester.createZendeskUser(orgid, name, company, email);
            if (res.getStatusCode() <> STATUS_CODE_201) {
                resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                // エラー時はエラーログ更新
                updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskユーザ作成', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
                return;
            }
        }
        // ユーザが存在する場合
        else {
            //2023.03.14 add start
            boolean ngflg = checkAddBeforeZendeskUser(notifyinfo,userid);
            if(ngflg){
                updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendesk登録前チェック', 0, '既に他の取引先に紐づく組織があり、自動処理ができません。手動にて対応ください。', null);
                return;
            }
            //2023.03.14 add end

            // Zendeskメンバーシップ作成
            res = requester.createZendeskMembership(orgid, userid);
            if (res.getStatusCode() <> STATUS_CODE_201) {
                resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                // エラー時はエラーログ更新
                updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskメンバーシップ作成', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
                return;
            }
            // 2023/1/23 SF_CORE_DEV-148 start
            res = requester.updateZendeskUser(userid, name, company);
            if (res.getStatusCode() <> STATUS_CODE_200) {
                resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                // エラー時はエラーログ更新
                updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskユーザ更新', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
                return;
            }
            // 2023/1/23 SF_CORE_DEV-148 end
        }
        //他の連絡先情報の更新処理を行う2023.02.23 add 
        ReplaceContactInfo rc = new ReplaceContactInfo(email,(String)notifyInfo.get('Etc' + index + '_Name__c'),(String)notifyInfo.get('Etc' + index + '_Mail__c'),(String)notifyInfo.get('Etc' + index + '_Company__c'));
        rc.replace();

        // 処理成功時は連絡先情報フラグおよびエラーログを更新
        updateNotifyInfoSuccessful(notifyInfo, index, null);
    }

    /**
     * 担当者が減ったとき
     * 対象組織からユーザを削除する(メンバーシップ削除)
     * 対象組織にユーザが存在しない場合は何もしない
     * API呼出最大3回
     * 
     * @param notifyInfo 連絡先情報
     * @param index 処理対象インデックス
     * @param orgid Zendesk組織ID
     * @param email メールアドレス
     */
    public static void executeDeleteMembership(NotifyInfo__c notifyInfo, Integer index, String orgid, String email) {

        ZendeskAPIRequester requester = new ZendeskAPIRequester();

        // Zendeskユーザ検索
        HttpResponse res = requester.getZendeskUser(email);
        String userid;
        Map<String, Object> resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
        if (res.getStatusCode() == STATUS_CODE_200) {
            userid = getZendeskUserid(email, resMap);
            if (String.isBlank(userid)) {
                // エラー時はエラーログ更新
                updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskユーザ検索', res.getStatusCode(), 'ユーザ検索に失敗しました。再度Zendesk連携を実施してください。', null);
                return;
            }
        } else {
            // エラー時はエラーログ更新
            updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskユーザ検索', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
            return;
        }

        // ユーザが存在する場合
        if (String.isNotBlank(userid)) {
            // Zendeskメンバーシップ検索
            res = requester.searchZendeskMembership(orgid, userid);
            String membershipid;
            if (res.getStatusCode() == STATUS_CODE_200) {
                Map<String, Object> resultJson = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                List<Object> resMemberships =  (List<Object>) resultJson.get('organization_memberships');
                for (Object resMembership : resMemberships) {
                    Map<String, Object> tmpResMembership = (Map<String, Object>) resMembership;
                    if (String.valueOf((Long) tmpResMembership.get('organization_id')) == orgid) {
                        membershipid = String.valueOf((Long) tmpResMembership.get('id'));
                        break;
                    }
                }
            }
            if (String.isNotBlank(membershipid)) {
                //2023.03.23 削除前にチケット有無をチェック add start
                res = requester.getZendeskTickets(userid,orgid);
                if (res.getStatusCode() == STATUS_CODE_200) {
                    resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                    System.debug('**==**== resMap => ' + resMap);
                    Integer ticketCount = (Integer) resMap.get('count');
                    if(ticketCount!=null && ticketCount > 0){
                        // エラー時はエラーログ更新
                        updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendesk削除前チェック', 0, 'ユーザがリクエスタとなっているオープンチケットがあります。チケット対処後再度実行ください。', null);
                        return;
                    }
                }else {
                    // エラーの時は、エラーログ更新。
                    updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendesk削除前チェック', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
                    return;
                }
                //2023.03.23 削除前にチケット有無をチェック add end

                system.debug('★削除実行★');
                // Zendeskメンバーシップ削除
                res = requester.deleteZendeskMembership(membershipid);
                if (res.getStatusCode() <> STATUS_CODE_204) {
                    resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                    // エラー時はエラーログ更新
                    updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskメンバーシップ削除', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
                    return;
                }
            }
        }

        // 処理成功時は連絡先情報フラグおよびエラーログを更新
        updateNotifyInfoSuccessful(notifyInfo, index, '詰める');
    }

    /**
     * 担当者の氏名やメアド（属性情報）が変更になったとき
     * Zendeskのユーザを更新する
     * API呼出最大4回
     * 
     * @param notifyInfo 連絡先情報
     * @param index 処理対象インデックス
     * @param orgid Zendesk組織ID
     * @param email 変更前メールアドレス
     * @param name 氏名
     * @param company 会社名
     * @param newEmail 変更後メールアドレス
     */
    public static void executeUpdateUser(NotifyInfo__c notifyInfo, Integer index
        , String orgid, String email, String name, String company, String newEmail) {

        ZendeskAPIRequester requester = new ZendeskAPIRequester();

        // Zendeskユーザ検索
        HttpResponse res = requester.getZendeskUser(email);
        String userid;
        Map<String, Object> resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
        if (res.getStatusCode() == STATUS_CODE_200) {
            userid = getZendeskUserid(email, resMap);
            if (String.isBlank(userid)) {
                // エラー時はエラーログ更新
                updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskユーザ検索', res.getStatusCode(), 'ユーザ検索に失敗しました。再度Zendesk連携を実施してください。', null);
                return;
            }
        } else {
            // エラー時はエラーログ更新
            updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskユーザ検索', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
            return;
        }

        // ユーザが存在する場合
        if (String.isNotBlank(userid)) {
            // Zendeskユーザ更新(メールアドレス以外)
            res = requester.updateZendeskUser(userid, name, company);
            if (res.getStatusCode() <> STATUS_CODE_200) {
                resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                // エラー時はエラーログ更新
                updateNotifyInfoErrorLog(notifyInfo, index, email, null, 'Zendeskユーザ更新', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
                return;
            }
            if (email <> newEmail) {
                // ZendeskユーザIdentity検索
                res = requester.searchZendeskIdentity(userid);
                String identityid;
                if (res.getStatusCode() == STATUS_CODE_200) {
                    identityid = getIdentityid((Map<String, Object>) system.JSON.deserializeUntyped(res.getBody()));
                } else {
                    resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                    // エラー時はエラーログ更新
                    updateNotifyInfoErrorLog(notifyInfo, index, email, newEmail, 'ZendeskユーザIdentity検索', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
                    return;
                }
                if (String.isNotBlank(identityid)) {
                    // ZendeskユーザIdentity更新
                    res = requester.updateZendeskIdentity(userid, identityid, newEmail);
                    if (res.getStatusCode() <> STATUS_CODE_200) {
                        resMap = (Map<String, Object>) system.JSON.deserializeUntyped(res.getBody());
                        // エラー時はエラーログ更新
                        updateNotifyInfoErrorLog(notifyInfo, index, email, newEmail, 'ZendeskユーザIdentity更新', res.getStatusCode(), (String) resMap.get('description'), getErrorDetail((Map<String, Object>) resMap.get('details')));
                        return;
                    }
                }
            }
        }

        // 処理成功時は連絡先情報フラグおよびエラーログを更新
        updateNotifyInfoSuccessful(notifyInfo, index, null);
        //他の連絡先情報の更新処理を行う2023.02.23 add 
        // ReplaceContactInfo rc = new ReplaceContactInfo(email,(String)notifyInfo.get('Etc' + index + '_Name__c'),(String)notifyInfo.get('Etc' + index + '_Mail__c'));
        ReplaceContactInfo rc = new ReplaceContactInfo(email,(String)notifyInfo.get('Etc' + index + '_Name__c'),(String)notifyInfo.get('Etc' + index + '_Mail__c'),(String)notifyInfo.get('Etc' + index + '_Company__c'));
        rc.replace();
    }

    /**
     * 案件が終了したとき
     * Zendeskの組織を削除する
     * 最大100件
     * API呼出最大1回
     * 
     * @param orgids Zendesk組織IDのリスト
     * @return 成功：TRUE 失敗：FALSE
     */
    public static Boolean executeDeleteOrganizations(List<String> orgids) {

        ZendeskAPIRequester requester = new ZendeskAPIRequester();

        // Zendesk組織削除
        HttpResponse res = requester.deleteZendeskOrganizations(orgids);

        if (res.getStatusCode() <> STATUS_CODE_200) {
            return false;
        }

        return true;
    }
    /**
     * Logout時に
     * Zendeskのセッションを削除する
     * 
     * @param userid Zendesk組織IDのリスト
     * @return 成功：TRUE 失敗：FALSE
     */
    public static Boolean executeLogout(String userid) {

        ZendeskAPIRequester requester = new ZendeskAPIRequester();

        // Zendesk組織削除
        HttpResponse res = requester.deleteZendeskSession(userid);

        if (res.getStatusCode() <> STATUS_CODE_204) {
            return false;
        }

        return true;
    }

    /**
     * ユーザ検索時のレスポンスからユーザIDを取得する
     * @param email メールアドレス
     * @param resultJson Response Body
     * @return ユーザID
     */
    private static String getZendeskUserid(String email, Map<String, Object> resultJson) {

        Integer resCnt = (Integer) Integer.valueOf(resultJson.get('count'));

        List<Object> users = (List<Object>) resultJson.get('users');
        
        String userid;

        if (resCnt == 1) {
            Map<String, Object> resUser = (Map<String, Object>) users[0];
            userid = String.valueOf((Long) resUser.get('id'));
        }

        return userid;
    }

    /**
     * ユーザIdentity検索時のレスポンスからIdentity IDを取得する
     * @param resultJson Response Body
     * @return ユーザIdentity ID
     */
    private static String getIdentityid(Map<String, Object> resultJson) {

        Integer resCnt = (Integer) resultJson.get('count');

        String identityid;

        if (resCnt == 0) {
            identityid = null;
        } else {
            List<Object> resIdentities = (List<Object>) resultJson.get('identities');
            for (Object resIdentity : resIdentities) {
                Map<String, Object> tmpIdentity =  (Map<String, Object>) resIdentity;
                if ((String) tmpIdentity.get('type') == 'email'
                    && (Boolean) tmpIdentity.get('primary') == true) {
                    identityid = String.valueOf((Long) tmpIdentity.get('id'));
                    break;
                }
            }
        }

        return identityid;
    }

    /**
     * エラーメッセージを取得する
     * @param detailMap エラーレスポンス詳細
     * @return エラーメッセージ
     */
    private static String getErrorDetail(Map<String, Object> detailMap) {

        if (detailMap == null) return '';
        
        List<Object> errors;
        String msg = '';

        errors = (List<Object>) detailMap.get('user_id');
        if (errors <> null) {
            for (Object o : errors) {
                Map<String, Object> errorMap = (Map<String, Object>) o;
                msg += ' ' + errorMap.get('description');
            }
        }

        errors = (List<Object>) detailMap.get('email');
        if (errors <> null) {
            for (Object o : errors) {
                Map<String, Object> errorMap = (Map<String, Object>) o;
                msg += ' ' + errorMap.get('description');
            }
        }

        return msg.trim();
    }

    /**
     * 処理成功時は連絡先情報フラグおよびエラーログを更新を更新する
     * 
     * @param notifyInfo 連絡先情報
     * @param index 処理対象インデックス
     * @param chgList 変更種別（新規、変更時：NULL、削除時：「詰める」に更新）
     */
    @TestVisible
    private static void updateNotifyInfoSuccessful(NotifyInfo__c notifyInfo, Integer index, String chgList) {

        notifyInfo.put('Etc' + index + '_ChgList__c', chgList);
        notifyInfo.put('Etc' + index + '_ErrorLog__c', null);
        notifyInfo.ProcessingFlg__c = false;
        update notifyInfo;
    }

    /**
     * エラー時はエラーログを更新する
     * 
     * @param notifyInfo 連絡先情報
     * @param index 処理対象インデックス
     * @param email 変更前メールアドレス
     * @param newEmail 変更後メールアドレス
     * @param process 処理
     * @param statusCode ステータスコード
     */
    @TestVisible
    private static void updateNotifyInfoErrorLog(NotifyInfo__c notifyInfo, Integer index, String email, String newEmail, String process, Integer statusCode, String description, String detail) {

        String errorLog = '【処理】' + process;
        errorLog += '【メールアドレス】' + email;
        if (String.isNotBlank(newEmail)) errorLog += '【メールアドレス(変更後)】' + newEmail;
        errorLog += '【ステータスコード】' + statusCode;
        errorLog += '【説明】' + description;
        if (String.isNotBlank(detail)) errorLog += '【詳細】' + detail;
        if (errorLog.length() > 255) errorLog = errorLog.substring(0, 255);

        // エラー時はエラーログ更新
        notifyInfo.put('Etc' + index + '_ErrorLog__c', errorLog);
        notifyInfo.ProcessingFlg__c = false;
        update notifyInfo;
    }

    /**
     * 連絡情報にその他ユーザーを追加するときの事前チェック
     * @param notifyinfo 連絡先情報
     * @param adduserid 追加するZendeskユーザのId
     * @return エラーメッセージ
     */
    private static Boolean checkAddBeforeZendeskUser(NotifyInfo__c notifyinfo,String adduserid) {
        Boolean ngflg = false;
        //この連絡先情報と紐づく案件情報の取得
        List<Constitution_Common__c> currentConCommonList = [
            SELECT 
                ID
                ,Account__c
                ,Commercial_flow__c
            FROM Constitution_Common__c
            WHERE Id = :notifyInfo.ConstitutionCommon__c
            ];
        //追加しようとするユーザーが紐づく案件の情報の確認
        //組織IDの取得
        ZendeskAPIRequester requester = new ZendeskAPIRequester();
        HttpResponse rsponse = requester.getZendeskOrganizations(adduserid);
        Map<String, Object> result = (Map<String, Object>) system.JSON.deserializeUntyped(rsponse.getBody());
        List<Object> organizations = (List<Object>) result.get('organizations');
        List<String> organizationList = new List<String>();
        for (Object element : organizations) {
            Map<String, Object> eMap = (Map<String, Object>)element;
            organizationList.add(String.valueOf(eMap.get('id')));
        }
        //追加予定のユーザーの案件情報を取得する
System.debug('**==**== organizationList => ' + organizationList);
        List<Constitution_Common__c> addUserCclist = [
            SELECT
                Id
                ,Account__c
                ,Commercial_flow__c
            FROM Constitution_Common__c
            WHERE ZendeskOrganizationId__c in :organizationList or ZendeskOrganizationId2__c in :organizationList
        ];
        System.debug('**==**== addUserCclist => ' + addUserCclist);
        //取得した案件情報の取引先、商流が連絡先情報と紐づく案件情報の取引先、商流と一致するかを確認する
        String currentAccId = currentConCommonList.get(0).Account__c;
        String currentCoFlow = currentConCommonList.get(0).Commercial_flow__c;
        System.debug('**==**== currentAccId => ' + currentAccId);
        System.debug('**==**== currentCoFlow => ' + currentCoFlow);
        if(String.isBlank(currentAccId) || String.isBlank(currentCoFlow)){
            ngflg = true;
            return ngflg;
        }
        if(addUserCclist!=null && addUserCclist.size() > 0){
            for(Constitution_Common__c cc:addUserCclist){
                if(String.isBlank(cc.Account__c) || String.isBlank(cc.Commercial_flow__c)){
                    ngflg = true;
                    return ngflg;
                }
                if(!currentAccId.equals(cc.Account__c) || !currentCoFlow.equals(cc.Commercial_flow__c)){
                    ngflg = true;
                }
            }
        }
        
        return ngflg;
    }
}