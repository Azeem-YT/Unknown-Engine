package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class DownscrollSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"HEY! The preference option is broken in this build!\nIf you would like to turn on downscroll"
			+ "\nPress Y if not, Press N.",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (!leftState)
		{
			if (FlxG.keys.justPressed.Y)
			{
				leftState = true;
				FlxG.save.data.downscroll = true;
				Main.gameSettings.saveSettings();
				FlxG.switchState(new MainMenuState());
			}
			if (FlxG.keys.justPressed.N)
			{
				leftState = true;
				FlxG.save.data.downscroll = false;
				Main.gameSettings.saveSettings();
				FlxG.switchState(new MainMenuState());
			}
		}

		super.update(elapsed);
	}
}