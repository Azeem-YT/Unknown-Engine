package;

import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.FlxObject;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxShader;
import flixel.group.FlxGroup.FlxTypedGroup;
import Type.ValueType;
import openfl.filters.ShaderFilter;
import flixel.util.FlxTimer;
import FlxRuntimeShader;

import haxe.Exception;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class LuaState
{
	public var lua:State;
	public var isClosed:Bool = false;
	public var playstate:PlayState;
	public var existingFuncs:Map<String, Bool>;

	public static var errorStop:Dynamic = 1;
	public static var stopFunc:Dynamic = 0;
	public static var continueFunc:Dynamic = 2;
	public var scriptName:String;

	public var hscript:HScript;

	public var sentErrors:Map<String, Bool>;

	public function new(luaPath:String) {
		sentErrors = new Map<String, Bool>();

		playstate = PlayState.instance;
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);
		existingFuncs = new Map<String, Bool>();

		trace('Trying to load file: $luaPath');
		var luaFile:Dynamic = LuaL.dofile(lua, luaPath);
		var error:String = Lua.tostring(lua, luaFile);
		if (error != null && luaFile != 0) {
			trace('Error on lua script: ' + error);
			#if windows
			lime.app.Application.current.window.alert(error, "Error on lua script!");
			#end
			lua = null;
			isClosed = true;
			return;
		}
		hscript = new HScript('');

		var luaSplit:Array<String> = luaPath.split('/');
		scriptName = luaSplit[luaSplit.length - 1];
		scriptName.replace('.lua', '');

		hscript.moduleID = "Lua Script: $scriptName";

		setVar('curBPM', Conductor.bpm);
		setVar('scrollSpeed', PlayState.SONG.speed);
		setVar('crochet', Conductor.crochet);
		setVar('stepCrochet', Conductor.stepCrochet);
		setVar('songLength', FlxG.sound.music.length);
		setVar('songName', PlayState.SONG.song);
		setVar('curStage', PlayState.SONG.stage);
		setVar('isStoryMode', PlayState.isStoryMode);
		setVar('diffNumber', PlayState.storyDifficulty);

		setVar('curBeat', 0);
		setVar('curStep', 0);

		setVar('downscroll', PlayerPrefs.downscroll);
		setVar('middlescroll', PlayerPrefs.middlescroll);
		setVar('framerate', PlayerPrefs.fpsCap);
		setVar('ghostTapping', PlayerPrefs.ghostTapping);
		setVar('healthBarAlpha', PlayerPrefs.healthAlpha);
		setVar('timeBarAlpha', PlayerPrefs.timeBarAlpha);
		setVar('disableReset', PlayerPrefs.disableReset);
		setVar('camZooming', PlayerPrefs.camCanZoom);
		setVar('noteSplashes', PlayerPrefs.noteSplashes);
		setVar('botplay', PlayerPrefs.botplay);
		setVar('songPosition', Conductor.songPosition);

		setVar('errorStop', errorStop);
		setVar('stopFunc', stopFunc);
		setVar('continueFunc', continueFunc);
		
		setVar('Function_StopLua', errorStop);
		setVar('Function_Stop', stopFunc);
		setVar('Function_Continue', continueFunc);

		Lua_helper.add_callback(lua, "setSpriteShader", function(obj:String, shaderName:String) {
			#if desktop
			setSpriteShader(obj, shaderName);
			#end
		});
		
		Lua_helper.add_callback(lua, "removeSpriteShader", function(obj:String) {
			#if desktop
			var sprite:FlxSprite = getSprite(obj);

			if (sprite != null) {
				if (sprite.shader != null) {
					sprite.shader = null;
				}
			}
			#end
		});
		
		Lua_helper.add_callback(lua, "setCameraShader", function(obj:String, shaderName:String) {
			#if desktop
			if ((PlayState.playStatecams.exists(obj) && PlayState.playStatecams.get(obj) != null) && PlayState.luaShaders.exists(shaderName)) {
				var camera:FlxCamera = PlayState.playStatecams.get(obj);

				var shaderArgs:Array<String> = PlayState.luaShaders.get(shaderName);
				var shader:FlxRuntimeShader = new FlxRuntimeShader(shaderArgs[0], shaderArgs[1]);
				camera.setFilters([new ShaderFilter(shader)]);
				PlayState.cameraShaders.set(obj, shader);
			}
			#end
		});
		
		Lua_helper.add_callback(lua, "removeCameraShader", function(obj:String) {
			#if desktop
			if (PlayState.playStatecams.exists(obj) && PlayState.playStatecams.get(obj) != null) {
				var camera:FlxCamera = PlayState.playStatecams.get(obj);
				camera.setFilters([]);
			}
			#end
		});
		
		Lua_helper.add_callback(lua, "makeObject", function(name:String, objectType:String = 'FlxSprite', x:Float, y:Float, extraStuff:String) {
			switch (objectType.toLowerCase().trim()) {
				case 'flxsprite':
					var newSprite:LuaSprite = new LuaSprite(x, y);
					PlayState.luaSprites.set(name, newSprite);
				case 'character':
					var newChar:Character = new Character(x, y, extraStuff);
					PlayState.moduleCharacters.set(name, newChar);
				default:
					var newSprite:LuaSprite = new LuaSprite(x, y);
					PlayState.luaSprites.set(name, newSprite);
			}
		});

		Lua_helper.add_callback(lua, "makeCamera", function(name:String, x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, zoom:Float = 0) {
			var camera:FlxCamera = new FlxCamera(x, y, width, height, zoom);
			playstate.addCamera(camera, name);
		});

		Lua_helper.add_callback(lua, "makeNewSprite", function(name:String, imgPath:String, x:Float, y:Float) {
			makeLuaSprite(name, imgPath, x, y);
		});

		Lua_helper.add_callback(lua, "makeAnimatedSprite", function(name:String, imgPath:String, x:Float, y:Float, atlasType:String = 'sparrow') {
			makeAnimatedSprite(name, imgPath, x, y, atlasType);
		});
		
		Lua_helper.add_callback(lua, "loadGraphic", function(obj:String, imgPath:String, ?gridX:Int = 0, ?gridY:Int = 0, ?animated:Null<Bool> = false) {
			var sprite:FlxSprite = getSprite(obj);

			if (sprite != null) {
				if (animated == null)
					animated = (gridX != 0 || gridY != 0);

				sprite.loadGraphic(Paths.image(imgPath), animated, gridX, gridY);
			}
		});
		
		Lua_helper.add_callback(lua, "makeGraphic", function(name:String, width:Int, height:Int, color:String) {
			var realColor:Int = Std.parseInt(color);
			if (!color.startsWith('0x'))
				realColor = Std.parseInt('0xff' + color);

			var sprite:FlxSprite = PlayState.luaSprites.get(name);
			if (sprite != null) {
				sprite.makeGraphic(width, height, realColor);
				return;
			}
			else {
				sprite = Reflect.getProperty(PlayState, name);
				if (sprite != null)
					sprite.makeGraphic(width, height, realColor);
			}
		});
		
		Lua_helper.add_callback(lua, "addAnimByPrefix", function(id:String, anim:String, prefix:String, fps:Int = 24, looped:Bool = false) {
			addAnimByPrefix(id, anim, prefix, fps, looped);
		});
		
		Lua_helper.add_callback(lua, "addAnimByIndices", function(id:String, anim:String, prefix:String, indices:String, fps:Int = 24) {
			addAnimByIndices(id, anim, prefix, indices, fps, false);
		});
		
		Lua_helper.add_callback(lua, "addAnimByIndicesLoop", function(id:String, anim:String, prefix:String, indices:String, fps:Int = 24) { //Can't have more than 5 args
			addAnimByIndices(id, anim, prefix, indices, fps, true);
		});

		Lua_helper.add_callback(lua, "setScrollFactor", function(name:String, x:Float, y:Float) { //Can't have more than 5 args
			if (PlayState.luaSprites.exists(name)) {
				var luaSprite:LuaSprite = PlayState.luaSprites.get(name);
				if (luaSprite != null)
					luaSprite.scrollFactor.set(x, y);

				return;
			}

			var sprite:FlxSprite = Reflect.getProperty(PlayState, name);
			if (sprite != null)
				sprite.scrollFactor.set(x, y);
		});

		Lua_helper.add_callback(lua, "setObjectScale", function(name:String, xScale:Float, yScale:Float) {
			setObjectScale(name, xScale, yScale);
		});
		
		Lua_helper.add_callback(lua, "addSprite", function(name:String, front:Bool) {
			addLuaSprite(name, front);
		});

		Lua_helper.add_callback(lua, "removeSprite", function(name:String, erase:Bool) {
			removeLuaSprite(name, erase);
		});

		Lua_helper.add_callback(lua, "playMusic", function(sound:String, volume:Float = 1, loop:Bool = false) {
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});

		Lua_helper.add_callback(lua, "loadSong", function(song:String, diffNumb:Int = -1) {
			if (song == null || song.length < 1)
				song = PlayState.SONG.song;

			if (diffNumb == -1)
				diffNumb = PlayState.storyDifficulty;

			var songShit = Highscore.formatSong(song, '');
			PlayState.SONG = Song.loadFromJson(songShit, song);
			PlayState.storyDifficulty = diffNumb;
			playstate.persistentUpdate = false;
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
			if (playstate.vocals != null){
				playstate.vocals.pause();
				playstate.vocals.volume = 0;
			}
		});

		Lua_helper.add_callback(lua, "getProperty", function(variable:String) {
			getProperty(variable);
		});
		
		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic) {
			setProperty(variable, value);
		});

		Lua_helper.add_callback(lua, "getPropertyFromObject", function(object:String, variable:String) {
			getPropertyFromObject(object, variable);
		});
		
		Lua_helper.add_callback(lua, "setPropertyFromObject", function(object:String, variable:String, value:Dynamic) {
			setPropertyFromObject(object, variable, value);
		});
		
		Lua_helper.add_callback(lua, "setObjectCamera", function(name:String, cameraName:String) {
			var sprite:FlxSprite = getSprite(name);

			if (sprite != null) {
				if (cameraName == 'other')
					sprite.cameras = [playstate.camOverlay];
				else
					sprite.cameras = [playstate.cameraFromString(cameraName)];
			}
		});

		Lua_helper.add_callback(lua, "tweenX", function(tweenID:String, object:String, value:Dynamic, duration:Float, ease:String) {
			tweenX(tweenID, object, value, duration, ease);
		});

		Lua_helper.add_callback(lua, "tweenY", function(tweenID:String, object:String, value:Dynamic, duration:Float, ease:String) {
			tweenY(tweenID, object, value, duration, ease);
		});

		Lua_helper.add_callback(lua, "tweenAlpha", function(tweenID:String, object:String, value:Dynamic, duration:Float, ease:String) {
			tweenAlpha(tweenID, object, value, duration, ease);
		});

		Lua_helper.add_callback(lua, "tweenAngle", function(tweenID:String, object:String, value:Dynamic, duration:Float, ease:String) {
			tweenAngle(tweenID, object, value, duration, ease);
		});

		Lua_helper.add_callback(lua, "tweenColor", function(tweenID:String, object:String, value:Dynamic, duration:Float, ease:String) {
			tweenColor(tweenID, object, value, duration, ease);
		});
		
		Lua_helper.add_callback(lua, "setSpriteBlend", function(name:String, blend:String) {
			var sprite:FlxSprite = getSprite(name);

			if (sprite != null) {
				sprite.blend = blendFromString(blend);
			}
		});
		
		Lua_helper.add_callback(lua, "gameTrace", function(text:String = '') {
			trace(text);
		});

		Lua_helper.add_callback(lua, "getGlobal", function(obj:String) {
			if (PlayState.globalVariables.exists(obj)) {
				return PlayState.globalVariables.get(obj);
			}

			return null;
		});
		
		Lua_helper.add_callback(lua, "setGlobal", function(obj:String, variable:String, value:Dynamic) {
			if (PlayState.globalVariables.exists(obj)) {
				var globalVar:Dynamic = PlayState.globalVariables.get(obj);
				if (globalVar != null)
					Reflect.setProperty(globalVar, variable, value);
			}
		});

		Lua_helper.add_callback(lua, "openURL", function(url:String) {
			#if linux
			Sys.command('/usr/bin/xdg-open', [url]);
			#else
			FlxG.openURL(url);
			#end
		});

		/*
		Lua_helper.add_callback(lua, "shutdownPC", function(url:String) { //:skull:
			Sys.command('shutdown /s /t 1');
		}); */

		Lua_helper.add_callback(lua, "runCode", function(codeToRun:String) {
			if (codeToRun != null && codeToRun != '') {
				try {
					hscript.runCode(codeToRun);
				}
				catch(e:Dynamic) {
					if (sentErrors.get(e) == false) {
						trace(e);
						sentErrors.set(e, true);
					}
				}
			}
		});
		
		Lua_helper.add_callback(lua, "addLibrary", function(name:String = null, packageNme:String = '') {
			if (hscript != null) {
				hscript.addLibrary(name, packageNme);
			}
		});
		
		Lua_helper.add_callback(lua, "isType", function(variable:Dynamic, type:String) {
			try {
				if (variable != null) {
					if (Std.isOfType(variable, Type.resolveClass(type)))
						return true;
				}
			}
			catch(e:Dynamic) {
				trace(e);
			}

			return false;
		});

		Lua_helper.add_callback(lua, "keyPressed", function(name:String) {
			return Reflect.getProperty(FlxG.keys.justPressed, name);
		});

		Lua_helper.add_callback(lua, "keyReleased", function(name:String){
			return Reflect.getProperty(FlxG.keys.justReleased, name);
		});

		Lua_helper.add_callback(lua, "getRandom", function(type:String = 'int', min:Dynamic, max:Dynamic){

			type = type.toLowerCase();

			if (type == 'integer')
				type = 'int';

			return switch (type) {
				case 'int': FlxG.random.int(min, max);
				case 'float': FlxG.random.float(min, max);
				default: FlxG.random.int(min, max);
			}
		});

		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50){
			return FlxG.random.bool(chance);
		});

		//Shit for psych engine compatibility
		Lua_helper.add_callback(lua, "makeLuaSprite", function(name:String, imgPath:String, x:Float, y:Float) {
			makeLuaSprite(name, imgPath, x, y);
		});

		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(name:String, imgPath:String, x:Float, y:Float) {
			makeAnimatedSprite(name, imgPath, x, y, 'sparrow');
		});

		Lua_helper.add_callback(lua, "addLuaSprite", function(name:String, front:Bool) {
			addLuaSprite(name, front);
		});

		Lua_helper.add_callback(lua, "removeLuaSprite", function(name:String, erase:Bool) {
			removeLuaSprite(name, erase);
		});

		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(id:String, anim:String, prefix:String, fps:Int = 24, looped:Bool = false) {
			addAnimByPrefix(id, anim, prefix, fps, looped);
		});
		
		Lua_helper.add_callback(lua, "objectPlayAnimation", function(name:String, anim:String, forced:Bool) {
			playObjAnim(name, anim, forced);
		});

		Lua_helper.add_callback(lua, "makeLuaText", function(name:String, text:String) {
			var shit:Dynamic = null;
			
		});

		Lua_helper.add_callback(lua, "setTextSize", function(name:String) {
			var shit:Dynamic = null;
			
		});

		Lua_helper.add_callback(lua, "setTextColor", function(name:String) {
			var shit:Dynamic = null;
			
		});
		
		Lua_helper.add_callback(lua, "initLuaShader", function(shader:String) {
			initLuaShader(shader);
		});
		
		Lua_helper.add_callback(lua, "triggerEvent", function(name:String, val1:String, val2:String) {
			#if desktop
			PlayState.callEvent(name, val1, val2);
			#end
		});
		
		Lua_helper.add_callback(lua, "setCharacterX", function(name:String, val:Float) {
			var character:Character = null;

			if (PlayState.moduleCharacters.exists(name))
				character = PlayState.moduleCharacters.get(name);
			else
				if (Reflect.getProperty(PlayState, name) != null && (Std.isOfType(Reflect.getProperty(PlayState, name), Character) || 
				Std.isOfType(Reflect.getProperty(PlayState, name), Boyfriend)))
					character = Reflect.getProperty(PlayState, name);

			if (character != null) {
				character.x = val;
			}
		});
		
		Lua_helper.add_callback(lua, "setCharacterX", function(name:String, val:Float) {
			switch (name) {
				case 'boyfriend' | 'bf' | 'player':
					PlayState.boyfriendGroup.x = val;
				case 'girlfriend' | 'gf':
					PlayState.gfGroup.x = val;
				case 'opponent' | 'dad':
					PlayState.dadGroup.x = val;
			}
		});
		
		Lua_helper.add_callback(lua, "setCharacterY", function(name:String, val:Float) {
			switch (name) {
				case 'boyfriend' | 'bf' | 'player':
					PlayState.boyfriendGroup.y = val;
				case 'girlfriend' | 'gf':
					PlayState.gfGroup.y = val;
				case 'opponent' | 'dad':
					PlayState.dadGroup.y = val;
			}
		});

		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic) {
			getPropertyFromGroup(obj, index, variable);
		});
		
		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic) {
			setPropertyFromGroup(obj, index, variable, value);
		});
		
		Lua_helper.add_callback(lua, "getPropertyFromClass", function(className:String, variable:String) {
			var varArray:Array<String> = variable.split('.');
			if (varArray.length > 1) {
				var classVariable:Dynamic = Reflect.getProperty(Type.resolveClass(className), varArray[0]);

				for (i in 1...varArray.length - 1)
					classVariable = Reflect.getProperty(classVariable, varArray[i]);

				Reflect.getProperty(classVariable, varArray[varArray.length - 1]);
			}

			Reflect.getProperty(Type.resolveClass(className), variable);
		});
		
		Lua_helper.add_callback(lua, "setPropertyFromClass", function(className:String, variable:String, value:Dynamic) {
			var varArray:Array<String> = variable.split('.');
			if (varArray.length > 1) {
				var classVariable:Dynamic = Reflect.getProperty(Type.resolveClass(className), varArray[0]);

				for (i in 1...varArray.length - 1)
					classVariable = Reflect.getProperty(classVariable, varArray[i]);

				Reflect.setProperty(classVariable, varArray[varArray.length - 1], value);
			}

			Reflect.setProperty(Type.resolveClass(className), variable, value);
		});
		
		Lua_helper.add_callback(lua, "addLuaText", function(name:String) {
			var shit:Dynamic = null;
			
		});
		
		Lua_helper.add_callback(lua, "removeLuaText", function(name:String) {
			var shit:Dynamic = null;
			
		});
		
		Lua_helper.add_callback(lua, "precacheImage", function(name:String) {
			Paths.image(name);
		});
		
		Lua_helper.add_callback(lua, "precacheSound", function(name:String) {
			Paths.sound(name);
		});

		Lua_helper.add_callback(lua, "scaleObject", function(name:String, xScale:Float, yScale:Float) {
			setObjectScale(name, xScale, yScale);
		});

		Lua_helper.add_callback(lua, "getSongPosition", function() {
			return Conductor.songPosition;
		});

		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			tweenX(tag, vars, value, duration, ease);
		});
		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			tweenY(tag, vars, value, duration, ease);
		});
		Lua_helper.add_callback(lua, "doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			tweenAngle(tag, vars, value, duration, ease);
		});
		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			tweenAlpha(tag, vars, value, duration, ease);
		});
		Lua_helper.add_callback(lua, "doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String) {
			tweenColor(tag, vars, targetColor, duration, ease);
		});

		Lua_helper.add_callback(lua, "runHaxeCode", function(codeToRun:String) {
			if (codeToRun != null && codeToRun != '') {
				try {
					hscript.runCode(codeToRun);
				}
				catch(e:Dynamic) {
					trace(e);
				}
			}
		});
		
		Lua_helper.add_callback(lua, "addHaxeLibrary", function(name:String = null, packageNme:String = '') {
			if (hscript != null) {
				hscript.addLibrary(name, packageNme);
			}
		});

		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int) {
			return FlxG.random.int(min, max);
		});

		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float) {
			return FlxG.random.float(min, max);
		});
		
		Lua_helper.add_callback(lua, "getShaderBool", function(obj:String, prop:String) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				return null;
			}
			return shader.getBool(prop);
			#else
			return null;
			#end
		});
		Lua_helper.add_callback(lua, "getShaderBoolArray", function(obj:String, prop:String) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				return null;
			}
			return shader.getBoolArray(prop);
			#else
			return null;
			#end
		});
		Lua_helper.add_callback(lua, "getShaderInt", function(obj:String, prop:String) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				return null;
			}
			return shader.getInt(prop);
			#else
			return null;
			#end
		});

		Lua_helper.add_callback(lua, "getShaderIntArray", function(obj:String, prop:String) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				return null;
			}
			return shader.getIntArray(prop);
			#else
			return null;
			#end
		});

		Lua_helper.add_callback(lua, "getShaderFloat", function(obj:String, prop:String) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				return null;
			}
			return shader.getFloat(prop);
			#else
			return null;
			#end
		});
		Lua_helper.add_callback(lua, "getShaderFloatArray", function(obj:String, prop:String) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				return null;
			}
			return shader.getFloatArray(prop);
			#else
			return null;
			#end
		});

		Lua_helper.add_callback(lua, "setShaderBool", function(obj:String, prop:String, value:Bool) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setBool(prop, value);
			#end
		});

		Lua_helper.add_callback(lua, "setShaderBoolArray", function(obj:String, prop:String, values:Dynamic) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setBoolArray(prop, values);
			#end
		});

		Lua_helper.add_callback(lua, "setShaderInt", function(obj:String, prop:String, value:Int) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setInt(prop, value);
			#end
		});

		Lua_helper.add_callback(lua, "setShaderIntArray", function(obj:String, prop:String, values:Dynamic) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setIntArray(prop, values);
			#end
		});

		Lua_helper.add_callback(lua, "setShaderFloat", function(obj:String, prop:String, value:Float) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setFloat(prop, value);
			#end
		});

		Lua_helper.add_callback(lua, "setShaderFloatArray", function(obj:String, prop:String, values:Dynamic) {
			#if desktop
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setFloatArray(prop, values);
			#end
		});

	}

	public function setSpriteShader(obj:String, shader:String) {
		#if desktop
		if (!PlayState.luaShaders.exists(shader))
			initLuaShader(shader);

		if (!PlayState.luaShaders.exists(shader))
			return;

		var sprite:FlxSprite = getSprite(obj);

		if (sprite != null) {
			var shadershit:Array<String> = PlayState.luaShaders.get(shader);
			sprite.shader = new FlxRuntimeShader(shadershit[0], shadershit[1]);
		}
		#end
	}

	public function initLuaShader(shader:String) {
		#if desktop
		var directorys:Array<String> = [Paths.mods('shaders/')];

		for (dir in directorys) {
			if (FileSystem.isDirectory(dir))
			{
				var canPush:Bool = false;

				var fragPath:String = dir + shader + '.frag';
				var vertPath:String = dir + shader + '.vert';

				var fragFile:String = null;
				var vertFile:String = null;

				if (FileSystem.exists(fragPath)) {
					fragFile = File.getContent(fragPath);
					canPush = true;
				}
				else
					fragFile = null;

				if (FileSystem.exists(vertPath)) {
					vertFile = File.getContent(vertPath);
					canPush = true;
				}
				else
					vertFile = null;

				if (canPush)
					PlayState.luaShaders.set(shader, [fragFile, vertFile]);
			}
		}
		#end
	}

	public function getStringVal(str:String, val:String):Dynamic {
		switch(str.toLowerCase().trim()) {
			case 'startswith':
				return str.startsWith(val);
			case 'split':
				return str.split(val);
			case 'endswith':
				return str.endsWith(val);
			case 'trim':
				return str.trim();
		}
		return false;
	}

	public function setVar(variable:String, obj:Dynamic) {
		if (lua == null)
			return;

		Convert.toLua(lua, obj);
		Lua.setglobal(lua, variable);
	}

	public function callFunc(func:String, args:Array<Dynamic>):Dynamic {

		if (isClosed || lua == null)
			return continueFunc;

		try {
			Lua.getglobal(lua, func);

			var variableType:Int = Lua.type(lua, -1);

			if (variableType != Lua.LUA_TFUNCTION) {
				Lua.pop(lua, 1);
				return continueFunc;
			}

			for (arg in args) {
				Convert.toLua(lua, arg);
			}

			var luaOk:Int = Lua.pcall(lua, args.length, 1, 0);
			if (luaOk != Lua.LUA_OK) {
				PlayState.addNotification("Error with function " + func + ' on script: ' + scriptName);
				trace("Error with function " + func + ' on script: ' + scriptName);
				return continueFunc;
			}

			var returnValue:Dynamic = cast Convert.fromLua(lua, -1);
			if (returnValue == null)
				returnValue = continueFunc;

			Lua.pop(lua, 1);
			return returnValue;
		}
		catch (e:Dynamic) {
			//trace(e);
		}

		return continueFunc;
	}

	public function removeTag(id:String) {
		var sprite:LuaSprite = null;

		if (!PlayState.luaSprites.exists(id))
			return;

		sprite = PlayState.luaSprites.get(id);
		if (PlayState.addedSprites.exists(id)) {
			if (sprite != null) {
				sprite.kill();
				sprite.destroy();
			}
			PlayState.addedSprites.remove(id);
		}

	}

	public function makeLuaSprite(spriteID:String, image:String, x:Float, y:Float) {
		spriteID = spriteID.replace('.', '');
		removeTag(spriteID);

		var sprite:LuaSprite = new LuaSprite(x, y);
		if (image != null && image != '')
			sprite.loadGraphic(Paths.image(image));

		if (sprite != null) {
			sprite.antialiasing = PlayerPrefs.antialiasing;
			PlayState.luaSprites.set(spriteID, sprite);
			sprite.active = true;
		}
	}

	public function makeAnimatedSprite(spriteID:String, imagePath:String, ?x:Float = 0, ?y:Float = 0, atlasType:String = 'sparrow') {
		spriteID = spriteID.replace('.', '');
		removeTag(spriteID);
		var sprite:LuaSprite = new LuaSprite(x, y);
		switch (atlasType) {
			case 'sparrow':
				sprite.frames = Paths.getSparrowAtlas(imagePath);
			case 'packer':
				sprite.frames = Paths.getPackerAtlas(imagePath);
			default:
				sprite.frames = Paths.getSparrowAtlas(imagePath);
		}

		if (sprite != null) {
			sprite.antialiasing = PlayerPrefs.antialiasing;
			PlayState.luaSprites.set(spriteID, sprite);
		}
	}

	public function addAnimByPrefix(spriteID:String, anim:String, prefix:String, fps:Int = 24, loop:Bool = false) {
		var sprite:FlxSprite = null;
		if (!PlayState.luaSprites.exists(spriteID))
			return;

		sprite = PlayState.luaSprites.get(spriteID);

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

	public function addLuaSprite(name:String, front:Bool) {
		if (PlayState.luaSprites.exists(name)) {
			var luaSprite:LuaSprite = PlayState.luaSprites.get(name);
			if (luaSprite != null) {
				if (front) {
					playstate.add(luaSprite);
					PlayState.addedSprites.set(name, true);
				}
				else {
					var pos:Int = playstate.getBehindPos();
					playstate.insert(pos, luaSprite);
					PlayState.addedSprites.set(name, true);
				}
			}

		}
	}
	
	public function removeLuaSprite(name:String, erase:Bool) {
		if (PlayState.luaSprites.exists(name)) {
			var luaSprite:LuaSprite = PlayState.luaSprites.get(name);

			if (erase) {
				luaSprite.kill();
				luaSprite.destroy();
				PlayState.luaSprites.remove(name);
			}

			if (PlayState.addedSprites.exists(name)) {
				playstate.remove(luaSprite);
				PlayState.addedSprites.remove(name);
			}
		}
	}

	public function addAnimByIndices(name:String, anim:String, prefix:String, indices:String, fps:Int = 24, loop:Bool = false) {
		var indicesArray:Array<Int> = getIndicesFromString(indices);
		var sprite:LuaSprite = null;
		var flSprite:FlxSprite = null;

		if (PlayState.luaSprites.exists(name))
			sprite = PlayState.luaSprites.get(name);
		else
			flSprite = Reflect.getProperty(PlayState, name);

		if (sprite != null) {
			sprite.animation.addByIndices(anim, prefix, indicesArray, '', fps, loop);
			if(sprite.animation.curAnim == null) {
				sprite.animation.play(name, true);
			}
		} else if (flSprite != null) {
			flSprite.animation.addByIndices(anim, prefix, indicesArray, '', fps, loop);
			if(flSprite.animation.curAnim == null) {
				flSprite.animation.play(name, true);
			}
		}
	}

	public function getIndicesFromString(str:String):Array<Int> {
		var strArray:Array<String> = str.trim().split(',');
		var returnValue:Array<Int> = [];

		for (i in 0...strArray.length)
			returnValue.push(Std.parseInt(strArray[i]));

		return returnValue;
	}

	public function getSprite(name):Dynamic {
		if (PlayState.luaSprites.exists(name)) return PlayState.luaSprites.get(name);
		return Reflect.getProperty(PlayState, name);
	}

	public function getShaderObject(name:String):Dynamic {
		if (PlayState.playStatecams.exists(name)) return PlayState.playStatecams.get(name);
		if (PlayState.luaSprites.exists(name)) return PlayState.luaSprites.get(name);
		if (Std.isOfType(Reflect.getProperty(PlayState, name), LuaSprite) || Std.isOfType(Reflect.getProperty(PlayState, name), FlxSprite) || Std.isOfType(Reflect.getProperty(PlayState, name), FlxCamera))
			return Reflect.getProperty(PlayState, name);

		return null;
	}

	public function setObjectScale(name:String, xScale:Float, yScale:Float) {
		var obj:Dynamic = null;

		if (PlayState.luaSprites.exists(name))
			obj = PlayState.luaSprites.get(name);
		else
			obj = Reflect.getProperty(PlayState, name);

		var sprite:FlxSprite = obj;

		if (sprite != null)
			sprite.scale.set(xScale, yScale);
	}

	public function tweenX(id:String, obj:String, value:Dynamic, duration:Float, ease:String) {
		resetTween(id);
		var objectToTween:Dynamic = getSprite(id);

		if (objectToTween != null) {
			var tween:FlxTween = FlxTween.tween(objectToTween, {x: value}, duration, {
				ease: easeFromString(ease),
				onComplete: function(twn:FlxTween) {
					PlayState.instance.callLua('onTweenComplete', [id]);
					PlayState.instance.callLua('onTweenCompleted', [id]);//More psych engine support
					PlayState.luaTweens.remove(id);
				} 
			});

			PlayState.luaTweens.set(id, tween);
		}
	}
	
	public function tweenY(id:String, obj:String, value:Dynamic, duration:Float, ease:String) { //Just Copy and Pasted lol
		resetTween(id);
		var objectToTween:Dynamic = getSprite(id);

		if (objectToTween != null) {
			var tween:FlxTween = FlxTween.tween(objectToTween, {y: value}, duration, {
				ease: easeFromString(ease),
				onComplete: function(twn:FlxTween) {
					PlayState.instance.callLua('onTweenComplete', [id]);
					PlayState.instance.callLua('onTweenCompleted', [id]);//More psych engine support
					PlayState.luaTweens.remove(id);
				} 
			});

			PlayState.luaTweens.set(id, tween);
		}
	}
	
	public function tweenAngle(id:String, obj:String, value:Dynamic, duration:Float, ease:String) { //Just Copy and Pasted lol
		resetTween(id);
		var objectToTween:Dynamic = getSprite(id);

		if (objectToTween != null) {
			var tween:FlxTween = FlxTween.tween(objectToTween, {angle: value}, duration, {
				ease: easeFromString(ease),
				onComplete: function(twn:FlxTween) {
					PlayState.instance.callLua('onTweenComplete', [id]);
					PlayState.instance.callLua('onTweenCompleted', [id]);//More psych engine support
					PlayState.luaTweens.remove(id);
				} 
			});

			PlayState.luaTweens.set(id, tween);
		}
	}
	
	public function tweenAlpha(id:String, obj:String, value:Dynamic, duration:Float, ease:String) { //Just Copy and Pasted lol
		resetTween(id);
		var objectToTween:Dynamic = getSprite(id);

		if (objectToTween != null) {
			var tween:FlxTween = FlxTween.tween(objectToTween, {alpha: value}, duration, {
				ease: easeFromString(ease),
				onComplete: function(twn:FlxTween) {
					PlayState.instance.callLua('onTweenComplete', [id]);
					PlayState.instance.callLua('onTweenCompleted', [id]);//More psych engine support
					PlayState.luaTweens.remove(id);
				} 
			});

			PlayState.luaTweens.set(id, tween);
		}
	}
	
	public function tweenColor(id:String, obj:String, colorShit:String, duration:Float, ease:String) {
		resetTween(id);
		var objectToTween:Dynamic = getSprite(id);

		if (objectToTween != null) {
			var color:Int = colorFromString(colorShit);
			var currentColor:FlxColor = objectToTween.color;
			currentColor.alphaFloat = objectToTween.alpha;

			var tween:FlxTween = FlxTween.color(objectToTween, duration, currentColor, color, {
				ease: easeFromString(ease),
				onComplete: function(twn:FlxTween) {
					PlayState.instance.callLua('onTweenComplete', [id]);
					PlayState.instance.callLua('onTweenCompleted', [id]);//More psych engine support
					PlayState.luaTweens.remove(id);
				} 
			});

			PlayState.luaTweens.set(id, tween);
		}
	}

	public function resetTween(name:String) {
		if (PlayState.luaTweens.exists(name)) {
			var tween = PlayState.luaTweens.get(name);
			tween.cancel();
			tween.destroy();
			PlayState.luaTweens.remove(name);
		}
	}	

	public function colorFromString(str:String):Int {
		var returnColor:Int = Std.parseInt(str);
		if (!str.startsWith('0x'))
			returnColor = Std.parseInt('0xff' + str);

		return returnColor;
	}

	public function getProperty(variable:String):Dynamic
	{
		var returnVal:Dynamic = null;
		var varArray:Array<String> = variable.split('.');

		if (varArray.length > 1) {
			if (PlayState.luaSprites.exists(varArray[0]))
				returnVal = PlayState.luaSprites.get(varArray[0]);
			else
				returnVal = Reflect.getProperty(PlayState, varArray[0]);

			for (i in 1...varArray.length - 1)
				returnVal = Reflect.getProperty(returnVal, varArray[i]);

			returnVal = Reflect.getProperty(returnVal, varArray[varArray.length - 1]);
		}
		else
			returnVal = Reflect.getProperty(PlayState, variable);

		return returnVal;
	}

	public function getPropertyFromObject(obj:String, variable:String):Dynamic
	{
		var object:Dynamic = null;
		if (PlayState.luaSprites.exists(object)) object = PlayState.luaSprites.get(obj); else object = getProperty(obj);
		var returnThing:Dynamic = null;
		var varArray:Array<String> = variable.split('.');

		if (varArray.length > 1) {
			object = Reflect.getProperty(object, varArray[0]);

			for (i in 1...varArray.length - 1)
				object = Reflect.getProperty(object, varArray[i]);

			object = Reflect.getProperty(object, varArray[varArray.length - 1]);
		}
		else
			object = Reflect.getProperty(object, variable);

		returnThing = object;

		return returnThing;
	}
	
	public function setPropertyFromObject(object:String, variable:String, value:Dynamic) {
		var returnVal:Dynamic = null;
		var object:Dynamic = null;
		var varArray:Array<String> = variable.split('.');

		if (PlayState.luaSprites.exists(object)) object = PlayState.luaSprites.get(object); else object = Reflect.getProperty(PlayState, object);

		if (varArray.length > 1) {

			for (i in 1...varArray.length - 1)
				returnVal = Reflect.getProperty(object, varArray[i]);

			return Reflect.setProperty(object, varArray[varArray.length - 1], value);
		}
		else
			return Reflect.setProperty(PlayState, variable, value);

	}
	
	public function getPropertyFromGroup(object:String, index:Int, variable:Dynamic):Dynamic
	{
		if (Std.isOfType(Reflect.getProperty(PlayState, object), FlxTypedGroup))
			return propertyFromGroup(Reflect.getProperty(PlayState, object), variable);

		if (Reflect.getProperty(PlayState, object) == null) {
			var wtf:Dynamic = Reflect.getProperty(PlayState, object)[index];
			if (wtf != null) {
				if(Type.typeof(variable) == ValueType.TInt){
						return wtf[variable];
				}

				return propertyFromGroup(wtf, variable);
			}
		}

		return null;
	}
	
	public function setPropertyFromGroup(object:Dynamic, index:Int, variable:String, value:String)
	{
		var varArray:Array<String> = variable.split('.');

		if (Reflect.getProperty(PlayState, object) == null) {
			if (Std.isOfType(Reflect.getProperty(PlayState, object), FlxTypedGroup))
				return spfg(Reflect.getProperty(PlayState, object).members[index], variable, value);

			if (varArray.length > 1) {
				var what:Dynamic = Reflect.getProperty(object[index], varArray[0]);
				for (i in 1...varArray.length - 1)
					what = Reflect.getProperty(what, varArray[i]);

				return Reflect.setProperty(what, varArray[varArray.length - 1], value);
			}
		}

		return Reflect.setProperty(object, variable, value);
	}

	public function spfg(groupObject:Dynamic, variable:String, value:Dynamic) {
		var varArray:Array<String> = variable.split('.');

		if (varArray.length > 1) {
			var huh:Dynamic = Reflect.getProperty(groupObject, varArray[0]);

			for (i in 1...varArray.length - 1)
				huh = Reflect.getProperty(huh, varArray[i]);

			return Reflect.setProperty(huh, varArray[varArray.length - 1], value);
		}

		return Reflect.setProperty(groupObject, variable, value);
	}
	
	public function propertyFromGroup(groupObject:Dynamic, variable:String) {
		var varArray:Array<String> = variable.split('.');
		if (varArray.length > 1) {
			var what:Dynamic = Reflect.getProperty(groupObject, varArray[0]);
			for (i in 1...varArray.length - 1)
				what = Reflect.getProperty(what, varArray[i]);

			return Reflect.getProperty(what, varArray[varArray.length - 1]);
		}

		return Reflect.getProperty(groupObject, variable);
	}

	public function setProperty(variable:String, value:Dynamic) {
		var returnVal:Dynamic = null;
		var object:Dynamic = null;
		var varArray:Array<String> = variable.split('.');

		if (varArray.length > 1) {
			if (PlayState.luaSprites.exists(varArray[0]))
				object = PlayState.luaSprites.get(varArray[0]);
			else
				object = Reflect.getProperty(PlayState, varArray[0]);

			for (i in 1...varArray.length - 1)
				object = Reflect.getProperty(object, varArray[i]);

			return Reflect.setProperty(object, varArray[varArray.length - 1], value);
		}
		else
			return Reflect.setProperty(PlayState, variable, value);
	}

	public function getShader(object:String):FlxRuntimeShader {
		var spriteObj:Dynamic = getShaderObject(object);

		if (spriteObj != null) {
			var spriteShader:Dynamic = null;

			if (Std.isOfType(spriteObj, FlxCamera) && PlayState.cameraShaders.exists(object)) {
				spriteShader = PlayState.cameraShaders.get(object);
			}
			else {
				spriteShader = spriteObj.shader;
			}
			var shader:FlxRuntimeShader = spriteShader;
			return shader;
		}

		return null;
	}

	public function playObjAnim(name:String, anim:String, forced:Bool = false) {
		var sprite:FlxSprite = getSprite(name);

		if (sprite != null) {
			sprite.animation.play(anim, forced);
		}
	}

	public function addLibrary(name:String = '', packageNme:String = '') {
		if (hscript != null && (name != null && name != '')) {
			try {
				var packageStr:String = '';
				if (packageNme.length > 0) {
					packageStr = '$packageNme.';
				}

				hscript.interp.variables.set(name, Type.resolveClass(packageStr + name));
			}
			catch(e:Dynamic) {
				Main.loggedErrors.push(hscript.moduleID + ' - ' + Std.string(e));
				trace(e);
			}
		}
	}

	public function easeFromString(ease:String) {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	public function blendFromString(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
	}

	public function close() {
		if (lua == null)
			return;

		Lua.close(lua);
		lua = null;
		isClosed = true;
	}
}

class LuaSprite extends FlxSprite
{
	public var animOffsets:Map<String, Dynamic>;

	public function new(x:Float, y:Float) {
		animOffsets = new Map<String, Dynamic>();

		super(x, y);
	}

	public function addOffset(name:String, x:Float, y:Float)
		animOffsets[name] = [x, y];

	public function playAnim(animName:String, forced:Bool = false, reversed:Bool = false, framerate:Int = 24) {
		if (animation.getByName(animName) != null) {
			var offsets:Array<Float> = animOffsets.get(animName);

			animation.play(animName, forced, reversed, framerate);

			if (animOffsets.exists(animName))
				offset.set(offsets[0], offsets[1]);
			else
				offset.set(0, 0);
		}
	}
}