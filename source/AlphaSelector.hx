package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxFrame;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import OptionsState;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end

class AlphaSelector extends FlxObject
{
	public var alphaParent:Alphabet;
	public var alphabetNumb:Alphabet;
	public var alphaText:String = "";
	public var targetY:Float;
	public var curValue:Float = 0;
	public var offsetMap:Map<String, Array<Dynamic>>;
	//public var selectorRight:FlxSprite;
	//public var selectorLeft:FlxSprite;
	public var valueType:String;
	public var className:String = 'OptionPrefs';

	public function new(x:Float, y:Float, minValue:Float, maxValue:Float, curValue:Dynamic, defaultVal:Dynamic, valueType:String, parentClass:String = 'OptionPrefs')
	{
		className = parentClass;
		//Was Planned on having Selector Arrows but it would crash game :(

		alphabetNumb = new Alphabet(0, 0, (valueType == 'float' ? Std.string(FlxMath.roundDecimal(curValue, 2)) : Std.string(Math.round(curValue))), false, false);
		alphaText = alphabetNumb.text;
		switch (className)
		{
			case 'OptionPrefs':
				OptionPrefs.instance.add(alphabetNumb);
			case 'NotePrefs':
				NotePrefs.instance.add(alphabetNumb);
			case 'ModPrefs':
				ModPrefs.instance.add(alphabetNumb);
		}

		visible = false;
		super(x, y);
	}

	public function changeAlphaText(newText:String) {
		alphabetNumb.setText(newText);
	}
}
