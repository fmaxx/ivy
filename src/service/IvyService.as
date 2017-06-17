/**
 * Created by maximfirsov on 11/06/2017.
 */
package service {
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

public class IvyService {

    private var tickers:Vector.<String>;
    private var loadedTickers:int;
    private var currentTicker: String;

    private var onCompleteCallback:Function;
    private var onErrorCallback:Function;
    private var onProgressCallback:Function;
    private var loadingTimeout:int;
    private var loader:IvyTickerLoader;

    public function IvyService() {
        loader = new IvyTickerLoader();
        loader.onCompleteCallback = onLoaderComplete;
        loader.onErrorCallback = onLoaderError;
    }

    public function run(tickers:Vector.<String>,
                        onComplete:Function,
                        onProgress:Function,
                        onError:Function):void{

        stop();

        this.tickers = tickers;
        this.onCompleteCallback = onComplete;
        this.onProgressCallback = onProgress;
        this.onErrorCallback = onError;

        nextTicker();
    }

    private function nextTicker():void {
        clearTimeout(loadingTimeout);
        var ind:int = tickers.indexOf(currentTicker);
        if(ind == (tickers.length - 1)){
            // completed
            trace('##########################');
        }else{
            currentTicker = tickers[ind + 1];
            var delay:int =randomTimeout();
            loadingTimeout = setTimeout(doLoad, delay);
        }
    }

    private function doLoad():void{
        trace("doLoad : " + currentTicker);
        loadTicker(currentTicker);
    }

    private function randomTimeout(min:int = 50, max:int = 300):int{
        var delta:int = max - min;
        return min + delta * Math.random();
    }

    private function loadTicker(ticker:String):void{
        loader.run(ticker, onLoaderComplete, onLoaderError);
    }

    private function onLoaderComplete(data:IvyTickerVO = null):void{
        trace("onHTTPComplete : " + data);
        loadedTickers++;
        callProgress(data);
        nextTicker();
    }

    private function callProgress(data:IvyTickerVO):void {
        if (onProgressCallback != null) {
            onProgressCallback(new IvyDownloadProgressVO(loadedTickers/tickers.length, data));
        }
    }

    private function onLoaderError(data:Object = null):void{
        trace("onHTTPError : " + data);
        loadedTickers++;
        nextTicker();
    }

    public function stop():void {
        this.onCompleteCallback = null;
        this.onProgressCallback = null;
        this.onErrorCallback = null;
        loader.stop();
        loadedTickers = 0;
        currentTicker = null;
        clearTimeout(loadingTimeout);
    }
}
}
