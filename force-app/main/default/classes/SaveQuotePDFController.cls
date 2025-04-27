public with sharing class SaveQuotePDFController {

    private Quote__c quote;

    public SaveQuotePDFController(ApexPages.StandardController stdController) {
        //this.quote = (Quote__c)stdController.getRecord();
        getQuote((Quote__c)stdController.getRecord());
    }

    public PageReference initAction() {
        saveAsPdf();
        return new PageReference('/' + this.quote.Id);
    }

    @TestVisible
    private void saveAsPdf() {

        PageReference pageRef = Page.CreateQuotePDF;
        pageRef.getParameters().put('id', this.quote.Id);

        String title = this.quote.ConstitutionCommon__r.Name + '_' + this.quote.QuoteNumber__c + '_' + Datetime.now().format('yyyyMMddHHmmss');
        
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
            insert FileUtility.createContentDocumentLink(cv.ContentDocumentId, this.quote.Id);
        } catch(Exception e) {
            
        }
    }

    /**
     * 見積取得
     */
    private void getQuote(Quote__c sorceQuote) {

        List<String> selectFields = new List<String>(
            Quote__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        Id qId = sorceQuote.Id;

        this.quote = Database.query(
            String.format(
                'SELECT {0}, ConstitutionCommon__r.Name FROM Quote__c WHERE Id = :qId LIMIT 1'
                , new List<String>{ String.join(selectFields, ', ') }
            )
        );

    }

}