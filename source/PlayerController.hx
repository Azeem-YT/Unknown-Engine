package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.input.actions.FlxActionInput;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxSignal;

using StringTools;

class PlayerController
{
	public static var playerControl:Controls;
	public static var activePlayers:Array<Controls> = [];
	public static var id:Int = 0;
	
	public static function setKeybordScheme(scheme){
		playerControl.setKeyboardScheme(scheme);
	}

	public static function init() {
		if (playerControl == null) {
			playerControl = new Controls('0', Solo);
			activePlayers.push(playerControl);
		}

		var useDefault = true;
		var controlData = FlxG.save.data.controls;
		if (controlData != null) {
			var keyData:Dynamic = null;
			if (id == 0 && controlData.p1 != null && controlData.p1.keys != null)
				keyData = controlData.p1.keys;
			else if (id == 1 && controlData.p2 != null && controlData.p2.keys != null)
				keyData = controlData.p2.keys;
			
			if (keyData != null) {
				useDefault = false;
				playerControl.fromSaveData(keyData, Keys);
			}
		}
		
		if (useDefault)
			playerControl.setKeyboardScheme(Solo);
	}

	public static function saveControls()
	{
		if (FlxG.save.data.controls == null)
			FlxG.save.data.controls = {};
		
		var playerData:{ ?keys:Dynamic, ?pad:Dynamic }
		if (id == 0)
		{
			if (FlxG.save.data.controls.p1 == null)
				FlxG.save.data.controls.p1 = {};
			playerData = FlxG.save.data.controls.p1;
		}
		else
		{
			if (FlxG.save.data.controls.p2 == null)
				FlxG.save.data.controls.p2 = {};
			playerData = FlxG.save.data.controls.p2;
		}
		
		var keyData = playerControl.createSaveData(Keys);
		if (keyData != null) {
			playerData.keys = keyData;
		}
		
		if (playerControl.gamepadsAdded.length > 0)
		{
			var padData = playerControl.createSaveData(Gamepad(playerControl.gamepadsAdded[0]));
			if (padData != null)
			{
				trace("saving pad data: " + haxe.Json.stringify(padData));
				playerData.pad = padData;
			}
		}
		
		FlxG.save.flush();
	}
}
