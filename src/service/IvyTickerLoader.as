/**
 * Created by maxim on 15.06.2017.
 */
package service {
import com.pk.utils.HTTPBuilder;

import flash.net.URLRequestMethod;

import flash.net.URLVariables;

import service.IvyTickerVO;

public class IvyTickerLoader {

    public var onCompleteCallback:Function;
    public var onErrorCallback:Function;
    private var ticker:String;
    private var builder:HTTPBuilder;
    private var tickerVO:IvyTickerVO;

    public function IvyTickerLoader() {
        builder = new HTTPBuilder();
        builder.setMethod(URLRequestMethod.GET);
    }

    public function run(ticker:String,
                        onComplete:Function,
                        onError:Function):void{
        stop();
        this.ticker = ticker;
        this.onCompleteCallback = onComplete;
        this.onErrorCallback = onError;
        loadHistoricalData();
    }

    private function loadHistoricalData():void {
//        var urlVars:URLVariables = buildVariables("1y", "1mo");
        var urlVars:URLVariables = buildVariables(Settings.RANGE, Settings.INTERVAL);
        runBuilder(urlVars, onHistoricalHTTPComplete);
    }

    private function buildVariables(range:String, interval:String):URLVariables{
        var urlVars:URLVariables = new URLVariables();
        urlVars.range = range;
        urlVars.interval = interval;
        urlVars.indicators = "quote";
        urlVars.includeTimestamps = true;
        return urlVars;
    }

    private function runBuilder(urlVars:URLVariables, completeCallback:Function):void{
        builder.setGETData(urlVars)
                .setURL("https://query1.finance.yahoo.com/v7/finance/chart/" + ticker)
//                .setURL("https://query1.finance.yahoo.com/v7/finance/chart/YHOO?range=1y&interval=1mo&indicators=quote&includeTimestamps=true")
                .setOnCompleteCallback(completeCallback)
                .setOnErrorCallback(onHTTPError)
                .run();
    }

    private function onHistoricalHTTPComplete(data:Object = null):void{
        tickerVO = parseHistoricalData(data);
//        trace("onHistoricalHTTPComplete : " + tickerVO);
        if(tickerVO){
            loadTodayData();
        }else{
            callError();
        }
    }

    private function onTodayHTTPComplete(data:Object = null):void{
//        trace("onTodayHTTPComplete : " + data);
        var vo:IvyTickerVO = parseTodayData(data);
        if(vo){
            callComplete(vo);
        }else{
            callError();
        }
    }

    private function loadTodayData():void {
        var urlVars:URLVariables = buildVariables("1d", Settings.LAST_INTERVAL);
        runBuilder(urlVars, onTodayHTTPComplete);
    }

    private function callError():void {
        if( onErrorCallback != null){
            onErrorCallback();
        }
    }

    private function callComplete(tickerVO:IvyTickerVO):void {
        if( onCompleteCallback != null){
            onCompleteCallback(tickerVO);
        }
    }

    private function parseHistoricalData(data:Object):IvyTickerVO {
        try{
            var rawData:Object = JSON.parse(String(data));
            var tickerVO:IvyTickerVO = new IvyTickerVO();
            tickerVO.addHistoricalData(rawData);
            return tickerVO.isHistoricalValid ? tickerVO : null;
        }catch(e:Error){}
        return null;
    }

    private function parseTodayData(data:Object):IvyTickerVO {
        try{
            var rawData:Object = JSON.parse(String(data));
            tickerVO.addTodayData(rawData);
            return tickerVO.isTodayValid ? tickerVO : null;
        }catch(e:Error){}
        return null;
    }

    private function onHTTPError(data:Object = null):void{
        trace("onHTTPError : " + data);
        callError();
    }

    public function stop():void {
        this.onCompleteCallback = null;
        this.onErrorCallback = null;
        this.ticker = null;
        builder.stop();
    }


}
}
