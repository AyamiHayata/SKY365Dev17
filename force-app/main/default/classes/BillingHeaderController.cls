public without sharing class BillingHeaderController {
    public BillingHeaderController() {

    }

    @AuraEnabled(cacheable=false)
    public static void billingCheckUpdate(BillingHeader__c billing){
        try {
            update billing;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            //throw new AuraHandledException(e.getMessage());
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
}