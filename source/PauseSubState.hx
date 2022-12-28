package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Practice Mode', 'Exit to menu'];
	var curMenu:String;
	var curSelected:Int = 0;
	var curDiffSelected:Int = 0;
	var practiceText:FlxText;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		if (PlayState.diffArray.length > 1) //Only add Change Diff if more than one diff
			menuItems = ['Resume', 'Restart Song', 'Practice Mode', 'Change Difficulty', 'Exit to menu'];

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += PlayState.diffArray[PlayState.storyDifficulty].toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		practiceText = new FlxText(20, levelDifficulty.y + 32, 0, "", 32);
		practiceText.text += "PRACTICE MODE";
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		add(practiceText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		practiceText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		practiceText.x = FlxG.width - (practiceText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(practiceText, {y: practiceText.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.8});
		if (PlayState.usingPractice)
			FlxTween.tween(practiceText, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.8});

		createMenu();

		cameras = [PlayState.instance.camHUD]; //A
	}

	function createMenu()
	{
		if (grpMenuShit != null)
			remove(grpMenuShit);

		curSelected = 0;

		switch (curMenu)
		{
			case 'diffMenu':
				grpMenuShit = new FlxTypedGroup<Alphabet>();
				add(grpMenuShit);

				for (i in 0...PlayState.diffArray.length)
				{
					var diff:String = StringTools.replace(PlayState.diffArray[i], '-', "");
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, diff, true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();
			default:
				grpMenuShit = new FlxTypedGroup<Alphabet>();
				add(grpMenuShit);

				for (i in 0...menuItems.length)
				{
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();
		}
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			var curSelectedDiff:String = '-' + PlayState.diffArray[curDiffSelected];

			switch (curMenu)
			{
				case 'diffMenu':
					PlayState.storyWeek = curDiffSelected;
					var song:String = Highscore.formatSong(PlayState.SONG.song.toLowerCase(), curSelectedDiff);
					PlayState.SONG = Song.loadFromJson(song, PlayState.SONG.song.toLowerCase());
					PlayState.instance.destroyModules();
					FlxG.resetState();
				default:
					switch (daSelected)
					{
						case "Resume":
							close();
						case "Restart Song":
							PlayState.instance.destroyModules();
							FlxG.resetState();
						case "Practice Mode":
							PlayState.usingPractice = !PlayState.usingPractice;
							if (practiceText.alpha == 1)
								practiceText.alpha = 0;
							else
								practiceText.alpha = 1;
						case 'Change Difficulty':
							curMenu = 'diffMenu';
							createMenu();
						case "Exit to menu":
							FlxG.switchState(new MainMenuState());
					}
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		if (curMenu == 'diffMenu')
			curDiffSelected += change;
		else
			curSelected += change;

		if (curMenu == 'diffMenu')
		{
			if (curDiffSelected < 0)
				curDiffSelected = PlayState.diffArray.length - 1;
			if (curDiffSelected >= PlayState.diffArray.length)
				curDiffSelected = 0;
		}
		else
		{
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
			if (curSelected >= menuItems.length)
				curSelected = 0;
		}

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			if (curMenu == 'diffMenu')
				item.targetY = bullShit - curDiffSelected;
			else
				item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
