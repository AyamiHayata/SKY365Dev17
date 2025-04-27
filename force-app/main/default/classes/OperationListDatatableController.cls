public class OperationListDatatableController {
    @AuraEnabled
    public static List <OperationList__c> fetchOperationLists(Id projectinformationId) {
        
        List<OperationList__c> opeList = [SELECT Id, 
                                          Name, 
                                          BeforeFlag__c, 
                                          InProgressFlag__c, 
                                          CompletedFlag__c, 
                                          EndedFlag__c,
                                          RepetitionDate__c,
                                          Host__c, 
                                          Alert__c, 
                                          ProjectInformation__c 
                                          FROM OperationList__c  
                                          WHERE CompletedFlag__c = false AND ProjectInformation__c = :projectinformationId ];
        //return list of OperationList__c
        return opeList;
    }
}