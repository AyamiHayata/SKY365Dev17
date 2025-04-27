({
    fetchOpe : function(component, event, helper) {
        //コンポーネント列にラベルをセットする
        component.set('v.mycolumns', [
            {label: '対応名', fieldName: 'LinkedName__c', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            // {label: '対応名', fieldName: 'Name', type: 'text'},
            {label: '開始前フラグ', fieldName: 'BeforeFlag__c', type: 'boolean', initialWidth: 110},
            {label: '継続中フラグ', fieldName: 'InProgressFlag__c', type: 'boolean', initialWidth: 110, sortable: true},
            {label: '終了フラグ', fieldName: 'EndedFlag__c', type: 'boolean', initialWidth: 110},
            {label: '繰り返し日時', fieldName: 'RepetitionDate__c', type: 'textarea'},
            {label: '対象ホスト', fieldName: 'Host__c', type: 'textarea'},
            {label: '対象アラート', fieldName: 'Alert__c', type: 'textarea'}
        ]);

        // サーバ側コントローラからデータを取得する
        var action = component.get("c.fetchOperationLists");
        
        action.setParams({
            projectinformationId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.opeList", response.getReturnValue());
                var records =response.getReturnValue();
                records.forEach(function(record){
                    record.LinkedName__c = '/'+record.Id;
                });
                helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
            }
        });
        $A.enqueueAction(action);
    },
    
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
   
})