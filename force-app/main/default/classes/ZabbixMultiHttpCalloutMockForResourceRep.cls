/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2021 SKY365 Inc. All Rights Reserved.
 *
 * パートナーサイト ZabbixリソースレポートMock
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2024/1      新規作成     
 ********************************************************************************/
public with sharing class ZabbixMultiHttpCalloutMockForResourceRep implements HttpCalloutMock{
    /**
     * レスポンス
     */    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();

        if(req.getEndpoint().contains('/zabbix/chart2.php')){
            String responseBody = 'This is a sample response body';
            res.setBodyAsBlob(Blob.valueOf(responseBody));
        }else if(req.getEndpoint().contains('/zabbix/index.php')){
            String responseBody = 'This is a sample response body';
            res.setHeader('Set-Cookie', 'zbx_session=eyJzZXNzaW9uaWQiOiI0MGI4MGRkNGI4NDc2NTQ1NDU4OWJmYWU4NWEzNWNjNiIsInNpZ24iOiI0YmZkMjI5Y2IyOTgyMTc4ZWU3OTE1OWZjMzg4YmQ5ZGU5MWZjNzUzZmQ3ZTlkMWIxMzFlZjA0ZWFlYzBhNjU5In0%3D; expires=Sun, 16-Jun-2024 12:49:06 GMT;');
            res.setBodyAsBlob(Blob.valueOf(responseBody));
        }else{
            Map<String, Object> reqBodyMap = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
            String method = (String) reqBodyMap.get('method');
            Map<String, Object> bodyMap;
            if (method == 'user.login') {
                bodyMap = new Map<String, Object>{
                    'jsonrpc' => '2.0',
                    'result' => '0424bd59b807674191e7d77572075f33',
                    'id' => 1
                };   
                res.setBody(JSON.serialize(bodyMap));
            }else if(method == 'host.get'){
                List<Object> hosts = new List<Object>();
                hosts.add(new Map<String, Object>{'hostid' => '1', 'host' => 'test-host-1', 'name' => 'test-host-1n'});
                hosts.add(new Map<String, Object>{'hostid' => '2', 'host' => 'test-host-2', 'name' => 'test-host-2n'});
                bodyMap = new Map<String, Object>{
                    'jsonrpc' => '2.0',
                    'result' => hosts,
                    'id' => 1
                };
                res.setBody(JSON.serialize(bodyMap));
            } else if(method == 'graph.get'){
                List<Object> hosts1 = new List<Object>();
                hosts1.add(new Map<String, Object>{'hostid' => '1', 'host' => 'test-host-1', 'name' => 'test-host-1'});
                List<Object> hosts2 = new List<Object>();
                hosts2.add(new Map<String, Object>{'hostid' => '2', 'host' => 'test-host-2', 'name' => 'test-host-1'});

                List<Object> items1 = new List<Object>();
                items1.add(new Map<String, Object>{'itemid' => '1', 'name' => 'test-host-1 $1', 'key_' => 'net.if.in[eth0,eth1]'});
                List<Object> items2 = new List<Object>();
                items2.add(new Map<String, Object>{'itemid' => '2', 'name' => 'test-host-2 $1', 'key_' => 'net.if.in[eth0,eth1]'});

                List<Object> resuls = new List<Object>();
                resuls.add(new Map<String, Object>{'graphid' => '1234', 'name' => 'テストCPUグラフ', 'hosts' => hosts1 , 'items' => items1});
                resuls.add(new Map<String, Object>{'graphid' => '2345', 'name' => 'テストネットワーク利用量', 'hosts' => hosts2 , 'items' => items2});
                
                bodyMap = new Map<String, Object>{
                    'jsonrpc' => '2.0',
                    'result' => resuls,
                    'id' => 1
                };
                res.setBody(JSON.serialize(bodyMap));
            } else if (method == 'user.logout') {
                bodyMap = new Map<String, Object>{
                    'jsonrpc' => '2.0',
                    'result' => true,
                    'id' => 1
                };
                res.setBody(JSON.serialize(bodyMap));
            } else if (method == 'history.get') {
                List<Object> results = new List<Object>();
                results.add(new Map<String, Object>{'itemid' => '39053', 'clock' => '1707660233', 'value' => 'Quote"Value', 'ns' => 'New\r\nLine'});
                results.add(new Map<String, Object>{'itemid' => '39053', 'clock' => '1707660173', 'value' => 'Comma,Value', 'ns' => '152736787'});
                bodyMap = new Map<String, Object>{
                    'jsonrpc' => '2.0',
                    'result' => results,
                    'id' => 1
                    
                };
                res.setBody(JSON.serialize(bodyMap));
            } else {
                    
            }
        }

        res.setStatusCode(200); 
        return res;     
    }
}