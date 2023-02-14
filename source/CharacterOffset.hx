package;

import flixel.FlxG;
import Character;
import helpers.*;

using StringTools;

class CharacterOffset extends MusicBeatState
{
	var characterFiles:Array<String> = [];
	var loadedChars:Map<String, Character> = new Map<String, Character>();
	var charData:Array<CharData> = [];
	var animList:Array<String> = [];
	var listLength:Int = 0;
	var dadChar:Character;
	var playerChar:Character;
	var camHUD:FlxCamera;
	var camCHARACTERS:FlxCamera;
	var curAnim:Int = 0;

	override function create() {
		super.create();

		camCHARACTERS = new FlxCamera;
		camCHARACTERS.bg.alpha = 0;
		camHUD = new FlxCamera();
		camHUG.bg.alpha = 0;
		FlxG.cameras.reset(camCHARACTERS);
		FlxG.cameras.add(camHUD);

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'shared'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		bg.cameras = [camCHARACTERS];
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'shared'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = FlxG.save.data.antialiasing;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains', 'shared'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = FlxG.save.data.antialiasing;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;
		add(stageCurtains);

		dadChar = new Character(0, 0, 'dad');
		add(dadChar);

		if (PlayState.SONG.player1 != null)
			playerChar = new Character(0, 0, PlayState.SONG.player1);
		else
			playerChar = new Character(0, 0, 'bf');
		add(playerChar);

		animList = playerChar.animation.getNameList();
		charData = playerChar.data;

		loadedChars.set(playerChar.curCharacter, playerChar);
		
		uiOffset = new FlxText(0, FlxG.height / 4, "X Offset: " + animArray[curAnim].offset[0] + '\nY Offset: ' + animArray[curAnim].offset[1], 45);
		add(uiOffset);

		uiPosOffset = new FlxText(0, FlxG.height / 8, "X Position Offset: " + animArray[curAnim].positionOffset[0] + '\nY Position Offset: ' + animArray[curAnim].positionOffset[1], 45);
		add(uiPosOffset);

		uiOffset.cameras = [camHUD];
		uiPosOffset.cameras = [camHUD];
	}

	public function changeAnim() {
		uiOffset.text = "X Offset: " + animArray[curAnim].offset[0] + '\nY Offset: ' + animArray[curAnim].offset[1];
		uiPosOffset.text = "X Position Offset: " + animArray[curAnim].positionOffset[0] + '\nY Position Offset: ' + animArray[curAnim].positionOffset[1];

		playerChar.playAnim(animData[i].prefix);
	}

	public function editPos(dir:Int = 0) {
		switch (dir) {
			case 0:
				posEditor = 'offset':
			case 1:
				posEditor = 'position':
		}
	}

	public function movePos(dir:String = 'Left') {
		switch (posEditor) {
			case 'offset':
				switch (dir) {
					default:
				}
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.LEFT) {
			curAnim--;
			changeAnim();
		}

		if (FlxG.keys.justPressed.RIGHT) {
			curAnim++;
			changeAnim();
		}

		if (FlxG.keys.justPressed.D) {
			editPos();
		}

		if (FlxG.keys.justPressed.A) {
			editPos(1);
		}

		if (FlxG.keys.justPressed.I)
	}
}