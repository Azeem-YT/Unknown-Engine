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

    public function new(x:Float, y:Float, noteData:Int){
        super(x, y);

        texture = 'noteSplashes';

        addAnims(texture);

        addSplash(x, y, noteData);
        antialiasing = true;
    }

    public function addSplash(x:Float, y:Float, noteData:Int, ?texture:String, ?threePlayer:Bool = false)
    {
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

        offset.set(10, 10);

        if (alpha <= 0)
            alpha = 1;

        if (threePlayer)
        {
            scale.x = 0.8;
            scale.y = 0.8;
        }

        playAnim(anim);
    }

    function addAnims(texture:String)
    {
        frames = Paths.getSparrowAtlas('noteSplashes/' + texture);

        var anims:Array<String> = ["purple", "blue", "green", "red"];

        var randomInt:Int = FlxG.random.int(1, 2);

        var anim:String = 'note impact ' + randomInt + ' ';
        
        animation.addByPrefix('purple', anim + 'purple', 24, false);
        animation.addByPrefix('blue', anim + 'blue', 24, false);
        animation.addByPrefix('green', anim + 'green', 24, false);
        animation.addByPrefix('red', anim + 'red', 24, false);

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