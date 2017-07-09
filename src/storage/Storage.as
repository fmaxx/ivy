/**
 * Created by maximfirsov on 09/07/2017.
 */
package storage {
import flash.net.SharedObject;

import org.apache.flex.collections.VectorCollection;

import vo.PresetVO;

public class Storage {

    public function Storage() {

    }

    static public function getSavedPresets():VectorCollection{
        var result:Vector.<PresetVO> = new <PresetVO>[];

        var all:PresetVO = new PresetVO();
        all.label = "All";
        all.all = true;
        result.push(all);

        var sharedObject:SharedObject = SharedObject.getLocal("presets");
        if(sharedObject.size > 0){
            var arr:Array = sharedObject.data.presets;
            for each (var string:String in arr) {
                var presetVO:PresetVO = new PresetVO();
                presetVO.fromJSONString(string);
                result.push(presetVO);
            }
        }
        return new VectorCollection(result);

    }

    static public function savePreset(preset:PresetVO):void{
        if(!preset)return;
        var sharedObject:SharedObject = SharedObject.getLocal("presets");
        if(sharedObject.size == 0){
            sharedObject.data.presets = [];
        }
        sharedObject.data.presets.push(preset.toJSONString());
        sharedObject.flush();
    }

    static public function removePreset(preset:PresetVO):void{
        if(!preset)return;
        var sharedObject:SharedObject = SharedObject.getLocal("presets");
        if(sharedObject.size == 0){
            sharedObject.data.presets = [];
        }
        var presets:Array = sharedObject.data.presets;
        for each (var string:String in presets) {
            var presetVO:PresetVO = new PresetVO();
            presetVO.fromJSONString(string);
            if(presetVO.label == preset.label){
                presets.removeAt(presets.indexOf(string));
                break;
            }
        }
        sharedObject.flush();
    }
}
}
