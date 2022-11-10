package optionHelpers;

import flixel.*;

class CheckBox extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float, y:Float)
	{
		animOffsets = new Map<String, Array<Dynamic>>();

		frames = Paths.getSparrowAtlas('checkboxThingie');
		antialiasing = true;

		animation.addByPrefix('false-finished', 'Check Box unselected');
		animation.addByIndices('false', 'uncheck', [10, 9, 8, 7, 6, 5, 4, 3, 2, 1], "", 12, false);
		animation.addByPrefix('true-finished', 'Check Box Selected Static');
		animation.addByIndices('true', 'Check Box selecting animation', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], "", 12, false);

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		addOffset('false', 45, 5);
		addOffset('true', 45, 5);
		addOffset('true-finished', 45, 5);
		addOffset('false-finished', 45, 5);

		super(x, y);
	}

	public function playAnim(AnimName:String, Forced:Bool = false)
	{
		animation.play(AnimName, Forced);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	override public function update(elapsed:Float)
	{
		if (animation != null)
		{
			if (animation.curAnim.finished && animation.curAnim.name == 'true-checking')
				playAnim('true-finished');
			if (animation.curAnim.finished && animation.curAnim.name == 'false-unchecking')
				playAnim('false-finished');
		}

		super.update(elapsed);
	}
}