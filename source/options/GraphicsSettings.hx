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

class GraphicsSettings extends BaseOptionsMenu
{
	override function create() {
		var option:OptionPref = new OptionPref(
			'fpsCounter', 
			"FPS Counter",
			'bool',
			true
		);
		pushOption(option);

		var option:OptionPref = new OptionPref(
			'antialiasing', 
			"Antialiasing",
			'bool',
			true
		);
		pushOption(option);

		var option:OptionPref = new OptionPref(
			'fpsCap', 
			"Framerate Cap",
			'float',
			60.0,
			30.0,
			240.0,
			10.0
		);
		pushOption(option);
		
		var option:OptionPref = new OptionPref(
			'persistentCache', 
			"Persistent Cached Data",
			'bool',
			false
		);
		pushOption(option);
		
		var option:OptionPref = new OptionPref(
			'showMem', 
			"Memory Counter",
			'bool',
			true
		);
		pushOption(option);

		var option:OptionPref = new OptionPref(
			'hudAlpha', 
			"Game Hud Alpha",
			'float',
			1,
			0.5,
			1,
			0.1
		);
		pushOption(option);

		var option:OptionPref = new OptionPref(
			'healthAlpha', 
			"Health Bar Alpha",
			'float',
			1,
			0,
			1,
			0.1
		);
		pushOption(option);

		#if desktop
		if (FileSystem.isDirectory(Paths.mods('options/graphics/'))) {
			for (file in FileSystem.readDirectory(Paths.mods('options/graphics/'))) {
				var filePath:String = Paths.mods('options/graphics/') + file;
				if (file.endsWith('.txt')) {
					pushOption(CoolUtil.optionFromText(filePath));
				}
			}
		}
		#end

		super.create();
	}
}