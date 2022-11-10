package helpers;

import flixel.FlxG;
import openfl.utils.AssetType;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class UnkownEngineHelpers
{
    public static var moduleStarted:Bool = false;

    public static function getCustomPath(file:String, type:AssetType, ?library:Null<String>, isMod:Bool = false)
    {
        #if MODDING_ALLOWED
        if (isMod)
         return Paths.getModPath(file, type, library);
        else
        #end
         return Paths.getPath(file, type, library);
    }

    public static function getShaderFile(type:String, file:String, isMod:Bool = false)
    {
        var daType:String = type.toLowerCase();

        #if MODDING_ALLOWED
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
        if (FileSystem.exists('mods/characters/' + char + '.json'))
            return 'mods/characters/$char.json';
        else
            return 'assets/characters/$char.json';
    }
}