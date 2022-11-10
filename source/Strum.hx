package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Strum extends FlxSprite
{
	public var characterToPlay:Array<Character> = [];
	public var singAnim:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
	public var noteData:Int;
	public var curX:Float;
	public var curY:Float;

	override public function new(x:Float, y:Float, noteData:Int, isPlayer:Bool = false)
	{
		curX = x;
		curY = y;
		this.noteData = noteData;

		super(x, y);
	}

	public function playAnim(animName:String, ?forced:Bool)
	{
		animation.play(animName, forced);
	}

	public function playCharAnim(?altAnim:Bool = false)
	{
		for (i in 0...characterToPlay.length)
		{
			if (altAnim)
				characterToPlay[i].playAnim(singAnim[noteData] + '-alt', true);
			else
				characterToPlay[i].playAnim(singAnim[noteData], true);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}