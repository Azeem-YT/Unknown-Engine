package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;

class setSkinState extends MusicBeatState
{
	public var curSkin:String = "Default";
	var bg:FlxSprite;
	var ui-Box:FlxUITabMenu;
	var camUI:FlxCamera;
	var camNOTE:FlxCamera;
	
	override function create()
	{
		camNOTE = new FlxCamera();
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;

		FlxG.cameras.reset(camNOTE);
		FlxG.cameras.add(camUI);

		FlxCamera.defaultCameras = [camNOTE];
	
		if (FlxG.save.data.daSkin == null)
		{
			FlxG.save.data.daSkin = "Default";
		}

		curSkin = FlxG.save.data.daSkin;

		FlxG.mouse.visible = true;

		bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		add(bg);

		ui-Box = new FlxUITabMenu(null, tabs, true);

		ui-Box.resize(300, 400);
		ui-Box.x = FlxG.width / 2;
		ui-Box.y = 20;
		ui-Box.cameras = [camUI];
		add(ui-Box);
		addUI();

		super.create();
	}

	function addUI()
	{
		var playerNoteTexDropDown = new FlxUIDropDownMenu(140, 150, FlxUIDropDownMenu.makeStrIdLabelArray(noteTexVer, true), function(noteTex:String)
		{
			_song.notePlayerTexture = noteTexVer[Std.parseInt(noteTex)];
		});

		playerNoteTexDropDown.selectedLabel = _song.notePlayerTexture;

		var tab_ui = new FlxUI(null, UI_box);
		tab_ui.name = "Note";
		tab_ui.add(playerNoteTexDropDown);

		ui-Box.addGroup(tab_ui);
		ui-Box.scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}