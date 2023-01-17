package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
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

class StringSelector extends FlxObject
{
	public var alphaParent:Alphabet;
	public var alphaText:String = "";
	public var alphabetText:Alphabet;

	public function new(x:Float, y:Float, curValue:String, defaultValue:String, className:String = 'OptionPrefs')
	{
		if (curValue != '' && curValue != null)
			alphaText = curValue;
		else
			alphaText = defaultValue;
		alphabetText = new Alphabet(0, 0, curValue, false, false);
		switch (className)
		{
			case 'OptionPrefs':
				OptionPrefs.instance.add(alphabetText);
			case 'NotePrefs':
				NotePrefs.instance.add(alphabetText);
			case 'ModPrefs':
				ModPrefs.instance.add(alphabetText);
		}

		visible = false;
		super(x, y);
	}

	public function changeAlphaText(newText) {
		alphabetText.setText(alphaText);
	}
}
