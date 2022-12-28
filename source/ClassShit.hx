package;

import flixel.*;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class ClassShit extends MusicBeatState
{
    public static function switchState(nextState:FlxState):Void //Here so the Fps counter updates current State.
    {
        FPS.currentClass = Type.getClass(nextState);
        FlxG.switchState(nextState);
    }
}