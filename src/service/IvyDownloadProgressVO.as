/**
 * Created by maxim on 15.06.2017.
 */
package service {
public class IvyDownloadProgressVO {

    public var value:Number;
    public var data:Object;

    public function IvyDownloadProgressVO(value:Number, data:Object) {
        this.value = value;
        this.data = data;
    }

    public function dispose():void {
        data = null;
    }
}
}
