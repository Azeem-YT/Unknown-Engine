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
#if desktop
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class SongInfo extends FlxSpriteGroup
{
	var metadata:Array<String> = [];
	var textData:Array<FlxText> = [];
	var textWidth:Float = 0;
	var timerCount:Float = 1;

	public function new(x:Float, y:Float, song:String) {
		super(x, y);

		var pulledData:String = '';

		#if desktop
		pulledData = File.getContent(Paths.txt('data/$song/songInfo'));		
		#else
		pulledData = Assets.getText(Paths.txt(getSongPath(song) + 'songInfo'));
		#end
	
		var splitData:Array<String> = [];
		splitData = pulledData.split('\n');
		var lines:Int = splitData.length - 1;

		var songName:FlxText = new FlxText(0, 0, 0, 'Song Name: ' + splitData[0], 24);
		songName.setFormat(Paths.font("arial.ttf"), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		textData.push(songName);

		var composer:FlxText = new FlxText(0, 0, 0, 'Composed by: ' + splitData[1], 24);
		composer.setFormat(Paths.font("arial.ttf"), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		composer.y = songName.y + (songName.height * 1.5);
		textData.push(composer);

		for (i in 0...splitData.length) {
			var skipList:Array<Int> = [0, 1];
			if (!skipList.contains(i)) {
				var extraText:FlxText = new FlxText(0, 0, 0, splitData[i], 24);
				extraText.setFormat(Paths.font("arial.ttf"), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
				extraText.y = textData[i - 1].y + (textData[i - 1].height * 1.5);
				textData.push(extraText);
			}
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
		 
		var textBG:FlxSprite = new FlxSprite(textData[0].x, textData[0].y).makeGraphic(Math.floor(textWidth + 24), Std.int(textHeight), FlxColor.BLACK);
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
				tweenBack();
			});
		}});
	}

	public function tweenBack() {
		FlxTween.tween(this, {x: x - textWidth}, 1, {ease: FlxEase.quintInOut, onComplete: function(twn:FlxTween){
			this.destroy();
		}});
	}
}
