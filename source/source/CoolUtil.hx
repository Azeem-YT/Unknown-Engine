package;

import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String {
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{

		var fileExists:Bool;

		#if desktop
		fileExists = FileSystem.exists(path);
		#else
		fileExists.Assets.exists(path);
		#end

		if (fileExists) {
			#if desktop
			var daList:Array<String> = File.getContent(path).trim().split('\n');
			#else
			var daList:Array<String> = Assets.getText(path).trim().split('\n');
			#end

			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}

			return daList;
		}

		return [];
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function spaceToDash(text:String):String
	{
		var returnValue:String = text;

		if (returnValue != null)
			returnValue = StringTools.replace(returnValue, " ", "-");

		return returnValue;
	}

	public static function stringToArray(text:String = null):Array<String> {
		var returnValue:Array<String> = [];

		if (text != null) {
			text = StringTools.replace(text, "[", "");
			text = StringTools.replace(text, "]", "");

			var stringList:Array<String> = text.split(",");
			for (i in 0...stringList.length)
				returnValue.push(stringList[i]);
		}

		return returnValue;
	}

	public static function stringToBool(text:String = null):Bool {
		if (text != null) {
			return switch (text) {
				case 'true': true;
				case 'false': false;
				default: false;
			}
		}

		return false;
	}

	public static function optionFromText(path:String):OptionPref { //A
		#if desktop
		var list:Array<String> = File.getContent(path).trim().split('\n');
		#else
		var list:Array<String> = Assets.getText(path).trim().split('\n');
		#end

		var option:OptionPref = null;

		for (i in 0...list.length)
			list[i] = list[i].trim();

		switch (list[2]) {
			case 'bool':
				option = new OptionPref(
					list[0],
					list[1],
					'bool',
					stringToBool(list[3])
				);
			case 'float':
				var defaultValue:Float = 0;
				var maxVal:Float = 10;
				var minVal:Float = 0;
				var valueAddBy:Float = 1;

				defaultValue = Math.round(Std.parseFloat(list[3]));
				maxVal = Math.round(Std.parseFloat(list[4]));
				minVal = Math.round(Std.parseFloat(list[5]));
				valueAddBy = Math.round(Std.parseFloat(list[6]));

				option = new OptionPref(
					list[0],
					list[1],
					'float',
					defaultValue,
					maxVal,
					minVal,
					valueAddBy
				);
			case 'int':
				var defaultValue:Int = 0;
				var maxVal:Int = 10;
				var minVal:Int = 0;
				var valueAddBy:Int = 1;

				defaultValue = Math.round(Std.parseInt(list[3]));
				maxVal = Math.round(Std.parseInt(list[4]));
				minVal = Math.round(Std.parseInt(list[5]));
				valueAddBy = Math.round(Std.parseInt(list[6]));

				option = new OptionPref(
					list[0],
					list[1],
					'int',
					defaultValue,
					maxVal,
					minVal,
					valueAddBy
				);
			case 'string':
				option = new OptionPref(
					list[0],
					list[1],
					'string',
					list[3],
					0,
					0,
					0,
					stringToArray(list[7])
				);
		}

		if (option != null)
			return option;
		else
			return new OptionPref(
				'error',
				'Error With Option',
				'bool',
				false
			);
	}
}
