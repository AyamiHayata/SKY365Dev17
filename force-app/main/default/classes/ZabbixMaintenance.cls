public class ZabbixMaintenance {

    // 期間のタイプ変換用Map
    private Map<String, String> timeperiodConvertMap = new Map<String, String>{
        '0' => '一度限り',
        '2' => '毎日',
        '3' => '毎週',
        '4' => '毎月'
    };

    // メンテナンスID
    public String maintenanceid { get; private set; }
    // 名前
    public String name { get; private set; }
    // 対象AWSリソース
    public List<ZabbixAWSResource> hosts { get; private set; }
    // 期間のタイプ
    private String timeperiod_type { get; private set; }
    public String disp_timeperiod_type {
        get {
            return this.timeperiodConvertMap.get(this.timeperiod_type);
        }
    }
    // 有効期限開始日時
    public Long active_since;
    public Datetime dt_active_since {
        get {
            return DateTime.newInstance(this.active_since * 1000);
        }
    }
    public String disp_active_since {
        get {
            // return this.dt_active_since.format();
            return this.dt_active_since.format('yyyy/MM/dd HH:mm','JST');
        }
    }
    // 有効期限終了日時
    public Long active_till;
    public Datetime dt_active_till {
        get {
            return DateTime.newInstance(this.active_till * 1000);
        }
    }
    public String disp_active_till {
        get {
            // return this.dt_active_till.format();
            return this.dt_active_till.format('yyyy/MM/dd HH:mm','JST');
        }
    }
    // 開始時刻 (時:分)
    private Long start_time { get; private set; }
    // メンテナンス期間
    private Long period { get; private set; }
    // 静観開始
    public String disp_start_time {
        get {
            // 期間のタイプが「毎日」「毎週」「毎月」の場合
            if (this.timeperiod_type <> '0') {
                Datetime tmp = DateTime.newInstance(this.start_time * 1000);
                // return tmp.format('HH:mm', 'GMT');
                return tmp.format('HH:mm', 'JST');
            }
            // 期間のタイプが「一度限り」の場合
            // return this.dt_active_since.format('HH:mm');
            return this.dt_active_since.format('HH:mm','JST');
        }
    }
    // 静観終了
    public String disp_end_time {
        get {
            // 期間のタイプが「毎日」「毎週」「毎月」の場合
            if (this.timeperiod_type <> '0') {
                Datetime tmp = DateTime.newInstance((this.start_time + this.period) * 1000);
                // return tmp.format('HH:mm', 'GMT');
                return tmp.format('HH:mm', 'JST');
            }
            // 期間のタイプが「一度限り」の場合
            // return this.dt_active_till.format('HH:mm');
            return this.dt_active_till.format('HH:mm','JST');
        }
    }

    public ZabbixMaintenance(String maintenanceid, String name, List<ZabbixAWSResource> hosts
        , String timeperiod_type, Long active_since, Long active_till, Long start_time, Long period) {
        this.maintenanceid = maintenanceid;
        this.name = name;
        this.hosts = hosts;
        this.timeperiod_type = timeperiod_type;
        this.active_since = active_since;
        this.active_till = active_till;
        this.start_time = start_time;
        this.period = period;
    }
}