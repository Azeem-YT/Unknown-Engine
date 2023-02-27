package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.graphics.frames.FlxFrame;
import Section.SwagSection;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end
import helpers.*;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharData =
{
	var framesPath:String;
	var flipX:Bool;
	var camOffset:Array<Float>;
	var playerOffset:Array<Float>; //Cam Offset for Player.
	var scale:Float;
	var healthIcon:String;
	var animatedIcon:Bool;
	var idleOnBeat:Int;
	var animations:Array<AnimData>;
	var positionOffset:Array<Float>;
	var healthColors:Array<Int>;
	var image:String; //If porting from psych engine
	var iconAnims:Array<String>;
	var iconIsLooped:Bool;
	var iconScale:Float;
	var portraitFrames:String;
	var portraitEnter:String;
	var portraitAnims:Array<PortraitData>;
	var portraitScale:Float;
	var deathCharacter:String;
	var deathSound:String;
	var noAntialiasing:Bool;
	var atlasType:String;
	var sing_duration:Dynamic;
}

typedef AnimData =
{
	var prefix:String;
	var anim:String;
	var indices:Array<Int>;
	var fps:Int;
	var loop:Bool;
	var offset:Array<Float>;
}

typedef PortraitData = 
{
	var prefix:String;
	var animName:String;
	var indices:Array<Int>;
	var loop:Bool;
	var fps:Int;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;

	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = default_character;

	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var stunned:Bool = false;
	public var danceIdle:Bool = false;
	public var idleDance:String = 'idle';
	public var canIdle:Bool = true;
	public var forceNoIdle:Bool = false;
	public var camOffset:Array<Float> = [0,0];
	public var animationNotes:Array<Dynamic> = [];
	public var positionOffset:Array<Float> = [0, 0];
	public var canSing:Bool = true;
	public var healthColors:Array<Int> = [128, 128, 128];
	public var idleOnBeat:Int = 2;
	public var singDuration:Float = 4;
	public var playerOffset:Array<Float> = [];
	public var usedOnStrum:Bool = false;
	public var ignoreList:Array<String> = ['idle', 'danceRight', 'danceLeft', 'singLEFT', 'singRIGHT', 'singDOWN', 'singUP'];

	public var healthIcon:String;

	public static var default_character:String = 'bf';

	public var data:CharData;
	public var healthIconIsAnimated:Bool = false;
	public var healthIconAnim:Array<String>;
	public var healthIconLooped:Bool;
	public var iconScale:Float = 1;

	public var animArray:Array<AnimData>;
	public var portraitArray:Array<PortraitData>;
	public var portraitEnter:String = null;
	public var deathCharacter:String = 'bf';
	public var deathSound:String = null;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		resetVars();

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'spooky':
				tex = Paths.getSparrowAtlas('spooky_kids_assets');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				addOffset("singUP", -20, 26);
				addOffset("singRIGHT", -130, -14);
				addOffset("singLEFT", 130, -10);
				addOffset("singDOWN", -50, -130);

				playAnim('danceRight');
			case 'monster':
				tex = Paths.getSparrowAtlas('Monster_Assets');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -30, -40);
				healthIcon = 'icon-monster';
				playAnim('idle');
			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('christmas/monsterChristmas');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -40, -94);
				healthIcon = 'icon-monster';
				playAnim('idle');

			case 'spirit':
				frames = Paths.getPackerAtlas('weeb/spirit');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -240);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -200, -280);
				addOffset("singDOWN", 170, 110);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('christmas/mom_dad_christmas_assets');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				addOffset('idle');
				addOffset("singUP", -47, 24);
				addOffset("singRIGHT", -1, -23);
				addOffset("singLEFT", -30, 16);
				addOffset("singDOWN", -31, -29);
				addOffset("singUP-alt", -47, 24);
				addOffset("singRIGHT-alt", -1, -24);
				addOffset("singLEFT-alt", -30, 15);
				addOffset("singDOWN-alt", -30, -27);

				playAnim('idle');

			case 'tankman':
				frames = Paths.getSparrowAtlas('characters/tankmanCaptain');
				quickAnimAdd("idle", "Tankman Idle Dance");
				if (isPlayer)
				{
					quickAnimAdd("singLEFTmiss", "Tankman Note Left MISS");
					quickAnimAdd("singRIGHTmiss", "Tankman Right Note MISS");
				}
				else
				{
					quickAnimAdd("singLEFTmiss", "Tankman Right Note MISS");
					quickAnimAdd("singRIGHTmiss", "Tankman Note Left MISS");
				}

				quickAnimAdd("singLEFT", "Tankman Right Note 1");
				quickAnimAdd("singRIGHT", "Tankman Note Left 1");

				quickAnimAdd("singUP", "Tankman UP note 1");
				quickAnimAdd("singDOWN", "Tankman DOWN note 1");
				quickAnimAdd("singUPmiss", "Tankman UP note MISS");
				quickAnimAdd("singDOWNmiss", "Tankman DOWN note MISS");
				quickAnimAdd("singDOWN-alt", "PRETTY GOOD");
				quickAnimAdd("singUP-alt", "TANKMAN UGH");
				
				addOffset('idle', 0, 0);
				addOffset('singUP', 24, 56);
				addOffset('singRIGHT', -1, -7);
				addOffset('singLEFT', 100, -14);
				addOffset('singDOWN', 98, -90);
				addOffset('singUPmiss', 53, 84);
				addOffset('singRIGHTmiss', -1, -3);
				addOffset('singLEFTmiss', -30, 16);
				addOffset('singDOWNmiss', 69, -99);
				addOffset('singUP-alt');
				addOffset('singDOWN-alt');

				playAnim("idle");

				flipX = true;

			default:
				var path = UnkownEngineHelpers.getCharJson(curCharacter);

				if (!FileSystem.exists(path))
				{
					curCharacter = 'bf';
					path = UnkownEngineHelpers.getCharJson(curCharacter);
				}

				data = Json.parse(File.getContent(path));

				var usingMod:Bool = false;

				if (data.framesPath == null && data.image != null)
					data.framesPath = data.image;

				switch (data.atlasType)
				{
					case 'packer':
						#if desktop
						frames = Paths.getModPackerAtlas(data.framesPath);
						if (frames == null)
						#end
							frames = Paths.getPackerAtlas(data.framesPath);
					default:
						#if desktop
						frames = Paths.getModSparrowAtlas(data.framesPath);
						if (frames == null)
						#end
							frames = Paths.getSparrowAtlas(data.framesPath);
				}

				if (data.camOffset != null && data.camOffset.length > 0)
					camOffset = data.camOffset;
					
				if (data.playerOffset != null && data.playerOffset.length > 0)
					playerOffset = data.playerOffset;
				
				if (data.healthIcon != null && data.healthIcon != '')
					healthIcon = data.healthIcon;
				else
					healthIcon = 'icon-face';

				healthIconIsAnimated = data.animatedIcon;

				if (healthIconIsAnimated){
					if (data.iconAnims != null)
						healthIconAnim = data.iconAnims;

					healthIconLooped = data.iconIsLooped;
					if (data.iconScale != 1)
						iconScale = data.iconScale;
				}

				portraitArray = data.portraitAnims;

				if (frames != null)
				{
					animArray = data.animations;

					positionOffset = data.positionOffset;

					if (animArray != null && animArray.length > 0)
					{
						for (anim in animArray)
						{
							if (anim.anim != null && anim.anim != "")
							{
								if (anim.indices != null && anim.indices.length > 0)
									animation.addByIndices(anim.prefix, anim.anim, anim.indices, "", anim.fps, anim.loop, data.flipX);
								else
									animation.addByPrefix(anim.prefix, anim.anim, anim.fps, anim.loop, data.flipX);

								if (anim.offset != null)
									addOffset(anim.prefix, anim.offset[0], anim.offset[1]);
								else
									addOffset(anim.prefix, 0, 0);
							}
						}
					}

					if (data.scale != 1)
						setGraphicSize(Std.int(width * data.scale));

					if (data.deathCharacter != null)
						deathCharacter = data.deathCharacter;

					if (data.deathSound != null)
						deathSound = data.deathSound;

					if (data.noAntialiasing)
						antialiasing = false;
					else
						antialiasing = true;

					idleOnBeat = data.idleOnBeat;

					if (data.healthColors != null && data.healthColors.length == 3)
						healthColors = data.healthColors;

					if (data.sing_duration != null)
						singDuration = data.sing_duration;
				}
				else
				{
					curCharacter = 'bf';

					frames = Paths.getSparrowAtlas('BOYFRIEND', "shared");
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);

					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

					animation.addByPrefix('scared', 'BF idle shaking', 24);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);

					playAnim('idle');

					flipX = true;
				}
		}

		if (healthIcon == null)
			healthIcon = 'icon-' + curCharacter;

		getIdle();
		dance();

		switch (curCharacter)
		{
			case 'pico-speaker':
				loadMappedAnims();
				playAnim('shoot1');
		}

		if (isPlayer)
			flipX = !flipX;

		if (idleOnBeat <= 0)
			idleOnBeat = 1;

		if (antialiasing)
			antialiasing = PlayerPrefs.antialiasing;

		updateHitbox();
	}

	public function loadOffsetFile(character:String)
	{
		var offset:Array<String> = CoolUtil.coolTextFile(Paths.txt('offsets/' + character + "Offsets"));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		} //Broken idk why
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (isPlayer) {
				if (animation.curAnim.name.startsWith('sing')) //Fix for opponent side option
					holdTimer += elapsed;
				else
					holdTimer = 0;
			}
			else {
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;
			}

			if (isPlayer) {
				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
					playAnim('idle', true);
			}

			if (animation.curAnim.name.startsWith("hey") || animation.curAnim.name.startsWith("hey")) {
				if (heyTimer >= Conductor.stepCrochet * 0.001 * 2) {
					dance();
					holdTimer = 0;
				}
			}

			if (!isPlayer && holdTimer >= Conductor.stepCrochet * 0.001 * singDuration) {
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'pico-speaker':
					forceNoIdle = true;

					if(animationNotes.length > 0 && Conductor.songPosition >= animationNotes[0][0])
					{
						var noteData:Int = 1;
						if(animationNotes[0][1] > 2) 
							noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}

					if (animation.curAnim != null)
						if (animation.curAnim.finished) 
							playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished && animation.curAnim != null)
					playAnim('danceRight');
			case 'tankman':
				if ((animation.curAnim.name == 'singDOWN-alt' || animation.curAnim.name == 'singUP-alt') && !animation.curAnim.finished && animation.curAnim != null)
					canIdle = false;
		}

		if (animation.curAnim != null) {
			if (animation.curAnim.finished && !canIdle)
				canIdle = true;

			if (animation.curAnim.finished && !ignoreList.contains(animation.curAnim.name))
				dance();
		}

		if (!ignoreList.contains(idleDance))
			ignoreList.push(idleDance);

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function getIdle()
	{
		switch (curCharacter)
		{
			case 'gf':
				danceIdle = true;
			case 'gf-christmas':
				danceIdle = true;
			case 'gf-car':
				danceIdle = true;
			case 'gf-pixel':
				danceIdle = true;
			case 'spooky':
				danceIdle = true;
			default:
				danceIdle = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);
		}
	}

	public function dance()
	{
		if (!debugMode && canIdle && !forceNoIdle)
		{
			if (danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight');
				else
					playAnim('danceLeft');
			}
			else
				playAnim(idleDance);
		}
	}

	public function playHey() {
		if (curCharacter == 'gf')
			playAnim("cheer", true);
		else
			playAnim("hey", true);

		heyTimer = 0.20;
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animOffsets.exists(AnimName) && animation.getByName(AnimName) != null)
		{
			animation.play(AnimName, Force, Reversed, Frame);

			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);

			if (curCharacter == 'gf')
			{
				if (AnimName == 'singLEFT')
				{
					danced = true;
				}
				else if (AnimName == 'singRIGHT')
				{
					danced = false;
				}

				if (AnimName == 'singUP' || AnimName == 'singDOWN')
				{
					danced = !danced;
				}
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(animPrefix:String, anim:String) {
		animation.addByPrefix(animPrefix, anim, 24, false);
	}

	public function loadMappedAnims()
	{
		var jsonData:Array<SwagSection> = Song.loadFromJson('picospeaker', 'stress').notes;
		for (section in jsonData)
		{
			for (picoNotes in section.sectionNotes)
			{
				animationNotes.push(picoNotes);
			}
		}

		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(noteSort);
	}

	public function setCanSing(value:Bool){ //Don't rlly need it but module can't find it so...
		canSing = value;
	}

	public function noteSort(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public function resetVars()
	{
		camOffset = [0,0];
		animationNotes = [];
		positionOffset = [0, 0];
		playerOffset = [0, 0];
		healthIconIsAnimated = false;
		healthIconAnim = [];
		healthIconLooped = false;
		iconScale = 1;
		portraitArray = [];
		portraitEnter = null;
		deathCharacter = 'bf';
		deathSound = null;
		idleDance = 'idle';
		healthIcon = null;
		idleOnBeat = 2;
		canSing = true;
		ignoreList = [idleDance, 'danceRight', 'danceLeft', 'singLEFT', 'singRIGHT', 'singDOWN', 'singUP'];
		animOffsets.clear();
	}
}
