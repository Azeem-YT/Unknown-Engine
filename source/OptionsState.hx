package;

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

using StringTools;

enum SettingTypes
{
	Int;
	Checkmark;
	Bool;
	Float;
	String;
}

class OptionsState extends MusicBeatState
{	
	private var catagorys:Map<String, Dynamic>;
	private var curSubGroup:FlxTypedGroup<Alphabet>;
	var curSelectedScript:Void->Void;
	private var thingie:FlxTypedGroup<FlxBasic>;

	var infoTexts:FlxText;
	var disableInput:Bool = false;
	var curSelection:Int = 0;
	var curCategory:String;

	override public function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		catagorys = [
			'main'=> [
				[
					['preferences', switchPref],
					['controls', openKeymenu],
					['Exit', exitMenu]
				]
			],
			'preferences' => [
				[
					['Downscroll', getOptions],
					['Middlescroll', getOptions],
					['Ghost Tapping', getOptions],
					['FPS Counter', getOptions]
				]
			]
		];

		for (fuckShit in catagorys.keys())
		{
			catagorys.get(fuckShit)[1] = returnSubGroup(fuckShit);
			catagorys.get(fuckShit)[2] = returnOptionType(catagorys.get(fuckShit)[1]);
		}

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		infoTexts = new FlxText(5, FlxG.height - 24, 0, "", 32);
		infoTexts.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoTexts.textField.background = true;
		infoTexts.textField.backgroundColor = FlxColor.BLACK;
		add(infoTexts);

		loadCatagory('main');
	}

	private var alphabetMap:Map<Alphabet, Dynamic>;

	function loadCatagory(category:String)
	{
		if (infoTexts != null)
			remove(infoTexts);

		if (thingie != null)
			remove(thingie);

		if (curSubGroup != null)
			remove(curSubGroup);

		curSubGroup = catagorys.get(category)[1];
		add(curSubGroup);

		for (i in 0...curSubGroup.length)
		{
			curSubGroup.members[i].y = (70 * 1.5 * i) + 30 + 155;
			curSubGroup.members[i].x = curSubGroup.members[i].x - 10;
		}

		curCategory = category;

		alphabetMap = catagorys.get(category)[2];
		thingie = new FlxTypedGroup<FlxBasic>();
		for (idk in curSubGroup)
			if (alphabetMap.get(idk) != null)
				thingie.add(alphabetMap.get(idk));

		add(thingie);

		add(infoTexts);

		// reset the selection
		curSelection = 0;
		changeSelection();
	}

	private function changeSelection(selection:Int = 0)
	{
		disableInput = false;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelection += selection;

		// wrap the current selection
		if (curSelection < 0)
			curSelection = curSubGroup.length - 1;
		else if (curSelection >= curSubGroup.length)
			curSelection = 0;

		for (i in 0...curSubGroup.length)
		{
			curSubGroup.members[i].alpha = 0.6;
			if (alphabetMap != null)
				setAlpha(alphabetMap.get(curSubGroup.members[i]), 0.6);
			curSubGroup.members[i].targetY = (i - curSelection) / 2;
		}

		if (curSubGroup.members[curSelection] != null) curSubGroup.members[curSelection].alpha = 1;

		curSelectedScript = catagorys.get(curCategory)[0][curSelection][1];
	}

	private function setAlpha(sprite:FlxSprite, newValue:Float = 1)
	{
		if (sprite != null)
			sprite.alpha = newValue;
	}

	private function returnOptionType(alphaGroup:FlxTypedGroup<Alphabet>):Map<Alphabet, Dynamic>
	{
		var returnGroup:Map<Alphabet, Dynamic> = new Map<Alphabet, Dynamic>();

		for (shitInMyPants in alphaGroup)
		{
			if (Main.gameSettings.gameSettingInfo.get(shitInMyPants.text) != null)
			{
				switch (Main.gameSettings.gameSettingInfo.get(shitInMyPants.text)[1])
				{
					case GameSettings.SettingTypes.Checkmark:
						// checkmark
						var checkmark:CheckBox = new CheckBox(10, shitInMyPants.y);
						add(checkmark);
						checkmark.playAnim(Std.string(Main.gameSettings.boolSettings.get(shitInMyPants.text)) + '-finished');

						returnGroup.set(shitInMyPants, checkmark);
					default:
						// dont do anything
						//im too lazy to do int and other stuff
						trace("Fuck, Sumtin Wrong");
				}
			}
		}

		return returnGroup;
	}
	
	private function getOptions()
	{
		if (Main.gameSettings.gameSettingInfo.get(curSubGroup.members[curSelection].text) != null)
		{
			switch (Main.gameSettings.gameSettingInfo.get(curSubGroup.members[curSelection].text)[1])
			{
				case GameSettings.SettingTypes.Checkmark:
					if (controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));
						disableInput = true;
						FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
						{
							Main.gameSettings.boolSettings.set(curSubGroup.members[curSelection].text,
								!Main.gameSettings.boolSettings.get(curSubGroup.members[curSelection].text));
							playCheckmarkAnim(alphabetMap.get(curSubGroup.members[curSelection]),
								Main.gameSettings.boolSettings.get(curSubGroup.members[curSelection].text));

							// save the setting
							Main.gameSettings.saveSettings();
							trace("Setting Bool to: " + Main.gameSettings.boolSettings.get(curSubGroup.members[curSelection].text));
							disableInput = false;
						});
					}
				default:
					// dont do anything
					//im too lazy to do int and other stuff
			}
		}
	}

	private function returnSubGroup(groupName:String):FlxTypedGroup<Alphabet>
	{
		var newGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

		for (i in 0...catagorys.get(groupName)[0].length)
		{
			if (Main.gameSettings.gameSettingInfo.get(catagorys.get(groupName)[0][i][0]) == null)
			{
				var newOption:Alphabet = new Alphabet(0, 0, catagorys.get(groupName)[0][i][0], true, false);
				newOption.screenCenter();
				newOption.targetY = i;
				if (groupName != 'main')
					newOption.isMenuItem = true;
				newOption.alpha = 0.6;
				newGroup.add(newOption);
			}
		}

		return newGroup;
	}

	override public function update(elapsed:Float)
	{
		if (!disableInput)
		{
			if (curSelectedScript != null)
				curSelectedScript();

			updateControls();
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (curCategory != 'main')
				loadCatagory('main');
			else
				ClassShit.switchState(new MainMenuState());
		}

	}

	function updateControls()
	{
		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var accept = controls.ACCEPT;

		if (up_p)
			changeSelection(-1);
		if (down_p)
			changeSelection(1);
	}

	function playCheckmarkAnim(checkmark:CheckBox, anim:Bool)
	{
		if (checkmark != null)
			checkmark.playAnim(Std.string(anim));
	}

	public function changeGroup()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			disableInput = true;
			FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				loadCatagory(curSubGroup.members[curSelection].text);
			});
		}
	}

	public function openKeymenu()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			disableInput = true;
			FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				ClassShit.switchState(new KeyBindState());
				disableInput = false;
			});
		}
	}

	public function exitMenu()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			disableInput = true;
			FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				ClassShit.switchState(new MainMenuState());
				disableInput = false;
			});
		}
	}

	public function switchPref()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			disableInput = true;
			FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				ClassShit.switchState(new OptionPrefs());
				disableInput = false;
			});
		}
	}
}

class KeyBindState extends MusicBeatState
{
	private var curSelection:Int = 0;
	private var keyOptions:FlxTypedGroup<Alphabet>;
	private var keyDir:Array<String> = ["Left", "Down", "Up", "Right"];
	private var uiKeyDir:Array<String> = ["", "", "", "", "UI Left", "UI Down", "UI Up", "UI Right"];
	private var changeKeyPrompt:FlxTypedGroup<FlxBasic>;
	private var prompt:FlxSprite;
	private var promptText:Alphabet;
	private var bottomPromptText:Alphabet;
	private var subStateOpen:Bool = false;
	private var camBG:FlxCamera;

	override public function create()
	{
		super.create();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		camBG = new FlxCamera();
		FlxG.cameras.add(camBG);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		bg.cameras = [camBG];

		keyOptions = generateKeys();

		changeKeyPrompt = new FlxTypedGroup<FlxBasic>();

		prompt = new FlxSprite(0, 0).makeGraphic(FlxG.width - 200, FlxG.height - 200, FlxColor.fromRGB(250, 253, 109));
		prompt.screenCenter();

		promptText = new Alphabet(0, 0, "Press any key to rebind", true, false);
		promptText.screenCenter();
		promptText.y += 50;
		changeKeyPrompt.add(promptText);
		
		bottomPromptText = new Alphabet(0, 0, "Press ESC to exit", true, false);
		bottomPromptText.screenCenter();
		bottomPromptText.y -= 150;
		changeKeyPrompt.add(bottomPromptText);

		add(prompt);
		add(changeKeyPrompt);

		prompt.visible = false;
		changeKeyPrompt.visible = false;
	}

	private function generateKeys():FlxTypedGroup<Alphabet>
	{
		keyOptions = new FlxTypedGroup<Alphabet>();

		var keyArray:Array<String> = [];

		for (i in 0...Main.gameSettings.keybindArray.length)
		{
			keyArray.push(Main.gameSettings.keybindArray[i]);
		}

		for (i in 0...keyArray.length)
		{
			if (keyArray[i] == null)
				keyArray[i] = '';

			var keyText:Alphabet = new Alphabet(0, 0, keyArray[i] + ' - ' + (i > 3 ? uiKeyDir[i] : keyDir[i]), true, false);
			keyText.screenCenter();
			keyText.targetY = i;
			keyText.alpha = 0.6;

			keyOptions.add(keyText);
		}

		for (i in 0...keyOptions.length)
		{
			keyOptions.members[i].y = (70 * 1.1 * i) + 30 - 12.5;
			keyOptions.members[i].x = keyOptions.members[i].x - 10;
		}

		keyOptions.members[curSelection].alpha = 1;

		add(keyOptions);

		return keyOptions;
	}

	private function changeSelection(selection:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelection = curSelection + selection;

		if (curSelection < 0)
			curSelection = keyOptions.length - 1;
		else if (curSelection >= keyOptions.length)
			curSelection = 0;
			
		for (i in 0...keyOptions.length)
		{
			keyOptions.members[i].alpha = 0.6;
		}

		keyOptions.members[curSelection].alpha = 1;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!subStateOpen)
		{
			var up = controls.UI_UP;
			var down = controls.UI_DOWN;
			var up_p = controls.UI_UP_P;
			var down_p = controls.UI_DOWN_P;
			var accept = controls.ACCEPT;

			if (down_p)
				changeSelection(1);
			if (up_p)
				changeSelection(-1);

			if (controls.BACK)
				ClassShit.switchState(new OptionsState());

			if (accept)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				subStateOpen = true;

				FlxFlicker.flicker(keyOptions.members[curSelection], 0.5, 0.12, true, false, function(flicker:FlxFlicker)
				{
					if (subStateOpen)
						openKeyState();
				});
			}
		}
		else
			keyUpdate();
	}

	private function openKeyState()
	{
		prompt.visible = true;
		changeKeyPrompt.visible = true;
	}

	private function closeKeyState()
	{
		prompt.visible = false;
		changeKeyPrompt.visible = false;

		subStateOpen = false;
	}

	private function keyUpdate()
	{
		if (FlxG.keys.justPressed.ESCAPE)
			closeKeyState();
		else if (FlxG.keys.justPressed.ANY)
		{
			var tempKey:String = FlxG.keys.getIsDown()[0].ID;

			if (!Main.gameSettings.keyBlacklist.contains(tempKey) && !Main.gameSettings.keybindArray.contains(tempKey))
			{
				Main.gameSettings.keybindArray[curSelection] = tempKey;
				save();
			}

			if (curSelection > 3)
			{
				Main.gameSettings.keybindArray[curSelection] = tempKey;
				save();
			}

			controls.setKeyboardScheme(None, false);

			resetAlphabet();

			closeKeyState();
		}
	}

	private function resetAlphabet()
	{
		if (keyOptions != null)
		{
			remove(keyOptions);

			keyOptions = generateKeys();
		}
	}

	private function save()
	{
		FlxG.save.data.leftBind = Main.gameSettings.keybindArray[0];
		FlxG.save.data.downBind = Main.gameSettings.keybindArray[1];
		FlxG.save.data.upBind = Main.gameSettings.keybindArray[2];
		FlxG.save.data.rightBind = Main.gameSettings.keybindArray[3];
		FlxG.save.data.uiLeftBind = Main.gameSettings.keybindArray[4];
		FlxG.save.data.uiDownBind = Main.gameSettings.keybindArray[5];
		FlxG.save.data.uiUpBind = Main.gameSettings.keybindArray[6];
		FlxG.save.data.uiRightBind = Main.gameSettings.keybindArray[7];
	}
}

class OptionPrefs extends MusicBeatState
{
	var alphaOptions:FlxTypedGroup<Alphabet>;
	var options:Array<String> = [];
	var optionsVars:Array<Bool> = [];
	var curSelected:Int = 0;
	var curOption:String = "";
	
	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		alphaOptions = generateOptions();

		changeSelection();
	}

	private function generateOptions():FlxTypedGroup<Alphabet>
	{
		alphaOptions = new FlxTypedGroup<Alphabet>();

		for (option in Main.gameSettings.gameSettingInfo.keys())
		{
			options.push(Main.gameSettings.gameSettingInfo.get(option)[0]);
			optionsVars.push(Main.gameSettings.gameSettingInfo.get(option)[1]);
		}

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i] + ' ' + optionsVars[i], true, false);
			optionText.screenCenter();
			optionText.targetY = i;
			optionText.alpha = 0.6;

			alphaOptions.add(optionText);
		}

		for (i in 0...alphaOptions.length)
		{
			alphaOptions.members[i].y = (70 * 1.1 * i) + 30 - 12.5;
			alphaOptions.members[i].x = alphaOptions.members[i].x - 10;
		}

		alphaOptions.members[curSelected].alpha = 1;

		add(alphaOptions);

		return alphaOptions;
	}

	function changeSelection(?change:Int = 0) //stolen from freeplay lmaoooo
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		curOption = options[curSelected];

		var bullShit:Int = 0;

		for (item in alphaOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
				//Sex
			}
		}
	}

	override function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
				ClassShit.switchState(new OptionsState());

		if (accepted)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			FlxFlicker.flicker(alphaOptions.members[curSelected], 0.5, 0.12, true, false, function(flicker:FlxFlicker)
			{
				setVar();
			});
		}

		super.update(elapsed);
	}

	private function resetAlpha()
	{	
		options = [];
		optionsVars = [];
		if (alphaOptions != null)
		{
			remove(alphaOptions);

			alphaOptions = generateOptions();
		}
	}

	function setVar()
	{
		switch (curOption)
		{
			case 'Downscroll':
				FlxG.save.data.downscroll = !optionsVars[curSelected];
				trace("Chosen Downscroll");
			case 'Middlescroll':
				FlxG.save.data.middlescroll = !optionsVars[curSelected];
				trace("Chosen Middlescroll");
			case 'FPS Counter':
				FlxG.save.data.fpsCounter = !optionsVars[curSelected];
				Main.setFPSVisible();
				trace("Chosen Fps Counter");
			case 'Ghost Tapping':
				FlxG.save.data.ghostTapping = !optionsVars[curSelected];
				trace("Chosen Ghost Tapping");
			case 'Play Opponent Side':
				FlxG.save.data.opponentSide = !optionsVars[curSelected];
			case 'Show curState':
				FlxG.save.data.showState = !optionsVars[curSelected];
			case 'Game Auto Pause':
				FlxG.save.data.autoPauseG = !optionsVars[curSelected];
			case 'Botplay':
				FlxG.save.data.botplay = !optionsVars[curSelected];
			default:
				if (Main.gameSettings.boolSettings.exists(curOption))
					Main.gameSettings.boolSettings.set(curOption, !Main.gameSettings.getSettingBool(curOption));
				else
					Main.gameSettings.boolSettings.set(curOption, true);
		}

		Main.gameSettings.saveSettings();

		resetAlpha();
	}
}