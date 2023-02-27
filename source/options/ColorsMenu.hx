package options;

import flixel.FlxG;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import options.AtlasText;

class ColorsMenu extends MusicBeatSubstate
{
	var curSelected:Int = 0;

	var grpNotes:FlxTypedGroup<UINote>;
	var grpTexts:FlxTypedGroup<AtlasText>;

	override function create() {
		super.create();

		var menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.scrollFactor.set(0, 0);
		add(menuBG);

		grpNotes = new FlxTypedGroup<UINote>();
		add(grpNotes);
		
		grpTexts = new FlxTypedGroup<AtlasText>();
		add(grpTexts);

		UINote.arrowColors = Note.arrowColors;

		for (i in 0...4)
		{
			var note:UINote = new UINote(0, i);

			note.x += ((225 * i) + i);
			note.x = note.x + 250;
			note.screenCenter(Y);

			grpNotes.add(note);

			var text:BoldText = new BoldText(note.x - 25 + (i == 2 ? 50 : 0), note.y - 200, Note.arrowNames[note.noteData]);
			grpTexts.add(text);

		}

		for (i in 0...grpTexts.members.length)
			grpTexts.members[i].alpha = 0.6;			
			
		grpTexts.members[curSelected].alpha = 1;		
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_RIGHT_P)
			curSelected += 1;

		if (controls.UI_LEFT_P)
			curSelected -= 1;

		if (curSelected < 0)
			curSelected = grpNotes.members.length - 1;
		if (curSelected >= grpNotes.members.length)
			curSelected = 0;

		if (controls.UI_RIGHT_P)
			onSwitch();

		if (controls.UI_LEFT_P)
			onSwitch();

		if (controls.UI_UP) {
			updateColors(elapsed * 0.3);
		}

		if (controls.UI_DOWN) {
			updateColors(-elapsed * 0.3);
		}

		if (controls.BACK) {
			PlayerPrefs.savePrefs();
			close();
		}

		super.update(elapsed);
	}

	public function onSwitch() {
		FlxG.sound.play(Paths.sound('scrollMenu'));

		for (i in 0...grpTexts.members.length)
			grpTexts.members[i].alpha = 0.6;
					
		grpTexts.members[curSelected].alpha = 1;		
	}

	public function updateColors(change:Float = 0) {
		var noteMember:UINote = grpNotes.members[curSelected];
		noteMember.colorSwap.update(change);
		Note.arrowColors[curSelected] = noteMember.colorSwap.hueShit;
		UINote.arrowColors[curSelected] = Note.arrowColors[curSelected];
		PlayerPrefs.noteColors[curSelected] = Note.arrowColors[curSelected];
	}
}