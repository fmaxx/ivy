/**
 * Created by maxim on 15.06.2017.
 */
package service {

[Bindable]
public class IvyTickerVO {

    private var _isHistoricalValid:Boolean;
    private var _isTodayValid:Boolean;
    public var ticker:String;
    public var averageValue:Number;
    public var lastValue:Number;
    public var percents:Number;

    public function IvyTickerVO() {

    }


    public function addHistoricalData(rawData:Object):void{
        _isHistoricalValid = false;
        averageValue = 0;
        var quotes:Vector.<QuoteVO> = getQuotes(rawData);
        if(quotes && quotes.length > 0){
            _isHistoricalValid = true;
            for each (var quoteVO:QuoteVO in quotes) {
                averageValue += quoteVO.value;
            }
            averageValue /= quotes.length;
        }
        ticker = getTicker(rawData);
    }

    public function get isHistoricalValid():Boolean {
        return _isHistoricalValid;
    }

    public function addTodayData(rawData:Object):void {
        _isTodayValid = false;
        var quotes:Vector.<QuoteVO> = getQuotes(rawData);
        if(quotes && quotes.length > 0){
            _isTodayValid = true;
            lastValue = quotes[quotes.length - 1].value;
        }

        if(averageValue > 0 && lastValue > 0){
            percents = Math.round( (lastValue/averageValue - 1) * 10000)/100;
        }
    }

    public function get isTodayValid():Boolean {
        return _isTodayValid;
    }


    private function getQuotes(rawData:Object):Vector.<QuoteVO> {
        var out:Vector.<QuoteVO>;
        if(rawData && rawData.hasOwnProperty("chart") &&
                rawData.chart.hasOwnProperty("result")){
            var result:Object = rawData.chart.result[0]

            if(result && result.hasOwnProperty("indicators") &&
                    result.hasOwnProperty("timestamp") ){
                var timestamps:Array = result.timestamp;
                var closeQuotes:Array = result.indicators.quote[0].close;
                out = new <QuoteVO>[];

                for (var i:int = 0; i < timestamps.length; i++) {
                    var number:Number = timestamps[i];
                    out.push(new QuoteVO(number, closeQuotes[i]))
                }
            }
        }

        return out;
    }

    private function getTicker(rawData:Object):String{
        if(rawData && rawData.hasOwnProperty("chart") &&
                rawData.chart.hasOwnProperty("result")){
            var meta:Object = rawData.chart.result[0].meta;
            return meta.symbol;
        }
        return null;
    }
}
}
