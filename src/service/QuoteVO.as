/**
 * Created by maximfirsov on 17/06/2017.
 */
package service {
public class QuoteVO {

    public var date:Date;
    public var value:Number;

    public function QuoteVO(timestamp:Number, value:Number) {
        date = new Date(timestamp * 1000)
        this.value = value;
    }
}
}
