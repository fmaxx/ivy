/**
 * Created by maxim on 14.09.2016.
 */
package com.pk.utils {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLStream;
import flash.net.URLVariables;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

public class HTTPBuilder {

    public static const URL_STREAM:String = "url_stream";
    public static const URL_LOADER:String = "url_loader";
    public static const MAX_ATTEMPTS:uint = 10;
    public static const MAX_ATTEMPTS_REACHED:String = "max_attempts_reached";


    private var _method:String;
    private var _url:String;
    private var _loaderType:String;
    private var _dataFormat:String = URLLoaderDataFormat.TEXT;
    private var _requestHeaders:Vector.<URLRequestHeader>;
    private var _POSTBody:Object;
    private var _GETBody:URLVariables;
    private var _httpStatus:int = -1;
    private var _maxAttempts:uint = 3;
    private var _numAttempts:uint;

    private var onHTTPStatus:Function;
    private var onComplete:Function;
    private var onError:Function;
    private var onProgress:Function;

    private var _isRunning:Boolean;
    private var loader:EventDispatcher;
    private var queryURL:String;
    private var request:URLRequest;
    private var runTimeout:int;
    private var _lastErrorEvent:Event;


    public function HTTPBuilder(url:String = "",
                                method:String = "POST",
                                loaderType:String = URL_STREAM) {
        setMethod(method);
        setURL(url);
        setLoaderType(loaderType);
    }

    public function run():HTTPBuilder{
        if(_isRunning) {
            return this;
        }
        _isRunning = true;
        if(loader == null){
            loader = createLoader(_loaderType);
            addEvents(loader);
        }

        _httpStatus = -1;
        _numAttempts = 0;
        _lastErrorEvent = null;
        queryURL = buildQuery();
//        trace("queryURL : " + queryURL);
        request = buildRequest(queryURL);
        doRun();
        return this;
    }

    private function doRun():void{
//        trace("loader : " + loader);
        try{
            loader["load"](request);
        }catch (e:Error){
            stop();
            callError(e);
        }
    }

    private function repeat():void{
        _numAttempts++;
        if(_numAttempts >= _maxAttempts){
            callError(new Error(MAX_ATTEMPTS_REACHED, _maxAttempts));
            return;
        }
        clearTimeout(runTimeout);
        runTimeout = setTimeout(doRun, getRunDelay());
    }

    private function getRunDelay():Number {
        return Math.pow(_numAttempts, 2) * 200;
    }

    private function callComplete(data:*):void {
        if(onComplete != null){
            onComplete(data);
        }
    }

    private function callError(arg_Error_or_ErrorEvent:*):void {
        if(onError != null){
            onError(arg_Error_or_ErrorEvent);
        }
    }

    private function buildQuery():String {
        var query:String = _url;
//        trace("_method : " + _method);
        if(_method == URLRequestMethod.GET) {
            var vars_str:String = parseURLVariables(_GETBody).join("&");
//            trace("vars_str : " + vars_str);
            if (_url.indexOf("?") == -1) {
                query = _url + "?" + vars_str;
            } else {
                query = _url + "&" + vars_str;
            }
        }
        return query;
    }

    private function buildRequest(queryURL:String):URLRequest{
        var request:URLRequest = new URLRequest(queryURL);
        request.data = buildData();
        var headers:Array = [];
        for each (var header:URLRequestHeader in _requestHeaders) {
            headers.push(header);
        }
        request.requestHeaders = headers;
        request.method = _method;
        return request;
    }

    private function buildData():Object{
        if(_method == URLRequestMethod.POST){
            if(_POSTBody){
                if( (_POSTBody is URLVariables) == false){
                    // JSON!
                    return JSON.stringify(_POSTBody);
                }
            }

        }
        return _POSTBody;
    }

    private function parseURLVariables(data:URLVariables):Vector.<String>{
        var result:Vector.<String> = new Vector.<String>();
        for (var parameter:String in data) {
            result.push(parameter + "=" + data[parameter]);
        }
        return result;
    }

    private function addEvents(loader:EventDispatcher):void {
        if(loader == null) return;
        loader.addEventListener(Event.COMPLETE, onLoaderComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
        loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
    }

    private function removeEvents(loader:EventDispatcher):void {
        if(loader == null) return;
        loader.removeEventListener(Event.COMPLETE, onLoaderComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
        loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
    }


    private function onLoaderHTTPStatus(event:HTTPStatusEvent):void {
        _httpStatus = event.status;
        if(onHTTPStatus != null){
            onHTTPStatus(_httpStatus);
        }
    }

    private function onLoaderError(event:ErrorEvent):void {
        _lastErrorEvent = event.clone();
        repeat();
    }

    private function onLoaderComplete(event:Event):void {
//        trace("onLoaderComplete : " + loader["data"] );
        if(_httpStatus == -1 || _httpStatus == 200){
            // parse result
            var data:* = parseData(loader);
            callComplete(data);
        }else{
            // something is wrong, try to reload...
            repeat();
        }
    }



    private function parseData(loader:EventDispatcher):* {
        var result:*;
        if(_loaderType == URL_STREAM){
            var urlStream:URLStream = URLStream(loader);
            try{
                result = urlStream.readUTFBytes(urlStream.bytesAvailable);
            }catch(e:Error){
                trace("[Error HTTPBuilder.parseData] : " + e);
            }
        }else{
            result = loader["data"];
        }
        return result;
    }

    private function createLoader(type:String):EventDispatcher {
        if(type == URL_STREAM){
            return new URLStream();
        }else{
            var l:URLLoader = new URLLoader();
            l.dataFormat = _dataFormat;
            return new URLLoader();
        }
    }

    public function stop():void{
        if(!_isRunning) return;
        _isRunning = false;
        clearTimeout(runTimeout);
        stopLoader();
    }

    private function stopLoader():void {
        if(loader){
            try{
                loader["close"]()
            }catch (e:Error){}
        }
    }

    public function dispose():void{
        stop();
        removeEvents(loader);
        loader = null;
        _requestHeaders = null;
        _method = null;
        _url = null;
        _loaderType = null;
        _POSTBody = null;
        _GETBody = null;
        onComplete = onHTTPStatus = onProgress = onError = null;
    }

    public function setMethod(method:String):HTTPBuilder{
        this._method = method;
        return this;
    }

    public function setURL(url:String):HTTPBuilder{
        this._url = url;
        return this;
    }

    public function setLoaderType(type:String):HTTPBuilder{
        if(type == URL_STREAM || type == URL_LOADER){
            this._loaderType = type;
        }else{
            this._loaderType = URL_STREAM;
        }
        return this;
    }

    public function setMaxAttempts(value:uint):HTTPBuilder{
        value  = value > MAX_ATTEMPTS ? MAX_ATTEMPTS : value;
        value  = value < 0 ? 0 : value;
        _maxAttempts = value;
        return this;
    }

    public function setDataFormat(value:String):HTTPBuilder{
        if(value == URLLoaderDataFormat.TEXT || value == URLLoaderDataFormat.BINARY || value == URLLoaderDataFormat.VARIABLES){
            _dataFormat = value;
        }
        return this;
    }

    public function setPOSTData(data:URLVariables):HTTPBuilder{
        _POSTBody = data;
        return this;
    }

    public function setPostJSONData(jsonData:Object):HTTPBuilder{
        _POSTBody = jsonData;
        return this;
    }

    public function setGETData(data:URLVariables):HTTPBuilder{
        _GETBody = data;
        return this;
    }

    public function setOnCompleteCallback(callback:Function):HTTPBuilder{
        onComplete = callback;
        return this;
    }

    public function setOnHTTPStatusCallback(callback:Function):HTTPBuilder{
        onHTTPStatus = callback;
        return this;
    }

    public function setOnProgessCallback(callback:Function):HTTPBuilder{
        onProgress = callback;
        return this;
    }

    public function setOnErrorCallback(callback:Function):HTTPBuilder{
        onError = callback;
        return this;
    }

    public function get method():String {
        return _method;
    }

    public function get url():String {
        return _url;
    }

    public function get requestHeaders():Vector.<URLRequestHeader> {
        return _requestHeaders ? _requestHeaders.concat() : null;
    }

    public function setRequestHeaders(value:Vector.<URLRequestHeader>):HTTPBuilder {
        _requestHeaders = value;
        return this;
    }

    public function get POSTBody():Object {
        return _POSTBody;
    }

    public function get GETBody():URLVariables {
        return _GETBody;
    }

    public function get isRunning():Boolean {
        return _isRunning;
    }

    public function get lastErrorEvent():Event {
        return _lastErrorEvent;
    }

    public function get httpStatus():int {
        return _httpStatus;
    }


}
}
