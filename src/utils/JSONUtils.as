package utils {

public class JSONUtils {

    static public function parse(data:*):Object{
        var result:Object = {};
        var json:Object;
        var err:Error;
        try{
            json = JSON.parse(String(data));
        }catch(e:Error){
            err = e;
        }

        result.ok = (err == null);
        result.json = json;
        result.data = data;
        result.err = err;
        return result;
    }

    static public function stringify(obj:*):String {
        var result:String;
        try{
            result = JSON.stringify(obj, null, 4);
        }catch (e:Error){
            trace("[Error] JSONUtils.stringify : " + e);
        }
        return result;
    }

    static public function prettyPrint(obj:Object):String{
        if(!obj) return "null";
        var result:String;
        try{
            result = JSON.stringify(obj, null, 4);
        }catch (e:Error){
            trace("[Error] JSONUtils.prettyPrint : " + e);
        }
        return result;
    }

}
}
