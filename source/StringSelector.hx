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
import options.OptionsState;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end

class StringSelector extends FlxObject
{
	public var alphaParent:Alphabet;
	public var alphaText:String = "";
	public var alphaOptions:FlxTypedGroup<Alphabet>;
	public var settingOptions:Array<String> = [];
	public var selectorRight:FlxSprite;
	public var selectorLeft:FlxSprite;
	var selected:Int = 0;

	public function new(x:Float, y:Float, curValue:String, defaultValue:String, className:String = 'OptionPrefs', settingOptions:Array<String>)
	{
		if (curValue != '' && curValue != null)
			alphaText = curValue;
		else
			alphaText = defaultValue;

		alphaOptions = new FlxTypedGroup<Alphabet>();
		this.settingOptions = settingOptions;

		for (i in 0...settingOptions.length)
		{
			var alphabetText = new Alphabet(0, 0, settingOptions[i], false, false);
			alphabetText.alpha = 0;
			alphaOptions.add(alphabetText);
		}

		selectorLeft = new FlxSprite(0, 0);
		selectorLeft.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		selectorLeft.animation.addByPrefix('idle', "arrow left");
		selectorLeft.animation.addByPrefix('press', "arrow push left");
		selectorLeft.animation.play('idle');

		selectorRight = new FlxSprite(0, 0);
		selectorRight.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		selectorRight.animation.addByPrefix('idle', "arrow right");
		selectorRight.animation.addByPrefix('press', "arrow push right");
		selectorRight.animation.play('idle');

		visible = false;
		super(x, y);
	}

	public function setText(selected:Int = 0){
		this.selected = selected;
		for (i in 0...alphaOptions.length)
			alphaOptions.members[i].alpha = 0;

		alphaOptions.members[this.selected].alpha = 1;
	}

	public function playAnim(sprite:FlxSprite, anim:String, forced:Bool = false){
		if (sprite != null) {
			sprite.animation.play(anim, forced);
		}
	}

	public function onLeft() {
		playAnim(selectorLeft, 'press', true);
	}

	public function onRight() {
		playAnim(selectorRight, 'press', true);
	}
}
