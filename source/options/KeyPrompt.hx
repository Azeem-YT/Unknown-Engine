package options;

import options.AtlasText;
import options.MenuList;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;

using StringTools;

class KeyPrompt extends FlxSpriteGroup
{
	inline static var MARGIN = 100;
	public var fieldText:BoldText;
	public var bgSprite:FlxSprite;
	public var backAdded:Bool = false;
	
	public function new(text:String) {
		bgSprite = new FlxSprite();

		fieldText = new BoldText(text);
		fieldText.scrollFactor.set(0, 0);

		super();
	}

	public function createBg(width:Int, height:Int, color = 0xFF808080) {
		if (bgSprite == null)
			bgSprite = new FlxSprite();
		bgSprite.makeGraphic(width, height, color, false, "prompt-bg");
		bgSprite.screenCenter(XY);
		if (!backAdded) {
			add(bgSprite);
			backAdded = true;
		}
	}

	override function update(elapsed:Float) {
		
		if (!exists && visible) {
			visible = false;
		}

		super.update(elapsed);
	}

	public function createBgFromMargin(margin = MARGIN, color = 0xFF808080) {
		createBg(Std.int(FlxG.width - margin * 2), Std.int(FlxG.height - margin * 2), color);
	}

	public function setText(text:String) {
		fieldText.text = text;
		fieldText.screenCenter(X);
	}
}
