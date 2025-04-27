/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * UT向けユーティリティ
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/06/08          M.Kawasaki       New
 ********************************************************************************/
@isTest
public class TestUtil {
    /**
     * UserRole
     *
     * @return UserRole
     */
    public static UserRole createUserRole() {
        UserRole role = new UserRole();
        role.Name = 'Kit_TestRole';
        return role;
    }
    /**
     * ユーザ
     *
     * @param profileName プロファイル名
     * @return ユーザ
     */
    public static User createUser(String profileName) {
        List<Profile> targetProfileList = [SELECT Id FROM Profile WHERE Name = :profileName ORDER BY CreatedDate LIMIT 1];
        User u = new User();
        u.LastName = 'テスト';
        u.FirstName = 'ユーザ';
        u.Username = 'KitaliveWellMe2' +  Date.today().format() + '@test.co.test';
        u.Email = 'Kitalive@test.co.test';
        u.Alias = '担当者';
        u.CommunityNickname = 'test担当者';
        u.TimeZoneSidKey = 'Asia/Tokyo';
        u.LocaleSidKey = 'ja_JP';
        u.EmailEncodingKey = 'ISO-2022-JP';
        u.ProfileId = targetProfileList[0].Id;
        u.LanguageLocaleKey = 'ja';
        return u;
    }

    /* 商品マスタ */
    public static Product__c createProducts(String taxType, Decimal unitPrice) {
        List<Product__c> productList = new List<Product__c>();
        Product__c product = new Product__c();
        product.Name = 'テスト商品';
        product.TaxType__c = taxType;
        product.UnitPrice__c = unitPrice;
        return product;
    }
    
    /* 取引先作成 */
    public static Account createAccount() {
        Account acc = new Account();
        acc.Name = 'テスト取引先';
        return acc;
    }

    /* 取引先責任者作成 */
    public static Contact createContact(Account acc) {
        Contact con = new Contact();
        con.FirstName = 'テスト';
        con.LastName = '取引先責任者';
        con.AccountId = acc.Id;
        return con;
    }

    /* 案件作成 */
    public static Constitution_Common__c createConstitution(Account acc) {
        Constitution_Common__c constitution = new Constitution_Common__c();
        constitution.Account__c = acc.Id;
        constitution.Name = 'テスト案件';
        return constitution;
    }

    /* 見積 */
    public static Quote__c createQuote(Id accId, Constitution_Common__c constitution) {
        Quote__c quote = new Quote__c();
        quote.BillAccount__c = accId;
        quote.ConstitutionCommon__c = constitution.Id;
        quote.EndUser__c = constitution.Account__c;
        return quote;
    }

    /* 見積明細 */
    public static QuoteDetail__c createQuoteDetail(Quote__c quote) {
        QuoteDetail__c qd = new QuoteDetail__c();
        qd.Quote__c = quote.Id;
        return qd;
    }

    /* 契約 */
    public static Contract__c createContract(Id accId, Constitution_Common__c constitution) {
        Contract__c contract = new Contract__c();
        contract.Billing__c = accId;
        contract.Constitution_Common__c = constitution.Id;
        contract.Account__c = constitution.Account__c;
        contract.Name = 'テスト契約';
        return contract;
    }

    /* 契約明細 */
    public static ContractDetail__c createContractDetail(Contract__c contract) {
        ContractDetail__c cd = new ContractDetail__c();
        cd.Contract__c = contract.Id;
        return cd;
    }


}