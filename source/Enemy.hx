package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class Enemy extends FlxSprite
{
	public function new(X:Int = 0, Y:Int = 0)
	{
		super(X, Y);

		makeGraphic(16, 16, 0xff00ff00);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		checkFlxRect();
	}

	public function checkFlxRect()
	{
		// trace(ID + " ID = " + FlxMath.pointInFlxRect(this.x, this.y, Reg.playerRect));
		if (FlxG.overlap(this, Reg.playerRectObject))
		{
			trace("Enemy ID " + ID + " is dead");
			this.kill();
		}
	}
}
