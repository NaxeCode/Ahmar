package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;

class DinnerRoom extends FlxState
{
	override function create()
	{
		super.create();
	}

	function level_create()
	{
		// Background Color
		FlxG.camera.bgColor = FlxColor.fromRGB(126, 126, 126);

		// Floor
		var floor = new FlxSprite(0, 0);
		floor.loadGraphic(AssetPaths.floor__png);
		add(floor);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
