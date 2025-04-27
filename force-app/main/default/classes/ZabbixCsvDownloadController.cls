public with sharing class ZabbixCsvDownloadController {
    public String graphCsvContent { get; private set; }
    public String attachmentFileName { get; private set; }

    public String selectedItemId { get; private set; }
    public Datetime reportStartDatetime { get; private set; }
    public Datetime reportEndDatetime { get; private set; }
    public String kanshiSystem { get; private set; }
    public String datadogDevName { get; private set; }
    public String groupId { get; private set; }


    public ZabbixCsvDownloadController() {
        System.debug('**==**== ZabbixCsvDownloadController start ==**==**');
        this.selectedItemId = EncodingUtil.urlDecode(ApexPages.CurrentPage().getParameters().get('selectedItemId'), 'UTF-8');
        this.reportStartDatetime = Datetime.valueOf(EncodingUtil.urlDecode(ApexPages.CurrentPage().getParameters().get('reportStartDatetime'), 'UTF-8'));
        this.reportEndDatetime = Datetime.valueOf(EncodingUtil.urlDecode(ApexPages.CurrentPage().getParameters().get('reportEndDatetime'), 'UTF-8'));
        this.groupId = EncodingUtil.urlDecode(ApexPages.CurrentPage().getParameters().get('groupId'), 'UTF-8');
        this.kanshiSystem = EncodingUtil.urlDecode(ApexPages.CurrentPage().getParameters().get('kanshiSystem'), 'UTF-8');
        // this.attachmentFileName = EncodingUtil.urlDecode(ApexPages.CurrentPage().getParameters().get('attachfilename'), 'UTF-8');
        this.attachmentFileName = ApexPages.CurrentPage().getParameters().get('attachfilename');
        
    }
    public PageReference createCSV() {
        System.debug('**==**== createCSV start ==**==**');
        // history 情報を取得してCSV形式にする
        Set<String> paraItemids = new Set<String>();
        paraItemids.add(selectedItemId);
        this.graphCsvContent = graphCsvContent = ZabbixAPIController.executeGetHistory(kanshiSystem, groupId, paraItemids, reportStartDatetime.addHours(-9), reportEndDatetime.addHours(-9));
        return null;
    }
}