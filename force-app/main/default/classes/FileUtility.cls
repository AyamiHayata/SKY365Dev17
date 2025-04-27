public class FileUtility {

    /**
     * ファイル作成
     * 
     * @param title タイトル
     * @param file PDFファイル
     * @param fileName ファイル名
     * @return ContentVersion
     */
    public static ContentVersion createContentVersion(String title, Blob file, String fileName) {

        ContentVersion cv = new ContentVersion();
        cv.Title          = title;
        cv.PathOnClient   = fileName;
        cv.IsMajorVersion = true;

        if (!Test.isRunningTest()) {
            cv.VersionData = file; // 本文
        }else{
            cv.VersionData = Blob.valueOf('test');
        }

        return cv;
    }

    /**
     * ContentDocumentLink作成
     * 
     * @param contentDocumentId ファイルID
     * @param entityId 関連先ID
     * @return ContentDocumentLink
     */
    public static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id entityId) {

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = entityId;

        return cdl;
    }
}