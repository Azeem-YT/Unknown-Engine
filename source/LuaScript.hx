package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
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
import openfl.display3D.textures.VideoTexture;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.app.Application;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import haxe.Exception;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.display.GraphicsShader;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
import haxe.Json;
import lime.utils.Assets;

class LuaScript
{
	public var lua:State = null;
	public static var instance:LuaScript;

	public function call(daFunction:String, args:Array<Dynamic>):Dynamic
	{
		if (lua == null)
		{
			trace("Lua is null. Function Tried calling: " + daFunction);
			return 0;
		}

		Lua.getglobal(lua, daFunction);

		for (arg in args)
		{
			Convert.toLua(lua, arg);
		}

		var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
		var ripError:String = Lua.tostring(lua, -1);

		Lua.tostring(lua, result);

		if (ripError != null)
		{
			if (ripError != "attempt to call a nil value")
			{
				return null;
			}
		}

		if (result == null)
		{
			trace("result is Null");
			return null;
		}
		else 
		{
			var convert:Dynamic = Convert.fromLua(lua, result);
			return convert;
		}
	}

	public function setVariable(variable:String, object:Dynamic)
	{
		if(lua == null) {
			trace('Can Not set Variable: ' + variable + ', lua is Null');
			return;
		}

		Convert.toLua(lua, object);
		Lua.setglobal(lua, variable);
	}

	function getActorByName(name:String):Dynamic
	{
		switch(name)
		{
			case 'boyfriend':
				return PlayState.boyfriend;
			case 'girlfriend':
				return PlayState.gf;
			case 'dad':
				return PlayState.dad;
			case 'strumLineNotes':
				return PlayState.instance.strumLineNotes;
		}

		return luaSprites.get(name);
	}

	public static var luaSprites:Map<String,FlxSprite> = [];

	public function getVariable(Variable:String, type:String) : Dynamic {
		Lua.getglobal(lua, Variable);
		var result = Convert.fromLua(lua,-1);
		Lua.pop(lua,1);

		if( result == null )
		{
			return null;
		}
		else 
		{
			var result = Convert.fromLua(lua, -1);
			return result;
		}
	}

	public function makeSprite(name:String, image:String, x:Float, y:Float, antialiasing:Bool = true)
	{
		var sprite:ModSprite = new ModSprite(x, y);
		if (Assets.exists(Paths.image(image)))
			sprite.loadGraphic(Paths.image(image));
		else
			sprite.loadGraphic(Paths.modImages(image));
		if (sprite != null)
		{
			sprite.antialiasing = antialiasing;
			PlayState.customSprites.set(name, sprite);
			sprite.active = true;
		}

		trace("Function: makeSprite");
	}

	public function makeChar(x:Float, y:Float, name:String, antialiasing:Bool = true, charName:String)
	{
		var character:ModCharacter = new ModCharacter(x, y, name);
		character.antialiasing = antialiasing;
		PlayState.customCharacters.set(charName, character);
	}

	public var scriptName:String = '';

	public function new(LuaScript:String)
	{		
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		instance = this;

		//trace('Lua version: ' + Lua.version());
		//trace("LuaJIT version: " + Lua.versionJIT());

		var result:Dynamic = LuaL.dofile(lua, LuaScript);

		scriptName = LuaScript;
		trace('Lua file loaded succesfully:' + LuaScript);

		setVariable('playerX', PlayState.boyfriendX);
		setVariable('playerY', PlayState.boyfriendY);
		setVariable('opponentX', PlayState.dadX);
		setVariable('opponentY', PlayState.dadY);
		setVariable('GfX', PlayState.gfX);
		setVariable('GfY', PlayState.gfY);
	
		setVariable("difficulty", PlayState.storyDifficulty);
		setVariable("bpm", Conductor.bpm);
		setVariable("scrollspeed", FlxG.save.data.scrollSpeed != 1 ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed);
		setVariable("fpsCap", FlxG.save.data.fpsCap);
		setVariable("downscroll", FlxG.save.data.downscroll);
	
		setVariable("curStep", 0);
		setVariable("curBeat", 0);
		setVariable("crochet", Conductor.stepCrochet);
		setVariable("safeZoneOffset", Conductor.safeZoneOffset);
	
		setVariable("cameraZoom", FlxG.camera.zoom);
	
		setVariable("cameraAngle", FlxG.camera.angle);

		//setVariable("onlyShowNotes", 'bool');
		setVariable('scoreTextInvisible', 'bool');
	
		setVariable("screenWidth",FlxG.width);
		setVariable("screenHeight",FlxG.height);
		setVariable("windowWidth",FlxG.width);
		setVariable("windowHeight",FlxG.height);
	
		setVariable("mustHit", false);

		setVariable("strumLineY", PlayState.strumLineY);			
		
		Lua_helper.add_callback(lua, "setTimeForward", function(seconds:Int) {
			seconds = seconds * 1000;
			PlayState.instance.setSongTime(Conductor.songPosition + seconds);
		});

		Lua_helper.add_callback(lua, "setTimeBackwards", function(seconds:Int) {
			seconds = seconds * 1000;
			PlayState.instance.setSongTime(Conductor.songPosition - seconds);
		});
		
		Lua_helper.add_callback(lua, "setSongTime", function(seconds:Int) {
			seconds = seconds * 1000;
			PlayState.instance.setSongTime(seconds);
		});

		Lua_helper.add_callback(lua," changeOpponentChar", function(newChar:String) {
			PlayState.instance.changeOpponentChar(newChar);
		});

		Lua_helper.add_callback(lua,"changePlayerChar", function(newChar:String){
			PlayState.instance.changePlayerChar(newChar);
		});

		Lua_helper.add_callback(lua,"changeGfChar", function(newChar:String){
			PlayState.instance.changeGfChar(newChar);
		});

		Lua_helper.add_callback(lua,"testTrace", function(Text:String){
			trace(Text);
		});

		Lua_helper.add_callback(lua," makeNewSprite", function(name:String, image:String, x:Float, y:Float, antialiasing:Bool = true) {
			makeSprite(name, image, x, y, antialiasing);
		});

		Lua_helper.add_callback(lua," makeNewAnimatedSprite", function(name:String, image:String, x:Float, y:Float, antialiasing:Bool) {
			var sprite:ModSprite = new ModSprite(x, y);
			if (Assets.exists(Paths.image(image)))
				sprite.frames = Paths.getSparrowAtlas(image);
			else
				sprite.frames = Paths.getModSparrowAtlas(image);
			if (sprite != null)
			{
				sprite.antialiasing = antialiasing;
				PlayState.customSprites.set(name, sprite);
				sprite.active = true;
			}
		});

		Lua_helper.add_callback(lua," AddSpritePrefix", function(daSprite:String, animationName:String, xmlName:String, frames:Int = 24, looped:Bool) {
			if (PlayState.customSprites.exists(daSprite))
			{
				var sprite:ModSprite = PlayState.customSprites.get(daSprite);
				sprite.animation.addByPrefix(animationName, xmlName, frames, looped);
				if (sprite != null && sprite.animation.curAnim == null)
					sprite.animation.play(animationName, true);
				return;
			}
			else
			{
				var sprite:FlxSprite = Reflect.getProperty(PlayState, daSprite);
				if (sprite != null)
				{
					sprite.animation.addByPrefix(animationName, xmlName, frames, looped);
					if (sprite.animation.curAnim == null)
						sprite.animation.play(animationName, true);
				}
			}
		});

		Lua_helper.add_callback(lua,"makeNewCharacter", function(x:Float, y:Float, name:String, antialiasing:Bool = true, charName:String) {
			makeChar(x, y, name, antialiasing, charName);
		});

		Lua_helper.add_callback(lua,"addCharacter", function(charName:String) {
			var character:ModCharacter = PlayState.customCharacters.get(charName);
			PlayState.instance.add(character);
			setVariable(charName, character);
		});

		Lua_helper.add_callback(lua,"followCamChar", function(charName:String, xOffset:Float, yOffset:Float, cancel:Bool) {
			var character:ModCharacter = PlayState.customCharacters.get(charName);
			PlayState.instance.camFollowChar(character, xOffset, yOffset, cancel);
		});

		Lua_helper.add_callback(lua,"addLuaSprite", function(name:String) {
			var shit:ModSprite = PlayState.customSprites.get(name);
			PlayState.instance.add(shit);
			trace("Added Sprite");
		});

		Lua_helper.add_callback(lua,"doCamFollow", function(x:Float, y:Float) {
			PlayState.instance.camFollow.x = x;
			PlayState.instance.camFollow.y = y;
		});
		
		// hud/camera
	
		Lua_helper.add_callback(lua,"setHudAngle", function (x:Float) {
			PlayState.instance.camHUD.angle = x;
		});
		
		Lua_helper.add_callback(lua,"setHealth", function (newHealth:Float) {
			PlayState.instance.health = newHealth;
		});

		Lua_helper.add_callback(lua,"setHudPosition", function (x:Int, y:Int) {
			PlayState.instance.camHUD.x = x;
			PlayState.instance.camHUD.y = y;
		});
	
		Lua_helper.add_callback(lua,"getHudX", function () {
			return PlayState.instance.camHUD.x;
		});
	
		Lua_helper.add_callback(lua,"getHudY", function () {
			return PlayState.instance.camHUD.y;
		});
		
		Lua_helper.add_callback(lua,"setCamPosition", function (x:Int, y:Int) {
			FlxG.camera.x = x;
			FlxG.camera.y = y;
		});
	
		Lua_helper.add_callback(lua,"getCameraX", function () {
			return FlxG.camera.x;
		});
	
		Lua_helper.add_callback(lua,"getCameraY", function () {
			return FlxG.camera.y;
		});
	
		Lua_helper.add_callback(lua,"setCamZoom", function(zoomAmount:Float) {
			FlxG.camera.zoom = zoomAmount;
		});
	
		Lua_helper.add_callback(lua,"setHudZoom", function(zoomAmount:Float) {
			PlayState.instance.camHUD.zoom = zoomAmount;
		});
	
		// strumline

		Lua_helper.add_callback(lua, "setStrumlineY", function(y:Float)
		{
			PlayState.strumLineY = y;
		});
	
		// actors
		
		Lua_helper.add_callback(lua,"getRenderedNotes", function() {
			return PlayState.instance.notes.length;
		});
	
		Lua_helper.add_callback(lua,"getRenderedNoteX", function(id:Int) {
			return PlayState.instance.notes.members[id].x;
		});
	
		Lua_helper.add_callback(lua,"getRenderedNoteY", function(id:Int) {
			return PlayState.instance.notes.members[id].y;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteType", function(id:Int) {
			return PlayState.instance.notes.members[id].noteData;
		});

		Lua_helper.add_callback(lua,"isSustain", function(id:Int) {
			return PlayState.instance.notes.members[id].isSustainNote;
		});

		Lua_helper.add_callback(lua,"isParentSustain", function(id:Int) {
			return PlayState.instance.notes.members[id].prevNote.isSustainNote;
		});

		
		Lua_helper.add_callback(lua,"getRenderedNoteParentX", function(id:Int) {
			return PlayState.instance.notes.members[id].prevNote.x;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteParentY", function(id:Int) {
			return PlayState.instance.notes.members[id].prevNote.y;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteHit", function(id:Int) {
			return PlayState.instance.notes.members[id].mustPress;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteCalcX", function(id:Int) {
			if (PlayState.instance.notes.members[id].mustPress)
				return PlayState.playerStrums.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
			return PlayState.instance.strumLineNotes.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
		});

		Lua_helper.add_callback(lua,"anyNotes", function() {
			return PlayState.instance.notes.members.length != 0;
		});

		Lua_helper.add_callback(lua,"getRenderedNoteStrumtime", function(id:Int) {
			return PlayState.instance.notes.members[id].strumTime;
		});
	
		Lua_helper.add_callback(lua,"getRenderedNoteScaleX", function(id:Int) {
			return PlayState.instance.notes.members[id].scale.x;
		});
	
		Lua_helper.add_callback(lua,"setRenderedNotePos", function(x:Float,y:Float, id:Int) {
			if (PlayState.instance.notes.members[id] == null)
				throw('error! you cannot set a rendered notes position when it doesnt exist! ID: ' + id);
			else
			{
				PlayState.instance.notes.members[id].x = x;
				PlayState.instance.notes.members[id].y = y;
			}
		});
	
		Lua_helper.add_callback(lua,"setRenderedNoteAlpha", function(alpha:Float, id:Int) {
			PlayState.instance.notes.members[id].alpha = alpha;
		});
	
		Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scale:Float, id:Int) {
			PlayState.instance.notes.members[id].setGraphicSize(Std.int(PlayState.instance.notes.members[id].width * scale));
		});

		Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scaleX:Int, scaleY:Int, id:Int) {
			PlayState.instance.notes.members[id].setGraphicSize(scaleX,scaleY);
		});

		Lua_helper.add_callback(lua,"getRenderedNoteWidth", function(id:Int) {
			return PlayState.instance.notes.members[id].width;
		});


		Lua_helper.add_callback(lua,"setRenderedNoteAngle", function(angle:Float, id:Int) {
			PlayState.instance.notes.members[id].angle = angle;
		});
	
		Lua_helper.add_callback(lua,"setActorX", function(x:Int,id:String) {
			getActorByName(id).x = x;
		});
		
		Lua_helper.add_callback(lua,"playActorAnimation", function(id:String,anim:String,force:Bool = false,reverse:Bool = false) {
			getActorByName(id).playAnim(anim, force, reverse);
		});
	
		Lua_helper.add_callback(lua,"setActorAlpha", function(alpha:Float,id:String) {
			getActorByName(id).alpha = alpha;
		});
	
		Lua_helper.add_callback(lua,"setActorY", function(y:Int,id:String) {
			getActorByName(id).y = y;
		});
					
		Lua_helper.add_callback(lua,"setActorAngle", function(angle:Int,id:String) {
			getActorByName(id).angle = angle;
		});
	
		Lua_helper.add_callback(lua,"setActorScale", function(scale:Float,id:String) {
			getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
		});
		
		Lua_helper.add_callback(lua, "setActorScaleXY", function(scaleX:Float, scaleY:Float, id:String)
		{
			getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scaleX), Std.int(getActorByName(id).height * scaleY));
		});
	
		Lua_helper.add_callback(lua, "setActorFlipX", function(flip:Bool, id:String)
		{
			getActorByName(id).flipX = flip;
		});

		Lua_helper.add_callback(lua, "setActorFlipY", function(flip:Bool, id:String)
		{
			getActorByName(id).flipY = flip;
		});
	
		Lua_helper.add_callback(lua,"getActorWidth", function (id:String) {
			return getActorByName(id).width;
		});
	
		Lua_helper.add_callback(lua,"getActorHeight", function (id:String) {
			return getActorByName(id).height;
		});
	
		Lua_helper.add_callback(lua,"getActorAlpha", function(id:String) {
			return getActorByName(id).alpha;
		});
	
		Lua_helper.add_callback(lua,"getActorAngle", function(id:String) {
			return getActorByName(id).angle;
		});
	
		Lua_helper.add_callback(lua,"getActorX", function (id:String) {
			return getActorByName(id).x;
		});
	
		Lua_helper.add_callback(lua,"getActorY", function (id:String) {
			return getActorByName(id).y;
		});

		Lua_helper.add_callback(lua,"setWindowPos",function(x:Int,y:Int) {
			Application.current.window.x = x;
			Application.current.window.y = y;
		});

		Lua_helper.add_callback(lua,"getWindowX",function() {
			return Application.current.window.x;
		});

		Lua_helper.add_callback(lua,"getWindowY",function() {
			return Application.current.window.y;
		});

		Lua_helper.add_callback(lua,"resizeWindow",function(Width:Int,Height:Int) {
			Application.current.window.resize(Width,Height);
		});
		
		Lua_helper.add_callback(lua,"getScreenWidth",function() {
			return Application.current.window.display.currentMode.width;
		});

		Lua_helper.add_callback(lua,"getScreenHeight",function() {
			return Application.current.window.display.currentMode.height;
		});

		Lua_helper.add_callback(lua,"getWindowWidth",function() {
			return Application.current.window.width;
		});

		Lua_helper.add_callback(lua,"getWindowHeight",function() {
			return Application.current.window.height;
		});

	
		// tweens
		
		Lua_helper.add_callback(lua,"tweenCameraPos", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenCameraAngle", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraZoom", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudPos", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenHudAngle", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudZoom", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {zoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenCameraAngleOut", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraZoomOut", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenHudAngleOut", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudZoomOut", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {zoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenPosOut", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosXAngleOut", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosYAngleOut", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenAngleOut", function(id:String, toAngle:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenCameraAngleIn", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenCameraZoomIn", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});
				
		Lua_helper.add_callback(lua,"tweenHudAngleIn", function(toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenHudZoomIn", function(toZoom:Float, time:Float, onComplete:String) {
			FlxTween.tween(PlayState.instance.camHUD, {zoom:toZoom}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,["camera"]);}}});
		});

		Lua_helper.add_callback(lua,"tweenPosIn", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosXAngleIn", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenPosYAngleIn", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenAngleIn", function(id:String, toAngle:Int, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenFadeIn", function(id:String, toAlpha:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});
	
		Lua_helper.add_callback(lua,"tweenFadeOut", function(id:String, toAlpha:Float, time:Float, onComplete:String) {
			FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {call(onComplete,[id]);}}});
		});

		Lua_helper.add_callback(lua, "getProperty", function(variable:String) {
			var v:Array<String> = variable.split('.');
			if(v.length > 1) {
				return Reflect.getProperty(getPropertyFunction(v), v[v.length-1]);
			}
			return Reflect.getProperty(getPlayStateInstance(), variable);
		});

		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic) {
			var v:Array<String> = variable.split('.');
			if(v.length > 1) {
				return Reflect.setProperty(getPropertyFunction(v), v[v.length - 1], value);
			}
			return Reflect.setProperty(getPlayStateInstance(), variable, value);
		});

		Lua_helper.add_callback(lua, "getPropertyFromClass", function(classVar:String, variable:String) {
			var v:Array<String> = variable.split('.');
			if(v.length > 1) {
				var b:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), v[0]);
				for (i in 1...v.length-1) {
					b = Reflect.getProperty(b, v[i]);
				}
				return Reflect.getProperty(b, v[v.length - 1]);
			}
			return Reflect.getProperty(Type.resolveClass(classVar), variable);
		});

		Lua_helper.add_callback(lua, "setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic) {
			var v:Array<String> = variable.split('.');
			if (v.length > 1)
			{
				var b:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), v[0]);
				for (i in 1...v.length - 1){
					b = Reflect.getProperty(b, v[i]);
				}
				return Reflect.setProperty(b, v[v.length - 1], value);
			}
		});

		#if debug
		trace("Done");
		#end
	}

	function getPropertyFunction(v:Array<String>):Dynamic
	{
		var b:Dynamic = getObject(v[0]);

		for (i in 1...v.length-1) {
			b = Reflect.getProperty(b, v[i]);
		}
		return b;
	}

	function getObject(objectName:String):Dynamic
	{
		var fuck:Dynamic = null;

		if (PlayState.customSprites.exists(objectName)) 
		{
			fuck = PlayState.customSprites.get(objectName);
		} 
		else 
		{
			fuck = Reflect.getProperty(getPlayStateInstance(), objectName);
		}

		return fuck;
	}

	function getPlayStateInstance()
	{
		return PlayState.instance;
	}

	public function die()
	{
		trace('killed the boi');
		Lua.close(lua);
		lua = null;
	}
}

class ModSprite extends FlxSprite
{
	public var wasAdded:Bool;
	//hi
}

class ModCharacter extends Character
{
	//hi again
}