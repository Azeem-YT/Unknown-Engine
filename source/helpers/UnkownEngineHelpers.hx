package helpers;

import flixel.FlxG;
import openfl.utils.AssetType;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class UnkownEngineHelpers
{
    public static var moduleStarted:Bool = false;
    public static var foundCharFiles:Array<String> = [];

    public static function getCustomPath(file:String, type:AssetType, ?library:Null<String>, isMod:Bool = false)
    {
        return Paths.getPath(file, type, library);
    }

    public static function getShaderFile(type:String, file:String, isMod:Bool = false)
    {
        var daType:String = type.toLowerCase();

        #if desktop
        if (isMod)
        {
            switch (daType)
            {
               case 'frag' | 'fragment':
                    return File.getContent('mods/shaders/$file.frag');
               case 'verg' | 'vertex':
                    return File.getContent('mods/shaders/$file.verg');
            }
        }
        else
        {
           switch (daType)
           {
                case 'frag' | 'fragment':
                    return File.getContent('assets/shaders/$file.frag');
                case 'verg' | 'vertex':
                    return File.getContent('assets/shaders/$file.verg');
           }
        }
        #else
        switch (daType)
        {
            case 'frag' | 'fragment':
                return File.getContent('assets/shaders/$file.frag');
            case 'verg' | 'vertex':
                return File.getContent('assets/shaders/$file.verg');
        }
        #end

        return return File.getContent('assets/shaders/$file.frag');
    }

    public static function resetGame()
    {
        trace("Reseting Game");
        FlxG.resetGame();
    }

    public static function getCharJson(char:String)
    {
        #if desktop
        if (FileSystem.exists('mods/characters/' + char + '.json'))
            return 'mods/characters/$char.json';
        else
        #end
            return 'assets/characters/$char.json';
    }
}