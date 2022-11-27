package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.system.*;
import flixel.util.*;
import flixel.*;
import flixel.text.*;
import flixel.math.*;
import flixel.graphics.*;
import UnkownModule.ModuleHandler;
import haxe.Exception;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import lime.utils.Assets;
import flixel.FlxG;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var ignoreNote = false;
	public var rating:String = "sick";

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType:String = null;
	public var noAnim:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	var playerStyle:String;
	var opponentStyle:String;
	public var curStyle:String;
	public var isPlayer:Bool = false;

	public static var currentNoteSkin:String = "Song Dependent";
	public static var noteSkinPath:String = "NOTE_assets";

	//Module Stuff
	public var noteTypePath:String = "NOTE_assets";
	public var noteXOffset:Float = 0;
	public var noteYOffset:Float = 0;
	public var healthGain:Float = 0.04;
	public var healthLoss:Float = 0.05;
	public var hitCauseMiss:Bool = false;

	public var customAnims:Bool = false;
	public var inCharter:Bool = false;

	public var daAnims:Array<String> = [];
	public var isThreePlayerNote:Bool = false;
	public var noteTypeSet:Bool = false;
	public var modifiedPos:Bool = false;

	function set_noteType(daNoteType:String)
	{
		if (daNoteType != "" && daNoteType != null && daNoteType != 'none')
		{
			switch (daNoteType)
			{
				case 'No Anim':
					noAnim = true;
				default:
					callNote(noteTypePath);
					noteType = daNoteType;
			}
		}
		else
		{
			loadDefaultNote();
			daNoteType = 'normal';
			noteType = daNoteType;
			return daNoteType;
		}

		return daNoteType;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?isPlayer:Bool, noteType:String = 'none', ?inCharter:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.isPlayer = isPlayer;
		this.inCharter = inCharter;

		if (noteType != null && noteType != "none" && noteType != "")
			this.noteType = noteType;
		else
		{
			this.noteType = 'normal';
			noteTypeSet = true;
		}

		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		if (PlayState.dadNoteStyle != null && !isPlayer)
			curStyle = PlayState.dadNoteStyle;
		else if (PlayState.bfNoteStyle != null && isPlayer)
			curStyle = PlayState.bfNoteStyle;
		else
			curStyle = 'normal';

		set_noteType(noteType);

		playNoteAnim();
	}

	function callNote(skinPath:String)
	{
		frames = Paths.getModSparrowAtlas(skinPath);
		
		if (frames == null)
			frames = Paths.getSparrowAtlas(skinPath);
			
		loadAnimations();

		if (frames == null) //if frames are still null then just load default note.
			loadDefaultNote();
	}

	function loadDefaultNote()
	{
		if (isPlayer)
		{
			switch (curStyle)
			{
				case 'pixel':
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);

					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);

					if (isSustainNote)
					{
						loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);

						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);

						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
				case 'normal':	
					if (FileSystem.exists(Paths.modImages('noteSkins/' + PlayState.SONG.notePlayerTexture)) && currentNoteSkin == "Song Dependent")
					{
						frames = Paths.getModSparrowAtlas('noteSkins/' + PlayState.SONG.notePlayerTexture);
					}
					else if (Assets.exists(Paths.image('noteSkins/' +PlayState.SONG.notePlayerTexture)) && currentNoteSkin == "Song Dependent")
					{
						frames = Paths.getSparrowAtlas('noteSkins/' + PlayState.SONG.notePlayerTexture);
					}
					else
					{
						frames = Paths.getSparrowAtlas("noteSkins/" + noteSkinPath);
					}

					animation.addByPrefix('greenScroll', 'green instance 1');
					animation.addByPrefix('redScroll', 'red instance 1');
					animation.addByPrefix('blueScroll', 'blue instance 1');
					animation.addByPrefix('purpleScroll', 'purple instance 1');

					animation.addByPrefix('purpleholdend', 'pruple end hold instance 1');
					animation.addByPrefix('greenholdend', 'green hold end instance 1');
					animation.addByPrefix('redholdend', 'red hold end instance 1');
					animation.addByPrefix('blueholdend', 'blue hold end instance 1');

					animation.addByPrefix('purplehold', 'purple hold piece instance 1');
					animation.addByPrefix('greenhold', 'green hold piece instance 1');
					animation.addByPrefix('redhold', 'red hold piece instance 1');
					animation.addByPrefix('bluehold', 'blue hold piece instance 1');

					animation.addByPrefix("eventNote", "arrow static instance 1");

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = FlxG.save.data.antialiasing;
				default:
					frames = Paths.getSparrowAtlas("noteSkins/" + noteSkinPath);

					animation.addByPrefix('greenScroll', 'green instance 1');
					animation.addByPrefix('redScroll', 'red instance 1');
					animation.addByPrefix('blueScroll', 'blue instance 1');
					animation.addByPrefix('purpleScroll', 'purple instance 1');

					animation.addByPrefix('purpleholdend', 'pruple end hold instance 1');
					animation.addByPrefix('greenholdend', 'green hold end instance 1');
					animation.addByPrefix('redholdend', 'red hold end instance 1');
					animation.addByPrefix('blueholdend', 'blue hold end instance 1');

					animation.addByPrefix('purplehold', 'purple hold piece instance 1');
					animation.addByPrefix('greenhold', 'green hold piece instance 1');
					animation.addByPrefix('redhold', 'red hold piece instance 1');
					animation.addByPrefix('bluehold', 'blue hold piece instance 1');

					animation.addByPrefix("eventNote", "arrow static instance 1");

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = FlxG.save.data.antialiasing;
			}
		}
		else
		{
			switch (curStyle)
			{
				case 'pixel':
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);

					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);

					if (isSustainNote)
					{
						loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);

						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);

						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
				case 'normal':
					if (FileSystem.exists(Paths.modImages(PlayState.SONG.noteOpponentTexture)) && currentNoteSkin == "Song Dependent")
						frames = Paths.getModSparrowAtlas(PlayState.SONG.noteOpponentTexture);
					else if (FileSystem.exists(Paths.image(PlayState.SONG.noteOpponentTexture)) && currentNoteSkin == "Song Dependent")
						frames = Paths.getSparrowAtlas(PlayState.SONG.noteOpponentTexture);
					else
						frames = Paths.getSparrowAtlas("noteSkins/" + noteSkinPath);

					animation.addByPrefix('greenScroll', 'green instance 1');
					animation.addByPrefix('redScroll', 'red instance 1');
					animation.addByPrefix('blueScroll', 'blue instance 1');
					animation.addByPrefix('purpleScroll', 'purple instance 1');

					animation.addByPrefix('purpleholdend', 'pruple end hold instance 1');
					animation.addByPrefix('greenholdend', 'green hold end instance 1');
					animation.addByPrefix('redholdend', 'red hold end instance 1');
					animation.addByPrefix('blueholdend', 'blue hold end instance 1');

					animation.addByPrefix('purplehold', 'purple hold piece instance 1');
					animation.addByPrefix('greenhold', 'green hold piece instance 1');
					animation.addByPrefix('redhold', 'red hold piece instance 1');
					animation.addByPrefix('bluehold', 'blue hold piece instance 1');

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = FlxG.save.data.antialiasing;
				default:
					frames = Paths.getSparrowAtlas("noteSkins/" + noteSkinPath);

					animation.addByPrefix('greenScroll', 'green instance 1');
					animation.addByPrefix('redScroll', 'red instance 1');
					animation.addByPrefix('blueScroll', 'blue instance 1');
					animation.addByPrefix('purpleScroll', 'purple instance 1');

					animation.addByPrefix('purpleholdend', 'pruple end hold instance 1');
					animation.addByPrefix('greenholdend', 'green hold end instance 1');
					animation.addByPrefix('redholdend', 'red hold end instance 1');
					animation.addByPrefix('blueholdend', 'blue hold end instance 1');

					animation.addByPrefix('purplehold', 'purple hold piece instance 1');
					animation.addByPrefix('greenhold', 'green hold piece instance 1');
					animation.addByPrefix('redhold', 'red hold piece instance 1');
					animation.addByPrefix('bluehold', 'blue hold piece instance 1');

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = FlxG.save.data.antialiasing;
			}
		}

		if (Main.gameSettings.getSettingBool("Middlescroll") && !isPlayer && !inCharter)
			alpha = 0;
	}

	public function loadAnimations()
	{
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		animation.addByPrefix('purpleholdend', 'pruple end hold');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');

		setGraphicSize(Std.int(width * 0.7));		
		updateHitbox();
		antialiasing = FlxG.save.data.antialiasing;
	}

	public function playNoteAnim()
	{
		switch (noteData)
		{
			case 0:
				animation.play('purpleScroll');
			case 1:
				animation.play('blueScroll');
			case 2:
				animation.play('greenScroll');
			case 3:
				animation.play('redScroll');
		}

		if (isSustainNote && prevNote != null)
		{
			if (Main.gameSettings.getSettingBool("Downscroll"))
				flipY = true;

			noteScore * 0.2;
			alpha = 0.6;

			if (Main.gameSettings.getSettingBool("Middlescroll") && !isPlayer && !inCharter)
				alpha = 0;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			if (curStyle == 'pixel')
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}

class NoteModuleHandler
{
	public static var parser:Parser;
	public static var vars:StringMap<Dynamic>;

	public function new(){
	}

	public static function setVars()
	{
		parser = new Parser();
		parser.allowTypes = true;

		vars = new StringMap<Dynamic>();

		vars.set("Sys", Sys);
		vars.set("Std", Std);
		vars.set("Conductor", Conductor);
		vars.set("MusicBeatState", MusicBeatState);
		vars.set("PlayState", PlayState);
		vars.set("Note", Note);
		vars.set("Paths", Paths);
		vars.set("StringTools", StringTools);
		vars.set("FlxG", FlxG);
		vars.set("FlxTimer", FlxTimer);
		vars.set("FlxSprite", FlxSprite);
		vars.set("FlxText", FlxText);
		vars.set("FlxMath", FlxMath);
		vars.set("Math", Math);
		vars.set("Bool", Bool);
		vars.set("String", String);
		vars.set("Float", Float);
		vars.set("Int", Int);
		vars.set("playSound", FlxG.sound.play);
	}

	public static function loadModule(path:String, ?params:StringMap<Dynamic>)
	{
		var daPath:String = path;

		if ((daPath != null || daPath != "") && FileSystem.exists(daPath))
			return new NoteModule(parser.parseString(File.getContent(daPath), daPath), params);
		else
			return null;
	}
}

class NoteModule
{
	public var interp:Interp;

	public var isAlive:Bool = true;

	public function new(?contents:Expr, ?params:StringMap<Dynamic>)
	{
		interp = new Interp();

		for (i in NoteModuleHandler.vars.keys())
			interp.variables.set(i, NoteModuleHandler.vars.get(i));

		interp.variables.set("exit", exit);
		interp.variables.set("exists", exists);
		interp.variables.set("get", get);
		interp.variables.set("set", set);

		interp.execute(contents);
	}

	public function exit():Dynamic
		return this.isAlive = false;

	public function get(field:String):Dynamic
		return interp.variables.get(field);

	public function set(field:String, value:Dynamic)
		interp.variables.set(field, value);

	public function exists(field:String):Bool
		return interp.variables.exists(field);
}