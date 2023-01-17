package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import Controls;

using StringTools;

class PlayerPrefs
{
	public static var fpsCap:Float = 144.0;
	public static var downscroll:Bool = false;
	public static var middlescroll:Bool = false;
	public static var fpsCounter:Bool = false;
	public static var botplay:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var timeType:String = 'Time Elapsed';
	public static var hudAlpha:Float = 1.0;
	public static var healthAlpha = 1.0;
	public static var timeBarAlpha:Float = 1.0;
	public static var disableReset:Bool = false;
	public static var camCanZoom:Bool = true;
	public static var loadedPrefs:Bool = false;
	public static var volumeKeys:Map<String, Array<String>> = [
		'volume_mute' => ['zero', 'none'],
		'volume_up' => ['numpadplus', 'none'],
		'volume_down' => ['numpadminus', 'none']
	];

	public static function savePrefs() {
		if (!loadedPrefs)
			resetPrefs();

		FlxG.save.data.downscroll = downscroll;
		FlxG.save.data.middlescroll = middlescroll;
		FlxG.save.data.fpsCap = fpsCap;
		FlxG.save.data.botplay = botplay;
		FlxG.save.data.fpsCounter = fpsCounter;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.timeType = timeType;
		FlxG.save.data.camCanZoom = camCanZoom;
		FlxG.save.data.disableReset = disableReset;
		FlxG.save.data.timeBarAlpha = timeBarAlpha;
		FlxG.save.data.hudAlpha = hudAlpha;
		FlxG.save.data.healthAlpha = healthAlpha;
	}

	public static function resetPrefs() {
		if(FlxG.save.data.downscroll != null) {
			downscroll = FlxG.save.data.downscroll;
		}
		if(FlxG.save.data.middlescroll != null) {
			middlescroll = FlxG.save.data.middlescroll;
		}
		if(FlxG.save.data.botplay != null) {
			botplay = FlxG.save.data.botplay;
		}
		if(FlxG.save.data.fpsCounter != null) {
			fpsCounter = FlxG.save.data.fpsCounter;
		}
		
		if(FlxG.save.data.noteSplashes != null) {
			fpsCounter = FlxG.save.data.noteSplashes;
		}

		if(FlxG.save.data.timeType != null) {
			fpsCounter = FlxG.save.data.timeType;
		}

		if(FlxG.save.data.camCanZoom != null) {
			camCanZoom = FlxG.save.data.camCanZoom;
		}

		if(FlxG.save.data.disableReset != null) {
			disableReset = FlxG.save.data.disableReset;
		}

		if(FlxG.save.data.timeBarAlpha != null) {
			timeBarAlpha = FlxG.save.data.timeBarAlpha;
		}

		if(FlxG.save.data.hudAlpha != null) {
			hudAlpha = FlxG.save.data.hudAlpha;
		}

		if(FlxG.save.data.healthAlpha != null) {
			healthAlpha = FlxG.save.data.healthAlpha;
		}

		if(FlxG.save.data.fpsCap != null) {
			fpsCap = FlxG.save.data.fpsCap;
		} else {
			fpsCap = 144.0;
		}

		setFramerate();

		if (!loadedPrefs)
			loadedPrefs = true;
	}

	public static function resetControls() {
		PlayerController.playerControl.setKeyboardScheme(KeyboardScheme.Solo);

		FlxG.sound.muteKeys = getKeys(volumeKeys.get('volume_mute'));
		FlxG.sound.volumeDownKeys = getKeys(volumeKeys.get('volume_down'));
		FlxG.sound.volumeUpKeys = getKeys(volumeKeys.get('volume_up'));
	}

	public static function setFramerate() {
		FlxG.save.data.fpsCap = fpsCap;
		if (fpsCap < 30)
			fpsCap = 30; //Make sure you dont soft lock ur game
		FlxG.updateFramerate = Math.round(fpsCap);
		FlxG.drawFramerate = Math.round(fpsCap);
	}

	public static function getKeys(keyArray:Array<String>):Array<FlxKey>
	{
		var returnArray:Array<FlxKey> = [];
		
		for (i in 0...keyArray.length) {
			var key:String = keyArray[i].toUpperCase();
			if(key != 'NONE') {
				returnArray.push(FlxKey.fromString(key));
			}
		}

		return returnArray;
	}

}
