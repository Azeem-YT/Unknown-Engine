package optionHelpers;

import flixel.FlxG;
import haxe.ds.StringMap;
import flixel.input.keyboard.FlxKey;

using StringTools;

enum SettingTypes
{
	Int;
	Checkmark;
	Bool;
	Float;
	String;
}

class GameSettings
{
	public var stringSettings:StringMap<String>;
	public var boolSettings:Map<String, Bool>;

	public var keybinds:StringMap<Dynamic>;
	public var keybindArray:Array<String> = [FlxG.save.data.leftBind, FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind, FlxG.save.data.uiLeftBind, FlxG.save.data.uiDownBind, FlxG.save.data.uiUpBind, FlxG.save.data.uiRightBind];
	public var keyBlacklist:Array<String> = ["ENTER", "ESCAPE", "BACKSPACE"];
	public var gameSettingInfo:Map<String, Dynamic> = [
		'Downscroll' => [
			FlxG.save.data.downscroll,
			Checkmark,
			'If Checked, the strumline will be flipped vertically.'
		],
		'Middlescroll' => [
			FlxG.save.data.middlescroll,
			Checkmark,
			'If Checked, the strumline will be on the middle of the screen.'
		],
		'FPS Counter' => [
			FlxG.save.data.fpsCounter,
			Checkmark,
			'If Checked, an Fps Counter will apear on the top left of the game.'
		],
		'Ghost Tapping' => [
			FlxG.save.data.ghostTapping,
			Checkmark,
			'If Checked, Ghost Tapping allowing you to press inputs without missing.'
		],
		'Play Opponent Side' => [
			FlxG.save.data.opponentSide,
			Checkmark,
			"Play the opponent's side instead of the player's side!"
		]
	];

	public var trueSettings:Map<String, Dynamic> = [];

	public function new()
	{
		init();
	}

	public function init()
	{
		stringSettings = new StringMap<String>();
		boolSettings = new Map<String, Bool>();
		keybinds = new StringMap<Dynamic>();

		boolSettings.set("Downscroll", FlxG.save.data.downscroll);
		boolSettings.set("Middlescroll", FlxG.save.data.middlescroll);
		boolSettings.set("Ghost Tapping", FlxG.save.data.ghostTapping);
		boolSettings.set("FPS Counter", FlxG.save.data.fpsCounter);
		boolSettings.set("Play Opponent Side", FlxG.save.data.opponentSide);
		keybinds.set("LeftBind", FlxG.save.data.leftBind);
		keybinds.set("DownBind", FlxG.save.data.downBind);
		keybinds.set("UpBind", FlxG.save.data.upBind);
		keybinds.set("RightBind", FlxG.save.data.rightBind);
		keybinds.set("SpaceBind", FlxG.save.data.dodgeBind);

		for (shit in gameSettingInfo.keys())
		{
			if (gameSettingInfo.get(shit) == SettingTypes.Checkmark)
				trueSettings.set(gameSettingInfo.get(shit), gameSettingInfo.get(shit)[0]);
		}

		if (FlxG.save.data.saveSettings == null)
			FlxG.save.data.saveSettings = trueSettings;
		else
			trueSettings = FlxG.save.data.saveSettings;
	}

	public function saveSettings()
	{
		FlxG.save.data.saveSettings = trueSettings;

		var stringSetting:Array<String> = [];

		for (lel in stringSettings.keys())
		{
			stringSetting.push(stringSettings.get(lel));
		}

		FlxG.save.data.stringSettings = stringSetting;

		var boolSetting:Array<Bool> = [];
		
		for (lel in stringSettings.keys())
		{
			boolSetting.push(boolSettings.get(lel));
		}

		FlxG.save.data.boolSettings = boolSetting;

		boolSettings.set("Downscroll", FlxG.save.data.downscroll);
		boolSettings.set("Middlescroll", FlxG.save.data.middlescroll);
		boolSettings.set("Ghost Tapping", FlxG.save.data.ghostTapping);
		boolSettings.set("FPS Counter", FlxG.save.data.fpsCounter);
		boolSettings.set("Play Opponent Side", FlxG.save.data.opponentSide);
		keybinds.set("LeftBind", FlxG.save.data.leftBind);
		keybinds.set("DownBind", FlxG.save.data.downBind);
		keybinds.set("UpBind", FlxG.save.data.upBind);
		keybinds.set("RightBind", FlxG.save.data.rightBind);
		keybinds.set("SpaceBind", FlxG.save.data.dodgeBind);
	}

	public function getSettingBool(variable:String):Bool
	{
		if (boolSettings.exists(variable))
		{
			var daBool:Bool = boolSettings.get(variable);
			return daBool;
		}
		else
		{
			trace("Bool doesn't exist or is null");
		}

		return true;
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
}