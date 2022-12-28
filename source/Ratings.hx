package;

import flixel.FlxG;
import flixel.math.FlxMath;

using StringTools;

class Ratings
{
	public static var accuracy:Float;
	public static var letterRank:String;
	//public static var comboNum:Int;
	public static var notesHit:Int;
	public static var scoreText:String = '';
	public static var accuracyDisplay:Float;
	public static var missed:Bool = false;

	public static function resetAccuracy()
	{
		accuracy = 0.001;
		accuracyDisplay = 0;
		letterRank = 'N/A';

		notesHit = 0;
		//comboNum = 0;

		scoreText = 'Accuracy: 0.00%' + PlayState.instance.scoreDivider + ' Rank: ' + letterRank;
	}

	public static function onNoteHit(judgement:String = 'shit', isSustain:Bool = false)
	{
		var shit:Float = 0;

		switch (judgement)
		{
			case 'sick':
				shit = 100;
			case 'good':
				shit = 75;
			case 'bad':
				shit = 25;
			case 'shit':
				shit = -50;
			case 'miss': 
				shit = -100;
				if (!missed)
					missed = true;
			default:
				shit = 0;
		}

		if (isSustain) {
			accuracy += Math.max(0, shit) / 2;
		}
		else {
			notesHit++;
			accuracy += Math.max(0, shit);
		}

		accuracyDisplay = FlxMath.roundDecimal(accuracy / notesHit, 2);

		if (accuracyDisplay > 100)
			accuracyDisplay = 100;

		if (missed && accuracyDisplay >= 100)
			accuracyDisplay = 99.9; //Fak U

		updateRank();
		updateDisplay();
	}

	public static function updateRank()
	{
		if (accuracyDisplay >= 100)
			letterRank = 'S+'
		else if (accuracyDisplay < 100 && accuracyDisplay > 90)
			letterRank = 'S';
		else if (accuracyDisplay <= 90 && accuracyDisplay > 80)
			letterRank = 'A';
		else if (accuracyDisplay <= 80 && accuracyDisplay > 70)
			letterRank = 'B';
		else if (accuracyDisplay <= 70 && accuracyDisplay > 65)
			letterRank = 'C';
		else if (accuracyDisplay <= 65 && accuracyDisplay > 50)
			letterRank = 'D';
		else
			letterRank = 'F';
	}

	public static function updateDisplay()
	{
		scoreText = 'Accuracy: ' + accuracyDisplay + '%' + PlayState.instance.scoreDivider + ' Rank: ' + letterRank;
	}
}
