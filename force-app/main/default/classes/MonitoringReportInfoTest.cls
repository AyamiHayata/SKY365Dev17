/********************************************************************************
 *
 * MonitoringReportInfoテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2024/03                              New
 ********************************************************************************/
@isTest
private class MonitoringReportInfoTest {
    /**
     * 【対象】
     * compareTo
     * 【条件】
     * エラーがない場合
     */
    @isTest
    public static void test_compareTo_001() {
        MonitoringReportInfo minfo1 = new MonitoringReportInfo();
        
        MonitoringReportInfo minfo2 = new MonitoringReportInfo('22222', 'host2');
        Test.startTest();
        Integer comparisonResult = minfo1.compareTo(minfo2);

        minfo1.setHostId('11111');
        minfo1.setHostName('host1');

        comparisonResult = minfo1.compareTo(minfo2);
        test.stopTest();
        System.assert( comparisonResult>0);
    }
    /**
     * 【対象】
     * compareTo
     * 【条件】
     * hostNameが辞書順で小さい場合
     */
    @isTest
    public static void test_compareTo_002() {
        MonitoringReportInfo minfo1 = new MonitoringReportInfo('apple', '11111');
        MonitoringReportInfo minfo2 = new MonitoringReportInfo('banana', '22222');

        Test.startTest();
        Integer comparisonResult = minfo1.compareTo(minfo2);
        Test.stopTest();

        System.assertEquals(-1, comparisonResult);
    }
    /**
     * 【対象】
     * compareTo
     * 【条件】
     * hostNameが辞書順で大きい場合
     */
    @isTest
    public static void test_compareTo_003() {
        MonitoringReportInfo minfo1 = new MonitoringReportInfo('zebra', '11111');
        MonitoringReportInfo minfo2 = new MonitoringReportInfo('apple', '22222');

        Test.startTest();
        Integer comparisonResult = minfo1.compareTo(minfo2);
        Test.stopTest();

        System.assert( 0 < comparisonResult);
    }
    /**
     * 【対象】
     * addGraph
     * 【条件】
     * グラフが正常に追加される場合
     */
    @isTest
    public static void test_addGraph_001() {
        MonitoringReportInfo minfo = new MonitoringReportInfo();
        String graphid = 'graph123';
        String graphName = 'Sample Graph';
        
        Test.startTest();
        minfo.addGraph(graphid, graphName);
        Test.stopTest();

        List<MonitoringReportInfo.Graph> graphs = minfo.getGraphList();
        System.assertEquals(1, graphs.size());
        MonitoringReportInfo.Graph addedGraph = graphs[0];

        System.assertEquals(graphid, addedGraph.graphid);
        System.assertEquals(graphName, addedGraph.graphName);
    }

    /**
     * 【対象】
     * Itemクラス
     * 【条件】
     * エラーがない場合
     */
    @isTest
    public static void test_Item_001() {
        MonitoringReportInfo minfo = new MonitoringReportInfo();
        String graphid = 'graph123';
        String graphName = 'Sample Graph';
        
        Test.startTest();
        minfo.addGraph(graphid, graphName);
        MonitoringReportInfo.Item tempItem = new MonitoringReportInfo.Item();
        tempItem.itemid= 'item1111';
        tempItem.itemname= 'itemname111';
        Test.stopTest();
    }
}