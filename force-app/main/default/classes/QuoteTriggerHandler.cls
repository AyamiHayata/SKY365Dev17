/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 見積トリガハンドラ
 * 見積書発行日によるTodo登録により、mitoco連携を行う
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/07          M.Kawasaki       New
 ********************************************************************************/
public without sharing class QuoteTriggerHandler {
    public QuoteTriggerHandler() {

    }

    /**
     * 見積書発行日に、新規Todoを登録し、登録したTodoのIDを見積側に保持する
     */
    public void registerTodo(List<Quote__c> newList) {
        List<Task> taskList = new List<Task>();
        // 案件名含む見積情報を取得しておく
        Map<Id, Quote__c> quoteInfoMap = getQuoteInfoMap(newList);
        for (Quote__c quote : newList) {
            if (quote.EstimateOutputDate__c != null && String.isNotBlank(quote.QuoteUser__c)) {
                Quote__c targetQuote = quoteInfoMap.get(quote.Id);
                taskList.add(createTaskFromQuoteAtInsert(quote, targetQuote.ConstitutionCommon__r.Name));
            }
        }
        insert taskList;

        // TodoのInsert後、TodoのIdを見積側に保持しておく。そのままnewListに書き込みできないため取得しなおして複製する。
        List<Quote__c> updateQuoteList = new List<Quote__c>();
        for (Task task : taskList) {
            Quote__c updateQuote = quoteInfoMap.get(task.WhatId);
            updateQuote.QuoteTodo__c = task.Id;
            updateQuoteList.add(updateQuote);
        }
        update updateQuoteList;
    }

    /**
     * 見積書発行日が変更されたら、登録済みのTodoの日付を更新する
     */
    public void updateTodoDate(Map<Id, Quote__c> oldMap, List<Quote__c> newList) {
        List<Task> insertTaskList = new List<Task>();
        List<Task> deleteTaskList = new List<Task>();
        List<Task> updateTaskList = new List<Task>();
        List<String> todoRegistList = new List<String>();

        // 案件名含む見積情報を取得しておく
        Map<Id, Quote__c> quoteInfoMap = getQuoteInfoMap(newList);
        
        for (Quote__c quote : newList) {
            Quote__c oldQuote = oldMap.get(quote.Id);

            if (String.isNotBlank(quote.QuoteTodo__c)) {
                if (quote.EstimateOutputDate__c  == null || String.isBlank(quote.QuoteUser__c)) {
                    // Todo削除
                    deleteTaskList.add(createTaskFromQuote(quote, quote.QuoteTodo__c));
                    todoRegistList.add(quote.Id);
                } else if (quote.EstimateOutputDate__c != null && quote.EstimateOutputDate__c != oldQuote.EstimateOutputDate__c) {
                    // Todo更新
                    updateTaskList.add(createTaskFromQuote(quote, quote.QuoteTodo__c));
                }
            } else {
                if (quote.EstimateOutputDate__c  != null && String.isNotBlank(quote.QuoteUser__c)) {
                    // Todo作成
                    Quote__c targetQuote = quoteInfoMap.get(quote.Id);
                    insertTaskList.add(createTaskFromQuoteAtInsert(quote, targetQuote.ConstitutionCommon__r.Name));
                    todoRegistList.add(quote.Id);
                }
            }
        }
        insert insertTaskList;
        update updateTaskList;

        // TodoのInsert後、TodoのIdを見積側に保持しておく。そのままnewListに書き込みできないため取得しなおして複製する。
        List<Quote__c> updateQuoteList = new List<Quote__c>();
        Map<Id, Quote__c> updateQuoteMap = new Map<Id, Quote__c>([SELECT Id, QuoteTodo__c From Quote__c WHERE Id IN : todoRegistList]);
        for (Task task : insertTaskList) {
            Quote__c updateQuote = updateQuoteMap.get(task.WhatId);
            updateQuote.QuoteTodo__c = task.Id;
            updateQuoteList.add(updateQuote);
        }
        for (Task task : deleteTaskList) {
            Quote__c updateQuote = updateQuoteMap.get(task.WhatId);
            updateQuote.QuoteTodo__c = null;
            updateQuoteList.add(updateQuote);
        }
        // 見積の更新
        update updateQuoteList;

        // Todoの削除
        delete deleteTaskList;

    }

    /**
     * 見積からTodo生成
     */
    private Task createTaskFromQuoteAtInsert(Quote__c quote, String subjectStr) {
        Task task = new Task();
        // 件名…Insert時のみ設定
        if (String.isNotBlank(subjectStr)) {
            task.Subject = subjectStr;
        }
        // 割当先＝見積担当者
        task.OwnerId = quote.QuoteUser__c;
        // 関連先＝見積レコード
        task.WhatId = quote.Id;
        // 期日＝見積書発行日
        task.ActivityDate = quote.EstimateOutputDate__c;
        // アラーム設定
        task.isReminderSet = true;
        if (task.ActivityDate != null) {
            // アラーム日付／時間 10時にセット
            task.ReminderDateTime = Datetime.newInstance(task.ActivityDate, Time.newInstance(10,0,0,0)); 
        }
        return task;

    }

    /**
     * 既にあるTodoをIdとして見積からTodo生成
     */
    private Task createTaskFromQuote(Quote__c quote, String quoteTodoId) {
        Task task = createTaskFromQuoteAtInsert(quote, '');
        task.Id = quoteTodoId;
        return task;
    }

    /**
     * 案件名含む見積Mapを取得する
     */
    private Map<Id, Quote__c> getQuoteInfoMap(List<Quote__c> newList) {
        List<String> insertList = new List<String>();
        for (Quote__c quote : newList) {
            insertList.add(quote.Id);
        }
        Map<Id, Quote__c> quoteInfoMap = new Map<Id, Quote__c>([SELECT Id, ConstitutionCommon__r.Name, QuoteTodo__c From Quote__c WHERE Id IN : insertList]);
        return quoteInfoMap;
    }
}