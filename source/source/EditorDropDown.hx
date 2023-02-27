package;

import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.StrNameLabel;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIButton;

/**
 * @author larsiusprime
 */
class EditorDropDown extends FlxUIDropDownMenu
{	
	var listLength:Int = 0;
	var scroll:Int = 0;

	public function new(X:Float = 0, Y:Float = 0, DataList:Array<StrNameLabel>, ?Callback:String->Void, ?Header:FlxUIDropDownHeader,
			?DropPanel:FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?UIControlCallback:Bool->FlxUIDropDownMenu->Void){
		super(X, Y, DataList, Callback, Header, DropPanel, ButtonList, UIControlCallback);
		dropDirection = Down;
	}

	private function updateList():Void {
		var buttonHeight = header.background.height;
		var offset = dropPanel.y; 

		for (i in 0...scroll) {
			if (list[i] != null)
				list[i].y = -99999;
		}

		for (i in scroll...listLength) {
			if (list[i] != null) {
				list[i].y = offset;
				offset += buttonHeight;
			}
		}
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		listLength = list.length;

		#if FLX_MOUSE
		if (dropPanel.visible)
		{
			if (listLength > 1){
				scroll--;
				updateList();
			}

			if(listLength > 1) 
			{
				if(FlxG.mouse.wheel > 0 || FlxG.keys.justPressed.UP) {
					scroll--;
					if (scroll < 0)
						scroll = 0;

					updateList();
				}
				else if (FlxG.mouse.wheel < 0 || FlxG.keys.justPressed.DOWN) {
					// Go down
					scroll--;
					if (scroll >= listLength)
						scroll = listLength - 1;

					updateList();
				}
			}
		}
		#end
	}
}