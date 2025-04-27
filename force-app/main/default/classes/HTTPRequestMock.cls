/********************************************************************************
 * SKY365 Source Materials.
 * Copyright (c) 2020 SKY365 Inc. All Rights Reserved.
 *
 * HTTPRequestMock
 *
 ********************************************************************************
 * Date        Name        Reason for change
 ********************************************************************************
 * 2020/10     kikuchi     新規作成
 ********************************************************************************/
@isTest
public class HTTPRequestMock implements HttpCalloutMock {
    public Integer statusCode { get; set; }
    public String body {get; set;}
 
   /**
    * コンストラクタ
    *
    */    
    public HTTPRequestMock (Integer code) {
    	this.statusCode = code;
        this.body = null;
    }
 
  /**
    * コンストラクタ
    *
    */    
    public HTTPRequestMock (Integer code, String body) {
    	this.statusCode = code;
        this.body = body;
    }
 
   /**
    * レスポンス
    *
    */    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(this.statusCode);
        if (!String.isEmpty(body)) {
            res.setBody(body);
        }
        return res;
    }
}