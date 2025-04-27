@isTest
public class OfficeMultiHttpCalloutMock implements HttpCalloutMock {

    public Boolean isToken { get; set; }
    public Boolean isGraphApiContants { get; set; }
    public Boolean isGraphApiContantsExistence { get; set; }
    public Boolean isGraphApiGroups { get; set; }
    public Boolean isGraphApiGroupsExistence { get; set; }
    public Boolean isApiContants { get; set; }
    public Boolean isApiGroups { get; set; }
    
    // 0:正常　9:エラー　8:要求したトークンなし
    public Integer iToken { get; set; }
    // 0:正常　9:エラー　8:連絡先なし
    public Integer iGraphApiContants { get; set; }
    // 0:正常　9:エラー　8:配布先なし
    public Integer iGraphApiGroups { get; set; }
    // 0:正常　9:エラー
    public Integer iApiContants { get; set; }
    public Integer iApiGroups { get; set; }
        
//    public OfficeMultiHttpCalloutMock(Boolean isToken, Boolean isContants, Boolean isContantsExistence,
//        Boolean isGroups, Boolean isGroupsExistence, Boolean isContantsApi, Boolean isGroupsApi) {
//        this.isToken = isToken;
//        this.isGraphApiContants = isContants;
//        this.isGraphApiContantsExistence = isContantsExistence;
//        this.isGraphApiGroups = isGroups;
//        this.isGraphApiGroupsExistence = isGroupsExistence;
//        this.isApiContants = isContantsApi;
//        this.isApiGroups = isGroupsApi;
//    }
    
    public OfficeMultiHttpCalloutMock(Integer iToken, Integer iGraphApiContants, Integer iGraphApiGroups,
            Integer iApiContants, Integer iApiGroups) {
        this.iToken = iToken;
        this.iGraphApiContants = iGraphApiContants;
        this.iGraphApiGroups = iGraphApiGroups;
        this.iApiContants = iApiContants;
        this.iApiGroups = iApiGroups;
    }

    /**
     * レスポンス
     */    
    public HTTPResponse respond(HTTPRequest req) {

        System.debug('★mock★req★' + req);

        HttpResponse res = new HttpResponse();

        // トークン取得
        if (req.getEndpoint().contains('https://login.microsoftonline.com/')) {
            Map<String, Object> bodyMap;
            //if (isToken) {
            if(iToken <> 9) {
                res.setStatusCode(200);
                if(iToken == 0) {
                    bodyMap = new Map<String, Object>{
                        'access_token' => 'eyJ0eXAiOiJKV1QiLCJub25jZSI6IkE2Z2J5eERQN2M3YUw3Nk14NzVHMDNXdkZDX01CSVpDdTdqTmJTdmQ5ZU0iLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kZjYwODdkNy04YjFkLTRhMGUtOTk2ZS01MTVjMzEyOGEyMWIvIiwiaWF0IjoxNjYxMjI4MTkwLCJuYmYiOjE2NjEyMjgxOTAsImV4cCI6MTY2MTIzMjA5MCwiYWlvIjoiRTJaZ1lEQ3RpK1p6YmZ5dElTU3hZaDNEamJQc0FBPT0iLCJhcHBfZGlzc',
                        'token_type' => 'Bearer'
                    };
                } else {
                    bodyMap = new Map<String, Object>{};
                }
            } else {
                res.setStatusCode(201);
                bodyMap = new Map<String, Object>{};
            }
            res.setBody(JSON.serialize(bodyMap));
        
        // Microsoft Graph取得（連絡先）
        } else if (req.getEndpoint().contains('https://graph.microsoft.com/v1.0/contacts')) {
            Map<String, Object> bodyMap;
            Map<String, Object> valueMap = new Map<String, Object>{
                'id' => 1
            };
            if (iGraphApiContants <> 9) {
                res.setStatusCode(200);
                if(iGraphApiContants == 0){
                    bodyMap = new Map<String, Object>{
                        '@odata.context' => 'https://graph.microsoft.com/v1.0/$metadata#groups',
                        'value' => new List<Object>{valueMap}
                    };
                } else {
                    bodyMap = new Map<String, Object>{
                        '@odata.context' => 'https://graph.microsoft.com/v1.0/$metadata#groups',
                        'value' => new List<Object>()
                    };
                }
            } else {
                res.setStatusCode(201);
                bodyMap = new Map<String, Object>{
                    '@odata.context' => 'https://graph.microsoft.com/v1.0/$metadata#groups',
                    'value' => new List<Object>()
                };
            }
            res.setBody(JSON.serialize(bodyMap));

        // Microsoft Graph取得（配布グループ）
        } else if (req.getEndpoint().contains('https://graph.microsoft.com/v1.0/groups')) {
            Map<String, Object> bodyMap;
            Map<String, Object> valueMap = new Map<String, Object>{
                'id' => 1
            };
            if (iGraphApiGroups <> 9) {
                res.setStatusCode(200);
                if(iGraphApiGroups == 0){
                    bodyMap = new Map<String, Object>{
                        '@odata.context' => 'https://graph.microsoft.com/v1.0/$metadata#groups',
                        'value' => new List<Object>{valueMap}
                    };
                } else {
                    bodyMap = new Map<String, Object>{
                        '@odata.context' => 'https://graph.microsoft.com/v1.0/$metadata#groups',
                        'value' => new List<Object>()
                    };
                }
            } else {
                res.setStatusCode(201);
                bodyMap = new Map<String, Object>{
                    '@odata.context' => 'https://graph.microsoft.com/v1.0/$metadata#groups',
                    'value' => new List<Object>()
                };
            }
            res.setBody(JSON.serialize(bodyMap));

            
        // 追加
        } else if (req.getEndpoint() == System.Label.PS_OFFICEAPI_URI + '/new_mail_contact.php') {
        //} else if (req.getEndpoint() == 'http://35.76.212.2/o365-tools/sandbox/new_mail_contact.php') {
            Map<String, Object> bodyMap;
            if (iApiContants == 0) {
                bodyMap = new Map<String, Object>{
                    'result' => '[SUCCESS]#New-MailContact'
                };
            } else {
                bodyMap = new Map<String, Object>{
                    'result' => '[ERR]#New-MailContact Error'
                };
            }
            res.setStatusCode(200);
            res.setBody(JSON.serialize(bodyMap));
        
        // 変更
        } else if (req.getEndpoint() == System.Label.PS_OFFICEAPI_URI + '/update_mail_contact.php') {
        //} else if (req.getEndpoint() == 'http://35.76.212.2/o365-tools/sandbox/update_mail_contact.php') {
            Map<String, Object> bodyMap;
            if(iApiContants == 0){
                bodyMap = new Map<String, Object>{
                    'result' => '[SUCCESS]#Set-MailContact'
                };
            } else {
                bodyMap = new Map<String, Object>{
                    'result' => '[ERR]#Set-MailContact Error'
                };
            }
            res.setStatusCode(200);
            res.setBody(JSON.serialize(bodyMap));
        
        // 削除
        } else if (req.getEndpoint() == System.Label.PS_OFFICEAPI_URI + '/delete_mail_contact.php') {
        //} else if (req.getEndpoint() == 'http://35.76.212.2/o365-tools/sandbox/delete_mail_contact.php') {
            Map<String, Object> bodyMap;
            if(iApiContants == 0){
                bodyMap = new Map<String, Object>{
                    'result' => '[SUCCESS]#Remove-MailContact'
                };
            } else {
                bodyMap = new Map<String, Object>{
                    'result' => '[ERR]#Remove-MailContact Error'
                };
            }
            res.setStatusCode(200);
            res.setBody(JSON.serialize(bodyMap));

        // メーリングリスト追加
        } else if (req.getEndpoint() == System.Label.PS_OFFICEAPI_URI + '/add_ml_member.php') {
        //} else if (req.getEndpoint() == 'http://35.76.212.2/o365-tools/sandbox/add_ml_member.php') {
            Map<String, Object> bodyMap;
            if(iApiGroups == 0){
                bodyMap = new Map<String, Object>{
                    'result' => '[SUCCESS]#Add-DistributionGroupMember'
                };
            } else {
                bodyMap = new Map<String, Object>{
                    'result' => '[ERR]#Add-DistributionGroupMember Error'
                };
            }
            res.setStatusCode(200);
            res.setBody(JSON.serialize(bodyMap));
        
        // メーリングリスト削除
        } else if (req.getEndpoint() == System.Label.PS_OFFICEAPI_URI + '/del_ml_member.php') {
        //} else if (req.getEndpoint() == 'http://35.76.212.2/o365-tools/sandbox/del_ml_member.php') {
            Map<String, Object> bodyMap;
            if(iApiGroups == 0){
                bodyMap = new Map<String, Object>{
                    'result' => '[SUCCESS]#Remove-DistributionGroupMember'
                };
            } else {
                bodyMap = new Map<String, Object>{
                    'result' => '[ERR]#Remove-DistributionGroupMember Error'
                };
            }
            res.setStatusCode(200);
            res.setBody(JSON.serialize(bodyMap));

        // 配布グループ削除
        } else if (req.getEndpoint() == System.Label.PS_OFFICEAPI_URI + '/del_ml_member.php') {
        //} else if (req.getEndpoint() == 'http://35.76.212.2/o365-tools/sandbox/del_ml_member.php') {
        Map<String, Object> bodyMap;
            if(iApiGroups == 0){
                bodyMap = new Map<String, Object>{
                    'result' => '[SUCCESS]#Remove-DistributionGroup'
                };
            } else {
                bodyMap = new Map<String, Object>{
                    'result' => '[ERR]#Remove-DistributionGroup Error'
                };
            }
            res.setStatusCode(200);
            res.setBody(JSON.serialize(bodyMap));

        } 

        return res;
    }
}