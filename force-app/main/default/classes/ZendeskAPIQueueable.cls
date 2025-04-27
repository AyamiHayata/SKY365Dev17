// Zendesk連携のみを実行する
public class ZendeskAPIQueueable implements Queueable, Database.AllowsCallouts {

    private Id notifyInfoId;
    private Integer index;
    private String fieldApiName_Prefix;
    private String fieldApiName_Name;
    private String fieldApiName_Company;
    private String fieldApiName_Mail;
    private String fieldApiName_AlertContact;
    private String fieldApiName_OtherThanAlertContact;
    private String fieldApiName_ChgList;
    private String fieldApiName_Errorlog;

    private static final Integer FILED_COUNT = 20;

    public ZendeskAPIQueueable(Id notifyInfoId, Integer index) {
        this.notifyInfoId = notifyInfoId;
        this.index = index;
        this.fieldApiName_Prefix = 'Etc' + this.index + '_';
        this.fieldApiName_Name = this.fieldApiName_Prefix + 'Name__c';
        this.fieldApiName_Company = this.fieldApiName_Prefix + 'Company__c';
        this.fieldApiName_Mail = this.fieldApiName_Prefix + 'Mail__c';
        this.fieldApiName_AlertContact = this.fieldApiName_Prefix + 'AlertContact__c';
        this.fieldApiName_OtherThanAlertContact = this.fieldApiName_Prefix + 'OtherThanAlertContact__c';
        this.fieldApiName_ChgList = this.fieldApiName_Prefix + 'ChgList__c';
        this.fieldApiName_Errorlog = this.fieldApiName_Prefix + 'ErrorLog__c';
    }

    public void execute(QueueableContext context) {

        System.debug('★処理対象インデックス★' + this.index);

        NotifyInfo__c notifyInfo = getNotifyInfo(this.notifyInfoId);
        String processName = (String) notifyInfo.get(this.fieldApiName_ChgList);
        
        String name = (String) notifyInfo.get(this.fieldApiName_Name);
        String company = (String) notifyInfo.get(this.fieldApiName_Company);
        String mail = (String) notifyInfo.get(this.fieldApiName_Mail);

        String zendeskOrgid = notifyInfo.ConstitutionCommon__r.ZendeskOrganizationId__c;

        NotifyInfo__c pastNotifyInfo;
        if (notifyInfo.PastOne__c <> null) pastNotifyInfo = getNotifyInfo(notifyInfo.PastOne__c);

        if (String.isNotBlank(processName)) {
            if (processName == '追加') {
                ZendeskAPIController.executeCreateUser(notifyInfo, this.index, zendeskOrgid, name, company, mail);
            } else if (processName == '削除') {
                ZendeskAPIController.executeDeleteMembership(notifyInfo, this.index, zendeskOrgid, mail);
            } else if (processName == '変更') {
                ZendeskAPIController.executeUpdateUser(notifyInfo, this.index, zendeskOrgid
                    , (String) pastNotifyInfo?.get(this.fieldApiName_Mail), name, company, mail);
            }
        }

        Integer nextIndex = ++this.index;
        System.debug('★次の処理対象インデックス★' + nextIndex);
        // 次のインデックスが20以下の場合、再度Queueableを呼びだす
        if (!Test.isRunningTest() && nextIndex <= FILED_COUNT) System.enqueueJob(new ZendeskAPIQueueable(this.notifyInfoId, nextIndex));
    }

    private NotifyInfo__c getNotifyInfo(Id nInfoId) {

        String soql = 'SELECT Id, ConstitutionCommon__r.ZendeskOrganizationId__c, PastOne__c';
        soql += ', SendListAlert__c, SendListAlertExpet__c';
        soql += ', ' + this.fieldApiName_Name;
        soql += ', ' + this.fieldApiName_Company;
        soql += ', ' + this.fieldApiName_Mail;
        soql += ', ' + this.fieldApiName_AlertContact;
        soql += ', ' + this.fieldApiName_OtherThanAlertContact;
        soql += ', ' + this.fieldApiName_ChgList;
        soql += ', ' + this.fieldApiName_Errorlog;
        soql += ' FROM NotifyInfo__c';
        soql += ' WHERE Id = :nInfoId LIMIT 1';

        return Database.query(soql);
    }
}