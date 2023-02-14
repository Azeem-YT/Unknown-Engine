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
	public var strumID:Int = 0;
	public var sustainHit:Bool = false;
	public var notePos:Int = 0;
	public var canGhost:Bool = false;
	public var noteHit:Bool = true;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType:String = null;
	public var noAnim:Bool = false;
	public var modifiedNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	var playerStyle:String;
	var opponentStyle:String;
	public var curStyle:String = 'normal';
	public var isPlayer:Bool = false;
	public static var noteSkinPath:String = "NOTE_assets";

	//Module Stuff
	public var noteTypePath:String = "";
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
	public var modifiedX:Float = 0;
	public var playerLane:Int = 1;
	public var strumLane:Int = 0;

	function set_noteType(daNoteType:String)
	{
		if (daNoteType != "" && daNoteType != null && (daNoteType != 'none' || daNoteType != 'normal'))
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

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?isPlayer:Bool, noteType:String = 'none', ?inCharter:Bool = false, ?strumID:Int = 0)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.strumID = strumID;
		this.isPlayer = (this.strumID == playerLane);
		strumLane = this.strumID + 1;
		this.mustPress = isPlayer;
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

		if (noteData > 3)
			this.noteData = 3;

		var daStage:String = PlayState.curStage;

		if (PlayState.dadNoteStyle != null && !(this.strumID == playerLane))
			curStyle = PlayState.dadNoteStyle;
		else if (PlayState.bfNoteStyle != null && (this.strumID == playerLane))
			curStyle = PlayState.bfNoteStyle;

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
		if (strumID == playerLane)
		{
			switch (curStyle.toLowerCase())
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
					antialiasing = false;
					updateHitbox();
				case 'normal':	
					if (PlayState.strumLines.members[strumID] != null && PlayState.strumLines.members[strumID].strums.members[noteData] != null)
						frames = PlayState.strumLines.members[strumID].strums.members[noteData].frames;
					else
						frames = Paths.getSparrowAtlas("noteSkins/" + noteSkinPath, "shared");

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
					antialiasing = PlayerPrefs.antialiasing;
				default:
					if (PlayState.strumLines.members[strumID] != null && PlayState.strumLines.members[strumID].strums.members[noteData] != null)
						frames = PlayState.strumLines.members[strumID].strums.members[noteData].frames;
					else
						frames = Paths.getSparrowAtlas("noteSkins/" + noteSkinPath, "shared");

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
					antialiasing = PlayerPrefs.antialiasing;
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
					if (PlayState.strumLines.members[strumID] != null && PlayState.strumLines.members[strumID].strums.members[noteData] != null)
						frames = PlayState.strumLines.members[strumID].strums.members[noteData].frames;
					else
						frames = Paths.getSparrowAtlas("noteSkins/" + noteSkinPath, "shared");

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
					antialiasing = PlayerPrefs.antialiasing;
				default:
					if (PlayState.strumLines.members[strumID] != null && PlayState.strumLines.members[strumID].strums.members[noteData] != null)
						frames = PlayState.strumLines.members[strumID].strums.members[noteData].frames;
					else
						frames = Paths.getSparrowAtlas("noteSkins/" + noteSkinPath, "shared");

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
					antialiasing = PlayerPrefs.antialiasing;
			}
		}
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
		antialiasing = PlayerPrefs.antialiasing;
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
			if (PlayerPrefs.downscroll)
				angle = 180;

			noteScore * 0.2;
			alpha = 0.6;

			if (PlayerPrefs.middlescroll && !isPlayer && !inCharter)
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

	public function runGhostTimer() {
		canGhost = true;
		noAnim = true;
		new FlxTimer().start(0.05, function(tmr:FlxTimer){
			canGhost = false;
			noAnim = false;
		});	
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var canPress:Bool = (playerLane == strumID);
		isPlayer = canPress;

		if (canPress)
		{
			if (PlayState.usingBotPlay)
				canBeHit = (strumTime <= Conductor.songPosition);
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;

				if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset)
					tooLate = true;
			}
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