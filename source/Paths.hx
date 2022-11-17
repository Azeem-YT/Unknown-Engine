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

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
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
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('$key.json', TEXT, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):Any
	{
		#if desktop
		var songFile:Sound = null;

		if (FileSystem.exists(modvoices(song)))
		{
			if (!modInst.exists(song))
				modInst.set(song, Sound.fromFile(modvoices(song)));

			songFile = modInst.get(song);
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

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function mp3(key:String, ?library:String)
	{
		return getPath('music/$key.mp3', MUSIC, library);
	}

	inline static public function module(key:String, ?library:String)
	{
		return getPath('modules/$key.hxs', TEXT, library);
	}

	inline static public function video(key:String)
	{
		return 'assets/videos/$key';
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function getSongPath(song:String)
	{
		song = song.toLowerCase();

		return 'assets/data/$song/';
	}

	#if desktop
	inline static public function mods(key:String = '') //getModPath was so useless. It prevented the images and other stuff to be loaded
	{
		return 'mods/' + key;
	}
	
	public inline static function getModPreloadPath(?file:String)
	{
		if (file != '' && file != null)
			return 'mods/$file';
		else
			return 'mods/';
	}

	inline static function getModLibraryPathForce(file:String, library:String)
	{
		return '$library:mods/$library/$file';
	}

	inline static public function stageLua(file:String, ?library)
	{
		return mods('stages/$file.lua');
	}

	inline static public function modJson(key:String = '', ?library:String) 
	{
		return mods('$key.json');
	}

	inline static public function modMusic(key:String = '', ?library:String)
	{
		return mods('music/$key.$SOUND_EXT');
	}

	inline static public function modSounds(key:String = '', ?library:String)
	{
		return mods('sounds/$key.$SOUND_EXT');
	}
	inline static public function modImages(key:String = '', ?library:String)
	{
		return mods('images/$key.png');
	}
	inline static public function modXml(key:String = '', ?library:String)
	{
		return mods('$key.xml');
	}
	inline static public function modTxt(key:String = '', ?library:String)
	{
		return mods('$key.txt');
	}
	inline static public function modvoices(song:String)
	{
		var songLowerCase:String = song.toLowerCase();
		return 'mods/songs/' + songLowerCase + '/Voices.$SOUND_EXT';
	}

	inline static public function modinst(song:String)
	{
		var songLowerCase:String = song.toLowerCase();
		return 'mods/songs/' + songLowerCase + 'Inst.$SOUND_EXT';
	}

	inline static public function getModSparrowAtlas(key:String)
	{
		return FlxAtlasFrames.fromSparrow(modImages(key), file('images/$key.xml'));
	}

	inline static public function getModPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(modImages(key, library), file('images/$key.txt', library));
	}
	#end
}
