public class ZabbixAWSResource {

    public String hostid { get; private set; }
    public String host { get; private set; }

    public ZabbixAWSResource(String hostid, String host) {
        this.hostid = hostid;
        this.host = host;
    }
}