package optionHelpers;

import haxe.ds.StringMap;
import flixel.input.keyboard.FlxKey;
import flixel.*;

using StringTools;

class GameSettings
{
	public var stringSettings:StringMap<String>;
	public var floatSettings:StringMap<Float>;
	public var intSettings:StringMap<Int>;
	public var boolSettings:Map<String, Bool>;

	public var keybinds:StringMap<Dynamic>;
	public var keybindArray:Array<String> = [FlxG.save.data.leftBind, FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind, FlxG.save.data.uiLeftBind, FlxG.save.data.uiDownBind, FlxG.save.data.uiUpBind, FlxG.save.data.uiRightBind];
	public var keyBlacklist:Array<String> = ["ENTER", "ESCAPE", "BACKSPACE"];
	public var gameSettingInfo:Map<String, Dynamic> = [];
	public var settingsList:Array<Array<Dynamic>> = [];
	public var noteSettings:Array<Array<Dynamic>> = [];
	public var graphicsSettings:Array<Array<Dynamic>> = [];

	public var trueSettings:Map<String, Dynamic> = [];

	public function new()
	{
		init();
	}

	public function init()
	{
		stringSettings = new StringMap<String>();
		floatSettings = new StringMap<Float>();
		intSettings = new StringMap<Int>();
		boolSettings = new Map<String, Bool>();
		keybinds = new StringMap<Dynamic>();

		if (!PlayerPrefs.loadedPrefs)
			PlayerPrefs.resetPrefs();

		resetSettings();
	}

	public function resetSettings()
	{
		keybinds.set("LeftBind", FlxG.save.data.leftBind);
		keybinds.set("DownBind", FlxG.save.data.downBind);
		keybinds.set("UpBind", FlxG.save.data.upBind);
		keybinds.set("RightBind", FlxG.save.data.rightBind);
		keybinds.set("SpaceBind", FlxG.save.data.dodgeBind);

		PlayerPrefs.savePrefs();
	}

	public function saveSettings()
	{
		FlxG.save.data.boolSettings = boolSettings;
		FlxG.save.data.stringSettings = stringSettings;
		FlxG.save.data.intSettings = intSettings;
		FlxG.save.data.floatSettings = floatSettings;

		resetSettings();
	}

	public function getKeyBind(direction:String):String
	{
		direction = direction.toLowerCase();

		var daKey:String = "";

		switch (direction)
		{
			case 'left':
				daKey = keybinds.get('LeftBind');
			case 'down':
				daKey = keybinds.get('DownBind');
			case 'up':
				daKey = keybinds.get('UpBind');
			case 'right':
				daKey = keybinds.get('RightBind');
			case 'space' | 'dodge':
				daKey = keybinds.get('SpaceBind');
		}

		return daKey;
	}

	public function getBindKey(direction:String):FlxKey
	{
		direction = direction.toLowerCase();

		var daKey:FlxKey = 32;

		switch (direction)
		{
			case 'left':
				daKey = FlxKey.fromString(keybinds.get('LeftBind'));
			case 'down':
				daKey = FlxKey.fromString(keybinds.get('DownBind'));
			case 'up':
				daKey = FlxKey.fromString(keybinds.get('UpBind'));
			case 'right':
				daKey = FlxKey.fromString(keybinds.get('RightBind'));
			case 'space' | 'dodge':
				daKey = FlxKey.fromString(keybinds.get('SpaceBind'));
			default:
				daKey = FlxKey.fromString('SPACE');
		}

		return daKey;
	}
}