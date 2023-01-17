package;

import flixel.*;
import flixel.math.FlxMath;
import OptionsState;

using StringTools;

class OptionPref extends FlxObject
{
	public var optionType:String;
	public var curValue:Float = 0;
	public var curSeleted:Int = 0;
	public var minValue:Dynamic = 0;
	public var maxValue:Float = 30;
	public var curSelected:Int = 0;
	public var optionsArray:Array<String> = [];
	public var optionSelected:String = '';
	public var valueToAdd:Float = 1;
	public var onLeft:Void -> Void;
	public var onRight:Void -> Void;
	public var onEnter:(isChecked:Bool) -> Void;
	public var isChecked:Bool = false;
	public var checkmark:AlphaCheckbox;
	public var selector:AlphaSelector;
	public var stringSelector:StringSelector;
	public var alphaText:Alphabet;
	public var targetY:Float = 0;
	public var variableName:String;
	public var text:String = '';

	public function new(x:Float, y:Float, variableName:String, optionText:String, optionType:String, curValue:Dynamic, parentClass:String = 'OptionPrefs', targetY:Float, defaultValue:Dynamic = null, ?min:Dynamic, ?max:Dynamic, ?valueAddBy:Float = 10, ?options:Array<String>)
	{
		this.optionType = optionType;
		this.targetY = targetY;
		this.variableName = variableName;
		alphaText = new Alphabet(x, y, optionText, true, false);
		alphaText.isMenuItem = true;
		alphaText.alpha = 0.6;
		alphaText.targetY = targetY;
		maxValue = max;
		minValue = min;
		valueToAdd = valueAddBy;
		this.curValue = curValue;

		switch (parentClass)
		{
			case 'ModPrefs':
				ModPrefs.instance.add(alphaText);
			case 'NotePrefs':
				NotePrefs.instance.add(alphaText);
			case 'OptionPrefs':
				OptionPrefs.instance.add(alphaText);
		}

		switch (optionType)
		{
			case 'integer':
				optionType = 'int';
			case 'booleen':
				optionType = 'bool';
		}

		if (this.optionType == 'bool') {
			checkmark = new AlphaCheckbox(x, y, getValue(), parentClass);
			checkmark.alphaParent = alphaText;
			switch (parentClass)
			{
				case 'ModPrefs':
					ModPrefs.instance.add(checkmark);
				case 'NotePrefs':
					NotePrefs.instance.add(checkmark);
				case 'OptionPrefs':
					OptionPrefs.instance.add(checkmark);
			}
		} else if (this.optionType == 'float') {
			selector = new AlphaSelector(x, y, min, max, curValue, defaultValue, 'Float');
			selector.alphaParent = alphaText;

			switch (parentClass)
			{
				case 'ModPrefs':
					ModPrefs.instance.add(selector);
				case 'NotePrefs':
					NotePrefs.instance.add(selector);
				case 'OptionPrefs':
					OptionPrefs.instance.add(selector);
			}
		} else if (this.optionType == 'int') {
			selector = new AlphaSelector(x, y, min, max, curValue, defaultValue, 'Int');
			selector.alphaParent = alphaText;

			switch (parentClass)
			{
				case 'ModPrefs':
					ModPrefs.instance.add(selector);
				case 'NotePrefs':
					NotePrefs.instance.add(selector);
				case 'OptionPrefs':
					OptionPrefs.instance.add(selector);
			}
		} else if (this.optionType == 'string' && options != null) {
			optionsArray = options;
			stringSelector = new StringSelector(x, y, curValue, defaultValue);
			stringSelector.alphaParent = alphaText;

			switch (parentClass)
			{
				case 'ModPrefs':
					ModPrefs.instance.add(stringSelector);
				case 'NotePrefs':
					NotePrefs.instance.add(stringSelector);
				case 'OptionPrefs':
					OptionPrefs.instance.add(stringSelector);
			}
		}

		super(x, y);
	}

	public function onPressLeft(?endFunction:Void -> Void)
	{
		if (optionType == 'float' || optionType == 'int') {
			curValue -= valueToAdd;

			if (curValue < minValue)
				curValue = minValue;

			if (optionType == 'float')
				selector.changeAlphaText(Std.string(FlxMath.roundDecimal(curValue, 1)));
			else
				selector.changeAlphaText(Std.string(Math.round(curValue)));

			if (optionType == 'int')
				setValue(Math.round(curValue));
			else
				setValue(curValue);
		}
		else if (optionType == 'string') {
			changeSelection(-1);
		}

		if (endFunction != null)
			endFunction();
	}

	public function onPressRight(?endFunction:Void -> Void)
	{
		var newValue:Dynamic = null;

		if (optionType == 'float' || optionType == 'int') {
			curValue += valueToAdd;
			if (curValue > maxValue)
				curValue = maxValue;

			if (optionType == 'float')
				selector.changeAlphaText(Std.string(FlxMath.roundDecimal(curValue, 1)));
			else
				selector.changeAlphaText(Std.string(Math.round(curValue)));

			if (optionType == 'int')
				setValue(Math.round(curValue));
			else
				setValue(curValue);
		}
		else if (optionType == 'string') {
			changeSelection(1);
		}

		if (endFunction != null)
			endFunction();
	}

	public function onPressEnter(?onCheck:(isChecked:Bool) -> Void) {
		checkmark.switchCheck(function(isChecked:Bool){
			setValue(isChecked);
			if (onCheck != null)
				onCheck(isChecked);
		});
	}

	public function changeSelection(change:Int) //Used for String Options
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		optionSelected = optionsArray[curSelected];
		stringSelector.alphaText = optionSelected;
		stringSelector.changeAlphaText(optionSelected);
		setValue(optionSelected);
	}

	override function update(elapsed:Float)
	{
		if (alphaText.targetY != targetY)
			alphaText.targetY = targetY;

		switch (optionType)
		{
			case 'bool':
				checkmark.checkbox.x = alphaText.lastSprite.x + 50;
				checkmark.checkbox.y = alphaText.lastSprite.y - 50;
			case 'int' | 'float':
				selector.y = alphaText.lastSprite.y;
				selector.x = alphaText.lastSprite.x + 50;
			case 'string':
				stringSelector.alphabetText.x = alphaText.lastSprite.x + (alphaText.lastSprite.width * 2);
				stringSelector.alphabetText.y = alphaText.y - 50;
		}

		super.update(elapsed);
	}

	public function getValue():Dynamic
		return Reflect.getProperty(PlayerPrefs, variableName);

	public function setValue(value:Dynamic) {
		Reflect.setProperty(PlayerPrefs, variableName, value);
		PlayerPrefs.savePrefs();
		Main.gameSettings.resetSettings();
		trace('Set Seting: ' + variableName + ' to ' + value);
	}
}

//typedef OptionType = OneOfFour<String, Float, Bool, Int>;