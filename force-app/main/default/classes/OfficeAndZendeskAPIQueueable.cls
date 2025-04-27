public class OfficeAndZendeskAPIQueueable implements Queueable, Database.AllowsCallouts {

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

    public OfficeAndZendeskAPIQueueable(Id notifyInfoId, Integer index) {
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

        Id jobId = context.getJobId();
        List<AsyncApexJob> jobs = [
            SELECT Id FROM AsyncApexJob
            WHERE Id <> :jobId
            AND ApexClass.Name = 'OfficeAndZendeskAPIQueueable'
            AND JobType = 'Queueable' AND Status = 'Processing'
            LIMIT 1
        ];

        System.debug(jobs);

        if (jobs.size() == 1) {
            System.enqueueJob(new OfficeAndZendeskAPIQueueable(this.notifyInfoId, 1));
            return;
        }

        System.debug('★処理対象インデックス★' + this.index);

        NotifyInfo__c notifyInfo = getNotifyInfo(this.notifyInfoId);
        String processName = (String) notifyInfo.get(this.fieldApiName_ChgList);
        
        String name = (String) notifyInfo.get(this.fieldApiName_Name);
        String company = (String) notifyInfo.get(this.fieldApiName_Company);
        String mail = (String) notifyInfo.get(this.fieldApiName_Mail);

        Boolean isAlertContact = (Boolean) notifyInfo.get(this.fieldApiName_AlertContact);
        Boolean isOtherThanAlertContact = (Boolean) notifyInfo.get(this.fieldApiName_OtherThanAlertContact);

        String zendeskOrgid = notifyInfo.ConstitutionCommon__r.ZendeskOrganizationId__c;

        NotifyInfo__c pastNotifyInfo;
        if (notifyInfo.PastOne__c <> null) pastNotifyInfo = getNotifyInfo(notifyInfo.PastOne__c);

        System.debug('★' + processName);

        if (String.isNotBlank(processName)) {

            Boolean isOfficeResult = true;

            if (processName == '追加') {

                // Office連携
                if (!Test.isRunningTest()) {
                    isOfficeResult = OfficeAPIController.executeCreate(notifyInfo, this.index, name, mail, processName);
                }

                // Office連携でエラーがなければ、Zendesk連携
                if (isOfficeResult) {
                    ZendeskAPIController.executeCreateUser(notifyInfo, this.index, zendeskOrgid, name, company, mail);
                }
            } else if (processName == '削除') {

                // Office連携
                if (!Test.isRunningTest()) {
                    isOfficeResult = OfficeAPIController.executeDelete(notifyInfo, this.index, name, mail, processName);
                }

                // Office連携でエラーがなければ、Zendesk連携
                if (isOfficeResult) {
                    ZendeskAPIController.executeDeleteMembership(notifyInfo, this.index, zendeskOrgid, mail);
                }
            } else if (processName == '変更') {

                // Office連携
                if (!Test.isRunningTest()) {
                    isOfficeResult = OfficeAPIController.executeUpdate(notifyInfo, this.index, name
                        , mail, pastNotifyInfo, processName);
                }
                
                // Office連携でエラーがなければ、Zendesk連携
                if (isOfficeResult) {
                    ZendeskAPIController.executeUpdateUser(notifyInfo, this.index, zendeskOrgid
                        , (String) pastNotifyInfo?.get(this.fieldApiName_Mail), name, company, mail);
                }
            }
        }

        Integer nextIndex = ++this.index;
        System.debug('★次の処理対象インデックス★' + nextIndex);
        // 次のインデックスが20以下の場合、再度Queueableを呼びだす
        if (!Test.isRunningTest() && nextIndex <= FILED_COUNT) System.enqueueJob(new OfficeAndZendeskAPIQueueable(this.notifyInfoId, nextIndex));
        //最後のインデックスの場合、エラーチェックをしZendeskチケットを発行する　23.04.12 add
        if (!Test.isRunningTest() && nextIndex == FILED_COUNT){
            Database.executebatch(new CretateZendeskTicket(notifyInfo.Id), 100);
        }
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