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
import options.OptionsState;
import optionHelpers.*;
import helpers.*;

using StringTools;

class BaseOptionsMenu extends MusicBeatSubstate
{
	public var alphaOptions:FlxTypedGroup<Alphabet>;
	public var settingOptions:Array<OptionPref>;
	public var options:Array<String> = [];
	public var optionsVars:Array<Bool> = [];
	public var curSelected:Int = 0;
	public var curOption:String = "";
	public var canMove:Bool = true;
	public var mainCamera:FlxCamera;
	public var camBG:FlxCamera;
	public var onExit:Void -> Void;
	
	override function create()
	{		
		mainCamera = new FlxCamera();
		FlxG.cameras.add(mainCamera);

		mainCamera.zoom = 0.85;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.3));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		generateOptions();

		canMove = true;
	}

	private function generateOptions()
	{
		alphaOptions = new FlxTypedGroup<Alphabet>();
		add(alphaOptions);

		var shit:Int = 0;

		for (i in 0...settingOptions.length) {
			var optionText:Alphabet = new Alphabet(0, 0, settingOptions[i].optionName, true);
			optionText.isMenuItem = true;
			optionText.optionItem = true;
			optionText.targetY = i;
			alphaOptions.add(optionText);

			switch (settingOptions[i].optionType)
			{
				case 'bool':
					add(settingOptions[i].checkmark.checkbox);
					settingOptions[i].checkmark.checkbox.cameras = [mainCamera];
					settingOptions[i].setCheckmark();
				case 'float' | 'int':
					add(settingOptions[i].selector.valueText);
				case 'string':
					add(settingOptions[i].stringSelector.selectorLeft);
					add(settingOptions[i].stringSelector.alphaOptions);
					add(settingOptions[i].stringSelector.selectorRight);
					settingOptions[i].stringSelector.selectorLeft.cameras = [mainCamera];
					settingOptions[i].stringSelector.alphaOptions.cameras = [mainCamera];
					settingOptions[i].stringSelector.selectorRight.cameras = [mainCamera];
			}
		}

		alphaOptions.members[curSelected].alpha = 1;
	}

	function changeSelection(?change:Int = 0) //stolen from freeplay lmaoooo
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = settingOptions.length - 1;
		if (curSelected >= settingOptions.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in alphaOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
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

		if (controls.BACK && canMove) {
			mainCamera.zoom = 1;

			if (onExit != null)
				onExit();
			
			close();
		}

		for (i in 0...settingOptions.length){
			var alphaText:Alphabet = alphaOptions.members[i];
			switch (settingOptions[i].optionType)
			{
				case 'bool':
					var checkmark:AlphaCheckbox = settingOptions[i].checkmark;
					checkmark.checkbox.x = alphaText.lastSprite.x + 50;
					checkmark.checkbox.y = alphaText.lastSprite.y - 50;

					if (checkmark.checkbox.animation.curAnim != null && checkmark.checkbox.animation.curAnim.finished)
					{
						switch (checkmark.checkbox.animation.curAnim.name)
						{
							case 'true':
								checkmark.playAnim('true-finished', true);
							case 'false':
								checkmark.playAnim('false-finished', true);
						}
					}

					checkmark.checkbox.x = alphaText.lastSprite.x + 50;
					checkmark.checkbox.y = alphaText.lastSprite.y - 50;

				case 'int' | 'float':
					var selector:AlphaSelector = settingOptions[i].selector;
					selector.valueText.y = alphaText.lastSprite.y;
					selector.valueText.x = alphaText.lastSprite.x + (alphaText.lastSprite.width * 2);
				case 'string':
					var stringSelector:StringSelector = settingOptions[i].stringSelector;
					stringSelector.alphaOptions.members[settingOptions[i].curSelected].x = alphaText.lastSprite.x + (alphaText.lastSprite.width * 4);
					stringSelector.alphaOptions.members[settingOptions[i].curSelected].y = alphaText.y - 50;

					if (stringSelector.selectorLeft != null)
						stringSelector.playAnim(stringSelector.selectorLeft, 'idle');

					if (stringSelector.selectorRight != null)
						stringSelector.playAnim(stringSelector.selectorRight, 'idle'); 

					stringSelector.selectorLeft.x = stringSelector.alphaOptions.members[settingOptions[i].curSelected].firstSprite.x - stringSelector.alphaOptions.members[settingOptions[i].curSelected].firstSprite.width - 10;
					stringSelector.selectorLeft.y = stringSelector.alphaOptions.members[settingOptions[i].curSelected].firstSprite.y - 10;

					stringSelector.selectorRight.x = stringSelector.alphaOptions.members[settingOptions[i].curSelected].lastSprite.x + stringSelector.alphaOptions.members[settingOptions[i].curSelected].lastSprite.width + 5;
					stringSelector.selectorRight.y = stringSelector.selectorLeft.y;
			}
		}


		switch (settingOptions[curSelected].optionType)
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
		var thePref:OptionPref = settingOptions[curSelected];

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
		var thePref:OptionPref = settingOptions[curSelected];

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

	private function pushOption(option:OptionPref) {
		if (settingOptions == null)
			settingOptions = [];

		settingOptions.push(option);
	}

	function getValue(variable):Dynamic
		return Reflect.getProperty(PlayerPrefs, variable);
}