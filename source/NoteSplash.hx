package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class NoteSplash extends FlxSprite
{
    public var texture:String;
    public var anim:String;
    public var textureLoaded:Bool = false;
    public var textureOverride:String = null;
    public var splashFrames:Array<Array<Int>> = null;

    public function new(x:Float, y:Float, noteData:Int){
        super(x, y);

        texture = 'noteSplashes';

        addAnims(texture);

        addSplash(x, y, noteData);
        antialiasing = true;
    }

    public function addSplash(x:Float, y:Float, noteData:Int, ?texture:String, ?threePlayer:Bool = false, ?textureOverride:String = null, ?offsetX:Float = 10, ?offsetY:Float = 10, ?splashFrames:Array<Array<Int>>)
    {
        if (textureOverride != null)
        {
            this.textureOverride = textureOverride;
            addAnims('noteSplashes');
        }

        this.splashFrames = splashFrames;

        switch (noteData)
        {
            case 0:
                anim = 'purple';
            case 1:
                anim = 'blue';
            case 2:
                anim = 'green';
            case 3:
                anim = 'red';
            default:
                anim = 'purple';
        }

        setPosition(x - 70, y - 70);

        if (offsetX != 10 && offsetY != 10)
            offset.set(offsetX, offsetY)
        else
            offset.set(10, 10);

        if (alpha <= 0)
            alpha = 0.8;

        if (threePlayer)
        {
            scale.x = 0.8;
            scale.y = 0.8;
        }

        playAnim(anim);
    }

    function addAnims(texture:String)
    {
        if (textureOverride != null)
        {
            #if desktop
            frames = Paths.getModSparrowAtlas('noteSplashes/' + textureOverride);

            if (frames == null)
            #end
                frames = Paths.getSparrowAtlas('noteSplashes/' + textureOverride);

            if (frames == null)
                frames = Paths.getSparrowAtlas('noteSplashes/' + texture);
        }
        else
            frames = Paths.getSparrowAtlas('noteSplashes/' + texture);

        var anims:Array<String> = ["purple", "blue", "green", "red"];

        var randomInt:Int = FlxG.random.int(1, 2);

        var anim:String = 'note impact ' + randomInt + ' ';
        
        if (splashFrames != null)
        {
            var purpleArray:Array<Int> = splashFrames[0];
            var blueArray:Array<Int> = splashFrames[1];
            var greenArray:Array<Int> = splashFrames[2];
            var redArray:Array<Int> = splashFrames[3];

            animation.add('purple', purpleArray, 24, false);
            animation.add('blue', blueArray, 24, false);
            animation.add('green', greenArray, 24, false);
            animation.add('red', redArray, 24, false);
        }
        else
        {
            animation.addByPrefix('purple', anim + 'purple', 24, false);
            animation.addByPrefix('blue', anim + 'blue', 24, false);
            animation.addByPrefix('green', anim + 'green', 24, false);
            animation.addByPrefix('red', anim + 'red', 24, false);
        }

        if (frames != null)
            textureLoaded = true;
    }

    public function playAnim(anim:String)
    {
       animation.play(anim);
    }

    override function update(elapsed:Float) {
        if(animation.curAnim != null)
            if(animation.curAnim.finished)
                kill();

        super.update(elapsed);
    }
}