package;

import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;
using flixel.util.FlxSpriteUtil;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class NotificationGroup extends FlxSpriteGroup
{
	public var notifGroup:FlxTypedGroup<Notification>;
	public var lastNotification:Notification = null;

	public function new() {
		notifGroup = new FlxTypedGroup<Notification>();
		//add(notifGroup);

		lastNotification = null;

		super();
	}

	public function addNotification(text:String) {
		var finalX:Float = -275;
		var finalY:Float = 0;

		if (lastNotification == null)
			finalY = 100;
		else
			finalY = lastNotification.textBG.y + (lastNotification.textBG.height * 2);

		var newNotif:Notification = new Notification(finalX, finalY, text);
		notifGroup.add(newNotif);
		if (lastNotification != null)
			newNotif.posNumber = lastNotification.posNumber + 1;
		newNotif.onFinish = function() {
			notifGroup.remove(newNotif);
			if (lastNotification.posNumber == newNotif.posNumber)
				lastNotification = null;
		}
		lastNotification = newNotif;
	}
}