package;

import flixel.FlxGame;
import levels.PrototypeState;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(1920, 1080, PrototypeState, 60, 60, true));
	}
}
