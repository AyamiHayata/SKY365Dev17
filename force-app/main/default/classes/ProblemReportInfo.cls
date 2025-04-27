/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2023 SKY365 Inc. All Rights Reserved.
 *
 * ProblemReportInfo Class
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/10     kikuchi     新規作成
 ********************************************************************************/
public with sharing class ProblemReportInfo {
    public Long lastchange { get; set; }
    public String host { get; set; }
    public String hostId { get; set; }
    public String triggerId { get; set; }
    public String description { get; set; }
    public String priority { get; set; }
    public String maintenance_status {get; set;}
    // priorityMapを作成
    public static Map<String, String> priorityMap = new Map<String, String>{
        '0' => '未分類',
        '1' => '情報',
        '2' => '警告',
        '3' => '軽度の障害',
        '4' => '重度の障害',
        '5' => '致命的な障害'
    };

    // priorityColorMapを作成
    public static Map<String, String> priorityColorMap = new Map<String, String>{
        '0' => '#c0c0c0',
        '1' => '#00ff7f',
        '2' => '#ffff00',
        '3' => '#ffa500',
        '4' => '#b22222',
        '5' => '#ff0000'
    };
    // メンテナンスマップ
    public static Map<String, String> maintenanceStatusMap = new Map<String, String>{
        '0' => '',
        '1' => '静観中'
        
    };

    /**
     * ProblemReportInfoクラスの新しいインスタンスを初期化します。
     */    
    public ProblemReportInfo() {
        lastchange = 0;
        host = '';
        hostId = '';
        triggerId = '';
        description = '';
        priority = '';
        maintenance_status = '';
    }
    

    /**
     * lastchangeをyyyy/MM/dd HH:mm:ssで取得します。
     * @return lastchange
     */
    public String getLastchangeCnv() {
        // lastchange（エポック秒）を年月日時分秒に変換
        Datetime dt = Datetime.newInstance(this.lastchange * 1000);
        return dt.format('yyyy/MM/dd HH:mm:ss', 'Asia/Tokyo');
    }

    /**
     * priorityを取得します。
     * @return priority
     */
    public String getPriorityCnv() {
        // priorityを日本語に変換
        return priorityMap.get(this.priority);
    }

    /**
     * maintenance_statusを取得します。
     */
    public String getMaintenanceStatusCnv() {
        // maintenance_statusを取得
        return maintenanceStatusMap.get(this.maintenance_status);
    }

    /**
   　* priorityColorMapを取得します。
     * @return priorityColorMap
     */
    public String getPriorityColorCnv() {
        // priorityColorMapを取得
        return priorityColorMap.get(this.priority);
    }

    /**
     * lastchangeを設定します。
     * @param lastchange lastchange
     */
/*
    public void setLastchange(Long lastchange) {
        this.lastchange = lastchange;
    }
*/

    /**
     * hostを設定します。
     * @param host host
     */
/*
     public void setHost(String host) {
        this.host = host;
    }
*/

    /**
     * hostIdを設定します。
     * @param hostId hostId
     */
/*
     public void setHostId(String hostId) {
        this.hostId = hostId;
    }
*/
    /**
     * triggerIdを設定します。
     * @param triggerId triggerId
     */
/*    
    public void setTriggerId(String triggerId) {
        this.triggerId = triggerId;
    }
*/
    /**
     * descriptionを設定します。
     * @param description description
     */
/*
    public void setDescription(String description) {
        this.description = description;
    }
*/
    /**
     * priorityを設定します。
     * @param priority priority
     */
/*
    public void setPriority(String priority) {
        this.priority = priority;
    }
*/
    /**
     * 継続時間を取得します。
     * @return 継続時間
     */
    public String getDuration() {
        // lastchangeを年月日時分秒に変換
        Datetime dt = Datetime.newInstance(this.lastchange * 1000);
        // 現在時刻を取得
        Datetime now = Datetime.now();
        // 継続時間を取得
        Long duration = now.getTime() - dt.getTime();
        // 継続時間を秒に変換
        duration = duration / 1000;
        // 継続時間を日時分秒に変換
        String durationStr = '';
        if (duration >= 86400) {
            Long i = duration / 86400;
            durationStr += String.valueOf(i) + 'd ';
            duration = duration - (i * 86400);
        }
        if (duration >= 3600) {
            Long i = duration / 3600;
            durationStr += String.valueOf(i) + 'h ';
            duration = duration - (i * 3600);
        }
        if (duration >= 60) {
            Long i = duration / 60;
            durationStr += String.valueOf(i) + 'm';
            duration = duration - (i * 60);
        }
        return durationStr;
    }

    /**
     * ProblemReportInfoリストをソートします。
     * @param items ProblemReportInfoリスト
     * @param order ソート順
     */
    public static void sortList(List<ProblemReportInfo> items, String order){
    
        List<ProblemReportInfo> resultList = new List<ProblemReportInfo>();
        Map<object, List<ProblemReportInfo>> objectMap = new Map<object, List<ProblemReportInfo>>();
        for(ProblemReportInfo ob : items){
            if(objectMap.get(ob.lastchange) == null){
                objectMap.put(ob.lastchange, new List<ProblemReportInfo>()); 
            }
            objectMap.get(ob.lastchange).add(ob);
        }       

        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();

        for(object key : keys){ 
            resultList.addAll(objectMap.get(key)); 
        }
        items.clear();
        if(order.toLowerCase() == 'asc'){
            for(ProblemReportInfo ob : resultList){
                items.add(ob); 
            }
        }
        else if(order.toLowerCase() == 'desc'){
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i]);  
            }
        }
    }    
}