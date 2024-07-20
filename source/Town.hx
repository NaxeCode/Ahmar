package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class Town extends FlxState
{
	// var player:Player;
	var pic:FlxSprite;
	var txt:FlxText;

	override function create()
	{
		super.create();

		FlxG.camera.bgColor = FlxColor.BROWN;

		pic = new FlxSprite();
		pic.makeGraphic(32, 32);
		pic.screenCenter();
		add(pic);

		FlxTween.tween(pic, {x: FlxG.width - pic.width - 50, y: FlxG.height - pic.height - 50, angle: 360}, 3,
			{type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});

		txt = new FlxText();
		txt.text = "Hello I'm AL";
		txt.screenCenter();
		txt.y += 40;
		add(txt);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
