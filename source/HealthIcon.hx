package;

import flixel.FlxSprite;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef AnimatedData = 
{
	var losingAnim:String;
	var neutralAnim:String;
	var image:String;
}

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var iconIsAnimated:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?animData:AnimatedData)
	{
		super();
		changeIcon(char, isPlayer, animData);
		scrollFactor.set();
	}

	public function changeIcon(char:String, isPlayer:Bool = false, ?animData:AnimatedData)
	{
		if (animData != null){
			frames = Paths.getSparrowAtlas(animData.image);
			animation.addByPrefix("winning", animData.neutralAnim, 24, true);
		}
		else
		{
			#if desktop
			if (FileSystem.exists(Paths.modImages('icons/$char')))
				loadGraphic(Paths.getImage('icons/$char'), true, 150, 150);
			else if (FileSystem.exists(Paths.modImages('icons/icon-$char')))
				loadGraphic(Paths.getImage('icons/icon-$char'), true, 150, 150);
			else #end if (Assets.exists(Paths.imagePth('icons/$char')))
				loadGraphic(Paths.image('icons/$char'), true, 150, 150);
			else if (Assets.exists(Paths.imagePth('icons/icon-$char')))
				loadGraphic(Paths.image('icons/icon-$char'), true, 150, 150);
			else
				loadGraphic(Paths.image('icons/icon-face'), true, 150, 150);
			
			animation.add(char, [0, 1], 0, false, isPlayer);
			animation.play(char);
			antialiasing = true;
		}

		if (char.endsWith('-pixel')) {
			antialiasing = false;
		}

		iconIsAnimated = false;
		if (antialiasing)
			antialiasing = PlayerPrefs.antialiasing;

		if (this == null) {
			trace('icon with character ' + char + ' is null!');
			loadGraphic(Paths.image("icons/icon-face"), true, 150, 150);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
