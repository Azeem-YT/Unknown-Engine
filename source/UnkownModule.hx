package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import haxe.Exception;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.GraphicsShader;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import flixel.graphics.tile.FlxGraphicsShader;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import helpers.*;

/* 
	you can pretty much just edit in-game variables and make your own events
*/
class ModuleHandler
{
	public static var parser:Parser;
	public static var vars:StringMap<Dynamic>;

	public function new()
	{
	
	}

	public function setVars()
	{
		parser = new Parser();

		parser.allowTypes = true;

		vars = new StringMap<Dynamic>();

		vars.set("Sys", Sys);
		vars.set("Std", Std);
		vars.set("FlxMath", FlxMath);
		vars.set("Conductor", Conductor);
		vars.set("MusicBeatState", MusicBeatState);
		vars.set("PlayState", PlayState);
		vars.set("Note", Note);
		vars.set("Paths", Paths);
		vars.set("Character", Character);
		vars.set("Boyfriend", Boyfriend);
		vars.set("StringTools", StringTools);
		vars.set("FlxG", FlxG);
		vars.set("FlxTimer", FlxTimer);
		vars.set("FlxTween", FlxTween);
		vars.set("FlxEase", FlxEase);
		vars.set("FlxSprite", FlxSprite);
		vars.set("TankBGSprite", TankBGSprite);
		vars.set("Bool", Bool);
		vars.set("String", String);
		vars.set("Float", Float);
		vars.set("Int", Int);
		vars.set("Array", Array);
		vars.set("ShaderFilter", ShaderFilter);
		vars.set("FlxGraphicShader", FlxGraphicsShader);
		vars.set("Control-LEFT", PlayState.instance.controls.LEFT);
		vars.set("Control-DOWN", PlayState.instance.controls.DOWN);
		vars.set("Control-UP", PlayState.instance.controls.UP);
		vars.set("Control-RIGHT", PlayState.instance.controls.RIGHT);
		vars.set("Control-UI_LEFT", PlayState.instance.controls.UI_LEFT);
		vars.set("Control-UI_DOWN", PlayState.instance.controls.UI_DOWN);
		vars.set("Control-UI_UP", PlayState.instance.controls.UI_UP);
		vars.set("Control-UI_RIGHT", PlayState.instance.controls.UI_RIGHT);
		vars.set("curBeat", PlayState.instance.curBeat);
		vars.set("curStep", PlayState.instance.curStep);
		vars.set("elapsed", PlayState.curElapsed);
		vars.set("loadModule", loadModule);
		vars.set("setClassVar", PlayState.setClassVar);
		vars.set("getClassVar", PlayState.getClassVar);
		vars.set("playSound", FlxG.sound.play);
		vars.set("add", PlayState.instance.add);
		vars.set("remove", PlayState.instance.remove);
		vars.set("boyfriend", PlayState.boyfriend);
		vars.set("dad", PlayState.dad);
		vars.set("gf", PlayState.gf);
	}

	public function loadModule(path:String, ?params:StringMap<Dynamic>)
	{
		var daPath:String = path;

		if ((daPath != null || daPath != "") && FileSystem.exists(daPath))
			return new UnkownModule(parser.parseString(File.getContent(daPath), daPath), params);
		else
			return null;
	}
}

class UnkownModule
{
	public var interp:Interp;

	public var isAlive:Bool = true;

	public function new(?contents:Expr, ?params:StringMap<Dynamic>)
	{
		interp = new Interp();

		for (i in ModuleHandler.vars.keys())
			interp.variables.set(i, ModuleHandler.vars.get(i));

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