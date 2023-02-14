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
import flash.display.BlendMode;
import flixel.group.FlxSpriteGroup;
import flixel.util.typeLimit.*;
import hxCodec.*;
import Stage;
import Note;
import Strum;
import sys.FileSystem;
import sys.io.File;
import LuaState;
import DialogueState;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;

	public static var laneNotes:Array<Array<Note>> = [];
	public static var noteDataLanes:Array<Array<Array<Note>>> = [];
	public static var laneSustains:Array<Array<Note>> = [];
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	//Module Stuff
	public static var moduleCharacters:Map<String, Character> = new Map<String, Character>();
	public static var moduleSprites:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	public static var moduleSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public static var moduleTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public static var moduleTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public static var gameObjects:Map<String, FlxObject> = new Map<String, FlxObject>();
	public static var addedObjects:Map<String, Bool> = new Map<String, Bool>();

	//Lua Shit
	public static var luaSprites:Map<String, LuaSprite> = new Map<String, LuaSprite>();
	public static var luaTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public static var luaSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public static var luaTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();

	public static var publicVariables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var playStatecams:Map<String, FlxCamera> = new Map<String, FlxCamera>();
	public static var addedSprites:Map<String, Bool> = new Map<String, Bool>();
	public static var luaShaders:Map<String, Array<String>> = new Map<String, Array<String>>();

	public static var boyfriendX:Float = 770;
	public static var boyfriendY:Float = 450;
	public static var gfX:Float = 400;
	public static var gfY:Float = 130;
	public static var dadX:Float = 100;
	public static var dadY:Float = 100;

	public static var bfChars:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public static var gfChars:Map<String, Character> = new Map<String, Character>();
	public static var dadChars:Map<String, Character> = new Map<String, Character>();

	public static var boyfriendGroup:FlxSpriteGroup;
	public static var dadGroup:FlxSpriteGroup;
	public static var gfGroup:FlxSpriteGroup;

	public static var practiceMode:Bool = false;
	public static var deathCounter:Int = 0;
	public static var usedPractice:Bool = false;

	public static var strumLineY:Float;

	var halloweenLevel:Bool = false;

	public var vocals:FlxSound;

	public static var bfGhosts:FlxTypedGroup<FlxSprite>;
	public static var dadGhosts:FlxTypedGroup<FlxSprite>;
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

	public static var strumLineNotes:FlxTypedGroup<StaticArrow>;
	public static var strumLines:FlxTypedGroup<Strum>;
	public static var playerStrums:Strum;
	public static var opponentStrums:Strum;
	public static var gfStrums:Strum;
	public static var splashGroup:FlxTypedGroup<NoteSplash>;

	public var playerLane:Int = 1;
	public var numbOfStrums:Int = 2;

	public var noteSplashOverride:String = null;

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
	public var skipCountdown:Bool = false;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	public static var seenCutscene:Bool = false;

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
	public var songInfoBar:SongInfo;
	public var songHasInfo:Bool = false;

	var talking:Bool = true;
	public var songScore:Int = 0;
	public var scoreTxt:FlxText;
	public var scoreDivider:String = ' | ';

	public static var curElapsed:Float = 0;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var doof:DialogueBox;
	var dialogueBox:DialogueState;

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
	public static var characterScripts:Array<UnkownModule> = [];
	public static var loadedScripts:Array<LuaState> = [];
	public var lastNotification:Notification;

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
		usedPractice = false;
		doCount = true;
		skipIntro = false;

		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		totalNotes = 0;
		laneNotes = [];
		laneSustains = [];

		misses = 0; //reset score

		#if desktop
		songEvents = [];
		#end

		Ratings.resetAccuracy();

		moduleHandler = new ModuleHandler();
		moduleHandler.setVars();
		NoteModuleHandler.setVars();

		destroyModules();
		loadedScripts = [];
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
		playStatecams.set('camGame', camGame);
		addCamera(camUnderlay, 'camUnderlay');
		addCamera(camNotes, 'camNotes');
		addCamera(camHUD, 'camHUD');
		addCamera(camOverlay, 'camOverlay');

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

		boyfriendGroup = new FlxSpriteGroup(boyfriendX, boyfriendY);
		dadGroup = new FlxSpriteGroup(dadX, dadY);
		gfGroup = new FlxSpriteGroup(gfX, gfY);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		if (boyfriend.frames == null){
			boyfriend = new Boyfriend(0, 0, 'bf');
			trace("Boyfriend character does not exists or has an error, sorry.");
		}

		gf = new Character(0, 0, gfVersion);
		if (gf.frames == null){
			gf = new Character(0, 0, 'gf');
			trace("Gf character does not exists or has an error, sorry.");
		}

		if (stageData.hidegf)
			gf.visible = false;

		dad = new Character(0, 0, SONG.player2);
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
							var moduleId:String = StringTools.replace(file, '.hxs', '');
							var module = moduleHandler.loadModule(moduleDir + file, moduleId);
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
		/*
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
			case 'parents-christmas':
				dad.x -= 500;
			case 'tankman':
				dad.y += 250;
		} */

		add(gfGroup);

		if (curStage == 'limo') {
			resetFastCar();
			addBehindChar(fastCar, 'girlfriend');
			add(limo);
		}

		bfGhosts = new FlxTypedGroup<FlxSprite>();
		dadGhosts = new FlxTypedGroup<FlxSprite>();

		add(dadGhosts);
		add(dadGroup);
		
		add(bfGhosts);
		add(boyfriendGroup);

		var luaFolders:Array<String> = [Paths.getPreloadPath('scripts/')];
		#if desktop
		luaFolders.push(Paths.mods('scripts/'));
		#end

		for (folder in luaFolders) {
			if (FileSystem.isDirectory(folder)) {
				for (luaFile in FileSystem.readDirectory(folder)) {
					if (luaFile.endsWith(".lua"))
						startLuaScript(folder + luaFile);
				}
			}
		}

		luaFolders = [Paths.getPreloadPath('stages/' + curStage + '/')]; //Stage Scripts
		#if desktop
		luaFolders.insert(0, Paths.mods('stages/' + curStage + '/'));
		#end

		for (folder in luaFolders) {
			if (FileSystem.isDirectory(folder)) {
				for (luaFile in FileSystem.readDirectory(folder)) {
					if (luaFile.endsWith(".lua"))
						startLuaScript(folder + luaFile);
				}
			}
		}

		callLua('onCreate', []);

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

		addCharacter('girlfriend');
		addCharacter('boyfriend');
		addCharacter('dad');

		switch (curStage) {
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				addBehindChar(evilTrail, 'dad');
			case 'tank':
				add(foregroundSprites);
		}

		doof = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = function() {
			startCountdown(true);
		};

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50 + FlxG.save.data.strumOffset).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		trace('Downscroll = ' + PlayerPrefs.downscroll);
		usingBotPlay = PlayerPrefs.botplay;

		if (PlayerPrefs.downscroll && FlxG.save.data.strumOffset == 0)
			strumLine.y = FlxG.height - 150;

		strumLines = new FlxTypedGroup<Strum>();
		add(strumLines);

		splashGroup = new FlxTypedGroup<NoteSplash>();

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);
		add(splashGroup);

		var splashID:String = SONG.splashJson;

		if (splashID == null || splashID == '')
			splashID = 'default';

		var preloadSplash:NoteSplash = new NoteSplash(100, 100, 0, splashID);
		splashGroup.add(preloadSplash);
		preloadSplash.alpha = 0;

		if (SONG.threePlayer)
			SONG.numbPlayers = 3;

		if (PlayerPrefs.playOpponent)
			playerLane = 0;

		regenStrums();

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

		trace('Current Song Path: ' + Paths.getSongPath(SONG.song));

		#if desktop
		var songCase:String = SONG.song.toLowerCase();
		if (FileSystem.exists(Paths.txt('data/$songCase/songInfo'))) {
			songHasInfo = true;
			songInfoBar = new SongInfo(-275, 100, SONG.song.toLowerCase());
			songInfoBar.cameras = [camOverlay];
			add(songInfoBar);
		}
		#else
		if (Assets.exists(Paths.txt(Paths.getSongPath(SONG.song) + 'songInfo'))) {
			songHasInfo = true;
			songInfoBar = new SongInfo(-275, 100, SONG.song.toLowerCase());
			songInfoBar.cameras = [camOverlay];
			add(songInfoBar);
		}
		#end

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
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColors[0], dad.healthColors[1], 
		dad.healthColors[2]), FlxColor.fromRGB(boyfriend.healthColors[0], boyfriend.healthColors[1], 
		boyfriend.healthColors[2]));
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
		watermarkLol.antialiasing = PlayerPrefs.antialiasing;

		timeText = new FlxText(FlxG.width / 2  - 215, strumLine.y - (PlayerPrefs.downscroll ? -40 : 40), 400, "0:00/???", 60);
		timeText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeText.scrollFactor.set();
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
		strumLines.cameras = [camNotes];
		for (i in 0...strumLines.length)
			strumLines.members[i].strums.cameras = [camNotes];
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


		if (isStoryMode && !seenCutscene)
		{
			seenCutscene = true;

			var songLowerCase:String = curSong.toLowerCase();

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
					#if desktop
					if (FileSystem.exists(Paths.modJson('data/$songLowerCase/dialogue')))
						startDialogue(Paths.modJson('data/$songLowerCase/dialogue'));
					else if (FileSystem.exists(Paths.json('data/$songLowerCase/dialogue')))
						startDialogue(Paths.json('data/$songLowerCase/dialogue'));
					else
						startCountdown();
					#else
					if (Assest.exists(Paths.json('data/$songLowerCase/dialogue')))
						startDialogue(Paths.json('data/$songLowerCase/dialogue'));
					else
						startCountdown();
					#end
			}
		}
		else
		{
			var songLowerCase:String = curSong.toLowerCase();
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		if (SONG.song.toLowerCase() == 'tutorial' && dad.curCharacter.startsWith('gf')) {
			dad.setPosition(gfX, gfY);
			gf.visible = false;
		}

		callLua('onCreatePost', []);
	}

	public function startCharacterScript(character:String = 'bf') {
		var canUse:Bool = false;
		var scriptPath:String = 'modules/characters/' + character + '.hxs';

		#if desktop
		if (FileSystem.exists(Paths.mods(scriptPath))) {
			scriptPath = Paths.mods(scriptPath);
			canUse = true;
		}
		else {
			scriptPath = Paths.getPreloadPath(scriptPath);
			if(FileSystem.exists(scriptPath)) {
				canUse = true;
			}
		}
		#else
		scriptPath = Paths.getPreloadPath(scriptPath);
		if(FileSystem.exists(scriptPath)) {
			canUse = true;
		}
		#end

		if (canUse)
			pushModule(scriptPath, 'character');
	}

	public function addCharacter(theChar:String = 'boyfriend')
	{
		switch (theChar) {
			case 'boyfriend':
				boyfriendGroup.add(boyfriend);
				startCharacterScript(boyfriend.curCharacter);
				setCharPos(boyfriend);
			case 'girlfriend':
				gfGroup.add(gf);
				startCharacterScript(gf.curCharacter);
				setCharPos(gf, true);
			case 'opponent' | 'dad':
				dadGroup.add(dad);
				startCharacterScript(dad.curCharacter);
				setCharPos(dad);
			default:
				if (moduleCharacters.exists(theChar)) {
					var char = moduleCharacters.get(theChar);
					dadGroup.add(char);
					startCharacterScript(char.curCharacter);
					setCharPos(char);
				}
		}
	}

	public function preloadChar(name:String, charType:Int = 0) {
		switch (charType) {
			case 0:
				if (!bfChars.exists(name)) {
					var bf:Boyfriend = new Boyfriend(0, 0, name);
					bfChars.set(name, bf);
					boyfriendGroup.add(bf);
					bf.alpha = 0.00001;
				}
			case 1:
				if (!dadChars.exists(name)) {
					var opponent:Character = new Character(0, 0, name);
					dadChars.set(name, opponent);
					dadGroup.add(opponent);
					opponent.alpha = 0.00001;
				}
			case 2:
				if (!gfChars.exists(name)) {
					var newGF:Character = new Character(0, 0, name);
					gfChars.set(name, newGF);
					gfGroup.add(newGF);
					newGF.alpha = 0.00001;
				}
			default:
				if (!moduleCharacters.exists(name)) {
					var newChar:Character = new Character(0, 0, name);
					moduleCharacters.set(name, newChar);
					dadGroup.add(newChar);
					newChar.alpha = 0.00001;
				}
		}
	}

	public function setCharPos(char:Character, isGF:Bool = false) {
		if (isGF && dad.curCharacter.startsWith('gf')) {
			char.setPosition(gfX, gfY);
			char.scrollFactor.set(0.95, 0.95);
		}

		if (char.positionOffset != null) {
			char.x += char.positionOffset[0];
			char.y += char.positionOffset[1];
		}
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

			trace('Video $name has finished!');
		}
		video.playVideo(Paths.video(name));
		trace('Playing Video $name');
	}

	public function playVideo(fileName:String) {
		var video:VideoHandler = new VideoHandler();
		video.finishCallback = function() {
			trace('Video $fileName has finished!');
		}
		video.playVideo(Paths.video(fileName));
		trace('Playing Video $fileName');
	}

	public function startDialogue(jsonPath:String = null) {
		if (jsonPath != null) {
			var rawJson = null;

			#if desktop
			if (FileSystem.exists(jsonPath))
				rawJson = File.getContent(jsonPath);
			#else
			if (Assets.exists(jsonPath))
				rawJson = Assets.getText(jsonPath);
			#end

			if (rawJson != null) {
				var jsonData:JsonData = Json.parse(rawJson);

				if (jsonData.dialogueData.length <= 0) {
					startCountdown(true);
					trace('Error! No dialogue lines found!');
					return;
				}

				dialogueBox = new DialogueState(jsonData);
				dialogueBox.cameras = [camOverlay];
				add(dialogueBox);
				if(endingSong)
					dialogueBox.finishThing = endSong;
				else
					dialogueBox.finishThing = function(){
						startCountdown(true);
					};
			} else {
				trace('Dialogue File is not found or has an error!');
				FlxG.log.warn('Dialogue File is not found or has an error!');
				if(endingSong)
					endSong();
				else
					startCountdown(true);
			}
		}
		else {
			trace('Dialogue File is not found or has an error!');
			FlxG.log.warn('Dialogue File is not found or has an error!');
			if(endingSong)
				endSong();
			else
				startCountdown(true);
		}
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

	function startCountdown(?overrideStop:Bool = false):Void
	{
		for (module in updateScript) {
			if (module.isAlive && module.exists('onStartCountdown')) {
				module.get('onStartCountdown')();
			}
		}

		var stopCount:Dynamic = callLua('onStartCountdown', []);
		inCutscene = false;
		if (stopCount != LuaState.stopFunc && !overrideStop || overrideStop) {
			talking = false;
			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			callLua('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (skipIntro)
			{
				swagCounter = 4;
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
						if (songHasInfo)
							songInfoBar.tweenText();
				}

				callLua('onCountdownTick', [swagCounter]); //For porting psych engine mods
				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
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

		if (PlayerPrefs.timeType != 'Disabled') {
			FlxTween.tween(timeBG, {alpha: 1}, 0.5);
			FlxTween.tween(timeBar, {alpha: 1}, 0.5);
			FlxTween.tween(timeText, {alpha: 1}, 0.5);
		}

		switch (curStage)
		{
			case 'tank':
				foregroundSprites.forEach(function(spr:TankBGSprite)
				{
					spr.dance();
				});
		}

		for (module in updateScript) {
		 	if (module.isAlive && module.exists('onSongStart'))
				module.get('onSongStart')();
		}

		callLua('onSongStart', []);
	}

	var debugNum:Int = 0;

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
			if (eventData.events != null)
				for (event in eventData.events)
					for (i in 0...event[1].length)
					{
						var event:Event = new Event(event[0], event[1][i][0], event[1][i][1], event[1][i][2]);
						songEvents.push(event);
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
				var playerData = Std.int(songNotes[1] / 4);
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var noteLane:Int = playerData;

				if (playerData > numbOfStrums)
					playerData = 0; //So no crash :)

				var gottaHitNote:Bool = false;
				var canHit:Bool = false;

				if (noteLane <= 2) {
					gottaHitNote = !section.mustHitSection;

					if (!gottaHitNote)
						switch (noteLane) {
							case 0:
								noteLane = 1;
							case 1 :
								noteLane = 0;
						}
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				if (daNoteData > -1) {
					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, Std.string(songNotes[3]), false, noteLane);
					swagNote.sustainLength = songNotes[2];
					swagNote.playerLane = playerLane;
					laneNotes[swagNote.strumID].push(swagNote);
					noteDataLanes[swagNote.strumID][swagNote.noteData].push(swagNote);
					swagNote.notePos = laneNotes[swagNote.strumID].length - 1;
					swagNote.scrollFactor.set();

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;

					unspawnNotes.push(swagNote);

					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, gottaHitNote, songNotes[3], false, noteLane);
						sustainNote.playerLane = playerLane;
						sustainNote.scrollFactor.set();
						laneSustains[sustainNote.strumID].push(sustainNote);
						if (daNoteData > -1) {
							unspawnNotes.push(sustainNote);
						}
					}

					if (swagNote.isPlayer && !swagNote.isSustainNote)
						totalNotes++;
				}
				else {
					#if desktop
					var event:Event = new Event(daStrumTime, songNotes[2], songNotes[3], songNotes[4]);
					songEvents.push(event);
					#end
				}
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

		for (i in 0...laneNotes.length) {
			laneNotes[i].sort(sortByShit);
			for (a in 0...noteDataLanes[i].length)
				noteDataLanes[i][a].sort(sortByShit); //Idk
		}


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

	public function regenStrums(){
		if (strumLines != null) {
			strumLines.forEach(function(strumline:Strum){
				strumLines.remove(strumline);
			});
		}

		if (SONG.numbPlayers <= 0)
			SONG.numbPlayers = 2;

		if (SONG.numbPlayers > 2)
		{

			numbOfStrums = SONG.numbPlayers;
			for (i in 0...SONG.numbPlayers){
				var playerNumb:Int = i + 1;
				var strumLine:Strum = new Strum(0, this, (playerNumb == playerLane ? bfNoteStyle : dadNoteStyle), null, PlayerPrefs.downscroll, i);
				strumLines.add(strumLine);
				for (i in 0...4)
					strumLineNotes.add(strumLine.strums.members[i]);
			}
		}
		else
		{
			numbOfStrums = 2;
			playerStrums = new Strum(0, this, bfNoteStyle, boyfriend, PlayerPrefs.downscroll, 1);
			opponentStrums = new Strum(0, this, dadNoteStyle, dad, PlayerPrefs.downscroll, 0);

			strumLines.add(opponentStrums);
			strumLines.add(playerStrums);
		}

		for (i in 0...strumLines.length) {
			if (strumLines.members[i].strumID != playerLane)
				strumLines.members[i].autoPlay = true;

			laneNotes.push([]);
			laneSustains.push([]);
			noteDataLanes.push([[], [], [], []]);

			//so no crash :)
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null) {
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
			callLua('onResume', []);

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

	public function moduleUpdate(elapsed:Float) {
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

		for (module in characterScripts) {
			if (module.isAlive && module.exists('onUpdate')) {
				module.get('onUpdate')(elapsed);
			}
		}
	}

	public function moduleUpdatePos(elapsed:Float) {
		for (module in updateScript) {
			if (module.isAlive && module.exists('onUpdatePost')) {
				module.get('onUpdatePost')(elapsed);
			}
		}

		for (noteModule in noteTypeScripts){
			if (noteModule.isAlive && noteModule.exists('onUpdatePost')) {
				noteModule.get('onUpdatePost')(elapsed);
			}
		}

		for (module in characterScripts) {
			if (module.isAlive && module.exists('onUpdatePost')) {
				module.get('onUpdatePost')(elapsed);
			}
		}
	}

	override public function update(elapsed:Float)
	{
		curElapsed = elapsed;

		moduleUpdate(elapsed);
		callLua('onUpdate', [elapsed]);

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

		if (persistentUpdate && paused)
			persistentUpdate = false;

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
				moveCam();
			else
				moveCam(true);
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

		if (health <= 0 && !practiceMode && !PlayerPrefs.botplay) {
			killPlayer();
			deathCounter += 1;
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				callLua('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]); //Sum more psych engine support

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.tooLate) {
					daNote.active = false;
					daNote.visible = false;
				}
				else {
					daNote.visible = true;
					daNote.active = true;
				}

				var isPlayer:Bool = daNote.isPlayer;
				var thirdPlayer:Bool = daNote.isThreePlayerNote;
				var isSustain:Bool = daNote.isSustainNote;
				var strumId:Int = daNote.strumID;
				var strumToGo:FlxTypedGroup<StaticArrow>;
				var modifiedX:Float = daNote.modifiedX;
				var goodHit:Bool = daNote.wasGoodHit;
				var prevNote:Note = daNote.prevNote;
				var mustPress:Bool = daNote.mustPress;
				var canBeHit:Bool = daNote.canBeHit;

				var sustainModifier:Float = 0;

				if (strumLines.members[strumId] != null)
					strumToGo = strumLines.members[strumId].strums;
				else
					strumToGo = opponentStrums.strums;

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

				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& ((daNote.strumID != playerLane) || (daNote.wasGoodHit || daNote.prevNote.wasGoodHit)))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if ((daNote.strumID == playerLane) && PlayerPrefs.botplay && canBeHit)
					goodNoteHit(daNote);

				if (goodHit && (daNote.strumID != playerLane))
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

				if (PlayerPrefs.downscroll)
					noteLate = (daNote.y >= strumLine.y + 106);
				else
					noteLate = (daNote.y < -daNote.height);

				if (noteLate && (daNote.strumID == playerLane))
				{
					if ((daNote.isSustainNote && !daNote.sustainHit || !daNote.isSustainNote) && !daNote.ignoreNote && !daNote.hitCauseMiss && !PlayerPrefs.botplay)
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

		if (!inCutscene) {
			keyShit();
			updateOpponentNote();
		}

		#if debug
		if (FlxG.keys.justPressed.ONE && !endingSong && !startingSong)
			endSong();
		if (FlxG.keys.justPressed.TWO && !endingSong && !startingSong)
			setSongTime(Conductor.songPosition + 10000);
		#end

		moduleUpdatePos(elapsed);
		callLua('onUpdatePost', [elapsed]);
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

		seenCutscene = false;
		canPause = false;
		deathCounter = 0;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore && !usedPractice && !PlayerPrefs.botplay) {
			Highscore.saveScore(SONG.song.toLowerCase(), songScore, diffText);
			Highscore.saveSongBeat(SONG.song);
		}

		var canStop:Dynamic = callLua('OnEndSong', []);

		if (canStop != LuaState.stopFunc) {
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

		if (!PlayerPrefs.botplay)
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

		if (!PlayerPrefs.botplay)
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

		if (curStage.startsWith('school'))
			rating.antialiasing = false;
		else
			rating.antialiasing = PlayerPrefs.antialiasing;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ratings/' + pixelShitPart1 + 'combo' + pixelShitPart2, "shared"));
		comboSpr.cameras = [camOverlay];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.antialiasing = PlayerPrefs.antialiasing;

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
				numScore.antialiasing = PlayerPrefs.antialiasing;
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

	public function updateOpponentNote():Void
	{
		for (i in 0...numbOfStrums) 
		{
			var possibleNotes:Array<Note> = [];
			var strumLine:Strum = strumLines.members[i];

			if (strumLine != null) 
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumID == strumLine.strumID && daNote.strumID != playerLane && !daNote.tooLate && !daNote.wasGoodHit)
					{
						// the sorting probably doesn't need to be in here? who cares lol
						possibleNotes.push(daNote);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
					}
				});

				if (possibleNotes.length > 0) 
				{
					var daNote = possibleNotes[0];

					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes) {
								//var randomGhost:Int = FlxG.random.int(0, 1);
								if (!possibleNotes[0].isSustainNote && possibleNotes[1].noteData != possibleNotes[0].noteData) { //Incase notes are stacked
									possibleNotes[0].canGhost = true; //Ghost thing
								}
							}

						}
					}
				}

				//Just used for ghosts
			}
		}
	}

	public function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		var upR = controls.NOTE_UP_R;
		var rightR = controls.NOTE_RIGHT_R;
		var downR = controls.NOTE_DOWN_R;
		var leftR = controls.NOTE_LEFT_R;

		var holdArray:Array<Bool> = [left, down, up, right];
		var pressArray:Array<Bool> = [leftP, downP, upP, rightP];
		var releaseArray:Array<Bool> = [leftR, downR, upR, rightR];

		if (PlayerPrefs.botplay) {
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if ((pressArray[2] || pressArray[3] || pressArray[1] || pressArray[0]) && !boyfriend.stunned && generatedMusic)
		{
			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit)
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

							if (!possibleNotes[0].isSustainNote && possibleNotes[1].noteData != possibleNotes[0].noteData) { //Incase notes are stacked
								possibleNotes[0].canGhost = true; //Ghost thing
							}

							controlArray = pressArray;

							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						var controlArray:Array<Bool> = [];

						controlArray = pressArray;

						if (controlArray[daNote.noteData])
							goodNoteHit(daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							var controlArray:Array<Bool> = [];

							controlArray = pressArray;
								
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
						}
					}
				}
				else // regular notes?
				{
					var controlArray:Array<Bool> = [];

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
				if (daNote.canBeHit && daNote.isSustainNote)
				{
					if (holdArray[daNote.noteData])
						goodNoteHit(daNote);
				}
			});
		}

		var strumLine:Strum = strumLines.members[playerLane];
		var bf:Character = strumLine.strumCharacter;
		strumLine.autoPlay = PlayerPrefs.botplay;

		if (bf != null) { //Character Shit
			bf.isPlayer = !strumLine.autoPlay;

			if (left || down || up || right)
				bf.holdTimer = 0;

			if (!strumLine.autoPlay)
			{
				if (bf.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left) {
					if (bf.animation.curAnim.name.startsWith('sing') && !bf.animation.curAnim.name.endsWith('miss')) {
						bf.dance();
					}
				}
			}
		}

		for (i in 0...strumLine.strums.length) {
			if (pressArray[i] && strumLine.strums.members[i].animation.curAnim.name != 'confirm')
				strumLine.strums.members[i].playAnim('pressed');
			if (releaseArray[i])
				strumLine.strums.members[i].playAnim('static');
		}
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		onNoteMiss(direction, daNote);

		if (daNote == null)
			health -= 0.05;
		else
			health -= daNote.healthLoss;

		if (combo > 5 && gf.animOffsets.exists('sad')) {
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

		var strumCharacter:Character = strumLines.members[playerLane].strumCharacter;

		if (strumCharacter != null) {
			switch (direction)
			{
				case 0:
					strumCharacter.playAnim('singLEFTmiss', true);
				case 1:
					strumCharacter.playAnim('singDOWNmiss', true);
				case 2:
					strumCharacter.playAnim('singUPmiss', true);
				case 3:
					strumCharacter.playAnim('singRIGHTmiss', true);
			}
		}

		postNoteMiss(direction, daNote);

		Ratings.onNoteHit('miss', (daNote != null ? daNote.isSustainNote : false)); //I know it says onNoteHit but idc
		callLua('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	public function onNoteMiss(direction:Int = 0, daNote:Note) { //Used for modules to update
		for (module in noteTypeScripts) {
			if (module.isAlive && module.exists('onNoteMiss'))
				module.get('onNoteMiss')(direction, daNote);
		}

		for (module in updateScript) {
			if (module.isAlive && module.exists('onNoteMiss'))
				module.get('onNoteMiss')(direction, daNote);
		}
	}

	public function postNoteMiss(direction:Int = 0, daNote:Note) {
		for (module in updateScript) {
			if (module.isAlive && module.exists('onNoteMissPost'))
				module.get('onNoteMissPost')(direction, daNote);
		}
		
		for (module in noteTypeScripts) {
			if (module.isAlive && module.exists('onNoteMissPost'))
				module.get('onNoteMissPost')(direction, daNote);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		var playerLaneReal:Int = playerLane;

		if (!note.wasGoodHit)
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

				strumLines.members[playerLane].strums.members[note.noteData].playAnim('confirm', true);

				return;
			}

			if (FlxG.save.data.hitsound && !note.isSustainNote) {
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

			note.noteHit = true;
			var nextSustain:Note = null;
			var nextNote:Note = null;

			if (laneNotes[note.strumID][note.notePos + 1] != null)
				nextNote = laneNotes[note.strumID][note.notePos + 1];

			var useAltAnim:Bool = false;

			if (note.noteType == 'Alt-Anim' || note.noteType == 'Alt Anim')
				useAltAnim = true;

			strumLines.members[playerLane].playCharAnim(note.noteData, useAltAnim, !note.noAnim, false, note.canGhost);
			strumLines.members[playerLane].strums.members[note.noteData].playAnim('confirm', true);

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (note.isSustainNote) {
				note.sustainHit = true;
			}

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

			callLua('goodNoteHit', [notes.members.indexOf(note), Math.round(Math.abs(note.noteData)), note.noteType, note.isSustainNote]);
			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function doGhost(char:Character, animName:String = '', isOpponent:Bool = true) {
		var ghost:FlxSprite = new FlxSprite(0, 0);
		var character:Character = char;
		var ghostSprite:FlxTypedGroup<FlxSprite> = dadGhosts;
		if (PlayerPrefs.playOpponent)
			isOpponent = !isOpponent;

		if (!isOpponent)
			ghostSprite = bfGhosts;

		var animData:Array<Dynamic> = character.animOffsets.get(animName);
		ghost.frames = character.frames;
		ghost.animation.copyFrom(character.animation);
		ghost.x = character.x;
		ghost.y = character.y;
		ghost.animation.play(animName, true);
		ghost.offset.set(animData[0], animData[1]);
		ghost.flipX = character.flipX;
		ghost.flipY = character.flipY;
		ghost.visible = character.visible;
		ghost.color = FlxColor.fromRGB(character.healthColors[0], character.healthColors[1], character.healthColors[2]);
		ghost.blend = LIGHTEN;
		ghostSprite.add(ghost);

		new FlxTimer().start(0.5, function(tmr:FlxTimer){
			//Ghost
			var ghostTween:FlxTween = FlxTween.tween(ghost, {alpha: 0}, 0.7, {
				ease: FlxEase.linear,
				onComplete: function(tween:FlxTween) {
					ghostSprite.remove(ghost);
				}
			});

		});
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
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20) {
			resyncVocals();
		}

		setLua('curStep', curStep);
		callLua('onStepHit', []);
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
				setLua('curBpm', Conductor.bpm);
				setLua('crochet', Conductor.crochet);
				setLua('stepCrochet', Conductor.stepCrochet);
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

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0 && PlayerPrefs.camCanZoom)
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

		for (i in 0...strumLines.length)
			strumLines.members[i].onBeat(curBeat);

		var gfIdle:Int = gf.idleOnBeat;

		if (curBeat % gfIdle == 0 && !gf.usedOnStrum)
			gf.dance();

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48) {
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

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
			lightningStrikeShit();
		}

		callLua('onBeatHit', [curBeat]);
	}

	var curLight:Int = 0;

	public function moveCam(isOpponent:Bool = false)
	{
		if (isOpponent) {
			camFollow.setPosition(dad.getMidpoint().x + 150 + dad.camOffset[0], 
			dad.getMidpoint().y - 100 + dad.camOffset[1]);

			if (SONG.song.toLowerCase() == 'tutorial' && isOpponent && dad.curCharacter == 'gf') {
				tweenCamIn();
			}
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x + 150 + boyfriend.camOffset[0] + 
			boyfriend.playerOffset[0], boyfriend.getMidpoint().y - 100 + boyfriend.camOffset[1] + 
			boyfriend.playerOffset[1]);
			if (SONG.song.toLowerCase() == 'tutorial' && dad.curCharacter == 'gf'){
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	public function opponentHit(daNote:Note)
	{
		var strumList:Strum = strumLines.members[daNote.strumID];

		daNote.noteHit = true;
		var nextNote:Note = null;

		if (laneNotes[daNote.strumID][daNote.notePos + 1] != null)
			nextNote = laneNotes[daNote.strumID][daNote.notePos + 1];

		var useAltAnim:Bool = false;

		if (daNote.noteType == 'Alt-Anim' || daNote.noteType == 'Alt Anim')
			useAltAnim = true;

		if (!daNote.isSustainNote) {
			if (nextNote != null && nextNote.strumTime == daNote.strumTime && !nextNote.isSustainNote)
				nextNote.canGhost = true;
		}

		if (strumList != null && !daNote.hitCauseMiss){
			strumList.strums.members[daNote.noteData].playAnim('confirm', true);
			strumList.playCharAnim(daNote.noteData, useAltAnim, !daNote.noAnim, true, daNote.canGhost);
		}

		callLua('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function callNoteSplash(noteData:Int, threePlayer:Bool = false){
        var daNote:FlxSprite = strumLines.members[playerLane].strums.members[noteData];

        spawnNoteSplash(daNote.x, daNote.y, noteData, threePlayer, noteSplashOverride);
    }

    public function spawnNoteSplash(x:Float, y:Float, noteData:Int, ?threePlayer:Bool = false, splashOverride:String = null) {
        var texture:String = 'noteSplashes';

        var splash:NoteSplash = splashGroup.recycle(NoteSplash);
        splash.addSplash(x, y, noteData, splashOverride);
        splashGroup.add(splash);
    }

	public function setCamZoom(zoom:Float) {
		defaultCamZoom = zoom;
	}

	public function destroyModules()
	{
		for (modules in updateScript) {
			modules.isAlive = false;
		}

		updateScript = [];
		
		for (modules in stageScripts) {
			modules.isAlive = false;
		}

		stageScripts = [];
		
		for (modules in noteTypeScripts) {
			modules.isAlive = false;
		}

		noteTypeScripts = [];
		
		for (modules in characterScripts) {
			modules.isAlive = false;
		}

		characterScripts = [];
	}

	public function addCamera(cam:FlxCamera, camID:String = '') {
		FlxG.cameras.add(cam);
		if (camID != null && camID != '')
			playStatecams.set(camID, cam);
	}

	public function cameraFromString(camName:String):FlxCamera {
		if (playStatecams.get(camName) == null)
			return camGame;

		return playStatecams.get(camName);
	}

	public static function addObject(object:ObjectType) {
		var obj:FlxObject = null;
		var variableName:String = '';
		if (object is String) {
			var name:String = object;
			if (moduleSprites.exists(name)) {
				var sprite:FlxSprite = moduleSprites.get(name);
				instance.add(sprite);
				addedSprites.set(name, true);
			}
			else if (gameObjects.exists(name)) {
				obj = gameObjects.get(name);
				variableName = name;
			}
		}
		else if (object is FlxSprite) {
			var sprite:FlxSprite = object;
			instance.add(sprite);
		}
		else if (object is FlxObject) {
			obj = object;
		}

		if (obj != null) {
			instance.add(obj);
			if (variableName != null && variableName != '')
				addedObjects.set(variableName, true);
		}
	}

	public static function setSpriteShader(sprite:SpriteType, shaderName:String) {
		#if desktop
		var gameSprite:FlxSprite = null;

		if (sprite is String) {
			var spriteID:String = sprite;
			if (moduleSprites.exists(spriteID))
				gameSprite = moduleSprites.get(spriteID);
		}
		else if (sprite is FlxSprite)
			gameSprite = sprite;

		if (gameSprite != null) {
			var shaderArgs:Array<String> = returnShader(shaderName);
			if (shaderArgs != null)
				gameSprite.shader = new FlxRuntimeShader(shaderArgs[0], shaderArgs[1]);
		}
		#end
	}

	public static function setCamShader(camID:String, name:String) {
		var camera:FlxCamera = playStatecams.get(name);

		if (camera != null) {
			var shaderThings:Array<String> = returnShader(name);
			camera.setFilters([new ShaderFilter(new FlxRuntimeShader(shaderThings[0], shaderThings[1]))]);
		}

		trace('Set Shader: ' + name + 'to Camera: ' + camID);
	}

	public static function removeSpriteShader(sprite:SpriteType, shaderName:String) {
		#if desktop
		var gameSprite:FlxSprite = null;

		if (sprite is String) {
			var spriteID:String = sprite;
			if (moduleSprites.exists(spriteID))
				gameSprite = moduleSprites.get(spriteID);
		}
		else if (sprite is FlxSprite)
			gameSprite = sprite;

		if (gameSprite != null) {
			gameSprite.shader = null;
		}
		#end
	}

	public static function returnShader(shaderName:String = null):Array<String> {
		var returnValue:Array<String> = null;

		#if desktop
		var dirs:Array<String> = [Paths.mods('shaders/'), Paths.getPreloadPath('shaders/')];
		if (!luaShaders.exists(shaderName)) {
			for (i in 0...dirs.length) {
				var fragFile:String = dirs[i] + shaderName + '.frag';
				var vertFile:String = dirs[i] + shaderName + '.vert';
				var fileExists:Bool = false;

				if (FileSystem.exists(fragFile)) {
					fragFile = File.getContent(fragFile);
					fileExists = true;
				}
				else
					fragFile = null;

				if (FileSystem.exists(vertFile)) {
					vertFile = File.getContent(vertFile);
					fileExists = true;
				}
				else
					vertFile = null;

				if (fileExists && !luaShaders.exists(shaderName)) {
					luaShaders.set(shaderName, [fragFile, vertFile]);
				}
			}
		}
		else
			if (luaShaders.get(shaderName) != null && luaShaders.get(shaderName).length > 0)
				returnValue = luaShaders.get(shaderName);
		#end

		return returnValue;
	}

	public static function makeAnimatedSprite(spriteID:String, imagePath:String, ?x:Float = 0, ?y:Float = 0, atlasType:String = 'sparrow') {
		spriteID = spriteID.replace('.', '');
		removeSprite(spriteID);
		var sprite:FlxSprite = new FlxSprite(x, y);
		switch (atlasType) {
			case 'sparrow':
				sprite.frames = Paths.getSparrowAtlas(imagePath);
			case 'packer':
				sprite.frames = Paths.getPackerAtlas(imagePath);
			default:
				sprite.frames = Paths.getSparrowAtlas(imagePath);
		}
		sprite.antialiasing = PlayerPrefs.antialiasing;
		PlayState.moduleSprites.set(spriteID, sprite);
	}

	public static function addAnimByPrefix(spriteID:String, anim:String, prefix:String, fps:Int = 24, loop:Bool = false) {
		var sprite:FlxSprite = null;
		sprite = moduleSprites.get(spriteID);

		if (sprite != null) {
			sprite.animation.addByPrefix(anim, prefix, fps, loop);
			if (sprite.animation.curAnim == null) {
				sprite.animation.play(anim, true);
			}
		} else{
			sprite = Reflect.getProperty(PlayState, spriteID);
			if (sprite != null) {
				sprite.animation.addByPrefix(anim, prefix, fps, loop);
				if (sprite.animation.curAnim == null) {
					sprite.animation.play(anim, true);
				}
			}
		}
	}

	public static function playSpriteAnim(spriteID:String, name:String, forced:Bool = false, ?reversed:Bool = false) {
		var sprite:FlxSprite = moduleSprites.get(spriteID);
		if (sprite != null) {
			if (sprite.animation.getByName(name) != null)
				sprite.animation.play(name, forced, reversed);
		}
	}

	public static function setScrollFactor(spriteID:String, x:Float, y:Float) {
		var sprite:FlxSprite = moduleSprites.get(spriteID);
		if (sprite != null)
			sprite.scrollFactor.set(x, y);
	}

	public static function removeSprite(id:String) {
		var sprite:FlxSprite = null;

		if (!moduleSprites.exists(id))
			return;

		sprite = moduleSprites.get(id);
		if (addedSprites.exists(id)) {
			if (sprite != null) {
				sprite.kill();
				sprite.destroy();
			}
			addedSprites.remove(id);
		}
	}

	public function killPlayer()
	{
		boyfriend.stunned = true;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		vocals.stop();
		FlxG.sound.music.stop();

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

	public function addBehindChar(object:FlxObject, name:String = 'girlfriend') {
		var index:Int = members.indexOf(gfGroup);

		switch (name) {
			case 'boyfriend':
				index = members.indexOf(boyfriendGroup);
			case 'girlfriend':
				index = members.indexOf(gfGroup);
			case 'opponent' | 'dad':
				index = members.indexOf(dadGroup);
			default:
				if (moduleCharacters.exists(name)) {
					var character = moduleCharacters.get(name);
					index = members.indexOf(character);
				}
		}

		insert(index, object);
	}
	
	public function getBehindPos():Int {
		var index:Int = members.indexOf(gfGroup);
		var dadIndex:Int = members.indexOf(dadGroup);
		var bfIndex:Int = members.indexOf(boyfriendGroup);

		if (bfIndex > index)
			index = bfIndex;

		if (dadIndex > bfIndex)
			index = dadIndex;
			
		return index;
	}

	public function callLua(func:String, args:Array<Dynamic>) {
		var returnValue:Dynamic = LuaState.continueFunc;
		for (luaScript in loadedScripts) {
			var value = luaScript.callFunc(func, args);

			if (value == LuaState.errorStop)
				break;

			if (value != null && (value != LuaState.errorStop || value != LuaState.continueFunc))
				returnValue = value;
			
		}

		return returnValue;
	}

	public function setLua(variable:String, data:Dynamic) {
		for (luaScript in loadedScripts) {
			luaScript.setVar(variable, data);
		}
	}

	public function startLuaScript(path:String) {
		#if desktop
		if (FileSystem.exists(path)) {
			loadedScripts.push(new LuaState(path));
		}
		#else
		if (Assets.exists(path)) {
			loadedScripts.push(new LuaState(path));
		}
		#end
	}

	public function changePlayerChar(newCharacter:String)
	{
		var lastAlpha:Float = boyfriend.alpha;
		boyfriend.alpha = 0.0001;
		if (!bfChars.exists(newCharacter))
		{
			var newChar:Boyfriend = new Boyfriend(0, 0, newCharacter);
			newChar.setPosition(boyfriendX + newChar.positionOffset[0], boyfriendY + newChar.positionOffset[1]);
			add(newChar);
			newChar.alpha = 0.00001;
			bfChars.set(newCharacter, newChar);
		}
		boyfriend = bfChars.get(newCharacter);
		boyfriend.alpha = lastAlpha;
		if (playerStrums != null)
			playerStrums.changeCharacter(boyfriend);
		else
			strumLines.members[playerLane].changeCharacter(boyfriend);
		iconP1.changeIcon(newCharacter, true, boyfriend.healthIconIsAnimated, boyfriend.healthIconAnim, boyfriend.healthIconLooped, boyfriend.iconScale);
	}

	public function changeOpponentChar(newCharacter:String)
	{
		var lastAlpha:Float = dad.alpha;
		dad.alpha = 0.0001;
		if (!dadChars.exists(newCharacter))
		{
			var newChar:Character = new Character(0, 0, newCharacter);
			newChar.setPosition(dadX + newChar.positionOffset[0], dadY + newChar.positionOffset[1]);
			add(newChar);
			newChar.alpha = 0.00001;
			dadChars.set(newCharacter, newChar);
		}
		dad = dadChars.get(newCharacter);
		dad.alpha = lastAlpha;
		if (opponentStrums != null)
			opponentStrums.changeCharacter(dad);
		else
			strumLines.members[0].changeCharacter(dad);
		iconP2.changeIcon(newCharacter, false, dad.healthIconIsAnimated, dad.healthIconAnim, dad.healthIconLooped, dad.iconScale);
	}

	public function changeGfChar(newCharacter:String)
	{
		var lastAlpha:Float = gf.alpha;
		gf.alpha = 0.0001;
		if (!gfChars.exists(newCharacter))
		{
			var newChar:Character = new Character(0, 0, newCharacter);
			newChar.setPosition(gfX + newChar.positionOffset[0], gfY + newChar.positionOffset[1]);
			add(newChar);
			newChar.alpha = 0.00001;
			startCharacterScript(newChar.curCharacter);
			gfChars.set(newCharacter, newChar);
		}
		if (strumLines.members[2] != null)
			strumLines.members[2].strumCharacter = gf;

		gf = gfChars.get(newCharacter);
		gf.alpha = lastAlpha;
	}

	public function pushCharToStrum(char:Character, strums:FlxTypedGroup<Strum>, id:Int, allStrums:Bool = false)
	{
		/*
			if (allStrums)
				for (i in 0...strums.length)
					strums.members[i].strumCharacter = char;
			else
				strums.members[id].strumCharacter = char;
		*/
	}

	public function pushModule(path:String = null, moduleType:String = '')
	{
		var splitPath:Array<String> = path.split('/');
		var moduleId:String = StringTools.replace(splitPath[splitPath.length - 1], '.hxs', '');
		switch (moduleType)
		{
			case 'Note' | 'note':
				var module = NoteModuleHandler.loadModule(path);
				noteTypeScripts.push(module);
			case 'Normal' | 'normal':
				var module = moduleHandler.loadModule(path, moduleId);
				updateScript.push(module);
			case 'Character' | 'character':
				var module = moduleHandler.loadModule(path, moduleId);
				characterScripts.push(module);
			default:
				var module = moduleHandler.loadModule(path, moduleId);
				updateScript.push(module);
		}
	}

	public static function addNotification(text:String)
		return Main.notifGroup.addNotification(text);
}

typedef SpriteType = OneOfTwo<String, FlxSprite>;
typedef ObjectType = OneOfThree<String, FlxSprite, FlxObject>;