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
import LuaScript;
import openfl.utils.AssetType;
import UnkownModule.ModuleHandler;
import hxCodec.*;
#if sys
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

	public static var customSprites:Map<String, ModSprite> = new Map();
	public static var customTimer:Map<String, FlxTimer> = new Map();
	public static var customSounds:Map<String, FlxSound> = new Map();
	public static var customCharacters:Map<String, ModCharacter> = new Map();
	public static var customTweens:Map<String, FlxTween> = new Map();

	public static var boyfriendX:Float = 770;
	public static var boyfriendY:Float = 450;
	public static var gfX:Float = 400;
	public static var gfY:Float = 130;
	public static var dadX:Float = 100;
	public static var dadY:Float = 100;

	public static var oldboyfriendX:Float = 770;
	public static var oldboyfriendY:Float = 450;
	public static var oldgfX:Float = 400;
	public static var oldgfY:Float = 130;
	public static var olddadX:Float = 100;
	public static var olddadY:Float = 100;

	public static var strumLineY:Float;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<Strum>;
	public static var playerStrums:FlxTypedGroup<Strum>;
	public static var opponentStrums:FlxTypedGroup<Strum>;
	public static var gfStrums:FlxTypedGroup<Strum>;
	public static var splashGroup:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
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

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camUnderlay:FlxCamera;

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
	var songScore:Int = 0;
	var scoreTxt:FlxText;

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

	public static var luaArray:Array<LuaScript> = [];
	public var skipArrowTween:Bool = false;

	public static var dadNoteStyle:String;
	public static var bfNoteStyle:String;

	public static var updateScript:Array<UnkownModule> = [];

	public var songSpeed:Float = 1;
	public var curTime:Float = 0;

	public var timeText:FlxText;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var moduleHandler:ModuleHandler;

	override public function create()
	{
		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		if (FileSystem.exists(Paths.lua("data/" + PlayState.SONG.song.toLowerCase()  + "/script")))
		{
			luaArray.push(new LuaScript(Paths.lua("data/" + PlayState.SONG.song.toLowerCase()  + "/script")));
		}

		moduleHandler = new ModuleHandler();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camUnderlay = new FlxCamera();
		camUnderlay.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camUnderlay);
		FlxG.cameras.add(camHUD);

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

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

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
				case 'tutorial' | 'bopeeboo' | 'fresh' | 'dadbattle':
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

		var moduleDir:String = Paths.getPreloadPath('modules/playstate/');
		var songModuleDir:String = Paths.getPreloadPath('modules/songs/' + SONG.song.toLowerCase());

		var directorys:Array<String> = [Paths.getPreloadPath()];

		#if MODDING_ALLOWED
		directorys.push(Paths.getModPreloadPath());
		#end

		if (!usingStage)
		{
			for (dir in 0...directorys.length)
			{
				moduleDir = directorys[dir] + 'stages/';

				if (FileSystem.isDirectory(moduleDir))
				{

					for (file in FileSystem.readDirectory(moduleDir))
					{
						var path = haxe.io.Path.join([moduleDir, file]);
						if (file == curStage + '.hxs')
						{
							moduleHandler.loadModule(moduleDir + file);
						}
					}
				}
				else
				{
					trace("Stage Path Error, File most likely doesn't exist, Path is: " + moduleDir);
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
			case 'halloween':
			{
				curStage = 'spooky';
				halloweenLevel = true;

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

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
				FlxG.sound.list.add(trainSound);

				// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
				add(street);
					}
			case 'limo':
			{
				curStage = 'limo';
				defaultCamZoom = 0.90;

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
				tankSky = new TankBGSprite("tankSky", -400,-400 , 0, 0);
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
			} //Week 7. Week 7 uses a different class than FlxSprite???
		}

		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODDING_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new LuaScript(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}

		#if MODDING_ALLOWED
		var path:String = SONG.stage;
		var tracedPath:String = Paths.stageLua(path);
		if (FileSystem.exists(Paths.stageLua(path)))
		{
			trace("Custom Stage: " + path);
			luaArray.push(new LuaScript(Paths.stageLua(path)));
			if (!stageHasScript)
				stageHasScript = true;
		}
		trace(tracedPath);
		#end

		doCall('OnStageCreate', []);

		boyfriend = new Boyfriend(boyfriendX, boyfriendY, SONG.player1);

		if (boyfriend.frames == null)
		{
			boyfriend = new Boyfriend(boyfriendX, boyfriendY, 'bf');
			trace("Boyfriend character does not exists or has an error, sorry.");
		}

		gf = new Character(gfX, gfY, gfVersion);

		if (gf.frames == null)
		{
			gf = new Character(gfX, gfY, 'gf');
			trace("Gf character does not exists or has an error, sorry.");
		}

		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(dadX, dadY, SONG.player2);

		if (dad.frames == null)
		{
			dad = new Character(dadX, dadY, 'dad');
			trace("Dad character does not exists or has an error, sorry.");
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

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
			//case 'tank':
			//	add(foregroundSprites);
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

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		trace('Downscroll = ' + Main.gameSettings.getSettingBool("Downscroll"));

		if (Main.gameSettings.getSettingBool("Downscroll"))
		{
			strumLine.y = FlxG.height - 150;
		}

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

		if (Main.gameSettings.getSettingBool("Downscroll"))
			healthBarBG.y = 50;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 600, healthBarBG.y + 30, 0, "", 200);
		scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		timeText = new FlxText(FlxG.width / 2  - 248, 19 + 25, 400, "0:00", 60);
		timeText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeText.scrollFactor.set();
		timeText.alpha = 1;
		timeText.borderSize = 2;
		timeText.cameras = [camHUD];
		add(timeText); //Time Elapsed;

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
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

			if (FileSystem.isDirectory(songModuleDir))
			{
				for (file in FileSystem.readDirectory(songModuleDir))
				{
					var path = haxe.io.Path.join([songModuleDir, file]);
					if (sys.FileSystem.isDirectory(songModuleDir) && file.endsWith('.hxs'))
					{
						moduleHandler.loadModule(songModuleDir + file);
					}
				}
			}
			else
			{
				trace("Song Path Error, File most likely doesn't exist, Path is: " + songModuleDir);
			}

			if (FileSystem.isDirectory(moduleDir))
			{
				trace(moduleDir);

				for (file in FileSystem.readDirectory(moduleDir))
				{
					var path = haxe.io.Path.join([moduleDir, file]);
					if (sys.FileSystem.isDirectory(moduleDir) && file.endsWith('.hxs'))
					{
						moduleHandler.loadModule(moduleDir + file);
					}
				}
			}
			else
			{
				trace("Path Error, File most likely doesn't exist, Path is: " + moduleDir);
			}
		}

		if (isStoryMode)
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

		doCall('OnCreate', []);

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
					FlxG.switchState(new StoryMenuState());
				else
				{
					SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase());
					FlxG.switchState(new PlayState());
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

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;


		var swagCounter:Int = 0;

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

		if (!paused)
			if (FileSystem.exists(Paths.modinst(SONG.song.toLowerCase())))
			{
				FlxG.sound.playMusic(Paths.modinst(PlayState.SONG.song.toLowerCase()), 1, false);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song.toLowerCase()), 1, false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end

		switch (curStage)
		{
			case 'tank':
				foregroundSprites.forEach(function(spr:TankBGSprite)
				{
					spr.defaultDance();
				});
		}

		setLuaVar('songLength', songLength);
		doCall('onSongStart', []);
	}

	var debugNum:Int = 0;

	public var realHitNote:Bool;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		songSpeed = songData.speed;

		if (SONG.needsVoices)
			if (FileSystem.exists(Paths.modvoices(PlayState.SONG.song)))
				vocals = new FlxSound().loadEmbedded(Paths.modvoices(PlayState.SONG.song));
			else 
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

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

				var isThirdPlayer:Bool= false;

				if (playerData > 7 && songData.threePlayer)
					isThirdPlayer = true;
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, (isThirdPlayer ? false : gottaHitNote), songNotes[3]);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				if (SONG.threePlayer)
				{
					swagNote.isThreePlayerNote = (playerData > 7);
					if (swagNote.isThreePlayerNote)
					{
						swagNote.canBeHit = false;
						swagNote.mustPress = false;
					}
					swagNote.scale.x = 0.6;
					swagNote.scale.y = 0.6;
				}

				if (daNoteData > -1)
				{
					unspawnNotes.push(swagNote);
				}

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, (isThirdPlayer ? false : gottaHitNote), songNotes[3]);
					sustainNote.scrollFactor.set();
					if (SONG.threePlayer)
					{
						sustainNote.isThreePlayerNote = (playerData > 7);
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

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2 + sustainNote.noteXOffset; // general offset
					}
				}

				swagNote.mustPress = (isThirdPlayer ? false : gottaHitNote);

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateOpponentStaticArrows(?threePlayer:Bool = false):Void
	{
		for (i in 0...4)
		{
			var noteTextureString:String;

			var babyArrow:Strum = new Strum((Main.gameSettings.getSettingBool("Middlescroll") ? -278 : 0), strumLine.y, i, false);

			switch (SONG.noteOpponentTexture)
			{
				case 'pixel':
					noteTextureString = 'pixel';
				case 'normal':
					noteTextureString = 'normal';
				default:
					noteTextureString = 'normal';
			}

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

					switch (Math.abs(i))
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

					switch (Math.abs(i))
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
					if (FileSystem.exists(Paths.modImages(SONG.noteOpponentTexture)))
						babyArrow.frames = Paths.getSparrowAtlas(SONG.noteOpponentTexture); //If you want to set a image path instead.
					else
						babyArrow.frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
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

			if (!isStoryMode && !skipArrowTween)
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (!skipArrowTween)
			{
				babyArrow.alpha = 1;
				babyArrow.y -= 10;
			}

			opponentStrums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * 0);

			if (Main.gameSettings.getSettingBool("Middlescroll"))
				babyArrow.x -= 300;

			if (threePlayer)
			{
				switch (i)
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

			strumLineNotes.add(babyArrow);

			babyArrow.characterToPlay.push(dad);
		}
	}

	private function generatePlayerStaticStaticArrows(?threePlayer:Bool = false):Void
	{
		for (i in 0...4)
		{
			var noteTextureString:String;

			var babyArrow:Strum = new Strum((Main.gameSettings.getSettingBool("Middlescroll") ? -278 : 0), opponentStrums.members[i].y, i, true);

			switch (SONG.noteOpponentTexture)
			{
				case 'pixel':
					noteTextureString = 'pixel';
				case 'normal':
					noteTextureString = 'normal';
				default:
					noteTextureString = '';
			}

			bfNoteStyle = noteTextureString;

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

					switch (Math.abs(i))
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

					switch (Math.abs(i))
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
					if (FileSystem.exists(Paths.modImages(SONG.noteOpponentTexture)))
						babyArrow.frames = Paths.getSparrowAtlas(SONG.noteOpponentTexture); //If you want to set a image path instead.
					else
						babyArrow.frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
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

			if (!isStoryMode && !skipArrowTween)
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (skipArrowTween)
			{
				babyArrow.alpha = 1;
				babyArrow.y -= 10;
			}

			playerStrums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * 1);

			if (threePlayer)
			{
				switch (i)
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

			strumLineNotes.add(babyArrow);

			babyArrow.characterToPlay.push(boyfriend);
		}
	}

	private function generateGfStaticArrows():Void
	{
		for (i in 0...4)
		{
			var noteTextureString:String;

			var babyArrow:Strum = new Strum(0, strumLine.y, i, false);

			switch (SONG.noteOpponentTexture)
			{
				case 'pixel':
					noteTextureString = 'pixel';
				case 'normal':
					noteTextureString = 'normal';
				default:
					noteTextureString = 'normal';
			}

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

					switch (Math.abs(i))
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

					switch (Math.abs(i))
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
					if (FileSystem.exists(Paths.modImages(SONG.noteOpponentTexture)))
						babyArrow.frames = Paths.getSparrowAtlas(SONG.noteOpponentTexture); //If you want to set a image path instead.
					else
						babyArrow.frames = Paths.getSparrowAtlas('noteSkins/NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
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

			if (!isStoryMode && !skipArrowTween)
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (!skipArrowTween)
			{
				babyArrow.alpha = 1;
				babyArrow.y -= 10;
			}

			babyArrow.scale.x = 0.6;
			babyArrow.scale.y = 0.6;

			gfStrums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * 0.5);

			switch (i)
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

			strumLineNotes.add(babyArrow);

			babyArrow.characterToPlay.push(gf);
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

	public function camFollowChar(char:Character, xOffset:Float = 150, yOffset:Float = 100, cancel:Bool = false, isDad:Bool = false)
	{
		if (cancel)
			cancelOutCharFollow = true;

		camFollow.setPosition(char.getMidpoint().x + xOffset, char.getMidpoint().y - yOffset);

		if (isDad)
		{
			switch (char.curCharacter)
			{
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
				case 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}
		}

		if (char.curCharacter == 'mom' && isDad)
			vocals.volume = 1;

		if (SONG.song.toLowerCase() == 'tutorial' && isDad && char.curCharacter == 'gf')
		{
			tweenCamIn();
		}
	}

	public function camFollowBF(char:Character, xOffset:Float, yOffset:Float)
	{
		camFollow.setPosition(char.getMidpoint().x - xOffset, char.getMidpoint().y - yOffset);

		switch (curStage)
		{
			case 'limo':
				camFollow.x = boyfriend.getMidpoint().x - 300;
			case 'mall':
				camFollow.y = boyfriend.getMidpoint().y - 200;
			case 'school':
				camFollow.x = boyfriend.getMidpoint().x - 200;
				camFollow.y = boyfriend.getMidpoint().y - 200;
			case 'schoolEvil':
				camFollow.x = boyfriend.getMidpoint().x - 200;
				camFollow.y = boyfriend.getMidpoint().y - 200;
		}

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

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	public var cancelOutCharFollow:Bool = false;

	override public function update(elapsed:Float)
	{
		doCall('OnUpdate', [elapsed]);
		setLuaVar("cancelOutCharFollow", cancelOutCharFollow);

		curElapsed = elapsed;

		for (module in updateScript) {
			if (module.isAlive && module.exists('onUpdate')) {
				module.get('onUpdate')(elapsed);
				trace("Les Goooooo");
			} else
				updateScript.splice(updateScript.indexOf(module), 1);
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

		recalculateRating();

		var healthPercent:Float = health * 50;

		if (healthPercent > 100)
			healthPercent = 100;

		scoreTxt.text = 'SCORE: ' + songScore + ' | MISSES: ' + misses + ' | HEALTH: ' + healthPercent + ' % | RATING: ' + RatingString;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
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
					var minutes:Float = 0;

					while (numbSeconds > 59)
					{
						numbSeconds -= 60;
						minutes += 1;
					}

					if (numbSeconds < 10)
						timeText.text = minutes + ":0" + numbSeconds;
					else
						timeText.text = minutes + ":" + numbSeconds;

				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !cancelOutCharFollow)
			{
				camFollowChar(dad, 150 + dad.camOffset[0], 100 + dad.camOffset[1], false, true);
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100 && !cancelOutCharFollow)
			{
				camFollowBF(boyfriend, 100 + boyfriend.camOffset[0], 100 + boyfriend.camOffset[1]);
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
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
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

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

				if (Main.gameSettings.getSettingBool("Downscroll"))
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(songSpeed, 2)));
				else
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(songSpeed, 2)));

				if (daNote.isThreePlayerNote)
				{
					daNote.x = gfStrums.members[daNote.noteData].x;
				}
				else if (daNote.isSustainNote)
				{
					daNote.x = (daNote.isPlayer ? playerStrums.members[daNote.noteData].x + 37 : opponentStrums.members[daNote.noteData].x + 37);
				}
				else
					daNote.x = (daNote.isPlayer ? playerStrums.members[daNote.noteData].x : opponentStrums.members[daNote.noteData].x);

				//Why wasn't this a thing?

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) || daNote.isSustainNote && daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2 && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && daNote.isThreePlayerNote)
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit || !daNote.mustPress && daNote.wasGoodHit && daNote.isThreePlayerNote)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";
					var useAltAnim:Bool = false;

					if (daNote.noteType == 'Alt-Anim')
					{
						useAltAnim = true;
					}

					if (daNote.isThreePlayerNote && SONG.threePlayer)
					{
						gfStrums.members[daNote.noteData].playCharAnim(useAltAnim);
					}
					else
					{
						opponentStrums.members[daNote.noteData].playCharAnim(useAltAnim);

						dad.holdTimer = 0;
					}

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (usingBotPlay && daNote.mustPress)
				{
					daNote.rating = "sick";
					goodNoteHit(daNote);
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed)); !Main.gameSettings.getSettingBool("Downscroll")

				if ((daNote.y < -daNote.height && !Main.gameSettings.getSettingBool("Downscroll") || daNote.y >= strumLine.y + 106 && Main.gameSettings.getSettingBool("Downscroll")) && daNote.mustPress)
				{
					if ((daNote.tooLate || !daNote.wasGoodHit) && !daNote.ignoreNote && !daNote.hitCauseMiss && !usingBotPlay && !daNote.isThreePlayerNote)
					{
						vocals.volume = 0;
						noteMiss(daNote.noteData, daNote);
					}
					else if (usingBotPlay)
					{
						daNote.rating = "sick";
						goodNoteHit(daNote);
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
		{
			setSongTime(Conductor.songPosition + 10000);
			clearNotes(Conductor.songPosition);
		}
		#end

		for (i in 0...opponentStrums.length)
		{
			opponentStatic(i);
		}

		if (SONG.threePlayer)
		{
			for (i in 0...gfStrums.length)
			{
				gfStatic(i);
			}
		}

		doCall('OnUpdatePost', [elapsed]);
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
	}

	public function clearNotes(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = false;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = false;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function recalculateRating()
	{
		if (misses == 0 && sicks > 0 && goods == 0 && bads == 0 && shits == 0)
			RatingString = 'PFC';
		if (misses == 0 && goods > 0)
			RatingString = 'GFC';
		if (misses == 0 && bads > 0)
			RatingString = 'FC';
		if (misses <= 9 && misses > 0)
			RatingString = 'SDCB';
		if (misses > 10)
			RatingString = 'CLEAR';
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
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

				FlxG.switchState(new StoryMenuState());

				StoryMenuState.setUnlocked(weekName);

				if (SONG.validScore) 
				{
					Highscore.saveWeekScore(weekName, campaignScore, storyDifficulty);
				}
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

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
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 0;

		var daRating:String = "sick";

		if (!usingBotPlay)
		{
			if (noteDiff > Conductor.safeZoneOffset * 0.75)
			{
				daNote.rating = 'shit';
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.5)
			{
				daNote.rating = 'bad';
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.25)
			{
				daNote.rating = 'good';
			}

			switch (daNote.rating)
			{
				case "shit":
					score = 50;
					shits++;
				case "bad":
					score = 100;
					bads++;
				case "good":
					score = 200;
					goods++;
				case "sick":
					score = 350;
					sicks++;
					callNoteSplash(daNote.noteData, (SONG.threePlayer ? true : false));
			}
		}

		songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daNote.rating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
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
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
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

	private function keyShit():Void
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

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		if (usingBotPlay)
		{
			controlArray = [false, false, false, false];
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
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

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (!daNote.isThreePlayerNote)
				{
					if (perfectMode)
						noteCheck(true, daNote);

					// Jump notes
					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes)
							{
								if (controlArray[coolNote.noteData])
								{
									goodNoteHit(coolNote);
								}
								else
								{
									var inIgnoreList:Bool = false;
									for (shit in 0...ignoreList.length)
									{
										if (controlArray[ignoreList[shit]])
											inIgnoreList = true;
									}
								}
							}
						}
						else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						{
							noteCheck(controlArray[daNote.noteData], daNote);
						}
						else
						{
							for (coolNote in possibleNotes)
							{
								noteCheck(controlArray[coolNote.noteData], coolNote);
							}
						}
					}
					else // regular notes?
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
				}
			}
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote && !daNote.isThreePlayerNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
							{
								goodNoteHit(daNote);
							}
						case 1:
							if (down)
							{
								goodNoteHit(daNote);
							}
						case 2:
							if (up)
							{
								goodNoteHit(daNote);
							}
						case 3:
							if (right)
							{
								goodNoteHit(daNote);
							}
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left || usingBotPlay)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}

		if (usingBotPlay)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.tooLate)
				{
					daNote.tooLate = false;
					daNote.rating = "sick";
					goodNoteHit(daNote); 
				}
			});
		}

		for (i in 0...playerStrums.length)
		{
			switch (i)
			{
				case 0:
					if (leftP && playerStrums.members[i].animation.curAnim.name != 'confirm')
						playerStrums.members[i].animation.play('pressed');
					if (leftR)
						playerStatic(0);
				case 1:
					if (downP && playerStrums.members[i].animation.curAnim.name != 'confirm')
						playerStrums.members[i].animation.play('pressed');
					if (downR)
						playerStatic(1);
				case 2:
					if (upP && playerStrums.members[i].animation.curAnim.name != 'confirm')
						playerStrums.members[i].animation.play('pressed');
					if (upR)
						playerStatic(2);
				case 3:
					if (rightP && playerStrums.members[i].animation.curAnim.name != 'confirm')
						playerStrums.members[i].animation.play('pressed');
					if (rightR)
						playerStatic(3);
			}

			if (playerStrums.members[i].animation.curAnim.name == 'confirm' && bfNoteStyle != 'pixel')
			{
				playerStrums.members[i].centerOffsets();
				playerStrums.members[i].offset.x -= 13;
				playerStrums.members[i].offset.y -= 13;
			}
			else
				playerStrums.members[i].centerOffsets();
		}
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
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
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
		{
			goodNoteHit(note);
		}
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

				return;
			}

			if (FlxG.save.data.hitsound && !note.isSustainNote)
			{
				FlxG.sound.play(UnkownEngineHelpers.getCustomPath('sounds/hitsound', SOUND));
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

			playerStrumAnim(note.noteData);

			note.wasGoodHit = true;
			vocals.volume = 1;

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
		setLuaVar("curStep", curStep);
		doCall("stepHit", [curStep]);

		for (module in updateScript) {
			if (module.isAlive && module.exists('onStepHit')) {
				module.get('onStepHit')(curStep);
			} else
				updateScript.splice(updateScript.indexOf(module), 1);
		}

		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		setLuaVar('curBeat', curBeat);
		doCall('beatHit', [curBeat]);

		for (module in updateScript) {
			if (module.isAlive && module.exists('onBeatHit')) {
				module.get('onBeatHit')(curBeat);
				trace("Les Goooooo BEATHIT");
			} else
				updateScript.splice(updateScript.indexOf(module), 1);
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
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
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
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend != null)
		{
			boyfriend.dance();
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'tank':
				tankWatchtower.defaultDance();

				foregroundSprites.forEach(function(spr:TankBGSprite)
				{
					spr.defaultDance();
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

	public function doCall(daFunction:String, args:Array<Dynamic>):Dynamic {
		var returnThing:Dynamic = 0;
		for (i in 0...luaArray.length){
			var fuck = luaArray[i].call(daFunction, args);
			if (fuck != null)
			{
				returnThing = fuck;
			}
		}

		return returnThing;
	}

	public function setLuaVar(variable:String, arg:Dynamic) {
		for (i in 0...luaArray.length) {
			luaArray[i].setVariable(variable, arg);
		}
	}

	function dadStrumAnim(id:Int)
	{
		opponentStrums.members[id].animation.play('confirm');
	}

	function playerStrumAnim(id:Int)
	{
		playerStrums.members[id].animation.play('confirm', true);
	}
	
	function gfStrumAnim(id:Int)
	{
		gfStrums.members[id].animation.play('confirm');
	}

	function playerStatic(id:Int)
	{
		playerStrums.members[id].animation.play('static');
	}
	
	function opponentStatic(id:Int)
	{
		opponentStrums.members[id].animation.play('static');
	}
	
	function gfStatic(id:Int)
	{
		gfStrums.members[id].animation.play('static');
	}

	public function changePlayerChar(newChar:String)
	{
		var boyfriendX = boyfriend.x;
		var boyfriendY = boyfriend.y;
		remove(boyfriend);
		boyfriend = new Boyfriend(boyfriendX, boyfriendY, newChar);
		add(boyfriend);
		iconP1.changeIcon(newChar);
	}

	public function changeOpponentChar(newChar:String)
	{
		var dadX = dad.x;
		var dadY = dad.y;
		remove(dad);
		dad = new Character(dadX, dadY, newChar);
		instance.add(PlayState.dad);
		iconP2.changeIcon(newChar);
	}

	public function changeGfChar(newChar:String)
	{
		var gfX = PlayState.gf.x;
		var gfY = PlayState.gf.y;
		PlayState.instance.remove(PlayState.gf);
		PlayState.gf = new Character(gfX, gfY, newChar);
		PlayState.instance.add(PlayState.gf);
	}

	function callNoteSplash(noteData:Int, threePlayer:Bool = false){
        var daNote:FlxSprite = playerStrums.members[noteData];

        spawnNoteSplash(daNote.x, daNote.y, noteData, threePlayer);
    }

    public function spawnNoteSplash(x:Float, y:Float, noteData:Int, ?threePlayer:Bool = false) {
        var texture:String = 'noteSplashes';

        var splash:NoteSplash = splashGroup.recycle(NoteSplash);
        splash.addSplash(x, y, noteData, threePlayer);
        splashGroup.add(splash);
    }
}