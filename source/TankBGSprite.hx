package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class TankBGSprite extends FlxSprite
{
	public var defaultAnim:String = null;

	public function new(image:String, x:Float, y:Float, ?xScroll:Float = 1, ?yScroll:Float = 1, ?anims:Array<String> = null, ?loop:Bool = false)
	{
		super(x, y);

		if (anims != null)
		{
			frames = Paths.getSparrowAtlas(image);
			for (i in 0...anims.length) {
				animation.addByPrefix(anims[i], anims[i], 24, loop);

				if (defaultAnim == null)
				{
					defaultAnim = anims[i];
					animation.play(anims[i]);
				}
			}
		}
		else
		{
			if (image != null && image != '')
				loadGraphic(Paths.image(image));
			active = false;
		}

		scrollFactor.set(xScroll, yScroll);
		antialiasing = true;
	}

	public function defaultDance() //lol funni
	{
		if (defaultAnim != null)
			animation.play(defaultAnim);
	}
}