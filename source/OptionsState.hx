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
		catagorys = [
			'Exit' => exitMenu,
			'Mods' => modPref, //Not Done
			'Notes' => notePref, //Not Done
			'Game Controls' => openKeymenu,
			'preferences' => switchPref
		];

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
		if (curSubGroup != null)
			remove(curSubGroup);

		curSubGroup = returnMainGroup();
		add(curSubGroup);

		for (i in 0...curSubGroup.length)
		{
			curSubGroup.members[i].y = (70 * 1.5 * i) + 30 + 155 - (15 * i);
			curSubGroup.members[i].y -= 5 * curSubGroup.length - 1;
			curSubGroup.members[i].x -= 10;
		}

		curCategory = category;

		curSelection = 0;
		changeSelection();
	}

	private function changeSelection(selection:Int = 0)
	{
		disableInput = false;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelection += selection;

		if (curSelection < 0)
			curSelection = curSubGroup.length - 1;
		
		if (curSelection >= curSubGroup.length)
			curSelection = 0;

		for (i in 0...curSubGroup.length)
		{
			curSubGroup.members[i].alpha = 0.6;
			if (i == curSelection)
				curSubGroup.members[i].alpha = 1;

			curSubGroup.members[i].targetY = (i - curSelection) / 2;
		}

		curSelectedScript = catagorys.get(curSubGroup.members[curSelection].text);
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
				default:
					// dont do anything
					//im too lazy to do int and other stuff
			}
		}
	}

	private function returnMainGroup():FlxTypedGroup<Alphabet>
	{
		var newGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
		var curI:Int = 0;

		for (shit in catagorys.keys())
		{
			var newOption:Alphabet = new Alphabet(0, 0, shit, true, false);
			newOption.screenCenter();
			newOption.targetY = curI;
			newOption.alpha = 0.6;
			newGroup.add(newOption);

			curI++;
		}

		return newGroup;
	}

	override public function update(elapsed:Float)
	{
		if (!disableInput)
		{
			if (curSelectedScript != null && controls.ACCEPT)
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
		FlxG.sound.play(Paths.sound('confirmMenu'));
		disableInput = true;
		FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
		{
			loadCatagory(curSubGroup.members[curSelection].text);
			disableInput = false;
		});
	}

	public function openKeymenu()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		disableInput = true;
		FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
		{
			ClassShit.switchState(new KeyBindState());
			disableInput = false;
		});
		
	}

	public function exitMenu()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		disableInput = true;
		FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
		{
			ClassShit.switchState(new MainMenuState());
			disableInput = false;
		});
	}

	public function switchPref()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		disableInput = true;
		FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
		{
			ClassShit.switchState(new OptionPrefs());
			disableInput = false;
		});
	}
	
	public function modPref()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		disableInput = true;
		FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
		{
			ClassShit.switchState(new ModPrefs());
			disableInput = false;
		});
	}
	
	public function notePref()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		disableInput = true;
		FlxFlicker.flicker(curSubGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
		{
			ClassShit.switchState(new NotePrefs());
			disableInput = false;
		});
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
		changeKeyPrompt.add(prompt);

		promptText = new Alphabet(0, prompt.y + prompt.height, "Press any key to rebind", true, false);
		promptText.screenCenter();
		promptText.y = prompt.y + prompt.height;
		changeKeyPrompt.add(promptText);
		
		bottomPromptText = new Alphabet(0, 0, "Press ESC to exit", true, false);
		bottomPromptText.screenCenter();
		bottomPromptText.y = prompt.y - prompt.height;
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

			var keyText:Alphabet = new Alphabet(0, 0, (i > 3 ? uiKeyDir[i] : keyDir[i]) + ' ' + keyArray[i], true, false);
			keyText.screenCenter();
			keyText.targetY = i;
			keyText.isMenuItem = true;
			keyText.alpha = 0.6;

			keyOptions.add(keyText);
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
		
		if (curSelection >= keyOptions.length)
			curSelection = 0;
			
		for (i in 0...keyOptions.length)
		{
			keyOptions.members[i].alpha = 0.6;
			keyOptions.members[i].targetY = i - curSelection;
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
			PlayerController.playerControl.setKeyboardScheme(None, false);

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
	public static var instance:OptionPrefs;
	var alphaOptions:FlxTypedGroup<OptionPref>;
	var options:Array<String> = [];
	var optionsVars:Array<Bool> = [];
	var curSelected:Int = 0;
	var curOption:String = "";
	var canMove:Bool = true;
	
	override function create()
	{
		instance = this;
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

		canMove = true;
	}

	public function getOptions()
	{
		for (option in Main.gameSettings.gameSettingInfo.keys())
		{
			options.push(Main.gameSettings.gameSettingInfo.get(option)[0]);
			optionsVars.push(Main.gameSettings.gameSettingInfo.get(option)[1]);
		}
	}

	private function generateOptions():FlxTypedGroup<OptionPref>
	{
		alphaOptions = new FlxTypedGroup<OptionPref>();

		var settingInfo:Array<Array<Dynamic>> = Main.gameSettings.settingsList;

		var shit:Int = 0;

		for (setting in settingInfo)
		{
			var isNumb:Bool = false;
			var isString:Bool = false;

			if (setting[2] == 'int' || setting[2] == 'float')
				isNumb = true;

			if (setting[2] == 'string')
				isString = true;

			var optionVariable:String = setting[1];

			var optionText:OptionPref = new OptionPref(
			0, 
			0, 
			optionVariable, 
			setting[0], 
			setting[2], 
			getValue(optionVariable), 
			'OptionPrefs', 
			shit,
			setting[3], 
			(isNumb ? setting[4] : 0),
			(isNumb ? setting[5] : 0), 
			(isNumb ? setting[6] : 10), 
			(isString ? setting[4] : null)); //Sorry for this lol

			optionText.alphaText.alpha = 0.6;
			alphaOptions.add(optionText);
			shit++;
		}

		alphaOptions.members[curSelected].alphaText.alpha = 1;

		add(alphaOptions);

		return alphaOptions;
	}

	function changeSelection(?change:Int = 0) //stolen from freeplay lmaoooo
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = alphaOptions.length - 1;
		if (curSelected >= alphaOptions.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in alphaOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alphaText.alpha = 0.6;

			if (item.targetY == 0)
				item.alphaText.alpha = 1;
		}
	}

	override function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP && canMove)
			changeSelection(-1);

		if (downP && canMove)
			changeSelection(1);

		if (controls.BACK && canMove)
			ClassShit.switchState(new OptionsState());


		switch (alphaOptions.members[curSelected].optionType)
		{
			case 'bool':
				updateCheckbox();
			case 'int' | 'float' | 'string':
				updateSelector();
		}

		super.update(elapsed);
	}

	private function updateSelector()
	{
		var thePref:OptionPref = alphaOptions.members[curSelected];

		if (controls.UI_LEFT_P){
			switch (thePref.variableName)
			{
				case 'fpsCap':
					thePref.onPressLeft(function(){
						PlayerPrefs.setFramerate();
					});
				default:
					thePref.onPressLeft();
			}
		}

		if (controls.UI_RIGHT_P) {
			switch (thePref.variableName)
			{
				case 'fpsCap':
					thePref.onPressRight(function(){
						PlayerPrefs.setFramerate();
					});
				default:
					thePref.onPressRight();
			}
		}
	}

	private function updateCheckbox()
	{
		var thePref:OptionPref = alphaOptions.members[curSelected];

		if (controls.ACCEPT){
			switch (thePref.variableName)
			{
				case 'fpsCounter':
					thePref.onPressEnter(function(isChecked:Bool){
						Main.setFPSVisible();
					});
				default:
					thePref.onPressEnter();
			}
		}
	}

	function getValue(variable):Dynamic
		return Reflect.getProperty(PlayerPrefs, variable);
}

class ModPrefs extends MusicBeatState
{
	public static var instance:ModPrefs;
	var alphaOptions:FlxTypedGroup<Alphabet>;
	var options:Array<String> = [];
	var optionsVars:Array<Bool> = [];
	var curSelected:Int = 0;
	var curOption:String = "";
	var canMove:Bool = true;
	
	override function create()
	{
		instance = this;
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

		canMove = true;
	}

	public function getOptions()
	{
		options.push("Not Done Yet");
		optionsVars.push(false);
	}

	private function generateOptions():FlxTypedGroup<Alphabet>
	{
		alphaOptions = new FlxTypedGroup<Alphabet>();

		getOptions();

		var shit:Int = 0;

		var alphabetText:Alphabet = new Alphabet(0, 0, 'Not Done Yet', true, false);
		alphabetText.isMenuItem = true;
		alphabetText.targetY = 0;
		alphaOptions.add(alphabetText);

		add(alphaOptions);

		return alphaOptions;
	}

	function changeSelection(?change:Int = 0) //stolen from freeplay lmaoooo
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = alphaOptions.length - 1;
		if (curSelected >= alphaOptions.length)
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

		if (upP && canMove)
		{
			changeSelection(-1);
		}
		if (downP && canMove)
		{
			changeSelection(1);
		}

		if (controls.BACK && canMove)
			ClassShit.switchState(new OptionsState());

		if (accepted && canMove)
		{
			canMove = false;

			FlxG.sound.play(Paths.sound('confirmMenu'));

			FlxFlicker.flicker(alphaOptions.members[curSelected], 0.5, 0.12, true, false, function(flicker:FlxFlicker)
			{
				//setVar();
				canMove = true;
			});
		}

		super.update(elapsed);
	}

	private function resetOptions()
	{	
		options = [];
		optionsVars = [];

		getOptions();
	}

	function setVar()
	{
		switch (curOption)
		{
			case 'Not Done Yet':
				trace('Not Done');
		}

		resetOptions();
		Main.gameSettings.resetSettings();
		trace('Chosen ' + curOption + ": " + optionsVars[curSelected]);
	}
}

class NotePrefs extends MusicBeatState
{
	public static var instance:NotePrefs;
	var alphaOptions:FlxTypedGroup<Alphabet>;
	var options:Array<String> = [];
	var optionsVars:Array<Bool> = [];
	var curSelected:Int = 0;
	var curOption:String = "";
	var canMove:Bool = true;
	
	override function create()
	{
		instance = this;
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

		canMove = true;
	}

	public function getOptions()
	{
		options.push("Not Done Yet");
		optionsVars.push(false);
	}

	private function generateOptions():FlxTypedGroup<Alphabet>
	{
		alphaOptions = new FlxTypedGroup<Alphabet>();

		getOptions();

		var shit:Int = 0;

		var alphabetText:Alphabet = new Alphabet(0, 0, 'Not Done Yet', true, false);
		alphabetText.isMenuItem = true;
		alphabetText.targetY = 0;
		alphaOptions.add(alphabetText);

		add(alphaOptions);

		return alphaOptions;
	}

	function changeSelection(?change:Int = 0) //stolen from freeplay lmaoooo
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = alphaOptions.length - 1;
		if (curSelected >= alphaOptions.length)
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

		if (upP && canMove)
		{
			changeSelection(-1);
		}
		if (downP && canMove)
		{
			changeSelection(1);
		}

		if (controls.BACK && canMove)
			ClassShit.switchState(new OptionsState());

		if (accepted && canMove)
		{
			canMove = false;

			FlxG.sound.play(Paths.sound('confirmMenu'));

			FlxFlicker.flicker(alphaOptions.members[curSelected], 0.5, 0.12, true, false, function(flicker:FlxFlicker)
			{
				//setVar();
				canMove = true;
			});
		}

		super.update(elapsed);
	}

	private function resetOptions()
	{	
		options = [];
		optionsVars = [];

		getOptions();
	}

	function setVar()
	{
		switch (curOption)
		{
			case 'Not Done Yet':
				trace('Not Done');
		}

		resetOptions();
		Main.gameSettings.resetSettings();
		trace('Chosen ' + curOption + ": " + optionsVars[curSelected]);
	}
}