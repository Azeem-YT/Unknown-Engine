package helpers;

import flixel.FlxG;
import openfl.utils.AssetType;
import sys.FileSystem;
import sys.io.File;
import lime.utils.Assets;
import flixel.FlxSprite;

using StringTools;

class UnkownEngineHelpers
{
    public static function resetGame() {
        trace("Reseting Game");
        FlxG.resetGame();
    }

    public static function getImagePixelWidth(texture:String = ''):Int {
        if (texture != null && texture != '') {
            var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(texture));

            if (sprite != null)
                return Math.floor(sprite.width / 4);
        }

        return 0;
    }
    
    public static function getImagePixelHeight(texture:String = ''):Int {
        if (texture != null && texture != '') {
            var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(texture));
            if (sprite != null)
                return Math.floor(sprite.height / 5);
        }

        return 0;
    }

    public static function getCharJson(char:String, isPlayer:Bool = false)
    {
        if (FileSystem.exists(Paths.mods('characters/$char-player.json')))
            return Paths.mods('characters/$char-player.json');

        if (FileSystem.exists(Paths.mods('characters/$char.json')))
            return Paths.mods('characters/$char.json');

        if (Assets.exists(Paths.getPreloadPath('characters/$char-player.json')))
            return Paths.getPreloadPath('characters/$char-player.json');

        return Paths.getPreloadPath('characters/$char.json');
    }
}