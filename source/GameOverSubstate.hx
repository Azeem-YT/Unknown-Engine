package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end

class GameOverSubstate extends MusicBeatSubstate
{
	public var bf:Boyfriend;
	public var camFollow:FlxObject;

	var stageSuffix:String = "";
	var deathSound:String;
	public static var moduleArray:Array<UnkownModule>;
	public static var instance:GameOverSubstate;

	public function new(x:Float, y:Float)
	{
		instance = this;

		var daStage = PlayState.curStage;
		var characterToUse:String = PlayState.boyfriend.deathCharacter;
		deathSound = PlayState.boyfriend.deathSound;
		var daBf:String = '';

		if (characterToUse != null)
		{
			switch (characterToUse)
			{
				case 'bf-pixel-dead':
					stageSuffix = '-pixel';
					daBf = 'bf-pixel-dead';
				default:
					daBf = characterToUse;
			}
		}
		else
		{
			switch (daStage)
			{
				case 'school':
					stageSuffix = '-pixel';
					daBf = 'bf-pixel-dead';
				case 'schoolEvil':
					stageSuffix = '-pixel';
					daBf = 'bf-pixel-dead';
				default:
					daBf = 'bf';
			}
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		if (deathSound == null)
			FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		else
			switch (deathSound)
			{
				case 'fnf_loss_sfx-pixel':
					FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
				default:
					#if desktop
					if (FileSystem.exists(Paths.modSounds(deathSound)))
						FlxG.sound.play(Paths.loadSound(deathSound));
					else
					#end
						FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
			}

		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		for (module in moduleArray)
		{
			if (module.isAlive && module.exists('onDeath'))
				module.get('onDeath')();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				ClassShit.switchState(new StoryMenuState());
			else
				ClassShit.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		for (module in moduleArray)
		{
			if (module.isAlive && module.exists('onDeath'))
				module.get('onDeath');
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			for (module in moduleArray)
			{
				if (module.isAlive && module.exists('onDeathConfirm'))
					module.get('onDeathConfirm')();
			}

			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
