package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class BGSprite extends FlxSprite
{
	public var defaultAnim:String = null;

	public function new(image:String, x:Float, y:Float, ?xScroll:Float = 1, ?yScroll:Float = 1, ?anims:Array<String> = null, ?loop:Bool = false)
	{
		super(x, y);

		if (anims != null)
		{
			#if desktop
			frames = Paths.getModSparrowAtlas(image);

			if (frames == null) 
			{
				if (PlayState.instance.libraryToUse != null)
					frames = Paths.getSparrowAtlas(image, PlayState.instance.libraryToUse);
				else
					frames = Paths.getSparrowAtlas(image);
			}
			#else
			if (PlayState.instance.libraryToUse != null)
				frames = Paths.getSparrowAtlas(image, PlayState.instance.libraryToUse);
			else
				frames = Paths.getSparrowAtlas(image);
			#end


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
			{
				#if desktop
				if (FileSystem.exists(Paths.modImages(image)))
					loadGraphic(Paths.getImage(image));
				else
				#end
					if (PlayState.instance.libraryToUse != null)
						loadGraphic(Paths.image(image, PlayState.instance.libraryToUse));
					else
						loadGraphic(Paths.image(image));
			}

			active = false;
		}

		scrollFactor.set(xScroll, yScroll);
		antialiasing = true;
	}

	public function dance()
	{
		if (defaultAnim != null)
			animation.play(defaultAnim);
	}
}