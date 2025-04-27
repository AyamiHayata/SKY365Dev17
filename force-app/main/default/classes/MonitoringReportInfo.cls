/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2023 SKY365 Inc. All Rights Reserved.
 *
 * MonitoringReportInfo Class
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2023/09     kikuchi     新規作成
 ********************************************************************************/
public with sharing class MonitoringReportInfo implements Comparable{
    public String hostName { get; set; }
    public String hostId { get; set; }
    public String zendskUserId { get; set; }
    public List<Graph> graphList = new List<Graph>();

    /**
     * Constructs a new MonitoringReportInfo object.
     */
    public MonitoringReportInfo() {
        hostName = '';
        hostId = '';
        graphList = new List<Graph>();
    }

    /**
     * Constructs a new MonitoringReportInfo object with the specified host name and ID.
     * @param hostName The name of the host.
     * @param hostId The ID of the host.
     */
    public MonitoringReportInfo(String hostName, String hostId) {
        this.hostName = hostName;
        this.hostId = hostId;
        graphList = new List<Graph>();
    }
    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        MonitoringReportInfo compareToInfo = (MonitoringReportInfo)compareTo;
        if (hostName == null || compareToInfo.hostName == null) {
            return (hostName == null ? (compareToInfo.hostName == null ? 0 : -1) : 1);
        }
        String chostname = hostName.toLowerCase();
        String chostnameHikaku = compareToInfo.hostName.toLowerCase();
        // return hostName.compareTo(compareToInfo.hostName); 
        return chostname.compareTo(chostnameHikaku); 
    }
    /**
     * Represents a graph object.
     * This class provides functionality for creating and manipulating graphs.
     */
    public with sharing class Graph {
        public String graphid { get; set; }
        public String graphName { get; set; }
        public Blob graphImage { get; set; }
        public String graphImageEncode { get; set; }
        public String graphImageId { get; set; }
        public String graphURL { get; set; }
        public String itemIds { get; set; }
        public String itemNames { get; set; }
        public List<Item> itemList { get; set; }
        
        /**
         * Creates a graph object.
         * @constructor
         */
        public Graph() {
            graphid = '';
            graphName = '';
            graphImage = null;
            graphImageEncode = ''; 
            graphURL = ''; 
            itemList = new List<Item>();
        }

    }

    /**
     * Sets the name of the host.
     * @param hostName The name of the host.
     */
    public void setHostName(String hostName) {
        this.hostName = hostName;
    }

    /**
     * Sets the ID of the host.
     * @param hostId The ID of the host.
     */
    public void setHostId(String hostId) {
        this.hostId = hostId;
    }

    /**
     * Adds a new graph to the list of graphs.
     * @param graphid The ID of the graph.
     * @param graphName The name of the graph.
     */    
    public void addGraph(String graphid, String graphName) {
        Graph g = new Graph();
        g.graphid = graphid;
        g.graphName = graphName;
        graphList.add(g);
    }



    /**
     * Returns a list of graphs.
     * @return A list of graphs.
     */
    public List<Graph> getGraphList() {
        return graphList;
    }

    public with sharing class Item {
        public String itemid { get; set; }
        public String itemName { get; set; }
        public String key { get; set; }
        public Item(){
            itemid = '';
            itemName = '';
            key = '';
        }

        /**
         * Returns a Convert ItemName.
         * @return A Convert ItemName.
         */        
        public String getItemNameCnv() {
            Set<String> keys = extractInterfaces();
            return replacePlaceholders(itemName, keys);
        }

        private Set<String> extractInterfaces() {
            Set<String> interfaces = new Set<String>();
            
            // Pattern to find content within square brackets
            Pattern interfacePattern = Pattern.compile('\\[(.*?)\\]');
            Matcher matcher = interfacePattern.matcher(key);
            
            // Extract matching group within brackets
            if (matcher.find()) {
                String matchedGroup = matcher.group(1);
                
                // Split the matched group by comma to get individual interfaces
                String[] interfaceArray = matchedGroup.split(',');
                for (String interfaceName : interfaceArray) {
                    // Add trimmed interface names to the set
                    interfaces.add(interfaceName.trim());
                }
            }
            return interfaces;
        }

        private String replacePlaceholders(String input, Set<String> placeholders) {
            // Setの要素をリストに変換し、インデックス操作を可能にする
            List<String> placeholderList = new List<String>(placeholders);
            // 正規表現のパターン（$の後ろの数字にマッチする）
            Pattern p = Pattern.compile('\\$(\\d+)');
            Matcher m = p.matcher(input);
            // マッチンググループが見つかるたびに置換を実行
            while (m.find()) {
                Integer index = Integer.valueOf(m.group(1));
                // Setにはインデックスがないので、リストのインデックスとして-1して扱う
                if (index > 0 && index <= placeholderList.size()) {
                    // グループでマッチした部分をリストから取得した値で置換
                    input = input.replace('$' + index, placeholderList[index - 1]);
                }
            }
            return input;
        }
    }


}