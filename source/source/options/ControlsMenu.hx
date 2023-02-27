package options;

import Controls;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxActionInput;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import options.AtlasText;
import options.MenuList;
import options.TextMenuList;
import optionHelpers.*;
import helpers.*;

using StringTools;

class ControlsMenu extends MusicBeatSubstate
{
	inline static public var COLUMNS = 2;
	static var controlList = Control.createAll();
	public var enabled(default, set):Bool = false;
	public var canExit:Bool = true;
	static var controlGroups:Array<Array<Control>> = [
		[NOTE_LEFT, NOTE_DOWN, NOTE_UP, NOTE_RIGHT],
		[UI_LEFT, UI_DOWN, UI_UP, UI_RIGHT],
		[]
	];

	static var headerMap:Map<String, String> = [
		"NOTE_LEFT" => "NOTES_",
		"NOTE_DOWN" => "NOTES_",
		"NOTE_UP" => "NOTES_",
		"NOTE_RIGHT" => "NOTES_",
		"UI_LEFT" => "UI_",
		"UI_DOWN" => "UI_",
		"UI_UP" => "UI_",
		"UI_RIGHT" => "UI_"
	];

	var itemGroups:Array<Array<InputItem>> = [for (i in 0...controlGroups.length) []];
	var controlGrid:MenuTypedList<InputItem>;
	var deviceList:TextMenuList;
	var menuCamera:FlxCamera;
	var prompt:KeyPrompt;
	var camFollow:FlxObject;
	var labels:FlxTypedGroup<AtlasText>;

	var currentDevice:Device = Keys;
	var deviceListSelected = false;

	override function create()
	{
		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = 0x0;
		camera = menuCamera;

		var menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.scrollFactor.set(0, 0);
		add(menuBG);

		labels = new FlxTypedGroup<AtlasText>();
		var headers = new FlxTypedGroup<AtlasText>();
		controlGrid = new MenuTypedList(Columns(COLUMNS), Vertical);

		add(labels);
		add(headers);
		add(controlGrid);

		if (FlxG.gamepads.numActiveGamepads > 0)
		{
			var devicesBg = new FlxSprite();
			devicesBg.makeGraphic(FlxG.width, 100, 0xFFfafd6d);
			add(devicesBg);
			deviceList = new TextMenuList(Horizontal, None);
			add(deviceList);
			deviceListSelected = true;

			var item;

			item = deviceList.createItem("Keyboard", Bold, selectDevice.bind(Keys));
			item.x = FlxG.width / 2 - item.width - 30;
			item.y = (devicesBg.height - item.height) / 2;

			item = deviceList.createItem("Gamepad", Bold, selectDevice.bind(Gamepad(FlxG.gamepads.firstActive.id)));
			item.x = FlxG.width / 2 + 30;
			item.y = (devicesBg.height - item.height) / 2;
		}

		var y = deviceList == null ? 30 : 120;
		var spacer = 70;
		var currentHeader:String = null;

		currentHeader = "NOTES_";
		headers.add(new BoldText(0, y, "NOTES")).screenCenter(X); //Notes first
		y += spacer;

		var addedHeaders:Map<String, Bool> = new Map<String, Bool>();
		addedHeaders.set("NOTES", true);

		for (i in 0...controlList.length)
		{
			var control = controlList[i];
			var name = control.getName();

			if (currentHeader != "UI_" && name.indexOf("UI_") == 0)
			{
				currentHeader = "UI_";
				headers.add(new BoldText(0, y, "UI")).screenCenter(X);
				y += spacer;
				addedHeaders.set("UI", true);
			}

			if (currentHeader != null && name.indexOf(currentHeader) == 0)
				name = name.substr(currentHeader.length);

			var replacedName:String = name.toUpperCase();
			
			if (replacedName.contains("NOTE"))
				replacedName = StringTools.replace(replacedName, "NOTE", "");

			if (replacedName.contains("_"))
				replacedName = StringTools.replace(replacedName, "_", " ");

			if (replacedName.startsWith(' '))
				replacedName = StringTools.replace(replacedName, " ", "");

			var label = labels.add(new BoldText(150, y, replacedName));
			label.alpha = 0.6;
			for (i in 0...COLUMNS)
				createItem(label.x + 400 + i * 300, y, control, i);

			y += spacer;
		}

		camFollow = new FlxObject(FlxG.width / 2, 0, 70, 70);
		if (deviceList != null)
		{
			camFollow.y = deviceList.selectedItem.y;
			controlGrid.selectedItem.idle();
			controlGrid.enabled = false;
		}
		else
			camFollow.y = controlGrid.selectedItem.y;

		menuCamera.follow(camFollow, null, 0.06);
		var margin = 100;
		menuCamera.deadzone.set(0, margin, menuCamera.width, menuCamera.height - margin * 2);
		menuCamera.minScrollY = 0;
		controlGrid.onChange.add(function(selected)
		{
			camFollow.y = selected.y;

			labels.forEach((label) -> label.alpha = 0.6);
			labels.members[Std.int(controlGrid.selectedIndex / COLUMNS)].alpha = 1.0;
		});

		prompt = new KeyPrompt("\nPress any key to rebind\n\n\n\n    Escape to cancel");
		prompt.bgSprite.scrollFactor.set(0, 0);
		prompt.exists = false;
		add(prompt);
	}

	function createItem(x = 0.0, y = 0.0, control:Control, index:Int)
	{
		var item = new InputItem(x, y, currentDevice, control, index, onSelect);
		for (i in 0...controlGroups.length)
		{
			if (controlGroups[i].contains(control))
				itemGroups[i].push(item);
		}

		return controlGrid.addItem(item.name, item);
	}

	function onSelect():Void
	{
		controlGrid.enabled = false;
		enabled = false;
		canExit = false;
		prompt.exists = true;
	}

	function goToDeviceList()
	{
		controlGrid.selectedItem.idle();
		labels.members[Std.int(controlGrid.selectedIndex / COLUMNS)].alpha = 0.6;
		controlGrid.enabled = false;
		deviceList.enabled = true;
		enabled = true;
		canExit = true;
		camFollow.y = deviceList.selectedItem.y;
		deviceListSelected = true;
	}

	function selectDevice(device:Device)
	{
		currentDevice = device;

		for (item in controlGrid.members)
			item.updateDevice(currentDevice);

		var inputName = device == Keys ? "key" : "button";
		var cancel = device == Keys ? "Escape" : "Back";
		// todo: alignment
		if (device == Keys)
			prompt.setText('\nPress any key to rebind\n\n\n\n    $cancel to cancel');
		else
			prompt.setText('\nPress any button\n   to rebind\n\n\n $cancel to cancel');

		controlGrid.selectedItem.select();
		labels.members[Std.int(controlGrid.selectedIndex / COLUMNS)].alpha = 1.0;
		controlGrid.enabled = true;
		deviceList.enabled = false;
		deviceListSelected = false;
		enabled = false;
		canExit = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (canExit && controls.BACK)
			close();

		var controls = PlayerController.playerControl;
		if (controlGrid.enabled && deviceList != null && deviceListSelected == false && controls.BACK)
			goToDeviceList();

		if (prompt.exists)
		{
			switch (currentDevice)
			{
				case Keys:
					{
						// check released otherwise bugs can happen when you change the BACK key
						var key = FlxG.keys.firstJustReleased();
						if (key != NONE)
						{
							if (key != ESCAPE)
								onInputSelect(key);
							closePrompt();
						}
					}
				case Gamepad(id):
					{
						var button = FlxG.gamepads.getByID(id).firstJustReleasedID();
						if (button != NONE)
						{
							if (button != BACK)
								onInputSelect(button);
							closePrompt();
						}
					}
			}
		}

	}

	function onInputSelect(input:Int)
	{
		var item = controlGrid.selectedItem;

		// check if that key is already set for this
		var column0 = Math.floor(controlGrid.selectedIndex / 2) * 2;
		for (i in 0...COLUMNS)
		{
			if (controlGrid.members[column0 + i].input == input)
				return;
		}

		// Check if items in the same group already have the new input
		for (group in itemGroups)
		{
			if (group.contains(item))
			{
				for (otherItem in group)
				{
					if (otherItem != item && otherItem.input == input)
					{
						// replace that input with this items old input.
						PlayerController.playerControl.replaceBinding(otherItem.control, currentDevice, item.input, otherItem.input);
						// Don't use resetItem() since items share names/labels
						otherItem.input = item.input;
						otherItem.label.text = item.label.text;
					}
				}
			}
		}

		PlayerController.playerControl.replaceBinding(item.control, currentDevice, input, item.input);
		// Don't use resetItem() since items share names/labels
		item.input = input;
		item.label.text = item.getLabel(input);

		PlayerController.saveControls();
	}

	function closePrompt()
	{
		prompt.exists = false;
		controlGrid.enabled = true;
		if (deviceList == null)
			canExit = true;
	}

	override function destroy()
	{
		super.destroy();

		itemGroups = null;

		if (FlxG.cameras.list.contains(menuCamera))
			FlxG.cameras.remove(menuCamera);
	}

	inline function set_enabled(value:Bool):Bool
	{
		if (value == false) {
			controlGrid.enabled = false;
			if (deviceList != null)
				deviceList.enabled = false;
		}
		else {
			controlGrid.enabled = !deviceListSelected;
			if (deviceList != null)
				deviceList.enabled = deviceListSelected;
		}

		return value;
	}
}

class InputItem extends TextMenuItem
{
	public var device(default, null):Device = Keys;
	public var control:Control;
	public var input:Int = -1;
	public var index:Int = -1;

	public function new(x = 0.0, y = 0.0, device, control, index, ?callback)
	{
		this.device = device;
		this.control = control;
		this.index = index;
		this.input = getInput();

		super(x, y, getLabel(input), Default, callback);
	}

	public function updateDevice(device:Device)
	{
		if (this.device != device)
		{
			this.device = device;
			input = getInput();
			label.text = getLabel(input);
		}
	}

	function getInput()
	{
		var list = PlayerController.playerControl.getInputsFor(control, device);
		if (list.length > index)
		{
			if (list[index] != FlxKey.ESCAPE || list[index] != FlxGamepadInputID.BACK)
				return list[index];

			if (list.length > ControlsMenu.COLUMNS)
				// Escape isn't mappable, show a third option, instead.
				return list[ControlsMenu.COLUMNS];
		}

		return -1;
	}

	public function getLabel(input:Int)
	{
		return input == -1 ? "---" : InputFormatter.format(input, device);
	}
}
