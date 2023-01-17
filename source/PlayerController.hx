package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class PlayerController
{
	public static var playerControl:Controls;
	public static var activePlayers:Array<Controls> = [];
	
	public static function setKeybordScheme(scheme){
		playerControl.setKeyboardScheme(scheme);
	}

	public static function init() {
		if (playerControl == null)
		{
			playerControl = new Controls('0', Solo);
			activePlayers.push(playerControl);
		}

		var activeControllers = FlxG.gamepads.numActiveGamepads;
		
		if (activeControllers > 0)
		{
			var gamepad = FlxG.gamepads.getByID(0);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:0';

			playerControl.addDefaultGamepad(0);
		}
		else if (activeControllers > 1)
		{
			for (player in 0...activeControllers)
			{
				activePlayers.push(new Controls('$player', Solo));
				var gamepad = FlxG.gamepads.getByID(player);
				if (gamepad == null)
					throw 'Unexpected null gamepad. id:$player';

				activePlayers[player].addDefaultGamepad(player);
			}
		}

	}
}
