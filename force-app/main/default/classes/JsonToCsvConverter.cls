public class JsonToCsvConverter {
    
    public static String convertJsonToCsv(Map<String, Object> resultJson) {

        System.debug('**== convertJsonToCsv start ==**');
        // JSONの`result`部分をデシリアライズ
        // List<Object> resultList = (List<Object>)JSON.deserializeUntyped(jsonString);
        List<Object> resultList = (List<Object>) resultJson.get('result');
        System.debug('**== resultList: ' + resultList);

        // CSVデータの初期化
        String csvString = '';
        Set<String> headerSet = new Set<String>();
        
        if (!resultList.isEmpty()) {
            // ヘッダーを取得するために最初の結果要素だけ見る
            Map<String, Object> firstResult = (Map<String, Object>)resultList[0];
            System.debug('**== firstResult: ' + firstResult);
            for (String key : firstResult.keySet()) {
                headerSet.add(key);
            }
            
            // ヘッダーリストをCSV文字列として書き出す
            List<String> headerList = new List<String>(headerSet);
            // csvString = String.join(headerList, ',') + '\n';
            // csvString = String.join(headerList, ',') + '<br/>';
            csvString = String.join(headerList, ',') + '\r\n';
        }
        
        // 各エントリ（各行）をループ処理してCSVデータを構築する
        for (Object result : resultList) {
            Map<String, Object> resultItem = (Map<String, Object>)result;
            List<String> values = new List<String>();
            for (String header : headerSet) {
                // 値を取得し、CSVの規則に従ってエスケープする
                Object value = resultItem.get(header);
                String valueStr = (value != null) ? String.valueOf(value) : '';
                
                // if (valueStr.contains('"')) { 
                //     valueStr = valueStr.replace('"', '""'); 
                // }
                // if (valueStr.contains(',') || valueStr.contains('\r\n')) {
                //     valueStr = '"' + valueStr.replace('"', '""') + '"';
                //     valueStr = '"' + valueStr + '"'; 
                // }
                if (valueStr.contains('"') || valueStr.contains(',') || valueStr.contains('\n')) {
                    valueStr = '"' + valueStr.replace('"', '""') + '"';
                }
                values.add(valueStr);
            }
            // csvString += String.join(values, ',') + '\n';
            // csvString += String.join(values, ',') + '<br/>';
            csvString += String.join(values, ',') + '\r\n';
        }

        // 生成されたCSV文字列を返す
        return csvString;
    }

}