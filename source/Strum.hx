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
	public var isPlayer:Bool = false;
	public var noteStyle:String = 'normal';
	public var modifiedY:Bool = false;

	override public function new(x:Float, y:Float, noteData:Int, isPlayer:Bool = false, ?noteStyle:String = 'normal')
	{
		curX = x;
		curY = y;
		this.noteData = noteData;
		this.isPlayer = isPlayer;
		this.noteStyle = noteStyle;

		super(x, y);
	}

	public function playAnim(animName:String, ?forced:Bool)
	{
		switch (animName)
		{
			case 'confirm':
				animation.play('confirm', forced);

				centerOffsets();
				offset.x -= 13;
				offset.y -= 13;
			default:
				animation.play(animName, forced);
				centerOffsets();
		}
	}

	public function playCharAnim(?altAnim:Bool = false)
	{
		for (i in 0...characterToPlay.length)
		{
			if (characterToPlay[i].canSing)
			{
				if (altAnim)
					characterToPlay[i].playAnim(singAnim[noteData] + '-alt', true);
				else
					characterToPlay[i].playAnim(singAnim[noteData], true);
			
				if (!characterToPlay[i].isPlayer)
					characterToPlay[i].holdTimer = 0;
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!isPlayer && animation.curAnim.name == 'confirm' && animation.curAnim.finished)
			playAnim("static", true);
	}
}