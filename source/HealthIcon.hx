package;

import flixel.FlxSprite;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		changeIcon(char, isPlayer);
		scrollFactor.set();
	}

	public function changeIcon(char:String, isPlayer:Bool = false)
	{
		#if desktop
		if (FileSystem.exists(Paths.modImages("icons/" + char)))
			loadGraphic(Paths.modImages("icons/" + char), true, 150, 150);
		else #end if (Assets.exists(Paths.image("icons/" + char)))
			loadGraphic(Paths.image("icons/" + char), true, 150, 150);
		else
			loadGraphic(Paths.image("icons/icon-face"), true, 150, 150);
			
		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
		antialiasing = true;

		if (char.endsWith('-pixel')) 
		{
			antialiasing = false;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
