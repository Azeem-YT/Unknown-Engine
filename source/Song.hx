package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if desktop
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var arrowTexture:String;
	var numbPlayers:Int;
	var threePlayer:Bool;
	var splashJson:String;
	var validScore:Bool;
	#if desktop
	var events:Array<Dynamic>;
	#end
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = null;
		
		#if desktop
		if (FileSystem.exists(Paths.modJson('data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase()))) {
			rawJson = File.getContent(Paths.modJson('data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase()));
			Paths.currentSongDir = Paths.mods('data/' + folder.toLowerCase() + '/');
		}
		else {
			if (Assets.exists(Paths.json('data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase()))) {
				rawJson = Assets.getText(Paths.json('data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();
				Paths.currentSongDir = Paths.getPreloadPath('data/' + folder.toLowerCase() + '/');
			}
		}
		#else
		if (Assets.exists(Paths.json('data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase()))) {
			rawJson = Assets.getText(Paths.json('data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();
			Paths.currentSongDir = Paths.getPreloadPath('data/' + folder.toLowerCase() + '/');
		}
		#end

		while (!rawJson.endsWith("}") && rawJson != null)
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		if (rawJson != null)
			return parseJSONshit(rawJson);

		return null;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
