package;

import flixel.*;
import flixel.math.FlxMath;
import options.OptionsState;

using StringTools;

class OptionPref
{
	public var optionType:String;
	public var optionName:String;
	public var curValue:Dynamic = 0;
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
	public var enterFunction:Void -> Void;
	public var checked:Bool = false;
	public var checkmark:AlphaCheckbox;
	public var selector:AlphaSelector;
	public var stringSelector:StringSelector;
	public var alphaText:Alphabet;
	public var targetY:Float = 0;
	public var variableName:String;
	public var text:String = '';

	public function new(variableName:String, optionText:String, optionType:String, defaultValue:Dynamic = null, ?min:Dynamic, ?max:Dynamic, ?valueAddBy:Float = 10, ?options:Array<String>, ?enterFunc:Void -> Void)
	{
		this.optionType = optionType;
		this.variableName = variableName;
		maxValue = max;
		minValue = min;
		valueToAdd = valueAddBy;
		optionName = optionText;
		this.curValue = getValue();

		switch (optionType)
		{
			case 'integer':
				optionType = 'int';
			case 'booleen':
				optionType = 'bool';
			case 'fl':
				optionType = 'float';
			case 'str':
				optionType = 'string';
		}

		switch (this.optionType) {
			case 'bool':
				checkmark = new AlphaCheckbox(0, 0, getValue());
			case 'float':
				selector = new AlphaSelector(0, 0, curValue, defaultValue, 'Float');
			case 'int':
				selector = new AlphaSelector(0, 0, curValue, defaultValue, 'Int');
			case 'string':
				optionsArray = options;
				stringSelector = new StringSelector(0, 0, curValue, defaultValue, optionsArray);
				stringSelector.setText(curSelected);
			case 'function':
				enterFunction = enterFunc;
		}
	}

	public function setCheckmark(){
		checkmark.getChecked(getValue());
	}

	public function onPressLeft(?endFunction:Void -> Void)
	{
		switch (optionType)
		{
			case 'int' | 'float':
				curValue -= valueToAdd;

				if (curValue < minValue)
					curValue = minValue;

				if (optionType == 'float')
					selector.setText(Std.string(FlxMath.roundDecimal(curValue, 1)));
				else
					selector.setText(Std.string(Math.round(curValue)));

				if (optionType == 'int')
					setValue(Math.round(curValue));
				else
					setValue(curValue);
			case 'string':
				changeSelection(-1);
		}

		if (endFunction != null)
			endFunction();
	}

	public function onPressRight(?endFunction:Void -> Void)
	{
		switch (optionType)
		{
			case 'int' | 'float':
				curValue += valueToAdd;
				if (curValue > maxValue)
					curValue = maxValue;

				if (optionType == 'float')
					selector.setText(Std.string(FlxMath.roundDecimal(curValue, 1)));
				else
					selector.setText(Std.string(Math.round(curValue)));

				if (optionType == 'int')
					setValue(Math.round(curValue));
				else
					setValue(curValue);
			case 'string':
				changeSelection(1);
		}

		if (endFunction != null)
			endFunction();
	}

	public function onPressEnter(?onCheck:(isChecked:Bool) -> Void) {
		switch (optionType) {
			case 'bool':
				checkmark.switchCheck(function(isChecked:Bool){
					setValue(isChecked);
					if (onCheck != null)
						onCheck(checked);
				});
			case 'function':
				if (enterFunction != null)
					enterFunction();
		}
	}

	public function changeSelection(change:Int) //Used for String Options
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		optionSelected = optionsArray[curSelected];
		stringSelector.setText(curSelected);

		if (change > 0)
			stringSelector.onRight();
		else if (change < 0)
			stringSelector.onLeft();

		setValue(optionSelected);
	}

	public function setValueText() {
		if (optionType == 'float')
			selector.setText(Std.string(FlxMath.roundDecimal(curValue, 2)));
		else if (optionType == 'int')
			selector.setText(Std.string(Math.round(curValue)));
	}

	public function getValue():Dynamic
	{	

		if (Reflect.getProperty(PlayerPrefs, variableName) != null) {
			if (optionType == 'string') {
				if (PlayerPrefs.selectedOption.exists(variableName))
					curSelected = PlayerPrefs.selectedOption.get(variableName);
			}
			return Reflect.getProperty(PlayerPrefs, variableName);
		}

		return PlayerPrefs.modVariables.get(variableName);
	}

	public function setValue(value:Dynamic) {
		if (Reflect.getProperty(PlayerPrefs, variableName) != null) {
			Reflect.setProperty(PlayerPrefs, variableName, value);
			if (optionType == 'string')
				PlayerPrefs.selectedOption.set(variableName, curSelected);
		}
		else {
			PlayerPrefs.modVariables.set(variableName, value);
			if (optionType == 'string')
				PlayerPrefs.selectedOption.set(variableName, curSelected);
		}
		PlayerPrefs.savePrefs();
		trace('Set Seting: ' + variableName + ' to ' + value);
	}
}