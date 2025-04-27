/********************************************************************************
 *
 * JSONからCSV生成クラスのテストクラス
 *
 ********************************************************************************
 * Date                Name             Reason for change
 ********************************************************************************
 * 2024/03                              New
 ********************************************************************************/
@isTest
private class JsonToCsvConverterTest {
    @isTest
    static void testConvertJsonToCsvWithEscapedCharacters() {
        // 特殊文字をエスケープする必要があるテストJSONデータを用意する
        Map<String, Object> testJson = new Map<String, Object>{
            'result' => new List<Object>{
                new Map<String, Object>{'itemid' => '39053', 'clock' => '1707660233', 'value' => 'Quote"Value', 'ns' => 'New\r\nLine'},
                new Map<String, Object>{'itemid' => '39053', 'clock' => '1707660173', 'value' => 'Comma,Value', 'ns' => '152736787'}
            }
        };

        // 期待されるCSV文字列（エスケープされた）を準備する
        String expectedCsv = '';
        expectedCsv += 'itemid,clock,value,ns\r\n';
        expectedCsv += '39053,1707660233,"Quote""Value","New\r\nLine"\r\n';
        expectedCsv += '39053,1707660173,"Comma,Value",152736787\r\n';

        // convertJsonToCsv() メソッドを実行する
        String actualCsv = JsonToCsvConverter.convertJsonToCsv(testJson);

        // 生成されたCSV文字列と期待されるCSVを検証する
        System.assertEquals(expectedCsv, actualCsv);
    }
    @isTest
    static void testEmptyResultList() {
        // 結果リストが空のテストJSONデータを用意する
        Map<String, Object> testJson = new Map<String, Object>{
            'result' => new List<Object>{}
        };

        // 空の結果リストの期待されるCSVはヘッダもデータも含まない
        String expectedCsv = '';

        // convertJsonToCsv() メソッドを実行する
        String actualCsv = JsonToCsvConverter.convertJsonToCsv(testJson);

        // 生成されたCSV文字列が空であることを検証する
        System.assertEquals(expectedCsv, actualCsv);
    }
}