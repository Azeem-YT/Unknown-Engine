package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var versionShit:FlxText;
	var gameVersion:String = "v" + Application.current.meta.get('version');
	var realFps:Float = FlxG.save.data.fpsR;
	var curOption:Int = 0;
	var optionName:String = "";
	var optionInfoS:String = ' | Press Left + Shift to decrease and Right + Shift to increase.';
	var optionInfo:Array<String> = [];
	var optionArray:Array<String> = ['FPS', 'Strum Offset'];

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		optionInfo = ['\nFPS Cap: ' + FlxG.save.data.fpsR + optionInfoS, '\nStrumline offset: ' + FlxG.save.data.strumOffset + optionInfoS];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		versionShit = new FlxText(5, FlxG.height - 36, 0, gameVersion + optionInfo[curOption], 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				ClassShit.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										ClassShit.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										ClassShit.switchState(new FreeplayState());

										trace("Freeplay Menu Selected");

									case 'options':
										FlxTransitionableState.skipNextTransIn = true;
										FlxTransitionableState.skipNextTransOut = true;
										ClassShit.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}

			var holdingShift:Bool = FlxG.keys.pressed.SHIFT;

			if (!holdingShift)
			{
				if (controls.UI_LEFT_P)
					changeOption(-1);
				if (controls.UI_RIGHT_P)
					changeOption(1);
			}

			switch (optionName)
			{
				case 'FPS':
					if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.LEFT)
						fpsDown(10);
					if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.RIGHT)
						fpsUp(10);
				case 'Strum Offset':
					if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.LEFT)
						FlxG.save.data.strumOffset -= 1;
					if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.strumOffset += 1;

					if (FlxG.save.data.strumOffset >= 150)
						FlxG.save.data.downscroll = true;
					else
						FlxG.save.data.downscroll = false;

					Main.gameSettings.saveSettings();

					updateText('\nStrumline offset: ' + FlxG.save.data.strumOffset + optionInfoS);
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}

	function changeOption(change:Int = 0)
	{
		curOption += change;

		if (curOption >= optionInfo.length)
			curOption = 0;
		if (curOption > 0)
			curOption = optionInfo.length - 1;

		optionName = optionArray[curOption];

		updateText(optionInfo[curOption]);
	}

	function fpsUp(value:Float = 10)
	{
		Main.fpsCap += value;

		FlxG.save.data.fpsR = Main.fpsCap;

		Main.setFramerateCap(Main.fpsCap);

		updateText('\nFPS Cap: ' + Main.fpsCap + optionInfoS);
	}
	
	function fpsDown(value:Float = 10)
	{
		Main.fpsCap -= value;

		FlxG.save.data.fpsR = Main.fpsCap;

		Main.setFramerateCap(Main.fpsCap);

		versionShit.text = '\nFPS Cap: ' + Main.fpsCap + optionInfoS;
	}

	function updateText(text:Dynamic)
	{
		versionShit.text = gameVersion + text;
	}
}
