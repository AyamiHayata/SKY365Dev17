/********************************************************************************
 * Kitalive Source Materials.
 * Copyright (c) 2021 Kitalive Inc. All Rights Reserved.
 *
 * 共通関数テストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2021/07/28          R.Matsui          New
 ********************************************************************************/
@isTest
private class CommonUtilTest {
    /**
     * 【対象】
     * setSplit
     * 【条件】
     * 文字入力なし
     * 【結果】
     * 行数分の空文字行が作成されること
     */
    @isTest
    public static void test_execute_001(){
        // データ準備
        String Data = '';
        Integer maxRowNum = 5;
        Decimal maxLen = 60;

        List<String> result = new List<String>();

        Test.startTest();
        result = CommonUtil.setSplit(data, maxRowNum, maxLen);

        Test.stopTest();

        System.assertEquals(result.size(), maxRowNum);
        System.assertEquals(result.get(0),'　');
        System.assertEquals(result.get(1),'　');
        System.assertEquals(result.get(2),'　');
        System.assertEquals(result.get(3),'　');
        System.assertEquals(result.get(4),'　');
    }

    /**
     * 【対象】
     * setSplit
     * 【条件】
     * 文字入力あり、改行文字数以内
     * 【結果】
     * 入力文字が改行されないこと
     * 行数分の空文字行が作成されること
     */
    @isTest
    public static void test_execute_002(){
        // データ準備
        String Data = 'あいうえおかきくけこ１２３４５６７８９０';
        Integer maxRowNum = 5;
        Decimal maxLen = 60;

        List<String> result = new List<String>();

        Test.startTest();
        result = CommonUtil.setSplit(data, maxRowNum, maxLen);

        Test.stopTest();

        System.assertEquals(result.size(), maxRowNum);
        System.assertEquals(result.get(0),'あいうえおかきくけこ１２３４５６７８９０');
        System.assertEquals(result.get(1),'　');
        System.assertEquals(result.get(2),'　');
        System.assertEquals(result.get(3),'　');
        System.assertEquals(result.get(4),'　');
    }

    /**
     * 【対象】
     * setSplit
     * 【条件】
     * 文字入力あり、改行文字数以上入力
     * 【結果】
     * 入力文字が改行されなること
     * 行数分の空文字行が作成されること
     */
    @isTest
    public static void test_execute_003(){
        // データ準備
        String Data1 = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほ';
        String Data2 = '２２２２２２２２２２２２２２２２２２２２２２２２２２２２２２';
        String Data3 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz12345678';
        String Data4 = '1234567890';
        Integer maxRowNum = 5;
        Decimal maxLen = 60;

        List<String> result = new List<String>();

        Test.startTest();
        result = CommonUtil.setSplit(data1+data2+data3+data4, maxRowNum, maxLen);

        Test.stopTest();

        System.assertEquals(result.size(), maxRowNum);
        System.assertEquals(result.get(0),data1+data2);
        System.assertEquals(result.get(1),data3);
        System.assertEquals(result.get(2),data4);
        System.assertEquals(result.get(3),'　');
        System.assertEquals(result.get(4),'　');
    }

    /**
     * 【対象】
     * setSplit
     * 【条件】
     * 文字入力あり、改行文字数以上入力かつ表示最大行数超過
     * 【結果】
     * 入力文字が改行されなること
     * 最大行数以上の行が削除されること
     */
    @isTest
    public static void test_execute_004(){
        // データ準備
        String Data1 = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほ';
        String Data2 = '２２２２２２２２２２２２２２２２２２２２２２２２２２２２２２';
        String Data3 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz12345678';
        String Data4 = '1234567890';
        Integer maxRowNum = 2;
        Decimal maxLen = 60;

        List<String> result = new List<String>();

        Test.startTest();
        result = CommonUtil.setSplit(data1+data2+data3+data4, maxRowNum, maxLen);

        Test.stopTest();

        System.assertEquals(result.size(), maxRowNum);
        System.assertEquals(result.get(0),data1+data2);
        System.assertEquals(result.get(1),data3);
    }
}