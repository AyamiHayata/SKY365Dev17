@isTest
public class ZendeskMultiHttpCalloutMock implements HttpCalloutMock {

    public Boolean isExistenceUser { get; set; }
    public Boolean isStatusError { get; set; }  //2023.03.06 add 
    private Boolean isIdentifySearchStsError = false;//2023.10.13 add 
    private Boolean isIdentifyUpdateStsError = false;  //2023.10.13 add 

    public ZendeskMultiHttpCalloutMock(Boolean isExistenceUser) {
        this.isExistenceUser = isExistenceUser;
        this.isStatusError = false; //2023.03.06 add 
    }
    //2023.03.06 add 4lines
    public ZendeskMultiHttpCalloutMock(Boolean isExistenceUser,Boolean isStatusError) {
        this.isExistenceUser = isExistenceUser;
        this.isStatusError = isStatusError;
    }

    /**
     * レスポンス
     */    
    public HTTPResponse respond(HTTPRequest req) {
        
        String body;
        Integer statusCode;

        if (req.getEndpoint().contains(ZendeskAPIRequester.ZENDESK_API_BASE_URI + '/api/v2/users/search?query=email:')) {
            //Zendeskユーザー検索
            Map<String, Object> bodyMap;
            if (isExistenceUser) {
                Map<String, Object> userMap = new Map<String, Object>{
                    'id' => 1,
                    'name' => 'test'
                };
                bodyMap = new Map<String, Object>{
                    'users' => new List<Object>{userMap},
                    'count' => 1
                };
            } else {
                bodyMap = new Map<String, Object>{
                    'users' => null,
                    'count' => 0
                };
            }
            body = JSON.serialize(bodyMap);
            if(isStatusError){
                statusCode = 201;
            }else{
                statusCode = 200;
            }
            
        } else if (req.getEndpoint() == ZendeskAPIRequester.ZENDESK_API_BASE_URI + '/api/v2/users') {
            //Zendeskユーザー登録
            Map<String, Object> userMap = new Map<String, Object>{
                'id' => 1,
                'name' => 'テスト',
                'email' => 'test@sky365.co.jp.ut',
                'details' => 'テスト会社'
            };
            Map<String, Object> bodyMap = new Map<String, Object>{
                'user' => userMap
            };
            body = JSON.serialize(bodyMap);
            statusCode = 201;
        } else if (req.getEndpoint() == ZendeskAPIRequester.ZENDESK_API_BASE_URI + '/api/v2/organization_memberships') {
            //Zendesk組織メンバー登録
            Map<String, Object> orgMembershipMap = new Map<String, Object>{
                'id' => 1,
                'user_id' => 2,
                'organization_id' => 3
            };
            Map<String, Object> bodyMap = new Map<String, Object>{
                'organization_membership' => orgMembershipMap
            };
            body = JSON.serialize(bodyMap);
            statusCode = 201;
        } else if (req.getEndpoint().contains('/organization_memberships.json')) {
            //Zendesk組織メンバー検索
            Map<String, Object> orgMembershipMap = new Map<String, Object>{
                'id' => 1,
                'user_id' => 2,
                'organization_id' => 12345
            };
            Map<String, Object> bodyMap = new Map<String, Object>{
                'organization_memberships' => new List<Object>{orgMembershipMap}
            };
            body = JSON.serialize(bodyMap);
            statusCode = 200;
        } else if (req.getEndpoint().contains('/api/v2/organization_memberships/')) {
            //Zendesk組織メンバー削除
            //2023.03.06 add 9lines
            if(!isStatusError){
                statusCode = 204;
            }else{
                Map<String, Object> bodyMap = new Map<String, Object>{
                    'description' => 'Error Test'
                };
                body = JSON.serialize(bodyMap);
                statusCode = 201;
            }
        } else if (req.getEndpoint() == ZendeskAPIRequester.ZENDESK_API_BASE_URI + '/api/v2/users/1') {
            //Zendeskユーザー更新
            Map<String, Object> userMap = new Map<String, Object>{
                'id' => 1,
                'name' => '更新テスト',
                'details' => '更新テスト会社'
            };
            Map<String, Object> bodyMap = new Map<String, Object>{
                'user' => userMap
            };
            //2023.03.06 add 5lines
            if(!isStatusError){
                statusCode = 200;
            }else{
                statusCode = 201;
                List<Object> userErrorList = new List<Object>();
                Map<String, Object> userIderrorMap = new Map<String, Object>();
                userIderrorMap.put('description','ERROR TEST');
                userErrorList.add(userIderrorMap);

                List<Object> emailErrorList = new List<Object>();
                Map<String, Object> emailErrorMap = new Map<String, Object>();
                emailErrorMap.put('description','ERROR TEST');
                emailErrorList.add(emailErrorMap);

                Map<String, Object> errorMap2 = new Map<String, Object>{
                    'user_id' => userErrorList
                    ,'email' => emailErrorList
                };
                bodyMap.put('details',errorMap2);
                bodyMap.put('description','ERROR TEST');
            }
            body = JSON.serialize(bodyMap);
        } else if (req.getEndpoint() == ZendeskAPIRequester.ZENDESK_API_BASE_URI + '/api/v2/users/1/identities') {
            //ZendeskユーザIdentity検索
            Map<String, Object> identityMap = new Map<String, Object>{
                'id' => 2,
                'primary' => true,
                'type' => 'email',
                'user_id' => 1,
                'value' => 'test@sky365.co.jp.ut'
            };
            Map<String, Object> bodyMap = new Map<String, Object>{
                'identities' => new List<Object>{identityMap}
            };
            body = JSON.serialize(bodyMap);
            statusCode = 200;
        } else if (req.getEndpoint() == ZendeskAPIRequester.ZENDESK_API_BASE_URI + '/api/v2/users/1/identities/2') {
            //ZendeskユーザーID(アイデンティティ)更新
            Map<String, Object> identityMap = new Map<String, Object>{
                'id' => 2,
                'primary' => true,
                'type' => 'email',
                'user_id' => 1,
                'value' => 'upd-test@sky365.co.jp.ut'
            };
            Map<String, Object> bodyMap = new Map<String, Object>{
                'identities' => new List<Object>{identityMap}
            };
            body = JSON.serialize(bodyMap);
            //2023.03.06 add 5lines
            if(!isStatusError){
                statusCode = 200;
            }else{
                statusCode = 201;
            }
            
        // }
        //2023.03.15 add else if
        }else if (req.getEndpoint().contains(ZendeskAPIRequester.ZENDESK_API_BASE_URI + '/api/v2/users/1/organizations.json')) {
            //Zendesk組織取得
            Map<String, Object> organization = new Map<String, Object>{
                'id' => 1,
                'organization_id' => 12345
            };
            List<Map<String,Object>> organizationList = new List<Map<String,Object>>();
            organizationList.add(organization);
            Map<String, Object> bodyMap = new Map<String, Object>{
                'organizations' => organizationList
            };
            body = JSON.serialize(bodyMap);
            statusCode = 200;
        //2023.03.24 add
        }else if (req.getEndpoint().contains(ZendeskAPIRequester.ZENDESK_API_BASE_URI + '/api/v2/search.json?query=type:ticket')) {
            //Zendeskチケット取得
            Map<String, Object> organization = new Map<String, Object>{
                'id' => 1,
                'organization_id' => 12345
            };
            List<Map<String,Object>> organizationList = new List<Map<String,Object>>();
            organizationList.add(organization);
            Map<String, Object> bodyMap = new Map<String, Object>{
                'organizations' => organizationList
            };
            body = JSON.serialize(bodyMap);
            statusCode = 200;
        //2023.10.13 add
        }else if (req.getEndpoint().contains(ZendeskAPIRequester.ZENDESK_API_BASE_URI + '/api/v2/users/12345/sessions')) {
            //Zendeskセッション削除
            if (isExistenceUser) {
                statusCode = 204;
            }else{
                statusCode = 404;
            }
        }


        HttpResponse res = new HttpResponse();
        if (String.isNotBlank(body)) res.setBody(body);
        res.setStatusCode(statusCode);

        return res;
    }
}