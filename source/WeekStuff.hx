package;

import flixel.FlxG;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;
import haxe.format.JsonParser;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef WeekData
{
	var songs:Array<Dynamic>;
	var characters:Array<String>;
	var storyPngFile:String;
	var weekTitle:String;
	var isUnlocked:Bool;
}

class WeekStuffs
{
	public var daFolder:String = '';
	var songs:Array<Dynamic>;
	var characters:Array<String>;
	var storyPngFile:String;
	var weekTitle:String;
	var isUnlocked:Bool;

	public static function createFile():WeekData
	{
		var weekFile:WeekData = {
		
			songs: ["Tutorial"],
			characters: ['dad', 'bf', 'gf'],
			storyPngFile: "week1",
			weekTitle: "custom Week",
			isUnlocked: true
		};

		return weekFile;
	}

	public function new(weekFile:WeekData, path:String)
	{
		songs = weekFile.songs;
		characters = weekFile.characters;
		storyPngFile = weekFile.storyPngFile;
		weekTitle = weekFile.weekTitle;
		isUnlocked = weekFile.isUnlocked
	}

	public static function reloadStoryWeek()
	{
		weeksList = [];
		weeksLoaded.clear();
		#if MODDING_ALLOWED
		var disabledMods:Array<String> = [];
		var modsListPath:String = 'modsList.txt';
		var directories:Array<String> = [Paths.getModPreloadPath(), Paths.getPreloadPath()];
		var originalLength:Int = directories.length;
		if(FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				if(splitName[1] == '0') // Disable mod
				{
					disabledMods.push(splitName[0]);
				}
				else // Sort mod loading order based on modsList.txt file
				{
					var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
					//trace('trying to push: ' + splitName[0]);
					if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.contains(splitName[0]) && !disabledMods.contains(splitName[0]) && !directories.contains(path + '/'))
					{
						directories.push(path + '/');
						//trace('pushed Directory: ' + splitName[0]);
					}
				}
			}
		}

		var modsDirectories:Array<String> = Paths.getModDirectories();
		for (folder in modsDirectories)
		{
			var pathThing:String = haxe.io.Path.join([Paths.mods(), folder]) + '/';
			if (!disabledMods.contains(folder) && !directories.contains(pathThing))
			{
				directories.push(pathThing);
				//trace('pushed Directory: ' + folder);
			}
		}
		#else
		var directories:Array<String> = [Paths.getPreloadPath()];
		var originalLength:Int = directories.length;
		#end

		var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getPreloadPath('weeks/weekList.txt'));
		for (i in 0...sexList.length) {
			for (j in 0...directories.length) {
				var fileToCheck:String = directories[j] + 'weeks/' + sexList[i] + '.json';
				if(!weeksLoaded.exists(sexList[i])) {
					var week:WeekFile = getWeekFile(fileToCheck);
					if(week != null) {
						var weekFile:WeekData = new WeekData(week, sexList[i]);

						#if MODDING_ALLOWED
						if(j >= originalLength) {
							weekFile.folder = directories[j].substring(Paths.mods().length, directories[j].length-1);
						}
						#end

						if(weekFile != null && (isStoryMode == null || (isStoryMode && !weekFile.hideStoryMode) || (!isStoryMode && !weekFile.hideFreeplay))) {
							weeksLoaded.set(sexList[i], weekFile);
							weeksList.push(sexList[i]);
						}
					}
				}
			}
		}

		#if MODDING_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i] + 'weeks/';
			if(FileSystem.exists(directory)) {
				var listOfWeeks:Array<String> = CoolUtil.coolTextFile(directory + 'weekList.txt');
				for (daWeek in listOfWeeks)
				{
					var path:String = directory + daWeek + '.json';
					if(sys.FileSystem.exists(path))
					{
						addWeek(daWeek, path, directories[i], i, originalLength);
					}
				}

				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json'))
					{
						addWeek(file.substr(0, file.length - 5), path, directories[i], i, originalLength);
					}
				}
			}
		}
		#end
	}

	public static function reloadFreeplayWeek()
	{
		
	}

	public function loadWeek(path:String)
	{
		var shit:String = null;
		if (Assets.exists(path))
		{
			rawJson = Assets.getText(path);
		}

		if (rawJson != null && rawJson.length > 0)
		{
			return cast Json.parse(rawJson);
		}

		return null;
	}
}