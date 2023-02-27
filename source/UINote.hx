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
import haxe.Exception;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import lime.utils.Assets;
import flixel.FlxG;
import shaderslmfao.ColorSwap;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class UINote extends FlxSprite //Just Used for UI stuff like color swap menu.
{
	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var tooLate:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;
	public var colorSwap:ColorSwap;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var curStyle:String = 'normal';
	public var isPlayer:Bool = false;

	public static var arrowColors:Array<Float> = [1, 1, 1, 1];

	public function new(strumTime:Float = 0, noteData:Int = 0) {
		super();

		this.isPlayer = false;
		this.strumTime = strumTime;
		this.noteData = noteData;

		if (noteData > 3)
			this.noteData = 3;

		callNote();

		playNoteAnim();
	}

	function callNote()
	{
		frames = Paths.getSparrowAtlas("noteSkins/NOTE_assets", "shared");

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

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		updateColors();
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
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (tooLate) {
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public function updateColors():Void {
		colorSwap.update(arrowColors[noteData]);
	}
}