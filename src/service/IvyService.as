/**
 * Created by maximfirsov on 11/06/2017.
 */
package service {
import com.pk.utils.HTTPBuilder;

public class IvyService {

    private var tickers:Vector.<String>;
    private var onCompleteCallback:Function;
    private var onErrorCallback:Function;
    private var builder:HTTPBuilder;

    public function IvyService() {

    }

    public function run(tickers:Vector.<String>, onComplete:Function, onError:Function):void{
        this.tickers = tickers;
        this.onCompleteCallback = onComplete;
        this.onErrorCallback = onError;

        if(builder){
            builder.stop();
        }


    }

    public function stop():void {

    }
}
}
