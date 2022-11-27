package;

#if desktop
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef StageData =
{
	var boyfriendPos:Array<Float>;
	var dadPos:Array<Float>;
	var gfPos:Array<Float>;
	var camZoom:Float;
	var hidegf:Bool;
}

class Stage 
{
	public var boyfriendPos:Array<Float>;
	public var dadPos:Array<Float>;
	public var gfPos:Array<Float>;
	public var camZoom:Float;

	public function new(?curStage:String = '')
	{

	}

	public static function loadData(curStage:String = 'stage'):StageData
	{
		var jsonData = null;

		#if desktop
		if (FileSystem.exists(Paths.mods('stages/' + curStage + '/' + curStage + '.json')))
			jsonData = Json.parse(File.getContent(Paths.mods('stages/' + curStage + '/' + curStage + '.json')));
		else if (Assets.exists(Paths.getPreloadPath('stages/$curStage/$curStage.json')))
			jsonData = Json.parse(Assets.getText(Paths.getPreloadPath('stages/$curStage/$curStage.json')));
		#else
		if (Assets.exists(Paths.getPreloadPath('stages/$curStage/$curStage.json')))
			jsonData = Json.parse(Assets.getText(Paths.getPreloadPath('stages/$curStage/$curStage.json')));
		#end

		if (jsonData == null)
			jsonData = loadDefaultData(jsonData);

		return jsonData;
	}

	public static function loadDefaultData(jsonData = null):Any
	{
		jsonData = {
			"boyfriendPos": [770.0, 450.0],
			"dadPos": [100.0, 100.0],
			"gfPos": [400.0, 130.0],
			"camZoom": 1.0,
			"hidegf": false
		};

		return jsonData;
	}

}
