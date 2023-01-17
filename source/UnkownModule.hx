package;

import flixel.system.*;
import flixel.util.*;
import flixel.*;
import flixel.text.*;
import flixel.math.*;
import flixel.graphics.*;
import flixel.input.*;
import flixel.input.keyboard.*;
import shaders.*;
import haxe.Exception;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.display.GraphicsShader;
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
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText.FlxTextBorderStyle;

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
		parser.allowMetadata = true;

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
		vars.set("FlxText", FlxText);
		vars.set("FlxTypedGroup", FlxTypedGroup);
		vars.set("FlxGroup", FlxGroup);
		vars.set("FlxTypedSpriteGroup", FlxTypedSpriteGroup);
		vars.set("FlxKeyboard", FlxKeyboard);
		vars.set("FlxKeyList", FlxKeyList);
		vars.set("FlxInput", FlxInput);
		vars.set("FlxCamera", FlxCamera);
		vars.set("FlxPoint", FlxPoint);
		vars.set("FlxAnimate", flxanimate.FlxAnimate);
		vars.set("GraphicShader", GraphicShader);
		vars.set("Shaders", GraphicShader.Shaders);
		vars.set("Song", Song);
		vars.set("Strum", Strum);
		#if desktop
		vars.set("Event", Event);
		#end
		vars.set("Xml", Xml);
		vars.set("Reflect", Reflect);
		vars.set("Math", Math);
		vars.set("TankBGSprite", TankBGSprite);
		vars.set("Bool", Bool);
		vars.set("String", String);
		vars.set("Float", Float);
		vars.set("Int", Int);
		vars.set("Array", Array);
		vars.set("UnkownModule", UnkownModule);
		vars.set("Parser", Parser);
		vars.set("File", File);
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
		vars.set("Main", Main);
		vars.set("loadModule", loadModule);
		vars.set("setClassVar", PlayState.setClassVar);
		vars.set("getClassVar", PlayState.getClassVar);
		vars.set("playSound", FlxG.sound.play);
		vars.set("add", PlayState.instance.add);
		vars.set("remove", PlayState.instance.remove);
		vars.set("boyfriend", PlayState.boyfriend);
		vars.set("dad", PlayState.dad);
		vars.set("gf", PlayState.gf);
		vars.set("changePlayerChar", PlayState.instance.changePlayerChar);
		vars.set("changeOpponentChar", PlayState.instance.changeOpponentChar);
		vars.set("changeGfChar", PlayState.instance.changeGfChar);
		vars.set("setCamZoom", PlayState.instance.setCamZoom);
		vars.set("screenCenterX", screenCenterX);
		vars.set("setCharacterProperty", PlayState.instance.setCharacterProperty);
		vars.set("setCharacterX", PlayState.instance.setCharacterX);
		vars.set("setCharacterY", PlayState.instance.setCharacterY);
		vars.set("addCharacter", PlayState.instance.addCharacter);
		vars.set("killPlayer", PlayState.instance.killPlayer);
		vars.set("screenCenterObjectX", screenCenterObjectX);
		vars.set("setTextBorderStyle", setTextBorderStyle);
		vars.set("setCamBGColorAlpha", setCamBGColorAlpha);
		vars.set("trace", traceText);
		vars.set("setColor", setColor);

		//Thats a lot of Variables...
	}

	public function screenCenterX(sprite:FlxObject)
	{
		sprite.screenCenter(X);
	}

	public function screenCenterObjectX(object:FlxObject)
	{
		object.screenCenter(X);
	}

	public function setCamBGColorAlpha(daCam:FlxCamera, value:Float = 0)
	{
		daCam.bgColor.alpha = 0;
	}

	public function traceText(text:Dynamic) {
		trace(text);
	}

	public function setTextBorderStyle(text:FlxText, style:String = 'OUTLINE', color:String = '0', size:Float = 1, quality:Float = 1)
	{
		var textStyle:FlxTextBorderStyle;
		var textColor:FlxColor = FlxColor.fromString(color);

		switch (style)
		{
			case 'OUTLINE' | 'Outline' | 'outline':
				textStyle = OUTLINE;
			case 'NONE' | 'None' | 'none':
				textStyle = NONE;
			case 'OUTLINE_FAST' | 'Outline_Fast' | 'Outline_fast' | 'outline_fast':
				textStyle = OUTLINE_FAST;
			case 'SHADOW' | 'Shadow' | 'shadow':
				textStyle = SHADOW;
			default:
				textStyle = NONE;
		}

		text.setBorderStyle(textStyle, textColor, size, quality);
	}

	public function setColor(sprite:FlxSprite, colorString:String = '', ?rgb:Array<Int>)
	{
		if (rgb.length > 0 && rgb != null)
			sprite.color = FlxColor.fromRGB(rgb[0], rgb[1], rgb[2]);
		else
			sprite.color = FlxColor.fromString(colorString);
	}

	public function loadModule(path:String, ?params:StringMap<Dynamic>):UnkownModule
	{
		var daPath:String = path;

		if (FileSystem.exists(daPath))
			return new UnkownModule(parser.parseString(File.getContent(daPath)), params);
		else
			return new UnkownModule(null, params);
	}
}

class UnkownModule
{
	public var interp:Interp;

	public var isAlive:Bool = true;

	public function new(?contents:Expr, ?params:StringMap<Dynamic>)
	{
		if (contents != null)
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
		else
			exit();
	}

	public function exit():Dynamic
		return this.isAlive = false;

	public function get(field:String):Dynamic
	{
		if (isAlive)
			return interp.variables.get(field);
		else
			return null;
	}

	public function set(field:String, value:Dynamic)
	{
		if (isAlive)
			interp.variables.set(field, value);
	}

	public function exists(field:String):Bool
	{
		if (isAlive)
			return interp.variables.exists(field);
		else
			return false;
	}

}