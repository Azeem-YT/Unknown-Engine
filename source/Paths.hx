package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if desktop
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
#end

import flash.media.Sound;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	public static var modInst:Map<String, Sound> = new Map<String, Sound>();
	public static var modVoices:Map<String, Sound> = new Map<String, Sound>();
	public static var loadedSounds:Map<String, Sound> = new Map<String, Sound>();
	public static var currentSongDir:String = 'assets/songs/tutorial';

	static var currentLevel:String = 'assets/';

	static public function setCurrentLevel(name:String) {
	 	currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	public inline static function getPreloadPath(?file:String)
	{
		if (file != null)
			return 'assets/$file';
		else
			return 'assets/';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
		return getPath(file, type, library);

	inline static public function txt(key:String, ?library:String):Any {
		#if desktop
		if (FileSystem.exists(mods('$key.txt')))
			return mods('key.txt');
		#end

		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
		return getPath('$key.xml', TEXT, library);

	inline static public function json(key:String, ?library:String)
		return getPath('$key.json', TEXT, library);

	inline static public function lua(key:String, ?library:String)
		return getPath('$key.lua', TEXT, library);

	static public function sound(key:String, ?library:String):Any
	{
		#if desktop
		var soundFile:Sound = null;

		if (FileSystem.exists(key))
		{
			if (!loadedSounds.exists(key))
				loadedSounds.set(key, Sound.fromFile(key));

			soundFile = loadedSounds.get(key);
		}

		if (soundFile != null)
			return soundFile;
		#end

		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):Any
	{
		var soundKey:String = key + FlxG.random.int(min, max);

		#if desktop
		var soundFile:Sound = null;

		if (FileSystem.exists(soundKey))
		{
			if (!loadedSounds.exists(soundKey))
				loadedSounds.set(soundKey, Sound.fromFile(soundKey));

			soundFile = loadedSounds.get(soundKey);
		}

		if (soundFile != null)
			return soundFile;
		#end

		return sound(soundKey, library);
	}

	inline static public function music(key:String, ?library:String):Any
	{
		#if desktop
		var soundFile:Sound = null;

		if (FileSystem.exists(key))
		{
			if (!loadedSounds.exists(key))
				loadedSounds.set(key, Sound.fromFile(key));

			soundFile = loadedSounds.get(key);
		}

		if (soundFile != null)
			return soundFile;
		#end

		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):Any
	{
		song = song.toLowerCase();

		#if desktop
		var songFile:Sound = null;

		if (FileSystem.exists(modvoices(song)))
		{
			if (!modVoices.exists(song))
				modVoices.set(song, Sound.fromFile(modvoices(song)));

			songFile = modVoices.get(song);
		}

		if (songFile != null)
			return songFile;
		#end

		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String):Any
	{
		song = song.toLowerCase();

		#if desktop
		var songFile:Sound = null;

		if (FileSystem.exists(modinst(song)))
		{
			if (!modInst.exists(song))
				modInst.set(song, Sound.fromFile(modinst(song)));

			songFile = modInst.get(song);
		}

		if (songFile != null)
			return songFile;
		#end

		return 'songs:assets/songs/$song/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String):Any
	{
		#if desktop
		var graphic:FlxGraphic;
		graphic = getImage(key);

		if (graphic != null)
			return graphic;
		#end

		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function imagePth(key:String, ?library:String)
		return getPath('images/$key.png', IMAGE, library);

	inline static public function mp3(key:String, ?library:String):Any {
		#if desktop
		var soundFile:Sound = null;
		var modKey:String = 'sounds/$key.mp3';

		if (FileSystem.exists(modKey))
		{
			if (!loadedSounds.exists(modKey))
				loadedSounds.set(key, Sound.fromFile(modKey));

			soundFile = loadedSounds.get(modKey);
		}

		if (soundFile != null)
			return soundFile;
		#end

		return getPath('music/$key.mp3', MUSIC, library);
	}

	inline static public function module(key:String, ?library:String)
		return getPath('modules/$key.hxs', TEXT, library);

	/*
		inline static public function getCharMod(char:String = 'bf') {
			#if desktop
			if (FileSystem.exists(Paths.mods('modules/characters/$char.hxs'))
				return Paths.mods('modules/characters/$char.hxs');
			else
				return module('characters/' + char;
			#end
	*/

	inline static public function video(key:String)
	{
		#if desktop
		if (FileSystem.exists(mods('videos/' + key)))
			return mods('videos/' + key);
		else
		#end
			return 'assets/videos/$key';
	}

	inline static public function font(key:String)
	{
		#if desktop
		if (FileSystem.exists(modFonts(key)))
			return modFonts(key);
		else
		#end
			return 'assets/fonts/$key';
	}

	inline static public function modules(key:String)
	{
		#if desktop
		if (FileSystem.exists(Paths.modModules(key)))
			return modModules(key);
		else
		#end
			return getPreloadPath('modules/$key.hxs');
	}

	inline static public function getSparrowAtlas(key:String, ?library:String) {
		#if desktop
		var sparrow = getModSparrowAtlas(key);

		if (sparrow != null)
			return sparrow;
		#end
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String) {
		#if desktop
		var packer = getModPackerAtlas(key);

		if (packer != null)
			return packer;
		#end

		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function getSongPath(song:String) {
		song = song.toLowerCase();
		return 'assets/data/$song/';
	}

	#if desktop
	public static var graphicIsLoaded:Map<String, Bool> = new Map<String, Bool>();

	inline static public function mods(key:String = '') {
		if (key != '' && key != null)
			return 'mods/$key';
		else
			return 'mods/';
	}

	inline static public function stageLua(file:String)
		return mods('stages/$file.lua');

	inline static public function modJson(key:String = '') 
		return mods('$key.json');

	inline static public function modMusic(key:String = '')
		return mods('music/$key.$SOUND_EXT');

	inline static public function modSounds(key:String = '')
		return mods('sounds/$key.$SOUND_EXT');

	inline static public function modImages(key:String = '')
		return mods('images/$key.png');

	inline static public function modXml(key:String = '')
		return mods('$key.xml');

	inline static public function modTxt(key:String = '')
		return mods('$key.txt');

	inline static public function modvoices(song:String) {
		var path:String = mods('songs/$song/Voices.$SOUND_EXT');
		return path;
	}

	inline static public function modinst(song:String) {
		var path:String = mods('songs/$song/Inst.$SOUND_EXT');
		return path;
	}

	inline static public function modFonts(key:String)
		return mods('fonts/$key');

	inline static function getFileContent(file:String, ?fileExtention:String)
	{
		if (FileSystem.exists(mods(file)))
			return File.getContent(mods(file));

		return null;
	}

	inline static public function loadSound(key:String):Any
	{
		var soundFile:Sound = null;

		if (FileSystem.exists(modSounds(key)))
		{
			if (!loadedSounds.exists(key))
				loadedSounds.set(key, Sound.fromFile(modSounds(key)));

			soundFile = loadedSounds.get(key);
		}

		if (soundFile != null)
			return soundFile;
		else
			return '';
	}

	inline static public function getImage(key:String):FlxGraphic
	{
		if (FileSystem.exists(modImages(key)))
		{
			if (!graphicIsLoaded.exists(key))
			{
				var bitmap:BitmapData = BitmapData.fromFile(modImages(key));
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
				graphic.persist = true; //Game crashes if I dont do this.
				FlxG.bitmap.addGraphic(graphic);
				graphicIsLoaded.set(key, true);
			}

			return FlxG.bitmap.get(key);
		}

		return null;
	}

	inline static public function modModules(key:String)
	{
		return mods('modules/$key.hxs');
	}

	inline static public function removeLoadedImages()
	{
		for (image in graphicIsLoaded.keys())
		{
			var graphic:FlxGraphic = FlxG.bitmap.get(image);
			if (graphic != null)
			{
				FlxG.bitmap.removeByKey(image);
				graphic.bitmap.dispose();
				graphic.destroy();
			}
		}

		graphicIsLoaded.clear();
	}

	inline static public function getModSparrowAtlas(key:String) {
		var graphic:FlxGraphic = getImage(key);

		return FlxAtlasFrames.fromSparrow(graphic, getFileContent('images/$key.xml'));
	}

	inline static public function getModPackerAtlas(key:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(getImage(key), getFileContent('images/$key.txt'));
	#end
}
