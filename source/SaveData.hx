package;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

using StringTools;

class SaveData
{
	public static var leftKeybind:String;
	public static var downKeybind:String;
	public static var upKeybind:String;
	public static var rightKeybind:String;
	public static var dodgeKeybind:String;

	public static function checkKeybinds()
	{
		if (FlxG.save.data.downBind == null)
		{
			FlxG.save.data.downBind = "S";
		}

		if (FlxG.save.data.upBind == null)
		{
			FlxG.save.data.upBind = "W";
		}

		if (FlxG.save.data.leftBind == null)
		{
			FlxG.save.data.leftBind = "A";
		}

		if (FlxG.save.data.rightBind == null)
		{
			FlxG.save.data.rightBind = "D";
		}

		if (FlxG.save.data.resetBind == null)
		{
			FlxG.save.data.resetBind = "R";
		}

		if (FlxG.save.data.dodgeBind == null)
		{
			FlxG.save.data.dodgeBind = "SPACE";
		}

		if (FlxG.save.data.uiDownBind == null)
		{
			FlxG.save.data.downBind = "S";
		}

		if (FlxG.save.data.uiUpBind == null)
		{
			FlxG.save.data.upBind = "W";
		}

		if (FlxG.save.data.uiLeftBind == null)
		{
			FlxG.save.data.leftBind = "A";
		}

		if (FlxG.save.data.uiRightBind == null)
		{
			FlxG.save.data.rightBind = "D";
		}

		leftKeybind = FlxG.save.data.leftBind; 
		downKeybind = FlxG.save.data.downBind;
		upKeybind = FlxG.save.data.upBind;
		rightKeybind = FlxG.save.data.rightBind;
		dodgeKeybind = FlxG.save.data.dodgeBind;

		trace("Current Keybinds: " + leftKeybind + ", " + downKeybind + ", " + upKeybind + ", " + rightKeybind + ", " + dodgeKeybind);
	}

	public static function checkVars()
	{
		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;
		if (FlxG.save.data.middlescroll == null)
			FlxG.save.data.middlescroll = false;
		if (FlxG.save.data.ghostTapping == null)
			FlxG.save.data.ghostTapping = true;
		if (FlxG.save.data.fpsCounter == null)
			FlxG.save.data.fpsCounter = true;
		if (FlxG.save.data.opponentSide ==  null)
			FlxG.save.data.opponentSide = true;
		if (FlxG.save.data.fpsR == null)
			FlxG.save.data.fpsR = 144.0;
	}
}
