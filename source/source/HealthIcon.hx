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
	public var iconIsAnimated:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?isAnimated:Bool = false, ?animArray:Array<String>, ?looped:Bool = false, ?scale:Float = 1)
	{
		super();
		changeIcon(char, isPlayer, isAnimated, animArray, looped, scale);
		scrollFactor.set();
	}

	public function changeIcon(char:String, isPlayer:Bool = false, ?isAnimated:Bool = false, ?animArray:Array<String>, ?looped:Bool = false, ?scale:Float = 1)
	{
		if (isAnimated){
			#if desktop
				frames = Paths.getModSparrowAtlas("icons/" + char);

				if (frames == null)
			#end
				frames = Paths.getSparrowAtlas("icons/" + char);

				if (frames != null){
					if (animArray != null){
						animation.addByPrefix('normal', animArray[0], 24, looped);
						animation.addByPrefix('losing', animArray[0], 24, looped);
					}
					else {
						animation.addByPrefix('normal', animArray[0], 24, looped);
						animation.addByPrefix('losing', animArray[1], 24, looped);
					}

					if (scale != 1)
						setGraphicSize(Std.int(width * scale));

					animation.play('normal');
				}

				if (frames == null){
					#if desktop
					if (FileSystem.exists(Paths.modImages("icons/" + char)))
						loadGraphic(Paths.getImage("icons/" + char), true, 150, 150);
					else #end if (Assets.exists(Paths.image("icons/" + char)))
						loadGraphic(Paths.image("icons/" + char), true, 150, 150);
					else
						loadGraphic(Paths.image("icons/icon-face"), true, 150, 150);
					isAnimated = false;
				}

				antialiasing = true;
		}
		else
		{
			#if desktop
			if (FileSystem.exists(Paths.modImages("icons/" + char)))
				loadGraphic(Paths.getImage("icons/" + char), true, 150, 150);
			else #end if (Assets.exists(Paths.image("icons/" + char)))
				loadGraphic(Paths.image("icons/" + char), true, 150, 150);
			else
				loadGraphic(Paths.image("icons/icon-face"), true, 150, 150);
			
			animation.add(char, [0, 1], 0, false, isPlayer);
			isAnimated = false;
			animation.play(char);
			antialiasing = true;
		}

		if (char.endsWith('-pixel')) {
			antialiasing = false;
		}

		iconIsAnimated = isAnimated;
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
