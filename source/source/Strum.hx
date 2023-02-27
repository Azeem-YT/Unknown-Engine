package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.graphics.FlxGraphic;
import shaderlmfao.ColorSwap;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class StaticArrow extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var noteData:Int = 0;

	public var initX:Float;
	public var initY:Float;

	public var originAngle:Float;
	public var colorSwap:ColorSwap;
	public var alphaTo:Float = 0.9;
	public var arrowDirs:Array<String> = ['left', 'down', 'up', 'right'];
	public var isPlayer:Bool = false;
	public var daPixelZoom:Float = 6;
	public var style:String = 'normal';

	public function new(x:Float, y:Float, noteData:Int = 0)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();

		this.noteData = noteData;

		updateHitbox();
		scrollFactor.set();

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		colorSwap.update(Note.arrowColors[noteData]);
	}

	public function playAnim(animName:String, ?forced:Bool = false)
	{
		animation.play(animName, forced);
		updateHitbox();

		switch (animName){
			case 'confirm':
				centerOffsets();
			if (style != 'pixel') {
				offset.x += 25;
				offset.y += 25;
			}
			default:
				centerOffsets();
		}
	}

	override public function update(elapsed:Float){
		super.update(elapsed);

		if (!isPlayer && animation.curAnim != null && animation.curAnim.finished && animation.curAnim.name != 'static')
			playAnim('static', true);
	}

	public function addArrowAnim(noteData:Int = 0) {
		switch (noteData) {
			case 0:
				animation.addByPrefix('static', 'arrow static instance 1');
				animation.addByPrefix('pressed', 'left press instance 1', 24, false);
				animation.addByPrefix('confirm', 'left confirm instance 1', 24, false);
			case 1:
				animation.addByPrefix('static', 'arrow static instance 2');
				animation.addByPrefix('pressed', 'down press instance 1', 24, false);
				animation.addByPrefix('confirm', 'down confirm instance 1', 24, false);
			case 2:
				animation.addByPrefix('static', 'arrow static instance 4');
				animation.addByPrefix('pressed', 'up press instance 1', 24, false);
				animation.addByPrefix('confirm', 'up confirm instance 1', 24, false);
			case 3:
				animation.addByPrefix('static', 'arrow static instance 3');
				animation.addByPrefix('pressed', 'right press instance 1', 24, false);
				animation.addByPrefix('confirm', 'right confirm instance 1', 24, false);
			default:
				animation.addByPrefix('static', arrowDirs[noteData] + ' static instance ' + noteData);
				animation.addByPrefix('pressed', arrowDirs[noteData] + ' press instance 1');
				animation.addByPrefix('static', arrowDirs[noteData] + ' confirm instance 1');
		}

		setGraphicSize(Std.int(width * 0.7));
		antialiasing = PlayerPrefs.antialiasing;
		updateHitbox();
		scrollFactor.set();
	}

	public function addArrowAnimPixel(noteData:Int = 0) 
	{
		switch (noteData)
		{
			case 0:
				animation.add('static', [0]);
				animation.add('pressed', [4, 8], 12, false);
				animation.add('confirm', [12, 16], 24, false);
			case 1:
				animation.add('static', [1]);
				animation.add('pressed', [5, 9], 12, false);
				animation.add('confirm', [13, 17], 24, false);
			case 2:
				animation.add('static', [2]);
				animation.add('pressed', [6, 10], 12, false);
				animation.add('confirm', [14, 18], 12, false);
			case 3:
				animation.add('static', [3]);
				animation.add('pressed', [7, 11], 12, false);
				animation.add('confirm', [15, 19], 24, false);
			default:
				animation.add('static', [2]);
				animation.add('pressed', [6, 10], 12, false);
				animation.add('confirm', [14, 18], 12, false);
				trace('noteData is over 4 or under 0');
		}
		setGraphicSize(Std.int(width * daPixelZoom));
		updateHitbox();
		antialiasing = false;
		scrollFactor.set();

		style = 'pixel';
	}

	public function getFrames(noteSkin:String = ''){
		#if desktop
		frames = Paths.getModSparrowAtlas(noteSkin);
		if (frames == null)
		#end
			frames = Paths.getSparrowAtlas(noteSkin);

		if (frames == null)
			frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');

		alpha = 1;
		visible = true;
	}
	
	public function getFramesPixel(noteSkin:String = ''){
		var graphic:FlxGraphic = null;

		graphic = FlxGraphic.fromGraphic(Paths.image(noteSkin));

		if (graphic == null)
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
		else
			loadGraphic(graphic, true, 17, 17);

		style = 'pixel';

		alpha = 1;
		visible = true;
	}

	public function addOffset(animName:String, x:Float = 0, y:Float = 0){
		animOffsets[animName] = [x, y];
	}
}

class Strum extends FlxTypedGroup<FlxBasic>
{	
	public var strums:FlxTypedGroup<StaticArrow>;
	public var strumCharacter:Character;
	public var playstateInstance:PlayState;
	public var numbOfArrows:Int = 0;
	public var playerNumb:Int = 2;
	public var downScroll:Bool = false;
	public var strumID:Int = 0;
	public var singDirs:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public var autoPlay:Bool = true;
	public var texture:String = 'NOTE_assets';
	public var style:String = 'normal';

	public function new(x:Float, instance:PlayState, ?noteSkin:String = 'noteSkins/NOTE_assets', ?strumChar:Character, ?downscroll:Bool = false, strumID:Int = 0)
	{
		super();

		strums = new FlxTypedGroup<StaticArrow>();
		playerNumb = instance.numbOfStrums;
		playstateInstance = instance;
		if (instance != null)
			playerNumb = instance.numbOfStrums;
		strumCharacter = strumChar;
		this.strumID = strumID;
		downScroll = downscroll;

		if (strumCharacter == null) {
			switch (strumID) {
				case 0:
					strumCharacter = PlayState.dad;
				case 1:
					strumCharacter = PlayState.boyfriend;
				case 2:
					strumCharacter = PlayState.gf;
			}
		}

		add(strums);

		switch (noteSkin) {
			case 'pixel':
				for (i in 0...4)
					addArrowPixel(i, 'weeb/pixelUI/arrows-pixels');
			default:
				for (i in 0...4)
					addArrow(i, noteSkin);
		}
	}

	public function onBeat(curBeat:Int) { //Hehe

		if (strumCharacter != null) {
			if (autoPlay && strumCharacter.isPlayer)
				strumCharacter.isPlayer = false;

			var charIdle:Int = strumCharacter.idleOnBeat;

			if (charIdle == 0)
				charIdle = 1;

			if (strumCharacter.danceIdle) {
				if (!strumCharacter.animation.curAnim.name.startsWith("sing") && curBeat % charIdle == 0)
					strumCharacter.dance();
			}
			else
				if (strumCharacter.animation.curAnim.name == strumCharacter.idleDance &&
					curBeat % charIdle == 0)
					strumCharacter.dance();
		}
	}

	public function addArrowPixel(noteData:Int, ?noteSkin:String = 'noteSkins/NOTE_assets') {
		var arrowValue:Int = playerNumb - 1;
		var arrowY:Float = 50;

		if (downScroll)
			arrowY = FlxG.height - 150;

		var staticArrow:StaticArrow = new StaticArrow(0, arrowY, noteData);
		staticArrow.getFramesPixel(noteSkin);
		staticArrow.addArrowAnimPixel(noteData);
		staticArrow.ID = noteData;
		staticArrow.x += Note.swagWidth * noteData * (2 / (arrowValue * 2));
		strums.add(staticArrow);
		staticArrow.isPlayer = (strumID == playstateInstance.playerLane);
		staticArrow.originAngle = 0;
		staticArrow.alphaTo = 1;
		staticArrow.playAnim('static');

		switch (playerNumb) {
			case 3:
				staticArrow.x += 50;
				if (strumID > 0)
					staticArrow.x += 400 * strumID;
				staticArrow.x += Note.swagWidth * (noteData / 3);
			case 4:
				staticArrow.x += 15;
				staticArrow.x += 310 * strumID;
				staticArrow.x += Note.swagWidth * (noteData / 3);
			case 2:
				switch (strumID) {
					case 1:
						staticArrow.x += FlxG.width / 1.75;
					default:
						staticArrow.x += 100;
				}
		}

		staticArrow.initX = staticArrow.x;
		staticArrow.initY = staticArrow.y;
		numbOfArrows++;
	}

	public function addArrow(noteData:Int, ?noteSkin:String = 'noteSkins/NOTE_assets', ?thirdPlayer:Bool = false){
		var arrowValue:Int = playerNumb - 1;
		var arrowY:Float = 50;

		if (downScroll)
			arrowY = FlxG.height - 150;

		var staticArrow:StaticArrow = new StaticArrow(0, arrowY, noteData);
		staticArrow.getFrames(noteSkin);
		staticArrow.ID = noteData;
		staticArrow.x += Note.swagWidth * noteData * (2 / (arrowValue * 2));
		staticArrow.addArrowAnim(noteData);
		strums.add(staticArrow);
		staticArrow.isPlayer = (strumID == playstateInstance.playerLane);
		staticArrow.originAngle = 0;
		staticArrow.alphaTo = 1;
		staticArrow.playAnim('static');

		switch (playerNumb) {
			case 3:
				staticArrow.x += 50;
				if (strumID > 0)
					staticArrow.x += 400 * strumID;
				staticArrow.x += Note.swagWidth * (noteData / 3);
			case 4:
				staticArrow.x += 15;
				staticArrow.x += 310 * strumID;
				staticArrow.x += Note.swagWidth * (noteData / 3);
			case 2:
				switch (strumID) {
					case 1:
						staticArrow.x += FlxG.width / 1.75;
					default:
						staticArrow.x += 100;
				}
		}

		staticArrow.initX = staticArrow.x;
		staticArrow.initY = staticArrow.y;
		numbOfArrows++;
	}

	public function getArrowByNumb(numb:Int = 0):StaticArrow {
		var returnArrow:StaticArrow = strums.members[0];

		if (strums.members[numb] != null)
			returnArrow = strums.members[numb];

		return returnArrow;
	}

	public function getArrowByString(arrowDir:String = 'left'):StaticArrow {
		var returnArrow:StaticArrow = strums.members[0];

		arrowDir = arrowDir.toLowerCase();

		switch (arrowDir){
			case 'left':
				returnArrow = strums.members[0];
			case 'down':
				returnArrow = strums.members[1];
			case 'up':
				returnArrow = strums.members[2];
			case 'right':
				returnArrow = strums.members[3];
		}

		return returnArrow;
	}

	public function playCharAnim(noteData:Int = 0, altAnim:Bool = false, canAnim:Bool = true, isOpponent:Bool = true, ?doGhost:Bool = false){
		if (strumCharacter != null && strumCharacter.canSing){
			if (canAnim) {
				if (altAnim){
					strumCharacter.playAnim(singDirs[noteData] + '-alt', true);
				}
				else
					strumCharacter.playAnim(singDirs[noteData], true);

				if (playstateInstance != null)
					if (playstateInstance.playerLane != strumID)
						strumCharacter.holdTimer = 0;
			}

			if (doGhost) 
				playstateInstance.doGhost(strumCharacter, singDirs[noteData], isOpponent);
		}
	}

	public function changeCharacter(char:Character) {
		strumCharacter.usedOnStrum = false;
		char.usedOnStrum = true;
		strumCharacter = char;
	}

}