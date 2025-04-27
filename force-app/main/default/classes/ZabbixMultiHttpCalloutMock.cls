@isTest
public class ZabbixMultiHttpCalloutMock implements HttpCalloutMock {

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
        } else if (method == 'maintenance.get') {
            List<Object> hosts = new List<Object>();
            hosts.add(new Map<String, Object>{'hostid' => '1', 'host' => 'test-host-1', 'name' => ''});
            hosts.add(new Map<String, Object>{'hostid' => '2', 'host' => 'test-host-2', 'name' => ''});
            List<Object> timeperiods = new List<Object>();
            timeperiods.add(new Map<String, Object>{'timeperiod_type' => '0', 'start_time' => '43200', 'period' => '21600'});
            List<Object> resuls = new List<Object>();
            resuls.add(new Map<String, Object>{'maintenanceid' => '1', 'name' => 'test-maintenance'
                , 'active_since' => '1659538800', 'active_till' => '1659625200', 'hosts' => hosts, 'timeperiods' => timeperiods});
            bodyMap = new Map<String, Object>{
                'jsonrpc' => '2.0',
                'result' => resuls,
                'id' => 1
            };
        } else if (method == 'maintenance.create'
            || method == 'maintenance.update'
            || method == 'maintenance.delete') {
            Map<String, Object> maintenanceids = new Map<String, Object>{
                'maintenanceids' => new List<String>{'1'}
            };
            bodyMap = new Map<String, Object>{
                'jsonrpc' => '2.0',
                'result' => maintenanceids,
                'id' => 1
            };
        } else if (method == 'user.logout') {
            bodyMap = new Map<String, Object>{
                'jsonrpc' => '2.0',
                'result' => true,
                'id' => 1
            };
        }

        HttpResponse res = new HttpResponse();
        res.setBody(JSON.serialize(bodyMap));
        res.setStatusCode(200);

        return res;
    }
}