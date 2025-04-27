/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 見積トリガハンドラテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/10          M.Kawasaki       New
 ********************************************************************************/
@isTest
 private class QuoteTriggerHandlerTest {
    
    @testSetup static void setUpTestData() {
        // 全メソッドで共通で使うようなテストデータはここでセットアップできる
        
    }

    /**
     * 【対象】
     * afterInsert
     * 【条件】
     * 正常系：新規の場合・見積担当者、見積書発行日が設定されている
     * 【結果】
     * 見積発行日の10時に、見積担当者に見積書発行のTodoが割り当てられること
     * 割り当てられたTodoのIdが見積側に保持されること
     */
    @isTest
    public static void test_afterInsert_001() {
        // データ準備
        User testUser = TestUtil.createUser('システム管理者');
        insert testUser;

        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // テスト開始
        Test.startTest();

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.QuoteUser__c = testUser.Id;
        Date myDate = Date.today();
        Date newDate = myDate.addDays(2);
        quote.EstimateOutputDate__c = newDate;
        insert quote;

        Id quoteId = quote.Id;

        Task task = [SELECT Id, toLabel(Subject), OwnerId, IsReminderSet, ActivityDate, ReminderDateTime FROM Task LIMIT 1][0];
        quote = [SELECT QuoteTodo__c FROM Quote__c WHERE Id =: quoteId][0];

        Test.stopTest();

        // 検証
        System.assertEquals(quote.QuoteTodo__c, task.Id);
        System.assertEquals(task.Subject, 'テスト案件');
        System.assertEquals(task.OwnerId, testUser.Id);
        System.assertEquals(task.IsReminderSet, True);
        System.assertEquals(task.ActivityDate, newDate);
        System.assertEquals(task.ReminderDateTime, DateTime.newInstance(newDate, Time.newInstance(10,0,0,0)));
    }

    /**
     * 【対象】
     * afterInsert
     * 【条件】
     * 異常系：新規の場合・見積担当者が設定されていない
     * 【結果】
     * Todoは作成されないこと
     */
    @isTest
    public static void test_afterInsert_002() {
        // データ準備
        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // テスト開始
        Test.startTest();

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        //quote.QuoteUser__c = testUser.Id;
        Date myDate = Date.today();
        Date newDate = myDate.addDays(2);
        quote.EstimateOutputDate__c = newDate;
        insert quote;

        Id quoteId = quote.Id;

        List<Task> taskList = [SELECT Id, toLabel(Subject), OwnerId, IsReminderSet, ActivityDate, ReminderDateTime FROM Task LIMIT 1];
        quote = [SELECT QuoteTodo__c FROM Quote__c WHERE Id =: quoteId][0];

        Test.stopTest();

        // 検証
        System.assertEquals(quote.QuoteTodo__c, null);
        System.assertEquals(taskList.size(), 0);
    }

    /**
     * 【対象】
     * afterUpdate
     * 【条件】
     * 正常系：更新の場合・見積担当者、見積書発行日が設定されており、見積書発行日を変更する
     * 【結果】
     * 登録されていたTodoの対象日が変更されていること
     * 割り当てられたTodoのIdは見積側に保持されたまま変わらないこと
     */
    @isTest
    public static void test_afterUpdate_001() {
        // データ準備
        User testUser = TestUtil.createUser('システム管理者');
        insert testUser;

        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // テスト開始
        Test.startTest();

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.QuoteUser__c = testUser.Id;
        Date myDate = Date.today();
        Date newDate = myDate.addDays(2);
        quote.EstimateOutputDate__c = newDate;
        insert quote;

        Id quoteId = quote.Id;

        newDate = myDate.addDays(3);
        quote.EstimateOutputDate__c = newDate;
        update quote;

        List<Task> taskList = [SELECT Id, toLabel(Subject), OwnerId, IsReminderSet, ActivityDate, ReminderDateTime FROM Task];
        quote = [SELECT QuoteTodo__c FROM Quote__c WHERE Id =: quoteId][0];

        Test.stopTest();

        // 検証
        System.assertEquals(taskList.size(),1);
        System.assertEquals(quote.QuoteTodo__c, taskList[0].Id);
        System.assertEquals(taskList[0].Subject, 'テスト案件');
        System.assertEquals(taskList[0].OwnerId, testUser.Id);
        System.assertEquals(taskList[0].IsReminderSet, True);
        System.assertEquals(taskList[0].ActivityDate, newDate);
        System.assertEquals(taskList[0].ReminderDateTime, DateTime.newInstance(newDate, Time.newInstance(10,0,0,0)));
    }

    /**
     * 【対象】
     * afterUpdate
     * 【条件】
     * 異常系：更新の場合・見積担当者、見積書発行日が設定されており、見積書発行日を削除する
     * 【結果】
     * 登録されていたTodoが削除されること
     * 見積に保持されていた割り当てられたTodoのIdが削除されること
     */
    @isTest
    public static void test_afterUpdate_002() {
        // データ準備
        User testUser = TestUtil.createUser('システム管理者');
        insert testUser;

        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // テスト開始
        Test.startTest();

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.QuoteUser__c = testUser.Id;
        Date myDate = Date.today();
        Date newDate = myDate.addDays(2);
        quote.EstimateOutputDate__c = newDate;
        insert quote;

        Id quoteId = quote.Id;

        quote.EstimateOutputDate__c = null;
        update quote;

        List<Task> taskList = [SELECT Id, toLabel(Subject), OwnerId, IsReminderSet, ActivityDate, ReminderDateTime FROM Task];
        quote = [SELECT QuoteTodo__c FROM Quote__c WHERE Id =: quoteId][0];

        Test.stopTest();

        // 検証
        System.assertEquals(taskList.size(),0);
        System.assertEquals(quote.QuoteTodo__c, null);
    }

    /**
     * 【対象】
     * afterUpdate
     * 【条件】
     * 異常系：更新の場合・見積担当者、見積書発行日が設定されており、見積担当者を削除する
     * 【結果】
     * 登録されていたTodoが削除されること
     * 見積に保持されていた割り当てられたTodoのIdが削除されること
     */
    @isTest
    public static void test_afterUpdate_003() {
        // データ準備
        User testUser = TestUtil.createUser('システム管理者');
        insert testUser;

        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // テスト開始
        Test.startTest();

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        quote.QuoteUser__c = testUser.Id;
        Date myDate = Date.today();
        Date newDate = myDate.addDays(2);
        quote.EstimateOutputDate__c = newDate;
        insert quote;

        Id quoteId = quote.Id;

        quote.QuoteUser__c = null;
        update quote;

        List<Task> taskList = [SELECT Id, toLabel(Subject), OwnerId, IsReminderSet, ActivityDate, ReminderDateTime FROM Task];
        quote = [SELECT QuoteTodo__c FROM Quote__c WHERE Id =: quoteId][0];

        Test.stopTest();

        // 検証
        System.assertEquals(taskList.size(),0);
        System.assertEquals(quote.QuoteTodo__c, null);
    }

    /**
     * 【対象】
     * afterUpdate
     * 【条件】
     * 正常系：更新の場合・もともと見積担当者が設定されておらず、Todoがない状態から、見積担当者が設定された場合
     * 【結果】
     * Todoが作成されること
     */
    @isTest
    public static void test_afterUpdate_004() {
        // データ準備
        User testUser = TestUtil.createUser('システム管理者');
        insert testUser;

        Account acc = TestUtil.createAccount();
        insert acc;

        Constitution_Common__c constitution = TestUtil.createConstitution(acc);
        insert constitution;

        // テスト開始
        Test.startTest();

        Quote__c quote = TestUtil.createQuote(acc.Id, constitution);
        //quote.QuoteUser__c = testUser.Id;
        Date myDate = Date.today();
        Date newDate = myDate.addDays(2);
        quote.EstimateOutputDate__c = newDate;
        insert quote;

        Id quoteId = quote.Id;

        quote.QuoteUser__c = testUser.Id;
        update quote;

        List<Task> taskList = [SELECT Id, toLabel(Subject), OwnerId, IsReminderSet, ActivityDate, ReminderDateTime FROM Task];
        quote = [SELECT QuoteTodo__c FROM Quote__c WHERE Id =: quoteId][0];

        Test.stopTest();

        // 検証
        System.assertEquals(taskList.size(),1);
        System.assertEquals(quote.QuoteTodo__c, taskList[0].Id);
        System.assertEquals(taskList[0].Subject, 'テスト案件');
        System.assertEquals(taskList[0].OwnerId, testUser.Id);
        System.assertEquals(taskList[0].IsReminderSet, True);
        System.assertEquals(taskList[0].ActivityDate, newDate);
        System.assertEquals(taskList[0].ReminderDateTime, DateTime.newInstance(newDate, Time.newInstance(10,0,0,0)));
    }
}