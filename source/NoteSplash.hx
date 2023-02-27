package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end
import helpers.*;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import shaderslmfao.ColorSwap;

using StringTools;

typedef SplashData = {
    var splashAnims:Array<SplashShit>;
    var splashTexture:String;
    var useFrames:Bool;
    var xOffset:Float;
    var yOffset:Float;
}

typedef SplashShit = {
    var anim:String;
    var prefix:String;
    var frames:Int;
    var hasRandom:Bool;
    var splashFrames:Array<Int>;
}

class NoteSplash extends FlxSprite
{
    public var texture(default, set):String;
    public var anim:String;
    public var textureLoaded:Bool = false;
    public var textureOverride:String = null;
    public var splashFrames:Array<Array<Int>> = null;
    public var splashData:SplashData;
    public var jsonPath:String = null;
    public var animList:Array<String> = [];
    public var noteColors:Array<String> = ['purple', 'blue', 'green', 'red'];
    public var useJson:Bool = false;
    public var colorSwap:ColorSwap;

    public function new(x:Float, y:Float, noteData:Int, splashID:String = 'default'){
        super(x, y);

        var textureShit:String = 'noteSplashes';

        #if desktop
        if (FileSystem.exists(Paths.modJson('noteSplashes/' + splashID))) {
            useJson = true;
            jsonPath = Paths.modJson('noteSplashes/' + splashID);
            splashData = Json.parse(File.getContent(jsonPath));
            textureShit = splashData.splashTexture;
        }
        else #end if (Assets.exists(Paths.json('noteSplashes/' + splashID))) {
            useJson = true;
            jsonPath = Paths.json('noteSplashes/' + splashID);
            splashData = Json.parse(File.getContent(jsonPath));
            textureShit = splashData.splashTexture;
        }
        else {
            useJson = false;
            textureShit = 'noteSplashes';
            splashData = null;
        }

        texture = textureShit;

        colorSwap = new ColorSwap();
        shader = colorSwap.shader;
		colorSwap.update(Note.arrowColors[noteData]);

        antialiasing = true;
    }

    public function addSplash(x:Float, y:Float, noteData:Int, ?texture:String)
    {
        if (textureOverride != null && textureOverride != texture)
            this.texture = textureOverride;

        anim = noteColors[noteData];

        setPosition(x - 70, y - 70);

        if (splashData != null)
            offset.set(splashData.xOffset, splashData.yOffset);
        else
            offset.set(10, 10);

        if (alpha <= 0)
            alpha = 0.8;

        playAnim(anim);
    }
    
    inline function set_texture(str:String):String {
        frames = Paths.getSparrowAtlas('noteSplashes/' + str);

        if (frames == null)
            frames = Paths.getSparrowAtlas('noteSplashes/noteSplashes');

        var randomInt:Int = FlxG.random.int(1, 2);

        var anim:String = 'note impact ' + randomInt + ' ';
        var animData:Array<String> = [];
        var animPrefixs:Array<String> = [];

        if (useJson && splashData != null) {
            for (i in 0...splashData.splashAnims.length) {
                if (splashData.splashAnims[i].hasRandom) {
                    animPrefixs.push(splashData.splashAnims[i].prefix);
                    var splitData:Array<String> = [];
                    var animToAdd:String = '';

                    splitData = splashData.splashAnims[i].anim.split("split");
                    animToAdd = splitData[0] + randomInt;
                    if (splitData[1] == null)
                        animToAdd += '';
                    else
                        animToAdd += splitData[1];

                    animData.push(animToAdd);
                }
            }
        }
        
        if (useJson && splashData != null)
        {
           if (splashData.useFrames) {
                for (i in 0...splashData.splashAnims.length)
                    animation.add(noteColors[i], splashData.splashAnims[i].splashFrames, splashData.splashAnims[i].frames, false);
           }
           else {
                for (i in 0...splashData.splashAnims.length)
                    animation.addByPrefix(noteColors[i], animData[i], splashData.splashAnims[i].frames, false);
           }
        }
        else
        {
            animation.addByPrefix('purple', anim + 'purple', 24, false);
            animation.addByPrefix('blue', anim + 'blue', 24, false);
            animation.addByPrefix('green', anim + 'green', 24, false);
            animation.addByPrefix('red', anim + 'red', 24, false);
        }

        animList = animation.getNameList();

        if (frames != null)
            textureLoaded = true;

        return str;
    }

    function addAnims(texture:String)
    {
        if (textureOverride != null)
            frames = Paths.getSparrowAtlas('noteSplashes/' + textureOverride);
        else
            frames = Paths.getSparrowAtlas('noteSplashes/' + texture);

        if (frames == null)
            frames = Paths.getSparrowAtlas('noteSplashes/noteSplashes');

        var randomInt:Int = FlxG.random.int(1, 2);

        var anim:String = 'note impact ' + randomInt + ' ';
        var animData:Array<String> = [];
        var animPrefixs:Array<String> = [];

        if (splashData != null) {
            for (i in 0...splashData.splashAnims.length) {
                if (splashData.splashAnims[i].hasRandom) {
                    animPrefixs.push(splashData.splashAnims[i].prefix);
                    var splitData:Array<String> = [];
                    var animToAdd:String = '';

                    splitData = splashData.splashAnims[i].anim.split("split");
                    animToAdd = splitData[0] + randomInt;
                    if (splitData[1] == null)
                        animToAdd += '';
                    else
                        animToAdd += splitData[1];

                    animData.push(animToAdd);
                }
            }
        }
        
        if (splashData != null)
        {
           if (splashData.useFrames) {
                for (i in 0...splashData.splashAnims.length)
                    animation.add(noteColors[i], splashData.splashAnims[i].splashFrames, splashData.splashAnims[i].frames, false);
           }
           else {
                for (i in 0...splashData.splashAnims.length)
                    animation.addByPrefix(noteColors[i], animData[i], splashData.splashAnims[i].frames, false);
           }
        }
        else
        {
            animation.addByPrefix('purple', anim + 'purple', 24, false);
            animation.addByPrefix('blue', anim + 'blue', 24, false);
            animation.addByPrefix('green', anim + 'green', 24, false);
            animation.addByPrefix('red', anim + 'red', 24, false);
        }

        animList = animation.getNameList();

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