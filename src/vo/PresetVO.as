/**
 * Created by maximfirsov on 09/07/2017.
 */
package vo {
import utils.JSONUtils;

[Bindable]
public class PresetVO {

    public var label:String;
    public var tickers:Array;
    public var all:Boolean;

    public function PresetVO() {

    }


    public function toJSONString():String{
        return JSONUtils.stringify(this);
    }

    public function fromJSONString(str:String):void{
        var obj:Object =  JSONUtils.parse(str);
        if(obj.ok){
            this.label = obj.json.label;
            this.tickers = obj.json.tickers;
        }
    }


}
}
