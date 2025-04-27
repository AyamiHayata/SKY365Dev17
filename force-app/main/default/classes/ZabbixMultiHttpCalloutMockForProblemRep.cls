/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * パートナーサイト Zabbix障害レポートZabbixResponceMock
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2024/1      新規作成     kikuchi
 ********************************************************************************/
public with sharing class ZabbixMultiHttpCalloutMockForProblemRep implements HttpCalloutMock {
    /**
     * レスポンス
     */    
    public HTTPResponse respond(HTTPRequest req) {
        Map<String, Object> reqBodyMap = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
        String method = (String) reqBodyMap.get('method');
        Map<String, Object> bodyMap;
        
        if (method == 'user.login') {
            bodyMap = new Map<String, Object>{
                'jsonrpc' => '2.0',
                'result' => '0424bd59b807674191e7d77572075f33',
                'id' => 1
            };            
        } else if (method == 'host.get') {
            List<Object> hosts = new List<Object>();
            hosts.add(new Map<String, Object>{'hostid' => '1', 'host' => 'test-host-1', 'name' => ''});
            hosts.add(new Map<String, Object>{'hostid' => '2', 'host' => 'test-host-2', 'name' => ''});
            bodyMap = new Map<String, Object>{
                'jsonrpc' => '2.0',
                'result' => hosts,
                'id' => 1
            };
        } else if (method == 'trigger.get') {
            List<Object> host1 = new List<Object>();
            host1.add(new Map<String, Object>{'hostid' => '1', 'host' => 'test-host-1', 'name' => ''});
            List<Object> host2 = new List<Object>();
            host2.add(new Map<String, Object>{'hostid' => '2', 'host' => 'test-host-2', 'name' => ''});

            
            List<Object> triggers = new List<Object>();
            triggers.add(new Map<String, Object>{'triggerid' => '1', 'description' => 'test-trigger-1', 'priority' => '1', 'lastchange' => '1682054565', 'hosts' => host1});
            triggers.add(new Map<String, Object>{'triggerid' => '2', 'description' => 'test-trigger-2', 'priority' => '2', 'lastchange' => '1682054565', 'hosts' => host2});
            bodyMap = new Map<String, Object>{
                'jsonrpc' => '2.0',
                'result' => triggers,
                'id' => 1
            };
        } else if (method == 'user.logout') {
            bodyMap = new Map<String, Object>{
                'jsonrpc' => '2.0',
                'result' => true,
                'id' => 1
            };
        } else {
                
        }
        HttpResponse res = new HttpResponse();
        res.setBody(JSON.serialize(bodyMap));
        res.setStatusCode(200);        
        return res;        
    }
}