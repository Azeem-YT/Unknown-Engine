package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.Lib;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import openfl.display3D.textures.VideoTexture;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.app.Application;
import helpers.*;
import openfl.utils.AssetType;
import UnkownModule.ModuleHandler;
import hxCodec.*;
import Stage;
import Note;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public static var moduleCharacters:Map<String, Character> = new Map<String, Character>();
	public static var gameObjects:Map<String, FlxBasic> = new Map<String, FlxBasic>();

	public static var boyfriendX:Float = 770;
	public static var boyfriendY:Float = 450;
	public static var gfX:Float = 400;
	public static var gfY:Float = 130;
	public static var dadX:Float = 100;
	public static var dadY:Float = 100;

	public static var bfChars:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public static var gfChars:Map<String, Character> = new Map<String, Character>();
	public static var dadChars:Map<String, Character> = new Map<String, Character>();

	public static var usingPractice:Bool = false;
	public static var usedPractice:Bool = false;

	public static var strumLineY:Float;

	var halloweenLevel:Bool = false;

	public var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public static var totalNotes:Int = 0;

	public static var strumLine:FlxSprite;
	public var curSection:Int = 0;

	public var camFollow:FlxObject;
	public var camPos:FlxPoint;

	public static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<Strum>;
	public static var playerStrums:FlxTypedGroup<Strum>;
	public static var opponentStrums:FlxTypedGroup<Strum>;
	public static var gfStrums:FlxTypedGroup<Strum>;
	public static var splashGroup:FlxTypedGroup<NoteSplash>;

	public var noteSplashOverride:String = null;
	public var splashOffsetX:Float = 10;
	public var splashOffsetY:Float = 10;
	public var splashFrames:Array<Array<Int>> = null;

	public var camZooming:Bool = false;
	public var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;
	public var sicks:Int;
	public var goods:Int;
	public var bads:Int;
	public var shits:Int;
	public var misses:Int;
	public var RatingString:String = '?';
	public static var usingBotPlay:Bool = false;

	public var middleScrollInt:Int = -250;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camUnderlay:FlxCamera;
	public var camOverlay:FlxCamera;
	public var camNotes:FlxCamera; //Too many cameras lol

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	//Week 2
	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	//Week 3
	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	//Week 4
	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	//Week 5
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	//Week 6
	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	//Week 7
	public var foregroundSprites:FlxTypedGroup<TankBGSprite>;
	var tankGround:TankBGSprite;
	var tankWatchtower:TankBGSprite;
	var smokeLeft:TankBGSprite;
	var smokeRight:TankBGSprite;
	var tankRuins:TankBGSprite;
	var tankBuildings:TankBGSprite;
	var tankMountains:TankBGSprite;
	var tankClouds:TankBGSprite;
	var tankSky:TankBGSprite;
	var tankRolling:TankBGSprite;
	public var tankmanRun:FlxTypedGroup<TankmenBG>;

	public static var weekName:String = "";

	var talking:Bool = true;
	public var songScore:Int = 0;
	public var scoreTxt:FlxText;
	public var scoreDivider:String = ' | ';

	public static var curElapsed:Float = 0;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var songHasScript:Bool;
	var stageHasScript:Bool;

	var songStarted:Bool;

	var noBG:Bool;
	public static var customAnims:Bool = false;

	public static var skipArrowTween:Bool = false;

	public static var dadNoteStyle:String;
	public static var bfNoteStyle:String;

	public static var updateScript:Array<UnkownModule> = [];
	public static var stageScripts:Array<UnkownModule> = [];
	public static var noteTypeScripts:Array<NoteModule> = [];

	public var songSpeed:Float = 1;
	public var curTime:Float = 0;

	public var timeText:FlxText;
	public var timeBG:FlxSprite;
	public var timeBar:FlxBar;
	public var timeLength:String = "0:00";

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var moduleHandler:ModuleHandler;

	public static var diffArray:Array<String> = ['easy', 'normal', 'hard'];

	public var diffText:String = '';

	public var libraryToUse:String = null;
	public var doCount:Bool = true;
	public var skipIntro:Bool = false;
	public static var arrowDirs:Array<String> = ['left', 'down', 'up', 'right'];
	#if desktop
	public static var songEvents:Array<Event> = [];
	#end

	override public function create()
	{
		instance = this;
		Paths.removeLoadedImages();
		usedPractice = false;
		doCount = true;
		skipIntro = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0; //reset score

		#if desktop
		songEvents = [];
		#end

		Ratings.resetAccuracy();

		moduleHandler = new ModuleHandler();
		moduleHandler.setVars();
		NoteModuleHandler.setVars();

		destroyModules();
		moduleCharacters.clear();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camUnderlay = new FlxCamera();
		camUnderlay.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camUnderlay);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOverlay);

		camHUD.alpha = PlayerPrefs.hudAlpha;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/thorns/thornsDialogue'));
		}

		diffText = '-' + diffArray[storyDifficulty];

		if (diffText == '-normal')
			diffText = '';

		#if desktop
		// Making difficulty text for Discord Rich Presence.

		storyDifficultyText = diffText;

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		noBG = FlxG.save.data.noBackground;

		curStage = SONG.stage;

		var usingStage:Bool = false;

		if (SONG.stage == null)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'tutorial' | 'bopeebo' | 'fresh' | 'dadbattle':
					curStage = 'stage';
					usingStage = true;
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
					usingStage = true;
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
					usingStage = true;
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
					usingStage = true;
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
					usingStage = true;
				case 'winter-horrorland':
					curStage = 'mallEvil';
					usingStage = true;
				case 'senpai' | 'roses':
					curStage = 'school';
					usingStage = true;
				case 'thorns':
					curStage = 'schoolEvil';
					usingStage = true;
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
					usingStage = true;
			}
		}

		var gfVersion:String = 'gf';

		if (SONG.gfVersion != null)
		{
			gfVersion = SONG.gfVersion;
		}
		else
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school':
					gfVersion = 'gf-pixel';
				case 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}

			switch (SONG.song.toLowerCase())
			{
				case 'ugh' | 'guns':
					gfVersion = 'gf-tankmen';
				case 'stress':
					gfVersion = "pico-speaker";
			}
		}

		var stageData:StageData = Stage.loadData(curStage);
		boyfriendX = stageData.boyfriendPos[0];
		boyfriendY = stageData.boyfriendPos[1];
		dadX = stageData.dadPos[0];
		dadY = stageData.dadPos[1];
		gfX = stageData.gfPos[0];
		gfY = stageData.gfPos[1];
		defaultCamZoom = stageData.camZoom;

		boyfriend = new Boyfriend(boyfriendX, boyfriendY, SONG.player1);
		if (boyfriend.frames == null){
			boyfriend = new Boyfriend(0, 0, 'bf');
			trace("Boyfriend character does not exists or has an error, sorry.");
		}

		gf = new Character(gfX, gfY, gfVersion);
		if (gf.frames == null){
			gf = new Character(0, 0, 'gf');
			trace("Gf character does not exists or has an error, sorry.");
		}
		gf.scrollFactor.set(0.95, 0.95);

		if (stageData.hidegf)
			gf.visible = false;

		dad = new Character(dadX, dadY, SONG.player2);
		if (dad.frames == null){
			dad = new Character(0, 0, 'dad');
			trace("Dad character does not exists or has an error, sorry.");
		}

		var moduleDir:String = Paths.getPreloadPath('modules/playstate/');
		var songModuleDir:String = Paths.getPreloadPath('modules/songs/' + SONG.song.toLowerCase());

		var directorys:Array<String> = [Paths.getPreloadPath()];

		#if desktop
		directorys.insert(0, Paths.mods());
		#end

		var stageFound:Bool = false;

		bfNoteStyle = SONG.notePlayerTexture;
		dadNoteStyle = SONG.noteOpponentTexture;

		if (!usingStage)
		{
			for (dir in 0...directorys.length)
			{
				moduleDir = directorys[dir] + 'stages/' + curStage + '/';
				var noteTypeDir:String = directorys[dir] + 'modules/noteTypes/';

				if (FileSystem.isDirectory(moduleDir))
				{
					for (file in FileSystem.readDirectory(moduleDir))
					{
						var path = haxe.io.Path.join([moduleDir, file]);
						if (file == curStage + '.hxs' && !stageFound)
						{
							var module = moduleHandler.loadModule(moduleDir + file);
							stageScripts.push(module);
							updateScript.push(module);
							stageFound = true;
							trace('Loading Module at ' + moduleDir + file);
						}
					}
				}
			}
		}

		switch (curStage)
		{
			case 'stage':
			{
				curStage = 'stage';

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'shared'));
				bg.antialiasing = FlxG.save.data.antialiasing;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
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
			}

			case 'spooky' | 'halloween':
			{
				curStage = 'spooky';
				halloweenLevel = true;

				libraryToUse = 'week2';

				var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = FlxG.save.data.antialiasing;
				add(halloweenBG);

				isHalloween = true;
			}
			case 'philly':
			{
				curStage = 'philly';

				libraryToUse = 'week3';

				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = FlxG.save.data.antialiasing;
					phillyCityLights.add(light);
				}

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
				add(streetBehind);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'shared'));
				FlxG.sound.list.add(trainSound);

				// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
				add(street);
			}
			case 'limo':
			{
				curStage = 'limo';
				defaultCamZoom = 0.90;

				libraryToUse = 'week4';

				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
				skyBG.scrollFactor.set(0.1, 0.1);
				skyBG.antialiasing = FlxG.save.data.antialiasing;
				add(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				bgLimo.antialiasing = FlxG.save.data.antialiasing;
				add(bgLimo);
				
				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...5)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
				}

				var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
				overlayShit.alpha = 0.5;
				// add(overlayShit);

				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

				// overlayShit.shader = shaderBullshit;

				var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = FlxG.save.data.antialiasing;

				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
				fastCar.antialiasing = FlxG.save.data.antialiasing;
				// add(limo);
			}
		case 'mall':
			{
				curStage = 'mall';

				defaultCamZoom = 0.80;

				libraryToUse = 'week5';

				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
				bg.antialiasing = FlxG.save.data.antialiasing;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = FlxG.save.data.antialiasing;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);

				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
				bgEscalator.antialiasing = FlxG.save.data.antialiasing;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);

				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
				tree.antialiasing = FlxG.save.data.antialiasing;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
				fgSnow.active = false;
				fgSnow.antialiasing = FlxG.save.data.antialiasing;
				add(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = FlxG.save.data.antialiasing;
				add(santa);
			}
		case 'mallEvil':
			{
				curStage = 'mallEvil';

				libraryToUse = 'week5';

				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
				bg.antialiasing = FlxG.save.data.antialiasing;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
				evilTree.antialiasing = FlxG.save.data.antialiasing;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
				evilSnow.antialiasing = FlxG.save.data.antialiasing;
				add(evilSnow);
			}
		case 'school':
			{
				curStage = 'school';

				// defaultCamZoom = 0.9;

				libraryToUse = 'week6';

				var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (SONG.song.toLowerCase() == 'roses')
				{
					bgGirls.getScared();
				}

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			}
		case 'schoolEvil':
			{
				curStage = 'schoolEvil';

				libraryToUse = 'week6';

				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

				var posX = 400;
				var posY = 200;

				var bg:FlxSprite = new FlxSprite(posX, posY);
				bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);
			}
		case 'tank':
			{	
				defaultCamZoom = 0.9;
				curStage = "tank";

				libraryToUse = 'week7';

				tankSky = new TankBGSprite("tankSky", -400, -400 , 0, 0);
				add(tankSky);

				tankClouds = new TankBGSprite("tankClouds", FlxG.random.int(-700,-100), FlxG.random.int(-20,20), 0.1, 0.1);
				tankClouds.active = true;
				tankClouds.velocity.x = FlxG.random.float(5, 15);
				add(tankClouds);

				tankMountains = new TankBGSprite("tankMountains",-300,-20, 0.2, 0.2);
				tankMountains.setGraphicSize(Std.int(1.2 * tankMountains.width));
				tankMountains.updateHitbox();
				add(tankMountains);

				tankBuildings = new TankBGSprite("tankBuildings", -200,0, 0.3, 0.3);
				tankBuildings.setGraphicSize(Std.int(1.1* tankBuildings.width));
				tankBuildings.updateHitbox();
				add(tankBuildings);

				tankRuins = new TankBGSprite("tankRuins", -200, 0, 0.35, 0.35);
				tankRuins.setGraphicSize(Std.int(1.1* tankRuins.width));
				tankRuins.updateHitbox();
				add(tankRuins);

				smokeLeft = new TankBGSprite("smokeLeft", -200, -100, 0.4, 0.4,["SmokeBlurLeft"], true);
				add(smokeLeft);

				smokeRight = new TankBGSprite("smokeRight", 1100, -100, 0.4, 0.4,["SmokeRight"],true);
				add(smokeRight);

				tankWatchtower = new TankBGSprite("tankWatchtower", 100, 50, 0.5, 0.5,["watchtower gradient color"]);
				add(tankWatchtower);

				tankRolling = new TankBGSprite("tankRolling", 300, 300, 0.5, 0.5,["BG tank w lighting"], true);
				add(tankRolling);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				tankGround = new TankBGSprite("tankGround", -420, -150);
				tankGround.setGraphicSize(Std.int(1.15* tankGround.width));
				tankGround.updateHitbox();
				add(tankGround);

				moveTank();

				foregroundSprites = new FlxTypedGroup<TankBGSprite>();

				var tank0 = new TankBGSprite("tank0", -500, 650, 1.7, 1.5, ["fg"]);
				foregroundSprites.add(tank0);

				var tank1 = new TankBGSprite("tank1",-300, 750, 2, 0.2, ["fg"]);
				foregroundSprites.add(tank1);

				var tank2 = new TankBGSprite("tank2", 450, 940, 1.5, 1.5, ["foreground"]);
				foregroundSprites.add(tank2);

				var tank3 = new TankBGSprite("tank4", 1300, 900, 1.5, 1.5, ["fg"]);
				foregroundSprites.add(tank3);

				var tank4 = new TankBGSprite("tank5", 1620, 700, 1.5, 1.5, ["fg"]);
				foregroundSprites.add(tank4);

				var tank5 = new TankBGSprite("tank3", 1300, 1200, 3.5, 2.5, ["fg"]);
				foregroundSprites.add(tank5);
			}
		}

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':
				dad.y += 250;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'tank':
				dad.x -= 100;
				switch (gf.curCharacter)
				{
					case 'pico-speaker':
						gf.y -= 150;
						gf.x -= 100;
					default:
						gf.x -= 200;
				}
		}

		add(gf);

		if (gf.curCharacter == "pico-speaker")
		{
			for (i in 0...TankmenBG.animationNotes.length)
			{
				if(FlxG.random.bool(16)) {
					var tankBih = tankmanRun.recycle(TankmenBG);
					tankBih.strumTime = TankmenBG.animationNotes[i][0];
					tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
					tankmanRun.add(tankBih);
				}
			}
		}

		// Shitty layering but whatev it works LOL

		switch (curStage)
		{
			case 'limo':
				add(limo);
		}

		add(dad);
		add(boyfriend);

		if (curStage == 'tank')
			add(foregroundSprites);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50 + FlxG.save.data.strumOffset).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		trace('Downscroll = ' + Main.gameSettings.getSettingBool("Downscroll"));
		usingBotPlay = Main.gameSettings.getSettingBool("Botplay");

		if (PlayerPrefs.downscroll && FlxG.save.data.strumOffset == 0)
			strumLine.y = FlxG.height - 150;

		if (FlxG.save.data.strumOffset >= 300)
			PlayerPrefs.downscroll = true;

		splashGroup = new FlxTypedGroup<NoteSplash>();

		strumLineNotes = new FlxTypedGroup<Strum>();
		add(strumLineNotes);
		add(splashGroup);

		var preloadSplash:NoteSplash = new NoteSplash(100, 100, 0);
		splashGroup.add(preloadSplash);
		preloadSplash.alpha = 0;

		playerStrums = new FlxTypedGroup<Strum>();

		opponentStrums = new FlxTypedGroup<Strum>();
		
		gfStrums = new FlxTypedGroup<Strum>();

		if (SONG.threePlayer)
		{
			generateGfStaticArrows();
			generateOpponentStaticArrows(true);
			generatePlayerStaticStaticArrows(true);
		}
		else
		{
			generateOpponentStaticArrows();
			generatePlayerStaticStaticArrows();
		}

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		var healthBarBGPath = Paths.image('healthBar');

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(healthBarBGPath);
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		if (PlayerPrefs.downscroll)
			healthBarBG.y = 50;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x, healthBarBG.y + 40, 0, "");
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 18);
		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		var watermarkLol:FlxText = new FlxText(0, 0, 0, 'UNKNOWN ENGINE BETA 3');
		watermarkLol.setFormat(Paths.font('vcr.ttf'), 18);
		watermarkLol.cameras = [camHUD];
		watermarkLol.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		add(watermarkLol);
		watermarkLol.setPosition(0, 700);
		watermarkLol.antialiasing = true;

		timeText = new FlxText(FlxG.width / 2  - 215, strumLine.y - (PlayerPrefs.downscroll ? -40 : 40), 400, "0:00/???", 60);
		timeText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeText.scrollFactor.set();
		timeText.alpha = 1;
		timeText.borderSize = 2;
		timeText.cameras = [camHUD];
		timeText.alpha = 0;

		//width / 4

		timeBG = new FlxSprite(0, timeText.y + 7).loadGraphic(healthBarBGPath);
		timeBG.screenCenter(X);
		timeBG.scrollFactor.set();
		timeBG.alpha = 0;
		timeBG.cameras = [camHUD];
		add(timeBG);
		timeText.x + 75;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true, boyfriend.healthIconIsAnimated, boyfriend.healthIconAnim, boyfriend.healthIconLooped, boyfriend.iconScale);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false, dad.healthIconIsAnimated, dad.healthIconAnim, dad.healthIconLooped, dad.iconScale);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		healthBar.alpha = PlayerPrefs.healthAlpha;
		healthBarBG.alpha = PlayerPrefs.healthAlpha;
		iconP1.alpha = PlayerPrefs.healthAlpha;
		iconP2.alpha = PlayerPrefs.healthAlpha;

		strumLineNotes.cameras = [camNotes];
		notes.cameras = [camNotes];
		splashGroup.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		for (dir in 0...directorys.length)
		{
			moduleDir = directorys[dir] + 'modules/playstate/';
			var songLowerCase:String = SONG.song.toLowerCase() + '/';
			songModuleDir = directorys[dir] + 'modules/songs/' + songLowerCase;
			var noteTypeDir = directorys[dir] + 'modules/noteTypes/';

			if (FileSystem.isDirectory(songModuleDir))
			{
				for (file in FileSystem.readDirectory(songModuleDir))
				{
					var path = haxe.io.Path.join([songModuleDir, file]);
					if (file.endsWith('.hxs'))
					{
						var module = moduleHandler.loadModule(songModuleDir + file);
						updateScript.push(module);
					}
				}
			}

			if (FileSystem.isDirectory(moduleDir))
			{
				for (file in FileSystem.readDirectory(moduleDir))
				{
					var path = haxe.io.Path.join([moduleDir, file]);
					if (sys.FileSystem.isDirectory(moduleDir) && file.endsWith('.hxs'))
					{
						var module = moduleHandler.loadModule(moduleDir + file);
						updateScript.push(module);
					}
				}
			}
			
			if (FileSystem.isDirectory(noteTypeDir))
			{
				for (file in FileSystem.readDirectory(noteTypeDir))
				{
					if (file.endsWith('.hxs'))
					{
						var module = NoteModuleHandler.loadModule(noteTypeDir + file);
						noteTypeScripts.push(module);
					}
				}
			}
		}
		
		for (module in updateScript){
			if (module.isAlive && module.exists('onCreatePost'))
				module.get('onCreatePost')();
		}


		if (isStoryMode && doCount)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'ugh':
					playCutscene('ughCutscene.mp4');
				case 'guns':
					playCutscene('gunsCutscene.mp4');
				case 'stress':
					playCutscene('stressCutscene.mp4');
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0)
	{
		if (!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankRolling.angle = (tankAngle - 90 + 15);
			tankRolling.x = (tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180)));
			tankRolling.y = (1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180)));
		}
	}

	function playCutscene(name:String, atEndOfSong:Bool = false)
	{
		inCutscene = true;
		FlxG.sound.music.stop();

		var video:VideoHandler = new VideoHandler();
		video.finishCallback = function()
		{
			if (atEndOfSong)
			{
				if (storyPlaylist.length <= 0)
					ClassShit.switchState(new StoryMenuState());
				else
				{
					SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase());
					ClassShit.switchState(new PlayState());
				}
			}
			else
				startCountdown();
		}
		video.playVideo(Paths.video(name));
		trace(Paths.video(name));
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		for (module in updateScript) {
			if (module.isAlive && module.exists('onStartCountdown')) {
				module.get('onStartCountdown')();
			}
		}

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		if (skipIntro)
		{
			swagCounter = 5;
			Conductor.songPosition = 0;
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(CoolUtil.spaceToDash(PlayState.SONG.song)), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end

		var seconds:Float = songLength / 1000;
		seconds = Math.round(seconds);

		timeLength = FlxStringUtil.formatTime(seconds, false);

		timeBar = new FlxBar(timeBG.x + 4, timeBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBG.width - 8), Std.int(timeBG.height - 8), Conductor,
			'songPosition', 0, Math.round(songLength));
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
		timeBar.alpha = 0;
		timeBar.cameras = [camHUD];
		add(timeBar);
		add(timeText);

		FlxTween.tween(timeBG, {alpha: 1}, 0.5);
		FlxTween.tween(timeBar, {alpha: 1}, 0.5);
		FlxTween.tween(timeText, {alpha: 1}, 0.5);

		switch (curStage)
		{
			case 'tank':
				foregroundSprites.forEach(function(spr:TankBGSprite)
				{
					spr.dance();
				});
		}

		for (module in updateScript)
		{
			if (module.isAlive && module.exists('onSongStart'))
				module.get('onSongStart')();
		}
	}

	var debugNum:Int = 0;

	public var realHitNote:Bool;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		songSpeed = songData.speed;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(CoolUtil.spaceToDash(PlayState.SONG.song)));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		//Song Events. 
		//Events are triggered through modules in mods folder, 
		//which is why it says desktop. 
		//You cannot add or remove events unless editing the json file.
		//I just put this here to run events if porting mods from Psych Engine :)

		#if desktop
		var songLowerCase:String = SONG.song.toLowerCase();
		if (FileSystem.exists(Paths.mods('data/$songLowerCase/events.json')))
		{
			var eventData:SwagSong = Song.loadFromJson('events', SONG.song.toLowerCase());
			for (event in eventData.events)
			{
				for (i in 0...event[1].length)
				{
					var event:Event = new Event(event[0], event[1][i][0], event[1][i][1], event[1][i][2]);
					songEvents.push(event);
				}
			}
		}
		#end

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var playerData = songNotes[1];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var isThirdPlayer:Bool = (playerData > 7 && playerData < 11 && songData.threePlayer);

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, (isThirdPlayer ? false : gottaHitNote), Std.string(songNotes[3]));
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				if (SONG.threePlayer)
				{
					swagNote.isThreePlayerNote = isThirdPlayer;
					if (swagNote.isThreePlayerNote)
					{
						swagNote.canBeHit = false;
						swagNote.mustPress = false;
					}

					if (!PlayerPrefs.middlescroll)
					{
						swagNote.scale.x = 0.6;
						swagNote.scale.y = 0.6;
					}
				}

				if (daNoteData > -1) {
					unspawnNotes.push(swagNote);
				}
				else
				{
					#if desktop
					var event:Event = new Event(daStrumTime, songNotes[2], songNotes[3], songNotes[4]);
					songEvents.push(event);
					#end
				}


				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, (isThirdPlayer ? false : gottaHitNote), songNotes[3]);
					sustainNote.scrollFactor.set();
					if (SONG.threePlayer)
					{
						sustainNote.isThreePlayerNote = isThirdPlayer;
						if (swagNote.isThreePlayerNote)
						{
							sustainNote.canBeHit = false;
							sustainNote.mustPress = false;
						}
						sustainNote.scale.x = 0.6;
						sustainNote.scale.y = 0.6;
					}
					if (daNoteData > -1)
					{
						unspawnNotes.push(sustainNote);
					}

					sustainNote.mustPress = (isThirdPlayer ? false : gottaHitNote);
				}

				swagNote.mustPress = (isThirdPlayer ? false : gottaHitNote);

				if (swagNote.isPlayer && !swagNote.isSustainNote)
					totalNotes++;
			}
			daBeats += 1;
		}

		#if desktop
		if (songData.events == null)
			songData.events = [];

		for (event in songData.events)
		{
			var event:Event = new Event(event[0], event[1][0][0], event[1][0][1], event[1][0][2]);
			songEvents.push(event);
		}
		#end

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		#if desktop
		if (songEvents.length > 1)
			songEvents.sort(sortEvents);
		#end

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	#if desktop
	public static function sortEvents(Obj:Event, Obj2:Event)
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj.time, Obj2.time);
	}

	public static function callEvent(eventName:String = '', value1:String = '', value2:String = '')
	{
		if (eventName != null && eventName != '')
		{
			for (module in updateScript) {
				if (module.isAlive && module.exists('onEvent'))
					module.get('onEvent')(eventName, value1, value2);
			}

			for (module in stageScripts) {
				if (module.isAlive && module.exists('onEvent'))
					module.get('onEvent')(eventName, value1, value2);
			}
		}
	}
	#end

	public function generateOpponentStaticArrows(?threePlayer:Bool = false):Void
	{
		for (i in 0...4)
			createStaticArrow(i, 0, (Main.gameSettings.getSettingBool('Middlescroll') ? false : isStoryMode), threePlayer);
	}

	public function generatePlayerStaticStaticArrows(?threePlayer:Bool = false):Void
	{
		for (i in 0...4)
			createStaticArrow(i, 1, (Main.gameSettings.getSettingBool('Middlescroll') ? false : isStoryMode), threePlayer);
	}

	public function generateGfStaticArrows():Void
	{
		for (i in 0...4)
			createStaticArrow(i, 2, (Main.gameSettings.getSettingBool('Middlescroll') ? false : isStoryMode), true);
	}

	public static function createStaticArrow(noteData:Int = 0, player:Int = 0, canTween:Bool = false, thirdPlayers:Bool = false)
	{
		switch (player)
		{
			case 1:
				var noteTextureString:String;
				noteTextureString = bfNoteStyle;

				var babyArrow:Strum = new Strum(0, strumLine.y - 5, noteData, (usingBotPlay ? false : true), noteTextureString);

				switch (noteTextureString)
				{
					case 'pixel':
						babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
						babyArrow.animation.add('green', [6]);
						babyArrow.animation.add('red', [7]);
						babyArrow.animation.add('blue', [5]);
						babyArrow.animation.add('purplel', [4]);

						babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState.daPixelZoom));
						babyArrow.updateHitbox();
						babyArrow.antialiasing = false;

						switch (Math.abs(noteData))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.add('static', [0]);
								babyArrow.animation.add('pressed', [4, 8], 12, false);
								babyArrow.animation.add('confirm', [12, 16], 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.add('static', [1]);
								babyArrow.animation.add('pressed', [5, 9], 12, false);
								babyArrow.animation.add('confirm', [13, 17], 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.add('static', [2]);
								babyArrow.animation.add('pressed', [6, 10], 12, false);
								babyArrow.animation.add('confirm', [14, 18], 12, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.add('static', [3]);
								babyArrow.animation.add('pressed', [7, 11], 12, false);
								babyArrow.animation.add('confirm', [15, 19], 24, false);
						}

					case 'normal':
						babyArrow.frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');
						babyArrow.animation.addByPrefix('green', 'arrowUP');
						babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
						babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
						babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

						babyArrow.antialiasing = true;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

						switch (Math.abs(noteData))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
								babyArrow.animation.addByPrefix('pressed', 'left press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm instance 1', 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
								babyArrow.animation.addByPrefix('pressed', 'down press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'down confirm instance 1', 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
								babyArrow.animation.addByPrefix('pressed', 'up press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'up confirm instance 1', 24, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
								babyArrow.animation.addByPrefix('pressed', 'right press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm instance 1', 24, false);
						}
					default:
						#if desktop
						babyArrow.frames = Paths.getModSparrowAtlas(bfNoteStyle); //If you want to set a image path instead.
						if (babyArrow.frames == null)
						#end
							babyArrow.frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');
						babyArrow.animation.addByPrefix('green', 'arrowUP');
						babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
						babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
						babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

						babyArrow.antialiasing = true;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

						switch (Math.abs(noteData))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
								babyArrow.animation.addByPrefix('pressed', 'left press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm instance 1', 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
								babyArrow.animation.addByPrefix('pressed', 'down press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'down confirm instance 1', 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
								babyArrow.animation.addByPrefix('pressed', 'up press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'up confirm instance 1', 24, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
								babyArrow.animation.addByPrefix('pressed', 'right press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm instance 1', 24, false);
						}
				}

				babyArrow.updateHitbox();
				babyArrow.scrollFactor.set();

				if (canTween && !skipArrowTween)
				{
					babyArrow.alpha = 0;
					FlxTween.tween(babyArrow, {alpha: 1, y: babyArrow.y + 10}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * noteData)});
				}
				
				playerStrums.add(babyArrow);

				babyArrow.animation.play('static');
				if (!PlayerPrefs.middlescroll)
				{
					if (thirdPlayers)
					{
						switch (noteData)
						{
							case 0:
								babyArrow.x = 850;
							case 1:
								babyArrow.x = 945;
							case 2:
								babyArrow.x = 1040;
							case 3:
								babyArrow.x = 1135;
						}

						babyArrow.scale.x = 0.6;
						babyArrow.scale.y = 0.6;
					}
					else
					{
						babyArrow.x += 50;
						babyArrow.x += (FlxG.width / 2);
					}
				}

				if (PlayerPrefs.middlescroll)
				{
					babyArrow.x += FlxG.width / 3;
				}

				strumLineNotes.add(babyArrow);
				babyArrow.characterToPlay.push(boyfriend);
			case 0:
				var noteTextureString:String;
				noteTextureString = dadNoteStyle;

				var babyArrow:Strum = new Strum(0, strumLine.y - 5, noteData, false, noteTextureString);

				switch (noteTextureString)
				{
					case 'pixel':
						babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
						babyArrow.animation.add('green', [6]);
						babyArrow.animation.add('red', [7]);
						babyArrow.animation.add('blue', [5]);
						babyArrow.animation.add('purplel', [4]);

						babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState.daPixelZoom));
						babyArrow.updateHitbox();
						babyArrow.antialiasing = false;

						switch (Math.abs(noteData))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.add('static', [0]);
								babyArrow.animation.add('pressed', [4, 8], 12, false);
								babyArrow.animation.add('confirm', [12, 16], 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.add('static', [1]);
								babyArrow.animation.add('pressed', [5, 9], 12, false);
								babyArrow.animation.add('confirm', [13, 17], 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.add('static', [2]);
								babyArrow.animation.add('pressed', [6, 10], 12, false);
								babyArrow.animation.add('confirm', [14, 18], 12, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.add('static', [3]);
								babyArrow.animation.add('pressed', [7, 11], 12, false);
								babyArrow.animation.add('confirm', [15, 19], 24, false);
						}

					case 'normal':
						babyArrow.frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');
						babyArrow.animation.addByPrefix('green', 'arrowUP');
						babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
						babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
						babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

						babyArrow.antialiasing = true;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

						switch (Math.abs(noteData))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
								babyArrow.animation.addByPrefix('pressed', 'left press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm instance 1', 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
								babyArrow.animation.addByPrefix('pressed', 'down press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'down confirm instance 1', 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
								babyArrow.animation.addByPrefix('pressed', 'up press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'up confirm instance 1', 24, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
								babyArrow.animation.addByPrefix('pressed', 'right press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm instance 1', 24, false);
						}
					default:
						#if desktop
						babyArrow.frames = Paths.getModSparrowAtlas(dadNoteStyle); //If you want to set a image path instead.
						if (babyArrow.frames == null)
						#end
							babyArrow.frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');
						babyArrow.animation.addByPrefix('green', 'arrowUP');
						babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
						babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
						babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

						babyArrow.antialiasing = true;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

						switch (Math.abs(noteData))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
								babyArrow.animation.addByPrefix('pressed', 'left press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm instance 1', 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
								babyArrow.animation.addByPrefix('pressed', 'down press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'down confirm instance 1', 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
								babyArrow.animation.addByPrefix('pressed', 'up press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'up confirm instance 1', 24, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
								babyArrow.animation.addByPrefix('pressed', 'right press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm instance 1', 24, false);
						}
				}

				babyArrow.updateHitbox();
				babyArrow.scrollFactor.set();
				var tweenOn:Bool = false;
				var tween:FlxTween = null;

				if (canTween && !skipArrowTween)
				{
					babyArrow.alpha = 0;
					tween = FlxTween.tween(babyArrow, {alpha: 1, y: babyArrow.y + 5}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * noteData)});
					tweenOn = true;
				}
				
				opponentStrums.add(babyArrow);
				babyArrow.animation.play('static');

				if (thirdPlayers && !PlayerPrefs.middlescroll)
				{
					switch (noteData)
					{
						case 0:
							babyArrow.x = 30;
						case 1:
							babyArrow.x = 125;
						case 2:
							babyArrow.x = 220;
						case 3:
							babyArrow.x = 315;
					}

					babyArrow.scale.x = 0.6;
					babyArrow.scale.y = 0.6;
				}
				else
					if (PlayerPrefs.middlescroll)
					{
						babyArrow.visible = false;
						babyArrow.x -= 500;
					}
					else	
						babyArrow.x += 100;

					strumLineNotes.add(babyArrow);
					babyArrow.characterToPlay.push(dad);
			case 2:
				var noteTextureString:String;
				noteTextureString = dadNoteStyle;

				var babyArrow:Strum = new Strum(0, strumLine.y, noteData, false, noteTextureString);

				switch (noteTextureString)
				{
					case 'pixel':
						babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
						babyArrow.animation.add('green', [6]);
						babyArrow.animation.add('red', [7]);
						babyArrow.animation.add('blue', [5]);
						babyArrow.animation.add('purplel', [4]);

						babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState.daPixelZoom));
						babyArrow.updateHitbox();
						babyArrow.antialiasing = false;

						switch (Math.abs(noteData))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.add('static', [0]);
								babyArrow.animation.add('pressed', [4, 8], 12, false);
								babyArrow.animation.add('confirm', [12, 16], 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.add('static', [1]);
								babyArrow.animation.add('pressed', [5, 9], 12, false);
								babyArrow.animation.add('confirm', [13, 17], 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.add('static', [2]);
								babyArrow.animation.add('pressed', [6, 10], 12, false);
								babyArrow.animation.add('confirm', [14, 18], 12, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.add('static', [3]);
								babyArrow.animation.add('pressed', [7, 11], 12, false);
								babyArrow.animation.add('confirm', [15, 19], 24, false);
						}

					case 'normal':
						babyArrow.frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');
						babyArrow.animation.addByPrefix('green', 'arrowUP');
						babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
						babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
						babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

						babyArrow.antialiasing = true;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

						switch (Math.abs(noteData))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
								babyArrow.animation.addByPrefix('pressed', 'left press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm instance 1', 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
								babyArrow.animation.addByPrefix('pressed', 'down press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'down confirm instance 1', 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
								babyArrow.animation.addByPrefix('pressed', 'up press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'up confirm instance 1', 24, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
								babyArrow.animation.addByPrefix('pressed', 'right press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm instance 1', 24, false);
						}
					default:
						#if desktop
						babyArrow.frames = Paths.getModSparrowAtlas(dadNoteStyle); //If you want to set a image path instead.
						if (babyArrow.frames == null)
						#end
							babyArrow.frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');
						babyArrow.animation.addByPrefix('green', 'arrowUP');
						babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
						babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
						babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

						babyArrow.antialiasing = true;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

						switch (Math.abs(noteData))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
								babyArrow.animation.addByPrefix('pressed', 'left press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm instance 1', 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
								babyArrow.animation.addByPrefix('pressed', 'down press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'down confirm instance 1', 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
								babyArrow.animation.addByPrefix('pressed', 'up press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'up confirm instance 1', 24, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
								babyArrow.animation.addByPrefix('pressed', 'right press instance 1', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm instance 1', 24, false);
							default:
								babyArrow.x += Note.swagWidth * noteData;
								babyArrow.animation.addByPrefix('static', arrowDirs[noteData] + ' static instance ' + noteData); // :)
								babyArrow.animation.addByPrefix('pressed', arrowDirs[noteData] + ' press instance 1');
								babyArrow.animation.addByPrefix('static', arrowDirs[noteData] + ' confirm instance 1');
						}
				}

				babyArrow.updateHitbox();
				babyArrow.scrollFactor.set();
				var tween:FlxTween;

				if (canTween && !skipArrowTween)
				{
					babyArrow.alpha = 0;
					var tween = FlxTween.tween(babyArrow, {alpha: 1, y: babyArrow.y + 5}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * noteData)});
				}
				
				gfStrums.add(babyArrow);
				babyArrow.animation.play('static');

				if (!PlayerPrefs.middlescroll)
				{
					switch (noteData)
					{
						case 0:
							babyArrow.x = 450;
						case 1:
							babyArrow.x = 545;
						case 2:
							babyArrow.x = 640;
						case 3:
							babyArrow.x = 735;
					}

					babyArrow.scale.x = 0.6;
					babyArrow.scale.y = 0.6;
				}
				else
					babyArrow.x -= 500;

				strumLineNotes.add(babyArrow);
				babyArrow.characterToPlay.push(gf);
		}

		trace("Created Arrow with the note data of: " + noteData + ', Player: ' + player);
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	public function camFollowChar(char:Character, xOffset:Float = 150, yOffset:Float = -100, cancel:Bool = false, isDad:Bool = false)
	{
		if (cancel)
			cancelOutCharFollow = true;

		if (isDad)
		{
			switch (char.curCharacter)
			{
				case 'mom':
					camPos.set(camPos.x, char.getMidpoint().y);
				case 'senpai':
					xOffset = -50;
					yOffset = -430;
				case 'senpai-angry':
					xOffset = -50;
					yOffset = -430;
				case 'pico':
					xOffset += 175;
			}
		}

		camPos.set(char.getMidpoint().x + xOffset, char.getMidpoint().y + yOffset);
		camFollow.setPosition(camPos.x, camPos.y);

		if (char.curCharacter == 'mom' && isDad)
			vocals.volume = 1;

		if (SONG.song.toLowerCase() == 'tutorial' && isDad && char.curCharacter == 'gf')
		{
			tweenCamIn();
		}
	}

	public function camFollowBF(char:Character, xOffset:Float = -100, yOffset:Float = -100)
	{
		switch (boyfriend.curCharacter)
		{
			case 'bf-car':
				xOffset = -300;
			case 'bf-christmas':
				yOffset = -200;
			case 'bf-pixel':
				xOffset = -200;
				yOffset = -200;
		}

		camPos.set(char.getMidpoint().x + xOffset, char.getMidpoint().y + yOffset);
		camFollow.setPosition(camPos.x, camPos.y);

		if (SONG.song.toLowerCase() == 'tutorial')
		{
			FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
		}
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	public var cancelOutCharFollow:Bool = false;

	override public function update(elapsed:Float)
	{
		curElapsed = elapsed;

		for (module in updateScript) {
			if (module.isAlive && module.exists('onUpdate')) {
				module.get('onUpdate')(elapsed);
			}
		}

		for (noteModule in noteTypeScripts){
			if (noteModule.isAlive && noteModule.exists('onUpdate')) {
				noteModule.get('onUpdate')(elapsed);
			}
		}

		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		var healthPercent:Float = FlxMath.roundDecimal(health * 50, 2);

		if (healthPercent > 100)
			healthPercent = 100;

		scoreTxt.text = 'SCORE: ' + songScore + scoreDivider + 'MISSES: ' + misses + scoreDivider + Ratings.scoreText;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				ClassShit.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			ClassShit.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (!iconP1.iconIsAnimated)
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		if (!iconP2.iconIsAnimated)
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (health < 0)
			health = 0;

		if (iconP1.iconIsAnimated){
			if (healthBar.percent < 20)
				iconP1.animation.play('losing');
			else
				iconP1.animation.play('normal');
		}
		else {
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;
		}

		if (iconP2.iconIsAnimated){
			if (healthBar.percent < 20)
				iconP2.animation.play('losing');
			else
				iconP2.animation.play('normal');
		}
		else {
			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;
		}

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			ClassShit.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;

					curTime = Math.round(songTime / 1000);

					var numbSeconds:Float = curTime;
					switch (PlayerPrefs.timeType)
					{
						case 'Time Elapsed':
							timeText.text = FlxStringUtil.formatTime(numbSeconds, false) + '/' + timeLength;
						case 'Song Name':
							timeText.text = SONG.song;
					}
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				if (boyfriend.camOffset != null)
					if (camPos.x != boyfriend.getMidpoint().x + (-100 + boyfriend.camOffset[0]) && !cancelOutCharFollow)
							camFollowBF(boyfriend, -100 + boyfriend.camOffset[0], -100 + boyfriend.camOffset[1]);
				else
					if (camPos.x != boyfriend.getMidpoint().x + -100 && !cancelOutCharFollow)
							camFollowBF(boyfriend, -100, -100);
			}
			else
			{
				if (dad.camOffset != null)
					if (camPos.x != dad.getMidpoint().x + (150 + dad.camOffset[0]) && !cancelOutCharFollow)
							camFollowChar(dad, 150 + dad.camOffset[0], -100 + dad.camOffset[1], false, true);
				else
					if (camPos.x != dad.getMidpoint().x + 150 && !cancelOutCharFollow)
							camFollowChar(dad, 150, -100, false, true);
			}
		}

		if (camZooming && PlayerPrefs.camCanZoom)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			camNotes.zoom = FlxMath.lerp(1, camNotes.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// ClassShit.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// ClassShit.switchState(new PlayState());
			}
		}

		if (controls.RESET)
			health = 0;

		if (health <= 0 && !usingPractice && !usingBotPlay)
			killPlayer();

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				var isPlayer:Bool = daNote.isPlayer;
				var thirdPlayer:Bool = daNote.isThreePlayerNote;
				var isSustain:Bool = daNote.isSustainNote;
				var strumToGo:FlxTypedGroup<Strum> = opponentStrums;
				var modifiedX:Float = daNote.modifiedX;
				var goodHit:Bool = daNote.wasGoodHit;
				var prevNote:Note = daNote.prevNote;
				var mustPress:Bool = daNote.mustPress;
				var canBeHit:Bool = daNote.canBeHit;

				if (isPlayer)
					strumToGo = playerStrums;

				if (thirdPlayer)
					strumToGo = gfStrums;

				if (!isPlayer && !thirdPlayer)
					strumToGo = opponentStrums;

				var sustainModifier:Float = 0;

				if (isSustain)
					sustainModifier = 37;

				if (PlayerPrefs.downscroll)
					daNote.y = (strumToGo.members[daNote.noteData].y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(songSpeed, 2)));
				else
					daNote.y = (strumToGo.members[daNote.noteData].y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(songSpeed, 2)));

				if (!daNote.modifiedPos)
					daNote.x = strumToGo.members[daNote.noteData].x + sustainModifier;
				else
					daNote.x = modifiedX;

				if (!daNote.modifiedNote)
				{
					if (daNote.isSustainNote)
						daNote.alpha = strumToGo.members[daNote.noteData].alpha * 0.6;
					else
						daNote.alpha = strumToGo.members[daNote.noteData].alpha;
					daNote.visible = strumToGo.members[daNote.noteData].visible;
					if (!daNote.isSustainNote)
						daNote.angle = strumToGo.members[daNote.noteData].angle;
				}

				// i am so fucking sorry for this if condition
				if (isSustain
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!mustPress || (goodHit || (prevNote.wasGoodHit && !canBeHit))) || 
					isSustain && daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2 
					&& (!mustPress || (goodHit || (prevNote.wasGoodHit && !daNote.canBeHit))) && thirdPlayer)
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (isPlayer && usingBotPlay && canBeHit)
					goodNoteHit(daNote);

				if (!mustPress && goodHit && !thirdPlayer || !mustPress && goodHit && thirdPlayer)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					opponentHit(daNote);

					if (SONG.needsVoices)
						vocals.volume = 1;

					for (module in updateScript) {
						if (module.isAlive && module.exists('onOpponentHit'))
							module.get('onOpponentHit')(daNote.noteData, daNote);
					}
					
					for (module in noteTypeScripts) {
						if (module.isAlive && module.exists('onOpponentHit'))
							module.get('onOpponentHit')(daNote.noteData, daNote);
					}

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var noteLate:Bool = false;

				if (PlayerPrefs.downscroll) {
					if (daNote.y >= strumLine.y + 106)
						noteLate = true;
				}
				else {
					if (daNote.y < -daNote.height)
						noteLate = true;
				}

				if (noteLate && mustPress)
				{
					if ((daNote.tooLate || !goodHit) && !daNote.ignoreNote && !daNote.hitCauseMiss && !usingBotPlay && !daNote.isThreePlayerNote)
					{
						vocals.volume = 0;
						noteMiss(daNote.noteData, daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE && !endingSong && !startingSong)
			endSong();
		if (FlxG.keys.justPressed.TWO && !endingSong && !startingSong)
			setSongTime(Conductor.songPosition + 10000);
		#end

		for (module in updateScript) {
			if (module.isAlive && module.exists('onUpdatePost')) {
				module.get('onUpdatePost')(elapsed);
			}
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;

		var curNote:Int = unspawnNotes.length - 1;

		while (curNote >= 0)
		{
			var daNote:Note = unspawnNotes[curNote];

			if (daNote.strumTime < Conductor.songPosition) 
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				
				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}

			curNote--;
		}

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.strumTime < Conductor.songPosition)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
		});
	}

	function endSong():Void
	{
		for (module in updateScript)
		{
			if (module.isAlive && module.exists('onEndSong'))
				module.get('onEndSong')();
		}

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore && !usedPractice && !usingBotPlay)
		{
			Highscore.saveScore(SONG.song.toLowerCase(), songScore, diffText);
			Highscore.saveSongBeat(SONG.song);
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				ClassShit.switchState(new StoryMenuState());

				StoryMenuState.setUnlocked(weekName);

				if (SONG.validScore && !usedPractice) 
				{
					Highscore.saveWeekScore(weekName, campaignScore, diffText);
				}
			}
			else
			{
				var difficulty:String = diffText;

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			ClassShit.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu')); //To keep game from crashing.
		}
	}

	var endingSong:Bool = false;

	public function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.cameras = [camOverlay];
		coolText.screenCenter();
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 0;

		var daRating:String = "sick";

		if (!usingBotPlay)
		{
			if (noteDiff > Conductor.safeZoneOffset * 0.9)
				daNote.rating = 'shit';
			else if (noteDiff > Conductor.safeZoneOffset * 0.75)
				daNote.rating = 'bad';
			else if (noteDiff > Conductor.safeZoneOffset * 0.2)
				daNote.rating = 'good';

			switch (daNote.rating)
			{
				case "shit":
					score = 50;
					daRating = 'shit';
					shits++;
				case "bad":
					score = 100;
					daRating = 'bad';
					bads++;
				case "good":
					score = 200;
					daRating = 'good';
					goods++;
				case "sick":
					score = 350;
					sicks++;
					daRating = 'sick';
			}
		}

		if (daRating == 'sick' && PlayerPrefs.noteSplashes)
			callNoteSplash(daNote.noteData, (SONG.threePlayer ? true : false));

		if (!usingBotPlay)
			Ratings.onNoteHit(daNote.rating, daNote.isSustainNote);

		songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if (curStage.startsWith('school'))
			rating.loadGraphic(Paths.image('ratings/' + pixelShitPart1 + daRating + pixelShitPart2, 'shared'));
		else
			rating.loadGraphic(Paths.image('ratings/' + daRating, 'shared'));
		rating.cameras = [camOverlay];
		rating.screenCenter();
		rating.x = coolText.x - 50;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		if (curStage.startsWith('school'))
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		else
			rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = true;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ratings/' + pixelShitPart1 + 'combo' + pixelShitPart2, "shared"));
		comboSpr.cameras = [camOverlay];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.antialiasing = true;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		if (curStage.startsWith('school'))
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		else
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		add(rating);

		if (curStage.startsWith('school')) {
			rating.antialiasing = false;
			comboSpr.antialiasing = false;
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ratings/' + pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, "shared"));
			numScore.cameras = [camOverlay];
			numScore.screenCenter();
			numScore.x = coolText.x +  (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	public function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var holdArray:Array<Bool> = [left, down, up, right];
		var pressArray:Array<Bool> = [leftP, downP, upP, rightP];
		var releaseArray:Array<Bool> = [leftR, downR, upR, rightR];

		if (usingBotPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if ((pressArray[2] || pressArray[3] || pressArray[1] || pressArray[0]) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							var controlArray:Array<Bool> = [];

							if (coolNote.isSustainNote)
								controlArray = holdArray;
							else
								controlArray = pressArray;

							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						var controlArray:Array<Bool> = [];

						if (daNote.isSustainNote)
							controlArray = holdArray;
						else
							controlArray = pressArray;

						if (controlArray[daNote.noteData])
							goodNoteHit(daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							var controlArray:Array<Bool> = [];

							if (coolNote.isSustainNote)
								controlArray = holdArray;
							else
								controlArray = pressArray;
								
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
						}
					}
				}
				else // regular notes?
				{
					var controlArray:Array<Bool> = [];

					if (daNote.isSustainNote)
						controlArray = holdArray;
					else
						controlArray = pressArray;

					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				}
			}
			else if (!PlayerPrefs.ghostTapping)
			{
				for (i in 0...pressArray.length)
					if (pressArray[i])
						noteMiss(i, null);
			}
		}

		if ((holdArray[2] || holdArray[3] || holdArray[1] || holdArray[0]) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote && !daNote.isThreePlayerNote)
				{
					if (holdArray[daNote.noteData])
						goodNoteHit(daNote);
				}
			});
		}

		if (usingBotPlay)
		{
			if (boyfriend.animation.curAnim.finished)
				boyfriend.playAnim('idle');
		}
		else
		{
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
		}

		for (i in 0...playerStrums.length)
		{
			if (pressArray[i] && playerStrums.members[i].animation.curAnim.name != 'confirm')
				playerStrums.members[i].playAnim('pressed');
			if (releaseArray[i])
				playerStrums.members[i].playAnim('static');
		}

		for (module in updateScript) {
			if (module.isAlive && module.exists('onKeyUpdate')) {
				module.get('onKeyUpdate')();
			}
		}
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		for (module in noteTypeScripts)
		{
			if (module.isAlive && module.exists('onNoteMiss'))
				module.get('onNoteMiss')(direction, daNote);
		}

		for (module in updateScript)
		{
			if (module.isAlive && module.exists('onNoteMiss'))
				module.get('onNoteMiss')(direction, daNote);
		}

		if (daNote == null)
			health -= 0.05;
		else
			health -= daNote.healthLoss;

		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;
		misses++;

		songScore -= 10;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
		{
			boyfriend.stunned = false;
		});

		switch (direction)
		{
			case 0:
				boyfriend.playAnim('singLEFTmiss', true);
			case 1:
				boyfriend.playAnim('singDOWNmiss', true);
			case 2:
				boyfriend.playAnim('singUPmiss', true);
			case 3:
				boyfriend.playAnim('singRIGHTmiss', true);
		}

		for (module in updateScript)
		{
			if (module.isAlive && module.exists('onNoteMissPost'))
				module.get('onNoteMissPost')(direction, daNote);
		}
		
		for (module in noteTypeScripts)
		{
			if (module.isAlive && module.exists('onNoteMissPost'))
				module.get('onNoteMissPost')(direction, daNote);
		}

		Ratings.onNoteHit('miss', (daNote != null ? daNote.isSustainNote : false)); //I know it says noteHit but idc
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit && !note.isThreePlayerNote)
		{
			if (note.hitCauseMiss)
			{
				noteMiss(note.noteData, note);

				note.wasGoodHit = true;

				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				playerStrums.members[note.noteData].playAnim('confirm', true);

				return;
			}

			if (FlxG.save.data.hitsound && !note.isSustainNote)
			{
				FlxG.sound.play(UnkownEngineHelpers.getCustomPath('sounds/hitsound', SOUND));
			}

			for (module in updateScript) {
				if (module.isAlive && module.exists('onGoodNoteHit')) {
					module.get('onGoodNoteHit')(note);
				}
			}

			for (module in noteTypeScripts)
			{
				if (module.isAlive && module.exists('onGoodNoteHit'))
					module.get('onGoodNoteHit')(note);
			}

			health += note.healthGain;

			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
			}

			if (!note.customAnims && !note.noAnim)
			{
				var useAltAnim:Bool = false;

				if (note.noteType == 'Alt-Anim')
					useAltAnim = true;

				playerStrums.members[note.noteData].playCharAnim(useAltAnim);
			}

			if (note.customAnims)
			{
				playerStrums.members[note.noteData].singAnim = note.daAnims;
				playerStrums.members[note.noteData].playCharAnim();
			}

			playerStrums.members[note.noteData].playAnim('confirm', true);

			note.wasGoodHit = true;
			vocals.volume = 1;

			for (module in updateScript) {
				if (module.isAlive && module.exists('onGoodNoteHitPost')) {
					module.get('onGoodNoteHitPost')(note.noteData, note);
				}
			}

			for (module in noteTypeScripts)
			{
				if (module.isAlive && module.exists('onGoodNoteHitPost'))
					module.get('onGoodNoteHitPost')(note.noteData, note);
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		for (module in updateScript) {
			if (module.isAlive && module.exists('onStepHit')) {
				module.get('onStepHit')(curStep);
			}
		}

		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		for (module in updateScript) {
			if (module.isAlive && module.exists('onBeatHit')) {
				module.get('onBeatHit')(curBeat);
			}
		}

		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			camNotes.zoom += 0.03;
		}

		if (!iconP1.iconIsAnimated)
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));

		if (!iconP2.iconIsAnimated)
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var gfIdle:Int = gf.idleOnBeat;
		var boyfrieindIdle:Int = boyfriend.idleOnBeat;
		var dadIdle:Int = dad.idleOnBeat;

		if (dadIdle == 0)
			dadIdle = 1;

		if (boyfrieindIdle == 0)
			boyfrieindIdle = 1;

		if (gfIdle == 0)
			gfIdle = 1;

		if (curBeat % gfIdle == 0)
			gf.dance();

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && curBeat % boyfrieindIdle == 0)
			boyfriend.dance();

		if (dad.danceIdle)
		{
			if (!dad.animation.curAnim.name.startsWith("sing") && curBeat % dadIdle == 0)
				dad.dance();
		}
		else
			if (dad.animation.curAnim.name == dad.idleDance && curBeat % dadIdle == 0)
				dad.dance();

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'tank':
				tankWatchtower.dance();

				foregroundSprites.forEach(function(spr:TankBGSprite)
				{
					spr.dance();
				});
			case 'school':
				if (bgGirls != null)
					bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
						dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;

	public function opponentHit(daNote:Note)
	{
		var altAnim:String = "";
		var useAltAnim:Bool = false;

		if (daNote.noteType == 'Alt-Anim')
		{
			useAltAnim = true;
		}

		if (!daNote.hitCauseMiss)
		{
			if (daNote.isThreePlayerNote && SONG.threePlayer)
			{
				gfStrums.members[daNote.noteData].playCharAnim(useAltAnim);
				gfStrums.members[daNote.noteData].playAnim('confirm', true);
			}
			else
			{
				opponentStrums.members[daNote.noteData].playCharAnim(useAltAnim);
				opponentStrums.members[daNote.noteData].playAnim('confirm', true);
			}
		}
	}

	function callNoteSplash(noteData:Int, threePlayer:Bool = false){
        var daNote:FlxSprite = playerStrums.members[noteData];

        spawnNoteSplash(daNote.x, daNote.y, noteData, threePlayer, noteSplashOverride);
    }

    public function spawnNoteSplash(x:Float, y:Float, noteData:Int, ?threePlayer:Bool = false, splashOverride:String = null) {
        var texture:String = 'noteSplashes';

        var splash:NoteSplash = splashGroup.recycle(NoteSplash);
        splash.addSplash(x, y, noteData, null, threePlayer, splashOverride, splashOffsetX, splashOffsetY, splashFrames);
        splashGroup.add(splash);
    }

	public static function getClassVar(className:String, variable:String)
	{
		var split:Array<String> = variable.split('.');

		if(split.length > 1) {
			var idk:Dynamic = Reflect.getProperty(Type.resolveClass(className), split[0]);
			for (i in 1...split.length-1) {
				idk = Reflect.getProperty(idk, split[i]);
			}
			return Reflect.getProperty(idk, split[split.length - 1]);
		}

		return Reflect.getProperty(Type.resolveClass(className), variable);
	}

	public static function setClassVar(className:String, variable:String, value:String)
	{
		var split:Array<String> = variable.split('.');
		if (split.length > 1)
		{
			var idk:Dynamic = Reflect.getProperty(Type.resolveClass(className), split[0]);
			for (i in 1...split.length - 1){
				idk = Reflect.getProperty(idk, split[i]);
			}
			return Reflect.setProperty(idk, split[split.length - 1], value);
		}

		return Reflect.setProperty(Type.resolveClass(className), variable, value);
	}

	public function setCamZoom(zoom:Float)
	{
		defaultCamZoom = zoom;
	}

	public function destroyModules()
	{
		for (modules in updateScript)
		{
			modules.isAlive = false;
		}

		updateScript = [];
		
		for (modules in stageScripts)
		{
			modules.isAlive = false;
		}

		stageScripts = [];
		
		for (modules in noteTypeScripts)
		{
			modules.isAlive = false;
		}

		noteTypeScripts = [];
	}

	public function setCharacterX(character:String = 'boyfriend', value:Float = 0, addValue:Bool = false)
	{
		var valueToAdd:Float = 0;

		if (addValue)
			valueToAdd = value;

		if (addValue)
			switch (character)
			{
				case 'boyfriend':
					boyfriendX += valueToAdd;
				case 'dad':
					dadX += valueToAdd;
				case 'gf':
					gfX += valueToAdd;
				default:
					if (moduleCharacters.exists(character)) {
						var char:Character = moduleCharacters.get(character);
						char.x += valueToAdd;
					}
			}
		else
			switch (character)
			{
				case 'boyfriend':
					boyfriendX = value;
				case 'dad':
					dadX = value;
				case 'gf':
					gfX = value;
				default:
					if (moduleCharacters.exists(character)) {
						var char:Character = moduleCharacters.get(character);
						char.x = value;
					}
			}
	}
	
	
	public function setCharacterY(character:String = 'boyfriend', value:Float, addValue:Bool = false)
	{
		var valueToAdd:Float = 0;

		if (addValue)
			valueToAdd = value;

		if (addValue)
			switch (character)
			{
				case 'boyfriend':
					boyfriendY += valueToAdd;
				case 'dad':
					dadY += valueToAdd;
				case 'gf':
					gfY += valueToAdd;
				default:
					if (moduleCharacters.exists(character)) {
						var char:Character = moduleCharacters.get(character);
						char.y += valueToAdd;
					}
			}
		else
			switch (character)
			{
				case 'boyfriend':
					boyfriendY = value;
				case 'dad':
					dadY = value;
				case 'gf':
					gfY = value;
				default:
					if (moduleCharacters.exists(character)) {
						var char:Character = moduleCharacters.get(character);
						char.y = value;
					}
			}
	}

	public function addCharacter(char:Character, charName:String = 'unknown')
	{
		if (!moduleCharacters.exists(charName))
		{
			add(char);
			moduleCharacters.set(charName, char);
		}
		else
			trace('Character already exists with the name' + charName);
	}

	public function setCharacterProperty(character:Character, variable:String = '', value:Dynamic = null)
	{
		if ((variable != null || variable != '') && value != null && character != null)
		{
			switch (variable)
			{
				case "idleDance":
					character.idleDance = value;
				case "canIdle":
					character.idleDance = value;
				case "healthIcon":
					character.healthIcon = value;
				case "x":
					//character.x = value;
				case "y":
					//character.y = value; x and y don't work for some reason;
			}
		}
	}

	public function setCharPositions(dadXPos:Float = 0, dadYPos:Float = 0, bfXPos:Float = 0, bfYPos:Float = 0, gfXPos:Float = 0, gfYPos:Float = 0)
	{
		dad.x = dadXPos;
		dad.y = dadYPos;

		boyfriend.x = bfXPos;
		boyfriend.y = bfYPos;

		gf.x = gfXPos;
		gf.y = gfYPos;
	}

	public function killPlayer()
	{
		boyfriend.stunned = true;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		vocals.stop();
		FlxG.sound.music.stop();

		GameOverSubstate.moduleArray = updateScript;
		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
		#if desktop
		DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
	}

	public function reduceHealth(value:Float) {
		health -= value;
	}

	public function gainHealth(value:Float) {
		health += value;
	}

	public function changePlayerChar(newChar:String)
	{
		var lastAlpha:Float = boyfriend.alpha;
		boyfriend.alpha = 0.0001;
		if (!bfChars.exists(newChar))
		{
			var theChar:Boyfriend = new Boyfriend(0, 0, newChar);
			theChar.setPosition(boyfriendX + theChar.positionOffset[0], boyfriendY +theChar.positionOffset[1]);
			add(theChar);
			theChar.alpha = 0.00001;
			bfChars.set(newChar, theChar);
		}
		boyfriend = bfChars.get(newChar);
		boyfriend.alpha = lastAlpha;
		iconP1.changeIcon(newChar, true, boyfriend.healthIconIsAnimated, boyfriend.healthIconAnim, boyfriend.healthIconLooped, boyfriend.iconScale);
	}

	public function changeOpponentChar(newChar:String)
	{
		var lastAlpha:Float = dad.alpha;
		dad.alpha = 0.0001;
		if (!dadChars.exists(newChar))
		{
			var theChar:Character = new Character(0, 0, newChar);
			theChar.setPosition(dadX + theChar.positionOffset[0], dadY +theChar.positionOffset[1]);
			add(theChar);
			theChar.alpha = 0.00001;
			dadChars.set(newChar, theChar);
		}
		dad = dadChars.get(newChar);
		dad.alpha = lastAlpha;
		iconP2.changeIcon(newChar, false, dad.healthIconIsAnimated, dad.healthIconAnim, dad.healthIconLooped, dad.iconScale);
	}

	public function changeGfChar(newChar:String)
	{
		var lastAlpha:Float = gf.alpha;
		gf.alpha = 0.0001;
		if (!gfChars.exists(newChar))
		{
			var theChar:Character = new Character(0, 0, newChar);
			theChar.setPosition(dadX + theChar.positionOffset[0], dadY +theChar.positionOffset[1]);
			add(theChar);
			theChar.alpha = 0.00001;
			gfChars.set(newChar, theChar);
		}
		gf = gfChars.get(newChar);
		gf.alpha = lastAlpha;
	}

	public function pushCharToStrum(char:Character, strums:FlxTypedGroup<Strum>, id:Int, allStrums:Bool = false)
	{
		if (allStrums)
			for (i in 0...strums.length)
				strums.members[i].characterToPlay.push(char);
		else
			strums.members[id].characterToPlay.push(char);
	}

	public function pushModule(path:String = null, moduleType:String = '')
	{
		switch (moduleType)
		{
			case 'Note' | 'note':
				var module = NoteModuleHandler.loadModule(path);
				noteTypeScripts.push(module);
			case 'Normal' | 'normal':
				var module = moduleHandler.loadModule(path);
				updateScript.push(module);
			default:
				var module = moduleHandler.loadModule(path);
				updateScript.push(module);
		}
	}
}