package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import optionHelpers.*;
import helpers.*;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class NoteSettings extends BaseOptionsMenu
{
	override function create() {
		var option:OptionPref = new OptionPref(
			'noteOffset', 
			"Note Offset",
			'int',
			0,
			0,
			500
		);
		pushOption(option);

		#if desktop
		if (FileSystem.isDirectory(Paths.mods('options/notes/'))) {
			for (file in FileSystem.readDirectory(Paths.mods('options/notes/'))) {
				var filePath:String = Paths.mods('options/notes/') + file;
				if (file.endsWith('.txt')) {
					pushOption(CoolUtil.optionFromText(filePath));
				}
			}
		}
		#end
		
		super.create();
	}
}