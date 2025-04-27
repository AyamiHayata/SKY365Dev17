@isTest(SeeAllData=false)
public class OperationListDatatableControllerTest {
    
    @isTest
    static void  fetchOperationListsTest(){
        Constitution_Common__c projectInformation = new Constitution_Common__c(Name = 'Lightning Data Table Apex Test');
        insert projectInformation;
        
        OperationList__c operationlist = new OperationList__c(Name = 'Apex Test Phase', 
                                                              Requester__c = 'https://www.google.co.jp',
                                                              Alert__c = 'Test Alert',
                                                              Host__c = 'Host01',
                                                              GroupWatcher__c = '済',
                                                              StartDate__c = Datetime.newInstance(2000, 1, 1),
                                                              EndDate__c = Datetime.newInstance(2099, 12, 31),
                                                              ProjectInformation__c = projectInformation.Id
                                                             );
        insert operationlist;
        
        List <OperationList__c> fetchOperationLists = OperationListDatatableController.fetchOperationLists(projectInformation.Id);
    }
}