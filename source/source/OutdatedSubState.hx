package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public var randomIntro:Array<String> = ["Woah!", "Sup dude, ", "Wow, ", "Oh, ", "Hey!"];

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			randomIntro[FlxG.random.int(0, randomIntro.length - 1)] 
			+ "looks like running an outdated version of the game!\nThe Current Version is "
			+ TitleState.currentVersion + '. Latest version is ' + TitleState.latestVersion
			+ ".\n Please update as the game! It might has some new stuff to share!\n"
			+ " Press Enter to go to github, or ESCAPE/BACK to ignore this!!",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT) {
			FlxG.openURL("https://github.com/Azeem-YT/Unknown-Engine");
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
