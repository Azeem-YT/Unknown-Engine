package;

import flixel.FlxGame;
import flixel.FlxG;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import optionHelpers.GameSettings;
import openfl.events.UncaughtErrorEvent;
import sys.FileSystem;
import sys.io.File;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false;
	public static var gameSettings:GameSettings;
	public static var fpsCap:Float = 60;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, gameCrashed);

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	public static var framerateCounter:FPS;

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, 60, 60, skipSplash, startFullscreen));
		
		gameSettings = new GameSettings();

		trace("Starting...");
	}

	private override function __update(transformOnly:Bool, updateChildren:Bool)
	{
		super.__update(transformOnly, updateChildren); //If you wanna update something in Main.
	}

	public static function setFramerateCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = fpsCap;
	}

	public function getframerateCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getframerate():Float
	{
		return framerateCounter.currentFPS;
	}

	public static function getFPSCounter()
	{
		framerateCounter = new FPS(10, 3, 0xFFFFFF);
		Lib.current.addChild(framerateCounter);
		trace("Adding FPS Counter...");
	}

	public static function setFPSVisible()
	{
		if (framerateCounter != null)
			framerateCounter.visible = PlayerPrefs.fpsCounter;
	}

	public function gameCrashed(errorMsg:UncaughtErrorEvent)
	{
		var error:String = "";
		var crashPath:String;
		var stack:Array<StackItem> = CallStack.exceptionStack(true);
		var curDate:String = Date.now().toString();

		curDate = StringTools.replace(curDate, " ", "_");
		curDate = StringTools.replace(curDate, ":", "'");

		crashPath = "crashs/UE_Crash" + curDate + ".txt";

		if (!FileSystem.exists("crashs/"))
			FileSystem.createDirectory("crashs/");

		for (crashStack in stack)
		{
			switch (crashStack)
			{
				case FilePos(s, file, line, column):
					error += file + " (line " + line + ")\n";
				default:
					Sys.println(crashStack);
			}
		}

		File.saveContent(crashPath, error + "\n");
	}
}
