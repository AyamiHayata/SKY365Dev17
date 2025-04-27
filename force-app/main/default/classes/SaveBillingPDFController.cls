public with sharing class SaveBillingPDFController {

    private BillingHeader__c billingHeader;

    public SaveBillingPDFController(ApexPages.StandardController stdController) {
        //this.quote = (Quote__c)stdController.getRecord();
        getBilling((BillingHeader__c)stdController.getRecord());
    }

    public PageReference initAction() {
        saveAsPdf();
        return new PageReference('/' + this.billingHeader.Id);
    }

    @TestVisible
    private void saveAsPdf() {

        PageReference pageRef = Page.CreateBillingPDF;
        pageRef.getParameters().put('id', this.billingHeader.Id);

        String title = this.billingHeader.BillingAccount__r.Name + '様_' + this.billingHeader.BillingNumber__c + '_' + Datetime.now().format('yyyyMMddHHmmss');
        
        String fileName = title + '.pdf';

        Blob file;
        if (Test.isRunningTest()) {
            file = Blob.valueOf('test');
        } else {
            file = pageRef.getContent();
        }

        ContentVersion cv = FileUtility.createContentVersion(title, file, fileName);

        // PDFファイルを作成
        try {
            insert cv;
            cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            insert FileUtility.createContentDocumentLink(cv.ContentDocumentId, this.billingHeader.Id);
        } catch(Exception e) {
            
        }
    }

    /**
     * 請求取得
     */
    private void getBilling(BillingHeader__c sorceBilling) {

        List<String> selectFields = new List<String>(
            BillingHeader__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id bId = sorceBilling.Id;

        this.billingHeader = Database.query(
            String.format(
                'SELECT {0}, BillingAccount__r.Name FROM BillingHeader__c WHERE Id = :bId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

    }

}