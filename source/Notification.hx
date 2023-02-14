package;

import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;
using flixel.util.FlxSpriteUtil;

using StringTools;

class Notification extends FlxSpriteGroup //wut
{
	var metadata:Array<String> = [];
	var textData:Array<FlxText> = [];
	var textWidth:Float = 0;
	public var posNumber:Int = 0;
	public var textBG:FlxSprite;
	public var timerCount:Float = 1;
	public var onFinish:Void -> Void;

	public function new(x:Float, y:Float, notifText:String = '') {
		super(x, y);
	
		var splitData:Array<String> = [];
		splitData = notifText.split('\n');

		for (i in 0...splitData.length) {
			var textAdd:FlxText = new FlxText(0, 0, 0, splitData[i], 24);
			textAdd.setFormat(Paths.font("arial.ttf"), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
			textAdd.y = textData[i - 1].y + (textData[i - 1].height * 1.5);
			textData.push(textAdd);
		}

		for (i in 0...textData.length) {
			textData[i].alpha = 0.7;
			textData[i].updateHitbox();
		}

		var maxWidth:Float = 0;

		for (i in 0...textData.length) {
			if (textData[i].fieldWidth > maxWidth)
				maxWidth = textData[i].fieldWidth;
		}	

		textWidth = maxWidth;

		var textHeight:Float = 0;

		for (i in 0...textData.length) {
			textHeight += textData[i].height;

			if (i == textData.length - 1)
				textHeight += textData[i].height;
		}
		
		textHeight += 15;
		 
		textBG = new FlxSprite(textData[0].x, textData[0].y).makeGraphic(Math.floor(textWidth + 24), Std.int(textHeight), FlxColor.BLACK);
		textBG.height = textBG.height - 15;
		textBG.alpha = 0.5;

		for (i in 0...textData.length) {
			if (i <= 0 && i > textData.length - 1)
				textData[i].text += '\n';
		}

		add(textBG);
		for (text in textData)
			add(text);

		x -= textWidth;
		alpha = 0.00001;
	}

	public function tweenText() {
		alpha = 1;
		FlxTween.tween(this, {x: x + textWidth}, 1, {ease: FlxEase.quintInOut, onComplete: function(twn:FlxTween){
			new FlxTimer().start(timerCount, function(tmr:FlxTimer){
				finishNotif();
			});
		}});
	}

	public function finishNotif() {
		FlxTween.tween(this, {x: x - textWidth}, 1, {ease: FlxEase.quintInOut, onComplete: function(twn:FlxTween){
			if (onFinish != null)
				onFinish();
			this.destroy();
		}});
	}
}
